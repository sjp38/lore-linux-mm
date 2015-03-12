Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f52.google.com (mail-oi0-f52.google.com [209.85.218.52])
	by kanga.kvack.org (Postfix) with ESMTP id 17691829A3
	for <linux-mm@kvack.org>; Thu, 12 Mar 2015 13:19:05 -0400 (EDT)
Received: by oiga141 with SMTP id a141so15799583oig.13
        for <linux-mm@kvack.org>; Thu, 12 Mar 2015 10:19:04 -0700 (PDT)
Received: from g4t3425.houston.hp.com (g4t3425.houston.hp.com. [15.201.208.53])
        by mx.google.com with ESMTPS id t82si2159039oib.86.2015.03.12.10.19.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Mar 2015 10:19:04 -0700 (PDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH v2 2/4] mtrr, x86: Fix MTRR lookup to handle inclusive entry
Date: Thu, 12 Mar 2015 11:18:08 -0600
Message-Id: <1426180690-24234-3-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1426180690-24234-1-git-send-email-toshi.kani@hp.com>
References: <1426180690-24234-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com
Cc: linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com, pebolle@tiscali.nl, Toshi Kani <toshi.kani@hp.com>

When an MTRR entry is inclusive to a requested range, i.e.
the start and end of the request are not within the MTRR
entry range but the range contains the MTRR entry entirely,
__mtrr_type_lookup() ignores such a case because both
start_state and end_state are set to zero.

This patch fixes the issue by adding a new flag, 'inclusive',
to detect the case.  This case is then handled in the same
way as (!start_state && end_state).

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
