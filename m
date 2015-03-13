Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f174.google.com (mail-ie0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id 1E13D829CA
	for <linux-mm@kvack.org>; Fri, 13 Mar 2015 17:34:43 -0400 (EDT)
Received: by iecvj10 with SMTP id vj10so123763659iec.0
        for <linux-mm@kvack.org>; Fri, 13 Mar 2015 14:34:42 -0700 (PDT)
Received: from g4t3426.houston.hp.com (g4t3426.houston.hp.com. [15.201.208.54])
        by mx.google.com with ESMTPS id ch8si1649533oec.62.2015.03.13.14.34.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Mar 2015 14:34:39 -0700 (PDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH v3 4/5] mtrr, x86: Clean up mtrr_type_lookup()
Date: Fri, 13 Mar 2015 15:33:40 -0600
Message-Id: <1426282421-25385-5-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1426282421-25385-1-git-send-email-toshi.kani@hp.com>
References: <1426282421-25385-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com
Cc: linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com, pebolle@tiscali.nl, Toshi Kani <toshi.kani@hp.com>

MTRRs contain fixed and variable entries.  mtrr_type_lookup()
may repeatedly call __mtrr_type_lookup() to handle a request
that overlaps with variable entries.  However,
__mtrr_type_lookup() also handles the fixed entries, which
do not have to be repeated.  Therefore, this patch creates
separate functions, mtrr_type_lookup_fixed() and
mtrr_type_lookup_variable(), to handle the fixed and variable
ranges respectively.

The patch also updates the function headers to clarify the
return values and output argument.  It updates comments to
clarify that the repeating is necessary to handle overlaps
with the default type, since overlaps with multiple entries
alone can be handled without such repeating.

There is no functional change in this patch.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
---
 arch/x86/kernel/cpu/mtrr/generic.c |  132 ++++++++++++++++++++++--------------
 1 file changed, 81 insertions(+), 51 deletions(-)

diff --git a/arch/x86/kernel/cpu/mtrr/generic.c b/arch/x86/kernel/cpu/mtrr/generic.c
index 4bff6db..271b19c 100644
--- a/arch/x86/kernel/cpu/mtrr/generic.c
+++ b/arch/x86/kernel/cpu/mtrr/generic.c
@@ -102,55 +102,64 @@ static int check_type_overlap(u8 *prev, u8 *curr)
 	return 0;
 }
 
-/*
- * Error/Semi-error returns:
- * 0xFF - when MTRR is not enabled
- * *repeat == 1 implies [start:end] spanned across MTRR range and type returned
- *		corresponds only to [start:*partial_end].
- *		Caller has to lookup again for [*partial_end:end].
+/**
+ * mtrr_type_lookup_fixed - look up memory type in MTRR fixed entries
+ *
+ * Return Values:
+ * memory type - Matched memory type
+ * 0xFF - Unmatched or fixed entries are disabled
  */
-static u8 __mtrr_type_lookup(u64 start, u64 end, u64 *partial_end, int *repeat)
+static u8 mtrr_type_lookup_fixed(u64 start, u64 end)
+{
+	int idx;
+
+	if (start >= 0x100000)
+		return 0xFF;
+
+	if (!(mtrr_state.have_fixed) ||
+	    !(mtrr_state.enabled & MTRR_STATE_MTRR_FIXED_ENABLED))
+		return 0xFF;
+
+	if (start < 0x80000) {		/* 0x0 - 0x7FFFF */
+		idx = 0;
+		idx += (start >> 16);
+		return mtrr_state.fixed_ranges[idx];
+
+	} else if (start < 0xC0000) {	/* 0x80000 - 0xBFFFF */
+		idx = 1 * 8;
+		idx += ((start - 0x80000) >> 14);
+		return mtrr_state.fixed_ranges[idx];
+	}
+
+	/* 0xC0000 - 0xFFFFF */
+	idx = 3 * 8;
+	idx += ((start - 0xC0000) >> 12);
+	return mtrr_state.fixed_ranges[idx];
+}
+
+/**
+ * mtrr_type_lookup_variable - look up memory type in MTRR variable entries
+ *
+ * Return Value:
+ * memory type - Matched memory type or the default memory type (unmatched)
+ *
+ * Output Argument:
+ * repeat - Set to 1 when [start:end] spanned across MTRR range and type
+ *	    returned corresponds only to [start:*partial_end].  Caller has
+ *	    to lookup again for [*partial_end:end].
+ */
+static u8 mtrr_type_lookup_variable(u64 start, u64 end, u64 *partial_end,
+				    int *repeat)
 {
 	int i;
 	u64 base, mask;
 	u8 prev_match, curr_match;
 
 	*repeat = 0;
-	if (!mtrr_state_set)
-		return 0xFF;
-
-	if (!(mtrr_state.enabled & MTRR_STATE_MTRR_ENABLED))
-		return 0xFF;
 
 	/* Make end inclusive end, instead of exclusive */
 	end--;
 
-	/* Look in fixed ranges. Just return the type as per start */
-	if ((start < 0x100000) &&
-	    (mtrr_state.have_fixed) &&
-	    (mtrr_state.enabled & MTRR_STATE_MTRR_FIXED_ENABLED)) {
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
-		} else {
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
 	prev_match = 0xFF;
 	for (i = 0; i < num_var_ranges; ++i) {
 		unsigned short start_state, end_state, inclusive;
@@ -179,7 +188,8 @@ static u8 __mtrr_type_lookup(u64 start, u64 end, u64 *partial_end, int *repeat)
 			 * Return the type for first region and a pointer to
 			 * the start of second region so that caller will
 			 * lookup again on the second region.
-			 * Note: This way we handle multiple overlaps as well.
+			 * Note: This way we handle overlaps with multiple
+			 * entries and the default type properly.
 			 */
 			if (start_state)
 				*partial_end = base + get_mtrr_size(mask);
@@ -208,21 +218,18 @@ static u8 __mtrr_type_lookup(u64 start, u64 end, u64 *partial_end, int *repeat)
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
@@ -230,22 +237,45 @@ u8 mtrr_type_lookup(u64 start, u64 end)
 	int repeat;
 	u64 partial_end;
 
-	type = __mtrr_type_lookup(start, end, &partial_end, &repeat);
+	if (!mtrr_state_set)
+		return 0xFF;
+
+	if (!(mtrr_state.enabled & MTRR_STATE_MTRR_ENABLED))
+		return 0xFF;
+
+	/*
+	 * Look up the fixed ranges first, which take priority over
+	 * the variable ranges.
+	 */
+	type = mtrr_type_lookup_fixed(start, end);
+	if (type != 0xFF)
+		return type;
+
+	/*
+	 * Look up the variable ranges.  Look of multiple ranges matching
+	 * this address and pick type as per MTRR precedence.
+	 */
+	type = mtrr_type_lookup_variable(start, end, &partial_end, &repeat);
 
 	/*
 	 * Common path is with repeat = 0.
 	 * However, we can have cases where [start:end] spans across some
-	 * MTRR range. Do repeated lookups for that case here.
+	 * MTRR ranges and/or the default type.  Do repeated lookups for
+	 * that case here.
 	 */
 	while (repeat) {
 		prev_type = type;
 		start = partial_end;
-		type = __mtrr_type_lookup(start, end, &partial_end, &repeat);
+		type = mtrr_type_lookup_variable(start, end, &partial_end,
+						 &repeat);
 
 		if (check_type_overlap(&prev_type, &type))
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
