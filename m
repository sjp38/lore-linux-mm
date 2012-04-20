Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 9D4836B00E7
	for <linux-mm@kvack.org>; Fri, 20 Apr 2012 15:44:16 -0400 (EDT)
Message-ID: <4F91BC8A.9020503@parallels.com>
Date: Fri, 20 Apr 2012 23:44:10 +0400
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: [PATCH] proc: Report PageAnon in last left bit of /proc/pid/pagemap
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>

Hi!

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

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 7dcd2a2..23dde5d 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -617,6 +617,7 @@ struct pagemapread {
 
 #define PM_PRESENT          PM_STATUS(4LL)
 #define PM_SWAP             PM_STATUS(2LL)
+#define PM_FILE             PM_STATUS(1LL)
 #define PM_NOT_PRESENT      PM_PSHIFT(PAGE_SHIFT)
 #define PM_END_OF_BUFFER    1
 
@@ -649,15 +650,23 @@ static u64 swap_pte_to_pagemap_entry(pte_t pte)
 	return swp_type(e) | (swp_offset(e) << MAX_SWAPFILES_SHIFT);
 }
 
-static u64 pte_to_pagemap_entry(pte_t pte)
+static u64 pte_to_pagemap_entry(struct vm_area_struct *vma, unsigned long addr, pte_t pte)
 {
 	u64 pme = 0;
 	if (is_swap_pte(pte))
 		pme = PM_PFRAME(swap_pte_to_pagemap_entry(pte))
 			| PM_PSHIFT(PAGE_SHIFT) | PM_SWAP;
-	else if (pte_present(pte))
+	else if (pte_present(pte)) {
+		u64 page_flags = 0;
+		struct page *pg;
+
+		pg = vm_normal_page(vma, addr, pte);
+		if (pg && !PageAnon(pg))
+			page_flags = PM_FILE;
+
 		pme = PM_PFRAME(pte_pfn(pte))
-			| PM_PSHIFT(PAGE_SHIFT) | PM_PRESENT;
+			| PM_PSHIFT(PAGE_SHIFT) | PM_PRESENT | page_flags;
+	}
 	return pme;
 }
 
@@ -686,7 +695,7 @@ static int pagemap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 		if (vma && (vma->vm_start <= addr) &&
 		    !is_vm_hugetlb_page(vma)) {
 			pte = pte_offset_map(pmd, addr);
-			pfn = pte_to_pagemap_entry(*pte);
+			pfn = pte_to_pagemap_entry(vma, addr, *pte);
 			/* unmap before userspace copy */
 			pte_unmap(pte);
 		}
@@ -743,7 +752,7 @@ static int pagemap_hugetlb_range(pte_t *pte, unsigned long hmask,
  * Bits 0-4   swap type if swapped
  * Bits 5-55  swap offset if swapped
  * Bits 55-60 page shift (page size = 1<<page shift)
- * Bit  61    reserved for future use
+ * Bit  61    page is filepage
  * Bit  62    page swapped
  * Bit  63    page present
  *

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
