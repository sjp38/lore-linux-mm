Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3F41B6B0279
	for <linux-mm@kvack.org>; Tue, 23 May 2017 02:58:27 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id p62so14639166wrc.13
        for <linux-mm@kvack.org>; Mon, 22 May 2017 23:58:27 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q130si1209111wme.84.2017.05.22.23.58.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 22 May 2017 23:58:26 -0700 (PDT)
Date: Tue, 23 May 2017 08:58:24 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [v5 1/1] mm: Adaptive hash table scaling
Message-ID: <20170523065823.GE12813@dhcp22.suse.cz>
References: <1495469329-755807-1-git-send-email-pasha.tatashin@oracle.com>
 <1495469329-755807-2-git-send-email-pasha.tatashin@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1495469329-755807-2-git-send-email-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mpe@ellerman.id.au

On Mon 22-05-17 12:08:49, Pavel Tatashin wrote:
> Allow hash tables to scale with memory but at slower pace, when HASH_ADAPT
> is provided every time memory quadruples the sizes of hash tables will only
> double instead of quadrupling as well. This algorithm starts working only
> when memory size reaches a certain point, currently set to 64G.
> 
> This is example of dentry hash table size, before and after four various
> memory configurations:
> 
> MEMORY    SCALE        HASH_SIZE
>         old    new    old     new
>     8G  13     13      8M      8M
>    16G  13     13     16M     16M
>    32G  13     13     32M     32M
>    64G  13     13     64M     64M
>   128G  13     14    128M     64M
>   256G  13     14    256M    128M
>   512G  13     15    512M    128M
>  1024G  13     15   1024M    256M
>  2048G  13     16   2048M    256M
>  4096G  13     16   4096M    512M
>  8192G  13     17   8192M    512M
> 16384G  13     17  16384M   1024M
> 32768G  13     18  32768M   1024M
> 65536G  13     18  65536M   2048M
> 
> Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/page_alloc.c | 25 +++++++++++++++++++++++++
>  1 file changed, 25 insertions(+)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 8afa63e81e73..409e0cd35381 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -7169,6 +7169,21 @@ static unsigned long __init arch_reserved_kernel_pages(void)
>  #endif
>  
>  /*
> + * Adaptive scale is meant to reduce sizes of hash tables on large memory
> + * machines. As memory size is increased the scale is also increased but at
> + * slower pace.  Starting from ADAPT_SCALE_BASE (64G), every time memory
> + * quadruples the scale is increased by one, which means the size of hash table
> + * only doubles, instead of quadrupling as well.
> + * Because 32-bit systems cannot have large physical memory, where this scaling
> + * makes sense, it is disabled on such platforms.
> + */
> +#if __BITS_PER_LONG > 32
> +#define ADAPT_SCALE_BASE	(64ul << 30)
> +#define ADAPT_SCALE_SHIFT	2
> +#define ADAPT_SCALE_NPAGES	(ADAPT_SCALE_BASE >> PAGE_SHIFT)
> +#endif
> +
> +/*
>   * allocate a large system hash table from bootmem
>   * - it is assumed that the hash table must contain an exact power-of-2
>   *   quantity of entries
> @@ -7199,6 +7214,16 @@ void *__init alloc_large_system_hash(const char *tablename,
>  		if (PAGE_SHIFT < 20)
>  			numentries = round_up(numentries, (1<<20)/PAGE_SIZE);
>  
> +#if __BITS_PER_LONG > 32
> +		if (!high_limit) {
> +			unsigned long adapt;
> +
> +			for (adapt = ADAPT_SCALE_NPAGES; adapt < numentries;
> +			     adapt <<= ADAPT_SCALE_SHIFT)
> +				scale++;
> +		}
> +#endif
> +
>  		/* limit to 1 bucket per 2^scale bytes of low memory */
>  		if (scale > PAGE_SHIFT)
>  			numentries >>= (scale - PAGE_SHIFT);
> -- 
> 2.13.0

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
