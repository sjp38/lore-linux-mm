Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 2DF4A6B0027
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 08:13:33 -0400 (EDT)
From: Michal Hocko <mhocko@suse.cz>
Subject: [RFC 0/3] soft reclaim rework
Date: Tue,  9 Apr 2013 14:13:12 +0200
Message-Id: <1365509595-665-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Ying Han <yinghan@google.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Glauber Costa <glommer@parallels.com>

Hi all,
It's been a long when I promised my take on the $subject but I got
permanently preempted by other tasks. I finally got it, fortunately.

This is just a first attempt. There are still some todos but I wanted to
post it soon to get a feedback.

The basic idea is quite simple. Pull soft reclaim into shrink_zone in
the first step and get rid of the previous soft reclaim infrastructure.
shrink_zone is done in two passes now. First it tries to do the soft
limit reclaim and it falls back to reclaim-all-mode if no group is over
the limit or no pages have been scanned. The second pass happens at the
same priority so the only time we waste is the memcg tree walk which
shouldn't be a big deal. There is certainly room for improvements in
that direction. But let's keep it simple for now.
As a bonus we will get rid of a _lot_ of code by this and soft reclaim
will not stand out like before.
The second step is somehow more controversial. I am redefining meaning
of the default soft limit value. I've not chosen 0 as we discussed
previously because I want to preserve hierarchical property of the soft
limit (if a parent up the hierarchy is over its limit then children are
over as well) so I have kept the default untouched - unlimited - but I
have slightly changed the meaning of this value. I interpret it as "user
doesn't care about soft limit". More precisely the value is ignored
unless it has been specified by user so such groups are eligible for
soft reclaim even though they do not reach the limit. Such groups
do not force their children to be reclaimed of course.
I guess the only possible use case where this wouldn't work as
expected is when somebody creates a group and set its soft limit to
a small value (e.g. 0) just to protect all other groups from being
reclaimed. With a new scheme all groups would be reclaimed while the
previous implementation could end up reclaiming only the "special"
group. This configuration can be achieved by the new scheme trivially
so I think we should be safe. Or does this sound like a big problem?
Finally the third step is soft limit reclaim integration into targeted
reclaim. The patch is trivial one liner.

I haven't get to test it properly yet. I've tested only 2 workloads:
1) 1GB RAM + 128MB swap in a kvm (host 4 GB RAM)
   - 2 memcgs (directly under root)
   	- A has soft limit 500MB and hard unlimited
	- B both hard and soft unlimited (default values)
   - One dd if=/dev/zero of=storage/$file bs=1024 count=1228800 per group
2) same setup
   - tar -xf linux source tree + make -j2 vmlinux

Results
1) I've checked memory.usage_in_bytes
Base (-mm tree)
	Group A		Group B	
median	446498816	448659456

Patches applied
median	524314624	377921536

So as expected, A got more room on behalf of B and it is nicely over its
soft limit. I wanted to compare the reclaim performance as well but we
do not account scanned and reclaimed pages during the old soft reclaim
(global_reclaim prevents that). But I am planning to look at it.
Anyway it doesn't look like we are scanning/reclaiming more with the
patched kernel:
Base: 	 pgscan_kswapd_dma32 394382	pgsteal_kswapd_dma32 394372
Patched: pgscan_kswapd_dma32 394501	pgsteal_kswapd_dma32 394491

So I would assume that the soft limit reclaim scanned more in the end.

Total runtime was slightly smaller for the patch version:
Base
		Group A		Group B
total time	480.087 s	480.067 s

Patches applied
total time	474.853 s	474.736 s

But this could be an artifacts of the guest scheduling or related to the
host activity so I wouldn't draw any conclusions from here.

2) kbuild test showed more or less the same results
usage_in_bytes
Base
		Group A		Group B
Median		394817536	395634688

Patches applied
median		483481600	302131200

A is kept closer to the soft limit again. There is some fluctuation
around the limit because kbuild creates a lot of short lived processes.
Base: 	 pgscan_kswapd_dma32 1648718	pgsteal_kswapd_dma32 1510749
Patched: pgscan_kswapd_dma32 2042065	pgsteal_kswapd_dma32 1667745

The differences are much bigger now so it would be interesting how much
has been scanned/reclaimed during soft reclaim in the base kernel.

I haven't included total runtime statistics here because they seemed
even more random due to guest/host interaction.

Any comments are welcome, of course.

Michal Hocko (3):
      memcg: integrate soft reclaim tighter with zone shrinking code
      memcg: Ignore soft limit until it is explicitly specified
      vmscan, memcg: Do softlimit reclaim also for targeted reclaim

Incomplete diffstat (without node-zone soft limit tree removal etc...)
so more deletions to come.
 include/linux/memcontrol.h |   10 +--
 mm/memcontrol.c            |  175 +++++++++-----------------------------------
 mm/vmscan.c                |   67 ++++++++++-------
 3 files changed, 78 insertions(+), 174 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
