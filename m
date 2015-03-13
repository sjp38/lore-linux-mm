Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f177.google.com (mail-ob0-f177.google.com [209.85.214.177])
	by kanga.kvack.org (Postfix) with ESMTP id 6923B829D0
	for <linux-mm@kvack.org>; Fri, 13 Mar 2015 17:34:43 -0400 (EDT)
Received: by obcwp18 with SMTP id wp18so22503796obc.6
        for <linux-mm@kvack.org>; Fri, 13 Mar 2015 14:34:43 -0700 (PDT)
Received: from g9t5009.houston.hp.com (g9t5009.houston.hp.com. [15.240.92.67])
        by mx.google.com with ESMTPS id a133si1657221oif.58.2015.03.13.14.34.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Mar 2015 14:34:42 -0700 (PDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH v3 5/5] mtrr, mm, x86: Enhance MTRR checks for KVA huge page mapping
Date: Fri, 13 Mar 2015 15:33:41 -0600
Message-Id: <1426282421-25385-6-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1426282421-25385-1-git-send-email-toshi.kani@hp.com>
References: <1426282421-25385-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com
Cc: linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com, pebolle@tiscali.nl, Toshi Kani <toshi.kani@hp.com>

This patch adds an additional argument, 'uniform', to
mtrr_type_lookup(), which returns 1 when a given range is
covered uniformly by MTRRs, i.e. the range is fully covered
by a single MTRR entry or the default type.

pud_set_huge() and pmd_set_huge() are changed to check the
new 'uniform' flag to see if it is safe to create a huge page
mapping to the range.  This allows them to create a huge page
mapping to a range covered by a single MTRR entry of any
memory type.  It also detects a non-optimal request properly.
They continue to check with the WB type since the WB type has
no effect even if a request spans multiple MTRR entries.

pmd_set_huge() logs a warning message to a non-optimal request
so that driver writers will be aware of such a case.  Drivers
should make a mapping request aligned to a single MTRR entry
when the range is covered by MTRRs.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
---
 arch/x86/include/asm/mtrr.h        |    5 +++--
 arch/x86/kernel/cpu/mtrr/generic.c |   35 +++++++++++++++++++++++++++--------
 arch/x86/mm/pat.c                  |    4 ++--
 arch/x86/mm/pgtable.c              |   25 +++++++++++++++----------
 4 files changed, 47 insertions(+), 22 deletions(-)

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
index 271b19c..6d6a540 100644
--- a/arch/x86/kernel/cpu/mtrr/generic.c
+++ b/arch/x86/kernel/cpu/mtrr/generic.c
@@ -143,19 +143,22 @@ static u8 mtrr_type_lookup_fixed(u64 start, u64 end)
  * Return Value:
  * memory type - Matched memory type or the default memory type (unmatched)
  *
- * Output Argument:
+ * Output Arguments:
  * repeat - Set to 1 when [start:end] spanned across MTRR range and type
  *	    returned corresponds only to [start:*partial_end].  Caller has
  *	    to lookup again for [*partial_end:end].
+ * uniform - Set to 1 when MTRR covers the region uniformly, i.e. the region
+ *	     is fully covered by a single MTRR entry or the default type.
  */
 static u8 mtrr_type_lookup_variable(u64 start, u64 end, u64 *partial_end,
-				    int *repeat)
+				    int *repeat, u8 *uniform)
 {
 	int i;
 	u64 base, mask;
 	u8 prev_match, curr_match;
 
 	*repeat = 0;
+	*uniform = 1;
 
 	/* Make end inclusive end, instead of exclusive */
 	end--;
@@ -203,6 +206,7 @@ static u8 mtrr_type_lookup_variable(u64 start, u64 end, u64 *partial_end,
 
 			end = *partial_end - 1; /* end is inclusive */
 			*repeat = 1;
+			*uniform = 0;
 		}
 
 		if (!start_state)
@@ -214,6 +218,7 @@ static u8 mtrr_type_lookup_variable(u64 start, u64 end, u64 *partial_end,
 			continue;
 		}
 
+		*uniform = 0;
 		if (check_type_overlap(&prev_match, &curr_match))
 			return curr_match;
 	}
@@ -230,13 +235,19 @@ static u8 mtrr_type_lookup_variable(u64 start, u64 end, u64 *partial_end,
  * Return Values:
  * memory type - The effective MTRR type for the region
  * 0xFF - MTRR is disabled
+ *
+ * Output Argument:
+ * uniform - Set to 1 when MTRR covers the region uniformly, i.e. the region
+ *	     is fully covered by a single MTRR entry or the default type.
  */
-u8 mtrr_type_lookup(u64 start, u64 end)
+u8 mtrr_type_lookup(u64 start, u64 end, u8 *uniform)
 {
-	u8 type, prev_type;
+	u8 type, prev_type, is_uniform, dummy;
 	int repeat;
 	u64 partial_end;
 
+	*uniform = 1;
+
 	if (!mtrr_state_set)
 		return 0xFF;
 
@@ -248,14 +259,17 @@ u8 mtrr_type_lookup(u64 start, u64 end)
 	 * the variable ranges.
 	 */
 	type = mtrr_type_lookup_fixed(start, end);
-	if (type != 0xFF)
+	if (type != 0xFF) {
+		*uniform = 0;
 		return type;
+	}
 
 	/*
 	 * Look up the variable ranges.  Look of multiple ranges matching
 	 * this address and pick type as per MTRR precedence.
 	 */
-	type = mtrr_type_lookup_variable(start, end, &partial_end, &repeat);
+	type = mtrr_type_lookup_variable(start, end, &partial_end,
+					 &repeat, &is_uniform);
 
 	/*
 	 * Common path is with repeat = 0.
@@ -266,16 +280,21 @@ u8 mtrr_type_lookup(u64 start, u64 end)
 	while (repeat) {
 		prev_type = type;
 		start = partial_end;
+		is_uniform = 0;
+
 		type = mtrr_type_lookup_variable(start, end, &partial_end,
-						 &repeat);
+						 &repeat, &dummy);
 
-		if (check_type_overlap(&prev_type, &type))
+		if (check_type_overlap(&prev_type, &type)) {
+			*uniform = 0;
 			return type;
+		}
 	}
 
 	if (mtrr_tom2 && (start >= (1ULL<<32)) && (end < mtrr_tom2))
 		return MTRR_TYPE_WRBACK;
 
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
index 4891fa1..3d6edea 100644
--- a/arch/x86/mm/pgtable.c
+++ b/arch/x86/mm/pgtable.c
@@ -567,17 +567,18 @@ void native_set_fixmap(enum fixed_addresses idx, phys_addr_t phys,
  * pud_set_huge - setup kernel PUD mapping
  *
  * MTRR can override PAT memory types with 4KB granularity.  Therefore,
- * it does not set up a huge page when the range is covered by a non-WB
- * type of MTRR.  0xFF indicates that MTRR are disabled.
+ * it only sets up a huge page when the range is mapped uniformly by MTRR
+ * (i.e. the range is fully covered by a single MTRR entry or the default
+ * type) or the MTRR memory type is WB.
  *
  * Return 1 on success, and 0 when no PUD was set.
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
  * MTRR can override PAT memory types with 4KB granularity.  Therefore,
- * it does not set up a huge page when the range is covered by a non-WB
- * type of MTRR.  0xFF indicates that MTRR are disabled.
+ * it only sets up a huge page when the range is mapped uniformly by MTRR
+ * (i.e. the range is fully covered by a single MTRR entry or the default
+ * type) or the MTRR memory type is WB.
  *
  * Return 1 on success, and 0 when no PMD was set.
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
