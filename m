Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id F06246B0070
	for <linux-mm@kvack.org>; Tue,  2 Dec 2014 03:38:09 -0500 (EST)
Received: by mail-pd0-f170.google.com with SMTP id fp1so12773894pdb.1
        for <linux-mm@kvack.org>; Tue, 02 Dec 2014 00:38:09 -0800 (PST)
Received: from tyo200.gate.nec.co.jp (TYO200.gate.nec.co.jp. [210.143.35.50])
        by mx.google.com with ESMTPS id ew1si1942500pbc.179.2014.12.02.00.38.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 02 Dec 2014 00:38:06 -0800 (PST)
Received: from tyo202.gate.nec.co.jp ([10.7.69.202])
	by tyo200.gate.nec.co.jp (8.13.8/8.13.4) with ESMTP id sB28c0qS026757
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Tue, 2 Dec 2014 17:38:02 +0900 (JST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v5 7/8] mm/hugetlb: fix suboptimal migration/hwpoisoned
 entry check
Date: Tue, 2 Dec 2014 08:26:40 +0000
Message-ID: <1417508759-10848-8-git-send-email-n-horiguchi@ah.jp.nec.com>
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

Currently hugetlb_fault() checks at first whether pte of the faulted addres=
s
is a migration or hwpoisoned entry, which means that we call huge_ptep_get(=
)
twice in single hugetlb_fault(). This is not optimized. The reason of this
approach is that without checking at first, huge_pte_alloc() can trigger
BUG_ON() because pmd_huge() returned false for non-present hugetlb entry.

With a previous patch in this series, pmd_huge() becomes to return true
for non-present entry, so we no longer need this dirty workaround.
Let's move the checking code to the proper place.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/hugetlb.c | 26 +++++++++++---------------
 1 file changed, 11 insertions(+), 15 deletions(-)

diff --git mmotm-2014-11-26-15-45.orig/mm/hugetlb.c mmotm-2014-11-26-15-45/=
mm/hugetlb.c
index a2bfd02e289f..6c38f9ad3d56 100644
--- mmotm-2014-11-26-15-45.orig/mm/hugetlb.c
+++ mmotm-2014-11-26-15-45/mm/hugetlb.c
@@ -3136,20 +3136,10 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_a=
rea_struct *vma,
 	struct hstate *h =3D hstate_vma(vma);
 	struct address_space *mapping;
 	int need_wait_lock =3D 0;
+	int need_wait_migration =3D 0;
=20
 	address &=3D huge_page_mask(h);
=20
-	ptep =3D huge_pte_offset(mm, address);
-	if (ptep) {
-		entry =3D huge_ptep_get(ptep);
-		if (unlikely(is_hugetlb_entry_migration(entry))) {
-			migration_entry_wait_huge(vma, mm, ptep);
-			return 0;
-		} else if (unlikely(is_hugetlb_entry_hwpoisoned(entry)))
-			return VM_FAULT_HWPOISON_LARGE |
-				VM_FAULT_SET_HINDEX(hstate_index(h));
-	}
-
 	ptep =3D huge_pte_alloc(mm, address, huge_page_size(h));
 	if (!ptep)
 		return VM_FAULT_OOM;
@@ -3176,12 +3166,16 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_a=
rea_struct *vma,
 	/*
 	 * entry could be a migration/hwpoison entry at this point, so this
 	 * check prevents the kernel from going below assuming that we have
-	 * a active hugepage in pagecache. This goto expects the 2nd page fault,
-	 * and is_hugetlb_entry_(migration|hwpoisoned) check will properly
-	 * handle it.
+	 * a active hugepage in pagecache.
 	 */
-	if (!pte_present(entry))
+	if (!pte_present(entry)) {
+		if (is_hugetlb_entry_migration(entry))
+			need_wait_migration =3D 1;
+		else if (is_hugetlb_entry_hwpoisoned(entry))
+			ret =3D VM_FAULT_HWPOISON_LARGE |
+				VM_FAULT_SET_HINDEX(hstate_index(h));
 		goto out_mutex;
+	}
=20
 	/*
 	 * If we are going to COW the mapping later, we examine the pending
@@ -3247,6 +3241,8 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_are=
a_struct *vma,
 	}
 out_mutex:
 	mutex_unlock(&htlb_fault_mutex_table[hash]);
+	if (need_wait_migration)
+		migration_entry_wait_huge(vma, mm, ptep);
 	/*
 	 * Generally it's safe to hold refcount during waiting page lock. But
 	 * here we just wait to defer the next page fault to avoid busy loop and
--=20
2.2.0.rc0.2.gf745acb

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
