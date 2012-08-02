From: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [RFC PATCH 00/23 V2] memory,
	numa: introduce MOVABLE-dedicated node and online_movable for hotplug
Date: Thu, 2 Aug 2012 10:52:48 +0800
Message-ID: <1343875991-7533-1-git-send-email-laijs@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Mel Gorman <mel-wPRd99KPJ+uzQB+pC5nmwQ@public.gmane.org>
Cc: Christoph Lameter <cl-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>, Dan Magenheimer <dan.magenheimer-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, Paul Gortmaker <paul.gortmaker-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org>, Konstantin Khlebnikov <khlebnikov-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, Sam Ravnborg <sam-uyr5N9Q2VtJg9hUCZPvPmw@public.gmane.org>, Gavin Shan <shangw-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Rik van Riel <riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, Hugh Dickins <hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Mel Gorman <mgorman-l3A5Bk7waGM@public.gmane.org>, KOSAKI Motohiro <kosaki.motohiro-+CUm20s59erQFUHtdCDX3A@public.gmane.org>, David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Petr Holasek <pholasek-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Wanlong Gao <gaowanlong-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>, Djalal Harouni <tixxdz-Umm1ozX2/EEdnm+yROfE0A@public.gmane.org>, Rusty Russell <rusty-8n+1lVoiYb80n/F98K4Iww@public.gmane.org>, Wen Congyang <wency-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>, Peter Zijlstra <a.p.zijlstra@ch>
List-Id: linux-mm.kvack.org

	A) Introduction:

This patchset adds MOVABLE-dedicated node and online_movable for memory-management.

It is used for anti-fragmentation(hugepage, big-order allocation...),
hot-removal-of-memory(virtualization, power-conserve, move memory between systems
to make better utilities of memories).

	B) changed from V1:

The original V1 patchset of MOVABLE-dedicated node is here:
http://comments.gmane.org/gmane.linux.kernel.mm/78122

The new V2 adds N_MEMORY and a notion of "MOVABLE-dedicated node".
And fix some related problems.

The orignal V1 patchset of "add online_movable" is here:
https://lkml.org/lkml/2012/7/4/145

The new V2 discards the MIGRATE_HOTREMOVE approach, and use a more straight
implementation(only 1 patch).

	C) User Interface:

When users(big system manager) need config some node/memory as MOVABLE:
	1 Use kernelcore_max_addr=XX when boot
	2 Use movable_online hotplug action when running
We may introduce some more convenient interface, such as
	movable_node=NODE_LIST boot option.

	D) Patches

Patch1        introduce N_MEMORY
Patch2-13     use N_MEMORY instead N_HIGH_MEMORY.
              The patches are separated by subsystem,
              *these conversions was(must be) checked carefully*.
              Patch13 also changes the node_states initialization
Patch14,15,17 Fix problems of the current code.(all related with hotplug)
Patch18       Add config to allow MOVABLE-dedicated node
Patch19-22    Add kernelcore_max_addr
Patch23       Add online_movable


Lai Jiangshan (19):
  node_states: introduce N_MEMORY
  cpuset: use N_MEMORY instead N_HIGH_MEMORY
  procfs: use N_MEMORY instead N_HIGH_MEMORY
  oom: use N_MEMORY instead N_HIGH_MEMORY
  mm,migrate: use N_MEMORY instead N_HIGH_MEMORY
  mempolicy: use N_MEMORY instead N_HIGH_MEMORY
  memcontrol: use N_MEMORY instead N_HIGH_MEMORY
  hugetlb: use N_MEMORY instead N_HIGH_MEMORY
  vmstat: use N_MEMORY instead N_HIGH_MEMORY
  kthread: use N_MEMORY instead N_HIGH_MEMORY
  init: use N_MEMORY instead N_HIGH_MEMORY
  vmscan: use N_MEMORY instead N_HIGH_MEMORY
  page_alloc: use N_MEMORY instead N_HIGH_MEMORY and change the node_states initialization
  slub, hotplug: ignore unrelated node's hot-adding and hot-removing
  memory_hotplug: fix missing nodemask management
  numa: add CONFIG_MOVABLE_NODE for movable-dedicated node
  page_alloc.c: don't subtract unrelated memmap from zone's present pages
  page_alloc: add kernelcore_max_addr
  mm, memory-hotplug: add online_movable

Yasuaki Ishimatsu (4):
  x86: get pg_data_t's memory from other node
  x86: use memblock_set_current_limit() to set memblock.current_limit
  memblock: limit memory address from memblock
  memblock: compare current_limit with end variable at
    memblock_find_in_range_node()

 Documentation/cgroups/cpusets.txt   |    2 +-
 Documentation/kernel-parameters.txt |    9 +++
 Documentation/memory-hotplug.txt    |   16 ++++-
 arch/x86/kernel/setup.c             |    4 +-
 arch/x86/mm/init_64.c               |    4 +-
 arch/x86/mm/numa.c                  |    8 ++-
 drivers/base/memory.c               |   19 +++--
 drivers/base/node.c                 |    8 ++-
 fs/proc/kcore.c                     |    2 +-
 fs/proc/task_mmu.c                  |    4 +-
 include/linux/cpuset.h              |    2 +-
 include/linux/memblock.h            |    1 +
 include/linux/memory_hotplug.h      |   13 +++-
 include/linux/nodemask.h            |    5 ++
 init/main.c                         |    2 +-
 kernel/cpuset.c                     |   32 ++++----
 kernel/kthread.c                    |    2 +-
 mm/Kconfig                          |    8 ++
 mm/hugetlb.c                        |   24 +++---
 mm/memblock.c                       |   10 ++-
 mm/memcontrol.c                     |   18 +++---
 mm/memory_hotplug.c                 |  137 ++++++++++++++++++++++++++++++++---
 mm/mempolicy.c                      |   12 ++--
 mm/migrate.c                        |    2 +-
 mm/oom_kill.c                       |    2 +-
 mm/page_alloc.c                     |   96 +++++++++++++++----------
 mm/page_cgroup.c                    |    2 +-
 mm/slub.c                           |    6 ++
 mm/vmscan.c                         |    4 +-
 mm/vmstat.c                         |    4 +-
 30 files changed, 335 insertions(+), 123 deletions(-)
