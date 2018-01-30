Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8211D6B0005
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 17:51:41 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id a9so12276050pff.0
        for <linux-mm@kvack.org>; Tue, 30 Jan 2018 14:51:41 -0800 (PST)
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (mail-by2nam01on0076.outbound.protection.outlook.com. [104.47.34.76])
        by mx.google.com with ESMTPS id k9si2381575pgo.42.2018.01.30.14.51.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 30 Jan 2018 14:51:40 -0800 (PST)
Subject: Re: [PATCHv3 3/3] x86/mm/encrypt: Rewrite sme_pgtable_calc()
References: <20180124163623.61765-1-kirill.shutemov@linux.intel.com>
 <20180124163623.61765-4-kirill.shutemov@linux.intel.com>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <12ffff46-474b-5fb5-c143-e2db29b3f8a0@amd.com>
Date: Tue, 30 Jan 2018 16:51:34 -0600
MIME-Version: 1.0
In-Reply-To: <20180124163623.61765-4-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Borislav Petkov <bp@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 1/24/2018 10:36 AM, Kirill A. Shutemov wrote:
> sme_pgtable_calc() is unnecessary complex. It can be re-written in a
> more stream-lined way.
> 
> As a side effect, we would get the code ready to boot-time switching
> between paging modes.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Reviewed-by: Tom Lendacky <thomas.lendacky@amd.com>

> ---
>  arch/x86/mm/mem_encrypt_identity.c | 42 +++++++++++---------------------------
>  1 file changed, 12 insertions(+), 30 deletions(-)
> 
> diff --git a/arch/x86/mm/mem_encrypt_identity.c b/arch/x86/mm/mem_encrypt_identity.c
> index 69635a02ce9e..613686cc56ae 100644
> --- a/arch/x86/mm/mem_encrypt_identity.c
> +++ b/arch/x86/mm/mem_encrypt_identity.c
> @@ -230,8 +230,7 @@ static void __init sme_map_range_decrypted_wp(struct sme_populate_pgd_data *ppd)
>  
>  static unsigned long __init sme_pgtable_calc(unsigned long len)
>  {
> -	unsigned long p4d_size, pud_size, pmd_size, pte_size;
> -	unsigned long total;
> +	unsigned long entries = 0, tables = 0;
>  
>  	/*
>  	 * Perform a relatively simplistic calculation of the pagetable
> @@ -245,42 +244,25 @@ static unsigned long __init sme_pgtable_calc(unsigned long len)
>  	 * Incrementing the count for each covers the case where the addresses
>  	 * cross entries.
>  	 */
> -	if (IS_ENABLED(CONFIG_X86_5LEVEL)) {
> -		p4d_size = (ALIGN(len, PGDIR_SIZE) / PGDIR_SIZE) + 1;
> -		p4d_size *= sizeof(p4d_t) * PTRS_PER_P4D;
> -		pud_size = (ALIGN(len, P4D_SIZE) / P4D_SIZE) + 1;
> -		pud_size *= sizeof(pud_t) * PTRS_PER_PUD;
> -	} else {
> -		p4d_size = 0;
> -		pud_size = (ALIGN(len, PGDIR_SIZE) / PGDIR_SIZE) + 1;
> -		pud_size *= sizeof(pud_t) * PTRS_PER_PUD;
> -	}
> -	pmd_size = (ALIGN(len, PUD_SIZE) / PUD_SIZE) + 1;
> -	pmd_size *= sizeof(pmd_t) * PTRS_PER_PMD;
> -	pte_size = 2 * sizeof(pte_t) * PTRS_PER_PTE;
>  
> -	total = p4d_size + pud_size + pmd_size + pte_size;
> +	/* PGDIR_SIZE is equal to P4D_SIZE on 4-level machine. */
> +	if (PTRS_PER_P4D > 1)
> +		entries += (DIV_ROUND_UP(len, PGDIR_SIZE) + 1) * sizeof(p4d_t) * PTRS_PER_P4D;
> +	entries += (DIV_ROUND_UP(len, P4D_SIZE) + 1) * sizeof(pud_t) * PTRS_PER_PUD;
> +	entries += (DIV_ROUND_UP(len, PUD_SIZE) + 1) * sizeof(pmd_t) * PTRS_PER_PMD;
> +	entries += 2 * sizeof(pte_t) * PTRS_PER_PTE;
>  
>  	/*
>  	 * Now calculate the added pagetable structures needed to populate
>  	 * the new pagetables.
>  	 */
> -	if (IS_ENABLED(CONFIG_X86_5LEVEL)) {
> -		p4d_size = ALIGN(total, PGDIR_SIZE) / PGDIR_SIZE;
> -		p4d_size *= sizeof(p4d_t) * PTRS_PER_P4D;
> -		pud_size = ALIGN(total, P4D_SIZE) / P4D_SIZE;
> -		pud_size *= sizeof(pud_t) * PTRS_PER_PUD;
> -	} else {
> -		p4d_size = 0;
> -		pud_size = ALIGN(total, PGDIR_SIZE) / PGDIR_SIZE;
> -		pud_size *= sizeof(pud_t) * PTRS_PER_PUD;
> -	}
> -	pmd_size = ALIGN(total, PUD_SIZE) / PUD_SIZE;
> -	pmd_size *= sizeof(pmd_t) * PTRS_PER_PMD;
>  
> -	total += p4d_size + pud_size + pmd_size;
> +	if (PTRS_PER_P4D > 1)
> +		tables += DIV_ROUND_UP(entries, PGDIR_SIZE) * sizeof(p4d_t) * PTRS_PER_P4D;
> +	tables += DIV_ROUND_UP(entries, P4D_SIZE) * sizeof(pud_t) * PTRS_PER_PUD;
> +	tables += DIV_ROUND_UP(entries, PUD_SIZE) * sizeof(pmd_t) * PTRS_PER_PMD;
>  
> -	return total;
> +	return entries + tables;
>  }
>  
>  void __init __nostackprotector sme_encrypt_kernel(struct boot_params *bp)
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
