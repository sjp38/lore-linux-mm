Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 21D7D6B006C
	for <linux-mm@kvack.org>; Tue,  2 Dec 2014 03:38:08 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id kx10so13037670pab.2
        for <linux-mm@kvack.org>; Tue, 02 Dec 2014 00:38:07 -0800 (PST)
Received: from tyo200.gate.nec.co.jp (TYO200.gate.nec.co.jp. [210.143.35.50])
        by mx.google.com with ESMTPS id b16si32492326pdj.189.2014.12.02.00.38.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 02 Dec 2014 00:38:05 -0800 (PST)
Received: from tyo202.gate.nec.co.jp ([10.7.69.202])
	by tyo200.gate.nec.co.jp (8.13.8/8.13.4) with ESMTP id sB28c0qM026757
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Tue, 2 Dec 2014 17:38:02 +0900 (JST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v5 6/8] mm/hugetlb: add migration entry check in
 __unmap_hugepage_range
Date: Tue, 2 Dec 2014 08:26:40 +0000
Message-ID: <1417508759-10848-7-git-send-email-n-horiguchi@ah.jp.nec.com>
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

If __unmap_hugepage_range() tries to unmap the address range over which
hugepage migration is on the way, we get the wrong page because pte_page()
doesn't work for migration entries. This patch simply clears the pte for
migration entries as we do for hwpoison entries.

Fixes: 290408d4a2 ("hugetlb: hugepage migration core")
Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: <stable@vger.kernel.org>  # [2.6.36+]
---
ChangeLog v4:
- check hwpoisoned hugepage and migrating hugepage with the same check
  instead of doing separately
---
 mm/hugetlb.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git mmotm-2014-11-26-15-45.orig/mm/hugetlb.c mmotm-2014-11-26-15-45/=
mm/hugetlb.c
index 2807be3f260d..a2bfd02e289f 100644
--- mmotm-2014-11-26-15-45.orig/mm/hugetlb.c
+++ mmotm-2014-11-26-15-45/mm/hugetlb.c
@@ -2657,9 +2657,10 @@ void __unmap_hugepage_range(struct mmu_gather *tlb, =
struct vm_area_struct *vma,
 			goto unlock;
=20
 		/*
-		 * HWPoisoned hugepage is already unmapped and dropped reference
+		 * Migrating hugepage or HWPoisoned hugepage is already
+		 * unmapped and its refcount is dropped, so just clear pte here.
 		 */
-		if (unlikely(is_hugetlb_entry_hwpoisoned(pte))) {
+		if (unlikely(!pte_present(pte))) {
 			huge_pte_clear(mm, address, ptep);
 			goto unlock;
 		}
--=20
2.2.0.rc0.2.gf745acb

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
