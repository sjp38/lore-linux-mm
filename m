Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f170.google.com (mail-ob0-f170.google.com [209.85.214.170])
	by kanga.kvack.org (Postfix) with ESMTP id D21BA6B0072
	for <linux-mm@kvack.org>; Fri, 15 May 2015 14:43:25 -0400 (EDT)
Received: by obbkp3 with SMTP id kp3so84321326obb.3
        for <linux-mm@kvack.org>; Fri, 15 May 2015 11:43:25 -0700 (PDT)
Received: from g1t5424.austin.hp.com (g1t5424.austin.hp.com. [15.216.225.54])
        by mx.google.com with ESMTPS id c10si1609598oia.129.2015.05.15.11.43.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 May 2015 11:43:25 -0700 (PDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH v5 3/6] mtrr, x86: Fix MTRR state checks in mtrr_type_lookup()
Date: Fri, 15 May 2015 12:23:54 -0600
Message-Id: <1431714237-880-4-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1431714237-880-1-git-send-email-toshi.kani@hp.com>
References: <1431714237-880-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: bp@alien8.de, akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com
Cc: linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com, pebolle@tiscali.nl, mcgrof@suse.com, Toshi Kani <toshi.kani@hp.com>

'mtrr_state.enabled' contains the FE (fixed MTRRs enabled)
and E (MTRRs enabled) flags in MSR_MTRRdefType.  Intel SDM,
section 11.11.2.1, defines these flags as follows:
 - All MTRRs are disabled when the E flag is clear.
   The FE flag has no affect when the E flag is clear.
 - The default type is enabled when the E flag is set.
 - MTRR variable ranges are enabled when the E flag is set.
 - MTRR fixed ranges are enabled when both E and FE flags
   are set.

MTRR state checks in __mtrr_type_lookup() do not match with
SDM.  Hence, this patch makes the following changes:
 - The current code detects MTRRs disabled when both E and
   FE flags are clear in mtrr_state.enabled.  Fix to detect
   MTRRs disabled when the E flag is clear.
 - The current code does not check if the FE bit is set in
   mtrr_state.enabled when looking into the fixed entries.
   Fix to check the FE flag.
 - The current code returns the default type when the E flag
   is clear in mtrr_state.enabled.  However, the default type
   is also disabled when the E flag is clear.  Fix to remove
   the code as this case is handled as MTRR disabled with
   the 1st change.

In addition, this patch defines the E and FE flags in
mtrr_state.enabled as follows.
 - FE flag: MTRR_STATE_MTRR_FIXED_ENABLED
 - E  flag: MTRR_STATE_MTRR_ENABLED

print_mtrr_state() and x86_get_mtrr_mem_range() are also updated
accordingly.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
---
 arch/x86/include/asm/mtrr.h        |    4 ++++
 arch/x86/kernel/cpu/mtrr/cleanup.c |    3 ++-
 arch/x86/kernel/cpu/mtrr/generic.c |   15 ++++++++-------
 3 files changed, 14 insertions(+), 8 deletions(-)

diff --git a/arch/x86/include/asm/mtrr.h b/arch/x86/include/asm/mtrr.h
index f768f62..ef92794 100644
--- a/arch/x86/include/asm/mtrr.h
+++ b/arch/x86/include/asm/mtrr.h
@@ -127,4 +127,8 @@ struct mtrr_gentry32 {
 				 _IOW(MTRR_IOCTL_BASE,  9, struct mtrr_sentry32)
 #endif /* CONFIG_COMPAT */
 
+/* Bit fields for enabled in struct mtrr_state_type */
+#define MTRR_STATE_MTRR_FIXED_ENABLED	0x01
+#define MTRR_STATE_MTRR_ENABLED		0x02
+
 #endif /* _ASM_X86_MTRR_H */
diff --git a/arch/x86/kernel/cpu/mtrr/cleanup.c b/arch/x86/kernel/cpu/mtrr/cleanup.c
index 5f90b85..70d7c93 100644
--- a/arch/x86/kernel/cpu/mtrr/cleanup.c
+++ b/arch/x86/kernel/cpu/mtrr/cleanup.c
@@ -98,7 +98,8 @@ x86_get_mtrr_mem_range(struct range *range, int nr_range,
 			continue;
 		base = range_state[i].base_pfn;
 		if (base < (1<<(20-PAGE_SHIFT)) && mtrr_state.have_fixed &&
-		    (mtrr_state.enabled & 1)) {
+		    (mtrr_state.enabled & MTRR_STATE_MTRR_ENABLED) &&
+		    (mtrr_state.enabled & MTRR_STATE_MTRR_FIXED_ENABLED)) {
 			/* Var MTRR contains UC entry below 1M? Skip it: */
 			printk(BIOS_BUG_MSG, i);
 			if (base + size <= (1<<(20-PAGE_SHIFT)))
diff --git a/arch/x86/kernel/cpu/mtrr/generic.c b/arch/x86/kernel/cpu/mtrr/generic.c
index e202d26..b0599db 100644
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
@@ -355,7 +354,9 @@ static void __init print_mtrr_state(void)
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
@@ -368,7 +369,7 @@ static void __init print_mtrr_state(void)
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
