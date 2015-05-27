Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id A29476B0107
	for <linux-mm@kvack.org>; Wed, 27 May 2015 10:20:11 -0400 (EDT)
Received: by pdbqa5 with SMTP id qa5so17280171pdb.0
        for <linux-mm@kvack.org>; Wed, 27 May 2015 07:20:11 -0700 (PDT)
Received: from terminus.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id r2si9311056pdi.3.2015.05.27.07.20.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 May 2015 07:20:10 -0700 (PDT)
Date: Wed, 27 May 2015 07:19:24 -0700
From: tip-bot for Toshi Kani <tipbot@zytor.com>
Message-ID: <tip-b73522e0c1be58d3c69b124985b8ccf94e3677f7@git.kernel.org>
Reply-To: bp@suse.de, mingo@kernel.org, hpa@zytor.com,
        linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
        mcgrof@suse.com, linux-mm@kvack.org, tglx@linutronix.de, bp@alien8.de,
        peterz@infradead.org, dvlasenk@redhat.com, brgerst@gmail.com,
        torvalds@linux-foundation.org, toshi.kani@hp.com, luto@amacapital.net
In-Reply-To: <1432628901-18044-8-git-send-email-bp@alien8.de>
References: <1431714237-880-7-git-send-email-toshi.kani@hp.com>
	<1432628901-18044-8-git-send-email-bp@alien8.de>
Subject: [tip:x86/mm] x86/mm/mtrr:
  Enhance MTRR checks in kernel mapping helpers
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-tip-commits@vger.kernel.org
Cc: luto@amacapital.net, toshi.kani@hp.com, torvalds@linux-foundation.org, dvlasenk@redhat.com, brgerst@gmail.com, peterz@infradead.org, bp@alien8.de, tglx@linutronix.de, linux-mm@kvack.org, mcgrof@suse.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, hpa@zytor.com, bp@suse.de, mingo@kernel.org

Commit-ID:  b73522e0c1be58d3c69b124985b8ccf94e3677f7
Gitweb:     http://git.kernel.org/tip/b73522e0c1be58d3c69b124985b8ccf94e3677f7
Author:     Toshi Kani <toshi.kani@hp.com>
AuthorDate: Tue, 26 May 2015 10:28:10 +0200
Committer:  Ingo Molnar <mingo@kernel.org>
CommitDate: Wed, 27 May 2015 14:40:58 +0200

x86/mm/mtrr: Enhance MTRR checks in kernel mapping helpers

This patch adds the argument 'uniform' to mtrr_type_lookup(),
which gets set to 1 when a given range is covered uniformly by
MTRRs, i.e. the range is fully covered by a single MTRR entry or
the default type.

Change pud_set_huge() and pmd_set_huge() to honor the 'uniform'
flag to see if it is safe to create a huge page mapping in the
range.

This allows them to create a huge page mapping in a range
covered by a single MTRR entry of any memory type. It also
detects a non-optimal request properly. They continue to check
with the WB type since it does not effectively change the
uniform mapping even if a request spans multiple MTRR entries.

pmd_set_huge() logs a warning message to a non-optimal request
so that driver writers will be aware of such a case. Drivers
should make a mapping request aligned to a single MTRR entry
when the range is covered by MTRRs.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
[ Realign, flesh out comments, improve warning message. ]
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
Link: http://lkml.kernel.org/r/1431714237-880-7-git-send-email-toshi.kani@hp.com
Link: http://lkml.kernel.org/r/1432628901-18044-8-git-send-email-bp@alien8.de
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 arch/x86/include/asm/mtrr.h        |  4 ++--
 arch/x86/kernel/cpu/mtrr/generic.c | 40 ++++++++++++++++++++++++++++----------
 arch/x86/mm/pat.c                  |  4 ++--
 arch/x86/mm/pgtable.c              | 38 +++++++++++++++++++++++-------------
 4 files changed, 58 insertions(+), 28 deletions(-)

