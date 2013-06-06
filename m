Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id B393C6B0031
	for <linux-mm@kvack.org>; Thu,  6 Jun 2013 12:48:17 -0400 (EDT)
Date: Thu, 6 Jun 2013 09:48:01 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v10 11/35] list_lru: per-node list infrastructure
Message-Id: <20130606094801.8a259edf.akpm@linux-foundation.org>
In-Reply-To: <51B0B58B.50203@parallels.com>
References: <1370287804-3481-1-git-send-email-glommer@openvz.org>
	<1370287804-3481-12-git-send-email-glommer@openvz.org>
	<20130605160804.be25fb655f075efe70ec57c0@linux-foundation.org>
	<51B0B58B.50203@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Glauber Costa <glommer@openvz.org>, linux-fsdevel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, hughd@google.com, Greg Thelen <gthelen@google.com>, Dave Chinner <dchinner@redhat.com>

On Thu, 6 Jun 2013 20:15:07 +0400 Glauber Costa <glommer@parallels.com> wrote:

> On 06/06/2013 03:08 AM, Andrew Morton wrote:
> >> +	for_each_node_mask(nid, lru->active_nodes) {
> >> > +		struct list_lru_node *nlru = &lru->node[nid];
> >> > +
> >> > +		spin_lock(&nlru->lock);
> >> > +		BUG_ON(nlru->nr_items < 0);
> > This is buggy.
> > 
> > The bit in lru->active_nodes could be cleared by now.  We can only make
> > this assertion if we recheck lru->active_nodes[nid] inside the
> > spinlocked region.
> > 
> Sorry Andrew, how so ?
> We will clear that flag if nr_items == 0. nr_items should *never* get to
> be less than 0, it doesn't matter if the node is cleared or not.
> 
> If the node is cleared, we would expected the following statement to
> expand to
>    count += nlru->nr_items = 0;
>    spin_unlock(&nlru->lock);
> 
> Which is actually cheaper than testing for the bit being still set.

Well OK - I didn't actually look at the expression the BUG_ON() was
testing.  You got lucky ;)

My point was that nlru->lock protects ->active_nodes and so the above
code is racy due to a locking error.  I now see that was incorrect -
active_nodes has no locking.

Well, it kinda has accidental locking - nrlu->lock happens to protect
this nrlu's bit in active_nodes while permitting other nrlu's bits to
concurrently change.


The bottom line is that code which does

	if (node_isset(n, active_nodes))
		use(n);

can end up using a node which is no longer in the active_nodes, because
there is no locking.  This is a bit weird and worrisome and might lead
to bugs in the future, at least.  Perhaps we can improve the
maintainability by documenting this at the active_nodes site, dunno.

This code gets changed a lot in later patches and I didn't check to see
if the problem remains in the final product.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
