Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id E38ED6B0037
	for <linux-mm@kvack.org>; Thu, 28 Aug 2014 21:56:17 -0400 (EDT)
Received: by mail-qg0-f49.google.com with SMTP id j107so1661532qga.36
        for <linux-mm@kvack.org>; Thu, 28 Aug 2014 18:56:17 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d5si8575893qaf.22.2014.08.28.18.56.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Aug 2014 18:56:17 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v3 2/6] mm/hugetlb: take page table lock in follow_huge_(addr|pmd|pud)()
Date: Thu, 28 Aug 2014 21:38:56 -0400
Message-Id: <1409276340-7054-3-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1409276340-7054-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1409276340-7054-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

We have a race condition between move_pages() and freeing hugepages,
where move_pages() calls follow_page(FOLL_GET) for hugepages internally
and tries to get its refcount without preventing concurrent freeing.
This race crashes the kernel, so this patch fixes it by moving FOLL_GET
code for hugepages into follow_huge_pmd() with taking the page table lock.

This patch also adds the similar locking to follow_huge_(addr|pud)
for consistency.

Here is the reproducer:

  $ cat movepages.c
  #include <stdio.h>
  #include <stdlib.h>
  #include <numaif.h>

  #define ADDR_INPUT      0x700000000000UL
  #define HPS             0x200000
  #define PS              0x1000

  int main(int argc, char *argv[]) {
          int i;
          int nr_hp = strtol(argv[1], NULL, 0);
          int nr_p  = nr_hp * HPS / PS;
          int ret;
          void **addrs;
          int *status;
          int *nodes;
          pid_t pid;

          pid = strtol(argv[2], NULL, 0);
          addrs  = malloc(sizeof(char *) * nr_p + 1);
          status = malloc(sizeof(char *) * nr_p + 1);
          nodes  = malloc(sizeof(char *) * nr_p + 1);

          while (1) {
                  for (i = 0; i < nr_p; i++) {
                          addrs[i] = (void *)ADDR_INPUT + i * PS;
                          nodes[i] = 1;
                          status[i] = 0;
                  }
                  ret = numa_move_pages(pid, nr_p, addrs, nodes, status,
                                        MPOL_MF_MOVE_ALL);
                  if (ret == -1)
                          err("move_pages");

                  for (i = 0; i < nr_p; i++) {
                          addrs[i] = (void *)ADDR_INPUT + i * PS;
                          nodes[i] = 0;
                          status[i] = 0;
                  }
                  ret = numa_move_pages(pid, nr_p, addrs, nodes, status,
                                        MPOL_MF_MOVE_ALL);
                  if (ret == -1)
                          err("move_pages");
          }
          return 0;
  }

  $ cat hugepage.c
  #include <stdio.h>
  #include <sys/mman.h>
  #include <string.h>

  #define ADDR_INPUT      0x700000000000UL
  #define HPS             0x200000

  int main(int argc, char *argv[]) {
          int nr_hp = strtol(argv[1], NULL, 0);
          char *p;

          while (1) {
                  p = mmap((void *)ADDR_INPUT, nr_hp * HPS, PROT_READ | PROT_WRITE,
                           MAP_PRIVATE | MAP_ANONYMOUS | MAP_HUGETLB, -1, 0);
                  if (p != (void *)ADDR_INPUT) {
                          perror("mmap");
                          break;
                  }
                  memset(p, 0, nr_hp * HPS);
                  munmap(p, nr_hp * HPS);
          }
  }

  $ sysctl vm.nr_hugepages=40
  $ ./hugepage 10 &
  $ ./movepages 10 $(pgrep -f hugepage)

