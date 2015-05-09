Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 941E26B007B
	for <linux-mm@kvack.org>; Sat,  9 May 2015 05:08:17 -0400 (EDT)
Received: by wizk4 with SMTP id k4so54363007wiz.1
        for <linux-mm@kvack.org>; Sat, 09 May 2015 02:08:17 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id kw8si2364904wjb.70.2015.05.09.02.08.15
        for <linux-mm@kvack.org>;
        Sat, 09 May 2015 02:08:15 -0700 (PDT)
Date: Sat, 9 May 2015 11:08:10 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v4 7/7] mtrr, mm, x86: Enhance MTRR checks for KVA huge
 page mapping
Message-ID: <20150509090810.GB4452@pd.tnic>
References: <1427234921-19737-1-git-send-email-toshi.kani@hp.com>
 <1427234921-19737-8-git-send-email-toshi.kani@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <1427234921-19737-8-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com, pebolle@tiscali.nl

On Tue, Mar 24, 2015 at 04:08:41PM -0600, Toshi Kani wrote:
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
>  arch/x86/include/asm/mtrr.h        |    5 +++--
>  arch/x86/kernel/cpu/mtrr/generic.c |   35 +++++++++++++++++++++++++++--------
>  arch/x86/mm/pat.c                  |    4 ++--
>  arch/x86/mm/pgtable.c              |   25 +++++++++++++++----------
>  4 files changed, 47 insertions(+), 22 deletions(-)

...

