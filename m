Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2CBB66B04A3
	for <linux-mm@kvack.org>; Mon, 29 Oct 2018 16:12:25 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id y72-v6so349852ede.22
        for <linux-mm@kvack.org>; Mon, 29 Oct 2018 13:12:25 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j19-v6si5837421edj.18.2018.10.29.13.12.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Oct 2018 13:12:23 -0700 (PDT)
Date: Mon, 29 Oct 2018 21:12:21 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [mm PATCH v4 1/6] mm: Use mm_zero_struct_page from SPARC on all
 64b architectures
Message-ID: <20181029201221.GP32673@dhcp22.suse.cz>
References: <20181017235043.17213.92459.stgit@localhost.localdomain>
 <20181017235408.17213.38641.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181017235408.17213.38641.stgit@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, pavel.tatashin@microsoft.com, dave.jiang@intel.com, linux-kernel@vger.kernel.org, willy@infradead.org, davem@davemloft.net, yi.z.zhang@linux.intel.com, khalid.aziz@oracle.com, rppt@linux.vnet.ibm.com, vbabka@suse.cz, sparclinux@vger.kernel.org, dan.j.williams@intel.com, ldufour@linux.vnet.ibm.com, mgorman@techsingularity.net, mingo@kernel.org, kirill.shutemov@linux.intel.com

On Wed 17-10-18 16:54:08, Alexander Duyck wrote:
> This change makes it so that we use the same approach that was already in
> use on Sparc on all the archtectures that support a 64b long.
> 
> This is mostly motivated by the fact that 7 to 10 store/move instructions
> are likely always going to be faster than having to call into a function
> that is not specialized for handling page init.
> 
> An added advantage to doing it this way is that the compiler can get away
> with combining writes in the __init_single_page call. As a result the
> memset call will be reduced to only about 4 write operations, or at least
> that is what I am seeing with GCC 6.2 as the flags, LRU poitners, and
> count/mapcount seem to be cancelling out at least 4 of the 8 assignments on
> my system.
> 
> One change I had to make to the function was to reduce the minimum page
> size to 56 to support some powerpc64 configurations.
> 
> This change should introduce no change on SPARC since it already had this
> code. In the case of x86_64 I saw a reduction from 3.75s to 2.80s when
> initializing 384GB of RAM per node. Pavel Tatashin tested on a system with
> Broadcom's Stingray CPU and 48GB of RAM and found that __init_single_page()
> takes 19.30ns / 64-byte struct page before this patch and with this patch
> it takes 17.33ns / 64-byte struct page. Mike Rapoport ran a similar test on
> a OpenPower (S812LC 8348-21C) with Power8 processor and 128GB or RAM. His
> results per 64-byte struct page were 4.68ns before, and 4.59ns after this
> patch.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>

I thought I have sent my ack already but haven't obviously.

Acked-by: Michal Hocko <mhocko@suse.com>

Thanks for the updated version. I will try to get to the rest of the
series soon.

> ---
>  arch/sparc/include/asm/pgtable_64.h |   30 --------------------------
>  include/linux/mm.h                  |   41 ++++++++++++++++++++++++++++++++---
>  2 files changed, 38 insertions(+), 33 deletions(-)
> 
> diff --git a/arch/sparc/include/asm/pgtable_64.h b/arch/sparc/include/asm/pgtable_64.h
> index 1393a8ac596b..22500c3be7a9 100644
> --- a/arch/sparc/include/asm/pgtable_64.h
> +++ b/arch/sparc/include/asm/pgtable_64.h
> @@ -231,36 +231,6 @@
>  extern struct page *mem_map_zero;
>  #define ZERO_PAGE(vaddr)	(mem_map_zero)
>  
> -/* This macro must be updated when the size of struct page grows above 80
> - * or reduces below 64.
> - * The idea that compiler optimizes out switch() statement, and only
> - * leaves clrx instructions
> - */
> -#define	mm_zero_struct_page(pp) do {					\
> -	unsigned long *_pp = (void *)(pp);				\
> -									\
> -	 /* Check that struct page is either 64, 72, or 80 bytes */	\
> -	BUILD_BUG_ON(sizeof(struct page) & 7);				\
> -	BUILD_BUG_ON(sizeof(struct page) < 64);				\
> -	BUILD_BUG_ON(sizeof(struct page) > 80);				\
> -									\
> -	switch (sizeof(struct page)) {					\
> -	case 80:							\
> -		_pp[9] = 0;	/* fallthrough */			\
> -	case 72:							\
> -		_pp[8] = 0;	/* fallthrough */			\
> -	default:							\
> -		_pp[7] = 0;						\
> -		_pp[6] = 0;						\
> -		_pp[5] = 0;						\
> -		_pp[4] = 0;						\
> -		_pp[3] = 0;						\
> -		_pp[2] = 0;						\
> -		_pp[1] = 0;						\
> -		_pp[0] = 0;						\
> -	}								\
> -} while (0)
> -
>  /* PFNs are real physical page numbers.  However, mem_map only begins to record
>   * per-page information starting at pfn_base.  This is to handle systems where
>   * the first physical page in the machine is at some huge physical address,
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index fcf9cc9d535f..6e2c9631af05 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -98,10 +98,45 @@ static inline void set_max_mapnr(unsigned long limit) { }
>  
>  /*
>   * On some architectures it is expensive to call memset() for small sizes.
> - * Those architectures should provide their own implementation of "struct page"
> - * zeroing by defining this macro in <asm/pgtable.h>.
> + * If an architecture decides to implement their own version of
> + * mm_zero_struct_page they should wrap the defines below in a #ifndef and
> + * define their own version of this macro in <asm/pgtable.h>
>   */
> -#ifndef mm_zero_struct_page
> +#if BITS_PER_LONG == 64
> +/* This function must be updated when the size of struct page grows above 80
> + * or reduces below 56. The idea that compiler optimizes out switch()
> + * statement, and only leaves move/store instructions. Also the compiler can
> + * combine write statments if they are both assignments and can be reordered,
> + * this can result in several of the writes here being dropped.
> + */
> +#define	mm_zero_struct_page(pp) __mm_zero_struct_page(pp)
> +static inline void __mm_zero_struct_page(struct page *page)
> +{
> +	unsigned long *_pp = (void *)page;
> +
> +	 /* Check that struct page is either 56, 64, 72, or 80 bytes */
> +	BUILD_BUG_ON(sizeof(struct page) & 7);
> +	BUILD_BUG_ON(sizeof(struct page) < 56);
> +	BUILD_BUG_ON(sizeof(struct page) > 80);
> +
> +	switch (sizeof(struct page)) {
> +	case 80:
> +		_pp[9] = 0;	/* fallthrough */
> +	case 72:
> +		_pp[8] = 0;	/* fallthrough */
> +	case 64:
> +		_pp[7] = 0;	/* fallthrough */
> +	case 56:
> +		_pp[6] = 0;
> +		_pp[5] = 0;
> +		_pp[4] = 0;
> +		_pp[3] = 0;
> +		_pp[2] = 0;
> +		_pp[1] = 0;
> +		_pp[0] = 0;
> +	}
> +}
> +#else
>  #define mm_zero_struct_page(pp)  ((void)memset((pp), 0, sizeof(struct page)))
>  #endif
>  
> 

-- 
Michal Hocko
SUSE Labs
