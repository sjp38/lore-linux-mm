From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Wed, 27 Feb 2008 16:47:08 -0500
Message-Id: <20080227214708.6858.53458.sendpatchset@localhost>
Subject: [PATCH 0/6] Use two zonelists per node instead of multiple zonelists v11r3
Sender: owner-linux-mm@kvack.org
From: Mel Gorman <mel@csn.ul.ie>
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: mel@csn.ul.ie, ak@suse.de, clameter@sgi.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, rientjes@google.com, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

[PATCH 0/6] Use two zonelists per node instead of multiple zonelists v11r3

This is a rebase of the two-zonelist patchset to 2.6.25-rc2-mm1.

Mel, still on vacation last I checked,  asked me to repost these
as I'd already rebased them and I've been testing them continually
on each -mm tree for months, hoping to see them in -mm for wider
testing.

I have a series of mempolicy cleanup patches, including a rework of the
reference counting that depend on this series.  David R. has a series
of mempolicy enhancements out for review that, IMO, will benefit from
this series.  In both cases, the removal of the custom zonelist for
MPOL_BIND is the important feature.

Lee

---

Changelog since V11r2
  o Rebase to 2.6.25-rc2-mm1

Changelog since V10
  o Rebase to 2.6.24-rc4-mm1
  o Clear up warnings in fs/buffer.c early in the patchset

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

The following patches replace multiple zonelists per node with two zonelists
that are filtered based on the GFP flags. The patches as a set fix a bug
with regard to the use of MPOL_BIND and ZONE_MOVABLE. With this patchset,
the MPOL_BIND will apply to the two highest zones when the highest zone
is ZONE_MOVABLE. This should be considered as an alternative fix for the
MPOL_BIND+ZONE_MOVABLE in 2.6.23 to the previously discussed hack that
filters only custom zonelists.

The first patch cleans up an inconsistency where direct reclaim uses
zonelist->zones where other places use zonelist.

The second patch introduces a helper function node_zonelist() for looking
up the appropriate zonelist for a GFP mask which simplifies patches later
in the set.

The third patch defines/remembers the "preferred zone" for numa statistics,
as it is no longer always the first zone in a zonelist.

The forth patch replaces multiple zonelists with two zonelists that are
filtered. The two zonelists are due to the fact that the memoryless patchset
introduces a second set of zonelists for __GFP_THISNODE.

The fifth patch introduces helper macros for retrieving the zone and node
indices of entries in a zonelist.

The final patch introduces filtering of the zonelists based on a nodemask. Two
zonelists exist per node, one for normal allocations and one for __GFP_THISNODE.

Performance results varied depending on the machine configuration. In real
workloads the gain/loss will depend on how much the userspace portion of
the benchmark benefits from having more cache available due to reduced
referencing of zonelists.

These are the range of performance losses/gains when running against
2.6.24-rc4-mm1. The set and these machines are a mix of i386, x86_64 and
ppc64 both NUMA and non-NUMA.

			     loss   to  gain
Total CPU time on Kernbench: -0.86% to  1.13%
Elapsed   time on Kernbench: -0.79% to  0.76%
page_test from aim9:         -4.37% to  0.79%
brk_test  from aim9:         -0.71% to  4.07%
fork_test from aim9:         -1.84% to  4.60%
exec_test from aim9:         -0.71% to  1.08%

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
