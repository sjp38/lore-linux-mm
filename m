Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 3C83A6B0038
	for <linux-mm@kvack.org>; Fri, 21 Aug 2015 10:20:56 -0400 (EDT)
Received: by wicne3 with SMTP id ne3so17348403wic.0
        for <linux-mm@kvack.org>; Fri, 21 Aug 2015 07:20:55 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gj1si4609595wib.19.2015.08.21.07.20.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 21 Aug 2015 07:20:54 -0700 (PDT)
Subject: Re: [PATCH 07/10] mm: page_alloc: Rename __GFP_WAIT to __GFP_RECLAIM
References: <1439376335-17895-1-git-send-email-mgorman@techsingularity.net>
 <1439376335-17895-8-git-send-email-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55D733C4.50709@suse.cz>
Date: Fri, 21 Aug 2015 16:20:52 +0200
MIME-Version: 1.0
In-Reply-To: <1439376335-17895-8-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Linux-MM <linux-mm@kvack.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, LKML <linux-kernel@vger.kernel.org>

On 08/12/2015 12:45 PM, Mel Gorman wrote:
> __GFP_WAIT was used to signal that the caller was in atomic context and
> could not sleep.  Now it is possible to distinguish between true atomic
> context and callers that are not willing to sleep. The latter should clear
> __GFP_DIRECT_RECLAIM so kswapd will still wake. As clearing __GFP_WAIT
> behaves differently, there is a risk that people will clear the wrong
> flags. This patch renames __GFP_WAIT to __GFP_RECLAIM to clearly indicate
> what it does -- setting it allows all reclaim activity, clearing them
> prevents it.
>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

...

> diff --git a/drivers/block/drbd/drbd_receiver.c b/drivers/block/drbd/drbd_receiver.c
> index c097909c589c..1d2046e68808 100644
> --- a/drivers/block/drbd/drbd_receiver.c
> +++ b/drivers/block/drbd/drbd_receiver.c
> @@ -357,7 +357,7 @@ drbd_alloc_peer_req(struct drbd_peer_device *peer_device, u64 id, sector_t secto
>   	}
>
>   	if (has_payload && data_size) {
> -		page = drbd_alloc_pages(peer_device, nr_pages, (gfp_mask & __GFP_WAIT));
> +		page = drbd_alloc_pages(peer_device, nr_pages, (gfp_mask & __GFP_RECLAIM));

I think here it should test only for direct reclaim (via the helper) and 
thus moved to patch 06?

> --- a/drivers/gpu/drm/i915/i915_gem.c
> +++ b/drivers/gpu/drm/i915/i915_gem.c
> @@ -2226,7 +2226,7 @@ i915_gem_object_get_pages_gtt(struct drm_i915_gem_object *obj)
>   	mapping = file_inode(obj->base.filp)->i_mapping;
>   	gfp = mapping_gfp_mask(mapping);
>   	gfp |= __GFP_NORETRY | __GFP_NOWARN;
> -	gfp &= ~(__GFP_IO | __GFP_WAIT);
> +	gfp &= ~(__GFP_IO | __GFP_RECLAIM);

Why clear the kswapd reclaim here?

> diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
> index ed37d26eb20d..393270436a4b 100644
> --- a/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
> +++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
> @@ -113,7 +113,7 @@ do {						\
>   do {									    \
>   	LASSERT(!in_interrupt() ||					    \
>   		((size) <= LIBCFS_VMALLOC_SIZE &&			    \
> -		 ((mask) & __GFP_WAIT) == 0));				    \
> +		 ((mask) & __GFP_RECLAIM) == 0));			    \
>   } while (0)

This should test only __GFP_DIRECT_RECLAIM?

