Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 6915A6B006C
	for <linux-mm@kvack.org>; Tue,  2 Dec 2014 03:33:09 -0500 (EST)
Received: by mail-pd0-f175.google.com with SMTP id y10so12682497pdj.6
        for <linux-mm@kvack.org>; Tue, 02 Dec 2014 00:33:09 -0800 (PST)
Received: from tyo200.gate.nec.co.jp (TYO200.gate.nec.co.jp. [210.143.35.50])
        by mx.google.com with ESMTPS id oy2si32467945pdb.191.2014.12.02.00.33.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 02 Dec 2014 00:33:06 -0800 (PST)
Received: from tyo201.gate.nec.co.jp ([10.7.69.201])
	by tyo200.gate.nec.co.jp (8.13.8/8.13.4) with ESMTP id sB28X0ik025985
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Tue, 2 Dec 2014 17:33:04 +0900 (JST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v5 2/8] mm/hugetlb: pmd_huge() returns true for non-present
 hugepage
Date: Tue, 2 Dec 2014 08:26:39 +0000
Message-ID: <1417508759-10848-3-git-send-email-n-horiguchi@ah.jp.nec.com>
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

Migrating hugepages and hwpoisoned hugepages are considered as
non-present hugepages, and they are referenced via migration entries
and hwpoison entries in their page table slots.

This behavior causes race condition because pmd_huge() doesn't tell
non-huge pages from migrating/hwpoisoned hugepages. follow_page_mask()
is one example where the kernel would call follow_page_pte() for such
hugepage while this function is supposed to handle only normal pages.

To avoid this, this patch makes pmd_huge() return true when pmd_none()
is true *and* pmd_present() is false. We don't have to worry about mixing
up non-present pmd entry with normal pmd (pointing to leaf level pte
entry) because pmd_present() is true in normal pmd.

The same race condition could happen in (x86-specific) gup_pmd_range(),
where this patch simply adds pmd_present() check instead of pmd_huge().
This is because gup_pmd_range() is fast path. If we have non-present
hugepage in this function, we will go into gup_huge_pmd(), then return
0 at flag mask check, and finally fall back to the slow path.

Fixes: 290408d4a2 ("hugetlb: hugepage migration core")
Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: <stable@vger.kernel.org> # [2.6.36+]
---
 arch/x86/mm/gup.c         | 2 +-
 arch/x86/mm/hugetlbpage.c | 8 +++++++-
 mm/hugetlb.c              | 2 ++
 3 files changed, 10 insertions(+), 2 deletions(-)

diff --git mmotm-2014-11-26-15-45.orig/arch/x86/mm/gup.c mmotm-2014-11-26-1=
5-45/arch/x86/mm/gup.c
index 207d9aef662d..448ee8912d9b 100644
--- mmotm-2014-11-26-15-45.orig/arch/x86/mm/gup.c
+++ mmotm-2014-11-26-15-45/arch/x86/mm/gup.c
@@ -172,7 +172,7 @@ static int gup_pmd_range(pud_t pud, unsigned long addr,=
 unsigned long end,
 		 */
 		if (pmd_none(pmd) || pmd_trans_splitting(pmd))
 			return 0;
-		if (unlikely(pmd_large(pmd))) {
+		if (unlikely(pmd_large(pmd) || !pmd_present(pmd))) {
 			/*
 			 * NUMA hinting faults need to be handled in the GUP
 			 * slowpath for accounting purposes and so that they
diff --git mmotm-2014-11-26-15-45.orig/arch/x86/mm/hugetlbpage.c mmotm-2014=
-11-26-15-45/arch/x86/mm/hugetlbpage.c
index 03b8a7c11817..9161f764121e 100644
--- mmotm-2014-11-26-15-45.orig/arch/x86/mm/hugetlbpage.c
+++ mmotm-2014-11-26-15-45/arch/x86/mm/hugetlbpage.c
@@ -54,9 +54,15 @@ int pud_huge(pud_t pud)
=20
 #else
=20
+/*
+ * pmd_huge() returns 1 if @pmd is hugetlb related entry, that is normal
+ * hugetlb entry or non-present (migration or hwpoisoned) hugetlb entry.
+ * Otherwise, returns 0.
+ */
 int pmd_huge(pmd_t pmd)
 {
-	return !!(pmd_val(pmd) & _PAGE_PSE);
+	return !pmd_none(pmd) &&
+		(pmd_val(pmd) & (_PAGE_PRESENT|_PAGE_PSE)) !=3D _PAGE_PRESENT;
 }
=20
 int pud_huge(pud_t pud)
diff --git mmotm-2014-11-26-15-45.orig/mm/hugetlb.c mmotm-2014-11-26-15-45/=
mm/hugetlb.c
index 6be4a690e554..dd42878549d5 100644
--- mmotm-2014-11-26-15-45.orig/mm/hugetlb.c
+++ mmotm-2014-11-26-15-45/mm/hugetlb.c
@@ -3679,6 +3679,8 @@ follow_huge_pmd(struct mm_struct *mm, unsigned long a=
ddress,
 {
 	struct page *page;
=20
+	if (!pmd_present(*pmd))
+		return NULL;
 	page =3D pte_page(*(pte_t *)pmd);
 	if (page)
 		page +=3D ((address & ~PMD_MASK) >> PAGE_SHIFT);
--=20
2.2.0.rc0.2.gf745acb

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
