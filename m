Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 0C99D6B0032
	for <linux-mm@kvack.org>; Sun, 21 Apr 2013 08:46:11 -0400 (EDT)
Received: by mail-we0-f178.google.com with SMTP id z53so5160840wey.37
        for <linux-mm@kvack.org>; Sun, 21 Apr 2013 05:46:10 -0700 (PDT)
Date: Sun, 21 Apr 2013 14:46:06 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: memcg: softlimit on internal nodes
Message-ID: <20130421124554.GA8473@dhcp22.suse.cz>
References: <20130420002620.GA17179@mtj.dyndns.org>
 <20130420031611.GA4695@dhcp22.suse.cz>
 <20130421022321.GE19097@mtj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130421022321.GE19097@mtj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>, Glauber Costa <glommer@parallels.com>, Michel Lespinasse <walken@google.com>, Greg Thelen <gthelen@google.com>

[I am terribly jet lagged so I should probably postpone any serious
thinking for few days but let me try]

On Sat 20-04-13 19:23:21, Tejun Heo wrote:
> Hello, Michal.
> 
> On Fri, Apr 19, 2013 at 08:16:11PM -0700, Michal Hocko wrote:
> > > For example, please consider the following hierarchy where s denotes
> > > the "softlimit" and h hardlimit.
> > > 
> > >       A (h:8G s:4G)
> > >      /            \
> > >     /              \
> > >  B (h:5G s:1G)    C (h:5G s:1G)
> ...
> > > It must not be any different for "softlimit".  If B or C are
> > > individually under 1G, they won't be targeted by the reclaimer and
> > > even if B and C are over 1G, let's say 2G, as long as the sum is under
> > > A's "softlimit" - 4G, reclaimer won't look at them. 
> > 
> > But we disagree on this one. If B and/or C are above their soft limit
> > we do (soft) reclaim them. It is exactly the same thing as if they were
> > hitting their hard limit (we just enforce the limit lazily).
> > 
> > You can look at the soft limit as a lazy limit which is enforced only if
> > there is an external pressure coming up the hierarchy - this can be
> > either global memory presure or a hard limit reached up the hierarchy.
> > Does this makes sense to you?
> 
> When flat, there's no confusion.  The problem is that what you
> describe makes the meaning of softlimit different for internal nodes
> and leaf nodes.

No inter and leaf nodes behave very same. Have a look at
mem_cgroup_soft_reclaim_eligible. All the confusion comes probably
from the understanding of the current semantic of what soft limit and
what it should do after my patch.
The current implementation stores all subtrees that are over the soft
limit in a tree sorted by how much they are excessing the limit. Have
a look at mem_cgroup_update_tree and its callers (namely down from
__mem_cgroup_commit_charge). My patch _preserves_ this behavior it just
makes the code much saner and as a bonus it doesn't touch groups (not
hierarchies) under the limit unless necessary which wasn't the case
previously.
So yes, I can understand why this is confusing for you. The soft limit
semantic is different because the limit is/was considered only if it
is/was in excess.

Maybe I was using word _guarantee_ too often to confuse you, I am sorry
if this is the case. The guarantee part comes from the group point of
view. So the original semantic of the hierarchical behavior is
unchanged.

What to does it mean that an inter node is under the soft limit
for the subhierarchy is questionable and there are usecases where
children groups might be under control of a different (even untrusted)
administrators (think about containers) so the implementation is not
straight forward. We certainly can do better than just reclaim everybody
but this is a subject to later improvements.

I will get to the rest of the email later.
[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
