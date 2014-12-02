Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 540A56B0069
	for <linux-mm@kvack.org>; Tue,  2 Dec 2014 03:33:08 -0500 (EST)
Received: by mail-pd0-f172.google.com with SMTP id y13so12708304pdi.31
        for <linux-mm@kvack.org>; Tue, 02 Dec 2014 00:33:08 -0800 (PST)
Received: from tyo200.gate.nec.co.jp (TYO200.gate.nec.co.jp. [210.143.35.50])
        by mx.google.com with ESMTPS id sm6si32504529pac.165.2014.12.02.00.33.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 02 Dec 2014 00:33:06 -0800 (PST)
Received: from tyo201.gate.nec.co.jp ([10.7.69.201])
	by tyo200.gate.nec.co.jp (8.13.8/8.13.4) with ESMTP id sB28X0im025985
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Tue, 2 Dec 2014 17:33:04 +0900 (JST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v5 8/8] mm/hugetlb: cleanup and rename
 is_hugetlb_entry_(migration|hwpoisoned)()
Date: Tue, 2 Dec 2014 08:26:41 +0000
Message-ID: <1417508759-10848-9-git-send-email-n-horiguchi@ah.jp.nec.com>
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

non_swap_entry() returns true if a given swp_entry_t is a migration
entry or hwpoisoned entry. So non_swap_entry() && is_migration_entry() is
identical with just is_migration_entry(). So by removing non_swap_entry(),
we can write is_hugetlb_entry_(migration|hwpoisoned)() more simply.

And the name is_hugetlb_entry_(migration|hwpoisoned) is lengthy and
it's not predictable from naming convention around pte_* family.
Just pte_migration() looks better, but these function contains hugetlb
specific (so architecture dependent) huge_pte_none() check, so let's
rename them as huge_pte_(migration|hwpoisoned).

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/hugetlb.c | 38 +++++++++++++-------------------------
 1 file changed, 13 insertions(+), 25 deletions(-)

diff --git mmotm-2014-11-26-15-45.orig/mm/hugetlb.c mmotm-2014-11-26-15-45/=
mm/hugetlb.c
index 6c38f9ad3d56..bc9cbdb4f58f 100644
--- mmotm-2014-11-26-15-45.orig/mm/hugetlb.c
+++ mmotm-2014-11-26-15-45/mm/hugetlb.c
@@ -2516,30 +2516,18 @@ static void set_huge_ptep_writable(struct vm_area_s=
truct *vma,
 		update_mmu_cache(vma, address, ptep);
 }
=20
-static int is_hugetlb_entry_migration(pte_t pte)
+static inline int huge_pte_migration(pte_t pte)
 {
-	swp_entry_t swp;
-
 	if (huge_pte_none(pte) || pte_present(pte))
 		return 0;
-	swp =3D pte_to_swp_entry(pte);
-	if (non_swap_entry(swp) && is_migration_entry(swp))
-		return 1;
-	else
-		return 0;
+	return is_migration_entry(pte_to_swp_entry(pte));
 }
=20
-static int is_hugetlb_entry_hwpoisoned(pte_t pte)
+static inline int huge_pte_hwpoisoned(pte_t pte)
 {
-	swp_entry_t swp;
-
 	if (huge_pte_none(pte) || pte_present(pte))
 		return 0;
-	swp =3D pte_to_swp_entry(pte);
-	if (non_swap_entry(swp) && is_hwpoison_entry(swp))
-		return 1;
-	else
-		return 0;
+	return is_hwpoison_entry(pte_to_swp_entry(pte));
 }
=20
 int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
@@ -2583,8 +2571,8 @@ int copy_hugetlb_page_range(struct mm_struct *dst, st=
ruct mm_struct *src,
 		entry =3D huge_ptep_get(src_pte);
 		if (huge_pte_none(entry)) { /* skip none entry */
 			;
-		} else if (unlikely(is_hugetlb_entry_migration(entry) ||
-				    is_hugetlb_entry_hwpoisoned(entry))) {
+		} else if (unlikely(huge_pte_migration(entry) ||
+				    huge_pte_hwpoisoned(entry))) {
 			swp_entry_t swp_entry =3D pte_to_swp_entry(entry);
=20
 			if (is_write_migration_entry(swp_entry) && cow) {
@@ -3169,9 +3157,9 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_are=
a_struct *vma,
 	 * a active hugepage in pagecache.
 	 */
 	if (!pte_present(entry)) {
-		if (is_hugetlb_entry_migration(entry))
+		if (huge_pte_migration(entry))
 			need_wait_migration =3D 1;
-		else if (is_hugetlb_entry_hwpoisoned(entry))
+		else if (huge_pte_hwpoisoned(entry))
 			ret =3D VM_FAULT_HWPOISON_LARGE |
 				VM_FAULT_SET_HINDEX(hstate_index(h));
 		goto out_mutex;
@@ -3303,8 +3291,8 @@ long follow_hugetlb_page(struct mm_struct *mm, struct=
 vm_area_struct *vma,
 		 * (in which case hugetlb_fault waits for the migration,) and
 		 * hwpoisoned hugepages (in which case we need to prevent the
 		 * caller from accessing to them.) In order to do this, we use
-		 * here is_swap_pte instead of is_hugetlb_entry_migration and
-		 * is_hugetlb_entry_hwpoisoned. This is because it simply covers
+		 * here is_swap_pte instead of huge_pte_migration and
+		 * huge_pte_hwpoisoned. This is because it simply covers
 		 * both cases, and because we can't follow correct pages
 		 * directly from any kind of swap entries.
 		 */
@@ -3382,11 +3370,11 @@ unsigned long hugetlb_change_protection(struct vm_a=
rea_struct *vma,
 			continue;
 		}
 		pte =3D huge_ptep_get(ptep);
-		if (unlikely(is_hugetlb_entry_hwpoisoned(pte))) {
+		if (unlikely(huge_pte_hwpoisoned(pte))) {
 			spin_unlock(ptl);
 			continue;
 		}
-		if (unlikely(is_hugetlb_entry_migration(pte))) {
+		if (unlikely(huge_pte_migration(pte))) {
 			swp_entry_t entry =3D pte_to_swp_entry(pte);
=20
 			if (is_write_migration_entry(entry)) {
@@ -3730,7 +3718,7 @@ follow_huge_pmd(struct mm_struct *mm, unsigned long a=
ddress,
 		if (flags & FOLL_GET)
 			get_page(page);
 	} else {
-		if (is_hugetlb_entry_migration(huge_ptep_get((pte_t *)pmd))) {
+		if (huge_pte_migration(huge_ptep_get((pte_t *)pmd))) {
 			spin_unlock(ptl);
 			__migration_entry_wait(mm, (pte_t *)pmd, ptl);
 			goto retry;
--=20
2.2.0.rc0.2.gf745acb

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
