Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3B9CC6B40BE
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 02:04:06 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id x3so15090039wru.22
        for <linux-mm@kvack.org>; Sun, 25 Nov 2018 23:04:06 -0800 (PST)
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id r7-v6si12197613wmb.2.2018.11.25.23.04.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 25 Nov 2018 23:04:04 -0800 (PST)
Subject: Re: [PATCH 5/5] arch: simplify several early memory allocations
References: <1543182277-8819-1-git-send-email-rppt@linux.ibm.com>
 <1543182277-8819-6-git-send-email-rppt@linux.ibm.com>
From: Christophe LEROY <christophe.leroy@c-s.fr>
Message-ID: <7a92357c-6251-fe84-d724-16fdc49d03a3@c-s.fr>
Date: Mon, 26 Nov 2018 08:03:55 +0100
MIME-Version: 1.0
In-Reply-To: <1543182277-8819-6-git-send-email-rppt@linux.ibm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: fr
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.ibm.com>, linux-kernel@vger.kernel.org
Cc: Michal Hocko <mhocko@suse.com>, linux-sh@vger.kernel.org, linux-mm@kvack.org, Rich Felker <dalias@libc.org>, Paul Mackerras <paulus@samba.org>, sparclinux@vger.kernel.org, Vincent Chen <deanbo422@gmail.com>, Jonas Bonn <jonas@southpole.se>, linux-c6x-dev@linux-c6x.org, Yoshinori Sato <ysato@users.sourceforge.jp>, Russell King <linux@armlinux.org.uk>, Mark Salter <msalter@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>, openrisc@lists.librecores.org, Greentime Hu <green.hu@gmail.com>, Stafford Horne <shorne@gmail.com>, Guan Xuetao <gxt@pku.edu.cn>, linux-arm-kernel@lists.infradead.org, Michal Simek <monstr@monstr.eu>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>



Le 25/11/2018 à 22:44, Mike Rapoport a écrit :
> There are several early memory allocations in arch/ code that use
> memblock_phys_alloc() to allocate memory, convert the returned physical
> address to the virtual address and then set the allocated memory to zero.
> 
> Exactly the same behaviour can be achieved simply by calling
> memblock_alloc(): it allocates the memory in the same way as
> memblock_phys_alloc(), then it performs the phys_to_virt() conversion and
> clears the allocated memory.
> 
> Replace the longer sequence with a simpler call to memblock_alloc().
> 
> Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
> ---
>   arch/arm/mm/mmu.c                     |  4 +---
>   arch/c6x/mm/dma-coherent.c            |  9 ++-------
>   arch/nds32/mm/init.c                  | 12 ++++--------
>   arch/powerpc/kernel/setup-common.c    |  4 ++--
>   arch/powerpc/mm/pgtable_32.c          |  4 +---
>   arch/powerpc/mm/ppc_mmu_32.c          |  3 +--
>   arch/powerpc/platforms/powernv/opal.c |  3 +--
>   arch/sparc/kernel/prom_64.c           |  7 ++-----
>   arch/sparc/mm/init_64.c               |  9 +++------
>   arch/unicore32/mm/mmu.c               |  4 +---
>   10 files changed, 18 insertions(+), 41 deletions(-)
> 
[...]

> diff --git a/arch/powerpc/mm/pgtable_32.c b/arch/powerpc/mm/pgtable_32.c
> index bda3c6f..9931e68 100644
> --- a/arch/powerpc/mm/pgtable_32.c
> +++ b/arch/powerpc/mm/pgtable_32.c
> @@ -50,9 +50,7 @@ __ref pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
>   	if (slab_is_available()) {
>   		pte = (pte_t *)__get_free_page(GFP_KERNEL|__GFP_ZERO);
>   	} else {
> -		pte = __va(memblock_phys_alloc(PAGE_SIZE, PAGE_SIZE));
> -		if (pte)
> -			clear_page(pte);
> +		pte = memblock_alloc(PAGE_SIZE, PAGE_SIZE);

memblock_alloc() uses memset to zeroize the block.

clear_page() is more performant than memset().


Christophe

[...]
