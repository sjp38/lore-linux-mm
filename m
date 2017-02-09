Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id AE27D6B0387
	for <linux-mm@kvack.org>; Thu,  9 Feb 2017 04:18:49 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id w185so19051306ita.5
        for <linux-mm@kvack.org>; Thu, 09 Feb 2017 01:18:49 -0800 (PST)
Received: from tyo162.gate.nec.co.jp (tyo162.gate.nec.co.jp. [114.179.232.162])
        by mx.google.com with ESMTPS id 89si17344047ioi.56.2017.02.09.01.18.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Feb 2017 01:18:48 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v3 04/14] mm: x86: move _PAGE_SWP_SOFT_DIRTY from bit 7
 to bit 1
Date: Thu, 9 Feb 2017 09:14:58 +0000
Message-ID: <20170209091458.GA15649@hori1.linux.bs1.fc.nec.co.jp>
References: <20170205161252.85004-1-zi.yan@sent.com>
 <20170205161252.85004-5-zi.yan@sent.com>
In-Reply-To: <20170205161252.85004-5-zi.yan@sent.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <8DAD67A605EFFB4BB1984EC46D6D79BC@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@sent.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "minchan@kernel.org" <minchan@kernel.org>, "vbabka@suse.cz" <vbabka@suse.cz>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "khandual@linux.vnet.ibm.com" <khandual@linux.vnet.ibm.com>, "zi.yan@cs.rutgers.edu" <zi.yan@cs.rutgers.edu>

On Sun, Feb 05, 2017 at 11:12:42AM -0500, Zi Yan wrote:
> From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>=20
> pmd_present() checks _PAGE_PSE along with _PAGE_PRESENT to avoid
> false negative return when it races with thp spilt
> (during which _PAGE_PRESENT is temporary cleared.) I don't think that
> dropping _PAGE_PSE check in pmd_present() works well because it can
> hurt optimization of tlb handling in thp split.
> In the current kernel, bits 1-4 are not used in non-present format
> since commit 00839ee3b299 ("x86/mm: Move swap offset/type up in PTE to
> work around erratum"). So let's move _PAGE_SWP_SOFT_DIRTY to bit 1.
> Bit 7 is used as reserved (always clear), so please don't use it for
> other purpose.
>=20
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>=20
> ChangeLog v3:
> - Move _PAGE_SWP_SOFT_DIRTY to bit 1, it was placed at bit 6. Because
> some CPUs might accidentally set bit 5 or 6.
>=20
> Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
> ---

More documenting will be helpful, could you do like follows?

Thanks,
Naoya Horiguchi
---
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Date: Sun, 5 Feb 2017 11:12:42 -0500
Subject: [PATCH] mm: x86: move _PAGE_SWP_SOFT_DIRTY from bit 7 to bit 1

pmd_present() checks _PAGE_PSE along with _PAGE_PRESENT to avoid
false negative return when it races with thp spilt
(during which _PAGE_PRESENT is temporary cleared.) I don't think that
dropping _PAGE_PSE check in pmd_present() works well because it can
hurt optimization of tlb handling in thp split.
In the current kernel, bits 1-4 are not used in non-present format
since commit 00839ee3b299 ("x86/mm: Move swap offset/type up in PTE to
work around erratum"). So let's move _PAGE_SWP_SOFT_DIRTY to bit 1.
Bit 7 is used as reserved (always clear), so please don't use it for
other purpose.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
---
 arch/x86/include/asm/pgtable_64.h    | 12 +++++++++---
 arch/x86/include/asm/pgtable_types.h | 10 +++++-----
 2 files changed, 14 insertions(+), 8 deletions(-)

diff --git a/arch/x86/include/asm/pgtable_64.h b/arch/x86/include/asm/pgtab=
le_64.h
index 73c7ccc38912..07c98c85cc96 100644
--- a/arch/x86/include/asm/pgtable_64.h
+++ b/arch/x86/include/asm/pgtable_64.h
@@ -157,15 +157,21 @@ static inline int pgd_large(pgd_t pgd) { return 0; }
 /*
  * Encode and de-code a swap entry
  *
- * |     ...            | 11| 10|  9|8|7|6|5| 4| 3|2|1|0| <- bit number
- * |     ...            |SW3|SW2|SW1|G|L|D|A|CD|WT|U|W|P| <- bit names
- * | OFFSET (14->63) | TYPE (9-13)  |0|X|X|X| X| X|X|X|0| <- swp entry
+ * |     ...            | 11| 10|  9|8|7|6|5| 4| 3|2| 1|0| <- bit number
+ * |     ...            |SW3|SW2|SW1|G|L|D|A|CD|WT|U| W|P| <- bit names
+ * | OFFSET (14->63) | TYPE (9-13)  |0|0|X|X| X| X|X|SD|0| <- swp entry
  *
  * G (8) is aliased and used as a PROT_NONE indicator for
  * !present ptes.  We need to start storing swap entries above
  * there.  We also need to avoid using A and D because of an
  * erratum where they can be incorrectly set by hardware on
  * non-present PTEs.
+ *
+ * SD (1) in swp entry is used to store soft dirty bit, which helps us
+ * remember soft dirty over page migration.
+ *
+ * Bit 7 in swp entry should be 0 because pmd_present checks not only P,
+ * but G.
  */
 #define SWP_TYPE_FIRST_BIT (_PAGE_BIT_PROTNONE + 1)
 #define SWP_TYPE_BITS 5
diff --git a/arch/x86/include/asm/pgtable_types.h b/arch/x86/include/asm/pg=
table_types.h
index 8b4de22d6429..3695abd58ef6 100644
--- a/arch/x86/include/asm/pgtable_types.h
+++ b/arch/x86/include/asm/pgtable_types.h
@@ -97,15 +97,15 @@
 /*
  * Tracking soft dirty bit when a page goes to a swap is tricky.
  * We need a bit which can be stored in pte _and_ not conflict
- * with swap entry format. On x86 bits 6 and 7 are *not* involved
- * into swap entry computation, but bit 6 is used for nonlinear
- * file mapping, so we borrow bit 7 for soft dirty tracking.
+ * with swap entry format. On x86 bits 1-4 are *not* involved
+ * into swap entry computation, but bit 7 is used for thp migration,
+ * so we borrow bit 1 for soft dirty tracking.
  *
  * Please note that this bit must be treated as swap dirty page
- * mark if and only if the PTE has present bit clear!
+ * mark if and only if the PTE/PMD has present bit clear!
  */
 #ifdef CONFIG_MEM_SOFT_DIRTY
-#define _PAGE_SWP_SOFT_DIRTY	_PAGE_PSE
+#define _PAGE_SWP_SOFT_DIRTY	_PAGE_RW
 #else
 #define _PAGE_SWP_SOFT_DIRTY	(_AT(pteval_t, 0))
 #endif
--=20
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
