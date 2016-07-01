Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2BCF3828E1
	for <linux-mm@kvack.org>; Fri,  1 Jul 2016 13:47:05 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id b13so216452417pat.3
        for <linux-mm@kvack.org>; Fri, 01 Jul 2016 10:47:05 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id dk7si5153960pab.20.2016.07.01.10.47.03
        for <linux-mm@kvack.org>;
        Fri, 01 Jul 2016 10:47:03 -0700 (PDT)
Subject: [PATCH 1/4] x86, swap: move swap offset/type up in PTE to work around erratum
From: Dave Hansen <dave@sr71.net>
Date: Fri, 01 Jul 2016 10:47:03 -0700
References: <20160701174658.6ED27E64@viggo.jf.intel.com>
In-Reply-To: <20160701174658.6ED27E64@viggo.jf.intel.com>
Message-Id: <20160701174703.64463F94@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: x86@kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, bp@alien8.de, ak@linux.intel.com, mhocko@suse.com, Dave Hansen <dave@sr71.net>


This erratum can result in Accessed/Dirty getting set by the hardware
when we do not expect them to be (on !Present PTEs).

Instead of trying to fix them up after this happens, we just
allow the bits to get set and try to ignore them.  We do this by
shifting the layout of the bits we use for swap offset/type in
our 64-bit PTEs.

It looks like this:

bitnrs: |     ...            | 11| 10|  9|8|7|6|5| 4| 3|2|1|0|
names:  |     ...            |SW3|SW2|SW1|G|L|D|A|CD|WT|U|W|P|
before: |         OFFSET (9-63)          |0|X|X| TYPE(1-5) |0|
 after: | OFFSET (14-63)  |  TYPE (9-13) |0|X|X|X| X| X|X|X|0|

Note that D was already a don't care (X) even before.  We just
move TYPE up and turn its old spot (which could be hit by the
A bit) into all don't cares.

We take 5 bits away from the offset, but that still leaves us
with 50 bits which lets us index into a 62-bit swapfile (4 EiB).
I think that's probably fine for the moment.  We could
theoretically reclaim 5 of the bits (1, 2, 3, 4, 7) but it
doesn't gain us anything.

---

 b/arch/x86/include/asm/pgtable_64.h |   26 ++++++++++++++++++++------
 1 file changed, 20 insertions(+), 6 deletions(-)

diff -puN arch/x86/include/asm/pgtable_64.h~knl-strays-10-move-swp-pte-bits arch/x86/include/asm/pgtable_64.h
--- a/arch/x86/include/asm/pgtable_64.h~knl-strays-10-move-swp-pte-bits	2016-07-01 10:42:06.511754330 -0700
+++ b/arch/x86/include/asm/pgtable_64.h	2016-07-01 10:42:06.514754467 -0700
@@ -140,18 +140,32 @@ static inline int pgd_large(pgd_t pgd) {
 #define pte_offset_map(dir, address) pte_offset_kernel((dir), (address))
 #define pte_unmap(pte) ((void)(pte))/* NOP */
 
-/* Encode and de-code a swap entry */
+/*
+ * Encode and de-code a swap entry
+ *
+ * |     ...            | 11| 10|  9|8|7|6|5| 4| 3|2|1|0| <- bit number
+ * |     ...            |SW3|SW2|SW1|G|L|D|A|CD|WT|U|W|P| <- bit names
+ * | OFFSET (14->63) | TYPE (10-13) |0|X|X|X| X| X|X|X|0| <- swp entry
+ *
+ * G (8) is aliased and used as a PROT_NONE indicator for
+ * !present ptes.  We need to start storing swap entries above
+ * there.  We also need to avoid using A and D because of an
+ * erratum where they can be incorrectly set by hardware on
+ * non-present PTEs.
+ */
+#define SWP_TYPE_FIRST_BIT (_PAGE_BIT_PROTNONE + 1)
 #define SWP_TYPE_BITS 5
-#define SWP_OFFSET_SHIFT (_PAGE_BIT_PROTNONE + 1)
+/* Place the offset above the type: */
+#define SWP_OFFSET_FIRST_BIT (SWP_TYPE_FIRST_BIT + SWP_TYPE_BITS + 1)
 
 #define MAX_SWAPFILES_CHECK() BUILD_BUG_ON(MAX_SWAPFILES_SHIFT > SWP_TYPE_BITS)
 
-#define __swp_type(x)			(((x).val >> (_PAGE_BIT_PRESENT + 1)) \
+#define __swp_type(x)			(((x).val >> (SWP_TYPE_FIRST_BIT)) \
 					 & ((1U << SWP_TYPE_BITS) - 1))
-#define __swp_offset(x)			((x).val >> SWP_OFFSET_SHIFT)
+#define __swp_offset(x)			((x).val >> SWP_OFFSET_FIRST_BIT)
 #define __swp_entry(type, offset)	((swp_entry_t) { \
-					 ((type) << (_PAGE_BIT_PRESENT + 1)) \
-					 | ((offset) << SWP_OFFSET_SHIFT) })
+					 ((type) << (SWP_TYPE_FIRST_BIT)) \
+					 | ((offset) << SWP_OFFSET_FIRST_BIT) })
 #define __pte_to_swp_entry(pte)		((swp_entry_t) { pte_val((pte)) })
 #define __swp_entry_to_pte(x)		((pte_t) { .pte = (x).val })
 
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
