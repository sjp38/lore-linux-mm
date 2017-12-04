Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 345286B0033
	for <linux-mm@kvack.org>; Mon,  4 Dec 2017 09:19:27 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id z12so11595749pgv.6
        for <linux-mm@kvack.org>; Mon, 04 Dec 2017 06:19:27 -0800 (PST)
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-bn3nam01on0054.outbound.protection.outlook.com. [104.47.33.54])
        by mx.google.com with ESMTPS id j67si5906225pfj.127.2017.12.04.06.19.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 04 Dec 2017 06:19:25 -0800 (PST)
Subject: Re: [PATCH] x86/mm: Rewrite sme_populate_pgd() in a more sensible way
References: <20171204112323.47019-1-kirill.shutemov@linux.intel.com>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <d177df77-cdc7-1507-08f8-fcdb3b443709@amd.com>
Date: Mon, 4 Dec 2017 08:19:11 -0600
MIME-Version: 1.0
In-Reply-To: <20171204112323.47019-1-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, Borislav Petkov <bp@suse.de>, Brijesh Singh <brijesh.singh@amd.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 12/4/2017 5:23 AM, Kirill A. Shutemov wrote:
> sme_populate_pgd() open-codes a lot of things that are not needed to be
> open-coded.
> 
> Let's rewrite it in a more stream-lined way.
> 
> This would also buy us boot-time switching between support between
> paging modes, when rest of the pieces will be upstream.

Hi Kirill,

Unfortunately, some of these can't be changed.  The use of p4d_offset(),
pud_offset(), etc., use non-identity mapped virtual addresses which cause
failures at this point of the boot process. Also, calls such as __p4d(),
__pud(), etc., are part of the paravirt support and can't be used yet,
either.  I can take a closer look at some of the others (p*d_none() and
p*d_large()) which make use of the native_ macros, but my worry would be
that these get changed in the future to the non-native calls and then
boot failures occur.

Thanks,
Tom

> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
> 
> The patch is only build tested. I don't have hardware. Tom, could you give it a try?
> 
> ---
>   arch/x86/mm/mem_encrypt.c | 89 +++++++++++++++--------------------------------
>   1 file changed, 29 insertions(+), 60 deletions(-)
> 
> diff --git a/arch/x86/mm/mem_encrypt.c b/arch/x86/mm/mem_encrypt.c
> index d9a9e9fc75dd..16038f7472ca 100644
> --- a/arch/x86/mm/mem_encrypt.c
> +++ b/arch/x86/mm/mem_encrypt.c
> @@ -489,73 +489,42 @@ static void __init sme_clear_pgd(pgd_t *pgd_base, unsigned long start,
>   static void __init *sme_populate_pgd(pgd_t *pgd_base, void *pgtable_area,
>   				     unsigned long vaddr, pmdval_t pmd_val)
>   {
> -	pgd_t *pgd_p;
> -	p4d_t *p4d_p;
> -	pud_t *pud_p;
> -	pmd_t *pmd_p;
> -
> -	pgd_p = pgd_base + pgd_index(vaddr);
> -	if (native_pgd_val(*pgd_p)) {
> -		if (IS_ENABLED(CONFIG_X86_5LEVEL))
> -			p4d_p = (p4d_t *)(native_pgd_val(*pgd_p) & ~PTE_FLAGS_MASK);
> -		else
> -			pud_p = (pud_t *)(native_pgd_val(*pgd_p) & ~PTE_FLAGS_MASK);
> -	} else {
> -		pgd_t pgd;
> -
> -		if (IS_ENABLED(CONFIG_X86_5LEVEL)) {
> -			p4d_p = pgtable_area;
> -			memset(p4d_p, 0, sizeof(*p4d_p) * PTRS_PER_P4D);
> -			pgtable_area += sizeof(*p4d_p) * PTRS_PER_P4D;
> -
> -			pgd = native_make_pgd((pgdval_t)p4d_p + PGD_FLAGS);
> -		} else {
> -			pud_p = pgtable_area;
> -			memset(pud_p, 0, sizeof(*pud_p) * PTRS_PER_PUD);
> -			pgtable_area += sizeof(*pud_p) * PTRS_PER_PUD;
> -
> -			pgd = native_make_pgd((pgdval_t)pud_p + PGD_FLAGS);
> -		}
> -		native_set_pgd(pgd_p, pgd);
> +	pgd_t *pgd;
> +	p4d_t *p4d;
> +	pud_t *pud;
> +	pmd_t *pmd;
> +
> +	pgd = pgd_base + pgd_index(vaddr);
> +	if (pgd_none(*pgd)) {
> +		p4d = pgtable_area;
> +		memset(p4d, 0, sizeof(*p4d) * PTRS_PER_P4D);
> +		pgtable_area += sizeof(*p4d) * PTRS_PER_P4D;
> +		native_set_pgd(pgd, __pgd(PGD_FLAGS | __pa(p4d)));
>   	}
>   
> -	if (IS_ENABLED(CONFIG_X86_5LEVEL)) {
> -		p4d_p += p4d_index(vaddr);
> -		if (native_p4d_val(*p4d_p)) {
> -			pud_p = (pud_t *)(native_p4d_val(*p4d_p) & ~PTE_FLAGS_MASK);
> -		} else {
> -			p4d_t p4d;
> -
> -			pud_p = pgtable_area;
> -			memset(pud_p, 0, sizeof(*pud_p) * PTRS_PER_PUD);
> -			pgtable_area += sizeof(*pud_p) * PTRS_PER_PUD;
> -
> -			p4d = native_make_p4d((pudval_t)pud_p + P4D_FLAGS);
> -			native_set_p4d(p4d_p, p4d);
> -		}
> +	p4d = p4d_offset(pgd, vaddr);
> +	if (p4d_none(*p4d)) {
> +		pud = pgtable_area;
> +		memset(pud, 0, sizeof(*pud) * PTRS_PER_PUD);
> +		pgtable_area += sizeof(*pud) * PTRS_PER_PUD;
> +		native_set_p4d(p4d, __p4d(P4D_FLAGS | __pa(pud)));
>   	}
>   
> -	pud_p += pud_index(vaddr);
> -	if (native_pud_val(*pud_p)) {
> -		if (native_pud_val(*pud_p) & _PAGE_PSE)
> -			goto out;
> -
> -		pmd_p = (pmd_t *)(native_pud_val(*pud_p) & ~PTE_FLAGS_MASK);
> -	} else {
> -		pud_t pud;
> -
> -		pmd_p = pgtable_area;
> -		memset(pmd_p, 0, sizeof(*pmd_p) * PTRS_PER_PMD);
> -		pgtable_area += sizeof(*pmd_p) * PTRS_PER_PMD;
> -
> -		pud = native_make_pud((pmdval_t)pmd_p + PUD_FLAGS);
> -		native_set_pud(pud_p, pud);
> +	pud = pud_offset(p4d, vaddr);
> +	if (pud_none(*pud)) {
> +		pmd = pgtable_area;
> +		memset(pmd, 0, sizeof(*pmd) * PTRS_PER_PMD);
> +		pgtable_area += sizeof(*pmd) * PTRS_PER_PMD;
> +		native_set_pud(pud, __pud(PUD_FLAGS | __pa(pmd)));
>   	}
> +	if (pud_large(*pud))
> +		goto out;
>   
> -	pmd_p += pmd_index(vaddr);
> -	if (!native_pmd_val(*pmd_p) || !(native_pmd_val(*pmd_p) & _PAGE_PSE))
> -		native_set_pmd(pmd_p, native_make_pmd(pmd_val));
> +	pmd = pmd_offset(pud, vaddr);
> +	if (pmd_large(*pmd))
> +		goto out;
>   
> +	native_set_pmd(pmd, native_make_pmd(pmd_val));
>   out:
>   	return pgtable_area;
>   }
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
