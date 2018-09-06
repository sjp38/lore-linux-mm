Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id C20AF6B77CD
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 04:38:43 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id z30-v6so3398866edd.19
        for <linux-mm@kvack.org>; Thu, 06 Sep 2018 01:38:43 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l9-v6si3165279edi.372.2018.09.06.01.38.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Sep 2018 01:38:42 -0700 (PDT)
Date: Thu, 6 Sep 2018 10:38:41 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 16/29] memblock: replace __alloc_bootmem_node with
 appropriate memblock_ API
Message-ID: <20180906083841.GA14951@dhcp22.suse.cz>
References: <1536163184-26356-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1536163184-26356-17-git-send-email-rppt@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1536163184-26356-17-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Ingo Molnar <mingo@redhat.com>, Michael Ellerman <mpe@ellerman.id.au>, Paul Burton <paul.burton@mips.com>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed 05-09-18 18:59:31, Mike Rapoport wrote:
> Use memblock_alloc_try_nid whenever goal (i.e. mininal address is
> specified) and memblock_alloc_node otherwise.

I suspect you wanted to say (i.e. minimal address) is specified

> Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>

Acked-by: Michal Hocko <mhocko@suse.com>

One note below

> ---
>  arch/ia64/mm/discontig.c       |  6 ++++--
>  arch/ia64/mm/init.c            |  2 +-
>  arch/powerpc/kernel/setup_64.c |  6 ++++--
>  arch/sparc/kernel/setup_64.c   | 10 ++++------
>  arch/sparc/kernel/smp_64.c     |  4 ++--
>  5 files changed, 15 insertions(+), 13 deletions(-)
> 
> diff --git a/arch/ia64/mm/discontig.c b/arch/ia64/mm/discontig.c
> index 1928d57..918dda9 100644
> --- a/arch/ia64/mm/discontig.c
> +++ b/arch/ia64/mm/discontig.c
> @@ -451,8 +451,10 @@ static void __init *memory_less_node_alloc(int nid, unsigned long pernodesize)
>  	if (bestnode == -1)
>  		bestnode = anynode;
>  
> -	ptr = __alloc_bootmem_node(pgdat_list[bestnode], pernodesize,
> -		PERCPU_PAGE_SIZE, __pa(MAX_DMA_ADDRESS));
> +	ptr = memblock_alloc_try_nid(pernodesize, PERCPU_PAGE_SIZE,
> +				     __pa(MAX_DMA_ADDRESS),
> +				     BOOTMEM_ALLOC_ACCESSIBLE,
> +				     bestnode);
>  
>  	return ptr;
>  }
> diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
> index ffcc358..2169ca5 100644
> --- a/arch/ia64/mm/init.c
> +++ b/arch/ia64/mm/init.c
> @@ -459,7 +459,7 @@ int __init create_mem_map_page_table(u64 start, u64 end, void *arg)
>  		pte = pte_offset_kernel(pmd, address);
>  
>  		if (pte_none(*pte))
> -			set_pte(pte, pfn_pte(__pa(memblock_alloc_node(PAGE_SIZE, PAGE_SIZE, node))) >> PAGE_SHIFT,
> +			set_pte(pte, pfn_pte(__pa(memblock_alloc_node(PAGE_SIZE, PAGE_SIZE, node)) >> PAGE_SHIFT,
>  					     PAGE_KERNEL));

This doesn't seem to belong to the patch, right?

>  	}
>  	return 0;
-- 
Michal Hocko
SUSE Labs