diff --git a/arch/x86/include/asm/mtrr.h b/arch/x86/include/asm/mtrr.h
index bb03a54..a31759e 100644
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
@@ -50,7 +50,7 @@ extern int mtrr_trim_uncached_memory(unsigned long end_pfn);
 extern int amd_special_default_mtrr(void);
 extern int phys_wc_to_mtrr_index(int handle);
 #  else
-static inline u8 mtrr_type_lookup(u64 addr, u64 end)
+static inline u8 mtrr_type_lookup(u64 addr, u64 end, u8 *uniform)
 {
 	/*
 	 * Return no-MTRRs:
diff --git a/arch/x86/kernel/cpu/mtrr/generic.c b/arch/x86/kernel/cpu/mtrr/generic.c
index e51100c..f782d9b 100644
--- a/arch/x86/kernel/cpu/mtrr/generic.c
+++ b/arch/x86/kernel/cpu/mtrr/generic.c
@@ -147,19 +147,24 @@ static u8 mtrr_type_lookup_fixed(u64 start, u64 end)
  * Return Value:
  * MTRR_TYPE_(type) - Matched memory type or default memory type (unmatched)
  *
- * Output Argument:
+ * Output Arguments:
  * repeat - Set to 1 when [start:end] spanned across MTRR range and type
  *	    returned corresponds only to [start:*partial_end].  Caller has
  *	    to lookup again for [*partial_end:end].
+ *
+ * uniform - Set to 1 when an MTRR covers the region uniformly, i.e. the
+ *	     region is fully covered by a single MTRR entry or the default
+ *	     type.
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
 
 	/* Make end inclusive instead of exclusive */
 	end--;
@@ -214,6 +219,7 @@ static u8 mtrr_type_lookup_variable(u64 start, u64 end, u64 *partial_end,
 
 			end = *partial_end - 1; /* end is inclusive */
 			*repeat = 1;
+			*uniform = 0;
 		}
 
 		if ((start & mask) != (base & mask))
@@ -225,6 +231,7 @@ static u8 mtrr_type_lookup_variable(u64 start, u64 end, u64 *partial_end,
 			continue;
 		}
 
+		*uniform = 0;
 		if (check_type_overlap(&prev_match, &curr_match))
 			return curr_match;
 	}
