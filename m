From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20070831205139.22283.71284.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 0/6] Use one zonelist per node instead of multiple zonelists v5
Date: Fri, 31 Aug 2007 21:51:39 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee.Schermerhorn@hp.com, ak@suse.de, clameter@sgi.com
Cc: Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The main changes here is a changeover to -mm and the dropping of gfp_skip until
it has been of proven performance benefit to scanning. The -mm switch is not
straight-forward as they collide heavily with the memoryless patches. This
set has the memoryless patches as a pre-requisite for smooth merging.

Node ID embedding in the zonelist->_zones was implemented but it was
ineffectual. Only the VSMP sub-architecture on x86_64 has enough space to
store the node ID so I dropped the patch again.

If there are no major objections to this, I'll push these patches towards
Andrew for -mm and wider testing. The full description of patchset is after
the changelog.

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
zonelist->zones where other places use zonelist.

The second patch replaces multiple zonelists with two zonelists that are
filtered. The two zonelists are due to the fact that the memoryless patchset
introduces a second set of zonelists for __GFP_THISNODE.

The third patch introduces filtering of the zonelists based on a nodemask.

The fourth patch replaces the two zonelists with one zonelist. A nodemask is
created when __GFP_THISNODE is specified to filter the list. The nodelists
could be pre-allocated with one-per-node but it's not clear that __GFP_THISNODE
is used often enough to be worth the effort.

The final patch replaces some static inline functions with macros. This
is purely for gcc 3.4 and possibly older versions that produce inferior
code. For readability, the patch can be dropped but if performance problems
are discovered, the compiler version and this final patch should be considered.

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
