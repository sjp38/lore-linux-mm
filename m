Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 775A96B0005
	for <linux-mm@kvack.org>; Tue,  5 Jun 2018 15:51:43 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id x14-v6so2087309wrr.17
        for <linux-mm@kvack.org>; Tue, 05 Jun 2018 12:51:43 -0700 (PDT)
Received: from outbound-smtp25.blacknight.com (outbound-smtp25.blacknight.com. [81.17.249.193])
        by mx.google.com with ESMTPS id d3-v6si2232130edc.96.2018.06.05.12.51.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 05 Jun 2018 12:51:41 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp25.blacknight.com (Postfix) with ESMTPS id 66D83B888F
	for <linux-mm@kvack.org>; Tue,  5 Jun 2018 20:51:41 +0100 (IST)
Date: Tue, 5 Jun 2018 20:51:40 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mremap: Avoid TLB flushing anonymous pages that are not
 in swap cache
Message-ID: <20180605195140.afc7xzgbre26m76l@techsingularity.net>
References: <20180605171319.uc5jxdkxopio6kg3@techsingularity.net>
 <bfc2e579-915f-24db-0ff0-29bd9148b8c0@intel.com>
 <20180605191245.3owve7gfut22tyob@techsingularity.net>
 <ecb75c29-3d1b-3b5e-ec9d-59c4f6c1ef08@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <ecb75c29-3d1b-3b5e-ec9d-59c4f6c1ef08@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, mhocko@kernel.org, vbabka@suse.cz, Aaron Lu <aaron.lu@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Jun 05, 2018 at 12:49:18PM -0700, Dave Hansen wrote:
> >> I usually try to make the non-pte-modifying functions take a pte_t
> >> instead of 'pte_t *' to make it obvious that there no modification going
> >> on.  Any reason not to do that here?
> > 
> > No, it was just a minor saving on stack usage.
> 
> We're just splitting hairs now :) but, realistically, this little helper
> will get inlined anyway, so it probably all generates the same code.
> 

I expect so and your point is valid that it should be obvious that no
modifications can take place.

> ...
> >> BTW, do you want to add a tiny comment about why we do the
> >> trylock_page()?  I assume it's because we don't want to wait on finding
> >> an exact answer: we just assume it is in the swap cache if the page is
> >> locked and flush regardless.
> > 
> > It's really because calling lock_page while holding a spinlock is
> > eventually going to ruin your day.
> 
> Hah, yeah, that'll do it.  Could you comment this, too?
> 

Yep, I made the change after reading your mail. This is how it currently
stands

---8<---
mremap: Avoid excessive TLB flushing for anonymous pages that are not in swap cache

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

The anonymous page race fix is overkill for two reasons. Pages that are
not in the swap cache are not going to be issued for IO and if a stale TLB
entry is used, the write still occurs on the same physical page. Any race
with mmap replacing the address space is handled by mmap_sem. As anonymous
pages are often dirty, it can mean that mremap always has to flush even
when it is not necessary.

This patch special cases anonymous pages to only flush ranges under the
page table lock if the page is in swap cache and can be potentially queued
for IO. Note that the full flush of the range being mremapped is still
flushed so TLB flushes are not eliminated entirely.

It uses the page lock to serialise against any potential reclaim. If the
page is added to the swap cache on the reclaim side after the page lock is
dropped on the mremap side then reclaim will call try_to_unmap_flush_dirty()
before issuing any IO so there is no data integrity issue. This means that
in the common case where a workload avoids swap entirely that mremap is
a much cheaper operation due to the lack of TLB flushes.

Using another testcase that simply calls mremap heavily with varying number
of threads, it was found that very broadly speaking that TLB shootdowns
were reduced by 31% on average throughout the entire test case but your
milage will vary.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/mremap.c | 45 ++++++++++++++++++++++++++++++++++++++++-----
 1 file changed, 40 insertions(+), 5 deletions(-)

diff --git a/mm/mremap.c b/mm/mremap.c
index 049470aa1e3e..5b9767b0446e 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -24,6 +24,7 @@
 #include <linux/uaccess.h>
 #include <linux/mm-arch-hooks.h>
 #include <linux/userfaultfd_k.h>
+#include <linux/mm_inline.h>
 
 #include <asm/cacheflush.h>
 #include <asm/tlbflush.h>
@@ -112,6 +113,44 @@ static pte_t move_soft_dirty_pte(pte_t pte)
 	return pte;
 }
 
+/* Returns true if a TLB must be flushed before PTL is dropped */
+static bool should_force_flush(pte_t pte)
+{
+	bool is_swapcache;
+	struct page *page;
+
+	if (!pte_present(pte) || !pte_dirty(pte))
+		return false;
+
+	/*
+	 * If we are remapping a dirty file PTE, make sure to flush TLB
+	 * before we drop the PTL for the old PTE or we may race with
+	 * page_mkclean().
+	 */
+	page = pte_page(pte);
+	if (page_is_file_cache(page))
+		return true;
+
+	/*
+	 * For anonymous pages, only flush swap cache pages that could
+	 * be unmapped and queued for swap since flush_tlb_batched_pending was
+	 * last called. Reclaim itself takes care that the TLB is flushed
+	 * before IO is queued. If a page is not in swap cache and a stale TLB
+	 * is used before mremap is complete then the write hits the same
+	 * physical page and there is no lost data loss.
+	 *
+	 * Check under the page lock to avoid any potential race with reclaim.
+	 * trylock is necessary as spinlocks are currently held. In the unlikely
+	 * event of contention, flush the TLB to be safe.
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
@@ -163,15 +202,11 @@ static void move_ptes(struct vm_area_struct *vma, pmd_t *old_pmd,
 
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
+		if (should_force_flush(pte))
 			force_flush = true;
 		pte = move_pte(pte, new_vma->vm_page_prot, old_addr, new_addr);
 		pte = move_soft_dirty_pte(pte);

-- 
Mel Gorman
SUSE Labs
