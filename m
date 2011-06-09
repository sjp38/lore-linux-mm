Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id BF3BF6B0078
	for <linux-mm@kvack.org>; Thu,  9 Jun 2011 12:58:19 -0400 (EDT)
Date: Thu, 9 Jun 2011 18:57:48 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 2/8] mm: memcg-aware global reclaim
Message-ID: <20110609165748.GA20333@cmpxchg.org>
References: <1306909519-7286-1-git-send-email-hannes@cmpxchg.org>
 <1306909519-7286-3-git-send-email-hannes@cmpxchg.org>
 <20110607122519.GA18571@infradead.org>
 <20110608093046.GB17886@cmpxchg.org>
 <20110609092617.GB10741@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110609092617.GB10741@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Jun 09, 2011 at 05:26:17AM -0400, Christoph Hellwig wrote:
> On Wed, Jun 08, 2011 at 11:30:46AM +0200, Johannes Weiner wrote:
> > On Tue, Jun 07, 2011 at 08:25:19AM -0400, Christoph Hellwig wrote:
> > > A few small nitpicks:
> > > 
> > > > +struct mem_cgroup *mem_cgroup_hierarchy_walk(struct mem_cgroup *root,
> > > > +					     struct mem_cgroup *prev)
> > > > +{
> > > > +	struct mem_cgroup *mem;
> > > > +
> > > > +	if (mem_cgroup_disabled())
> > > > +		return NULL;
> > > > +
> > > > +	if (!root)
> > > > +		root = root_mem_cgroup;
> > > > +	/*
> > > > +	 * Even without hierarchy explicitely enabled in the root
> > > > +	 * memcg, it is the ultimate parent of all memcgs.
> > > > +	 */
> > > > +	if (!(root == root_mem_cgroup || root->use_hierarchy))
> > > > +		return root;
> > > 
> > > The logic here reads a bit weird, why not simply:
> > > 
> > > 	 /*
> > > 	  * Even without hierarchy explicitely enabled in the root
> > > 	  * memcg, it is the ultimate parent of all memcgs.
> > > 	  */
> > > 	if (!root || root == root_mem_cgroup)
> > > 		return root_mem_cgroup;
> > > 	if (root->use_hierarchy)
> > > 		return root;
> > 
> > What you are proposing is not equivalent, so... case in point!  It's
> > meant to do the hierarchy walk for when foo->use_hierarchy, obviously,
> > but ALSO for root_mem_cgroup, which is parent to everyone else even
> > without use_hierarchy set.  I changed it to read like this:
> > 
> > 	if (!root)
> > 		root = root_mem_cgroup;
> > 	if (!root->use_hierarchy && root != root_mem_cgroup)
> > 		return root;
> > 	/* actually iterate hierarchy */
> > 
> > Does that make more sense?
> 
> It does, sorry for misparsing it.  The thing that I really hated was
> the conditional assignment of root.  Can we clean this up somehow
> by making the caller pass root_mem_cgroup in the case where it
> passes root right now, or at least always pass NULL when it means
> root_mem_cgroup.
> 
> Note really that important in the end, it just irked me when I looked
> over it, especially the conditional assigned of root to root_mem_cgroup,
> and then a little later checking for the equality of the two.

Yeah, the assignment is an ugly interface fixup because
root_mem_cgroup is local to memcontrol.c, as is struct mem_cgroup as a
whole.

I'll look into your suggestion from the other mail of making struct
mem_cgroup and struct mem_cgroup_per_zone always available, and have
everyone operate against root_mem_cgroup per default.

> Thinking about it it's probably better left as-is for now to not
> complicate the series, and maybe revisit it later once things have
> settled a bit.

I may take you up on that if this approach turns out to require more
change than is sensible to add to this series.

I'll at least add an

     /* XXX: until vmscan.c knows about root_mem_cgroup */

or so, if this is the case, to explain the temporary nastiness.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
