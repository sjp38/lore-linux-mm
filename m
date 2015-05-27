Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 074416B0106
	for <linux-mm@kvack.org>; Wed, 27 May 2015 10:19:58 -0400 (EDT)
Received: by pdbki1 with SMTP id ki1so17258970pdb.1
        for <linux-mm@kvack.org>; Wed, 27 May 2015 07:19:57 -0700 (PDT)
Received: from terminus.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id b5si26208669pdk.61.2015.05.27.07.19.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 May 2015 07:19:57 -0700 (PDT)
Date: Wed, 27 May 2015 07:19:05 -0700
From: tip-bot for Toshi Kani <tipbot@zytor.com>
Message-ID: <tip-0cc705f56e400764a171055f727d28a48260bb4b@git.kernel.org>
Reply-To: mingo@kernel.org, hpa@zytor.com, bp@alien8.de, dvlasenk@redhat.com,
        bp@suse.de, akpm@linux-foundation.org, brgerst@gmail.com,
        peterz@infradead.org, tglx@linutronix.de, linux-mm@kvack.org,
        luto@amacapital.net, mcgrof@suse.com, toshi.kani@hp.com,
        torvalds@linux-foundation.org, linux-kernel@vger.kernel.org
In-Reply-To: <1432628901-18044-6-git-send-email-bp@alien8.de>
References: <1431714237-880-6-git-send-email-toshi.kani@hp.com>
	<1432628901-18044-6-git-send-email-bp@alien8.de>
Subject: [tip:x86/mm] x86/mm/mtrr: Clean up mtrr_type_lookup()
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-tip-commits@vger.kernel.org
Cc: hpa@zytor.com, dvlasenk@redhat.com, bp@alien8.de, bp@suse.de, mingo@kernel.org, luto@amacapital.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, mcgrof@suse.com, toshi.kani@hp.com, brgerst@gmail.com, peterz@infradead.org, akpm@linux-foundation.org, tglx@linutronix.de

Commit-ID:  0cc705f56e400764a171055f727d28a48260bb4b
Gitweb:     http://git.kernel.org/tip/0cc705f56e400764a171055f727d28a48260bb4b
Author:     Toshi Kani <toshi.kani@hp.com>
AuthorDate: Tue, 26 May 2015 10:28:08 +0200
Committer:  Ingo Molnar <mingo@kernel.org>
CommitDate: Wed, 27 May 2015 14:40:57 +0200

x86/mm/mtrr: Clean up mtrr_type_lookup()

MTRRs contain fixed and variable entries. mtrr_type_lookup() may
repeatedly call __mtrr_type_lookup() to handle a request that
overlaps with variable entries.

However, __mtrr_type_lookup() also handles the fixed entries,
which do not have to be repeated. Therefore, this patch creates
separate functions, mtrr_type_lookup_fixed() and
mtrr_type_lookup_variable(), to handle the fixed and variable
ranges respectively.

The patch also updates the function headers to clarify the
return values and output argument. It updates comments to
clarify that the repeating is necessary to handle overlaps with
the default type, since overlaps with multiple entries alone can
be handled without such repeating.

There is no functional change in this patch.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
Signed-off-by: Borislav Petkov <bp@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Brian Gerst <brgerst@gmail.com>
Cc: Denys Vlasenko <dvlasenk@redhat.com>
Cc: Elliott@hp.com
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Luis R. Rodriguez <mcgrof@suse.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: dave.hansen@intel.com
Cc: linux-mm <linux-mm@kvack.org>
Cc: pebolle@tiscali.nl
Link: http://lkml.kernel.org/r/1431714237-880-6-git-send-email-toshi.kani@hp.com
Link: http://lkml.kernel.org/r/1432628901-18044-6-git-send-email-bp@alien8.de
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 arch/x86/kernel/cpu/mtrr/generic.c | 138 +++++++++++++++++++++++--------------
 1 file changed, 86 insertions(+), 52 deletions(-)

diff --git a/arch/x86/kernel/cpu/mtrr/generic.c b/arch/x86/kernel/cpu/mtrr/generic.c
index 7b1491c..e51100c 100644
--- a/arch/x86/kernel/cpu/mtrr/generic.c
+++ b/arch/x86/kernel/cpu/mtrr/generic.c
@@ -102,55 +102,68 @@ static int check_type_overlap(u8 *prev, u8 *curr)
 	return 0;
 }
 
