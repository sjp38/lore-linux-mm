From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20071121003848.10789.18030.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 0/6] Use two zonelists per node instead of multiple zonelists v10
Date: Wed, 21 Nov 2007 00:38:48 +0000 (GMT)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee.Schermerhorn@hp.com, clameter@sgi.com
Cc: Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This release brings the number of zonelists to two instead of one. Getting
all the corner cases right for __GFP_THISNODE and one zonelist was turning
into a complicated mess. Not only was it affecting too many paths but it
reached the point where it should be reviewed as a standalone change.

Much of the aims of the earlier sets are met by having two zonelists. The
hack is still removed, the number of zonelists is reduced and the MPOL_BIND
policy still behaves sensibly. I believe this to be a reasonable starting
point leaving the full one-zonelist approach to be tackled later.

There were a few bugs and issues highlighed from reviews fixed up which
are briefly described in the changelog.

There are concerns over the stability of mainline and -mm at the moment
and the evidence is on http://test.kernel.org so we should verify for sure
it is still ok. The set passes a slightly modified numactl regression test
on x86_64. The slight modification was required because numastat behaves
differently than the regression test expects (nodes in reverse order). Lee,
can you confirm it still hasn't regressed with your tests before another
attempt is made to push it please?

Changelog since V9
  o Rebase to 2.6.24-rc2-mm1
  o Lookup the nodemask for each allocator callsite in mempolicy.c
  o Update NUMA statistics based on preferred zone, not first zonelist entry
  o When __GFP_THISNODE is specified with MPOL_BIND and the current node is
    not in the allowed nodemask, the first node in the mask will be used
  o Stick with using two zonelists instead of one because of excessive
    complexity with corner cases

Changelog since V8
  o Rebase to 2.6.24-rc2
  o Added ack for the OOM changes
  o Behave correctly when GFP_THISNODE and a node ID are specified
  o Clear up warning over type of nodes_intersects() function

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
filters only custom zonelists.

The first patch cleans up an inconsitency where direct reclaim uses
zonelist->zones where other places use zonelist.

The second patch introduces a helper function node_zonelist() for looking
up the appropriate zonelist for a GFP mask which simplifies patches later
in the set.

The third patch replaces multiple zonelists with two zonelists that are
filtered. The two zonelists are due to the fact that the memoryless patchset
introduces a second set of zonelists for __GFP_THISNODE.

The fourth patch introduces helper macros for retrieving the zone and node indices of entries in a zonelist.

The final patch introduces filtering of the zonelists based on a nodemask. Two
zonelists exist per node, one for normal allocations and one for __GFP_THISNODE.

Performance results varied depending on the machine configuration but were
usually small performance gains. In real workloads the gain/loss will depend
on how much the userspace portion of the benchmark benefits from having more
cache available due to reduced referencing of zonelists.

These are the range of performance losses/gains when running against
2.6.24-rc2-mm1. The set and these machines are a mix of i386, x86_64 and
ppc64 both NUMA and non-NUMA.

			     loss   to  gain
Total CPU time on Kernbench: -1.54% to  0.54%
Elapsed   time on Kernbench: -0.75% to  0.42%
page_test from aim9:         -8.23% to 10.71%
brk_test  from aim9:         -3.32% to  4.78%
fork_test from aim9:         -0.44% to  0.38%
exec_test from aim9:         -0.95% to  1.11%

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
