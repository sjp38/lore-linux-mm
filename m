Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f49.google.com (mail-qa0-f49.google.com [209.85.216.49])
	by kanga.kvack.org (Postfix) with ESMTP id DC8766B0037
	for <linux-mm@kvack.org>; Fri,  1 Aug 2014 14:31:46 -0400 (EDT)
Received: by mail-qa0-f49.google.com with SMTP id dc16so4251974qab.8
        for <linux-mm@kvack.org>; Fri, 01 Aug 2014 11:31:46 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id jr8si16979983qcb.42.2014.08.01.11.31.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Aug 2014 11:31:46 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v2 1/3] mm/hugetlb: take refcount under page table lock in follow_huge_pmd()
Date: Fri,  1 Aug 2014 13:37:41 -0400
Message-Id: <1406914663-8631-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

We have a race condition between move_pages() and freeing hugepages,
where move_pages() calls follow_page(FOLL_GET) for hugepages internally
and tries to get its refcount without preventing concurrent freeing.
This race crashes the kernel, so this patch fixes it by moving FOLL_GET
code for hugepages into follow_huge_pmd() with taking the page table lock.

This patch passes the following test. And libhugetlbfs test shows no
regression.

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

ChangeLog v2:
- introduce follow_huge_pmd_lock() to do locking in arch-independent code.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: <stable@vger.kernel.org>  # [3.12+]
---
 include/linux/hugetlb.h |  3 +++
 mm/gup.c                | 17 ++---------------
 mm/hugetlb.c            | 27 +++++++++++++++++++++++++++
 3 files changed, 32 insertions(+), 15 deletions(-)

diff --git mmotm-2014-07-22-15-58.orig/include/linux/hugetlb.h mmotm-2014-07-22-15-58/include/linux/hugetlb.h
index 41272bcf73f8..194834853d6f 100644
--- mmotm-2014-07-22-15-58.orig/include/linux/hugetlb.h
+++ mmotm-2014-07-22-15-58/include/linux/hugetlb.h
@@ -101,6 +101,8 @@ struct page *follow_huge_pmd(struct mm_struct *mm, unsigned long address,
 				pmd_t *pmd, int write);
 struct page *follow_huge_pud(struct mm_struct *mm, unsigned long address,
 				pud_t *pud, int write);
+struct page *follow_huge_pmd_lock(struct vm_area_struct *vma,
+				unsigned long address, pmd_t *pmd, int flags);
 int pmd_huge(pmd_t pmd);
 int pud_huge(pud_t pmd);
 unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
@@ -134,6 +136,7 @@ static inline void hugetlb_show_meminfo(void)
 }
 #define follow_huge_pmd(mm, addr, pmd, write)	NULL
 #define follow_huge_pud(mm, addr, pud, write)	NULL
+#define follow_huge_pmd_lock(vma, addr, pmd, flags)	NULL
 #define prepare_hugepage_range(file, addr, len)	(-EINVAL)
 #define pmd_huge(x)	0
 #define pud_huge(x)	0
diff --git mmotm-2014-07-22-15-58.orig/mm/gup.c mmotm-2014-07-22-15-58/mm/gup.c
index 91d044b1600d..e4bd59efe686 100644
--- mmotm-2014-07-22-15-58.orig/mm/gup.c
+++ mmotm-2014-07-22-15-58/mm/gup.c
@@ -174,21 +174,8 @@ struct page *follow_page_mask(struct vm_area_struct *vma,
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
+		return follow_huge_pmd_lock(vma, address, pmd, flags);
 	if ((flags & FOLL_NUMA) && pmd_numa(*pmd))
 		return no_page_table(vma, flags);
 	if (pmd_trans_huge(*pmd)) {
diff --git mmotm-2014-07-22-15-58.orig/mm/hugetlb.c mmotm-2014-07-22-15-58/mm/hugetlb.c
index 7263c770e9b3..4437896cd6ed 100644
--- mmotm-2014-07-22-15-58.orig/mm/hugetlb.c
+++ mmotm-2014-07-22-15-58/mm/hugetlb.c
@@ -3687,6 +3687,33 @@ follow_huge_pud(struct mm_struct *mm, unsigned long address,
 
 #endif /* CONFIG_ARCH_WANT_GENERAL_HUGETLB */
 
+struct page *follow_huge_pmd_lock(struct vm_area_struct *vma,
+				unsigned long address, pmd_t *pmd, int flags)
+{
+	struct page *page;
+	spinlock_t *ptl;
+
+	if (flags & FOLL_GET)
+		ptl = huge_pte_lock(hstate_vma(vma), vma->vm_mm, (pte_t *)pmd);
+
+	page = follow_huge_pmd(vma->vm_mm, address, pmd, flags & FOLL_WRITE);
+
+	if (flags & FOLL_GET) {
+		/*
+		 * Refcount on tail pages are not well-defined and
+		 * shouldn't be taken. The caller should handle a NULL
+		 * return when trying to follow tail pages.
+		 */
+		if (PageHead(page))
+			get_page(page);
+		else
+			page = NULL;
+		spin_unlock(ptl);
+	}
+
+	return page;
+}
+
 #ifdef CONFIG_MEMORY_FAILURE
 
 /* Should be called in hugetlb_lock */
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
