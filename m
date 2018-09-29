Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id A47E38E0001
	for <linux-mm@kvack.org>; Sat, 29 Sep 2018 17:48:38 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id t79-v6so6762605wmt.3
        for <linux-mm@kvack.org>; Sat, 29 Sep 2018 14:48:38 -0700 (PDT)
Received: from shadbolt.e.decadent.org.uk (shadbolt.e.decadent.org.uk. [88.96.1.126])
        by mx.google.com with ESMTPS id x11-v6si7315680wrv.22.2018.09.29.14.48.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 29 Sep 2018 14:48:36 -0700 (PDT)
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
MIME-Version: 1.0
From: Ben Hutchings <ben@decadent.org.uk>
Date: Sat, 29 Sep 2018 22:43:07 +0100
Message-ID: <lsq.1538257387.740574776@decadent.org.uk>
Subject: [PATCH 3.16 092/131] x86/mm: Move swap offset/type up in PTE to
 work around erratum
In-Reply-To: <lsq.1538257386.330095874@decadent.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, stable@vger.kernel.org
Cc: akpm@linux-foundation.org, "H. Peter Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@kernel.org>, Denys Vlasenko <dvlasenk@redhat.com>, Peter Zijlstra <peterz@infradead.org>, linux-mm@kvack.org, mhocko@suse.com, Brian Gerst <brgerst@gmail.com>, Toshi Kani <toshi.kani@hp.com>, "Luis R. Rodriguez" <mcgrof@suse.com>, Ingo Molnar <mingo@kernel.org>, Dave Hansen <dave@sr71.net>, dave.hansen@intel.com, Linus Torvalds <torvalds@linux-foundation.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>

3.16.59-rc1 review patch.  If anyone has any objections, please let me know.

------------------

From: Dave Hansen <dave.hansen@linux.intel.com>

commit 00839ee3b299303c6a5e26a0a2485427a3afcbbf upstream.

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
[bwh: Backported to 3.16: Bit 9 may be reserved for PAGE_BIT_NUMA, which
 no longer exists upstream.  Adjust the bit numbers accordingly,
 incorporating commit ace7fab7a6cd "x86/mm: Fix swap entry comment and
 macro".]
Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
--- a/arch/x86/include/asm/pgtable_64.h
+++ b/arch/x86/include/asm/pgtable_64.h
@@ -162,23 +162,37 @@ static inline int pgd_large(pgd_t pgd) {
 #define pte_offset_map(dir, address) pte_offset_kernel((dir), (address))
 #define pte_unmap(pte) ((void)(pte))/* NOP */
 
-/* Encode and de-code a swap entry */
-#define SWP_TYPE_BITS 5
+/*
+ * Encode and de-code a swap entry
+ *
+ * |     ...                | 11| 10|  9|8|7|6|5| 4| 3|2|1|0| <- bit number
+ * |     ...                |SW3|SW2|SW1|G|L|D|A|CD|WT|U|W|P| <- bit names
+ * | OFFSET (15->63) | TYPE (10-14) | 0 |0|X|X|X| X| X|X|X|0| <- swp entry
+ *
+ * G (8) is aliased and used as a PROT_NONE indicator for
+ * !present ptes.  We need to start storing swap entries above
+ * there.  We also need to avoid using A and D because of an
+ * erratum where they can be incorrectly set by hardware on
+ * non-present PTEs.
+ */
 #ifdef CONFIG_NUMA_BALANCING
 /* Automatic NUMA balancing needs to be distinguishable from swap entries */
-#define SWP_OFFSET_SHIFT (_PAGE_BIT_PROTNONE + 2)
+#define SWP_TYPE_FIRST_SHIFT (_PAGE_BIT_PROTNONE + 2)
 #else
-#define SWP_OFFSET_SHIFT (_PAGE_BIT_PROTNONE + 1)
+#define SWP_TYPE_FIRST_SHIFT (_PAGE_BIT_PROTNONE + 1)
 #endif
+#define SWP_TYPE_BITS 5
+/* Place the offset above the type: */
+#define SWP_OFFSET_FIRST_BIT (SWP_TYPE_FIRST_BIT + SWP_TYPE_BITS)
 
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
 
