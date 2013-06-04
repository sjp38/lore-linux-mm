Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 5E74F6B0031
	for <linux-mm@kvack.org>; Tue,  4 Jun 2013 09:45:27 -0400 (EDT)
Date: Tue, 4 Jun 2013 15:45:23 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch -v4 4/8] memcg: enhance memcg iterator to support
 predicates
Message-ID: <20130604134523.GH31242@dhcp22.suse.cz>
References: <1370254735-13012-1-git-send-email-mhocko@suse.cz>
 <1370254735-13012-5-git-send-email-mhocko@suse.cz>
 <20130604010737.GF29989@mtj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130604010737.GF29989@mtj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>, Glauber Costa <glommer@parallels.com>, Michel Lespinasse <walken@google.com>, Greg Thelen <gthelen@google.com>, Balbir Singh <bsingharora@gmail.com>

On Mon 03-06-13 18:07:37, Tejun Heo wrote:
> On Mon, Jun 03, 2013 at 12:18:51PM +0200, Michal Hocko wrote:
> > The caller of the iterator might know that some nodes or even subtrees
> > should be skipped but there is no way to tell iterators about that so
> > the only choice left is to let iterators to visit each node and do the
> > selection outside of the iterating code. This, however, doesn't scale
> > well with hierarchies with many groups where only few groups are
> > interesting.
> > 
> > This patch adds mem_cgroup_iter_cond variant of the iterator with a
> > callback which gets called for every visited node. There are three
> > possible ways how the callback can influence the walk. Either the node
> > is visited, it is skipped but the tree walk continues down the tree or
> > the whole subtree of the current group is skipped.
> > 
> > TODO is it correct to reclaim + cond together? What if the cache simply
> > skips interesting nodes which another predicate would find interesting?
> 
> I don't know.  Maybe it's just taste but it looks pretty ugly to me.
> Why does everything have to be folded into the iteration function?

There are basically 2 options. Factor out skipping logic into something
like memcg_cgroup_iter_skip_node and memcg_cgroup_iter_skip_tree or
bundle the generic predicate into iterators.
I find the in-iterator version more convenient to use because the caller
doesn't have to handle skip cases explicitly. All the users would have
to do the same thing (which is now hidden in the iterator) anyway.

Besides that it helps reducing the memcg code in vmscan (which we try to
keep at minimum). I already feel guilty for the code this patch set
adds.

Is this something that you find serious enough to block this series?
I do not want to push hard but I would like to settle with something
finally. This is taking way longer than I would like.

> The iteration only depends on the current position.  Can't you factor
> out skipping part outside the function rather than rolling into this
> monstery thing with predicate callback?  Just test the condition
> outside and call a function to skip whatever is necessary?
> 
> Also, cgroup_rightmost_descendant() can be pretty expensive depending
> on how your tree looks like. 

I have no problem using something else. This was just the easiest to
use and it behaves more-or-less good for hierarchies which are more or
less balanced. If this turns out to be a problem we can introduce a
new cgroup_skip_subtree which would get to last->sibling or go up the
parent chain until there is non-NULL sibling. But what would be the next
selling point here if we made it perfect right now? ;)

> It travels to the rightmost child at
> each level until it can't.  In extreme cases, you can travel the whole
> subtree.  This usually isn't a problem for its usecases but yours may
> be different, I'm not sure.

But that would be the case only if the hierarchy would be right wing
prevailing (aka politically incorrect for some :P)
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
