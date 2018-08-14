Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id ACF366B0003
	for <linux-mm@kvack.org>; Tue, 14 Aug 2018 13:46:44 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id l15-v6so11735244pff.1
        for <linux-mm@kvack.org>; Tue, 14 Aug 2018 10:46:44 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id d7-v6si16711506pll.162.2018.08.14.10.46.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Aug 2018 10:46:43 -0700 (PDT)
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH 4.4 22/43] x86/mm: Move swap offset/type up in PTE to work around erratum
Date: Tue, 14 Aug 2018 19:17:58 +0200
Message-Id: <20180814171518.589533556@linuxfoundation.org>
In-Reply-To: <20180814171517.014285600@linuxfoundation.org>
References: <20180814171517.014285600@linuxfoundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Dave Hansen <dave@sr71.net>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, "Luis R. Rodriguez" <mcgrof@suse.com>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Toshi Kani <toshi.kani@hp.com>, dave.hansen@intel.com, linux-mm@kvack.org, mhocko@suse.com, Ingo Molnar <mingo@kernel.org>, Guenter Roeck <linux@roeck-us.net>

4.4-stable review patch.  If anyone has any objections, please let me know.

------------------

From: Dave Hansen <dave.hansen@linux.intel.com>

commit 00839ee3b299303c6a5e26a0a2485427a3afcbbf upstream

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

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Brian Gerst <brgerst@gmail.com>
Cc: Dave Hansen <dave@sr71.net>
Cc: Denys Vlasenko <dvlasenk@redhat.com>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Luis R. Rodriguez <mcgrof@suse.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Toshi Kani <toshi.kani@hp.com>
Cc: dave.hansen@intel.com
Cc: linux-mm@kvack.org
Cc: mhocko@suse.com
Link: http://lkml.kernel.org/r/20160708001911.9A3FD2B6@viggo.jf.intel.com
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Guenter Roeck <linux@roeck-us.net>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---
 arch/x86/include/asm/pgtable_64.h |   26 ++++++++++++++++++++------
 1 file changed, 20 insertions(+), 6 deletions(-)

--- a/arch/x86/include/asm/pgtable_64.h
+++ b/arch/x86/include/asm/pgtable_64.h
@@ -163,18 +163,32 @@ static inline int pgd_large(pgd_t pgd) {
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
 
