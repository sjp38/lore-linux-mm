Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 568AC6B0006
	for <linux-mm@kvack.org>; Fri, 18 Jan 2013 03:08:30 -0500 (EST)
Date: Fri, 18 Jan 2013 19:08:25 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 09/19] list_lru: per-node list infrastructure
Message-ID: <20130118080825.GP2498@dastard>
References: <1354058086-27937-1-git-send-email-david@fromorbit.com>
 <1354058086-27937-10-git-send-email-david@fromorbit.com>
 <50F6FDC8.5020909@parallels.com>
 <20130116225521.GF2498@dastard>
 <50F7475F.90609@parallels.com>
 <20130117042245.GG2498@dastard>
 <50F84118.7030608@parallels.com>
 <20130118001029.GK2498@dastard>
 <50F89C77.4010101@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50F89C77.4010101@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, xfs@oss.sgi.com, Greg Thelen <gthelen@google.com>, Ying Han <yinghan@google.com>, Suleiman Souhlal <suleiman@google.com>

On Thu, Jan 17, 2013 at 04:51:03PM -0800, Glauber Costa wrote:
> On 01/17/2013 04:10 PM, Dave Chinner wrote:
> > and we end up with:
> > 
> > lru_add(struct lru_list *lru, struct lru_item *item)
> > {
> > 	node_id = min(object_to_nid(item), lru->numnodes);
> > 	
> > 	__lru_add(lru, node_id, &item->global_list);
> > 	if (memcg) {
> > 		memcg_lru = find_memcg_lru(lru->memcg_lists, memcg_id)
> > 		__lru_add_(memcg_lru, node_id, &item->memcg_list);
> > 	}
> > }
> 
> A follow up thought: If we have multiple memcgs, and global pressure
> kicks in (meaning none of them are particularly under pressure),
> shouldn't we try to maintain fairness among them and reclaim equal
> proportions from them all the same way we do with sb's these days, for
> instance?

I don't like the complexity. The global lists will be reclaimed in
LRU order, so it's going to be as fair as can be. If there's a memcg
that has older unused objectsi than the others, then froma global
perspective they should be reclaimed first because the memcg is not
using them...

> I would argue that if your memcg is small, the list of dentries is
> small: scan it all for the nodes you want shouldn't hurt.

on the contrary - the memcg might be small, but what happens if
someone ran a find across all the filesytsems on the system in it?
Then the LRU will be huge, and scanning expensive...

We can't make static decisions about small and large, and we can't
trust heuristics to get it right, either. If we have a single list,
we don't/can't do node-aware reclaim efficiently and so shouldn't
even try.

> if the memcg is big, it will have per-node lists anyway.

But may have no need for them due to the workload. ;)

> Given that, do we really want to pay the price of two list_heads
> in the objects?

I'm just looking at ways at making the infrastructure sane. If the
cost is an extra 16 bytes per object on a an LRU, then that a small
price to pay for having robust memory reclaim infrastructure....

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
