Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id C9B126B0033
	for <linux-mm@kvack.org>; Mon, 22 Apr 2013 11:19:11 -0400 (EDT)
Date: Mon, 22 Apr 2013 17:19:08 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: memcg: softlimit on internal nodes
Message-ID: <20130422151908.GF18286@dhcp22.suse.cz>
References: <20130420002620.GA17179@mtj.dyndns.org>
 <20130420031611.GA4695@dhcp22.suse.cz>
 <20130421022321.GE19097@mtj.dyndns.org>
 <20130421124554.GA8473@dhcp22.suse.cz>
 <20130422043939.GB25089@mtj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130422043939.GB25089@mtj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>, Glauber Costa <glommer@parallels.com>, Michel Lespinasse <walken@google.com>, Greg Thelen <gthelen@google.com>

On Sun 21-04-13 21:39:39, Tejun Heo wrote:
> Hey, Michal.
> 
> On Sun, Apr 21, 2013 at 02:46:06PM +0200, Michal Hocko wrote:
> > [I am terribly jet lagged so I should probably postpone any serious
> > thinking for few days but let me try]
> 
> Sorry about raising a flame war so soon after the conference week.
> None of these is really urgent, so please take your time.
> 
> > The current implementation stores all subtrees that are over the soft
> > limit in a tree sorted by how much they are excessing the limit. Have
> > a look at mem_cgroup_update_tree and its callers (namely down from
> > __mem_cgroup_commit_charge). My patch _preserves_ this behavior it just
> > makes the code much saner and as a bonus it doesn't touch groups (not
> > hierarchies) under the limit unless necessary which wasn't the case
> > previously.
> 
> What you describe is already confused.  What does that knob mean then?

Well, it would help to start with Documentation/cgroups/memory.txt
"
7. Soft limits

Soft limits allow for greater sharing of memory. The idea behind soft
limits is to allow control groups to use as much of the memory as
needed, provided

a. There is no memory contention
b. They do not exceed their hard limit

When the system detects memory contention or low memory, control groups
are pushed back to their soft limits. If the soft limit of each control
group is very high, they are pushed back as much as possible to make
sure that one control group does not starve the others of memory.

Please note that soft limits is a best-effort feature; it comes with
no guarantees, but it does its best to make sure that when memory is
heavily contended for, memory is allocated based on the soft limit
hints/setup. Currently soft limit based reclaim is set up such that
it gets invoked from balance_pgdat (kswapd).
"

As you can see there no single mention about groups below their soft
limits. All we are saying here is that those groups that are above will
get reclaimed.

> Google folks seem to think it's an allocation guarantee but global
> reclaim is broken and breaches the configuration (which I suppose is
> arising from their usage of memcg) and I don't understand what your
> definition of the knob is apart from the description of what's
> implemented now, which apparently is causing horrible confusion on all
> the involved parties.

OK, I guess I start understanding where all the confusion comes from.
Let me stress again that the rework doesn't provide any guarantee. It
just integrates the soft limit reclaim into the main reclaim routines,
gets rid of a lot of code and last but not least makes a greater chance
that under-the-soft limit groups are not reclaimed unless really
necessary.

So please take these into consideration for the future discussions.

> > So yes, I can understand why this is confusing for you. The soft limit
> > semantic is different because the limit is/was considered only if it
> > is/was in excess.
> > 
> > Maybe I was using word _guarantee_ too often to confuse you, I am sorry
> > if this is the case. The guarantee part comes from the group point of
> > view. So the original semantic of the hierarchical behavior is
> > unchanged.
> 
> I don't care what word you use.  There are two choices.  Pick one and
> stick with it.  Don't make it something which inhibits reclaim if
> under limit for leaf nodes but behaves somewhat differently if an
> ancestor is under pressure or whatever.  Just pick one.  It is either
> an reclaim inhibitor or actual soft limit.

OK, I will not repeat the same mistake and let this frustrating
discussion going on to "let's redo the soft limit reclaim again #1001"
point again. No this is not about guarantee. And _never_ will be! Full
stop.
We can try to be clever during the outside pressure and prefer
reclaiming over soft limit groups first. Which we used to do and will
do after rework as well. As a side effect of that a properly designed
hierachy with opt-in soft limited groups can actually accomplish some
isolation is a nice side effect but no _guarantee_.

> > What to does it mean that an inter node is under the soft limit
> > for the subhierarchy is questionable and there are usecases where
> 
> It's not frigging questionable.  You're just horribly confused.
> 
> Thanks.
> 
> -- 
> tejun

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
