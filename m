Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f179.google.com (mail-ob0-f179.google.com [209.85.214.179])
	by kanga.kvack.org (Postfix) with ESMTP id 215386B006E
	for <linux-mm@kvack.org>; Tue, 24 Mar 2015 18:27:50 -0400 (EDT)
Received: by obcjt1 with SMTP id jt1so5788019obc.2
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 15:27:49 -0700 (PDT)
Received: from g4t3427.houston.hp.com (g4t3427.houston.hp.com. [15.201.208.55])
        by mx.google.com with ESMTPS id 21si366686oil.18.2015.03.24.15.27.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Mar 2015 15:27:49 -0700 (PDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH v4 2/7] mtrr, x86: Fix MTRR lookup to handle inclusive entry
Date: Tue, 24 Mar 2015 16:08:36 -0600
Message-Id: <1427234921-19737-3-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1427234921-19737-1-git-send-email-toshi.kani@hp.com>
References: <1427234921-19737-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com
Cc: linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com, pebolle@tiscali.nl, Toshi Kani <toshi.kani@hp.com>

When an MTRR entry is inclusive to a requested range, i.e.
the start and end of the request are not within the MTRR
entry range but the range contains the MTRR entry entirely,
__mtrr_type_lookup() ignores such a case because both
start_state and end_state are set to zero.

This bug can cause the following issues:
1) reserve_memtype() tracks an effective memory type in case
   a request type is WB (ex. /dev/mem blindly uses WB). Missing
   to track with its effective type causes a subsequent request
   to map the same range with the effective type to fail.
2) pud_set_huge() and pmd_set_huge() check if a requested range
   has any overlap with MTRRs. Missing to detect an overlap may
   cause a performance penalty or undefined behavior.

This patch fixes the bug by adding a new flag, 'inclusive',
to detect the inclusive case.  This case is then handled in
the same way as (!start_state && end_state).  With this fix,
__mtrr_type_lookup() handles the inclusive case properly.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
---
 arch/x86/kernel/cpu/mtrr/generic.c |   17 +++++++++--------
 1 file changed, 9 insertions(+), 8 deletions(-)

diff --git a/arch/x86/kernel/cpu/mtrr/generic.c b/arch/x86/kernel/cpu/mtrr/generic.c
index 7d74f7b..a82e370 100644
--- a/arch/x86/kernel/cpu/mtrr/generic.c
+++ b/arch/x86/kernel/cpu/mtrr/generic.c
@@ -154,7 +154,7 @@ static u8 __mtrr_type_lookup(u64 start, u64 end, u64 *partial_end, int *repeat)
 
 	prev_match = 0xFF;
 	for (i = 0; i < num_var_ranges; ++i) {
-		unsigned short start_state, end_state;
+		unsigned short start_state, end_state, inclusive;
 
 		if (!(mtrr_state.var_ranges[i].mask_lo & (1 << 11)))
 			continue;
@@ -166,15 +166,16 @@ static u8 __mtrr_type_lookup(u64 start, u64 end, u64 *partial_end, int *repeat)
 
 		start_state = ((start & mask) == (base & mask));
 		end_state = ((end & mask) == (base & mask));
+		inclusive = ((start < base) && (end > base));
 
-		if (start_state != end_state) {
+		if ((start_state != end_state) || inclusive) {
 			/*
 			 * We have start:end spanning across an MTRR.
-			 * We split the region into
-			 * either
-			 * (start:mtrr_end) (mtrr_end:end)
-			 * or
-			 * (start:mtrr_start) (mtrr_start:end)
+			 * We split the region into either
+			 * - start_state:1
+			 *     (start:mtrr_end) (mtrr_end:end)
+			 * - end_state:1 or inclusive:1
+			 *     (start:mtrr_start) (mtrr_start:end)
 			 * depending on kind of overlap.
 			 * Return the type for first region and a pointer to
 			 * the start of second region so that caller will
@@ -195,7 +196,7 @@ static u8 __mtrr_type_lookup(u64 start, u64 end, u64 *partial_end, int *repeat)
 			*repeat = 1;
 		}
 
-		if ((start & mask) != (base & mask))
+		if (!start_state)
 			continue;
 
 		curr_match = mtrr_state.var_ranges[i].base_lo & 0xff;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
