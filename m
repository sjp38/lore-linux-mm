Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f178.google.com (mail-yk0-f178.google.com [209.85.160.178])
	by kanga.kvack.org (Postfix) with ESMTP id 6B7F76B0038
	for <linux-mm@kvack.org>; Tue, 24 Mar 2015 19:41:57 -0400 (EDT)
Received: by ykcn8 with SMTP id n8so4828180ykc.3
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 16:41:57 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id wa5si975229vdb.107.2015.03.24.16.41.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 24 Mar 2015 16:41:56 -0700 (PDT)
Message-ID: <5511F629.2070907@oracle.com>
Date: Tue, 24 Mar 2015 18:41:29 -0500
From: Dave Kleikamp <dave.kleikamp@oracle.com>
MIME-Version: 1.0
Subject: Re: [patch 1/4] fs, jfs: remove slab object constructor
References: <alpine.DEB.2.10.1503241607240.21805@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.10.1503241607240.21805@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Kleikamp <shaggy@kernel.org>, Christoph Hellwig <hch@lst.de>, Sebastian Ott <sebott@linux.vnet.ibm.com>, Mikulas Patocka <mpatocka@redhat.com>, Catalin Marinas <catalin.marinas@arm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jfs-discussion@lists.sourceforge.net

On 03/24/2015 06:08 PM, David Rientjes wrote:
> Mempools based on slab caches with object constructors are risky because
> element allocation can happen either from the slab cache itself, meaning
> the constructor is properly called before returning, or from the mempool
> reserve pool, meaning the constructor is not called before returning,
> depending on the allocation context.
> 
> For this reason, we should disallow creating mempools based on slab
> caches that have object constructors.  Callers of mempool_alloc() will
> be responsible for properly initializing the returned element.
> 
> Then, it doesn't matter if the element came from the slab cache or the
> mempool reserved pool.
> 
> The only occurrence of a mempool being based on a slab cache with an
> object constructor in the tree is in fs/jfs/jfs_metapage.c.  Remove it
> and properly initialize the element in alloc_metapage().
> 
> At the same time, META_free is never used, so remove it as well.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>
Acked-by: Dave Kleikamp <dave.kleikamp@oracle.com>

> ---
>  fs/jfs/jfs_metapage.c | 31 ++++++++++++-------------------
>  fs/jfs/jfs_metapage.h |  1 -
>  2 files changed, 12 insertions(+), 20 deletions(-)
> 
> diff --git a/fs/jfs/jfs_metapage.c b/fs/jfs/jfs_metapage.c
> --- a/fs/jfs/jfs_metapage.c
> +++ b/fs/jfs/jfs_metapage.c
> @@ -183,30 +183,23 @@ static inline void remove_metapage(struct page *page, struct metapage *mp)
>  
>  #endif
>  
> -static void init_once(void *foo)
> -{
> -	struct metapage *mp = (struct metapage *)foo;
> -
> -	mp->lid = 0;
> -	mp->lsn = 0;
> -	mp->flag = 0;
> -	mp->data = NULL;
> -	mp->clsn = 0;
> -	mp->log = NULL;
> -	set_bit(META_free, &mp->flag);
> -	init_waitqueue_head(&mp->wait);
> -}
> -
>  static inline struct metapage *alloc_metapage(gfp_t gfp_mask)
>  {
> -	return mempool_alloc(metapage_mempool, gfp_mask);
> +	struct metapage *mp = mempool_alloc(metapage_mempool, gfp_mask);
> +
> +	if (mp) {
> +		mp->lid = 0;
> +		mp->lsn = 0;
> +		mp->data = NULL;
> +		mp->clsn = 0;
> +		mp->log = NULL;
> +		init_waitqueue_head(&mp->wait);
> +	}
> +	return mp;
>  }
>  
>  static inline void free_metapage(struct metapage *mp)
>  {
> -	mp->flag = 0;
> -	set_bit(META_free, &mp->flag);
> -
>  	mempool_free(mp, metapage_mempool);
>  }
>  
> @@ -216,7 +209,7 @@ int __init metapage_init(void)
>  	 * Allocate the metapage structures
>  	 */
>  	metapage_cache = kmem_cache_create("jfs_mp", sizeof(struct metapage),
> -					   0, 0, init_once);
> +					   0, 0, NULL);
>  	if (metapage_cache == NULL)
>  		return -ENOMEM;
>  
> diff --git a/fs/jfs/jfs_metapage.h b/fs/jfs/jfs_metapage.h
> --- a/fs/jfs/jfs_metapage.h
> +++ b/fs/jfs/jfs_metapage.h
> @@ -48,7 +48,6 @@ struct metapage {
>  
>  /* metapage flag */
>  #define META_locked	0
> -#define META_free	1
>  #define META_dirty	2
>  #define META_sync	3
>  #define META_discard	4
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
