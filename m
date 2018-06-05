Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id E8E226B0005
	for <linux-mm@kvack.org>; Tue,  5 Jun 2018 13:13:25 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id r2-v6so1831118wrm.15
        for <linux-mm@kvack.org>; Tue, 05 Jun 2018 10:13:25 -0700 (PDT)
Received: from outbound-smtp08.blacknight.com (outbound-smtp08.blacknight.com. [46.22.139.13])
        by mx.google.com with ESMTPS id a13-v6si24298869edk.364.2018.06.05.10.13.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Jun 2018 10:13:24 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp08.blacknight.com (Postfix) with ESMTPS id D21891C1CCF
	for <linux-mm@kvack.org>; Tue,  5 Jun 2018 18:13:23 +0100 (IST)
Date: Tue, 5 Jun 2018 18:13:19 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH] mremap: Avoid TLB flushing anonymous pages that are not in
 swap cache
Message-ID: <20180605171319.uc5jxdkxopio6kg3@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: mhocko@kernel.org, vbabka@suse.cz, Aaron Lu <aaron.lu@intel.com>, Dave Hansen <dave.hansen@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Commit 5d1904204c99 ("mremap: fix race between mremap() and page cleanning")
fixed races between mremap and other operations for both file-backed and
anonymous mappings. The file-backed was the most critical as it allowed the
possibility that data could be changed on a physical page after page_mkclean
returned which could trigger data loss or data integrity issues. A customer
reported that the cost of the TLBs for anonymous regressions was excessive
and resulting in a 30-50% drop in performance overall since this commit
on a microbenchmark. Unfortunately I neither have access to the test-case
nor can I describe what it does other than saying that mremap operations
dominate heavily.

The anonymous page race fix is overkill for two reasons. Pages that are not
in the swap cache are not going to be issued for IO and if a stale TLB entry
is used, the write still occurs on the same physical page. Any race with
mmap replacing the address space is handled by mmap_sem. As anonymous pages
are often dirty, it can mean that mremap always has to flush even when it is
not necessary.

This patch special cases anonymous pages to only flush if the page is in
swap cache and can be potentially queued for IO. It uses the page lock to
serialise against any potential reclaim. If the page is added to the swap
cache on the reclaim side after the page lock is dropped on the mremap
side then reclaim will call try_to_unmap_flush_dirty() before issuing
any IO so there is no data integrity issue. This means that in the common
case where a workload avoids swap entirely that mremap is a much cheaper
operation due to the lack of TLB flushes.

Using another testcase that simply calls mremap heavily with varying number
of threads, it was found that very broadly speaking that TLB shootdowns
were reduced by 31% on average throughout the entire test case but your
milage will vary.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/mremap.c | 42 +++++++++++++++++++++++++++++++++++++-----
 1 file changed, 37 insertions(+), 5 deletions(-)

diff --git a/mm/mremap.c b/mm/mremap.c
index 049470aa1e3e..d26c5a00fd9d 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -24,6 +24,7 @@
 #include <linux/uaccess.h>
 #include <linux/mm-arch-hooks.h>
 #include <linux/userfaultfd_k.h>
+#include <linux/mm_inline.h>
 
 #include <asm/cacheflush.h>
 #include <asm/tlbflush.h>
@@ -112,6 +113,41 @@ static pte_t move_soft_dirty_pte(pte_t pte)
 	return pte;
 }
 
+/* Returns true if a TLB must be flushed before PTL is dropped */
+static bool should_force_flush(pte_t *pte)
+{
+	bool is_swapcache;
+	struct page *page;
+
+	if (!pte_present(*pte) || !pte_dirty(*pte))
+		return false;
+
+	/*
+	 * If we are remapping a dirty file PTE, make sure to flush TLB
+	 * before we drop the PTL for the old PTE or we may race with
+	 * page_mkclean().
+	 */
+	page = pte_page(*pte);
+	if (page_is_file_cache(page))
+		return true;
+
+	/*
+	 * For anonymous pages, only flush swap cache pages that could
+	 * be unmapped and queued for swap since flush_tlb_batched_pending was
+	 * last called. Reclaim itself takes care that the TLB is flushed
+	 * before IO is queued. If a page is not in swap cache and a stale TLB
+	 * is used before mremap is complete then the write hits the same
+	 * physical page and there is no lost data loss. Check under the
+	 * page lock to avoid any potential race with reclaim.
+	 */
+	if (!trylock_page(page))
+		return true;
+	is_swapcache = PageSwapCache(page);
+	unlock_page(page);
+
+	return is_swapcache;
+}
+
 static void move_ptes(struct vm_area_struct *vma, pmd_t *old_pmd,
 		unsigned long old_addr, unsigned long old_end,
 		struct vm_area_struct *new_vma, pmd_t *new_pmd,
@@ -163,15 +199,11 @@ static void move_ptes(struct vm_area_struct *vma, pmd_t *old_pmd,
 
 		pte = ptep_get_and_clear(mm, old_addr, old_pte);
 		/*
-		 * If we are remapping a dirty PTE, make sure
-		 * to flush TLB before we drop the PTL for the
-		 * old PTE or we may race with page_mkclean().
-		 *
 		 * This check has to be done after we removed the
 		 * old PTE from page tables or another thread may
 		 * dirty it after the check and before the removal.
 		 */
-		if (pte_present(pte) && pte_dirty(pte))
+		if (should_force_flush(&pte))
 			force_flush = true;
 		pte = move_pte(pte, new_vma->vm_page_prot, old_addr, new_addr);
 		pte = move_soft_dirty_pte(pte);
