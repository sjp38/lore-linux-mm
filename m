Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 143CC6B0044
	for <linux-mm@kvack.org>; Mon, 30 Apr 2012 06:48:58 -0400 (EDT)
Received: by lagz14 with SMTP id z14so2498811lag.14
        for <linux-mm@kvack.org>; Mon, 30 Apr 2012 03:48:56 -0700 (PDT)
Subject: [PATCH v3] proc: report file/anon bit in /proc/pid/pagemap
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Mon, 30 Apr 2012 14:48:50 +0400
Message-ID: <20120430104850.11118.58938.stgit@zurg>
In-Reply-To: <4F91BC8A.9020503@parallels.com>
References: <4F91BC8A.9020503@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Rik van Riel <riel@redhat.com>, Pavel Emelyanov <xemul@parallels.com>, Hugh Dickins <hughd@google.com>, Matt Mackall <mpm@selenic.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Andrew Morton <akpm@linux-foundation.org>

This is an implementation of Andrew's proposal to extend the pagemap file
bits to report what is missing about tasks' working set.

The problem with the working set detection is multilateral. In the criu
(checkpoint/restore) project we dump the tasks' memory into image files
and to do it properly we need to detect which pages inside mappings are
really in use. The mincore syscall I though could help with this did not.
First, it doesn't report swapped pages, thus we cannot find out which
parts of anonymous mappings to dump. Next, it does report pages from page
cache as present even if they are not mapped, and it doesn't make
difference between private pages that has been cow-ed and private pages
that has not been cow-ed.

Note, that issue with swap pages is critical -- we must dump swap pages to
image file. But the issues with file pages are optimization -- we can take
all file pages to image, this would be correct, but if we know that a page
is not mapped or not cow-ed, we can remove them from dump file. The dump
would still be self-consistent, though significantly smaller in size (up
to 10 times smaller on real apps).

Andrew noticed, that the proc pagemap file solved 2 of 3 above issues -- it
reports whether a page is present or swapped and it doesn't report not
mapped page cache pages. But, it doesn't distinguish cow-ed file pages from
not cow-ed.

I would like to make the last unused bit in this file to report whether the
page mapped into respective pte is PageAnon or not.

[comment stolen from Pavel Emelyanov's v1 patch]

v2:
* Rebase to uptodate kernel
* Fix file/anon bit reporting for migration entries
* Fix frame bits interval comment, it uses 55 lower bits (64 - 3 - 6)

v3:
* fix stupid misprint s/if/else if/
* rebase on top of "[PATCH bugfix] proc/pagemap: correctly report non-present
  ptes and holes between vmas"
* second patch (with indexes for nonlinear mappings) was droppped.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Pavel Emelyanov <xemul@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Matt Mackall <mpm@selenic.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
---
 Documentation/vm/pagemap.txt |    2 +-
 fs/proc/task_mmu.c           |   48 ++++++++++++++++++++++++++----------------
 2 files changed, 31 insertions(+), 19 deletions(-)

diff --git a/Documentation/vm/pagemap.txt b/Documentation/vm/pagemap.txt
index 4600cbe..7587493 100644
--- a/Documentation/vm/pagemap.txt
+++ b/Documentation/vm/pagemap.txt
@@ -16,7 +16,7 @@ There are three components to pagemap:
     * Bits 0-4   swap type if swapped
     * Bits 5-54  swap offset if swapped
     * Bits 55-60 page shift (page size = 1<<page shift)
-    * Bit  61    reserved for future use
+    * Bit  61    page is file-page or shared-anon
     * Bit  62    page swapped
     * Bit  63    page present
 
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 9f9c033..b073971 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -700,6 +700,7 @@ struct pagemapread {
 
 #define PM_PRESENT          PM_STATUS(4LL)
 #define PM_SWAP             PM_STATUS(2LL)
+#define PM_FILE             PM_STATUS(1LL)
 #define PM_NOT_PRESENT      PM_PSHIFT(PAGE_SHIFT)
 #define PM_END_OF_BUFFER    1
 
@@ -733,22 +734,33 @@ static int pagemap_pte_hole(unsigned long start, unsigned long end,
 	return err;
 }
 
-static u64 swap_pte_to_pagemap_entry(pte_t pte)
+static void pte_to_pagemap_entry(pagemap_entry_t *pme,
+		struct vm_area_struct *vma, unsigned long addr, pte_t pte)
 {
-	swp_entry_t e = pte_to_swp_entry(pte);
-	return swp_type(e) | (swp_offset(e) << MAX_SWAPFILES_SHIFT);
-}
-
-static void pte_to_pagemap_entry(pagemap_entry_t *pme, pte_t pte)
-{
-	if (is_swap_pte(pte))
-		*pme = make_pme(PM_PFRAME(swap_pte_to_pagemap_entry(pte))
-				| PM_PSHIFT(PAGE_SHIFT) | PM_SWAP);
-	else if (pte_present(pte))
-		*pme = make_pme(PM_PFRAME(pte_pfn(pte))
-				| PM_PSHIFT(PAGE_SHIFT) | PM_PRESENT);
-	else
+	u64 frame, flags;
+	struct page *page = NULL;
+
+	if (pte_present(pte)) {
+		frame = pte_pfn(pte);
+		flags = PM_PRESENT;
+		page = vm_normal_page(vma, addr, pte);
+	} else if (is_swap_pte(pte)) {
+		swp_entry_t entry = pte_to_swp_entry(pte);
+
+		frame = swp_type(entry) |
+			(swp_offset(entry) << MAX_SWAPFILES_SHIFT);
+		flags = PM_SWAP;
+		if (is_migration_entry(entry))
+			page = migration_entry_to_page(entry);
+	} else {
 		*pme = make_pme(PM_NOT_PRESENT);
+		return;
+	}
+
+	if (page && !PageAnon(page))
+		flags |= PM_FILE;
+
+	*pme = make_pme(PM_PFRAME(frame) | PM_PSHIFT(PAGE_SHIFT) | flags);
 }
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
@@ -815,7 +827,7 @@ static int pagemap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 		if (vma && (vma->vm_start <= addr) &&
 		    !is_vm_hugetlb_page(vma)) {
 			pte = pte_offset_map(pmd, addr);
-			pte_to_pagemap_entry(&pme, *pte);
+			pte_to_pagemap_entry(&pme, vma, addr, *pte);
 			/* unmap before userspace copy */
 			pte_unmap(pte);
 		}
@@ -869,11 +881,11 @@ static int pagemap_hugetlb_range(pte_t *pte, unsigned long hmask,
  * For each page in the address space, this file contains one 64-bit entry
  * consisting of the following:
  *
- * Bits 0-55  page frame number (PFN) if present
+ * Bits 0-54  page frame number (PFN) if present
  * Bits 0-4   swap type if swapped
- * Bits 5-55  swap offset if swapped
+ * Bits 5-54  swap offset if swapped
  * Bits 55-60 page shift (page size = 1<<page shift)
- * Bit  61    reserved for future use
+ * Bit  61    page is file-page or shared-anon
  * Bit  62    page swapped
  * Bit  63    page present
  *

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
