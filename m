Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f172.google.com (mail-ob0-f172.google.com [209.85.214.172])
	by kanga.kvack.org (Postfix) with ESMTP id B78A06B0071
	for <linux-mm@kvack.org>; Tue, 24 Mar 2015 18:27:54 -0400 (EDT)
Received: by obcjt1 with SMTP id jt1so5789155obc.2
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 15:27:54 -0700 (PDT)
Received: from g4t3427.houston.hp.com (g4t3427.houston.hp.com. [15.201.208.55])
        by mx.google.com with ESMTPS id j5si339480oev.82.2015.03.24.15.27.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Mar 2015 15:27:54 -0700 (PDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH v4 5/7] mtrr, x86: Define MTRR_TYPE_INVALID for mtrr_type_lookup()
Date: Tue, 24 Mar 2015 16:08:39 -0600
Message-Id: <1427234921-19737-6-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1427234921-19737-1-git-send-email-toshi.kani@hp.com>
References: <1427234921-19737-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com
Cc: linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com, pebolle@tiscali.nl, Toshi Kani <toshi.kani@hp.com>

mtrr_type_lookup() returns 0xFF when it cannot return a valid
MTRR memory type since MTRRs are disabled.  This patch defines
MTRR_TYPE_INVALID to clarify the meaning of this value, and
documents its usage.

There is no functional change in this patch.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
---
 arch/x86/include/asm/mtrr.h        |    2 +-
 arch/x86/include/uapi/asm/mtrr.h   |    8 +++++++-
 arch/x86/kernel/cpu/mtrr/generic.c |   14 +++++++-------
 arch/x86/mm/pgtable.c              |    8 ++++----
 4 files changed, 19 insertions(+), 13 deletions(-)

diff --git a/arch/x86/include/asm/mtrr.h b/arch/x86/include/asm/mtrr.h
index f768f62..a174af6 100644
--- a/arch/x86/include/asm/mtrr.h
+++ b/arch/x86/include/asm/mtrr.h
@@ -55,7 +55,7 @@ static inline u8 mtrr_type_lookup(u64 addr, u64 end)
 	/*
 	 * Return no-MTRRs:
 	 */
-	return 0xff;
+	return MTRR_TYPE_INVALID;
 }
 #define mtrr_save_fixed_ranges(arg) do {} while (0)
 #define mtrr_save_state() do {} while (0)
