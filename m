Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f169.google.com (mail-yk0-f169.google.com [209.85.160.169])
	by kanga.kvack.org (Postfix) with ESMTP id C13DD800CA
	for <linux-mm@kvack.org>; Fri,  7 Nov 2014 02:04:51 -0500 (EST)
Received: by mail-yk0-f169.google.com with SMTP id 131so2039912ykp.28
        for <linux-mm@kvack.org>; Thu, 06 Nov 2014 23:04:51 -0800 (PST)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id i69si5792711yhg.164.2014.11.06.23.04.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 06 Nov 2014 23:04:50 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH -mm v7 01/13] mm/pagewalk: remove pgd_entry() and pud_entry()
Date: Fri, 7 Nov 2014 07:01:52 +0000
Message-ID: <1415343692-6314-2-git-send-email-n-horiguchi@ah.jp.nec.com>
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

Currently no user of page table walker sets ->pgd_entry() or ->pud_entry(),
so checking their existence in each loop is just wasting CPU cycle.
So let's remove it to reduce overhead.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/mm.h | 6 ------
 mm/pagewalk.c      | 9 ++-------
 2 files changed, 2 insertions(+), 13 deletions(-)

diff --git mmotm-2014-11-05-16-01.orig/include/linux/mm.h mmotm-2014-11-05-=
16-01/include/linux/mm.h
index 423024a0d3db..ba964aa0282a 100644
--- mmotm-2014-11-05-16-01.orig/include/linux/mm.h
+++ mmotm-2014-11-05-16-01/include/linux/mm.h
@@ -1120,8 +1120,6 @@ void unmap_vmas(struct mmu_gather *tlb, struct vm_are=
a_struct *start_vma,
=20
 /**
  * mm_walk - callbacks for walk_page_range
- * @pgd_entry: if set, called for each non-empty PGD (top-level) entry
- * @pud_entry: if set, called for each non-empty PUD (2nd-level) entry
  * @pmd_entry: if set, called for each non-empty PMD (3rd-level) entry
  *	       this handler is required to be able to handle
  *	       pmd_trans_huge() pmds.  They may simply choose to
@@ -1135,10 +1133,6 @@ void unmap_vmas(struct mmu_gather *tlb, struct vm_ar=
ea_struct *start_vma,
  * (see walk_page_range for more details)
  */
 struct mm_walk {
-	int (*pgd_entry)(pgd_t *pgd, unsigned long addr,
-			 unsigned long next, struct mm_walk *walk);
-	int (*pud_entry)(pud_t *pud, unsigned long addr,
-	                 unsigned long next, struct mm_walk *walk);
 	int (*pmd_entry)(pmd_t *pmd, unsigned long addr,
 			 unsigned long next, struct mm_walk *walk);
 	int (*pte_entry)(pte_t *pte, unsigned long addr,
diff --git mmotm-2014-11-05-16-01.orig/mm/pagewalk.c mmotm-2014-11-05-16-01=
/mm/pagewalk.c
index ad83195521f2..5d41393260c8 100644
--- mmotm-2014-11-05-16-01.orig/mm/pagewalk.c
+++ mmotm-2014-11-05-16-01/mm/pagewalk.c
@@ -86,9 +86,7 @@ static int walk_pud_range(pgd_t *pgd, unsigned long addr,=
 unsigned long end,
 				break;
 			continue;
 		}
-		if (walk->pud_entry)
-			err =3D walk->pud_entry(pud, addr, next, walk);
-		if (!err && (walk->pmd_entry || walk->pte_entry))
+		if (walk->pmd_entry || walk->pte_entry)
 			err =3D walk_pmd_range(pud, addr, next, walk);
 		if (err)
 			break;
@@ -234,10 +232,7 @@ int walk_page_range(unsigned long addr, unsigned long =
end,
 			pgd++;
 			continue;
 		}
-		if (walk->pgd_entry)
-			err =3D walk->pgd_entry(pgd, addr, next, walk);
-		if (!err &&
-		    (walk->pud_entry || walk->pmd_entry || walk->pte_entry))
+		if (walk->pmd_entry || walk->pte_entry)
 			err =3D walk_pud_range(pgd, addr, next, walk);
 		if (err)
 			break;
--=20
2.2.0.rc0.2.gf745acb

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
