Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id B2D536B006E
	for <linux-mm@kvack.org>; Tue,  2 Dec 2014 03:33:10 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id eu11so12918402pac.22
        for <linux-mm@kvack.org>; Tue, 02 Dec 2014 00:33:10 -0800 (PST)
Received: from tyo200.gate.nec.co.jp (TYO200.gate.nec.co.jp. [210.143.35.50])
        by mx.google.com with ESMTPS id bg2si32669755pdb.20.2014.12.02.00.33.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 02 Dec 2014 00:33:07 -0800 (PST)
Received: from tyo201.gate.nec.co.jp ([10.7.69.201])
	by tyo200.gate.nec.co.jp (8.13.8/8.13.4) with ESMTP id sB28X0io025985
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Tue, 2 Dec 2014 17:33:04 +0900 (JST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v5 3/8] mm/hugetlb: take page table lock in follow_huge_pmd()
Date: Tue, 2 Dec 2014 08:26:39 +0000
Message-ID: <1417508759-10848-4-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1417508759-10848-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1417508759-10848-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>
Cc: David Rientjes <rientjes@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

We have a race condition between move_pages() and freeing hugepages,
where move_pages() calls follow_page(FOLL_GET) for hugepages internally
and tries to get its refcount without preventing concurrent freeing.
This race crashes the kernel, so this patch fixes it by moving FOLL_GET
code for hugepages into follow_huge_pmd() with taking the page table lock.

This patch intentionally removes page=3D=3DNULL check after pte_page. This
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
          int nr_hp =3D strtol(argv[1], NULL, 0);
          int nr_p  =3D nr_hp * HPS / PS;
          int ret;
          void **addrs;
          int *status;
          int *nodes;
          pid_t pid;

          pid =3D strtol(argv[2], NULL, 0);
          addrs  =3D malloc(sizeof(char *) * nr_p + 1);
          status =3D malloc(sizeof(char *) * nr_p + 1);
          nodes  =3D malloc(sizeof(char *) * nr_p + 1);

          while (1) {
                  for (i =3D 0; i < nr_p; i++) {
                          addrs[i] =3D (void *)ADDR_INPUT + i * PS;
                          nodes[i] =3D 1;
                          status[i] =3D 0;
                  }
                  ret =3D numa_move_pages(pid, nr_p, addrs, nodes, status,
                                        MPOL_MF_MOVE_ALL);
                  if (ret =3D=3D -1)
                          err("move_pages");

                  for (i =3D 0; i < nr_p; i++) {
                          addrs[i] =3D (void *)ADDR_INPUT + i * PS;
                          nodes[i] =3D 0;
                          status[i] =3D 0;
                  }
                  ret =3D numa_move_pages(pid, nr_p, addrs, nodes, status,
                                        MPOL_MF_MOVE_ALL);
                  if (ret =3D=3D -1)
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
          int nr_hp =3D strtol(argv[1], NULL, 0);
          char *p;

          while (1) {
                  p =3D mmap((void *)ADDR_INPUT, nr_hp * HPS, PROT_READ | P=
ROT_WRITE,
                           MAP_PRIVATE | MAP_ANONYMOUS | MAP_HUGETLB, -1, 0=
);
                  if (p !=3D (void *)ADDR_INPUT) {
                          perror("mmap");
                          break;
                  }
                  memset(p, 0, nr_hp * HPS);
                  munmap(p, nr_hp * HPS);
          }
  }

  $ sysctl vm.nr_hugepages=3D40
  $ ./hugepage 10 &
  $ ./movepages 10 $(pgrep -f hugepage)