> @@ -235,13 +240,19 @@ static u8 mtrr_type_lookup_variable(u64 start, u64 end, u64 *partial_end,
>   * Return Values:
>   * MTRR_TYPE_(type)  - The effective MTRR type for the region
>   * MTRR_TYPE_INVALID - MTRR is disabled
> + *
> + * Output Argument:
> + * uniform - Set to 1 when MTRR covers the region uniformly, i.e. the region
> + *	     is fully covered by a single MTRR entry or the default type.

I'd call this "single_mtrr". "uniform" could also mean that the resulting
type is uniform, i.e. of the same type but spanning multiple MTRRs.

>   */
> -u8 mtrr_type_lookup(u64 start, u64 end)
> +u8 mtrr_type_lookup(u64 start, u64 end, u8 *uniform)
>  {
> -	u8 type, prev_type;
> +	u8 type, prev_type, is_uniform, dummy;
>  	int repeat;
>  	u64 partial_end;
>  
> +	*uniform = 1;
> +

You're setting it here...

>  	if (!mtrr_state_set)
>  		return MTRR_TYPE_INVALID;

... but if you return here, you would've changed the thing uniform
points to needlessly as you're returning an error.

> @@ -253,14 +264,17 @@ u8 mtrr_type_lookup(u64 start, u64 end)
>  	 * the variable ranges.
>  	 */
>  	type = mtrr_type_lookup_fixed(start, end);
> -	if (type != MTRR_TYPE_INVALID)
> +	if (type != MTRR_TYPE_INVALID) {
> +		*uniform = 0;
>  		return type;
> +	}
>  
>  	/*
>  	 * Look up the variable ranges.  Look of multiple ranges matching
>  	 * this address and pick type as per MTRR precedence.
>  	 */
> -	type = mtrr_type_lookup_variable(start, end, &partial_end, &repeat);
> +	type = mtrr_type_lookup_variable(start, end, &partial_end,
> +					 &repeat, &is_uniform);
>  
>  	/*
>  	 * Common path is with repeat = 0.
> @@ -271,16 +285,21 @@ u8 mtrr_type_lookup(u64 start, u64 end)
>  	while (repeat) {
>  		prev_type = type;
>  		start = partial_end;
> +		is_uniform = 0;

So I think it would be better if you added an out: label where you do
exit from the function and set return values there.

So something like that, I'm pasting the whole function here so that you
can follow better:

u8 mtrr_type_lookup(u64 start, u64 end, u8 *uniform)
{
        u8 type, prev_type, is_uniform = 1, dummy;
        int repeat;
        u64 partial_end;

        if (!mtrr_state_set)
                return MTRR_TYPE_INVALID;

        if (!(mtrr_state.enabled & MTRR_STATE_MTRR_ENABLED))
                return MTRR_TYPE_INVALID;

        /*
         * Look up the fixed ranges first, which take priority over
         * the variable ranges.
         */
        type = mtrr_type_lookup_fixed(start, end);
        if (type != MTRR_TYPE_INVALID) {
                is_uniform = 0;
                goto out;
        }

        /*
         * Look up the variable ranges.  Look of multiple ranges matching
         * this address and pick type as per MTRR precedence.
         */
        type = mtrr_type_lookup_variable(start, end, &partial_end,
                                         &repeat, &is_uniform);

        /*
         * Common path is with repeat = 0.
         * However, we can have cases where [start:end] spans across some
         * MTRR ranges and/or the default type.  Do repeated lookups for
         * that case here.
         */
        while (repeat) {
                prev_type = type;
                start = partial_end;
                is_uniform = 0;

                type = mtrr_type_lookup_variable(start, end, &partial_end,
                                                 &repeat, &dummy);

                if (check_type_overlap(&prev_type, &type))
                        goto out;

        }

        if (mtrr_tom2 && (start >= (1ULL<<32)) && (end < mtrr_tom2))
                type = MTRR_TYPE_WRBACK;

out:
        *uniform = is_uniform;
        return type;
}
---

This way you're setting the uniform pointer in a single location and you're
working with the local variable inside the function.

Much easier to follow.

> +
>  		type = mtrr_type_lookup_variable(start, end, &partial_end,
> -						 &repeat);
> +						 &repeat, &dummy);
>  
> -		if (check_type_overlap(&prev_type, &type))
> +		if (check_type_overlap(&prev_type, &type)) {
> +			*uniform = 0;
>  			return type;
> +		}
>  	}
>  
>  	if (mtrr_tom2 && (start >= (1ULL<<32)) && (end < mtrr_tom2))
>  		return MTRR_TYPE_WRBACK;
>  
> +	*uniform = is_uniform;
>  	return type;
>  }
>  
> diff --git a/arch/x86/mm/pat.c b/arch/x86/mm/pat.c
> index 35af677..372ad42 100644
> --- a/arch/x86/mm/pat.c
> +++ b/arch/x86/mm/pat.c
> @@ -267,9 +267,9 @@ static unsigned long pat_x_mtrr_type(u64 start, u64 end,
>  	 * request is for WB.
>  	 */
>  	if (req_type == _PAGE_CACHE_MODE_WB) {
> -		u8 mtrr_type;
> +		u8 mtrr_type, uniform;
>  
> -		mtrr_type = mtrr_type_lookup(start, end);
> +		mtrr_type = mtrr_type_lookup(start, end, &uniform);
>  		if (mtrr_type != MTRR_TYPE_WRBACK)
>  			return _PAGE_CACHE_MODE_UC_MINUS;
>  
> diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
> index cfca4cf..3d6edea 100644
> --- a/arch/x86/mm/pgtable.c
> +++ b/arch/x86/mm/pgtable.c
> @@ -567,17 +567,18 @@ void native_set_fixmap(enum fixed_addresses idx, phys_addr_t phys,
>   * pud_set_huge - setup kernel PUD mapping
>   *
>   * MTRR can override PAT memory types with 4KB granularity.  Therefore,
> - * it does not set up a huge page when the range is covered by a non-WB
> - * type of MTRR.  MTRR_TYPE_INVALID indicates that MTRR are disabled.
> + * it only sets up a huge page when the range is mapped uniformly by MTRR
> + * (i.e. the range is fully covered by a single MTRR entry or the default
> + * type) or the MTRR memory type is WB.
>   *
>   * Return 1 on success, and 0 when no PUD was set.
>   */
>  int pud_set_huge(pud_t *pud, phys_addr_t addr, pgprot_t prot)
>  {
> -	u8 mtrr;
> +	u8 mtrr, uniform;
>  
> -	mtrr = mtrr_type_lookup(addr, addr + PUD_SIZE);
> -	if ((mtrr != MTRR_TYPE_WRBACK) && (mtrr != MTRR_TYPE_INVALID))
> +	mtrr = mtrr_type_lookup(addr, addr + PUD_SIZE, &uniform);
> +	if ((!uniform) && (mtrr != MTRR_TYPE_WRBACK))
>  		return 0;
>  
>  	prot = pgprot_4k_2_large(prot);
> @@ -593,18 +594,22 @@ int pud_set_huge(pud_t *pud, phys_addr_t addr, pgprot_t prot)
>   * pmd_set_huge - setup kernel PMD mapping
>   *
>   * MTRR can override PAT memory types with 4KB granularity.  Therefore,
> - * it does not set up a huge page when the range is covered by a non-WB
> - * type of MTRR.  MTRR_TYPE_INVALID indicates that MTRR are disabled.
> + * it only sets up a huge page when the range is mapped uniformly by MTRR
> + * (i.e. the range is fully covered by a single MTRR entry or the default
> + * type) or the MTRR memory type is WB.
>   *
>   * Return 1 on success, and 0 when no PMD was set.
>   */
>  int pmd_set_huge(pmd_t *pmd, phys_addr_t addr, pgprot_t prot)
>  {
> -	u8 mtrr;
> +	u8 mtrr, uniform;
>  
> -	mtrr = mtrr_type_lookup(addr, addr + PMD_SIZE);
> -	if ((mtrr != MTRR_TYPE_WRBACK) && (mtrr != MTRR_TYPE_INVALID))
> +	mtrr = mtrr_type_lookup(addr, addr + PMD_SIZE, &uniform);
> +	if ((!uniform) && (mtrr != MTRR_TYPE_WRBACK)) {
> +		pr_warn("pmd_set_huge: requesting [mem %#010llx-%#010llx], which spans more than a single MTRR entry\n",
> +				addr, addr + PMD_SIZE);
>  		return 0;

So this returns 0, i.e. failure already. Why do we even have to warn?
Caller already knows it failed.

And this warning would flood dmesg needlessly.

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.
--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
