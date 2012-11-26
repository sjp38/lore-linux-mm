Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id E53ED6B0073
	for <linux-mm@kvack.org>; Mon, 26 Nov 2012 13:48:12 -0500 (EST)
From: Michal Hocko <mhocko@suse.cz>
Subject: rework mem_cgroup iterator
Date: Mon, 26 Nov 2012 19:47:45 +0100
Message-Id: <1353955671-14385-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>, Tejun Heo <htejun@gmail.com>, Glauber Costa <glommer@parallels.com>, Li Zefan <lizefan@huawei.com>

Hi all,
this is a second version of the patchset previously posted here:
https://lkml.org/lkml/2012/11/13/335

The patch set tries to make mem_cgroup_iter saner in the way how it
walks hierarchies. css->id based traversal is far from being ideal as it
is not deterministic because it depends on the creation ordering.

Diffstat looks promising but it is fair the say that the biggest cleanup is
just css_get_next removal. The memcg code has grown a bit but I think it is
worth the resulting outcome (the sanity ;)).

The first patch fixes a potential misbehaving which I haven't seen but the
fix is needed for the later patches anyway. We could take it alone as well
but I do not have any bug report to base the fix on. The second one is also
preparatory and it is new to the series.

The third patch replaces css_get_next by cgroup iterators which are
scheduled for 3.8 in Tejun's tree and I depend on the following two patches:
fe1e904c cgroup: implement generic child / descendant walk macros
7e187c6c cgroup: use rculist ops for cgroup->children

The third and fourth patches are an attempt for simplification of the
mem_cgroup_iter. css juggling is removed and the iteration logic is
moved to a helper so that the reference counting and iteration are
separated.

The last patch just removes css_get_next as there is no user for it any
longer.

I am also thinking that leaf-to-root iteration makes more sense but this
patch is not included in the series yet because I have to think some
more about the justification.

I have dropped "[RFC 4/5] memcg: clean up mem_cgroup_iter"
(https://lkml.org/lkml/2012/11/13/333) because testing quickly shown
that my thinking was flawed and VM_BUG_ON(!prev && !memcg) triggered
very quickly. This also suggest that this version has seen some testing,
unlike the previous one ;)
The test was simple but I guess it exercised this code path quite heavily.
        A (limit = 280M, use_hierarchy=true)
      / | \
     B  C  D (all have 100M limit)

and independent kernel build (with the full distribution config) in
all children groups. This triggers both children only and hierarchical
reclaims.

The shortlog says:
Michal Hocko (6):
      memcg: synchronize per-zone iterator access by a spinlock
      memcg: keep prev's css alive for the whole mem_cgroup_iter
      memcg: rework mem_cgroup_iter to use cgroup iterators
      memcg: simplify mem_cgroup_iter
      memcg: further simplify mem_cgroup_iter
      cgroup: remove css_get_next

And diffstat:
 include/linux/cgroup.h |    7 ---
 kernel/cgroup.c        |   49 ---------------------
 mm/memcontrol.c        |  110 +++++++++++++++++++++++++++++++++++++-----------
 3 files changed, 86 insertions(+), 80 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
