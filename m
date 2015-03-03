Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 9F6236B0038
	for <linux-mm@kvack.org>; Tue,  3 Mar 2015 17:44:17 -0500 (EST)
Received: by pdev10 with SMTP id v10so5497118pde.0
        for <linux-mm@kvack.org>; Tue, 03 Mar 2015 14:44:17 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 3si2694177pdl.95.2015.03.03.14.44.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Mar 2015 14:44:16 -0800 (PST)
Date: Tue, 3 Mar 2015 14:44:14 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3 6/6] x86, mm: Support huge KVA mappings on x86
Message-Id: <20150303144414.9f97ef25ad8aed7d112896bf@linux-foundation.org>
In-Reply-To: <1425404664-19675-7-git-send-email-toshi.kani@hp.com>
References: <1425404664-19675-1-git-send-email-toshi.kani@hp.com>
	<1425404664-19675-7-git-send-email-toshi.kani@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, arnd@arndb.de, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com

On Tue,  3 Mar 2015 10:44:24 -0700 Toshi Kani <toshi.kani@hp.com> wrote:

> This patch implements huge KVA mapping interfaces on x86.
> 
> On x86, MTRRs can override PAT memory types with a 4KB granularity.
> When using a huge page, MTRRs can override the memory type of the
> huge page, which may lead a performance penalty.  The processor
> can also behave in an undefined manner if a huge page is mapped to
> a memory range that MTRRs have mapped with multiple different memory
> types.  Therefore, the mapping code falls back to use a smaller page
> size toward 4KB when a mapping range is covered by non-WB type of
> MTRRs.  The WB type of MTRRs has no affect on the PAT memory types.
> 
> pud_set_huge() and pmd_set_huge() call mtrr_type_lookup() to see
> if a given range is covered by MTRRs.  MTRR_TYPE_WRBACK indicates
> that the range is either covered by WB or not covered and the MTRR
> default value is set to WB.  0xFF indicates that MTRRs are disabled.
> 
> HAVE_ARCH_HUGE_VMAP is selected when X86_64 or X86_32 with X86_PAE
> is set.  X86_32 without X86_PAE is not supported since such config
> can unlikey be benefited from this feature, and there was an issue
> found in testing.
> 
> ...
>
> +
> +#ifdef CONFIG_HAVE_ARCH_HUGE_VMAP
> +int pud_set_huge(pud_t *pud, phys_addr_t addr, pgprot_t prot)
> +{
> +	u8 mtrr;
> +
> +	/*
> +	 * Do not use a huge page when the range is covered by non-WB type
> +	 * of MTRRs.
> +	 */
> +	mtrr = mtrr_type_lookup(addr, addr + PUD_SIZE);
> +	if ((mtrr != MTRR_TYPE_WRBACK) && (mtrr != 0xFF))
> +		return 0;

It would be good to notify the operator in some way when this happens. 
Otherwise the kernel will run more slowly and there's no way of knowing
why.  I guess slap a pr_info() in there.  Or maybe pr_warn()?

> +	prot = pgprot_4k_2_large(prot);
> +
> +	set_pte((pte_t *)pud, pfn_pte(
> +		(u64)addr >> PAGE_SHIFT,
> +		__pgprot(pgprot_val(prot) | _PAGE_PSE)));
> +
> +	return 1;
> +}
> +
> +int pmd_set_huge(pmd_t *pmd, phys_addr_t addr, pgprot_t prot)
> +{
> +	u8 mtrr;
> +
> +	/*
> +	 * Do not use a huge page when the range is covered by non-WB type
> +	 * of MTRRs.
> +	 */
> +	mtrr = mtrr_type_lookup(addr, addr + PMD_SIZE);
> +	if ((mtrr != MTRR_TYPE_WRBACK) && (mtrr != 0xFF))
> +		return 0;
> +
> +	prot = pgprot_4k_2_large(prot);
> +
> +	set_pte((pte_t *)pmd, pfn_pte(
> +		(u64)addr >> PAGE_SHIFT,
> +		__pgprot(pgprot_val(prot) | _PAGE_PSE)));
> +
> +	return 1;
> +}
>
> +int pud_clear_huge(pud_t *pud)
> +{
> +	if (pud_large(*pud)) {
> +		pud_clear(pud);
> +		return 1;
> +	}
> +
> +	return 0;
> +}
> +
> +int pmd_clear_huge(pmd_t *pmd)
> +{
> +	if (pmd_large(*pmd)) {
> +		pmd_clear(pmd);
> +		return 1;
> +	}
> +
> +	return 0;
> +}

I didn't see anywhere where the return values of these functions are
documented.  It's all fairly obvious, but we could help the rearers
a bit.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
