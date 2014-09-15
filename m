Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f51.google.com (mail-qa0-f51.google.com [209.85.216.51])
	by kanga.kvack.org (Postfix) with ESMTP id C3F026B00A8
	for <linux-mm@kvack.org>; Mon, 15 Sep 2014 18:56:20 -0400 (EDT)
Received: by mail-qa0-f51.google.com with SMTP id i13so4654559qae.38
        for <linux-mm@kvack.org>; Mon, 15 Sep 2014 15:56:20 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v6si16907164qco.27.2014.09.15.15.56.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Sep 2014 15:56:20 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v3 2/5] mm/hugetlb: take page table lock in follow_huge_pmd()
Date: Mon, 15 Sep 2014 18:39:56 -0400
Message-Id: <1410820799-27278-3-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1410820799-27278-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1410820799-27278-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>, stable@vger.kernel.org

We have a race condition between move_pages() and freeing hugepages,
where move_pages() calls follow_page(FOLL_GET) for hugepages internally
and tries to get its refcount without preventing concurrent freeing.
This race crashes the kernel, so this patch fixes it by moving FOLL_GET
code for hugepages into follow_huge_pmd() with taking the page table lock.

This patch intentionally removes page==NULL check after pte_page. This
is justified because pte_page() never returns NULL for any architectures
or configurations.

This patch changes the behavior of follow_huge_pmd() for tail pages and
then tail pages can be pinned/returned. So the caller must be changed to
properly handle the returned tail pages.

We could have a choice to add the similar locking to follow_huge_(addr|pud)
for consistency, but it's not necessary because currently these functions
don't support FOLL_GET flag, so let's leave it for future development.

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

Fixes: e632a938d914 ("mm: migrate: add hugepage migration code to move_pages()")
Reported-by: Hugh Dickins <hughd@google.com>
Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: <stable@vger.kernel.org>  # [3.12+]
---
ChangeLog v4:
- remove changes related to taking ptl from follow_huge_(addr|pud)(),
  which is not neccessary because these functions don't support FOLL_GET
  at least for now
- add justification of removing page==NULL check to patch description
- stop changing parameter mm to vma in follow_huge_(pud|pmd)()
- use pmd_lockptr() instead of huge_pte_lock() in follow_huge_pmd()
- use get_page() instead of get_page_unless_zero() in follow_huge_pmd()
- use Fixes: tag and move changelog under '---'

ChangeLog v3:
- remove unnecessary if (page) check
- check (pmd|pud)_huge again after holding ptl
- do the same change also on follow_huge_pud()
- take page table lock also in follow_huge_addr()

ChangeLog v2:
- introduce follow_huge_pmd_lock() to do locking in arch-independent code.
---
 include/linux/hugetlb.h |  8 ++++----
 mm/gup.c                | 25 ++++---------------------
 mm/hugetlb.c            | 30 +++++++++++++++++++-----------
 mm/migrate.c            |  3 ++-
 4 files changed, 29 insertions(+), 37 deletions(-)

diff --git mmotm-2014-09-09-14-42.orig/include/linux/hugetlb.h mmotm-2014-09-09-14-42/include/linux/hugetlb.h
index 6e6d338641fe..14020c7796af 100644
--- mmotm-2014-09-09-14-42.orig/include/linux/hugetlb.h
+++ mmotm-2014-09-09-14-42/include/linux/hugetlb.h
@@ -99,9 +99,9 @@ int huge_pmd_unshare(struct mm_struct *mm, unsigned long *addr, pte_t *ptep);
 struct page *follow_huge_addr(struct mm_struct *mm, unsigned long address,
 			      int write);
 struct page *follow_huge_pmd(struct mm_struct *mm, unsigned long address,
-				pmd_t *pmd, int write);
+				pmd_t *pmd, int flags);
 struct page *follow_huge_pud(struct mm_struct *mm, unsigned long address,
-				pud_t *pud, int write);
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
+#define follow_huge_pmd(mm, addr, pmd, flags)	NULL
+#define follow_huge_pud(mm, addr, pud, flags)	NULL
 #define prepare_hugepage_range(file, addr, len)	(-EINVAL)
 #define pmd_huge(x)	0
 #define pud_huge(x)	0
diff --git mmotm-2014-09-09-14-42.orig/mm/gup.c mmotm-2014-09-09-14-42/mm/gup.c
index 91d044b1600d..4575d23a33b9 100644
--- mmotm-2014-09-09-14-42.orig/mm/gup.c
+++ mmotm-2014-09-09-14-42/mm/gup.c
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
+		return follow_huge_pud(mm, address, pud, flags);
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
+		return follow_huge_pmd(mm, address, pmd, flags);
 	if ((flags & FOLL_NUMA) && pmd_numa(*pmd))
 		return no_page_table(vma, flags);
 	if (pmd_trans_huge(*pmd)) {
diff --git mmotm-2014-09-09-14-42.orig/mm/hugetlb.c mmotm-2014-09-09-14-42/mm/hugetlb.c
index 34351251e164..941832ee3d5a 100644
--- mmotm-2014-09-09-14-42.orig/mm/hugetlb.c
+++ mmotm-2014-09-09-14-42/mm/hugetlb.c
@@ -3668,26 +3668,34 @@ follow_huge_addr(struct mm_struct *mm, unsigned long address,
 
 struct page * __weak
 follow_huge_pmd(struct mm_struct *mm, unsigned long address,
-		pmd_t *pmd, int write)
+		pmd_t *pmd, int flags)
 {
-	struct page *page;
+	struct page *page = NULL;
+	spinlock_t *ptl;
 
-	page = pte_page(*(pte_t *)pmd);
-	if (page)
-		page += ((address & ~PMD_MASK) >> PAGE_SHIFT);
+	ptl = pmd_lockptr(mm, pmd);
+	spin_lock(ptl);
+
+	if (!pmd_huge(*pmd))
+		goto out;
+
+	page = pte_page(*(pte_t *)pmd) + ((address & ~PMD_MASK) >> PAGE_SHIFT);
+
+	if (flags & FOLL_GET)
+		get_page(page);
+out:
+	spin_unlock(ptl);
 	return page;
 }
 
 struct page * __weak
 follow_huge_pud(struct mm_struct *mm, unsigned long address,
-		pud_t *pud, int write)
+		pud_t *pud, int flags)
 {
-	struct page *page;
+	if (flags & FOLL_GET)
+		return NULL;
 
-	page = pte_page(*(pte_t *)pud);
-	if (page)
-		page += ((address & ~PUD_MASK) >> PAGE_SHIFT);
-	return page;
+	return pte_page(*(pte_t *)pud) + ((address & ~PUD_MASK) >> PAGE_SHIFT);
 }
 
 #ifdef CONFIG_MEMORY_FAILURE
diff --git mmotm-2014-09-09-14-42.orig/mm/migrate.c mmotm-2014-09-09-14-42/mm/migrate.c
index 09d489c55c21..29f12ca176d7 100644
--- mmotm-2014-09-09-14-42.orig/mm/migrate.c
+++ mmotm-2014-09-09-14-42/mm/migrate.c
@@ -1246,7 +1246,8 @@ static int do_move_page_to_node_array(struct mm_struct *mm,
 			goto put_and_set;
 
 		if (PageHuge(page)) {
-			isolate_huge_page(page, &pagelist);
+			if (PageHead(page))
+				isolate_huge_page(page, &pagelist);
 			goto put_and_set;
 		}
 
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
