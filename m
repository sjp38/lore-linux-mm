Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	by kanga.kvack.org (Postfix) with ESMTP id 4A6B990002C
	for <linux-mm@kvack.org>; Tue, 10 Mar 2015 16:24:13 -0400 (EDT)
Received: by igal13 with SMTP id l13so32468805iga.1
        for <linux-mm@kvack.org>; Tue, 10 Mar 2015 13:24:13 -0700 (PDT)
Received: from g1t5424.austin.hp.com (g1t5424.austin.hp.com. [15.216.225.54])
        by mx.google.com with ESMTPS id sb9si3534737igb.33.2015.03.10.13.24.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Mar 2015 13:24:12 -0700 (PDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH 3/3] mtrr, mm, x86: Enhance MTRR checks for KVA huge page mapping
Date: Tue, 10 Mar 2015 14:23:17 -0600
Message-Id: <1426018997-12936-4-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1426018997-12936-1-git-send-email-toshi.kani@hp.com>
References: <1426018997-12936-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, arnd@arndb.de
Cc: linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com, pebolle@tiscali.nl, Toshi Kani <toshi.kani@hp.com>

This patch adds an additional argument, *uniform, to
mtrr_type_lookup(), which returns 1 when a given range is
either fully covered by a single MTRR entry or not covered
at all.

pud_set_huge() and pmd_set_huge() are changed to check the
new uniform flag to see if it is safe to create a huge page
mapping to the range.  This allows them to create a huge page
mapping to a range covered by a single MTRR entry of any
memory type.  It also detects an unoptimal request properly.
They continue to check with the WB type since the WB type has
no effect even if a request spans to multiple MTRR entries.

pmd_set_huge() logs a warning message to an unoptimal request
so that driver writers will be aware of such case.  Drivers
should make a mapping request aligned to a single MTRR entry
when the range is covered by MTRRs.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
---
 arch/x86/include/asm/mtrr.h        |    5 +++--
 arch/x86/kernel/cpu/mtrr/generic.c |   32 +++++++++++++++++++++++++-------
 arch/x86/mm/pat.c                  |    4 ++--
 arch/x86/mm/pgtable.c              |   25 +++++++++++++++----------
 4 files changed, 45 insertions(+), 21 deletions(-)

diff --git a/arch/x86/include/asm/mtrr.h b/arch/x86/include/asm/mtrr.h
index f768f62..5b4d467 100644
--- a/arch/x86/include/asm/mtrr.h
+++ b/arch/x86/include/asm/mtrr.h
@@ -31,7 +31,7 @@
  * arch_phys_wc_add and arch_phys_wc_del.
  */
 # ifdef CONFIG_MTRR
-extern u8 mtrr_type_lookup(u64 addr, u64 end);
+extern u8 mtrr_type_lookup(u64 addr, u64 end, u8 *uniform);
 extern void mtrr_save_fixed_ranges(void *);
 extern void mtrr_save_state(void);
 extern int mtrr_add(unsigned long base, unsigned long size,
@@ -50,11 +50,12 @@ extern int mtrr_trim_uncached_memory(unsigned long end_pfn);
 extern int amd_special_default_mtrr(void);
 extern int phys_wc_to_mtrr_index(int handle);
 #  else
-static inline u8 mtrr_type_lookup(u64 addr, u64 end)
+static inline u8 mtrr_type_lookup(u64 addr, u64 end, u8 *uniform)
 {
 	/*
 	 * Return no-MTRRs:
 	 */
+	*uniform = 1;
 	return 0xff;
 }
 #define mtrr_save_fixed_ranges(arg) do {} while (0)
diff --git a/arch/x86/kernel/cpu/mtrr/generic.c b/arch/x86/kernel/cpu/mtrr/generic.c
index cdb955f..aef238c 100644
--- a/arch/x86/kernel/cpu/mtrr/generic.c
+++ b/arch/x86/kernel/cpu/mtrr/generic.c
@@ -108,14 +108,19 @@ static int check_type_overlap(u8 *prev, u8 *curr)
  * *repeat == 1 implies [start:end] spanned across MTRR range and type returned
  *		corresponds only to [start:*partial_end].
  *		Caller has to lookup again for [*partial_end:end].
+ * *uniform == 1 The requested range is either fully covered by a single MTRR
+ *		 entry or not covered at all.
  */
-static u8 __mtrr_type_lookup(u64 start, u64 end, u64 *partial_end, int *repeat)
+static u8 __mtrr_type_lookup(u64 start, u64 end,
+			     u64 *partial_end, int *repeat, u8 *uniform)
 {
 	int i;
 	u64 base, mask;
 	u8 prev_match, curr_match;
 
 	*repeat = 0;
+	*uniform = 1;
+
 	if (!mtrr_state_set)
 		return 0xFF;
 
@@ -128,6 +133,7 @@ static u8 __mtrr_type_lookup(u64 start, u64 end, u64 *partial_end, int *repeat)
 	/* Look in fixed ranges. Just return the type as per start */
 	if (mtrr_state.have_fixed && (start < 0x100000)) {
 		int idx;
+		*uniform = 0;
 
 		if (start < 0x80000) {
 			idx = 0;
@@ -195,6 +201,7 @@ static u8 __mtrr_type_lookup(u64 start, u64 end, u64 *partial_end, int *repeat)
 
 			end = *partial_end - 1; /* end is inclusive */
 			*repeat = 1;
+			*uniform = 0;
 		}
 
 		if (!start_state)
@@ -206,6 +213,7 @@ static u8 __mtrr_type_lookup(u64 start, u64 end, u64 *partial_end, int *repeat)
 			continue;
 		}
 
+		*uniform = 0;
 		if (check_type_overlap(&prev_match, &curr_match))
 			return curr_match;
 	}
@@ -222,17 +230,21 @@ static u8 __mtrr_type_lookup(u64 start, u64 end, u64 *partial_end, int *repeat)
 }
 
 /*
- * Returns the effective MTRR type for the region
+ * Returns the effective MTRR type for the region.  *uniform is set to 1
+ * when a given range is either fully covered by a single MTRR entry or
+ * not covered at all.
+ *
  * Error return:
  * 0xFF - when MTRR is not enabled
  */
