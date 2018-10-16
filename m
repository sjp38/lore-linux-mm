Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id CD2E36B0005
	for <linux-mm@kvack.org>; Tue, 16 Oct 2018 15:01:14 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id n1-v6so25233516qtb.17
        for <linux-mm@kvack.org>; Tue, 16 Oct 2018 12:01:14 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f6-v6sor16527794qvr.8.2018.10.16.12.01.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Oct 2018 12:01:13 -0700 (PDT)
Subject: Re: [mm PATCH v3 1/6] mm: Use mm_zero_struct_page from SPARC on all
 64b architectures
References: <20181015202456.2171.88406.stgit@localhost.localdomain>
 <20181015202656.2171.92963.stgit@localhost.localdomain>
From: Pavel Tatashin <pasha.tatashin@gmail.com>
Message-ID: <57c559f6-4858-7a52-7fbb-979caa08f240@gmail.com>
Date: Tue, 16 Oct 2018 15:01:11 -0400
MIME-Version: 1.0
In-Reply-To: <20181015202656.2171.92963.stgit@localhost.localdomain>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.h.duyck@linux.intel.com>, linux-mm@kvack.org, akpm@linux-foundation.org
Cc: pavel.tatashin@microsoft.com, mhocko@suse.com, dave.jiang@intel.com, linux-kernel@vger.kernel.org, willy@infradead.org, davem@davemloft.net, yi.z.zhang@linux.intel.com, khalid.aziz@oracle.com, rppt@linux.vnet.ibm.com, vbabka@suse.cz, sparclinux@vger.kernel.org, dan.j.williams@intel.com, ldufour@linux.vnet.ibm.com, mgorman@techsingularity.net, mingo@kernel.org, kirill.shutemov@linux.intel.com



On 10/15/18 4:26 PM, Alexander Duyck wrote:
> This change makes it so that we use the same approach that was already in
> use on Sparc on all the archtectures that support a 64b long.
> 
> This is mostly motivated by the fact that 8 to 10 store/move instructions
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
> Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>


I have tested on Broadcom's Stingray cpu with 48G RAM:
__init_single_page() takes 19.30ns / 64-byte struct page
Wit the change it takes 17.33ns / 64-byte struct page

Please add this data and also the data from Intel to the description.

Thank you,
Pavel

> ---
>  arch/sparc/include/asm/pgtable_64.h |   30 ------------------------------
>  include/linux/mm.h                  |   34 ++++++++++++++++++++++++++++++++++
>  2 files changed, 34 insertions(+), 30 deletions(-)
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
> index bb0de406f8e7..ec6e57a0c14e 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -102,8 +102,42 @@ static inline void set_max_mapnr(unsigned long limit) { }
>   * zeroing by defining this macro in <asm/pgtable.h>.
>   */

The comment above becomes outdated. Please change, we use optimized
mm_zero_struct_page on every 64-bit platform.

>  #ifndef mm_zero_struct_page
> +#if BITS_PER_LONG == 64
> +/* This function must be updated when the size of struct page grows above 80
> + * or reduces below 64. The idea that compiler optimizes out switch()
> + * statement, and only leaves move/store instructions
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
> +	default:
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
> +#endif
>  
>  /*
>   * Default maximum number of active map areas, this limits the number of vmas
> 
