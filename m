From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v5 6/6] mtrr, mm, x86: Enhance MTRR checks for KVA huge
 page mapping
Date: Mon, 18 May 2015 15:33:48 +0200
Message-ID: <20150518133348.GA23618@pd.tnic>
References: <1431714237-880-1-git-send-email-toshi.kani@hp.com>
 <1431714237-880-7-git-send-email-toshi.kani@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1431714237-880-7-git-send-email-toshi.kani@hp.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Toshi Kani <toshi.kani@hp.com>
Cc: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com, pebolle@tiscali.nl, mcgrof@suse.com
List-Id: linux-mm.kvack.org

On Fri, May 15, 2015 at 12:23:57PM -0600, Toshi Kani wrote:
> This patch adds an additional argument, 'uniform', to
> mtrr_type_lookup(), which returns 1 when a given range is
> covered uniformly by MTRRs, i.e. the range is fully covered
> by a single MTRR entry or the default type.
> 
> pud_set_huge() and pmd_set_huge() are changed to check the
> new 'uniform' flag to see if it is safe to create a huge page
> mapping to the range.  This allows them to create a huge page
> mapping to a range covered by a single MTRR entry of any
> memory type.  It also detects a non-optimal request properly.
> They continue to check with the WB type since the WB type has
> no effect even if a request spans multiple MTRR entries.
> 
> pmd_set_huge() logs a warning message to a non-optimal request
> so that driver writers will be aware of such a case.  Drivers
> should make a mapping request aligned to a single MTRR entry
> when the range is covered by MTRRs.
> 
> Signed-off-by: Toshi Kani <toshi.kani@hp.com>
> ---
>  arch/x86/include/asm/mtrr.h        |    4 ++--
>  arch/x86/kernel/cpu/mtrr/generic.c |   37 ++++++++++++++++++++++++++----------
>  arch/x86/mm/pat.c                  |    4 ++--
>  arch/x86/mm/pgtable.c              |   33 ++++++++++++++++++++------------
>  4 files changed, 52 insertions(+), 26 deletions(-)

...

>  int pmd_set_huge(pmd_t *pmd, phys_addr_t addr, pgprot_t prot)
>  {
> -	u8 mtrr;
> +	u8 mtrr, uniform;
>  
> -	mtrr = mtrr_type_lookup(addr, addr + PMD_SIZE);
> -	if ((mtrr != MTRR_TYPE_WRBACK) && (mtrr != MTRR_TYPE_INVALID))
> +	mtrr = mtrr_type_lookup(addr, addr + PMD_SIZE, &uniform);
> +	if ((mtrr != MTRR_TYPE_INVALID) && (!uniform) &&
> +	    (mtrr != MTRR_TYPE_WRBACK)) {
> +		pr_warn_once("pmd_set_huge: requesting [mem %#010llx-%#010llx], which spans more than a single MTRR entry\n",
> +				addr, addr + PMD_SIZE);
>  		return 0;
> +	}

All applied, I reformatted the comments in this last one a bit and made
the warning message hopefully a bit more descriptive:

---
From: Toshi Kani <toshi.kani@hp.com>
Date: Fri, 15 May 2015 12:23:57 -0600
Subject: [PATCH] x86/mm: Enhance MTRR checks in kernel mapping helpers

This patch adds the argument 'uniform' to mtrr_type_lookup(), which gets
set to 1 when a given range is covered uniformly by MTRRs, i.e. the
range is fully covered by a single MTRR entry or the default type.

Change pud_set_huge() and pmd_set_huge() to honor the 'uniform' flag to
see if it is safe to create a huge page mapping in the range.

This allows them to create a huge page mapping in a range covered by
a single MTRR entry of any memory type. It also detects a non-optimal
request properly. They continue to check with the WB type since it does
not effectively change the uniform mapping even if a request spans
multiple MTRR entries.

pmd_set_huge() logs a warning message to a non-optimal request so that
driver writers will be aware of such a case. Drivers should make a
mapping request aligned to a single MTRR entry when the range is covered
by MTRRs.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
Cc: dave.hansen@intel.com
Cc: Elliott@hp.com
Cc: pebolle@tiscali.nl
Cc: Luis R. Rodriguez <mcgrof@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: linux-mm <linux-mm@kvack.org>
Cc: x86-ml <x86@kernel.org>
Cc: lkml <linux-kernel@vger.kernel.org>
Link: http://lkml.kernel.org/r/1431714237-880-7-git-send-email-toshi.kani@hp.com
[ Realign comments, improve warning message. ]
Signed-off-by: Borislav Petkov <bp@suse.de>
---
 arch/x86/include/asm/mtrr.h        |  4 ++--
 arch/x86/kernel/cpu/mtrr/generic.c | 40 +++++++++++++++++++++++++++----------
 arch/x86/mm/pat.c                  |  4 ++--
 arch/x86/mm/pgtable.c              | 41 +++++++++++++++++++++++++-------------
 4 files changed, 61 insertions(+), 28 deletions(-)

diff --git a/arch/x86/include/asm/mtrr.h b/arch/x86/include/asm/mtrr.h
index bb03a547c1ab..a31759e1edd9 100644
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
index e51100c49eea..f782d9b62cb3 100644
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
index 35af6771a95a..372ad422c2c3 100644
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
index c30f9819786b..f1894daa79ee 100644
--- a/arch/x86/mm/pgtable.c
+++ b/arch/x86/mm/pgtable.c
@@ -566,19 +566,24 @@ void native_set_fixmap(enum fixed_addresses idx, phys_addr_t phys,
 /**
  * pud_set_huge - setup kernel PUD mapping
  *
- * MTRR can override PAT memory types with 4KiB granularity.  Therefore,
- * this function does not set up a huge page when the range is covered
- * by a non-WB type of MTRR.  MTRR_TYPE_INVALID indicates that MTRR are
- * disabled.
+ * MTRRs can override PAT memory types with 4KiB granularity. Therefore,
+ * this function sets up a huge page only if all of the following
+ * conditions are met:
+ *
+ *  - MTRRs are disabled.
+ *  - The range is mapped uniformly by an MTRR, i.e. the range is
+ *    fully covered by a single MTRR entry or the default type.
+ *  - The MTRR memory type is WB.
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
@@ -593,20 +598,28 @@ int pud_set_huge(pud_t *pud, phys_addr_t addr, pgprot_t prot)
 /**
  * pmd_set_huge - setup kernel PMD mapping
  *
- * MTRR can override PAT memory types with 4KiB granularity.  Therefore,
- * this function does not set up a huge page when the range is covered
- * by a non-WB type of MTRR.  MTRR_TYPE_INVALID indicates that MTRR are
- * disabled.
+ * MTRRs can override PAT memory types with 4KiB granularity. Therefore,
+ * this function sets up a huge page only if all of the following
+ * conditions are met:
+ *
+ *  - MTRR is disabled.
+ *  - The range is mapped uniformly by an MTRR, i.e. the range is
+ *    fully covered by a single MTRR entry or the default type.
+ *  - The MTRR memory type is WB.
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
2.3.5

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.
--
