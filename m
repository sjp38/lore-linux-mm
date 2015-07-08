From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 0/8 -v3] memcg cleanups + get rid of mm_struct::owner
Date: Wed,  8 Jul 2015 14:27:44 +0200
Message-ID: <1436358472-29137-1-git-send-email-mhocko@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, Greg Thelen <gthelen@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

Hi,
this is the third version of the patch series. The previous version was posted
here: http://marc.info/?l=linux-mm&m=143290066126282 and the first version
here: http://marc.info/?l=linux-mm&m=143264102317318&w=2.

Johannes has suggested to export struct mem_cgroup because some other
things will become easier. So even though this is not directly related
to the patchset I have posted it together because there are some
dependencies.

The first patch exports struct mem_cgroup along with its dependencies +
some simple accessor functions so they can be inlined in the code.

The second patch is a minor cleanup for cgroup writeback code which hasn't
been present in the previous version.

The third patch simply cleans up some extern declarations in memcontrol.h
because we are not consistent in that regard.

The fourth patch moves some more memcg code to vmscan as it doesn't have any
other users.

The fifth patch is from Tejun and it cleans up mem_cgroup_can_attach a
bit and the follow up patches depend on it.

The sixth patch is preparatory and it's touching sock_update_memcg which
doesn't check for cg_proto == NULL. It doesn't have to do it currently
because mem_cgroup_from_task always return non-NULL but the code is awkward
and this will no longer be true with the follow up patch.

The patch number 7 is the core one and it gets rid of mm_struct::owner
in favor of mm_struct::memcg. The rationale is described in the patch
so I will not repeat it here again.

The last patch gets rid of mem_cgroup_from_task which is not needed anymore.

I have tried to compile test this with my usual configs battery +
randconfigs and nothing blown up. I have also runtime tested migration
between two memcgs as fast as possible. Except for pre-existing races no
regressions seemed to be introduced.

I was worried about the user visible change this patch introduces
but Johannes and Tejun seem to be OK with that and nobody complained
since this was posted last time as an RFC. The changelog states
that a potential usecase is not really worth all the troubles the
implementation exposes to the memcg behavior.

changes since v2
	- rebased on top of the current mmotm tree
	- clenaup mem_cgroup_root_css
changes since v1
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

Shortlog says:
Michal Hocko (7):
      memcg: export struct mem_cgroup
      memcg: get rid of mem_cgroup_root_css for !CONFIG_MEMCG
      memcg: get rid of extern for functions in memcontrol.h
      memcg, mm: move mem_cgroup_select_victim_node into vmscan
      memcg, tcp_kmem: check for cg_proto in sock_update_memcg
      memcg: get rid of mm_struct::owner
      memcg: get rid of mem_cgroup_from_task

Tejun Heo (1):
      memcg: restructure mem_cgroup_can_attach()

And diffstat looks promissing as well.
 fs/exec.c                  |   2 +-
 include/linux/memcontrol.h | 439 +++++++++++++++++++++++++++++++++----
 include/linux/mm_types.h   |  12 +-
 include/linux/swap.h       |  10 +-
 include/net/sock.h         |  28 ---
 kernel/exit.c              |  89 --------
 kernel/fork.c              |  10 +-
 mm/debug.c                 |   4 +-
 mm/memcontrol.c            | 527 ++++++---------------------------------------
 mm/memory-failure.c        |   2 +-
 mm/slab_common.c           |   2 +-
 mm/vmscan.c                |  98 ++++++++-
 12 files changed, 579 insertions(+), 644 deletions(-)

Thanks
