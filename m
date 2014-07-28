Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f48.google.com (mail-qg0-f48.google.com [209.85.192.48])
	by kanga.kvack.org (Postfix) with ESMTP id 546246B0036
	for <linux-mm@kvack.org>; Mon, 28 Jul 2014 14:34:43 -0400 (EDT)
Received: by mail-qg0-f48.google.com with SMTP id i50so9100789qgf.35
        for <linux-mm@kvack.org>; Mon, 28 Jul 2014 11:34:42 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 93si33578772qgk.108.2014.07.28.11.34.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jul 2014 11:34:41 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 2/3] mm/hugetlb: take refcount under page table lock in follow_huge_pmd()
Date: Mon, 28 Jul 2014 14:08:30 -0400
Message-Id: <1406570911-28133-2-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1406570911-28133-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1406570911-28133-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

We have a race condition between move_pages() and freeing hugepages,
where move_pages() calls follow_page(FOLL_GET) for hugepages internally
and tries to get its refcount without preventing concurrent freeing.
This race crashes the kernel, so this patch fixes it by moving FOLL_GET
code for hugepages into follow_huge_pmd() with taking the page table lock.

This patch passes the following test. And libhugetlbfs test shows no
regression.

  $ cat move_pages.c
  #include <stdio.h>
  #include <stdlib.h>
  #include <numaif.h>

  #define ADDR_INPUT      0x700000000000
  #define HPS             0x200000
  #define PS              0x1000

  int main(int argc, char *argv[]) {
          int i;
          int nr_hp = 1;
          int nr_p  = nr_hp * HPS / PS;
          int ret;
          void **addrs;
          int *status;
          int *nodes;
          pid_t pid;

          if (argc < 2) {
                  fprintf(stderr, "no args for pid\n");
                  exit(EXIT_FAILURE);
          }

          pid = strtol(argv[1], NULL, 0);
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
          char *p;

          while (1) {
                  p = mmap((void *)ADDR_INPUT, HPS, PROT_READ | PROT_WRITE,
                           MAP_PRIVATE | MAP_ANONYMOUS | MAP_HUGETLB, -1, 0);
                  if (p != (void *)ADDR_INPUT) {
                          perror("mmap");
                          break;
                  }
                  memset(p, 0, HPS);
                  munmap(p, HPS);
          }
  }

  $ sysctl vm.nr_hugepages=10
  $ ./hugepage &
  $ ./move_pages $(pgrep -f hugepage)

Note for stable inclusion:
  This patch fixes e632a938d914 ("mm: migrate: add hugepage migration code
  to move_pages()"), so is applicable to -stable kernels which includes it.
  And this patch depends on the patch "mm/hugetlb: replace parameters of
  follow_huge_pmd/pud()".

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: <stable@vger.kernel.org>  # [3.12+]
---
 mm/gup.c     | 17 ++---------------
 mm/hugetlb.c | 18 ++++++++++++++++++
 2 files changed, 20 insertions(+), 15 deletions(-)

diff --git mmotm-2014-07-22-15-58.orig/mm/gup.c mmotm-2014-07-22-15-58/mm/gup.c
index ba2c933625b2..ecd5dc0e2952 100644
--- mmotm-2014-07-22-15-58.orig/mm/gup.c
+++ mmotm-2014-07-22-15-58/mm/gup.c
@@ -174,21 +174,8 @@ struct page *follow_page_mask(struct vm_area_struct *vma,
 	pmd = pmd_offset(pud, address);
 	if (pmd_none(*pmd))
 		return no_page_table(vma, flags);
-	if (pmd_huge(*pmd) && vma->vm_flags & VM_HUGETLB) {
-		page = follow_huge_pmd(vma, address, pmd, flags);
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
diff --git mmotm-2014-07-22-15-58.orig/mm/hugetlb.c mmotm-2014-07-22-15-58/mm/hugetlb.c
index ade297a9c519..6793914b6aac 100644
--- mmotm-2014-07-22-15-58.orig/mm/hugetlb.c
+++ mmotm-2014-07-22-15-58/mm/hugetlb.c
@@ -3655,10 +3655,28 @@ follow_huge_pmd(struct vm_area_struct *vma, unsigned long address,
 		pmd_t *pmd, int flags)
 {
 	struct page *page;
+	spinlock_t *ptl;
+
+	if (flags & FOLL_GET)
+		ptl = huge_pte_lock(hstate_vma(vma), vma->vm_mm, (pte_t *)pmd);
 
 	page = pte_page(*(pte_t *)pmd);
 	if (page)
 		page += ((address & ~PMD_MASK) >> PAGE_SHIFT);
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
 	return page;
 }
 
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
