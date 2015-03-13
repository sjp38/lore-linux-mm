Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f176.google.com (mail-ob0-f176.google.com [209.85.214.176])
	by kanga.kvack.org (Postfix) with ESMTP id 7375F829CA
	for <linux-mm@kvack.org>; Fri, 13 Mar 2015 17:34:38 -0400 (EDT)
Received: by obcwo20 with SMTP id wo20so22588303obc.2
        for <linux-mm@kvack.org>; Fri, 13 Mar 2015 14:34:38 -0700 (PDT)
Received: from g1t5424.austin.hp.com (g1t5424.austin.hp.com. [15.216.225.54])
        by mx.google.com with ESMTPS id e71si1649091oih.123.2015.03.13.14.34.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Mar 2015 14:34:37 -0700 (PDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH v3 3/5] mtrr, x86: Fix MTRR state checks in mtrr_type_lookup()
Date: Fri, 13 Mar 2015 15:33:39 -0600
Message-Id: <1426282421-25385-4-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1426282421-25385-1-git-send-email-toshi.kani@hp.com>
References: <1426282421-25385-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com
Cc: linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com, pebolle@tiscali.nl, Toshi Kani <toshi.kani@hp.com>

'mtrr_state.enabled' contains FE (fixed MTRRs enabled) and
E (MTRRs enabled) flags in MSR_MTRRdefType.  Intel SDM,
section 11.11.2.1, defines these flags as follows:
 - All MTRRs are disabled when the E flag is clear.
   The FE flag has no affect when the E flag is clear.
 - The default type is enabled when the E flag is set.
 - MTRR variable ranges are enabled when the E flag is set.
 - MTRR fixed ranges are enabled when both E and FE flags
   are set.

MTRR state checks in __mtrr_type_lookup() do not follow the
SDM definitions.  Therefore, this patch fixes the MTRR state
checks according to the SDM.  This patch defines the flags
in mtrr_state.enabled as follows.  print_mtrr_state() is also
updated.
 - FE flag: MTRR_STATE_MTRR_FIXED_ENABLED
 - E  flag: MTRR_STATE_MTRR_ENABLED

Lastly, this patch fixes the 'else if (start < 0x1000000)',
which checks a fixed range but has an extra-zero in the
address, to 'else' with no condition.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
---
 arch/x86/include/uapi/asm/mtrr.h   |    4 ++++
 arch/x86/kernel/cpu/mtrr/generic.c |   17 +++++++++--------
 2 files changed, 13 insertions(+), 8 deletions(-)

diff --git a/arch/x86/include/uapi/asm/mtrr.h b/arch/x86/include/uapi/asm/mtrr.h
index d0acb65..66ba88d 100644
--- a/arch/x86/include/uapi/asm/mtrr.h
+++ b/arch/x86/include/uapi/asm/mtrr.h
@@ -88,6 +88,10 @@ struct mtrr_state_type {
 	mtrr_type def_type;
 };
 
+/* Bit fields for enabled in struct mtrr_state_type */
+#define MTRR_STATE_MTRR_FIXED_ENABLED	0x01
+#define MTRR_STATE_MTRR_ENABLED		0x02
+
 #define MTRRphysBase_MSR(reg) (0x200 + 2 * (reg))
 #define MTRRphysMask_MSR(reg) (0x200 + 2 * (reg) + 1)
 
diff --git a/arch/x86/kernel/cpu/mtrr/generic.c b/arch/x86/kernel/cpu/mtrr/generic.c
index a82e370..4bff6db 100644
--- a/arch/x86/kernel/cpu/mtrr/generic.c
+++ b/arch/x86/kernel/cpu/mtrr/generic.c
@@ -119,14 +119,16 @@ static u8 __mtrr_type_lookup(u64 start, u64 end, u64 *partial_end, int *repeat)
 	if (!mtrr_state_set)
 		return 0xFF;
 
-	if (!mtrr_state.enabled)
+	if (!(mtrr_state.enabled & MTRR_STATE_MTRR_ENABLED))
 		return 0xFF;
 
 	/* Make end inclusive end, instead of exclusive */
 	end--;
 
 	/* Look in fixed ranges. Just return the type as per start */
-	if (mtrr_state.have_fixed && (start < 0x100000)) {
+	if ((start < 0x100000) &&
+	    (mtrr_state.have_fixed) &&
+	    (mtrr_state.enabled & MTRR_STATE_MTRR_FIXED_ENABLED)) {
 		int idx;
 
 		if (start < 0x80000) {
@@ -137,7 +139,7 @@ static u8 __mtrr_type_lookup(u64 start, u64 end, u64 *partial_end, int *repeat)
 			idx = 1 * 8;
 			idx += ((start - 0x80000) >> 14);
 			return mtrr_state.fixed_ranges[idx];
-		} else if (start < 0x1000000) {
+		} else {
 			idx = 3 * 8;
 			idx += ((start - 0xC0000) >> 12);
 			return mtrr_state.fixed_ranges[idx];
@@ -149,9 +151,6 @@ static u8 __mtrr_type_lookup(u64 start, u64 end, u64 *partial_end, int *repeat)
 	 * Look of multiple ranges matching this address and pick type
 	 * as per MTRR precedence
 	 */
-	if (!(mtrr_state.enabled & 2))
-		return mtrr_state.def_type;
-
 	prev_match = 0xFF;
 	for (i = 0; i < num_var_ranges; ++i) {
 		unsigned short start_state, end_state, inclusive;
@@ -348,7 +347,9 @@ static void __init print_mtrr_state(void)
 		 mtrr_attrib_to_str(mtrr_state.def_type));
 	if (mtrr_state.have_fixed) {
 		pr_debug("MTRR fixed ranges %sabled:\n",
-			 mtrr_state.enabled & 1 ? "en" : "dis");
+			((mtrr_state.enabled & MTRR_STATE_MTRR_ENABLED) &&
+			 (mtrr_state.enabled & MTRR_STATE_MTRR_FIXED_ENABLED)) ?
+			 "en" : "dis");
 		print_fixed(0x00000, 0x10000, mtrr_state.fixed_ranges + 0);
 		for (i = 0; i < 2; ++i)
 			print_fixed(0x80000 + i * 0x20000, 0x04000,
@@ -361,7 +362,7 @@ static void __init print_mtrr_state(void)
 		print_fixed_last();
 	}
 	pr_debug("MTRR variable ranges %sabled:\n",
-		 mtrr_state.enabled & 2 ? "en" : "dis");
+		 mtrr_state.enabled & MTRR_STATE_MTRR_ENABLED ? "en" : "dis");
 	high_width = (__ffs64(size_or_mask) - (32 - PAGE_SHIFT) + 3) / 4;
 
 	for (i = 0; i < num_var_ranges; ++i) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
