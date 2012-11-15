Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id E8E246B00A9
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 03:51:28 -0500 (EST)
From: Wen Congyang <wency@cn.fujitsu.com>
Subject: [PART3 Patch v2 00/14] introduce N_MEMORY
Date: Thu, 15 Nov 2012 16:57:23 +0800
Message-Id: <1352969857-26623-1-git-send-email-wency@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org
Cc: Rob Landley <rob@landley.net>, Andrew Morton <akpm@linux-foundation.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Jiang Liu <jiang.liu@huawei.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Yinghai Lu <yinghai@kernel.org>, Rusty Russell <rusty@rustcorp.com.au>, Lin feng <linfeng@cn.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>

This patch is part3 of the following patchset:
    https://lkml.org/lkml/2012/10/29/319

Part1 is here:
    https://lkml.org/lkml/2012/10/31/30

Part2 is here:
    https://lkml.org/lkml/2012/10/31/73

Part4 is here:
    https://lkml.org/lkml/2012/10/31/129

Part5 is here:
    https://lkml.org/lkml/2012/10/31/145

Part6 is here:
    https://lkml.org/lkml/2012/10/31/248

You can apply this patchset without the other parts.

Note: part1 and part2 are in mm tree now. part5 are being reimplemented(We will
post it some days later).

We need a node which only contains movable memory. This feature is very
important for node hotplug. So we will add a new nodemask
for all memory. N_MEMORY contains movable memory but N_HIGH_MEMORY
doesn't contain it.

The meaning of N_MEMORY and N_HIGH_MEMORY nodemask:
1. N_HIGH_MEMORY: the node contains the memory that kernel can use. movable
   node aren't in this nodemask.
2. N_MEMORY: the node contains memory.

Why we intrdouce a new nodemask, not rename N_HIGH_MEMORY to N_MEMORY?

See the following two codes:
1.
==========================
static void *__meminit alloc_page_cgroup(size_t size, int nid)
{
	gfp_t flags = GFP_KERNEL | __GFP_ZERO | __GFP_NOWARN;
	void *addr = NULL;

	addr = alloc_pages_exact_nid(nid, size, flags);
	if (addr) {
		kmemleak_alloc(addr, size, 1, flags);
		return addr;
	}

	if (node_state(nid, N_HIGH_MEMORY))
		addr = vzalloc_node(size, nid);
	else
		addr = vzalloc(size);

	return addr;
}
==========================
If the node only has ZONE_MOVABLE memory, we should use vzalloc().
So we should have a mask that stores the node which has memory that
the kernel can use.

2.
==========================
static int mpol_set_nodemask(struct mempolicy *pol,
		     const nodemask_t *nodes, struct nodemask_scratch *nsc)
{
	int ret;

	/* if mode is MPOL_DEFAULT, pol is NULL. This is right. */
	if (pol == NULL)
		return 0;
	/* Check N_HIGH_MEMORY */
	nodes_and(nsc->mask1,
		  cpuset_current_mems_allowed, node_states[N_HIGH_MEMORY]);
...
		if (pol->flags & MPOL_F_RELATIVE_NODES)
			mpol_relative_nodemask(&nsc->mask2, nodes,&nsc->mask1);
		else
			nodes_and(nsc->mask2, *nodes, nsc->mask1);
...
}
==========================
If the user specifies 2 nodes: one has ZONE_MOVABLE memory, and the other one
doesn't. The cpuset for this task contains all nodes. nsc->mask2 should contain
these 2 nodes. So we should hava a mask that store the node which has memory,
and use this mask to calculate nsc->mask1.


The movable node will implemtent in part4. So N_MEMORY is equal to N_HIGH_MEMORY
now.

Changes from v1 to v2:
1. add your Signed-off-by, because I am on the the patch delivery path. Andrew
   Morton tells me this.
2. patch13: The newest kernel adds some codes which use N_HIGH_MEMORY. It shoule
   be N_MEMORY now.

Lai Jiangshan (14):
  node_states: introduce N_MEMORY
  cpuset: use N_MEMORY instead N_HIGH_MEMORY
  procfs: use N_MEMORY instead N_HIGH_MEMORY
  memcontrol: use N_MEMORY instead N_HIGH_MEMORY
  oom: use N_MEMORY instead N_HIGH_MEMORY
  mm,migrate: use N_MEMORY instead N_HIGH_MEMORY
  mempolicy: use N_MEMORY instead N_HIGH_MEMORY
  hugetlb: use N_MEMORY instead N_HIGH_MEMORY
  vmstat: use N_MEMORY instead N_HIGH_MEMORY
  kthread: use N_MEMORY instead N_HIGH_MEMORY
  init: use N_MEMORY instead N_HIGH_MEMORY
  vmscan: use N_MEMORY instead N_HIGH_MEMORY
  page_alloc: use N_MEMORY instead N_HIGH_MEMORY change the node_states
    initialization
  hotplug: update nodemasks management

 Documentation/cgroups/cpusets.txt |  2 +-
 Documentation/memory-hotplug.txt  |  5 ++-
 arch/x86/mm/init_64.c             |  4 +-
 drivers/base/node.c               |  2 +-
 fs/proc/kcore.c                   |  2 +-
 fs/proc/task_mmu.c                |  4 +-
 include/linux/cpuset.h            |  2 +-
 include/linux/memory.h            |  1 +
 include/linux/nodemask.h          |  1 +
 init/main.c                       |  2 +-
 kernel/cpuset.c                   | 32 +++++++-------
 kernel/kthread.c                  |  2 +-
 mm/hugetlb.c                      | 24 +++++------
 mm/memcontrol.c                   | 18 ++++----
 mm/memory_hotplug.c               | 87 ++++++++++++++++++++++++++++++++-------
 mm/mempolicy.c                    | 12 +++---
 mm/migrate.c                      |  2 +-
 mm/oom_kill.c                     |  2 +-
 mm/page_alloc.c                   | 42 ++++++++++---------
 mm/page_cgroup.c                  |  2 +-
 mm/vmscan.c                       |  4 +-
 mm/vmstat.c                       |  4 +-
 22 files changed, 162 insertions(+), 94 deletions(-)

-- 
1.8.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
