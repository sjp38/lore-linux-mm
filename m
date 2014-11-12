Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 2B46F6B00B5
	for <linux-mm@kvack.org>; Tue, 11 Nov 2014 21:58:27 -0500 (EST)
Received: by mail-pd0-f172.google.com with SMTP id r10so11319251pdi.31
        for <linux-mm@kvack.org>; Tue, 11 Nov 2014 18:58:26 -0800 (PST)
Received: from mail-pd0-x22a.google.com (mail-pd0-x22a.google.com. [2607:f8b0:400e:c02::22a])
        by mx.google.com with ESMTPS id bj6si21519562pdb.237.2014.11.11.18.58.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 11 Nov 2014 18:58:25 -0800 (PST)
Received: by mail-pd0-f170.google.com with SMTP id z10so11350186pdj.1
        for <linux-mm@kvack.org>; Tue, 11 Nov 2014 18:58:25 -0800 (PST)
Date: Tue, 11 Nov 2014 18:58:23 -0800
From: Kelley Nielsen <kelleynnn@gmail.com>
Subject: [RFC v6 2/2] mm: swapoff prototype: frontswap handling added
Message-ID: <20141112025823.GA7464@kelleynnn-virtual-machine>
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
 mm/shmem.c    |  1 +
 mm/swapfile.c | 53 +++++++++++++++++++++++++++++++++++++----------------
 2 files changed, 38 insertions(+), 16 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index 2a7179c..e7a813f 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -629,6 +629,7 @@ static int shmem_unuse_inode(struct inode *inode, unsigned int type)
 	int entries = 0;
 	swp_entry_t entry;
 	unsigned int stype;
+
 	pgoff_t start = 0;
 	gfp = mapping_gfp_mask(mapping);
 
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 966862c..cc3887a 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1146,7 +1146,7 @@ out_nolock:
 
 static int unuse_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 				unsigned long addr, unsigned long end,
-				unsigned int type)
+				unsigned int type, unsigned long pages_to_unuse)
 {
 	struct page *page;
 	swp_entry_t entry;
@@ -1169,6 +1169,8 @@ static int unuse_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 			continue;
 		if (found_type != type)
 			continue;
+		if ((pages_to_unuse > 0) && (!frontswap_test(si, offset)))
+				continue;
 
 		swap_map = &si->swap_map[offset];
 		if (!swap_count(*swap_map))
@@ -1210,6 +1212,15 @@ static int unuse_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 		SetPageDirty(page);
 		unlock_page(page);
 		page_cache_release(page);
+		if (ret && pages_to_unuse > 0) {
+			pages_to_unuse--;
+			/*
+			 * we've unused all we need for frontswap,
+			 * so return special code to indicate this.
+			 */
+			if (pages_to_unuse == 0)
+				return 2;
+		}
 try_next:
 		pte = pte_offset_map(pmd, addr);
 	} while (pte++, addr += PAGE_SIZE, addr != end);
