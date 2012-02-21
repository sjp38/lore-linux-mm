Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 796F86B00ED
	for <linux-mm@kvack.org>; Tue, 21 Feb 2012 18:03:29 -0500 (EST)
Received: by dadv6 with SMTP id v6so9060183dad.14
        for <linux-mm@kvack.org>; Tue, 21 Feb 2012 15:03:28 -0800 (PST)
Date: Tue, 21 Feb 2012 15:03:03 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 6/10] mm/memcg: take care over pc->mem_cgroup
In-Reply-To: <20120221181321.637556cd.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.LSU.2.00.1202211437140.2012@eggly.anvils>
References: <alpine.LSU.2.00.1202201518560.23274@eggly.anvils> <alpine.LSU.2.00.1202201533260.23274@eggly.anvils> <20120221181321.637556cd.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 21 Feb 2012, KAMEZAWA Hiroyuki wrote:
> On Mon, 20 Feb 2012 15:34:28 -0800 (PST)
> Hugh Dickins <hughd@google.com> wrote:
> 	return NULL;
> >  
> > +	lruvec = page_lock_lruvec(page);
> >  	lock_page_cgroup(pc);
> >  
> 
> Do we need to take lrulock+irq disable per page in this very very hot path ?

I'm sure we don't want to: I hope you were pleased to find it goes away
(from most cases) a couple of patches later.

I had lruvec lock nested inside page_cgroup lock in the rollup I sent in
December, whereas you went for page_cgroup lock nested inside lruvec lock
in your lrucare patch.

I couldn't find an imperative reason why they should be one way round or
the other, so I tried hard to stick with your ordering, and it did work
(in this 6/10).  But then I couldn't work out how to get rid of the
overheads added in doing it this way round, so swapped them back.

> 
> Hmm.... How about adding NR_ISOLATED counter into lruvec ?
> 
> Then, we can delay freeing lruvec until all conunters goes down to zero.
> as...
> 
> 	bool we_can_free_lruvec = true;
> 
> 	lock_lruvec(lruvec->lock);
> 	for_each_lru_lruvec(lru)
> 		if (!list_empty(&lruvec->lru[lru]))
> 			we_can_free_lruvec = false;
> 	if (lruvec->nr_isolated)
> 		we_can_free_lruvec = false;
> 	unlock_lruvec(lruvec)
> 	if (we_can_free_lruvec)
> 		kfree(lruvec);
> 
> If compaction, lumpy reclaim free a page taken from LRU,
> it knows what it does and can decrement lruvec->nr_isolated properly
> (it seems zone's NR_ISOLATED is decremented at putback.)

At the moment I'm thinking that what we end up with by 9/10 is
better than adding such a refcount.  But I'm not entirely happy with
mem_cgroup_reset_uncharged_to_root (it adds a further page_cgroup
lookup just after I got rid of some others), and need yet to think
about the race which Konstantin posits, so all options remain open.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
