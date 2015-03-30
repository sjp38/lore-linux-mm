Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id C85FD6B0038
	for <linux-mm@kvack.org>; Mon, 30 Mar 2015 05:48:04 -0400 (EDT)
Received: by padcy3 with SMTP id cy3so162227413pad.3
        for <linux-mm@kvack.org>; Mon, 30 Mar 2015 02:48:04 -0700 (PDT)
Received: from tyo200.gate.nec.co.jp (TYO200.gate.nec.co.jp. [210.143.35.50])
        by mx.google.com with ESMTPS id ep3si7329782pbd.133.2015.03.30.02.48.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 30 Mar 2015 02:48:02 -0700 (PDT)
Received: from tyo202.gate.nec.co.jp ([10.7.69.202])
	by tyo200.gate.nec.co.jp (8.13.8/8.13.4) with ESMTP id t2U9m0KW009656
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Mon, 30 Mar 2015 18:48:00 +0900 (JST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [RFC][PATCH] mm: hugetlb: add stub-like do_hugetlb_numa()
Date: Mon, 30 Mar 2015 09:40:54 +0000
Message-ID: <1427708426-31610-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

hugetlb doesn't support NUMA balancing now, but that doesn't mean that we
don't have to make hugetlb code prepared for PROTNONE entry properly.
In the current kernel, when a process accesses to hugetlb range protected
with PROTNONE, it causes unexpected COWs, which finally put hugetlb subsyst=
em
into broken/uncontrollable state, where for example h->resv_huge_pages is
subtracted too much and wrapped around to a very large number, and free
hugepage pool is no longer maintainable.

This patch simply clears PROTNONE when it's caught out. Real NUMA balancing
code for hugetlb is not implemented yet (not sure how much it's worth doing=
.)

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 include/asm-generic/hugetlb.h | 13 +++++++++++++
 mm/hugetlb.c                  | 24 ++++++++++++++++++++++++
 2 files changed, 37 insertions(+)

diff --git v4.0-rc4.orig/include/asm-generic/hugetlb.h v4.0-rc4/include/asm=
-generic/hugetlb.h
index 99b490b4d05a..7e73cc9e57b1 100644
--- v4.0-rc4.orig/include/asm-generic/hugetlb.h
+++ v4.0-rc4/include/asm-generic/hugetlb.h
@@ -37,4 +37,17 @@ static inline void huge_pte_clear(struct mm_struct *mm, =
unsigned long addr,
 	pte_clear(mm, addr, ptep);
 }
=20
+#ifdef CONFIG_NUMA_BALANCING
+static inline int huge_pte_protnone(pte_t pte)
+{
+	return (pte_flags(pte) & (_PAGE_PROTNONE | _PAGE_PRESENT))
+		=3D=3D _PAGE_PROTNONE;
+}
+#else
+static inline int huge_pte_protnone(pte_t pte)
+{
+	return 0;
+}
+#endif /* CONFIG_NUMA_BALANCING */
+
 #endif /* _ASM_GENERIC_HUGETLB_H */
diff --git v4.0-rc4.orig/mm/hugetlb.c v4.0-rc4/mm/hugetlb.c
index cbb0bbc6662a..18c169674ee4 100644
--- v4.0-rc4.orig/mm/hugetlb.c
+++ v4.0-rc4/mm/hugetlb.c
@@ -3090,6 +3090,28 @@ static int hugetlb_no_page(struct mm_struct *mm, str=
uct vm_area_struct *vma,
 	goto out;
 }
=20
+#ifdef CONFIG_NUMA_BALANCING
+/*
+ * NUMA balancing code is to be implemented. Now we just clear PROTNONE to
+ * avoid unstability of hugetlb subsystem.
+ */
+static int do_hugetlb_numa(struct mm_struct *mm, struct vm_area_struct *vm=
a,
+				unsigned long address, pte_t *ptep, pte_t pte)
+{
+	spinlock_t *ptl =3D huge_pte_lockptr(hstate_vma(vma), mm, ptep);
+
+	spin_lock(ptl);
+	if (unlikely(!pte_same(*ptep, pte)))
+		goto unlock;
+	pte =3D pte_mkhuge(huge_pte_modify(pte, vma->vm_page_prot));
+	pte =3D pte_mkyoung(pte);
+	set_huge_pte_at(mm, address, ptep, pte);
+unlock:
+	spin_unlock(ptl);
+	return 0;
+}
+#endif
+
 #ifdef CONFIG_SMP
 static u32 fault_mutex_hash(struct hstate *h, struct mm_struct *mm,
 			    struct vm_area_struct *vma,
@@ -3144,6 +3166,8 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_are=
a_struct *vma,
 	ptep =3D huge_pte_offset(mm, address);
 	if (ptep) {
 		entry =3D huge_ptep_get(ptep);
+		if (huge_pte_protnone(entry))
+			return do_hugetlb_numa(mm, vma, address, ptep, entry);
 		if (unlikely(is_hugetlb_entry_migration(entry))) {
 			migration_entry_wait_huge(vma, mm, ptep);
 			return 0;
--=20
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