-/*
- * Error/Semi-error returns:
- * MTRR_TYPE_INVALID - when MTRR is not enabled
- * *repeat == 1 implies [start:end] spanned across MTRR range and type returned
- *		corresponds only to [start:*partial_end].
- *		Caller has to lookup again for [*partial_end:end].
+/**
+ * mtrr_type_lookup_fixed - look up memory type in MTRR fixed entries
+ *
+ * Return the MTRR fixed memory type of 'start'.
+ *
+ * MTRR fixed entries are divided into the following ways:
+ *  0x00000 - 0x7FFFF : This range is divided into eight 64KB sub-ranges
+ *  0x80000 - 0xBFFFF : This range is divided into sixteen 16KB sub-ranges
+ *  0xC0000 - 0xFFFFF : This range is divided into sixty-four 4KB sub-ranges
+ *
+ * Return Values:
+ * MTRR_TYPE_(type)  - Matched memory type
+ * MTRR_TYPE_INVALID - Unmatched
+ */
+static u8 mtrr_type_lookup_fixed(u64 start, u64 end)
+{
+	int idx;
+
+	if (start >= 0x100000)
+		return MTRR_TYPE_INVALID;
+
+	/* 0x0 - 0x7FFFF */
+	if (start < 0x80000) {
+		idx = 0;
+		idx += (start >> 16);
+		return mtrr_state.fixed_ranges[idx];
+	/* 0x80000 - 0xBFFFF */
+	} else if (start < 0xC0000) {
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
+ * MTRR_TYPE_(type) - Matched memory type or default memory type (unmatched)
+ *
+ * Output Argument:
+ * repeat - Set to 1 when [start:end] spanned across MTRR range and type
+ *	    returned corresponds only to [start:*partial_end].  Caller has
+ *	    to lookup again for [*partial_end:end].
  */
-static u8 __mtrr_type_lookup(u64 start, u64 end, u64 *partial_end, int *repeat)
+static u8 mtrr_type_lookup_variable(u64 start, u64 end, u64 *partial_end,
+				    int *repeat)
 {
 	int i;
 	u64 base, mask;
 	u8 prev_match, curr_match;
 
 	*repeat = 0;
-	if (!mtrr_state_set)
-		return MTRR_TYPE_INVALID;
-
-	if (!(mtrr_state.enabled & MTRR_STATE_MTRR_ENABLED))
-		return MTRR_TYPE_INVALID;
 
-	/* Make end inclusive end, instead of exclusive */
+	/* Make end inclusive instead of exclusive */
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
 	prev_match = MTRR_TYPE_INVALID;
 	for (i = 0; i < num_var_ranges; ++i) {
 		unsigned short start_state, end_state, inclusive;
@@ -186,7 +199,8 @@ static u8 __mtrr_type_lookup(u64 start, u64 end, u64 *partial_end, int *repeat)
 			 * advised to lookup again after having adjusted start
 			 * and end.
 			 *
-			 * Note: This way we handle multiple overlaps as well.
+			 * Note: This way we handle overlaps with multiple
+			 * entries and the default type properly.
 			 */
 			if (start_state)
 				*partial_end = base + get_mtrr_size(mask);
@@ -215,21 +229,18 @@ static u8 __mtrr_type_lookup(u64 start, u64 end, u64 *partial_end, int *repeat)
 			return curr_match;
 	}
 
-	if (mtrr_tom2) {
-		if (start >= (1ULL<<32) && (end < mtrr_tom2))
-			return MTRR_TYPE_WRBACK;
-	}
-
 	if (prev_match != MTRR_TYPE_INVALID)
 		return prev_match;
 
 	return mtrr_state.def_type;
 }
 
-/*
- * Returns the effective MTRR type for the region
- * Error return:
- * MTRR_TYPE_INVALID - when MTRR is not enabled
+/**
+ * mtrr_type_lookup - look up memory type in MTRR
+ *
+ * Return Values:
+ * MTRR_TYPE_(type)  - The effective MTRR type for the region
+ * MTRR_TYPE_INVALID - MTRR is disabled
  */
 u8 mtrr_type_lookup(u64 start, u64 end)
 {
@@ -237,22 +248,45 @@ u8 mtrr_type_lookup(u64 start, u64 end)
 	int repeat;
 	u64 partial_end;
 
-	type = __mtrr_type_lookup(start, end, &partial_end, &repeat);
+	if (!mtrr_state_set)
+		return MTRR_TYPE_INVALID;
+
+	if (!(mtrr_state.enabled & MTRR_STATE_MTRR_ENABLED))
+		return MTRR_TYPE_INVALID;
+
+	/*
+	 * Look up the fixed ranges first, which take priority over
+	 * the variable ranges.
+	 */
+	if ((start < 0x100000) &&
+	    (mtrr_state.have_fixed) &&
+	    (mtrr_state.enabled & MTRR_STATE_MTRR_FIXED_ENABLED))
+		return mtrr_type_lookup_fixed(start, end);
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
+		type = mtrr_type_lookup_variable(start, end, &partial_end, &repeat);
 
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
