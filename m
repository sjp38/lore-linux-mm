Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f171.google.com (mail-yk0-f171.google.com [209.85.160.171])
	by kanga.kvack.org (Postfix) with ESMTP id 009276B0038
	for <linux-mm@kvack.org>; Sat, 21 Mar 2015 17:14:29 -0400 (EDT)
Received: by ykfc206 with SMTP id c206so56784807ykf.1
        for <linux-mm@kvack.org>; Sat, 21 Mar 2015 14:14:29 -0700 (PDT)
Received: from mail-pd0-x22a.google.com (mail-pd0-x22a.google.com. [2607:f8b0:400e:c02::22a])
        by mx.google.com with ESMTPS id cc10si2357178pad.30.2015.03.19.03.55.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Mar 2015 03:55:47 -0700 (PDT)
Received: by pdnc3 with SMTP id c3so73065472pdn.0
        for <linux-mm@kvack.org>; Thu, 19 Mar 2015 03:55:47 -0700 (PDT)
Date: Thu, 19 Mar 2015 03:55:45 -0700
From: Kelley Nielsen <kelleynnn@gmail.com>
Subject: [RFC v7 2/2] mm: swapoff prototype: frontswap handling added
Message-ID: <20150319105545.GA8156@kelleynnn-virtual-machine>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, riel@surriel.com, riel@redhat.com, opw-kernel@googlegroups.com, hughd@google.com, akpm@linux-foundation.org, jamieliu@google.com, sjenning@linux.vnet.ibm.com, sarah.a.sharp@intel.com

The prototype of the new swapoff (without the quadratic complexity)
presently ignores the frontswap case. Pass the count of
pages_to_unuse down the page table walks in try_to_unuse(),
and return from the walk when the desired number of pages
has been swapped back in.

Signed-off-by: Kelley Nielsen <kelleynnn@gmail.com>
---
Changes since v6:

- In try_to_unuse(), copy pages_to_unuse to local fs_pages_to_unuse
  and pass by reference (instead of value) down the page table walk
- create #define FRONTSWAP_PAGES_UNUSED to pass special code
  back up the chain from unuse_pte_range()
- Test for this return code in try_to_unuse() and exit before
  orphans cleanup and retries
- In unuse_pte_range, move decrement of frontswap pages count
  next to call to delete_from_swap_cache(), so that it happens
  on every unused swap slot instead of every pte unmap
- Remove unnecessary goto after call to unuse_mm() in try_to_unuse()
- Remove blank line in shmem.c/shmem_unuse_inode()
---
 mm/swapfile.c | 60 +++++++++++++++++++++++++++++++++++++++++------------------
 1 file changed, 42 insertions(+), 18 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 79c47b6..e4f5289 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1144,9 +1144,11 @@ out_nolock:
 	return ret;
 }
 
+#define FRONTSWAP_PAGES_UNUSED 2
 static int unuse_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 				unsigned long addr, unsigned long end,
-				unsigned int type)
+				unsigned int type,
+				unsigned long *fs_pages_to_unuse)
 {
 	struct page *page;
 	swp_entry_t entry;
@@ -1169,6 +1171,8 @@ static int unuse_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 			continue;
 		if (found_type != type)
 			continue;
+		if ((*fs_pages_to_unuse > 0) && (!frontswap_test(si, offset)))
+				continue;
 
 		swap_map = &si->swap_map[offset];
 		if (!swap_count(*swap_map))
@@ -1205,11 +1209,18 @@ static int unuse_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 		if (PageSwapCache(page) && (swap_count(*swap_map) == 0)) {
 			wait_on_page_writeback(page);
 			delete_from_swap_cache(page);
+			if (*fs_pages_to_unuse > 0) {
+				(*fs_pages_to_unuse)--;
+				if (*fs_pages_to_unuse == 0)
+					ret = FRONTSWAP_PAGES_UNUSED;
+			}
 		}
 
 		SetPageDirty(page);
 		unlock_page(page);
 		page_cache_release(page);
+		if (ret == FRONTSWAP_PAGES_UNUSED)
+			goto out;
 try_next:
 		pte = pte_offset_map(pmd, addr);
 	} while (pte++, addr += PAGE_SIZE, addr != end);
