Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f173.google.com (mail-ob0-f173.google.com [209.85.214.173])
	by kanga.kvack.org (Postfix) with ESMTP id 89D876B0073
	for <linux-mm@kvack.org>; Fri, 15 May 2015 14:43:30 -0400 (EDT)
Received: by obcus9 with SMTP id us9so84394755obc.2
        for <linux-mm@kvack.org>; Fri, 15 May 2015 11:43:30 -0700 (PDT)
Received: from g4t3425.houston.hp.com (g4t3425.houston.hp.com. [15.201.208.53])
        by mx.google.com with ESMTPS id q20si1627747oel.29.2015.05.15.11.43.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 May 2015 11:43:29 -0700 (PDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH v5 4/6] mtrr, x86: Define MTRR_TYPE_INVALID for mtrr_type_lookup()
Date: Fri, 15 May 2015 12:23:55 -0600
Message-Id: <1431714237-880-5-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1431714237-880-1-git-send-email-toshi.kani@hp.com>
References: <1431714237-880-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: bp@alien8.de, akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com
Cc: linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com, pebolle@tiscali.nl, mcgrof@suse.com, Toshi Kani <toshi.kani@hp.com>

mtrr_type_lookup() returns 0xFF when it cannot return a valid
MTRR memory type since MTRRs are disabled.  This patch defines
MTRR_TYPE_INVALID to clarify the meaning of this value, and
documents its usage.

Document the return values of Kernel Virtual Address mapping
functions, pud_set_huge(), pmd_set_huge, pud_clear_huge() and
pmd_clear_huge().

There is no functional change in this patch.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
---
 arch/x86/include/asm/mtrr.h        |    2 +-
 arch/x86/include/uapi/asm/mtrr.h   |    8 ++++++-
 arch/x86/kernel/cpu/mtrr/generic.c |   14 ++++++------
 arch/x86/mm/pgtable.c              |   42 +++++++++++++++++++++++++++---------
 4 files changed, 47 insertions(+), 19 deletions(-)