Fixes: e632a938d914 ("mm: migrate: add hugepage migration code to move_page=
s()")
Reported-by: Hugh Dickins <hughd@google.com>
Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: <stable@vger.kernel.org>  # [3.12+]
---
ChangeLog v5:
- make follow_huge_pmd() wake and retry if pmd is migration entry,
  for that purpose __migration_entry_wait() is exported outside mm/migrate.=
c
- make follow_huge_pmd() return NULL if pmd is hwpoison entry
- return no_page_table() instead of NULL if follow_huge_pmd/pud returns NUL=
L

ChangeLog v4:
- remove changes related to taking ptl from follow_huge_(addr|pud)(),
  which is not neccessary because these functions don't support FOLL_GET
  at least for now
- add justification of removing page=3D=3DNULL check to patch description
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
 include/linux/swapops.h |  4 ++++
 mm/gup.c                | 25 ++++++++-----------------
 mm/hugetlb.c            | 48 ++++++++++++++++++++++++++++++++++-----------=
---
 mm/migrate.c            |  5 +++--
 5 files changed, 53 insertions(+), 37 deletions(-)

diff --git mmotm-2014-11-26-15-45.orig/include/linux/hugetlb.h mmotm-2014-1=
1-26-15-45/include/linux/hugetlb.h
index cdd149ca5cc0..65b73169f511 100644
--- mmotm-2014-11-26-15-45.orig/include/linux/hugetlb.h
+++ mmotm-2014-11-26-15-45/include/linux/hugetlb.h
@@ -99,9 +99,9 @@ int huge_pmd_unshare(struct mm_struct *mm, unsigned long =
*addr, pte_t *ptep);
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
@@ -133,8 +133,8 @@ static inline void hugetlb_report_meminfo(struct seq_fi=
le *m)
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
diff --git mmotm-2014-11-26-15-45.orig/include/linux/swapops.h mmotm-2014-1=
1-26-15-45/include/linux/swapops.h
index 6adfb7bfbf44..e288d5c016a7 100644
--- mmotm-2014-11-26-15-45.orig/include/linux/swapops.h
+++ mmotm-2014-11-26-15-45/include/linux/swapops.h
@@ -137,6 +137,8 @@ static inline void make_migration_entry_read(swp_entry_=
t *entry)
 	*entry =3D swp_entry(SWP_MIGRATION_READ, swp_offset(*entry));
 }
=20
+extern void __migration_entry_wait(struct mm_struct *mm, pte_t *ptep,
+					spinlock_t *ptl);
 extern void migration_entry_wait(struct mm_struct *mm, pmd_t *pmd,
 					unsigned long address);
 extern void migration_entry_wait_huge(struct vm_area_struct *vma,
@@ -150,6 +152,8 @@ static inline int is_migration_entry(swp_entry_t swp)
 }
 #define migration_entry_to_page(swp) NULL
 static inline void make_migration_entry_read(swp_entry_t *entryp) { }