-u8 mtrr_type_lookup(u64 start, u64 end)
+u8 mtrr_type_lookup(u64 start, u64 end, u8 *uniform)
 {
-	u8 type, prev_type;
+	u8 type, prev_type, is_uniform, dummy;
 	int repeat;
 	u64 partial_end;
 
-	type = __mtrr_type_lookup(start, end, &partial_end, &repeat);
+	type = __mtrr_type_lookup(start, end,
+				  &partial_end, &repeat, &is_uniform);
 
 	/*
 	 * Common path is with repeat = 0.
@@ -242,12 +254,18 @@ u8 mtrr_type_lookup(u64 start, u64 end)
 	while (repeat) {
 		prev_type = type;
 		start = partial_end;
-		type = __mtrr_type_lookup(start, end, &partial_end, &repeat);
+		is_uniform = 0;
 
-		if (check_type_overlap(&prev_type, &type))
+		type = __mtrr_type_lookup(start, end,
+					  &partial_end, &repeat, &dummy);
+
+		if (check_type_overlap(&prev_type, &type)) {
+			*uniform = 0;
 			return type;
+		}
 	}
 
+	*uniform = is_uniform;
 	return type;
 }
 
diff --git a/arch/x86/mm/pat.c b/arch/x86/mm/pat.c
index 35af677..372ad42 100644
--- a/arch/x86/mm/pat.c
+++ b/arch/x86/mm/pat.c
@@ -267,9 +267,9 @@ static unsigned long pat_x_mtrr_type(u64 start, u64 end,
 	 * request is for WB.
 	 */
 	if (req_type == _PAGE_CACHE_MODE_WB) {
-		u8 mtrr_type;
+		u8 mtrr_type, uniform;
 
-		mtrr_type = mtrr_type_lookup(start, end);
+		mtrr_type = mtrr_type_lookup(start, end, &uniform);
 		if (mtrr_type != MTRR_TYPE_WRBACK)
 			return _PAGE_CACHE_MODE_UC_MINUS;
 
diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
index a0f7eeb..25843a9 100644
--- a/arch/x86/mm/pgtable.c
+++ b/arch/x86/mm/pgtable.c
@@ -567,17 +567,18 @@ void native_set_fixmap(enum fixed_addresses idx, phys_addr_t phys,
  * pud_set_huge - setup kernel PUD mapping
  *
  * MTRRs can override PAT memory types with a 4KB granularity.  Therefore,
- * it does not set up a huge page when the range is covered by non-WB type
- * of MTRRs.  0xFF indicates that MTRRs are disabled.
+ * it only sets up a huge page when the range is mapped uniformly (i.e.
+ * either fully covered by a single MTRR entry or not covered at all) or
+ * the MTRR type is WB.
  *
  * Return 1 on success, and 0 on no-operation.
  */
 int pud_set_huge(pud_t *pud, phys_addr_t addr, pgprot_t prot)
 {
-	u8 mtrr;
+	u8 mtrr, uniform;
 
-	mtrr = mtrr_type_lookup(addr, addr + PUD_SIZE);
-	if ((mtrr != MTRR_TYPE_WRBACK) && (mtrr != 0xFF))
+	mtrr = mtrr_type_lookup(addr, addr + PUD_SIZE, &uniform);
+	if ((!uniform) && (mtrr != MTRR_TYPE_WRBACK))
 		return 0;
 
 	prot = pgprot_4k_2_large(prot);
@@ -593,18 +594,22 @@ int pud_set_huge(pud_t *pud, phys_addr_t addr, pgprot_t prot)
  * pmd_set_huge - setup kernel PMD mapping
  *
  * MTRRs can override PAT memory types with a 4KB granularity.  Therefore,
- * it does not set up a huge page when the range is covered by non-WB type
- * of MTRRs.  0xFF indicates that MTRRs are disabled.
+ * it only sets up a huge page when the range is mapped uniformly (i.e.
+ * either fully covered by a single MTRR entry or not covered at all) or
+ * the MTRR type is WB.
  *
  * Return 1 on success, and 0 on no-operation.
  */
 int pmd_set_huge(pmd_t *pmd, phys_addr_t addr, pgprot_t prot)
 {
-	u8 mtrr;
+	u8 mtrr, uniform;
 
-	mtrr = mtrr_type_lookup(addr, addr + PMD_SIZE);
-	if ((mtrr != MTRR_TYPE_WRBACK) && (mtrr != 0xFF))
+	mtrr = mtrr_type_lookup(addr, addr + PMD_SIZE, &uniform);
+	if ((!uniform) && (mtrr != MTRR_TYPE_WRBACK)) {
+		pr_warn("pmd_set_huge: requesting [mem %#010llx-%#010llx], which spans more than a single MTRR entry\n",
+				addr, addr + PMD_SIZE);
 		return 0;
+	}
 
 	prot = pgprot_4k_2_large(prot);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
