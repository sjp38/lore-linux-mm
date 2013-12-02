Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f52.google.com (mail-yh0-f52.google.com [209.85.213.52])
	by kanga.kvack.org (Postfix) with ESMTP id 7941E6B0031
	for <linux-mm@kvack.org>; Mon,  2 Dec 2013 17:11:00 -0500 (EST)
Received: by mail-yh0-f52.google.com with SMTP id i72so9411227yha.39
        for <linux-mm@kvack.org>; Mon, 02 Dec 2013 14:11:00 -0800 (PST)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [2001:44b8:8060:ff02:300:1:2:7])
        by mx.google.com with ESMTP id f29si564339yhd.195.2013.12.02.14.10.58
        for <linux-mm@kvack.org>;
        Mon, 02 Dec 2013 14:10:59 -0800 (PST)
Date: Tue, 3 Dec 2013 09:10:52 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [patch 9/9] mm: keep page cache radix tree nodes in check
Message-ID: <20131202221052.GT8803@dastard>
References: <1386012108-21006-1-git-send-email-hannes@cmpxchg.org>
 <1386012108-21006-10-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1386012108-21006-10-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Hellwig <hch@infradead.org>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Metin Doslu <metin@citusdata.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan.kim@gmail.com>, Ozgun Erdogan <ozgun@citusdata.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Roman Gushchin <klamm@yandex-team.ru>, Ryan Mallon <rmallon@gmail.com>, Tejun Heo <tj@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, Dec 02, 2013 at 02:21:48PM -0500, Johannes Weiner wrote:
> Previously, page cache radix tree nodes were freed after reclaim
> emptied out their page pointers.  But now reclaim stores shadow
> entries in their place, which are only reclaimed when the inodes
> themselves are reclaimed.  This is problematic for bigger files that
> are still in use after they have a significant amount of their cache
> reclaimed, without any of those pages actually refaulting.  The shadow
> entries will just sit there and waste memory.  In the worst case, the
> shadow entries will accumulate until the machine runs out of memory.
> 
> To get this under control, the VM will track radix tree nodes
> exclusively containing shadow entries on a per-NUMA node list.
> Per-NUMA rather than global because we expect the radix tree nodes
> themselves to be allocated node-locally and we want to reduce
> cross-node references of otherwise independent cache workloads.  A
> simple shrinker will then reclaim these nodes on memory pressure.
> 
> A few things need to be stored in the radix tree node to implement the
> shadow node LRU and allow tree deletions coming from the list:
> 
> 1. There is no index available that would describe the reverse path
>    from the node up to the tree root, which is needed to perform a
>    deletion.  To solve this, encode in each node its offset inside the
>    parent.  This can be stored in the unused upper bits of the same
>    member that stores the node's height at no extra space cost.
> 
> 2. The number of shadow entries needs to be counted in addition to the
>    regular entries, to quickly detect when the node is ready to go to
>    the shadow node LRU list.  The current entry count is an unsigned
>    int but the maximum number of entries is 64, so a shadow counter
>    can easily be stored in the unused upper bits.
> 
> 3. Tree modification needs tree lock and tree root, which are located
>    in the address space, so store an address_space backpointer in the
>    node.  The parent pointer of the node is in a union with the 2-word
>    rcu_head, so the backpointer comes at no extra cost as well.
> 
> 4. The node needs to be linked to an LRU list, which requires a list
>    head inside the node.  This does increase the size of the node, but
>    it does not change the number of objects that fit into a slab page.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Mostly looks ok, though there is no need to expose the internals of
list_lru_add/del. The reason for the different return values was so
that the isolate callback could simply use list_del_init() and not
have to worry about all the internal accounting stuff. We can drop
the lock and then do the accounting after regaining it because it
won't result in the count of objects going negative and triggering
warnings.

Hence I think that all we need to do is add a new isolate return
value "LRU_REMOVED_RETRY" and add it to list_lru_walk_node() like
so:

 		switch (ret) {
+		case LRU_REMOVED_RETRY:
+			/*
+			 * object was removed from the list so we need to
+			 * account for it just like LRU_REMOVED hence the
+			 * fallthrough.  However, the list lock was also
+			 * dropped so we need to restart the list walk.
+			 */
 		case LRU_REMOVED:
 			if (--nlru->nr_items == 0)
 				node_clear(nid, lru->active_nodes);
 			WARN_ON_ONCE(nlru->nr_items < 0);
 			isolated++;
+			if (ret == LRU_REMOVED_RETRY)
+				goto restart;
 			break;

> +static unsigned long scan_shadow_nodes(struct shrinker *shrinker,
> +				       struct shrink_control *sc)
> +{
> +	unsigned long nr_reclaimed = 0;
> +
> +	list_lru_walk_node(&workingset_shadow_nodes, sc->nid,
> +			   shadow_lru_isolate, &nr_reclaimed, &sc->nr_to_scan);
> +
> +	return nr_reclaimed;
> +}

Do we need check against GFP_NOFS here? I don't think so, but I just
wanted to check...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