@@ -1220,7 +1231,8 @@ out:
 
 static inline int unuse_pmd_range(struct vm_area_struct *vma, pud_t *pud,
 				unsigned long addr, unsigned long end,
-				unsigned int type)
+				unsigned int type,
+				unsigned long *fs_pages_to_unuse)
 {
 	pmd_t *pmd;
 	unsigned long next;
@@ -1231,8 +1243,9 @@ static inline int unuse_pmd_range(struct vm_area_struct *vma, pud_t *pud,
 		next = pmd_addr_end(addr, end);
 		if (pmd_none_or_trans_huge_or_clear_bad(pmd))
 			continue;
-		ret = unuse_pte_range(vma, pmd, addr, next, type);
-		if (ret < 0)
+		ret = unuse_pte_range(vma, pmd, addr, next, type,
+				fs_pages_to_unuse);
+		if (ret < 0 || ret == 2)
 			return ret;
 	} while (pmd++, addr = next, addr != end);
 	return 0;
@@ -1240,7 +1253,8 @@ static inline int unuse_pmd_range(struct vm_area_struct *vma, pud_t *pud,
 
 static inline int unuse_pud_range(struct vm_area_struct *vma, pgd_t *pgd,
 				unsigned long addr, unsigned long end,
-				unsigned int type)
+				unsigned int type,
+				unsigned long *fs_pages_to_unuse)
 {
 	pud_t *pud;
 	unsigned long next;
@@ -1251,14 +1265,16 @@ static inline int unuse_pud_range(struct vm_area_struct *vma, pgd_t *pgd,
 		next = pud_addr_end(addr, end);
 		if (pud_none_or_clear_bad(pud))
 			continue;
-		ret = unuse_pmd_range(vma, pud, addr, next, type);
-		if (ret < 0)
+		ret = unuse_pmd_range(vma, pud, addr, next, type,
+				fs_pages_to_unuse);
+		if (ret < 0 || ret == 2)
 			return ret;
 	} while (pud++, addr = next, addr != end);
 	return 0;
 }
 
-static int unuse_vma(struct vm_area_struct *vma, unsigned int type)
+static int unuse_vma(struct vm_area_struct *vma, unsigned int type,
+		unsigned long *fs_pages_to_unuse)
 {
 	pgd_t *pgd;
 	unsigned long addr, end, next;
@@ -1272,14 +1288,16 @@ static int unuse_vma(struct vm_area_struct *vma, unsigned int type)
 		next = pgd_addr_end(addr, end);
 		if (pgd_none_or_clear_bad(pgd))
 			continue;
-		ret = unuse_pud_range(vma, pgd, addr, next, type);
-		if (ret < 0)
+		ret = unuse_pud_range(vma, pgd, addr, next, type,
+				fs_pages_to_unuse);
+		if (ret < 0 || ret == 2)
 			return ret;
 	} while (pgd++, addr = next, addr != end);
 	return 0;
 }
 
-static int unuse_mm(struct mm_struct *mm, unsigned int type)
+static int unuse_mm(struct mm_struct *mm, unsigned int type,
+		unsigned long *fs_pages_to_unuse)
 {
 	struct vm_area_struct *vma;
 	int ret = 0;
@@ -1287,7 +1305,7 @@ static int unuse_mm(struct mm_struct *mm, unsigned int type)
 	down_read(&mm->mmap_sem);
 	for (vma = mm->mmap; vma; vma = vma->vm_next) {
 		if (vma->anon_vma) {
-			ret = unuse_vma(vma, type);
+			ret = unuse_vma(vma, type, fs_pages_to_unuse);
 			if (ret)
 				break;
 		}
@@ -1342,7 +1360,6 @@ static unsigned int find_next_to_unuse(struct swap_info_struct *si,
 	return i;
 }
 
-/* TODO: frontswap */
 #define MAX_RETRIES 3
 int try_to_unuse(unsigned int type, bool frontswap,
 		 unsigned long pages_to_unuse)
@@ -1354,10 +1371,14 @@ int try_to_unuse(unsigned int type, bool frontswap,
 	struct swap_info_struct *si = swap_info[type];
 	struct page *page;
 	swp_entry_t entry;
+	unsigned long fs_pages_to_unuse = 0;
 	unsigned int i = 0;
 	unsigned int oldi = 0;
 	int retries = 0;
 
+	if (frontswap)
+		fs_pages_to_unuse = pages_to_unuse;
+
 retry:
 	retval = shmem_unuse(type);
 	if (retval)
@@ -1381,9 +1402,7 @@ retry:
 		mmput(prev_mm);
 		prev_mm = mm;
 
-		retval = unuse_mm(mm, type);
-		if (retval)
-			goto out_put;
+		retval = unuse_mm(mm, type, &fs_pages_to_unuse);
 
 		/*
 		 * Make sure that we aren't completely killing
@@ -1396,8 +1415,13 @@ retry:
 
 out_put:
 	mmput(prev_mm);
-	if (retval)
+	if (retval < 0)
+		goto out;
+	if (retval == FRONTSWAP_PAGES_UNUSED) {
+		retval = 0;
 		goto out;
+	}
+
 	while ((i = find_next_to_unuse(si, i, frontswap)) != 0) {
 		/*
 		 * under global memory pressure, swap entries
@@ -1410,7 +1434,7 @@ out_put:
 		 */
 		if (i < oldi) {
 			retries++;
-			if (retries > MAX_RETRIES) {
+			if ((retries > MAX_RETRIES) || frontswap) {
 				retval = -EBUSY;
 				goto out;
 			}
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