diff --git a/arch/x86/include/uapi/asm/mtrr.h b/arch/x86/include/uapi/asm/mtrr.h
index 66ba88d..0bc86c6 100644
--- a/arch/x86/include/uapi/asm/mtrr.h
+++ b/arch/x86/include/uapi/asm/mtrr.h
@@ -107,7 +107,7 @@ struct mtrr_state_type {
 #define MTRRIOC_GET_PAGE_ENTRY   _IOWR(MTRR_IOCTL_BASE, 8, struct mtrr_gentry)
 #define MTRRIOC_KILL_PAGE_ENTRY  _IOW(MTRR_IOCTL_BASE,  9, struct mtrr_sentry)
 
-/*  These are the region types  */
+/* MTRR memory types, which are defined in SDM */
 #define MTRR_TYPE_UNCACHABLE 0
 #define MTRR_TYPE_WRCOMB     1
 /*#define MTRR_TYPE_         2*/
@@ -117,5 +117,11 @@ struct mtrr_state_type {
 #define MTRR_TYPE_WRBACK     6
 #define MTRR_NUM_TYPES       7
 
+/*
+ * Invalid MTRR memory type.  mtrr_type_lookup() returns this value when
+ * MTRRs are disabled.  Note, this value is allocated from the reserved
+ * values (0x7-0xff) of the MTRR memory types.
+ */
+#define MTRR_TYPE_INVALID    0xff
 
 #endif /* _UAPI_ASM_X86_MTRR_H */
diff --git a/arch/x86/kernel/cpu/mtrr/generic.c b/arch/x86/kernel/cpu/mtrr/generic.c
index 4bff6db..8bd1298 100644
--- a/arch/x86/kernel/cpu/mtrr/generic.c
+++ b/arch/x86/kernel/cpu/mtrr/generic.c
@@ -104,7 +104,7 @@ static int check_type_overlap(u8 *prev, u8 *curr)
 
 /*
  * Error/Semi-error returns:
- * 0xFF - when MTRR is not enabled
+ * MTRR_TYPE_INVALID - when MTRR is not enabled
  * *repeat == 1 implies [start:end] spanned across MTRR range and type returned
  *		corresponds only to [start:*partial_end].
  *		Caller has to lookup again for [*partial_end:end].
@@ -117,10 +117,10 @@ static u8 __mtrr_type_lookup(u64 start, u64 end, u64 *partial_end, int *repeat)
 
 	*repeat = 0;
 	if (!mtrr_state_set)
-		return 0xFF;
+		return MTRR_TYPE_INVALID;
 
 	if (!(mtrr_state.enabled & MTRR_STATE_MTRR_ENABLED))
-		return 0xFF;
+		return MTRR_TYPE_INVALID;
 
 	/* Make end inclusive end, instead of exclusive */
 	end--;
@@ -151,7 +151,7 @@ static u8 __mtrr_type_lookup(u64 start, u64 end, u64 *partial_end, int *repeat)
 	 * Look of multiple ranges matching this address and pick type
 	 * as per MTRR precedence
 	 */
-	prev_match = 0xFF;
+	prev_match = MTRR_TYPE_INVALID;
 	for (i = 0; i < num_var_ranges; ++i) {
 		unsigned short start_state, end_state, inclusive;
 
@@ -199,7 +199,7 @@ static u8 __mtrr_type_lookup(u64 start, u64 end, u64 *partial_end, int *repeat)
 			continue;
 
 		curr_match = mtrr_state.var_ranges[i].base_lo & 0xff;
-		if (prev_match == 0xFF) {
+		if (prev_match == MTRR_TYPE_INVALID) {
 			prev_match = curr_match;
 			continue;
 		}
@@ -213,7 +213,7 @@ static u8 __mtrr_type_lookup(u64 start, u64 end, u64 *partial_end, int *repeat)
 			return MTRR_TYPE_WRBACK;
 	}
 
-	if (prev_match != 0xFF)
+	if (prev_match != MTRR_TYPE_INVALID)
 		return prev_match;
 
 	return mtrr_state.def_type;
@@ -222,7 +222,7 @@ static u8 __mtrr_type_lookup(u64 start, u64 end, u64 *partial_end, int *repeat)
 /*
  * Returns the effective MTRR type for the region
  * Error return:
- * 0xFF - when MTRR is not enabled
+ * MTRR_TYPE_INVALID - when MTRR is not enabled
  */
 u8 mtrr_type_lookup(u64 start, u64 end)
 {
diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
index 4891fa1..cfca4cf 100644
--- a/arch/x86/mm/pgtable.c
+++ b/arch/x86/mm/pgtable.c
@@ -568,7 +568,7 @@ void native_set_fixmap(enum fixed_addresses idx, phys_addr_t phys,
  *
  * MTRR can override PAT memory types with 4KB granularity.  Therefore,
  * it does not set up a huge page when the range is covered by a non-WB
- * type of MTRR.  0xFF indicates that MTRR are disabled.
+ * type of MTRR.  MTRR_TYPE_INVALID indicates that MTRR are disabled.
  *
  * Return 1 on success, and 0 when no PUD was set.
  */
@@ -577,7 +577,7 @@ int pud_set_huge(pud_t *pud, phys_addr_t addr, pgprot_t prot)
 	u8 mtrr;
 
 	mtrr = mtrr_type_lookup(addr, addr + PUD_SIZE);
-	if ((mtrr != MTRR_TYPE_WRBACK) && (mtrr != 0xFF))
+	if ((mtrr != MTRR_TYPE_WRBACK) && (mtrr != MTRR_TYPE_INVALID))
 		return 0;
 
 	prot = pgprot_4k_2_large(prot);
@@ -594,7 +594,7 @@ int pud_set_huge(pud_t *pud, phys_addr_t addr, pgprot_t prot)
  *
  * MTRR can override PAT memory types with 4KB granularity.  Therefore,
  * it does not set up a huge page when the range is covered by a non-WB
- * type of MTRR.  0xFF indicates that MTRR are disabled.
+ * type of MTRR.  MTRR_TYPE_INVALID indicates that MTRR are disabled.
  *
  * Return 1 on success, and 0 when no PMD was set.
  */
@@ -603,7 +603,7 @@ int pmd_set_huge(pmd_t *pmd, phys_addr_t addr, pgprot_t prot)
 	u8 mtrr;
 
 	mtrr = mtrr_type_lookup(addr, addr + PMD_SIZE);
-	if ((mtrr != MTRR_TYPE_WRBACK) && (mtrr != 0xFF))
+	if ((mtrr != MTRR_TYPE_WRBACK) && (mtrr != MTRR_TYPE_INVALID))
 		return 0;
 
 	prot = pgprot_4k_2_large(prot);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