@@ -1220,7 +1231,7 @@ out:
 
 static inline int unuse_pmd_range(struct vm_area_struct *vma, pud_t *pud,
 				unsigned long addr, unsigned long end,
-				unsigned int type)
+				unsigned int type, unsigned long pages_to_unuse)
 {
 	pmd_t *pmd;
 	unsigned long next;
@@ -1231,8 +1242,9 @@ static inline int unuse_pmd_range(struct vm_area_struct *vma, pud_t *pud,
 		next = pmd_addr_end(addr, end);
 		if (pmd_none_or_trans_huge_or_clear_bad(pmd))
 			continue;
-		ret = unuse_pte_range(vma, pmd, addr, next, type);
-		if (ret < 0)
+		ret = unuse_pte_range(vma, pmd, addr, next, type,
+				pages_to_unuse);
+		if (ret < 0 || ret == 2)
 			return ret;
 	} while (pmd++, addr = next, addr != end);
 	return 0;
@@ -1240,7 +1252,7 @@ static inline int unuse_pmd_range(struct vm_area_struct *vma, pud_t *pud,
 
 static inline int unuse_pud_range(struct vm_area_struct *vma, pgd_t *pgd,
 				unsigned long addr, unsigned long end,
-				unsigned int type)
+				unsigned int type, unsigned long pages_to_unuse)
 {
 	pud_t *pud;
 	unsigned long next;
@@ -1251,14 +1263,16 @@ static inline int unuse_pud_range(struct vm_area_struct *vma, pgd_t *pgd,
 		next = pud_addr_end(addr, end);
 		if (pud_none_or_clear_bad(pud))
 			continue;
-		ret = unuse_pmd_range(vma, pud, addr, next, type);
-		if (ret < 0)
+		ret = unuse_pmd_range(vma, pud, addr, next, type,
+				pages_to_unuse);
+		if (ret < 0 || ret == 2)
 			return ret;
 	} while (pud++, addr = next, addr != end);
 	return 0;
 }
 
-static int unuse_vma(struct vm_area_struct *vma, unsigned int type)
+static int unuse_vma(struct vm_area_struct *vma, unsigned int type,
+		unsigned long pages_to_unuse)
 {
 	pgd_t *pgd;
 	unsigned long addr, end, next;
@@ -1272,14 +1286,16 @@ static int unuse_vma(struct vm_area_struct *vma, unsigned int type)
 		next = pgd_addr_end(addr, end);
 		if (pgd_none_or_clear_bad(pgd))
 			continue;
-		ret = unuse_pud_range(vma, pgd, addr, next, type);
-		if (ret < 0)
+		ret = unuse_pud_range(vma, pgd, addr, next, type,
+				pages_to_unuse);
+		if (ret < 0 || ret == 2)
 			return ret;
 	} while (pgd++, addr = next, addr != end);
 	return 0;
 }
 
-static int unuse_mm(struct mm_struct *mm, unsigned int type)
+static int unuse_mm(struct mm_struct *mm, unsigned int type,
+		unsigned long pages_to_unuse)
 {
 	struct vm_area_struct *vma;
 	int ret = 0;
@@ -1287,7 +1303,7 @@ static int unuse_mm(struct mm_struct *mm, unsigned int type)
 	down_read(&mm->mmap_sem);
 	for (vma = mm->mmap; vma; vma = vma->vm_next) {
 		if (vma->anon_vma) {
-			ret = unuse_vma(vma, type);
+			ret = unuse_vma(vma, type, pages_to_unuse);
 			if (ret)
 				break;
 		}
@@ -1342,7 +1358,6 @@ static unsigned int find_next_to_unuse(struct swap_info_struct *si,
 	return i;
 }
 
-/* TODO: frontswap */
 #define MAX_RETRIES 3
 int try_to_unuse(unsigned int type, bool frontswap,
 		 unsigned long pages_to_unuse)
@@ -1358,6 +1373,9 @@ int try_to_unuse(unsigned int type, bool frontswap,
 	unsigned int oldi = 0;
 	int retries = 0;
 
+	if (!frontswap)
+		pages_to_unuse = 0;
+
 retry:
 	retval = shmem_unuse(type);
 	if (retval)
@@ -1381,7 +1399,8 @@ retry:
 		mmput(prev_mm);
 		prev_mm = mm;
 
-		retval = unuse_mm(mm, type);
+		/* return code to stop and return */
+		retval = unuse_mm(mm, type, pages_to_unuse);
 		if (retval)
 			goto out_put;
 
@@ -1396,8 +1415,10 @@ retry:
 
 out_put:
 	mmput(prev_mm);
-	if (retval)
+	if (retval < 0)
 		goto out;
+	retval = 0;
+
 	while ((i = find_next_to_unuse(si, i, frontswap)) != 0) {
 		/*
 		 * under global memory pressure, swap entries
@@ -1410,7 +1431,7 @@ out_put:
 		 */
 		if (i < oldi) {
 			retries++;
-			if (retries > MAX_RETRIES)
+			if ((retries > MAX_RETRIES) || frontswap)
 				goto out;
 			goto retry;
 		}
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
