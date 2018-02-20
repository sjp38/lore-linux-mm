Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id BF8776B000C
	for <linux-mm@kvack.org>; Tue, 20 Feb 2018 12:45:19 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id v16so8641739wrv.14
        for <linux-mm@kvack.org>; Tue, 20 Feb 2018 09:45:19 -0800 (PST)
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id 3si9994165wmd.3.2018.02.20.09.45.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Feb 2018 09:45:18 -0800 (PST)
Subject: Re: [PATCH 1/6] powerpc/mm/32: Use pfn_valid to check if pointer is
 in RAM
References: <20180220161424.5421-1-j.neuschaefer@gmx.net>
 <20180220161424.5421-2-j.neuschaefer@gmx.net>
From: christophe leroy <christophe.leroy@c-s.fr>
Message-ID: <0d14cb2c-dd00-d258-cb15-302b2a9d684f@c-s.fr>
Date: Tue, 20 Feb 2018 18:45:09 +0100
MIME-Version: 1.0
In-Reply-To: <20180220161424.5421-2-j.neuschaefer@gmx.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: fr
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?Q?Jonathan_Neusch=c3=a4fer?= <j.neuschaefer@gmx.net>, linuxppc-dev@lists.ozlabs.org
Cc: linux-kernel@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, linux-mm@kvack.org, Joel Stanley <joel@jms.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Balbir Singh <bsingharora@gmail.com>, Guenter Roeck <linux@roeck-us.net>



Le 20/02/2018 A  17:14, Jonathan NeuschA?fer a A(C)critA :
> The Nintendo Wii has a memory layout that places two chunks of RAM at
> non-adjacent addresses, and MMIO between them. Currently, the allocation
> of these MMIO areas is made possible by declaring the MMIO hole as
> reserved memory and allowing reserved memory to be allocated (cf.
> wii_memory_fixups).
> 
> This patch is the first step towards proper support for discontiguous
> memory on PPC32 by using pfn_valid to check if a pointer points into
> RAM, rather than open-coding the check. It should result in no
> functional difference.
> 
> Signed-off-by: Jonathan NeuschA?fer <j.neuschaefer@gmx.net>
> ---
>   arch/powerpc/mm/pgtable_32.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/arch/powerpc/mm/pgtable_32.c b/arch/powerpc/mm/pgtable_32.c
> index d35d9ad3c1cd..b5c009893a44 100644
> --- a/arch/powerpc/mm/pgtable_32.c
> +++ b/arch/powerpc/mm/pgtable_32.c
> @@ -147,7 +147,7 @@ __ioremap_caller(phys_addr_t addr, unsigned long size, unsigned long flags,
>   	 * Don't allow anybody to remap normal RAM that we're using.
>   	 * mem_init() sets high_memory so only do the check after that.
>   	 */
> -	if (slab_is_available() && (p < virt_to_phys(high_memory)) &&
> +	if (slab_is_available() && pfn_valid(__phys_to_pfn(p)) &&

I'm not sure this is equivalent:

high_memory = (void *) __va(max_low_pfn * PAGE_SIZE);
#define ARCH_PFN_OFFSET		((unsigned long)(MEMORY_START >> PAGE_SHIFT))
#define pfn_valid(pfn)		((pfn) >= ARCH_PFN_OFFSET && (pfn) < max_mapnr)
set_max_mapnr(max_pfn);

So in the current implementation it checks against max_low_pfn while 
your patch checks against max_pfn

	max_low_pfn = max_pfn = memblock_end_of_DRAM() >> PAGE_SHIFT;
#ifdef CONFIG_HIGHMEM
	max_low_pfn = lowmem_end_addr >> PAGE_SHIFT;
#endif

Christophe

>   	    !(__allow_ioremap_reserved && memblock_is_region_reserved(p, size))) {
>   		printk("__ioremap(): phys addr 0x%llx is RAM lr %ps\n",
>   		       (unsigned long long)p, __builtin_return_address(0));
> 

---
L'absence de virus dans ce courrier A(C)lectronique a A(C)tA(C) vA(C)rifiA(C)e par le logiciel antivirus Avast.
https://www.avast.com/antivirus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
