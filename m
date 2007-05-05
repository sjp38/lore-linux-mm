Date: Sat, 5 May 2007 10:29:08 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Dquot slab cache: Fix competing alignments
In-Reply-To: <Pine.LNX.4.64.0705042218140.21707@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0705051028310.27873@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0705042218140.21707@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Do not apply since this includes removing SLAB_HWCACHE_ALIGN.

On Fri, 4 May 2007, Christoph Lameter wrote:

> There is a competing specification of an alignment and hardware
> cache alignment in the kmem_cache_create call. Remove the cache 
> alignments. Convert call to use a macro and specify cache line alignment 
> on the struct.
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> 
> Index: slub/fs/dquot.c
> ===================================================================
> --- slub.orig/fs/dquot.c	2007-05-04 21:56:20.000000000 -0700
> +++ slub/fs/dquot.c	2007-05-04 22:17:50.000000000 -0700
> @@ -1848,11 +1848,8 @@ static int __init dquot_init(void)
>  
>  	register_sysctl_table(sys_table);
>  
> -	dquot_cachep = kmem_cache_create("dquot", 
> -			sizeof(struct dquot), sizeof(unsigned long) * 4,
> -			(SLAB_HWCACHE_ALIGN|SLAB_RECLAIM_ACCOUNT|
> -				SLAB_MEM_SPREAD|SLAB_PANIC),
> -			NULL, NULL);
> +	dquot_cachep = KMEM_CACHE(dquot,
> +			SLAB_MEM_SPREAD|SLAB_RECLAIM_ACCOUNT|SLAB_PANIC);
>  
>  	order = 0;
>  	dquot_hash = (struct hlist_head *)__get_free_pages(GFP_ATOMIC, order);
> Index: slub/include/linux/quota.h
> ===================================================================
> --- slub.orig/include/linux/quota.h	2007-05-04 22:06:09.000000000 -0700
> +++ slub/include/linux/quota.h	2007-05-04 22:06:54.000000000 -0700
> @@ -225,7 +225,7 @@ struct dquot {
>  	unsigned long dq_flags;		/* See DQ_* */
>  	short dq_type;			/* Type of quota */
>  	struct mem_dqblk dq_dqb;	/* Diskquota usage */
> -};
> +} ____cacheline_aligned;
>  
>  #define NODQUOT (struct dquot *)NULL
>  
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
