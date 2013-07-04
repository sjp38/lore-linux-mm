Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 10F836B0036
	for <linux-mm@kvack.org>; Thu,  4 Jul 2013 12:36:46 -0400 (EDT)
Date: Thu, 4 Jul 2013 18:36:43 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: linux-next: slab shrinkers: BUG at mm/list_lru.c:92
Message-ID: <20130704163643.GF7833@dhcp22.suse.cz>
References: <20130627145411.GA24206@dhcp22.suse.cz>
 <20130629025509.GG9047@dastard>
 <20130630183349.GA23731@dhcp22.suse.cz>
 <20130701012558.GB27780@dastard>
 <20130701075005.GA28765@dhcp22.suse.cz>
 <20130701081056.GA4072@dastard>
 <20130702092200.GB16815@dhcp22.suse.cz>
 <20130702121947.GE14996@dastard>
 <20130702124427.GG16815@dhcp22.suse.cz>
 <20130703112403.GP14996@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130703112403.GP14996@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Glauber Costa <glommer@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed 03-07-13 21:24:03, Dave Chinner wrote:
> On Tue, Jul 02, 2013 at 02:44:27PM +0200, Michal Hocko wrote:
> > On Tue 02-07-13 22:19:47, Dave Chinner wrote:
> > [...]
> > > Ok, so it's been leaked from a dispose list somehow. Thanks for the
> > > info, Michal, it's time to go look at the code....
> > 
> > OK, just in case we will need it, I am keeping the machine in this state
> > for now. So we still can play with crash and check all the juicy
> > internals.
> 
> My current suspect is the LRU_RETRY code. I don't think what it is
> doing is at all valid - list_for_each_safe() is not safe if you drop
> the lock that protects the list. i.e. there is nothing that protects
> the stored next pointer from being removed from the list by someone
> else. Hence what I think is occurring is this:
> 
> 
> thread 1			thread 2
> lock(lru)
> list_for_each_safe(lru)		lock(lru)
>   isolate			......
>     lock(i_lock)
>     has buffers
>       __iget
>       unlock(i_lock)
>       unlock(lru)
>       .....			(gets lru lock)
>       				list_for_each_safe(lru)
> 				  walks all the inodes
> 				  finds inode being isolated by other thread
> 				  isolate
> 				    i_count > 0
> 				      list_del_init(i_lru)
> 				      return LRU_REMOVED;
> 				   moves to next inode, inode that
> 				   other thread has stored as next
> 				   isolate
> 				     i_state |= I_FREEING
> 				     list_move(dispose_list)
> 				     return LRU_REMOVED
> 				 ....
> 				 unlock(lru)
>       lock(lru)
>       return LRU_RETRY;
>   if (!first_pass)
>     ....
>   --nr_to_scan
>   (loop again using next, which has already been removed from the
>   LRU by the other thread!)
>   isolate
>     lock(i_lock)
>     if (i_state & ~I_REFERENCED)
>       list_del_init(i_lru)	<<<<< inode is on dispose list!
> 				<<<<< inode is now isolated, with I_FREEING set
>       return LRU_REMOVED;
> 
> That fits the corpse left on your machine, Michal. One thread has
> moved the inode to a dispose list, the other thread thinks it is
> still on the LRU and should be removed, and removes it.
> 
> This also explains the lru item count going negative - the same item
> is being removed from the lru twice. So it seems like all the
> problems you've been seeing are caused by this one problem....
> 
> Patch below that should fix this.

Good news! The test was running since morning and it didn't hang nor
crashed. So this really looks like the right fix. It will run also
during weekend to be 100% sure. But I guess it is safe to say

Tested-by: Michal Hocko <mhocko@suse.cz>

Thanks a lot Dave!

> 
> Cheers,
> 
> Dave.
> -- 
> Dave Chinner
> david@fromorbit.com
> 
> list_lru: fix broken LRU_RETRY behaviour
> 
> From: Dave Chinner <dchinner@redhat.com>
> 
> The LRU_RETRY code assumes that the list traversal status after we
> have dropped and regained the list lock. Unfortunately, this is not
> a valid assumption, and that can lead to racing traversals isolating
> objects that the other traversal expects to be the next item on the
> list.
> 
> This is causing problems with the inode cache shrinker isolation,
> with races resulting in an inode on a dispose list being "isolated"
> because a racing traversal still thinks it is on the LRU. The inode
> is then never reclaimed and that causes hangs if a subsequent lookup
> on that inode occurs.
> 
> Fix it by always restarting the list walk on a LRU_RETRY return from
> the isolate callback. Avoid the possibility of livelocks the current
> code was trying to aavoid by always decrementing the nr_to_walk
> counter on retries so that even if we keep hitting the same item on
> the list we'll eventually stop trying to walk and exit out of the
> situation causing the problem.
> 
> Reported-by: Michal Hocko <mhocko@suse.cz>
> Signed-off-by: Dave Chinner <dchinner@redhat.com>
> ---
>  mm/list_lru.c |   29 ++++++++++++-----------------
>  1 file changed, 12 insertions(+), 17 deletions(-)
> 
> diff --git a/mm/list_lru.c b/mm/list_lru.c
> index dc71659..7246791 100644
> --- a/mm/list_lru.c
> +++ b/mm/list_lru.c
> @@ -71,19 +71,19 @@ list_lru_walk_node(struct list_lru *lru, int nid, list_lru_walk_cb isolate,
>  	struct list_lru_node	*nlru = &lru->node[nid];
>  	struct list_head *item, *n;
>  	unsigned long isolated = 0;
> -	/*
> -	 * If we don't keep state of at which pass we are, we can loop at
> -	 * LRU_RETRY, since we have no guarantees that the caller will be able
> -	 * to do something other than retry on the next pass. We handle this by
> -	 * allowing at most one retry per object. This should not be altered
> -	 * by any condition other than LRU_RETRY.
> -	 */
> -	bool first_pass = true;
>  
>  	spin_lock(&nlru->lock);
>  restart:
>  	list_for_each_safe(item, n, &nlru->list) {
>  		enum lru_status ret;
> +
> +		/*
> +		 * decrement nr_to_walk first so that we don't livelock if we
> +		 * get stuck on large numbesr of LRU_RETRY items
> +		 */
> +		if (--(*nr_to_walk) == 0)
> +			break;
> +
>  		ret = isolate(item, &nlru->lock, cb_arg);
>  		switch (ret) {
>  		case LRU_REMOVED:
> @@ -98,19 +98,14 @@ restart:
>  		case LRU_SKIP:
>  			break;
>  		case LRU_RETRY:
> -			if (!first_pass) {
> -				first_pass = true;
> -				break;
> -			}
> -			first_pass = false;
> +			/*
> +			 * The lru lock has been dropped, our list traversal is
> +			 * now invalid and so we have to restart from scratch.
> +			 */
>  			goto restart;
>  		default:
>  			BUG();
>  		}
> -
> -		if ((*nr_to_walk)-- == 0)
> -			break;
> -
>  	}
>  
>  	spin_unlock(&nlru->lock);

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
