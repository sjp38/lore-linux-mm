Date: Mon, 22 Oct 2007 14:31:47 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 14/14] bufferhead: Revert constructor removal
Message-Id: <20071022143147.03de69ca.akpm@linux-foundation.org>
In-Reply-To: <20070925233008.731010041@sgi.com>
References: <20070925232543.036615409@sgi.com>
	<20070925233008.731010041@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 25 Sep 2007 16:25:57 -0700
Christoph Lameter <clameter@sgi.com> wrote:

> The constructor for buffer_head slabs was removed recently. We need
> the constructor back in slab defrag in order to insure that slab objects
> always have a definite state even before we allocated them.
> 

I don't understand.  Slab defrag isn't merged.

> 
> ---
>  fs/buffer.c |   19 +++++++++++++++----
>  1 files changed, 15 insertions(+), 4 deletions(-)
> 
> Index: linux-2.6.23-rc8-mm1/fs/buffer.c
> ===================================================================
> --- linux-2.6.23-rc8-mm1.orig/fs/buffer.c	2007-09-25 15:14:40.000000000 -0700
> +++ linux-2.6.23-rc8-mm1/fs/buffer.c	2007-09-25 15:36:50.000000000 -0700
> @@ -3093,7 +3093,7 @@ static void recalc_bh_state(void)
>  	
>  struct buffer_head *alloc_buffer_head(gfp_t gfp_flags)
>  {
> -	struct buffer_head *ret = kmem_cache_zalloc(bh_cachep,
> +	struct buffer_head *ret = kmem_cache_alloc(bh_cachep,
>  				set_migrateflags(gfp_flags, __GFP_RECLAIMABLE));
>  	if (ret) {
>  		INIT_LIST_HEAD(&ret->b_assoc_buffers);
> @@ -3137,12 +3137,24 @@ static int buffer_cpu_notify(struct noti
>  	return NOTIFY_OK;
>  }
>  
> +static void
> +init_buffer_head(struct kmem_cache *cachep, void *data)
> +{
> +	struct buffer_head * bh = (struct buffer_head *)data;
> +
> +	memset(bh, 0, sizeof(*bh));
> +	INIT_LIST_HEAD(&bh->b_assoc_buffers);
> +}
> +
>  void __init buffer_init(void)
>  {
>  	int nrpages;
>  
> -	bh_cachep = KMEM_CACHE(buffer_head,
> -			SLAB_RECLAIM_ACCOUNT|SLAB_PANIC|SLAB_MEM_SPREAD);
> +	bh_cachep = kmem_cache_create("buffer_head",
> +			sizeof(struct buffer_head), 0,
> +				(SLAB_RECLAIM_ACCOUNT|SLAB_PANIC|
> +				SLAB_MEM_SPREAD),
> +				init_buffer_head);
>  

So I see no need for this patch?  Shouldn't it be part of a slab-defrag
patch series?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