diff --git a/arch/x86/include/asm/mtrr.h b/arch/x86/include/asm/mtrr.h
index ef92794..bb03a54 100644
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
index d0acb65..7528dcf 100644
--- a/arch/x86/include/uapi/asm/mtrr.h
+++ b/arch/x86/include/uapi/asm/mtrr.h
@@ -103,7 +103,7 @@ struct mtrr_state_type {
 #define MTRRIOC_GET_PAGE_ENTRY   _IOWR(MTRR_IOCTL_BASE, 8, struct mtrr_gentry)
 #define MTRRIOC_KILL_PAGE_ENTRY  _IOW(MTRR_IOCTL_BASE,  9, struct mtrr_sentry)
 
-/*  These are the region types  */
+/* MTRR memory types, which are defined in SDM */
 #define MTRR_TYPE_UNCACHABLE 0
 #define MTRR_TYPE_WRCOMB     1
 /*#define MTRR_TYPE_         2*/
@@ -113,5 +113,11 @@ struct mtrr_state_type {
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
index b0599db..7b1491c 100644
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
 
@@ -206,7 +206,7 @@ static u8 __mtrr_type_lookup(u64 start, u64 end, u64 *partial_end, int *repeat)
 			continue;
 
 		curr_match = mtrr_state.var_ranges[i].base_lo & 0xff;
-		if (prev_match == 0xFF) {
+		if (prev_match == MTRR_TYPE_INVALID) {
 			prev_match = curr_match;
 			continue;
 		}
@@ -220,7 +220,7 @@ static u8 __mtrr_type_lookup(u64 start, u64 end, u64 *partial_end, int *repeat)
 			return MTRR_TYPE_WRBACK;
 	}
 
-	if (prev_match != 0xFF)
+	if (prev_match != MTRR_TYPE_INVALID)
 		return prev_match;
 
 	return mtrr_state.def_type;
@@ -229,7 +229,7 @@ static u8 __mtrr_type_lookup(u64 start, u64 end, u64 *partial_end, int *repeat)
 /*
  * Returns the effective MTRR type for the region
  * Error return:
- * 0xFF - when MTRR is not enabled
+ * MTRR_TYPE_INVALID - when MTRR is not enabled
  */
 u8 mtrr_type_lookup(u64 start, u64 end)
 {
diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
index 0b97d2c..c30f981 100644
--- a/arch/x86/mm/pgtable.c
+++ b/arch/x86/mm/pgtable.c
@@ -563,16 +563,22 @@ void native_set_fixmap(enum fixed_addresses idx, phys_addr_t phys,
 }
 
 #ifdef CONFIG_HAVE_ARCH_HUGE_VMAP
+/**
+ * pud_set_huge - setup kernel PUD mapping
+ *
+ * MTRR can override PAT memory types with 4KiB granularity.  Therefore,
+ * this function does not set up a huge page when the range is covered
+ * by a non-WB type of MTRR.  MTRR_TYPE_INVALID indicates that MTRR are
+ * disabled.
+ *
+ * Returns 1 on success and 0 on failure.
+ */
 int pud_set_huge(pud_t *pud, phys_addr_t addr, pgprot_t prot)
 {
 	u8 mtrr;
 
-	/*
-	 * Do not use a huge page when the range is covered by non-WB type
-	 * of MTRRs.
-	 */
 	mtrr = mtrr_type_lookup(addr, addr + PUD_SIZE);
-	if ((mtrr != MTRR_TYPE_WRBACK) && (mtrr != 0xFF))
+	if ((mtrr != MTRR_TYPE_WRBACK) && (mtrr != MTRR_TYPE_INVALID))
 		return 0;
 
 	prot = pgprot_4k_2_large(prot);
@@ -584,16 +590,22 @@ int pud_set_huge(pud_t *pud, phys_addr_t addr, pgprot_t prot)
 	return 1;
 }
 
+/**
+ * pmd_set_huge - setup kernel PMD mapping
+ *
+ * MTRR can override PAT memory types with 4KiB granularity.  Therefore,
+ * this function does not set up a huge page when the range is covered
+ * by a non-WB type of MTRR.  MTRR_TYPE_INVALID indicates that MTRR are
+ * disabled.
+ *
+ * Returns 1 on success and 0 on failure.
+ */
 int pmd_set_huge(pmd_t *pmd, phys_addr_t addr, pgprot_t prot)
 {
 	u8 mtrr;
 
-	/*
-	 * Do not use a huge page when the range is covered by non-WB type
-	 * of MTRRs.
-	 */
 	mtrr = mtrr_type_lookup(addr, addr + PMD_SIZE);
-	if ((mtrr != MTRR_TYPE_WRBACK) && (mtrr != 0xFF))
+	if ((mtrr != MTRR_TYPE_WRBACK) && (mtrr != MTRR_TYPE_INVALID))
 		return 0;
 
 	prot = pgprot_4k_2_large(prot);
@@ -605,6 +617,11 @@ int pmd_set_huge(pmd_t *pmd, phys_addr_t addr, pgprot_t prot)
 	return 1;
 }
 
+/**
+ * pud_clear_huge - clear kernel PUD mapping when it is set
+ *
+ * Returns 1 on success and 0 on failure (no PUD map is found).
+ */
 int pud_clear_huge(pud_t *pud)
 {
 	if (pud_large(*pud)) {
@@ -615,6 +632,11 @@ int pud_clear_huge(pud_t *pud)
 	return 0;
 }
 
+/**
+ * pmd_clear_huge - clear kernel PMD mapping when it is set
+ *
+ * Returns 1 on success and 0 on failure (no PMD map is found).
+ */
 int pmd_clear_huge(pmd_t *pmd)
 {
 	if (pmd_large(*pmd)) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
