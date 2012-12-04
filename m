Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 04BD16B0044
	for <linux-mm@kvack.org>; Tue,  4 Dec 2012 03:45:47 -0500 (EST)
Date: Tue, 4 Dec 2012 09:45:44 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 4/4] memcg: replace cgroup_lock with memcg specific
 memcg_lock
Message-ID: <20121204084544.GC31319@dhcp22.suse.cz>
References: <1354282286-32278-1-git-send-email-glommer@parallels.com>
 <1354282286-32278-5-git-send-email-glommer@parallels.com>
 <20121203171532.GG17093@dhcp22.suse.cz>
 <50BDAD38.6030200@parallels.com>
 <20121204082316.GB31319@dhcp22.suse.cz>
 <50BDB4E3.4040107@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50BDB4E3.4040107@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>

On Tue 04-12-12 12:31:31, Glauber Costa wrote:
> On 12/04/2012 12:23 PM, Michal Hocko wrote:
> > On Tue 04-12-12 11:58:48, Glauber Costa wrote:
> >> On 12/03/2012 09:15 PM, Michal Hocko wrote:
> >>> On Fri 30-11-12 17:31:26, Glauber Costa wrote:
> >>> [...]
> >>>> +/*
> >>>> + * must be called with memcg_lock held, unless the cgroup is guaranteed to be
> >>>> + * already dead (like in mem_cgroup_force_empty, for instance).
> >>>> + */
> >>>> +static inline bool memcg_has_children(struct mem_cgroup *memcg)
> >>>> +{
> >>>> +	return mem_cgroup_count_children(memcg) != 1;
> >>>> +}
> >>>
> >>> Why not just keep list_empty(&cgrp->children) which is much simpler much
> >>> more effective and correct here as well because cgroup cannot vanish
> >>> while we are at the call because all callers come from cgroup fs?
> >>>
> >> Because it depends on cgroup's internal representation, which I think
> >> we're better off not depending upon, even if this is not as serious a
> >> case as the locking stuff. But also, technically, cgrp->children is
> >> protected by the cgroup_lock(), while since we'll hold the memcg_lock
> >> during creation and also around the iterators, we cover everything with
> >> the same lock.
> > 
> > The list is RCU safe so we do not have to use cgroup_lock there for this
> > kind of test.
> > 
> >> That said, of course we don't need to do the full iteration here, and
> >> mem_cgroup_count_children is indeed overkill. We could just as easily
> >> verify if any child exist - it is just an emptiness test after all. But
> >> it is not living in any fast path, though, and I just assumed code reuse
> >> to win over efficiency in this particular case -
> >> mem_cgroup_count_children already existed...
> > 
> > Yes but the function name suggests a more generic usage and the test is
> > really an overkill. Maybe we can get a cgroup generic helper
> > cgroup_as_children which would do the thing without exhibiting cgroup
> > internals. What do you think?
> > 
> I will give it another round of thinking, but I still don't see the
> reason for calling to cgroup core with this. 

Because such a helper might be useful in general? I didn't check if
somebody does the same test elsewhere though.

> If you really dislike doing a children count (I don't like as well, I
> just don't dislike), maybe we can do something like:
> 
> i = 0;
> for_each_mem_cgroup_tree(iter, memcg) {
> 	if (i++ == 1)
> 		return false;
> }
> return true;

I guess you meant:
i = 0;
for_each_mem_cgroup_tree(iter, memcg) {
	if (i++ == 1) {
		mem_cgroup_iter_break(iter);
		break;
	}
}
return i > 1;

which is still much more work than necessary. Not that this would be a
killer thing it just hit my eyes. I think the easiest thing would be to
not fold this change into this patch and do it as a separate patch if
there is a real reason for it - e.g. cgroup core would like to give us a
helper or they tell us _do_not_missuse_our_internals_.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
