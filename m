Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id D0ACC6B002E
	for <linux-mm@kvack.org>; Thu, 22 Mar 2018 11:55:54 -0400 (EDT)
Received: by mail-ot0-f197.google.com with SMTP id q12-v6so3865254oth.6
        for <linux-mm@kvack.org>; Thu, 22 Mar 2018 08:55:54 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id a73si1858487oib.46.2018.03.22.08.55.53
        for <linux-mm@kvack.org>;
        Thu, 22 Mar 2018 08:55:53 -0700 (PDT)
From: Punit Agrawal <punit.agrawal@arm.com>
Subject: Re: [RFC, PATCH 07/22] x86/mm: Mask out KeyID bits from page table entry pfn
References: <20180305162610.37510-1-kirill.shutemov@linux.intel.com>
	<20180305162610.37510-8-kirill.shutemov@linux.intel.com>
Date: Thu, 22 Mar 2018 15:55:50 +0000
In-Reply-To: <20180305162610.37510-8-kirill.shutemov@linux.intel.com> (Kirill
	A. Shutemov's message of "Mon, 5 Mar 2018 19:25:55 +0300")
Message-ID: <87woy414vt.fsf@e105922-lin.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Dave Hansen <dave.hansen@intel.com>, Kai Huang <kai.huang@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Kirill,

A flyby comment below.

"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> writes:

> MKTME claims several upper bits of the physical address in a page table
> entry to encode KeyID. It effectively shrinks number of bits for
> physical address. We should exclude KeyID bits from physical addresses.
>
> For instance, if CPU enumerates 52 physical address bits and number of
> bits claimed for KeyID is 6, bits 51:46 must not be threated as part
> physical address.
>
> This patch adjusts __PHYSICAL_MASK during MKTME enumeration.
>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  arch/x86/kernel/cpu/intel.c | 24 ++++++++++++++++++++++++
>  1 file changed, 24 insertions(+)
>
> diff --git a/arch/x86/kernel/cpu/intel.c b/arch/x86/kernel/cpu/intel.c
> index c770689490b5..35436bbadd0b 100644
> --- a/arch/x86/kernel/cpu/intel.c
> +++ b/arch/x86/kernel/cpu/intel.c
> @@ -580,6 +580,30 @@ static void detect_tme(struct cpuinfo_x86 *c)
>  		mktme_status = MKTME_ENABLED;
>  	}
>  
> +#ifdef CONFIG_X86_INTEL_MKTME
> +	if (mktme_status == MKTME_ENABLED && nr_keyids) {
> +		/*
> +		 * Mask out bits claimed from KeyID from physical address mask.
> +		 *
> +		 * For instance, if a CPU enumerates 52 physical address bits
> +		 * and number of bits claimed for KeyID is 6, bits 51:46 of
> +		 * physical address is unusable.
> +		 */
> +		phys_addr_t keyid_mask;
> +
> +		keyid_mask = 1ULL << c->x86_phys_bits;
> +		keyid_mask -= 1ULL << (c->x86_phys_bits - keyid_bits);
> +		physical_mask &= ~keyid_mask;

You could use GENMASK_ULL() to construct the keyid_mask instead of
rolling your own here.

Thanks,
Punit


> +	} else {
> +		/*
> +		 * Reset __PHYSICAL_MASK.
> +		 * Maybe needed if there's inconsistent configuation
> +		 * between CPUs.
> +		 */
> +		physical_mask = (1ULL << __PHYSICAL_MASK_SHIFT) - 1;
> +	}
> +#endif
> +
>  	/*
>  	 * Exclude KeyID bits from physical address bits.
>  	 *
