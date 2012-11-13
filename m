Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id F07B26B0092
	for <linux-mm@kvack.org>; Tue, 13 Nov 2012 10:31:18 -0500 (EST)
From: Michal Hocko <mhocko@suse.cz>
Subject: [RFC] rework mem_cgroup iterator
Date: Tue, 13 Nov 2012 16:30:34 +0100
Message-Id: <1352820639-13521-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>, Tejun Heo <htejun@gmail.com>, Glauber Costa <glommer@parallels.com>

Hi all,
this patch set tries to make mem_cgroup_iter saner in the way how it
walks hierarchies. css->id based traversal is far from being ideal as it
is not deterministic because it depends on the creation ordering.

Diffstat looks promising but it is fair the say that the biggest cleanup is
just css_get_next removal. The memcg code has grown a bit but I think it is
worth the resulting outcome (the sanity ;)).

The first patch fixes a potential misbehaving which I haven't seen but the
fix is needed for the later patches anyway. We could take it alone as well
but I do not have any bug report to base the fix on.

The second patch replaces css_get_next by cgroup iterators which are
scheduled for 3.8 in Tejun's tree and I depend on the following two patches:
fe1e904c cgroup: implement generic child / descendant walk macros
7e187c6c cgroup: use rculist ops for cgroup->children

The third patch is an attempt for simplification of the mem_cgroup_iter. It
basically removes all css usages to make the code easier. The next patch
removes the big while(!memcg) loop around the iterating logic. It could have
been folded into #3 but I rather have the rework separate from the code
moving noise.

The last patch just removes css_get_next as there is no user for it any
longer.

I am also thinking that leaf-to-root iteration makes more sense but this
patch is not included in the series yet because I have to think some
more about the justification.

So far I didn't get to testing but I am posting this early if everybody is
OK with this change.

Any thoughts?

Cumulative diffstat:
 include/linux/cgroup.h |    7 ---
 kernel/cgroup.c        |   49 ---------------------
 mm/memcontrol.c        |  110 +++++++++++++++++++++++++++++++++---------------
 3 files changed, 75 insertions(+), 91 deletions(-)

Michal Hocko (5):
      memcg: synchronize per-zone iterator access by a spinlock
      memcg: rework mem_cgroup_iter to use cgroup iterators
      memcg: simplify mem_cgroup_iter
      memcg: clean up mem_cgroup_iter
      cgroup: remove css_get_next

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
