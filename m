Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id AF46D6B0082
	for <linux-mm@kvack.org>; Fri, 29 May 2015 07:57:39 -0400 (EDT)
Received: by wivl4 with SMTP id l4so14967392wiv.1
        for <linux-mm@kvack.org>; Fri, 29 May 2015 04:57:39 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id dm2si3186959wib.6.2015.05.29.04.57.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 29 May 2015 04:57:37 -0700 (PDT)
From: Michal Hocko <mhocko@suse.cz>
Subject: [RFC 0/7 -v2] memcg cleanups + get rid of mm_struct::owner
Date: Fri, 29 May 2015 13:57:18 +0200
Message-Id: <1432900645-8856-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, Greg Thelen <gthelen@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Hi,
this is the second version of the RFC. The previous version was posted
here: http://marc.info/?l=linux-mm&m=143264102317318&w=2. It has grown
the number of patches based on the previous feedback.

Johannes has suggested to export struct mem_cgroup because some other
things will become easier. So even though this is not directly related
to the patchset I have posted it together because there are some
dependencies. First two patches are doing this move.

The third patch simply cleans up some extern declarations in memcontrol.h
because we are not consistent in that regard.

The fourth patch is the same one from Tejun which cleans up
mem_cgroup_can_attach a bit and the follow up patches depend on it.

The fifth patch is preparatory and it's touching sock_update_memcg which
doesn't check for cg_proto == NULL. It doesn't have to do it currently
because mem_cgroup_from_task always return non-NULL but the code is awkward
and this will no longer be true with the follow up patch.

All these can go without the rest IMO.

The patch number 6 is the core one and it gets rid of mm_struct::owner
in favor of mm_struct::memcg. The rationale is described in the patch
so I will not repeat it here again. The changes since the last post
are
	- added Suggested-by Oleg has it was him who kicked me into doing
	  it
	- exec_mmap association was missing [Oleg]
	- mem_cgroup_from_task cannot return NULL anymore [Oleg]
        - mm_match_cgroup doesn't have to play games and it can use
          rcu_dereference after mm_struct is exported [Johannes]
	- drop mm_move_memcg as it has only one user in memcontrol.c
	  so it can be opencoded [Johannes]
	- functions to associate and drop mm->memcg association have
	  to be static inline for !CONFIG_MEMCG [Johannes]
	- drop synchronize_rcu nonsense during memcg move [Johannes]
	- drop "memcg: Use mc.moving_task as the indication for charge
	  moving" patch because we can get the target task from css
	  easily [Johannes]
	- rename css_set_memcg renamed to css_inherit_memcg because the
	  name better suits its usage
	- dropped css_get(&from->css) during move because it is pinned
	  already by the mm. We just have to be careful and do not drop
	  it before we are really done during migration.

I have tried to compile test this with my usual configs battery +
randconfigs and nothing blown up.

I have also runtime tested that charges end up in a proper memcg
and migration between two memcgs as fast as possible. Except for
pre-existing races no regressions seemed to be introduced.

I was worried about the user visible change this patch introduces but
Johannes seems to be OK with that. The changelog states that a potential
usecase is not really worth all the troubles the implementation exposes
to the memcg behavior. I am still posting this as an RFC so that we give
more time to others.

The last patch gets rid of mem_cgroup_from_task because this is a really
weird interface (see more in the changelog). After mm->owner is gone
we have only 2 more callers remaining and both of them can be changed
to not use it. So better get rid of this before we get new callers.

Shortlog says:
Michal Hocko (6):
      memcg: export struct mem_cgroup
      memcg: get rid of extern for functions in memcontrol.h
      memcg, mm: move mem_cgroup_select_victim_node into vmscan
      memcg, tcp_kmem: check for cg_proto in sock_update_memcg
      memcg: get rid of mm_struct::owner
      memcg: get rid of mem_cgroup_from_task

Tejun Heo (1):
      memcg: restructure mem_cgroup_can_attach()

And diffstat looks promissing as well.
 fs/exec.c                  |   2 +-
 include/linux/memcontrol.h | 437 +++++++++++++++++++++++++++++++++----
 include/linux/mm_types.h   |  12 +-
 include/linux/swap.h       |  10 +-
 include/net/sock.h         |  28 ---
 kernel/exit.c              |  89 --------
 kernel/fork.c              |  10 +-
 mm/debug.c                 |   4 +-
 mm/memcontrol.c            | 527 ++++++---------------------------------------
 mm/memory-failure.c        |   2 +-
 mm/slab_common.c           |   2 +-
 mm/vmscan.c                |  96 +++++++++
 12 files changed, 577 insertions(+), 642 deletions(-)

Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
