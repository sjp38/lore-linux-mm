Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 806EB6B0034
	for <linux-mm@kvack.org>; Wed,  5 Jun 2013 23:51:38 -0400 (EDT)
Date: Wed, 5 Jun 2013 20:51:23 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v10 11/35] list_lru: per-node list infrastructure
Message-Id: <20130605205123.7be6a0fe.akpm@linux-foundation.org>
In-Reply-To: <20130606032107.GQ29338@dastard>
References: <1370287804-3481-1-git-send-email-glommer@openvz.org>
	<1370287804-3481-12-git-send-email-glommer@openvz.org>
	<20130605160804.be25fb655f075efe70ec57c0@linux-foundation.org>
	<20130606032107.GQ29338@dastard>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Glauber Costa <glommer@openvz.org>, linux-fsdevel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, hughd@google.com, Greg Thelen <gthelen@google.com>, Dave Chinner <dchinner@redhat.com>

On Thu, 6 Jun 2013 13:21:07 +1000 Dave Chinner <david@fromorbit.com> wrote:

> > > +struct list_lru {
> > > +	/*
> > > +	 * Because we use a fixed-size array, this struct can be very big if
> > > +	 * MAX_NUMNODES is big. If this becomes a problem this is fixable by
> > > +	 * turning this into a pointer and dynamically allocating this to
> > > +	 * nr_node_ids. This quantity is firwmare-provided, and still would
> > > +	 * provide room for all nodes at the cost of a pointer lookup and an
> > > +	 * extra allocation. Because that allocation will most likely come from
> > > +	 * a different slab cache than the main structure holding this
> > > +	 * structure, we may very well fail.
> > > +	 */
> > > +	struct list_lru_node	node[MAX_NUMNODES];
> > > +	nodemask_t		active_nodes;
> > 
> > Some documentation of the data structure would be helpful.  It appears
> > that active_nodes tracks (ie: duplicates) node[x].nr_items!=0.
> > 
> > It's unclear that active_nodes is really needed - we could just iterate
> > across all items in list_lru.node[].  Are we sure that the correct
> > tradeoff decision was made here?
> 
> Yup. Think of all the cache line misses that checking
> node[x].nr_items != 0 entails. If MAX_NUMNODES = 1024, there's 1024
> cacheline misses right there. The nodemask is a much more cache
> friendly method of storing active node state.

Well, it depends on the relative frequency of list-wide walking.  If
that's "very low" then the cost of maintaining active_nodes could
dominate.

Plus all the callsites which traverse active_nodes will touch
list_lru.node[n] anyway, so the cache-miss impact will be unaltered.

> not to mention that for small machines with a large MAX_NUMNODES,
> we'd be checking nodes that never have items stored on them...

Yes, there is that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
