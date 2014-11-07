Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f45.google.com (mail-yh0-f45.google.com [209.85.213.45])
	by kanga.kvack.org (Postfix) with ESMTP id 6B8CF800CA
	for <linux-mm@kvack.org>; Fri,  7 Nov 2014 02:05:22 -0500 (EST)
Received: by mail-yh0-f45.google.com with SMTP id f10so2156988yha.32
        for <linux-mm@kvack.org>; Thu, 06 Nov 2014 23:05:22 -0800 (PST)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id 45si8446201yhc.27.2014.11.06.23.05.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 06 Nov 2014 23:05:21 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH -mm v7 09/13] memcg: cleanup preparation for page table walk
Date: Fri, 7 Nov 2014 07:02:01 +0000
Message-ID: <1415343692-6314-10-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1415343692-6314-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1415343692-6314-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Peter Feiner <pfeiner@google.com>, Jerome Marchand <jmarchan@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

pagewalk.c can handle vma in itself, so we don't have to pass vma via
walk->private. And both of mem_cgroup_count_precharge() and
mem_cgroup_move_charge() do for each vma loop themselves, but now it's
done in pagewalk.c, so let's clean up them.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
ChangeLog v4:
- use walk_page_range() instead of walk_page_vma() with for loop.
---
 mm/memcontrol.c | 49 ++++++++++++++++---------------------------------
 1 file changed, 16 insertions(+), 33 deletions(-)

diff --git mmotm-2014-11-05-16-01.orig/mm/memcontrol.c mmotm-2014-11-05-16-=
01/mm/memcontrol.c
index 496f0b9cd786..59d1342bbda7 100644
--- mmotm-2014-11-05-16-01.orig/mm/memcontrol.c
+++ mmotm-2014-11-05-16-01/mm/memcontrol.c
@@ -4959,7 +4959,7 @@ static int mem_cgroup_count_precharge_pte_range(pmd_t=
 *pmd,
 					unsigned long addr, unsigned long end,
 					struct mm_walk *walk)
 {
-	struct vm_area_struct *vma =3D walk->private;
+	struct vm_area_struct *vma =3D walk->vma;
 	pte_t *pte;
 	spinlock_t *ptl;
=20
@@ -4985,20 +4985,13 @@ static int mem_cgroup_count_precharge_pte_range(pmd=
_t *pmd,
 static unsigned long mem_cgroup_count_precharge(struct mm_struct *mm)
 {
 	unsigned long precharge;
-	struct vm_area_struct *vma;
=20
+	struct mm_walk mem_cgroup_count_precharge_walk =3D {
+		.pmd_entry =3D mem_cgroup_count_precharge_pte_range,
+		.mm =3D mm,
+	};
 	down_read(&mm->mmap_sem);
-	for (vma =3D mm->mmap; vma; vma =3D vma->vm_next) {
-		struct mm_walk mem_cgroup_count_precharge_walk =3D {
-			.pmd_entry =3D mem_cgroup_count_precharge_pte_range,
-			.mm =3D mm,
-			.private =3D vma,
-		};
-		if (is_vm_hugetlb_page(vma))
-			continue;
-		walk_page_range(vma->vm_start, vma->vm_end,
-					&mem_cgroup_count_precharge_walk);
-	}
+	walk_page_range(0, ~0UL, &mem_cgroup_count_precharge_walk);
 	up_read(&mm->mmap_sem);
=20
 	precharge =3D mc.precharge;
@@ -5131,7 +5124,7 @@ static int mem_cgroup_move_charge_pte_range(pmd_t *pm=
d,
 				struct mm_walk *walk)
 {
 	int ret =3D 0;
-	struct vm_area_struct *vma =3D walk->private;
+	struct vm_area_struct *vma =3D walk->vma;
 	pte_t *pte;
 	spinlock_t *ptl;
 	enum mc_target_type target_type;
@@ -5227,7 +5220,10 @@ put:			/* get_mctgt_type() gets the page */
=20
 static void mem_cgroup_move_charge(struct mm_struct *mm)
 {
-	struct vm_area_struct *vma;
+	struct mm_walk mem_cgroup_move_charge_walk =3D {
+		.pmd_entry =3D mem_cgroup_move_charge_pte_range,
+		.mm =3D mm,
+	};
=20
 	lru_add_drain_all();
 	/*
@@ -5250,24 +5246,11 @@ static void mem_cgroup_move_charge(struct mm_struct=
 *mm)
 		cond_resched();
 		goto retry;
 	}
-	for (vma =3D mm->mmap; vma; vma =3D vma->vm_next) {
-		int ret;
-		struct mm_walk mem_cgroup_move_charge_walk =3D {
-			.pmd_entry =3D mem_cgroup_move_charge_pte_range,
-			.mm =3D mm,
-			.private =3D vma,
-		};
-		if (is_vm_hugetlb_page(vma))
-			continue;
-		ret =3D walk_page_range(vma->vm_start, vma->vm_end,
-						&mem_cgroup_move_charge_walk);
-		if (ret)
-			/*
-			 * means we have consumed all precharges and failed in
-			 * doing additional charge. Just abandon here.
-			 */
-			break;
-	}
+	/*
+	 * When we have consumed all precharges and failed in doing
+	 * additional charge, the page walk just aborts.
+	 */
+	walk_page_range(0, ~0UL, &mem_cgroup_move_charge_walk);
 	up_read(&mm->mmap_sem);
 	atomic_dec(&mc.from->moving_account);
 }
--=20
2.2.0.rc0.2.gf745acb

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
