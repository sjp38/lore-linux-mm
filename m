Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 52A2B6B026D
	for <linux-mm@kvack.org>; Wed, 13 Jun 2018 14:37:09 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id e1-v6so1175911pgp.20
        for <linux-mm@kvack.org>; Wed, 13 Jun 2018 11:37:09 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id z2-v6si2678354pgc.435.2018.06.13.11.37.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jun 2018 11:37:07 -0700 (PDT)
Subject: Re: [PATCHv3 14/17] x86/mm: Introduce direct_mapping_size
References: <20180612143915.68065-1-kirill.shutemov@linux.intel.com>
 <20180612143915.68065-15-kirill.shutemov@linux.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <4ece14a4-27bd-e10a-4c2c-822c3e629dcd@intel.com>
Date: Wed, 13 Jun 2018 11:37:07 -0700
MIME-Version: 1.0
In-Reply-To: <20180612143915.68065-15-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>
Cc: Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 06/12/2018 07:39 AM, Kirill A. Shutemov wrote:
> Kernel need to have a way to access encrypted memory. We are going to
"The kernel needs"...

> use per-KeyID direct mapping to facilitate the access with minimal
> overhead.

What are the security implications of this approach?

> Direct mapping for each KeyID will be put next to each other in the

That needs to be "a direct mapping" or "the direct mapping".  It's
missing an article to start the sentence.

> virtual address space. We need to have a way to find boundaries of
> direct mapping for particular KeyID.
> 
> The new variable direct_mapping_size specifies the size of direct
> mapping. With the value, it's trivial to find direct mapping for
> KeyID-N: PAGE_OFFSET + N * direct_mapping_size.

I think this deserves an update to Documentation/x86/x86_64/mm.txt, no?

> Size of direct mapping is calculated during KASLR setup. If KALSR is
> disable it happens during MKTME initialization.

"disabled"

> diff --git a/arch/x86/mm/kaslr.c b/arch/x86/mm/kaslr.c
> index 4408cd9a3bef..3d8ef8cb97e1 100644
> --- a/arch/x86/mm/kaslr.c
> +++ b/arch/x86/mm/kaslr.c
> @@ -69,6 +69,15 @@ static inline bool kaslr_memory_enabled(void)
>  	return kaslr_enabled() && !IS_ENABLED(CONFIG_KASAN);
>  }
>  
> +#ifndef CONFIG_X86_INTEL_MKTME
> +static void __init setup_direct_mapping_size(void)
> +{
> +	direct_mapping_size = max_pfn << PAGE_SHIFT;
> +	direct_mapping_size = round_up(direct_mapping_size, 1UL << TB_SHIFT);
> +	direct_mapping_size += (1UL << TB_SHIFT) * CONFIG_MEMORY_PHYSICAL_PADDING;
> +}
> +#endif

Comments, please.

>  /* Initialize base and padding for each memory region randomized with KASLR */
>  void __init kernel_randomize_memory(void)
>  {
> @@ -93,7 +102,11 @@ void __init kernel_randomize_memory(void)
>  	if (!kaslr_memory_enabled())
>  		return;
>  
> -	kaslr_regions[0].size_tb = 1 << (__PHYSICAL_MASK_SHIFT - TB_SHIFT);
> +	/*
> +	 * Upper limit for direct mapping size is 1/4 of whole virtual
> +	 * address space
> +	 */
> +	kaslr_regions[0].size_tb = 1 << (__VIRTUAL_MASK_SHIFT - 1 - TB_SHIFT);

Is this a cleanup that can be separate?

>  	kaslr_regions[1].size_tb = VMALLOC_SIZE_TB;
>  
>  	/*
> @@ -101,8 +114,10 @@ void __init kernel_randomize_memory(void)
>  	 * add padding if needed (especially for memory hotplug support).
>  	 */
>  	BUG_ON(kaslr_regions[0].base != &page_offset_base);
> -	memory_tb = DIV_ROUND_UP(max_pfn << PAGE_SHIFT, 1UL << TB_SHIFT) +
> -		CONFIG_MEMORY_PHYSICAL_PADDING;
> +
> +	setup_direct_mapping_size();
> +
> +	memory_tb = direct_mapping_size * mktme_nr_keyids + 1;

What's the +1 for?  Is "mktme_nr_keyids" 0 for "MKTME unsupported"?
That needs to be called out, I think.

>  	/* Adapt phyiscal memory region size based on available memory */
>  	if (memory_tb < kaslr_regions[0].size_tb)
> diff --git a/arch/x86/mm/mktme.c b/arch/x86/mm/mktme.c
> index 43a44f0f2a2d..3e5322bf035e 100644
> --- a/arch/x86/mm/mktme.c
> +++ b/arch/x86/mm/mktme.c
> @@ -89,3 +89,51 @@ static bool need_page_mktme(void)
>  struct page_ext_operations page_mktme_ops = {
>  	.need = need_page_mktme,
>  };
> +
> +void __init setup_direct_mapping_size(void)
> +{
> +	unsigned long available_va;
> +
> +	/* 1/4 of virtual address space is didicated for direct mapping */
> +	available_va = 1UL << (__VIRTUAL_MASK_SHIFT - 1);
> +
> +	/* How much memory the systrem has? */
> +	direct_mapping_size = max_pfn << PAGE_SHIFT;
> +	direct_mapping_size = round_up(direct_mapping_size, 1UL << 40);
> +
> +	if (mktme_status != MKTME_ENUMERATED)
> +		goto out;
> +
> +	/*
> +	 * Not enough virtual address space to address all physical memory with
> +	 * MKTME enabled. Even without padding.
> +	 *
> +	 * Disable MKTME instead.
> +	 */
> +	if (direct_mapping_size > available_va / mktme_nr_keyids + 1) {
> +		pr_err("x86/mktme: Disabled. Not enough virtual address space\n");
> +		pr_err("x86/mktme: Consider switching to 5-level paging\n");
> +		mktme_disable();
> +		goto out;
> +	}
> +
> +	/*
> +	 * Virtual address space is divided between per-KeyID direct mappings.
> +	 */
> +	available_va /= mktme_nr_keyids + 1;
> +out:
> +	/* Add padding, if there's enough virtual address space */
> +	direct_mapping_size += (1UL << 40) * CONFIG_MEMORY_PHYSICAL_PADDING;
> +	if (direct_mapping_size > available_va)
> +		direct_mapping_size = available_va;
> +}

Do you really need two copies of this function?  Shouldn't it see
mktme_status!=MKTME_ENUMERATED and just jump out?  How is the code
before that "goto out" different from the CONFIG_MKTME=n case?
