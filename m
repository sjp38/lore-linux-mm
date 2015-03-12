Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f182.google.com (mail-ob0-f182.google.com [209.85.214.182])
	by kanga.kvack.org (Postfix) with ESMTP id 9565E829A3
	for <linux-mm@kvack.org>; Thu, 12 Mar 2015 13:19:07 -0400 (EDT)
Received: by obcvb8 with SMTP id vb8so15441998obc.0
        for <linux-mm@kvack.org>; Thu, 12 Mar 2015 10:19:07 -0700 (PDT)
Received: from g4t3427.houston.hp.com (g4t3427.houston.hp.com. [15.201.208.55])
        by mx.google.com with ESMTPS id sb9si4187357obb.24.2015.03.12.10.19.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Mar 2015 10:19:06 -0700 (PDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH v2 3/4] mtrr, x86: Clean up mtrr_type_lookup()
Date: Thu, 12 Mar 2015 11:18:09 -0600
Message-Id: <1426180690-24234-4-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1426180690-24234-1-git-send-email-toshi.kani@hp.com>
References: <1426180690-24234-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com
Cc: linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com, pebolle@tiscali.nl, Toshi Kani <toshi.kani@hp.com>

MTRRs contain fixed and variable entries.  mtrr_type_lookup()
may repeatedly call __mtrr_type_lookup() to handle a request
that overlaps with variable entries.  However,
__mtrr_type_lookup() also handles the fixed entries and other
conditions, which do not have to be repeated.  This patch moves
such code from __mtrr_type_lookup() to mtrr_type_lookup().

This patch also changes the 'else if (start < 0x1000000)',
which checks a fixed range but has an extra zero in the address,
to 'else' with no condition.

Lastly, the patch updates the function headers to clarify the
return values and output argument.  It also updates comments to
clarify that the repeating is necessary to handle overlaps with
the default type, since overlaps with multiple entries alone
can be handled without such repeating.

There is no functional change in this patch.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
---
 arch/x86/kernel/cpu/mtrr/generic.c |  102 +++++++++++++++++++-----------------
 1 file changed, 53 insertions(+), 49 deletions(-)

diff --git a/arch/x86/kernel/cpu/mtrr/generic.c b/arch/x86/kernel/cpu/mtrr/generic.c
index a82e370..ef34a4f 100644
--- a/arch/x86/kernel/cpu/mtrr/generic.c
+++ b/arch/x86/kernel/cpu/mtrr/generic.c
@@ -102,12 +102,16 @@ static int check_type_overlap(u8 *prev, u8 *curr)
 	return 0;
 }
 
