Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id AFB126B0034
	for <linux-mm@kvack.org>; Mon, 13 May 2013 03:46:30 -0400 (EDT)
From: Michal Hocko <mhocko@suse.cz>
Subject: [patch v3 0/3 -mm] Soft limit rework
Date: Mon, 13 May 2013 09:46:09 +0200
Message-Id: <1368431172-6844-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>, Glauber Costa <glommer@parallels.com>, Michel Lespinasse <walken@google.com>, Greg Thelen <gthelen@google.com>, Tejun Heo <tj@kernel.org>, Balbir Singh <bsingharora@gmail.com>

Hi,

This is the third version of the patchset. 
The first version has been posted here: http://permalink.gmane.org/gmane.linux.kernel.mm/97973
(lkml wasn't CCed at the time so I cannot find it in lwn.net
archives). There were no major objections. The second version
has been posted here http://lwn.net/Articles/548191/ as a part
of a longer and spicier thread which started after LSF here:
https://lwn.net/Articles/548192/
So this is a back to trees repost which tries to get only the guts from
the original post.

Changes between RFC (aka V1) -> V2
As there were no major objections there were only some minor cleanups
since the last version and I have moved "memcg: Ignore soft limit until
it is explicitly specified" to the end of the series.

Changes between V2 -> V3
No changes in the code since the last version. I have just rebased the
series on top of the current mmotm tree. The most controversial part
has been dropped (the last patch "memcg: Ignore soft limit until it is
explicitly specified") so there are no semantical changes to the soft
limit behavior. This makes this work mostly a code clean up and code
reorganization. Nevertheless, this is enough to make the soft limit work
more efficiently according to my testing and groups above the soft limit
are reclaimed much less as a result.

The basic idea is quite simple. Pull soft reclaim into shrink_zone in
the first step and get rid of the previous soft reclaim infrastructure.
shrink_zone is done in two passes now. First it tries to do the soft
limit reclaim and it falls back to reclaim-all-mode if no group is over
the limit or no pages have been scanned. The second pass happens at the
same priority so the only time we waste is the memcg tree walk which
shouldn't be a big deal [1]. There is certainly room for improvements
in that direction (e.g. do not do soft reclaim pass if no limit has
been specified for any group yet or if we know that no group is bellow
the limit). But let's keep it simple for now.  As a bonus we will get
rid of a _lot_ of code by this and soft reclaim will not stand out like
before. The clean up is in a separate patch because I felt it would be
easier to review that way.

The second step is soft limit reclaim integration into targeted
reclaim. It should be rather straight forward. Soft limit has been used
only for the global reclaim so far but it makes for any kind of pressure
coming from up-the-hierarchy, including targeted reclaim.

My primary test case was a parallel kernel (each make is run with -j4
with a distribution .config in a separate cgroup without any hard
limit) build on a 8 CPU machine booted with 1GB memory.  I was mostly
interested in 2 setups. Default - no soft limit set and - and 0 soft
limit set to both groups.
The first one should tell us whether the rework regresses the default
behavior while the second one should show us improvements in an extreme
case where both workloads are always over the soft limit.

/usr/bin/time -v has been used to collect the statistics and each
configuration had 3 runs after fresh boot without any other load on the
system.

* No-limit
Base kernel (before)
System:	min:238.26	max:240.87	avg:239.85	stdev:0.90
User:	min:1166.40	max:1173.79	avg:1169.92	stdev:2.41
Elapsed: min:09:38.06	max:09:57.96	avg:09:48.80	stdev:00:07.14


Rework (after)
System:	min:238.88[100.3%]	max:242.43[100.6%]	avg:240.70[100.4%]	stdev:1.62
User:	min:1168.61[100.2%]	max:1171.15[99.8%]	avg:1169.69[100%]	stdev:0.82
Elapsed: min:09:31.85[98.9%]	max:09:57.74[100.0%]	avg:09:47.57[99.8%]	stdev:00:09.54	

The numbers are within stdev so I think we are doing good here.

* 0-limit
Base kernel (before)
System:	min:244.74	max:248.66	avg:246.39	stdev:1.20
User:	min:1190.51	max:1195.70	avg:1193.77	stdev:1.66
Elapsed: min:12:39.73	max:12:56.79	avg:12:48.33	stdev:00:06.59

Rework (after)
System:	min:238.64[97.5%]	max:242.34[97.5%]	avg:240.67[97.7%]	stdev:1.26
User:	min:1166.20[98%]	max:1170.98[98%]	avg:1168.17[97.9%]	stdev:1.44
Elapsed: min:09:47.53[77.3%]	max:09:59.05[77.1%]	avg:09:53.23[77.2%]	stdev:00:04.72

We can see 2% time decrease for both System and User time which is not
rocket high but sounds like a good outcome from a cleanup ;). It is even
more interesting to check the Elapsed time numbers which show that the
parallel load is much more effective. I haven't looked into the specific
reasons for this boost up deeply but I would guess that priority-0
reclaim done in the original implementation should be a big contributor.

Page fault statistics tell us at least part of the story:
Base
Major min:29686		max:34224	avg:31028.67	stdev:1503.11
Minor min:35919443	max:35980518	avg:35945936.50	stdev:21340.41

Rework
Major min:332[1.1%]	max:883[2.6%]		avg:478.67[1.5%]	stdev:187.46
Minor min:35583644[99%]	max:35660073[99%]	avg:35621868.67[99%]	stdev:29240.64

While the minor faults are within the noise the major faults are reduced
considerably. This looks like an aggressive pageout during the reclaim
and that pageout affects the working set presumably.  If we look at the
same numbers for no-limit (aka no soft limit in action) we get very
similar numbers to 0-limit rework:
Base
Major min:208.00 max:454.00, avg:375.17 stdev:86.73

Rework
Major min:270.00 max:730.00, avg:431.67 stdev:143.58

So this clearly points at the priority-0 reclaim.

Shortlog says:
Michal Hocko (3):
      memcg: integrate soft reclaim tighter with zone shrinking code
      memcg: Get rid of soft-limit tree infrastructure
      vmscan, memcg: Do softlimit reclaim also for targeted reclaim

And the diffstat:
 include/linux/memcontrol.h |   12 +-
 mm/memcontrol.c            |  387 +++-----------------------------------------
 mm/vmscan.c                |   62 ++++---
 3 files changed, 65 insertions(+), 396 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