Note for stable inclusion:
  This patch fixes e632a938d914 ("mm: migrate: add hugepage migration code
  to move_pages()"), so is applicable to -stable kernels which includes it.

ChangeLog v3:
- remove unnecessary if (page) check
- check (pmd|pud)_huge again after holding ptl
- do the same change also on follow_huge_pud()
- take page table lock also in follow_huge_addr()

ChangeLog v2:
- introduce follow_huge_pmd_lock() to do locking in arch-independent code.

Reported-by: Hugh Dickins <hughd@google.com>
Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: <stable@vger.kernel.org>  # [3.12+]
---
 arch/ia64/mm/hugetlbpage.c    |  9 +++++++--
 arch/metag/mm/hugetlbpage.c   |  4 ++--
 arch/powerpc/mm/hugetlbpage.c | 22 +++++++++++-----------
 include/linux/hugetlb.h       | 12 ++++++------
 mm/gup.c                      | 25 ++++---------------------
 mm/hugetlb.c                  | 43 +++++++++++++++++++++++++++++++------------
 6 files changed, 61 insertions(+), 54 deletions(-)

diff --git mmotm-2014-08-25-16-52.orig/arch/ia64/mm/hugetlbpage.c mmotm-2014-08-25-16-52/arch/ia64/mm/hugetlbpage.c
index 52b7604b5215..6170381bf074 100644
--- mmotm-2014-08-25-16-52.orig/arch/ia64/mm/hugetlbpage.c
+++ mmotm-2014-08-25-16-52/arch/ia64/mm/hugetlbpage.c
@@ -91,17 +91,22 @@ int prepare_hugepage_range(struct file *file,
 
 struct page *follow_huge_addr(struct mm_struct *mm, unsigned long addr, int write)
 {
-	struct page *page;
+	struct page *page = NULL;
 	pte_t *ptep;
+	spinlock_t *ptl;
 
 	if (REGION_NUMBER(addr) != RGN_HPAGE)
 		return ERR_PTR(-EINVAL);
 
 	ptep = huge_pte_offset(mm, addr);
+	ptl = huge_pte_lock(hstate_vma(vma), vma->vm_mm, ptep);
 	if (!ptep || pte_none(*ptep))
-		return NULL;
+		goto out;
+
 	page = pte_page(*ptep);
 	page += ((addr & ~HPAGE_MASK) >> PAGE_SHIFT);
+out:
+	spin_unlock(ptl);
 	return page;
 }
 int pmd_huge(pmd_t pmd)
diff --git mmotm-2014-08-25-16-52.orig/arch/metag/mm/hugetlbpage.c mmotm-2014-08-25-16-52/arch/metag/mm/hugetlbpage.c
index 745081427659..5e96ef096df9 100644
--- mmotm-2014-08-25-16-52.orig/arch/metag/mm/hugetlbpage.c
+++ mmotm-2014-08-25-16-52/arch/metag/mm/hugetlbpage.c
@@ -104,8 +104,8 @@ int pud_huge(pud_t pud)
 	return 0;
 }
 
-struct page *follow_huge_pmd(struct mm_struct *mm, unsigned long address,
-			     pmd_t *pmd, int write)
+struct page *follow_huge_pmd(struct vm_area_struct *vma, unsigned long address,
+			     pmd_t *pmd, int flags)
 {
 	return NULL;
 }
diff --git mmotm-2014-08-25-16-52.orig/arch/powerpc/mm/hugetlbpage.c mmotm-2014-08-25-16-52/arch/powerpc/mm/hugetlbpage.c
index 9517a93a315c..1d8854a56309 100644
--- mmotm-2014-08-25-16-52.orig/arch/powerpc/mm/hugetlbpage.c
+++ mmotm-2014-08-25-16-52/arch/powerpc/mm/hugetlbpage.c
@@ -677,38 +677,38 @@ struct page *
 follow_huge_addr(struct mm_struct *mm, unsigned long address, int write)
 {
 	pte_t *ptep;
-	struct page *page;
+	struct page *page = ERR_PTR(-EINVAL);
 	unsigned shift;
 	unsigned long mask;
+	spinlock_t *ptl;
 	/*
 	 * Transparent hugepages are handled by generic code. We can skip them
 	 * here.
 	 */
 	ptep = find_linux_pte_or_hugepte(mm->pgd, address, &shift);
-
+	ptl = huge_pte_lock(hstate_vma(vma), vma->vm_mm, ptep);
 	/* Verify it is a huge page else bail. */
 	if (!ptep || !shift || pmd_trans_huge(*(pmd_t *)ptep))
-		return ERR_PTR(-EINVAL);
+		goto out;
 
 	mask = (1UL << shift) - 1;
-	page = pte_page(*ptep);
-	if (page)
-		page += (address & mask) / PAGE_SIZE;
-
+	page = pte_page(*ptep) + ((address & mask) >> PAGE_SHIFT);
+out:
+	spin_unlock(ptl);
 	return page;
 }
 
 struct page *
-follow_huge_pmd(struct mm_struct *mm, unsigned long address,
-		pmd_t *pmd, int write)
+follow_huge_pmd(struct vm_area_struct *vma, unsigned long address,
+		pmd_t *pmd, int flags)
 {
 	BUG();
 	return NULL;
 }
 
 struct page *
-follow_huge_pud(struct mm_struct *mm, unsigned long address,
-		pmd_t *pmd, int write)
+follow_huge_pud(struct vm_area_struct *vma, unsigned long address,
+		pud_t *pud, int flags)
 {
 	BUG();
 	return NULL;
diff --git mmotm-2014-08-25-16-52.orig/include/linux/hugetlb.h mmotm-2014-08-25-16-52/include/linux/hugetlb.h
index 6e6d338641fe..b3200fce07aa 100644
--- mmotm-2014-08-25-16-52.orig/include/linux/hugetlb.h
+++ mmotm-2014-08-25-16-52/include/linux/hugetlb.h
@@ -98,10 +98,10 @@ pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr);
 int huge_pmd_unshare(struct mm_struct *mm, unsigned long *addr, pte_t *ptep);
 struct page *follow_huge_addr(struct mm_struct *mm, unsigned long address,
 			      int write);
-struct page *follow_huge_pmd(struct mm_struct *mm, unsigned long address,
-				pmd_t *pmd, int write);
-struct page *follow_huge_pud(struct mm_struct *mm, unsigned long address,
-				pud_t *pud, int write);
+struct page *follow_huge_pmd(struct vm_area_struct *vma, unsigned long address,
+				pmd_t *pmd, int flags);
+struct page *follow_huge_pud(struct vm_area_struct *vma, unsigned long address,
+				pud_t *pud, int flags);
 int pmd_huge(pmd_t pmd);
 int pud_huge(pud_t pmd);
 unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
@@ -133,8 +133,8 @@ static inline void hugetlb_report_meminfo(struct seq_file *m)
 static inline void hugetlb_show_meminfo(void)
 {
 }
-#define follow_huge_pmd(mm, addr, pmd, write)	NULL
-#define follow_huge_pud(mm, addr, pud, write)	NULL
+#define follow_huge_pmd(vma, addr, pmd, flags)	NULL
+#define follow_huge_pud(vma, addr, pud, flags)	NULL
 #define prepare_hugepage_range(file, addr, len)	(-EINVAL)
 #define pmd_huge(x)	0
 #define pud_huge(x)	0
diff --git mmotm-2014-08-25-16-52.orig/mm/gup.c mmotm-2014-08-25-16-52/mm/gup.c
index 91d044b1600d..597a5e92e265 100644
--- mmotm-2014-08-25-16-52.orig/mm/gup.c
+++ mmotm-2014-08-25-16-52/mm/gup.c
@@ -162,33 +162,16 @@ struct page *follow_page_mask(struct vm_area_struct *vma,
 	pud = pud_offset(pgd, address);
 	if (pud_none(*pud))
 		return no_page_table(vma, flags);
-	if (pud_huge(*pud) && vma->vm_flags & VM_HUGETLB) {
-		if (flags & FOLL_GET)
-			return NULL;
-		page = follow_huge_pud(mm, address, pud, flags & FOLL_WRITE);
-		return page;
-	}
+	if (pud_huge(*pud) && vma->vm_flags & VM_HUGETLB)
+		return follow_huge_pud(vma, address, pud, flags);
 	if (unlikely(pud_bad(*pud)))
 		return no_page_table(vma, flags);
 
 	pmd = pmd_offset(pud, address);
 	if (pmd_none(*pmd))
 		return no_page_table(vma, flags);
-	if (pmd_huge(*pmd) && vma->vm_flags & VM_HUGETLB) {
-		page = follow_huge_pmd(mm, address, pmd, flags & FOLL_WRITE);
-		if (flags & FOLL_GET) {
-			/*
-			 * Refcount on tail pages are not well-defined and
-			 * shouldn't be taken. The caller should handle a NULL
-			 * return when trying to follow tail pages.
-			 */
-			if (PageHead(page))
-				get_page(page);
-			else
-				page = NULL;
-		}
-		return page;
-	}
+	if (pmd_huge(*pmd) && vma->vm_flags & VM_HUGETLB)
+		return follow_huge_pmd(vma, address, pmd, flags);
 	if ((flags & FOLL_NUMA) && pmd_numa(*pmd))
 		return no_page_table(vma, flags);
 	if (pmd_trans_huge(*pmd)) {
diff --git mmotm-2014-08-25-16-52.orig/mm/hugetlb.c mmotm-2014-08-25-16-52/mm/hugetlb.c
index 022767506c7b..c5345c5edb50 100644
--- mmotm-2014-08-25-16-52.orig/mm/hugetlb.c
+++ mmotm-2014-08-25-16-52/mm/hugetlb.c
@@ -3667,26 +3667,45 @@ follow_huge_addr(struct mm_struct *mm, unsigned long address,
 }
 
 struct page * __weak
-follow_huge_pmd(struct mm_struct *mm, unsigned long address,
-		pmd_t *pmd, int write)
+follow_huge_pmd(struct vm_area_struct *vma, unsigned long address,
+		pmd_t *pmd, int flags)
 {
-	struct page *page;
+	struct page *page = NULL;
+	spinlock_t *ptl;
 
-	page = pte_page(*(pte_t *)pmd);
-	if (page)
-		page += ((address & ~PMD_MASK) >> PAGE_SHIFT);
+	ptl = huge_pte_lock(hstate_vma(vma), vma->vm_mm, (pte_t *)pmd);
+
+	if (!pmd_huge(*pmd))
+		goto out;
+
+	page = pte_page(*(pte_t *)pmd) + ((address & ~PMD_MASK) >> PAGE_SHIFT);
+
+	if (flags & FOLL_GET)
+		if (!get_page_unless_zero(page))
+			page = NULL;
+out:
+	spin_unlock(ptl);
 	return page;
 }
 
 struct page * __weak
-follow_huge_pud(struct mm_struct *mm, unsigned long address,
-		pud_t *pud, int write)
+follow_huge_pud(struct vm_area_struct *vma, unsigned long address,
+		pud_t *pud, int flags)
 {
-	struct page *page;
+	struct page *page = NULL;
+	spinlock_t *ptl;
 
-	page = pte_page(*(pte_t *)pud);
-	if (page)
-		page += ((address & ~PUD_MASK) >> PAGE_SHIFT);
+	if (flags & FOLL_GET)
+		return NULL;
+
+	ptl = huge_pte_lock(hstate_vma(vma), vma->vm_mm, (pte_t *)pud);
+
+	if (!pud_huge(*pud))
+		goto out;
+
+	page = pte_page(*(pte_t *)pud) + ((address & ~PUD_MASK) >> PAGE_SHIFT);
+out:
+	spin_unlock(ptl);
 	return page;
 }
 
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