>   #define LIBCFS_ALLOC_POST(ptr, size)					    \
> diff --git a/fs/btrfs/extent_io.c b/fs/btrfs/extent_io.c
> index 35660da77921..92e284d0362e 100644
> --- a/fs/btrfs/extent_io.c
> +++ b/fs/btrfs/extent_io.c
> @@ -718,7 +718,7 @@ int clear_extent_bit(struct extent_io_tree *tree, u64 start, u64 end,
>   	if (start > end)
>   		goto out;
>   	spin_unlock(&tree->lock);
> -	if (mask & __GFP_WAIT)
> +	if (mask & __GFP_RECLAIM)
>   		cond_resched();
>   	goto again;
>   }
> @@ -1028,7 +1028,7 @@ __set_extent_bit(struct extent_io_tree *tree, u64 start, u64 end,
>   	if (start > end)
>   		goto out;
>   	spin_unlock(&tree->lock);
> -	if (mask & __GFP_WAIT)
> +	if (mask & __GFP_RECLAIM)
>   		cond_resched();
>   	goto again;
>   }
> @@ -1253,7 +1253,7 @@ int convert_extent_bit(struct extent_io_tree *tree, u64 start, u64 end,
>   	if (start > end)
>   		goto out;
>   	spin_unlock(&tree->lock);
> -	if (mask & __GFP_WAIT)
> +	if (mask & __GFP_RECLAIM)
>   		cond_resched();
>   	first_iteration = false;
>   	goto again;

This too?

> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index dbd246a14e2f..e066f3afae73 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -104,7 +104,7 @@ struct vm_area_struct;
>    * can be cleared when the reclaiming of pages would cause unnecessary
>    * disruption.
>    */
> -#define __GFP_WAIT (__GFP_DIRECT_RECLAIM|__GFP_KSWAPD_RECLAIM)
> +#define __GFP_RECLAIM (__GFP_DIRECT_RECLAIM|__GFP_KSWAPD_RECLAIM)
>   #define __GFP_DIRECT_RECLAIM	((__force gfp_t)___GFP_DIRECT_RECLAIM) /* Caller can reclaim */
>   #define __GFP_KSWAPD_RECLAIM	((__force gfp_t)___GFP_KSWAPD_RECLAIM) /* kswapd can wake */
>
> @@ -123,12 +123,12 @@ struct vm_area_struct;
>    */
>   #define GFP_ATOMIC	(__GFP_HIGH|__GFP_ATOMIC|__GFP_KSWAPD_RECLAIM)
>   #define GFP_NOWAIT	(__GFP_KSWAPD_RECLAIM)
> -#define GFP_NOIO	(__GFP_WAIT)
> -#define GFP_NOFS	(__GFP_WAIT | __GFP_IO)
> -#define GFP_KERNEL	(__GFP_WAIT | __GFP_IO | __GFP_FS)
> -#define GFP_TEMPORARY	(__GFP_WAIT | __GFP_IO | __GFP_FS | \
> +#define GFP_NOIO	(__GFP_RECLAIM)
> +#define GFP_NOFS	(__GFP_RECLAIM | __GFP_IO)
> +#define GFP_KERNEL	(__GFP_RECLAIM | __GFP_IO | __GFP_FS)
> +#define GFP_TEMPORARY	(__GFP_RECLAIM | __GFP_IO | __GFP_FS | \
>   			 __GFP_RECLAIMABLE)
> -#define GFP_USER	(__GFP_WAIT | __GFP_IO | __GFP_FS | __GFP_HARDWALL)
> +#define GFP_USER	(__GFP_RECLAIM | __GFP_IO | __GFP_FS | __GFP_HARDWALL)
>   #define GFP_HIGHUSER	(GFP_USER | __GFP_HIGHMEM)
>   #define GFP_HIGHUSER_MOVABLE	(GFP_HIGHUSER | __GFP_MOVABLE)
>   #define GFP_IOFS	(__GFP_IO | __GFP_FS)

Hmm GFP_IOFS should maybe include __GFP_KSWAPD_RECLAIM? Although I 
wonder if it makes sense to use it like "... | GFP_IOFS" and not just as 
a mask "... & ~GFP_IOFS". Not including __GFP_KSWAPD_RECLAIM changes the 
former use, while including it changes the latter one.
Maybe we should just remove it while at it? There's only a handful of 
users. mm/ uses it as a mask, and the rest is in staging/lustre and it's 
doing allocations like "__GFP_ZERO | GFP_IOFS" which looks like a 
mistake to me - what good is IO or FS without DIRECT_RECLAIM?

It's probably best we removed it or changed it to __GFP_IOFS. The form 
without underscores suggests usage as parameter to alloc functions and 
that's clearly wrong here.

> diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
> index d8e2e3918ce2..4bee2392dbb2 100644
> --- a/net/netlink/af_netlink.c
> +++ b/net/netlink/af_netlink.c
> @@ -2061,7 +2061,7 @@ int netlink_broadcast_filtered(struct sock *ssk, struct sk_buff *skb, u32 portid
>   	consume_skb(info.skb2);
>
>   	if (info.delivered) {
> -		if (info.congested && (allocation & __GFP_WAIT))
> +		if (info.congested && (allocation & __GFP_RECLAIM))
>   			yield();

Just direct reclaim?

>   		return 0;
>   	}
> diff --git a/net/rxrpc/ar-connection.c b/net/rxrpc/ar-connection.c
> index 6631f4f1e39b..b5cd65401a28 100644
> --- a/net/rxrpc/ar-connection.c
> +++ b/net/rxrpc/ar-connection.c
> @@ -500,7 +500,7 @@ int rxrpc_connect_call(struct rxrpc_sock *rx,
>   		if (bundle->num_conns >= 20) {
>   			_debug("too many conns");
>
> -			if (!(gfp & __GFP_WAIT)) {
> +			if (!(gfp & __GFP_RECLAIM)) {
>   				_leave(" = -EAGAIN");
>   				return -EAGAIN;
>   			}

ditto?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