-/*
- * Error/Semi-error returns:
- * 0xFF - when MTRR is not enabled
- * *repeat == 1 implies [start:end] spanned across MTRR range and type returned
- *		corresponds only to [start:*partial_end].
- *		Caller has to lookup again for [*partial_end:end].
+/**
+ * __mtrr_type_lookup - look up memory type in MTRR variable entries
+ *
+ * Return Value:
+ * memory type - Matched memory type or the default memory type (unmatched)
+ *
+ * Output Argument:
+ * repeat - Set to 1 when [start:end] spanned across MTRR range and type
+ *	    returned corresponds only to [start:*partial_end].  Caller has
+ *	    to lookup again for [*partial_end:end].
  */
 static u8 __mtrr_type_lookup(u64 start, u64 end, u64 *partial_end, int *repeat)
 {
@@ -116,42 +120,10 @@ static u8 __mtrr_type_lookup(u64 start, u64 end, u64 *partial_end, int *repeat)
 	u8 prev_match, curr_match;
 
 	*repeat = 0;
-	if (!mtrr_state_set)
-		return 0xFF;
-
-	if (!mtrr_state.enabled)
-		return 0xFF;
 
 	/* Make end inclusive end, instead of exclusive */
 	end--;
 
-	/* Look in fixed ranges. Just return the type as per start */
-	if (mtrr_state.have_fixed && (start < 0x100000)) {
-		int idx;
-
-		if (start < 0x80000) {
-			idx = 0;
-			idx += (start >> 16);
-			return mtrr_state.fixed_ranges[idx];
-		} else if (start < 0xC0000) {
-			idx = 1 * 8;
-			idx += ((start - 0x80000) >> 14);
-			return mtrr_state.fixed_ranges[idx];
-		} else if (start < 0x1000000) {
-			idx = 3 * 8;
-			idx += ((start - 0xC0000) >> 12);
-			return mtrr_state.fixed_ranges[idx];
-		}
-	}
-
-	/*
-	 * Look in variable ranges
-	 * Look of multiple ranges matching this address and pick type
-	 * as per MTRR precedence
-	 */
-	if (!(mtrr_state.enabled & 2))
-		return mtrr_state.def_type;
-
 	prev_match = 0xFF;
 	for (i = 0; i < num_var_ranges; ++i) {
 		unsigned short start_state, end_state, inclusive;
@@ -180,7 +152,8 @@ static u8 __mtrr_type_lookup(u64 start, u64 end, u64 *partial_end, int *repeat)
 			 * Return the type for first region and a pointer to
 			 * the start of second region so that caller will
 			 * lookup again on the second region.
-			 * Note: This way we handle multiple overlaps as well.
+			 * Note: This way we handle overlaps with multiple
+			 * entries and the default type properly.
 			 */
 			if (start_state)
 				*partial_end = base + get_mtrr_size(mask);
@@ -209,21 +182,18 @@ static u8 __mtrr_type_lookup(u64 start, u64 end, u64 *partial_end, int *repeat)
 			return curr_match;
 	}
 
-	if (mtrr_tom2) {
-		if (start >= (1ULL<<32) && (end < mtrr_tom2))
-			return MTRR_TYPE_WRBACK;
-	}
-
 	if (prev_match != 0xFF)
 		return prev_match;
 
 	return mtrr_state.def_type;
 }
 
-/*
- * Returns the effective MTRR type for the region
- * Error return:
- * 0xFF - when MTRR is not enabled
+/**
+ * mtrr_type_lookup - look up memory type in MTRR
+ *
+ * Return Values:
+ * memory type - The effective MTRR type for the region
+ * 0xFF - MTRR is disabled
  */
 u8 mtrr_type_lookup(u64 start, u64 end)
 {
@@ -231,12 +201,43 @@ u8 mtrr_type_lookup(u64 start, u64 end)
 	int repeat;
 	u64 partial_end;
 
+	if (!mtrr_state_set || !mtrr_state.enabled)
+		return 0xFF;
+
+	/* Look in fixed ranges. Just return the type as per start */
+	if (mtrr_state.have_fixed && (start < 0x100000)) {
+		int idx;
+
+		if (start < 0x80000) {
+			idx = 0;
+			idx += (start >> 16);
+			return mtrr_state.fixed_ranges[idx];
+		} else if (start < 0xC0000) {
+			idx = 1 * 8;
+			idx += ((start - 0x80000) >> 14);
+			return mtrr_state.fixed_ranges[idx];
+		} else {
+			idx = 3 * 8;
+			idx += ((start - 0xC0000) >> 12);
+			return mtrr_state.fixed_ranges[idx];
+		}
+	}
+
+	/*
+	 * Look in variable ranges
+	 * Look of multiple ranges matching this address and pick type
+	 * as per MTRR precedence
+	 */
+	if (!(mtrr_state.enabled & 2))
+		return mtrr_state.def_type;
+
 	type = __mtrr_type_lookup(start, end, &partial_end, &repeat);
 
 	/*
 	 * Common path is with repeat = 0.
 	 * However, we can have cases where [start:end] spans across some
-	 * MTRR range. Do repeated lookups for that case here.
+	 * MTRR ranges and/or the default type.  Do repeated lookups for
+	 * that case here.
 	 */
 	while (repeat) {
 		prev_type = type;
@@ -247,6 +248,9 @@ u8 mtrr_type_lookup(u64 start, u64 end)
 			return type;
 	}
 
+	if (mtrr_tom2 && (start >= (1ULL<<32)) && (end < mtrr_tom2))
+		return MTRR_TYPE_WRBACK;
+
 	return type;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
