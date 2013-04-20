Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id DA9DF6B0002
	for <linux-mm@kvack.org>; Fri, 19 Apr 2013 23:16:19 -0400 (EDT)
Date: Fri, 19 Apr 2013 20:16:11 -0700
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: memcg: softlimit on internal nodes
Message-ID: <20130420031611.GA4695@dhcp22.suse.cz>
References: <20130420002620.GA17179@mtj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130420002620.GA17179@mtj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>, Glauber Costa <glommer@parallels.com>, Michel Lespinasse <walken@google.com>, Greg Thelen <gthelen@google.com>

On Fri 19-04-13 17:26:20, Tejun Heo wrote:
> Hello, Michal and all.
> 
> Sorry about asking silly questions and leaving in the middle.  I had a
> plane to catch which I just barely made.  I thought about it on the
> way here and your proposal seems confused.
> 
> I think the crux of the confusion comes from the fact that you're
> essentially proposing flipping the meaning of the knob for internal
> nodes - it means minmum guaranteed allocation - that is, the shrinker
> won't bother the cgroup if the memory consumption is under the
> softlimit - and your proposal is to reverse that for cgroups with
> children so that it actually means "soft" limit - creating pressure if
> above the limit (IIUC, it isn't entirely that either as the pressure
> is created iff the whole system is under memory pressure, right?).

No, one of the patches changes that and put the soft reclaim to the hard
reclaim path as well - basically try to reclaim over-soft limit groups
first and do not both others if you can make your target. Please refer
to the patchset for details
(http://comments.gmane.org/gmane.linux.kernel.mm/97973)

> Regardless of the direction of a configuration, a parent cgroup should
> gate that configuration in the same direction.  ie. If it's a limit
> for a leaf node when reached, it also is an limit for the whole
> subtree for an internal cgroup.

Agreed and that is exactly what I was saying and what the code does.

> If it's a configuration which guarantees allocation (in the sense that
> it'll be excluded in memory reclaim if under limit), the same, if the
> subtree is under limit, reclaim shouldn't trigger.
> 
> For example, please consider the following hierarchy where s denotes
> the "softlimit" and h hardlimit.
> 
>       A (h:8G s:4G)
>      /            \
>     /              \
>  B (h:5G s:1G)    C (h:5G s:1G)
> 
> For hard limit, nobody seems confused how the internal limit should
> apply - If either B or C goes over 5G, the one going over that limit
> will be on the receiving end of OOM killer.

Right

> Also, even if both B and C are individually under 5G, if the sum of
> the two goes over A's limit - 8G, OOM killer will be activated on the
> subtree.  It'd be a policy decision whether to kill tasks from A, B or
> C, but the no matter what the parent's limit will be enforced in the
> subtree.  Note that this is a perfectly valid configuration.

Agreed.

> It is *not* an invalid configuration.  It is exactly what the
> hierarchical configuration is supposed to do.
> 
> It must not be any different for "softlimit".  If B or C are
> individually under 1G, they won't be targeted by the reclaimer and
> even if B and C are over 1G, let's say 2G, as long as the sum is under
> A's "softlimit" - 4G, reclaimer won't look at them. 

But we disagree on this one. If B and/or C are above their soft limit
we do (soft) reclaim them. It is exactly the same thing as if they were
hitting their hard limit (we just enforce the limit lazily).

You can look at the soft limit as a lazy limit which is enforced only if
there is an external pressure coming up the hierarchy - this can be
either global memory presure or a hard limit reached up the hierarchy.
Does this makes sense to you?

> It is exactly the same as hardlimit, just the opposite direction.
> 
> Now, let's consider the following hierarchy just to be sure.  Let's
> assume that A itself doesn't have any tasks for simplicity.
> 
>       A (h:16G s:4G)
>      /            \
>     /              \
>  B (h:7G s:5G)    C (h:7G s:5G)
> 
> For hardlimit, it is clear that A's limit won't do anything.

It _does_ if A has tasks which add pressure to B+C. Or even if you do
not have any tasks because A might hold some reparented pages from
groups which are gone now.

> No matter what B and C do.  In exactly the same way, A's "softlimit"
> doesn't do anything regardless of what B and C do.

And same here.

> Just like A's hardlimit doesn't impose any further restrictions on B
> and C, A's softlimit doesn't give any further guarantee to B and C.
> There's no difference at all.

If A hits its hard limit then we reclaim that subtree so we _can_ and
_do_ reclaim also from B and C. This is what the current code does and
soft reclaim doesn't change that at all. The only thing it changes is
that it tries to save groups bellow the limit from reclaiming.

> Now, it's completely silly that "softlimit" is actually allocation
> guarantee rather than an actual limit.  I guess it's born out of
> similar confusion?  Maybe originally the operation was a confused mix
> of the two and it moved closer to guaranteeing behavior over time?

I wouldn't call it silly. It actually makes a lot of sense if you look
at it as a delayed limit which would allow you to allocate more if there
is not any outside memory pressure.

> Anyways, it's apparent why actual soft limit - that is something which
> creates reclaim pressure even when the system as whole isn't under
> memory pressure - would be useful, and I'm actually kinda surprised
> that it doesn't already exist.  It isn't difficult to imagine use
> cases where the user doesn't want certain services/applications (say
> backup, torrent or static http server serving large files) to not
> consume huge amount of memory without triggering OOM killer.  It is
> something which is fundamentally useful and I think is why people are
> confused and pulling the current "softlimit" towards something like
> that.

Actually the use case is this. Say you have an important workload which
shouldn't be influenced by other less important workloads (say backup
for simplicity). You set up a soft limit for your important load to
match its average working set. The backup doesn't need any hard limit
and soft limit set to 0 because a) you do not know how much it would
need and b) you like to make run as fast as possible. Check what happens
now. Backup uses all the remaining memory until the global reclaims
starts. The global reclaim will start reclaiming the backup or even
your important workload if it consumed more than its soft limit (say
after a peak load). As far as you can reclaim from the backup enough to
satisfy the global memory pressure you do not have to hit the important
workload. Sounds like a huge win to me!

You can even look at the soft limit as to an "intelligent" mlock which
keeps the memory "locked" as far as you can keep handling the external
memory pressure. This is new with this new re-implementation because the
original code uses soft limit only as a hint who to reclaim first but
doesn't consider it any further.

> If such actual soft limit is desired (I don't know, it just seems like
> a very fundamental / logical feature to me), please don't try to
> somehow overload "softlimit".  They are two fundamentally different
> knobs, both make sense in their own ways, and when you stop confusing
> the two, there's nothing ambiguous about what what each knob means in
> hierarchical situations.  This goes the same for the "untrusted" flag
> Ying told me, which seems like another confused way to overload two
> meanings onto "softlimit".  Don't overload!
> 
> Now let's see if this gogo thing actually works.
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