@@ -241,10 +248,15 @@ static u8 mtrr_type_lookup_variable(u64 start, u64 end, u64 *partial_end,
  * Return Values:
  * MTRR_TYPE_(type)  - The effective MTRR type for the region
  * MTRR_TYPE_INVALID - MTRR is disabled
+ *
+ * Output Argument:
+ * uniform - Set to 1 when an MTRR covers the region uniformly, i.e. the
+ *	     region is fully covered by a single MTRR entry or the default
+ *	     type.
  */
-u8 mtrr_type_lookup(u64 start, u64 end)
+u8 mtrr_type_lookup(u64 start, u64 end, u8 *uniform)
 {
-	u8 type, prev_type;
+	u8 type, prev_type, is_uniform = 1, dummy;
 	int repeat;
 	u64 partial_end;
 
@@ -260,14 +272,18 @@ u8 mtrr_type_lookup(u64 start, u64 end)
 	 */
 	if ((start < 0x100000) &&
 	    (mtrr_state.have_fixed) &&
-	    (mtrr_state.enabled & MTRR_STATE_MTRR_FIXED_ENABLED))
-		return mtrr_type_lookup_fixed(start, end);
+	    (mtrr_state.enabled & MTRR_STATE_MTRR_FIXED_ENABLED)) {
+		is_uniform = 0;
+		type = mtrr_type_lookup_fixed(start, end);
+		goto out;
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
@@ -278,15 +294,19 @@ u8 mtrr_type_lookup(u64 start, u64 end)
 	while (repeat) {
 		prev_type = type;
 		start = partial_end;
-		type = mtrr_type_lookup_variable(start, end, &partial_end, &repeat);
+		is_uniform = 0;
+		type = mtrr_type_lookup_variable(start, end, &partial_end,
+						 &repeat, &dummy);
 
 		if (check_type_overlap(&prev_type, &type))
-			return type;
+			goto out;
 	}
 
 	if (mtrr_tom2 && (start >= (1ULL<<32)) && (end < mtrr_tom2))
-		return MTRR_TYPE_WRBACK;
+		type = MTRR_TYPE_WRBACK;
 
+out:
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
index c30f981..fb0a9dd 100644
--- a/arch/x86/mm/pgtable.c
+++ b/arch/x86/mm/pgtable.c
@@ -566,19 +566,28 @@ void native_set_fixmap(enum fixed_addresses idx, phys_addr_t phys,
 /**
  * pud_set_huge - setup kernel PUD mapping
  *
- * MTRR can override PAT memory types with 4KiB granularity.  Therefore,
- * this function does not set up a huge page when the range is covered
- * by a non-WB type of MTRR.  MTRR_TYPE_INVALID indicates that MTRR are
- * disabled.
+ * MTRRs can override PAT memory types with 4KiB granularity. Therefore, this
+ * function sets up a huge page only if any of the following conditions are met:
+ *
+ * - MTRRs are disabled, or
+ *
+ * - MTRRs are enabled and the range is completely covered by a single MTRR, or
+ *
+ * - MTRRs are enabled and the corresponding MTRR memory type is WB, which
+ *   has no effect on the requested PAT memory type.
+ *
+ * Callers should try to decrease page size (1GB -> 2MB -> 4K) if the bigger
+ * page mapping attempt fails.
  *
  * Returns 1 on success and 0 on failure.
  */
 int pud_set_huge(pud_t *pud, phys_addr_t addr, pgprot_t prot)
 {
-	u8 mtrr;
+	u8 mtrr, uniform;
 
-	mtrr = mtrr_type_lookup(addr, addr + PUD_SIZE);
-	if ((mtrr != MTRR_TYPE_WRBACK) && (mtrr != MTRR_TYPE_INVALID))
+	mtrr = mtrr_type_lookup(addr, addr + PUD_SIZE, &uniform);
+	if ((mtrr != MTRR_TYPE_INVALID) && (!uniform) &&
+	    (mtrr != MTRR_TYPE_WRBACK))
 		return 0;
 
 	prot = pgprot_4k_2_large(prot);
@@ -593,20 +602,21 @@ int pud_set_huge(pud_t *pud, phys_addr_t addr, pgprot_t prot)
 /**
  * pmd_set_huge - setup kernel PMD mapping
  *
- * MTRR can override PAT memory types with 4KiB granularity.  Therefore,
- * this function does not set up a huge page when the range is covered
- * by a non-WB type of MTRR.  MTRR_TYPE_INVALID indicates that MTRR are
- * disabled.
+ * See text over pud_set_huge() above.
  *
  * Returns 1 on success and 0 on failure.
  */
 int pmd_set_huge(pmd_t *pmd, phys_addr_t addr, pgprot_t prot)
 {
-	u8 mtrr;
+	u8 mtrr, uniform;
 
-	mtrr = mtrr_type_lookup(addr, addr + PMD_SIZE);
-	if ((mtrr != MTRR_TYPE_WRBACK) && (mtrr != MTRR_TYPE_INVALID))
+	mtrr = mtrr_type_lookup(addr, addr + PMD_SIZE, &uniform);
+	if ((mtrr != MTRR_TYPE_INVALID) && (!uniform) &&
+	    (mtrr != MTRR_TYPE_WRBACK)) {
+		pr_warn_once("%s: Cannot satisfy [mem %#010llx-%#010llx] with a huge-page mapping due to MTRR override.\n",
+			     __func__, addr, addr + PMD_SIZE);
 		return 0;
+	}
 
 	prot = pgprot_4k_2_large(prot);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
