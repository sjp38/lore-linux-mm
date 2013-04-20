Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 3DFC76B0002
	for <linux-mm@kvack.org>; Fri, 19 Apr 2013 20:26:28 -0400 (EDT)
Received: by mail-ia0-f175.google.com with SMTP id e16so3949789iaa.34
        for <linux-mm@kvack.org>; Fri, 19 Apr 2013 17:26:27 -0700 (PDT)
Date: Fri, 19 Apr 2013 17:26:20 -0700
From: Tejun Heo <tj@kernel.org>
Subject: memcg: softlimit on internal nodes
Message-ID: <20130420002620.GA17179@mtj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>, Glauber Costa <glommer@parallels.com>, Michel Lespinasse <walken@google.com>, Greg Thelen <gthelen@google.com>

Hello, Michal and all.

Sorry about asking silly questions and leaving in the middle.  I had a
plane to catch which I just barely made.  I thought about it on the
way here and your proposal seems confused.

I think the crux of the confusion comes from the fact that you're
essentially proposing flipping the meaning of the knob for internal
nodes - it means minmum guaranteed allocation - that is, the shrinker
won't bother the cgroup if the memory consumption is under the
softlimit - and your proposal is to reverse that for cgroups with
children so that it actually means "soft" limit - creating pressure if
above the limit (IIUC, it isn't entirely that either as the pressure
is created iff the whole system is under memory pressure, right?).

Regardless of the direction of a configuration, a parent cgroup should
gate that configuration in the same direction.  ie. If it's a limit
for a leaf node when reached, it also is an limit for the whole
subtree for an internal cgroup.  If it's a configuration which
guarantees allocation (in the sense that it'll be excluded in memory
reclaim if under limit), the same, if the subtree is under limit,
reclaim shouldn't trigger.

For example, please consider the following hierarchy where s denotes
the "softlimit" and h hardlimit.

      A (h:8G s:4G)
     /            \
    /              \
 B (h:5G s:1G)    C (h:5G s:1G)

For hard limit, nobody seems confused how the internal limit should
apply - If either B or C goes over 5G, the one going over that limit
will be on the receiving end of OOM killer.  Also, even if both B and
C are individually under 5G, if the sum of the two goes over A's limit
- 8G, OOM killer will be activated on the subtree.  It'd be a policy
decision whether to kill tasks from A, B or C, but the no matter what
the parent's limit will be enforced in the subtree.  Note that this is
a perfectly valid configuration.  It is *not* an invalid
configuration.  It is exactly what the hierarchical configuration is
supposed to do.

It must not be any different for "softlimit".  If B or C are
individually under 1G, they won't be targeted by the reclaimer and
even if B and C are over 1G, let's say 2G, as long as the sum is under
A's "softlimit" - 4G, reclaimer won't look at them.  It is exactly the
same as hardlimit, just the opposite direction.

Now, let's consider the following hierarchy just to be sure.  Let's
assume that A itself doesn't have any tasks for simplicity.

      A (h:16G s:4G)
     /            \
    /              \
 B (h:7G s:5G)    C (h:7G s:5G)

For hardlimit, it is clear that A's limit won't do anything.  No
matter what B and C do.  In exactly the same way, A's "softlimit"
doesn't do anything regardless of what B and C do.  Just like A's
hardlimit doesn't impose any further restrictions on B and C, A's
softlimit doesn't give any further guarantee to B and C.  There's no
difference at all.

Now, it's completely silly that "softlimit" is actually allocation
guarantee rather than an actual limit.  I guess it's born out of
similar confusion?  Maybe originally the operation was a confused mix
of the two and it moved closer to guaranteeing behavior over time?

Anyways, it's apparent why actual soft limit - that is something which
creates reclaim pressure even when the system as whole isn't under
memory pressure - would be useful, and I'm actually kinda surprised
that it doesn't already exist.  It isn't difficult to imagine use
cases where the user doesn't want certain services/applications (say
backup, torrent or static http server serving large files) to not
consume huge amount of memory without triggering OOM killer.  It is
something which is fundamentally useful and I think is why people are
confused and pulling the current "softlimit" towards something like
that.

If such actual soft limit is desired (I don't know, it just seems like
a very fundamental / logical feature to me), please don't try to
somehow overload "softlimit".  They are two fundamentally different
knobs, both make sense in their own ways, and when you stop confusing
the two, there's nothing ambiguous about what what each knob means in
hierarchical situations.  This goes the same for the "untrusted" flag
Ying told me, which seems like another confused way to overload two
meanings onto "softlimit".  Don't overload!

Now let's see if this gogo thing actually works.

Thanks.

--
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
