Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 2971F6B0002
	for <linux-mm@kvack.org>; Tue, 23 Apr 2013 05:34:11 -0400 (EDT)
From: Michal Hocko <mhocko@suse.cz>
Subject: [RFC v2 0/4] soft limit rework
Date: Tue, 23 Apr 2013 11:33:55 +0200
Message-Id: <1366709639-10240-1-git-send-email-mhocko@suse.cz>
In-Reply-To: <20130422183020.GF12543@htj.dyndns.org>
References: <20130422183020.GF12543@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: cgroups@vger.kernel.org, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>, Glauber Costa <glommer@parallels.com>, Michel Lespinasse <walken@google.com>, Greg Thelen <gthelen@google.com>

This is the second version of the patchset. There were some minor
cleanups since the last version and I have moved "memcg: Ignore soft
limit until it is explicitly specified" to the end of the series as it
seems to be more controversial than I thought.

The basic idea is quite simple. Pull soft reclaim into shrink_zone in
the first step and get rid of the previous soft reclaim infrastructure.
shrink_zone is done in two passes now. First it tries to do the soft
limit reclaim and it falls back to reclaim-all-mode if no group is over
the limit or no pages have been scanned. The second pass happens at the
same priority so the only time we waste is the memcg tree walk which
shouldn't be a big deal [1]. There is certainly room for improvements in
that direction. But let's keep it simple for now.
As a bonus we will get rid of a _lot_ of code by this and soft reclaim
will not stand out like before. The clean up is in a separate patch because
I felt it would be easier to review that way.

The second step is soft limit reclaim integration into targeted
reclaim. It should be rather straight forward. Soft limit has been used
only for the global reclaim so far but it makes for any kind of pressure
coming from up-the-hierarchy, including targeted reclaim.

The last step is somehow more controversial as the discussions show. I
am redefining meaning of the default soft limit value. I've not chosen
0 as we discussed previously because I want to preserve hierarchical
property of the soft limit (if a parent up the hierarchy is over its
limit then children are over as well - same as with the hard limit) so
I have kept the default untouched - unlimited - but I have slightly
changed the meaning of this value. I interpret it as "user doesn't
care about soft limit". More precisely the value is ignored unless it
has been specified by admin/user so such groups are eligible for soft
reclaim even though they do not reach the limit. Such groups do not
force their children to be reclaimed so we can look at them as neutral
for the soft reclaim.

I will attach my testing results later on.

Shortlog says:
Michal Hocko (4):
      memcg: integrate soft reclaim tighter with zone shrinking code
      memcg: Get rid of soft-limit tree infrastructure
      vmscan, memcg: Do softlimit reclaim also for targeted reclaim
      memcg: Ignore soft limit until it is explicitly specified

And the diffstat:
 include/linux/memcontrol.h |   12 +-
 mm/memcontrol.c            |  438 +++++---------------------------------------
 mm/vmscan.c                |   62 ++++---
 3 files changed, 88 insertions(+), 424 deletions(-)

which sounds optimistic, doesn't it?

---
[1] I have tested this by creating a hierarchy 10 levels deep with
2 groups at each level - all of them below their soft limit and a
single group eligible for the reclaim running dd reading a lot of page
cache. The system time was withing stdev comparing to the previous
implementation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
