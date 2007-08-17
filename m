From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20070817201647.14792.2690.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 0/6] Use one zonelist per node instead of multiple zonelists v4
Date: Fri, 17 Aug 2007 21:16:47 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee.Schermerhorn@hp.com, ak@suse.de, clameter@sgi.com
Cc: Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Biggest changes are altering the embedding of zone IDs so that the type is
unsigned long instead of struct zone * and the removal of MPOL_BIND-specific
zonelists and filering based on node data instead. The biggest concern is the
last patch where FASTCALL doesn't appear to do the right thing in all cases.

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

The second patch replaces multiple zonelists with one zonelist that is
filtered.

The final patch is a fix that depends on the previous two patches. The
patch changes policy zone so that the MPOL_BIND policy gets applied
to the two highest populated zones when the highest populated zone is
ZONE_MOVABLE. Otherwise, MPOL_BIND only applies to the highest populated zone.

The tests passed regression tests with numactltest. Performance results
varied depending on the machine configuration but were usually small
performance gains. The new algorithm relies heavily on the implementation
of zone_idx which is currently pretty expensive. Experiments to optimise
this have shown significant improvements for this algorithm, but is beyond
the scope of this patchset. Due to the nature of the change, the results
for other people are likely to vary - it'll usually win but occasionally lose.

In real workloads the gain/loss will depend on how much the userspace
portion of the benchmark benefits from having more cache available due
to reduced referencing of zonelists. I expect it'll be more noticable on
x86_64 with many zones than on IA64 which typically would only have one
active zonelist-per-node.

These are the range of performance losses/gains I found when running against
2.6.23-rc1-mm2. The set and these machines are a mix of i386, x86_64 and
ppc64 both NUMA and non-NUMA.

Total CPU time on Kernbench: -0.02% to  0.27%
Elapsed   time on Kernbench: -0.21% to  1.26%
page_test from aim9:         -3.41% to  3.90%
brk_test  from aim9:         -0.20% to 40.94%
fork_test from aim9:         -0.42% to  4.59%
exec_test from aim9:         -0.78% to  1.95%
Size reduction of pg_dat_t:   0     to  7808 bytes (depends on alignment)

The TBench figures were too variable between runs to draw conclusions from but
there didn't appear to be any regressions there. The hackbench results for both
sockets and pipes was within noise. I haven't gone though lmbench.

These three patches are a standalone set which address the MPOL_BIND problem
with ZONE_MOVABLE as well as reducing memory usage and in many cases the
cache footprint of the kernel.  They should be considered as a bug fix due to
the MPOL_BIND fixup.

If these patches are accepted, the follow-on work would entail;

o Encode zone_id in the zonelist pointers to avoid zone_idx() (Christoph's idea)
o If zone_id works out, eliminate z_to_n from the zonelist cache as unnecessary
o Remove bind_zonelist() (Patch in progress, very messy right now)
o Eliminate policy_zone (Trickier)

Comments?
-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
