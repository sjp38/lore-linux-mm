Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 778246B0078
	for <linux-mm@kvack.org>; Thu,  9 Jun 2011 05:26:31 -0400 (EDT)
Date: Thu, 9 Jun 2011 05:26:17 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [patch 2/8] mm: memcg-aware global reclaim
Message-ID: <20110609092617.GB10741@infradead.org>
References: <1306909519-7286-1-git-send-email-hannes@cmpxchg.org>
 <1306909519-7286-3-git-send-email-hannes@cmpxchg.org>
 <20110607122519.GA18571@infradead.org>
 <20110608093046.GB17886@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110608093046.GB17886@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Jun 08, 2011 at 11:30:46AM +0200, Johannes Weiner wrote:
> On Tue, Jun 07, 2011 at 08:25:19AM -0400, Christoph Hellwig wrote:
> > A few small nitpicks:
> > 
> > > +struct mem_cgroup *mem_cgroup_hierarchy_walk(struct mem_cgroup *root,
> > > +					     struct mem_cgroup *prev)
> > > +{
> > > +	struct mem_cgroup *mem;
> > > +
> > > +	if (mem_cgroup_disabled())
> > > +		return NULL;
> > > +
> > > +	if (!root)
> > > +		root = root_mem_cgroup;
> > > +	/*
> > > +	 * Even without hierarchy explicitely enabled in the root
> > > +	 * memcg, it is the ultimate parent of all memcgs.
> > > +	 */
> > > +	if (!(root == root_mem_cgroup || root->use_hierarchy))
> > > +		return root;
> > 
> > The logic here reads a bit weird, why not simply:
> > 
> > 	 /*
> > 	  * Even without hierarchy explicitely enabled in the root
> > 	  * memcg, it is the ultimate parent of all memcgs.
> > 	  */
> > 	if (!root || root == root_mem_cgroup)
> > 		return root_mem_cgroup;
> > 	if (root->use_hierarchy)
> > 		return root;
> 
> What you are proposing is not equivalent, so... case in point!  It's
> meant to do the hierarchy walk for when foo->use_hierarchy, obviously,
> but ALSO for root_mem_cgroup, which is parent to everyone else even
> without use_hierarchy set.  I changed it to read like this:
> 
> 	if (!root)
> 		root = root_mem_cgroup;
> 	if (!root->use_hierarchy && root != root_mem_cgroup)
> 		return root;
> 	/* actually iterate hierarchy */
> 
> Does that make more sense?

It does, sorry for misparsing it.  The thing that I really hated was
the conditional assignment of root.  Can we clean this up somehow
by making the caller pass root_mem_cgroup in the case where it
passes root right now, or at least always pass NULL when it means
root_mem_cgroup.

Note really that important in the end, it just irked me when I looked
over it, especially the conditional assigned of root to root_mem_cgroup,
and then a little later checking for the equality of the two.

Thinking about it it's probably better left as-is for now to not
complicate the series, and maybe revisit it later once things have
settled a bit.

> > It actually is the per-memcg shrinker now, and thus should be called
> > shrink_memcg.
> 
> Per-zone per-memcg, actually.  shrink_zone_memcg?

Sounds fine to me.

> I have gcc version 4.6.0 20110530 (Red Hat 4.6.0-9) (GCC) on this
> machine, and it manages to optimize the loop away completely.

Ok, good enough.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