+static inline void __migration_entry_wait(struct mm_struct *mm, pte_t *pte=
p,
+					spinlock_t *ptl) { }
 static inline void migration_entry_wait(struct mm_struct *mm, pmd_t *pmd,
 					 unsigned long address) { }
 static inline void migration_entry_wait_huge(struct vm_area_struct *vma,
diff --git mmotm-2014-11-26-15-45.orig/mm/gup.c mmotm-2014-11-26-15-45/mm/g=
up.c
index 3af2f08578ce..a9b260c5e2c8 100644
--- mmotm-2014-11-26-15-45.orig/mm/gup.c
+++ mmotm-2014-11-26-15-45/mm/gup.c
@@ -167,10 +167,10 @@ struct page *follow_page_mask(struct vm_area_struct *=
vma,
 	if (pud_none(*pud))
 		return no_page_table(vma, flags);
 	if (pud_huge(*pud) && vma->vm_flags & VM_HUGETLB) {
-		if (flags & FOLL_GET)
-			return NULL;
-		page =3D follow_huge_pud(mm, address, pud, flags & FOLL_WRITE);
-		return page;
+		page =3D follow_huge_pud(mm, address, pud, flags);
+		if (page)
+			return page;
+		return no_page_table(vma, flags);
 	}
 	if (unlikely(pud_bad(*pud)))
 		return no_page_table(vma, flags);
@@ -179,19 +179,10 @@ struct page *follow_page_mask(struct vm_area_struct *=
vma,
 	if (pmd_none(*pmd))
 		return no_page_table(vma, flags);
 	if (pmd_huge(*pmd) && vma->vm_flags & VM_HUGETLB) {
-		page =3D follow_huge_pmd(mm, address, pmd, flags & FOLL_WRITE);
-		if (flags & FOLL_GET) {
-			/*
-			 * Refcount on tail pages are not well-defined and
-			 * shouldn't be taken. The caller should handle a NULL
-			 * return when trying to follow tail pages.
-			 */
-			if (PageHead(page))
-				get_page(page);
-			else
-				page =3D NULL;
-		}
-		return page;
+		page =3D follow_huge_pmd(mm, address, pmd, flags);
+		if (page)
+			return page;
+		return no_page_table(vma, flags);
 	}
 	if ((flags & FOLL_NUMA) && pmd_numa(*pmd))
 		return no_page_table(vma, flags);
diff --git mmotm-2014-11-26-15-45.orig/mm/hugetlb.c mmotm-2014-11-26-15-45/=
mm/hugetlb.c
index dd42878549d5..adafced1aa17 100644
--- mmotm-2014-11-26-15-45.orig/mm/hugetlb.c
+++ mmotm-2014-11-26-15-45/mm/hugetlb.c
@@ -3675,28 +3675,48 @@ follow_huge_addr(struct mm_struct *mm, unsigned lon=
g address,
=20
 struct page * __weak
 follow_huge_pmd(struct mm_struct *mm, unsigned long address,
-		pmd_t *pmd, int write)
+		pmd_t *pmd, int flags)
 {
-	struct page *page;
-
-	if (!pmd_present(*pmd))
-		return NULL;
-	page =3D pte_page(*(pte_t *)pmd);
-	if (page)
-		page +=3D ((address & ~PMD_MASK) >> PAGE_SHIFT);
+	struct page *page =3D NULL;
+	spinlock_t *ptl;
+retry:
+	ptl =3D pmd_lockptr(mm, pmd);
+	spin_lock(ptl);
+	/*
+	 * make sure that the address range covered by this pmd is not
+	 * unmapped from other threads.
+	 */
+	if (!pmd_huge(*pmd))
+		goto out;
+	if (pmd_present(*pmd)) {
+		page =3D pte_page(*(pte_t *)pmd) +
+			((address & ~PMD_MASK) >> PAGE_SHIFT);
+		if (flags & FOLL_GET)
+			get_page(page);
+	} else {
+		if (is_hugetlb_entry_migration(huge_ptep_get((pte_t *)pmd))) {
+			spin_unlock(ptl);
+			__migration_entry_wait(mm, (pte_t *)pmd, ptl);
+			goto retry;
+		}
+		/*
+		 * hwpoisoned entry is treated as no_page_table in
+		 * follow_page_mask().
+		 */
+	}
+out:
+	spin_unlock(ptl);
 	return page;
 }
=20
 struct page * __weak
 follow_huge_pud(struct mm_struct *mm, unsigned long address,
-		pud_t *pud, int write)
+		pud_t *pud, int flags)
 {
-	struct page *page;
+	if (flags & FOLL_GET)
+		return NULL;
=20
-	page =3D pte_page(*(pte_t *)pud);
-	if (page)
-		page +=3D ((address & ~PUD_MASK) >> PAGE_SHIFT);
-	return page;
+	return pte_page(*(pte_t *)pud) + ((address & ~PUD_MASK) >> PAGE_SHIFT);
 }
=20
 #ifdef CONFIG_MEMORY_FAILURE
diff --git mmotm-2014-11-26-15-45.orig/mm/migrate.c mmotm-2014-11-26-15-45/=
mm/migrate.c
index 41945cb0ca38..a4b2a4103d38 100644
--- mmotm-2014-11-26-15-45.orig/mm/migrate.c
+++ mmotm-2014-11-26-15-45/mm/migrate.c
@@ -229,7 +229,7 @@ static void remove_migration_ptes(struct page *old, str=
uct page *new)
  * get to the page and wait until migration is finished.
  * When we return from this function the fault will be retried.
  */
-static void __migration_entry_wait(struct mm_struct *mm, pte_t *ptep,
+void __migration_entry_wait(struct mm_struct *mm, pte_t *ptep,
 				spinlock_t *ptl)
 {
 	pte_t pte;
@@ -1260,7 +1260,8 @@ static int do_move_page_to_node_array(struct mm_struc=
t *mm,
 			goto put_and_set;
=20
 		if (PageHuge(page)) {
-			isolate_huge_page(page, &pagelist);
+			if (PageHead(page))
+				isolate_huge_page(page, &pagelist);
 			goto put_and_set;
 		}
=20
--=20
2.2.0.rc0.2.gf745acb

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
