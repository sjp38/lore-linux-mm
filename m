Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 76E666B0009
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 05:06:50 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id t6so4311065pgt.11
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 02:06:50 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a61-v6si5815688pla.271.2018.03.16.02.06.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 16 Mar 2018 02:06:49 -0700 (PDT)
Date: Fri, 16 Mar 2018 10:06:47 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] Revert "mm/memblock.c: hardcode the end_pfn being -1"
Message-ID: <20180316090647.GC23100@dhcp22.suse.cz>
References: <1521168966-5245-1-git-send-email-hejianet@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1521168966-5245-1-git-send-email-hejianet@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jia He <hejianet@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Catalin Marinas <catalin.marinas@arm.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, AKASHI Takahiro <takahiro.akashi@linaro.org>, Gioh Kim <gi-oh.kim@profitbricks.com>, Daniel Vacek <neelx@redhat.com>, linux-kernel@vger.kernel.org, Jia He <jia.he@hxt-semitech.com>

On Thu 15-03-18 19:56:06, Jia He wrote:
> This reverts commit 379b03b7fa05f7db521b7732a52692448a3c34fe.
> 
> Commit 864b75f9d6b0 ("mm/page_alloc: fix memmap_init_zone pageblock
> alignment") introduced boot hang issues in arm/arm64 machines, so
> Ard Biesheuvel reverted in commit 3e04040df6d4. But there is a
> preparation patch for commit 864b75f9d6b0. So just revert it for
> the sake of caution.

Why? Is there anything wrong with this one?

> 
> Signed-off-by: Jia He <jia.he@hxt-semitech.com>
> ---
>  mm/memblock.c | 10 +++++-----
>  1 file changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/memblock.c b/mm/memblock.c
> index b6ba6b7..5a9ca2a 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -1107,7 +1107,7 @@ unsigned long __init_memblock memblock_next_valid_pfn(unsigned long pfn,
>  	struct memblock_type *type = &memblock.memory;
>  	unsigned int right = type->cnt;
>  	unsigned int mid, left = 0;
> -	phys_addr_t addr = PFN_PHYS(++pfn);
> +	phys_addr_t addr = PFN_PHYS(pfn + 1);
>  
>  	do {
>  		mid = (right + left) / 2;
> @@ -1118,15 +1118,15 @@ unsigned long __init_memblock memblock_next_valid_pfn(unsigned long pfn,
>  				  type->regions[mid].size))
>  			left = mid + 1;
>  		else {
> -			/* addr is within the region, so pfn is valid */
> -			return pfn;
> +			/* addr is within the region, so pfn + 1 is valid */
> +			return min(pfn + 1, max_pfn);
>  		}
>  	} while (left < right);
>  
>  	if (right == type->cnt)
> -		return -1UL;
> +		return max_pfn;
>  	else
> -		return PHYS_PFN(type->regions[right].base);
> +		return min(PHYS_PFN(type->regions[right].base), max_pfn);
>  }
>  
>  /**
> -- 
> 2.7.4
> 

-- 
Michal Hocko
SUSE Labs
