Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f175.google.com (mail-ie0-f175.google.com [209.85.223.175])
	by kanga.kvack.org (Postfix) with ESMTP id 101E26B0092
	for <linux-mm@kvack.org>; Tue, 10 Mar 2015 16:24:11 -0400 (EDT)
Received: by iecsf10 with SMTP id sf10so29037531iec.2
        for <linux-mm@kvack.org>; Tue, 10 Mar 2015 13:24:10 -0700 (PDT)
Received: from g1t5424.austin.hp.com (g1t5424.austin.hp.com. [15.216.225.54])
        by mx.google.com with ESMTPS id ey4si1377493icb.9.2015.03.10.13.24.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Mar 2015 13:24:10 -0700 (PDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH 2/3] mtrr, x86: Fix MTRR lookup to handle inclusive entry
Date: Tue, 10 Mar 2015 14:23:16 -0600
Message-Id: <1426018997-12936-3-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1426018997-12936-1-git-send-email-toshi.kani@hp.com>
References: <1426018997-12936-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, arnd@arndb.de
Cc: linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com, pebolle@tiscali.nl, Toshi Kani <toshi.kani@hp.com>

When an MTRR entry is inclusive to a requested range, i.e.
the start and end of the request are not within the MTRR
entry range but the range contains the MTRR entry entirely,
__mtrr_type_lookup() ignores such case because both
start_state and end_state are set to zero.

This patch fixes the issue by adding a new flag, inclusive,
to detect the case.  This case is then handled in the same
way as (!start_state && end_state).

Also updated the comment in __mtrr_type_lookup() to clarify
that the repeat handling is necessary to handle overlaps
with the default type, since overlaps with multiple entries
alone can be handled without such repeat.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
---
 arch/x86/kernel/cpu/mtrr/generic.c |   20 +++++++++++---------
 1 file changed, 11 insertions(+), 9 deletions(-)

diff --git a/arch/x86/kernel/cpu/mtrr/generic.c b/arch/x86/kernel/cpu/mtrr/generic.c
index 7d74f7b..cdb955f 100644
--- a/arch/x86/kernel/cpu/mtrr/generic.c
+++ b/arch/x86/kernel/cpu/mtrr/generic.c
@@ -154,7 +154,7 @@ static u8 __mtrr_type_lookup(u64 start, u64 end, u64 *partial_end, int *repeat)
 
 	prev_match = 0xFF;
 	for (i = 0; i < num_var_ranges; ++i) {
-		unsigned short start_state, end_state;
+		unsigned short start_state, end_state, inclusive;
 
 		if (!(mtrr_state.var_ranges[i].mask_lo & (1 << 11)))
 			continue;
@@ -166,20 +166,22 @@ static u8 __mtrr_type_lookup(u64 start, u64 end, u64 *partial_end, int *repeat)
 
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
 			 * lookup again on the second region.
-			 * Note: This way we handle multiple overlaps as well.
+			 * Note: This way we handle overlaps with multiple
+			 * entries and the default type properly.
 			 */
 			if (start_state)
 				*partial_end = base + get_mtrr_size(mask);
@@ -195,7 +197,7 @@ static u8 __mtrr_type_lookup(u64 start, u64 end, u64 *partial_end, int *repeat)
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
