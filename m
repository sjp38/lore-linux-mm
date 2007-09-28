From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20070928142326.16783.98817.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 0/6] Use one zonelist per node instead of multiple zonelists v8
Date: Fri, 28 Sep 2007 15:23:26 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: Lee.Schermerhorn@hp.com, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rientjes@google.com, kamezawa.hiroyu@jp.fujitsu.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

Hi Andrew,

This is the one-zonelist patchset again. There were multiple collisions
with patches in -mm like the policy cleanups, policy refcounting, the memory
controller patches and OOM killer changes. The functionality of the code has
not changed since the last release. I'm still hoping to merge this to -mm
when it is considered a bit more stable.

I've added David Rientjes to the cc as the OOM-zone-locking code is affected
by this patchset now and I want to be sure I didn't accidently break it. The
changes to try_set_zone_oom() are the most important here. I believe the
code is equivilant but a second opinion would not hurt.

Changelog since V7
  o Rebase to 2.6.23-rc8-mm2

Changelog since V6
  o Fix build bug in relation to memory controller combined with one-zonelist
  o Use while() instead of a stupid looking for()
  o Instead of encoding zone index information in a pointer, this version
    introduces a structure that stores a zone pointer and its index 

Changelog since V5
  o Rebase to 2.6.23-rc4-mm1
  o Drop patch that replaces inline functions with macros

Changelog since V4
  o Rebase to -mm kernel. Host of memoryless patches collisions dealt with
  o Do not call wakeup_kswapd() for every zone in a zonelist
  o Dropped the FASTCALL removal
  o Have cursor in iterator advance earlier
  o Use nodes_and in cpuset_nodes_valid_mems_allowed()
  o Use defines instead of inlines, noticably better performance on gcc-3.4
    No difference on later compilers such as gcc 4.1
  o Dropped gfp_skip patch until it is proven to be of benefit. Tests are
    currently inconclusive but it definitly consumes at least one cache
    line

Changelog since V3
  o Fix compile error in the parisc change
  o Calculate gfp_zone only once in __alloc_pages
  o Calculate classzone_idx properly in get_page_from_freelist
  o Alter check so that zone id embedded may still be used on UP
  o Use Kamezawa-sans suggestion for skipping zones in zonelist
  o Add __alloc_pages_nodemask() to filter zonelist based on a nodemask. This
    removes the need for MPOL_BIND to have a custom zonelist
  o Move zonelist iterators and helpers to mm.h
  o Change _zones from struct zone * to unsigned long
  
Changelog since V2
  o shrink_zones() uses zonelist instead of zonelist->zones
  o hugetlb uses zonelist iterator
  o zone_idx information is embedded in zonelist pointers
  o replace NODE_DATA(nid)->node_zonelist with node_zonelist(nid)

Changelog since V1
  o Break up the patch into 3 patches
  o Introduce iterators for zonelists
  o Performance regression test

The following patches replace multiple zonelists per node with one zonelist
that is filtered based on the GFP flags. The patches as a set fix a bug
with regard to the use of MPOL_BIND and ZONE_MOVABLE. With this patchset,
the MPOL_BIND will apply to the two highest zones when the highest zone
is ZONE_MOVABLE. This should be considered as an alternative fix for the
MPOL_BIND+ZONE_MOVABLE in 2.6.23 to the previously discussed hack that
filters only custom zonelists. As a bonus, the patchset reduces the cache
footprint of the kernel and should improve performance in a number of cases.

The first patch cleans up an inconsitency where direct reclaim uses
zonelist->zones where other places use zonelist. The second patch introduces
a helper function node_zonelist() for looking up the appropriate zonelist
for a GFP mask which simplifies patches later in the set.

The third patch replaces multiple zonelists with two zonelists that are
filtered. The two zonelists are due to the fact that the memoryless patchset
introduces a second set of zonelists for __GFP_THISNODE.

The fourth patch introduces helper macros for retrieving the zone and node indices of entries in a zonelist.

The fifth patch introduces filtering of the zonelists based on a nodemask.

The final patch replaces the two zonelists with one zonelist. A nodemask is
created when __GFP_THISNODE is specified to filter the list. The nodelists
could be pre-allocated with one-per-node but it's not clear that __GFP_THISNODE
is used often enough to be worth the effort.

Performance results varied depending on the machine configuration but were
usually small performance gains. In real workloads the gain/loss will depend
on how much the userspace portion of the benchmark benefits from having more
cache available due to reduced referencing of zonelists.

These are the range of performance losses/gains when running against
2.6.23-rc3-mm1. The set and these machines are a mix of i386, x86_64 and
ppc64 both NUMA and non-NUMA.

Total CPU time on Kernbench: -0.67% to  3.05%
Elapsed   time on Kernbench: -0.25% to  2.96%
page_test from aim9:         -6.98% to  5.60%
brk_test  from aim9:         -3.94% to  4.11%
fork_test from aim9:         -5.72% to  4.14%
exec_test from aim9:         -1.02% to  1.56%

The TBench figures were too variable between runs to draw conclusions from but
there didn't appear to be any regressions there. The hackbench results for both
sockets and pipes were within noise.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
