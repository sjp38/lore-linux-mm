From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20051021095658.14409.26527.sendpatchset@skynet.csn.ul.ie>
Subject: [PATCH 0/8] Fragmentation Avoidance V18
Date: Fri, 21 Oct 2005 10:56:59 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, lhms-devel@lists.sourceforge.net
Cc: Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

Changelog since v17
o Update to 2.6.14-rc4-mm1
o Remove explicit casts where implicit casts were in place
o Change __GFP_USER to __GFP_EASYRCLM, RCLM_USER to RCLM_EASY and PCPU_USER to
  PCPU_EASY
o Print a warning and return NULL if both RCLM flags are set in the GFP flags
o Reduce size of fallback_allocs
o Change magic number 64 to FREE_AREA_USEMAP_SIZE
o CodingStyle regressions cleanup
o Move sparsemen setup_usemap() out of header
o Changed fallback_balance to a mechanism that depended on zone->present_pages
  to avoid hotplug problems later
o Many superflous parenthesis removed

Changlog since v16
o Variables using bit operations now are unsigned long. Note that when used
  as indices, they are integers and cast to unsigned long when necessary.
  This is because aim9 shows regressions when used as unsigned longs 
  throughout (~10% slowdown)
o 004_showfree added to provide more debugging information
o 008_stats dropped. Even with CONFIG_ALLOCSTATS disabled, it is causing 
  severe performance regressions. No explanation as to why
o for_each_rclmtype_order moved to header
o More coding style cleanups

Changelog since V14 (V15 not released)
o Update against 2.6.14-rc3
o Resync with Joel's work. All suggestions made on fix-ups to his last
  set of patches should also be in here. e.g. __GFP_USER is still __GFP_USER
  but is better commented.
o Large amount of CodingStyle, readability cleanups and corrections pointed
  out by Dave Hansen.
o Fix CONFIG_NUMA error that corrupted per-cpu lists
o Patches broken out to have one-feature-per-patch rather than
  more-code-per-patch
o Fix fallback bug where pages for RCLM_NORCLM end up on random other
  free lists.

Changelog since V13
o Patches are now broken out
o Added per-cpu draining of userrclm pages
o Brought the patch more in line with memory hotplug work
o Fine-grained use of the __GFP_USER and __GFP_KERNRCLM flags
o Many coding-style corrections
o Many whitespace-damage corrections

Changelog since V12
o Minor whitespace damage fixed as pointed by Joel Schopp

Changelog since V11
o Mainly a redefiff against 2.6.12-rc5
o Use #defines for indexing into pcpu lists
o Fix rounding error in the size of usemap

Changelog since V10
o All allocation types now use per-cpu caches like the standard allocator
o Removed all the additional buddy allocator statistic code
o Elimated three zone fields that can be lived without
o Simplified some loops
o Removed many unnecessary calculations

Changelog since V9
o Tightened what pools are used for fallbacks, less likely to fragment
o Many micro-optimisations to have the same performance as the standard 
  allocator. Modified allocator now faster than standard allocator using
  gcc 3.3.5
o Add counter for splits/coalescing

Changelog since V8
o rmqueue_bulk() allocates pages in large blocks and breaks it up into the
  requested size. Reduces the number of calls to __rmqueue()
o Beancounters are now a configurable option under "Kernel Hacking"
o Broke out some code into inline functions to be more Hotplug-friendly
o Increased the size of reserve for fallbacks from 10% to 12.5%. 

Changelog since V7
o Updated to 2.6.11-rc4
o Lots of cleanups, mainly related to beancounters
o Fixed up a miscalculation in the bitmap size as pointed out by Mike Kravetz
  (thanks Mike)
o Introduced a 10% reserve for fallbacks. Drastically reduces the number of
  kernnorclm allocations that go to the wrong places
o Don't trigger OOM when large allocations are involved

Changelog since V6
o Updated to 2.6.11-rc2
o Minor change to allow prezeroing to be a cleaner looking patch

Changelog since V5
o Fixed up gcc-2.95 errors
o Fixed up whitespace damage

Changelog since V4
o No changes. Applies cleanly against 2.6.11-rc1 and 2.6.11-rc1-bk6. Applies
  with offsets to 2.6.11-rc1-mm1

Changelog since V3
o inlined get_pageblock_type() and set_pageblock_type()
o set_pageblock_type() now takes a zone parameter to avoid a call to page_zone()
o When taking from the global pool, do not scan all the low-order lists

Changelog since V2
o Do not to interfere with the "min" decay
o Update the __GFP_BITS_SHIFT properly. Old value broke fsync and probably
  anything to do with asynchronous IO
  
Changelog since V1
o Update patch to 2.6.11-rc1
o Cleaned up bug where memory was wasted on a large bitmap
o Remove code that needed the binary buddy bitmaps
o Update flags to avoid colliding with __GFP_ZERO changes
o Extended fallback_count bean counters to show the fallback count for each
  allocation type
o In-code documentation

Version 1
o Initial release against 2.6.9

This patch is designed to reduce fragmentation in the standard buddy allocator
without impairing the performance of the allocator. High fragmentation in
the standard binary buddy allocator means that high-order allocations can
rarely be serviced. This patch works by dividing allocations into three
different types of allocations;

UserReclaimable - These are userspace pages that are easily reclaimable. This
	flag is set when it is known that the pages will be trivially reclaimed
	by writing the page out to swap or syncing with backing storage

KernelReclaimable - These are pages allocated by the kernel that are easily
	reclaimed. This is stuff like inode caches, dcache, buffer_heads etc.
	These type of pages potentially could be reclaimed by dumping the
	caches and reaping the slabs

KernelNonReclaimable - These are pages that are allocated by the kernel that
	are not trivially reclaimed. For example, the memory allocated for a
	loaded module would be in this category. By default, allocations are
	considered to be of this type

Instead of having one global MAX_ORDER-sized array of free lists,
there are four, one for each type of allocation and another reserve for
fallbacks. 

Once a 2^MAX_ORDER block of pages it split for a type of allocation, it is
added to the free-lists for that type, in effect reserving it. Hence, over
time, pages of the different types can be clustered together. This means that
if 2^MAX_ORDER number of pages were required, the system could linearly scan
a block of pages allocated for UserReclaimable and page each of them out.

Fallback is used when there are no 2^MAX_ORDER pages available and there
are no free pages of the desired type. The fallback lists were chosen in a
way that keeps the most easily reclaimable pages together.

Three benchmark results are included all based on a 2.6.14-rc3 kernel
compiled with gcc 3.4 (it is known that gcc 2.95 produces different results).
The first is the output of portions of AIM9 for the vanilla allocator and
the modified one;

(Tests run with bench-aim9.sh from VMRegress 0.17)
2.6.14-rc4-mm1-clean
------------------------------------------------------------------------------------------------------------
 Test        Test        Elapsed  Iteration    Iteration          Operation
Number       Name      Time (sec)   Count   Rate (loops/sec)    Rate (ops/sec)
------------------------------------------------------------------------------------------------------------
     1 creat-clo           60.03        963   16.04198        16041.98 File Creations and Closes/second
     2 page_test           60.02       4239   70.62646       120064.98 System Allocations & Pages/second
     3 brk_test            60.02       1560   25.99134       441852.72 System Memory Allocations/second
     4 jmp_test            60.01     251354 4188.53524      4188535.24 Non-local gotos/second
     5 signal_test         60.01       5091   84.83586        84835.86 Signal Traps/second
     6 exec_test           60.07        758   12.61861           63.09 Program Loads/second
     7 fork_test           60.05        814   13.55537         1355.54 Task Creations/second
     8 link_test           60.02       5326   88.73709         5590.44 Link/Unlink Pairs/second

2.6.14-rc3-mbuddy-v18
------------------------------------------------------------------------------------------------------------
 Test        Test        Elapsed  Iteration    Iteration          Operation
Number       Name      Time (sec)   Count   Rate (loops/sec)    Rate (ops/sec)
------------------------------------------------------------------------------------------------------------
     1 creat-clo           60.05        959   15.97002        15970.02 File Creations and Closes/second
     2 page_test           60.02       4239   70.62646       120064.98 System Allocations & Pages/second
     3 brk_test            60.03       1552   25.85374       439513.58 System Memory Allocations/second
     4 jmp_test            60.01     250647 4176.75387      4176753.87 Non-local gotos/second
     5 signal_test         60.02       4967   82.75575        82755.75 Signal Traps/second
     6 exec_test           60.03        747   12.44378           62.22 Program Loads/second
     7 fork_test           60.02        818   13.62879         1362.88 Task Creations/second
     8 link_test           60.00       5255   87.58333         5517.75 Link/Unlink Pairs/second

Difference in performance operations report generated by diff-aim9.sh
                   Clean   mbuddy-v18
                ---------- ----------
 1 creat-clo      15828.06   15970.02     141.96  0.90% File Creations and Closes/second
 2 page_test     120339.94  120064.98    -274.96 -0.23% System Allocations & Pages/second
 3 brk_test      427053.14  439513.58   12460.44  2.92% System Memory Allocations/second
 4 jmp_test     4183169.47 4176753.87   -6415.60 -0.15% Non-local gotos/second
 5 signal_test    84171.94   82755.75   -1416.19 -1.68% Signal Traps/second
 6 exec_test         61.64      62.22       0.58  0.94% Program Loads/second
 7 fork_test       1360.76    1362.88       2.12  0.16% Task Creations/second
 8 link_test       5509.48    5517.75       8.27  0.15% Link/Unlink Pairs/second

In this test, there were small regressions in the page_test. However, it
is known that different kernel configurations, compilers and even different
runs show similar varianes of +/- 3% .

The second benchmark tested the CPU cache usage to make sure it was not
getting clobbered. The test was to repeatedly render a large postscript file
10 times and get the average. The result is;

2.6.14-rc4-mm1-clean:      Average: 43.098 real, 40.188 user, 0.03 sys
2.6.14-rc4-mm1-mbuddy-v18: Average: 43.218 real, 40.478 user, 0.05 sys

So there are no adverse cache effects. The last test is to show that the
allocator can satisfy more high-order allocations, especially under load,
than the standard allocator. The test performs the following;

1. Start updatedb running in the background
2. Load kernel modules that tries to allocate high-order blocks on demand
3. Clean a kernel tree
4. Make 6 copies of the tree. As each copy finishes, a compile starts at -j2
5. Start compiling the primary tree
6. Sleep 1 minute while the 7 trees are being compiled
7. Use the kernel module to attempt 160 times to allocate a 2^10 block of pages
    - note, it only attempts 160 times, no matter how often it succeeds
    - An allocation is attempted every 1/10th of a second
    - Performance will get badly shot as it forces considerable amounts of
      pageout

The result of the allocations under load (load averaging 18) were;

2.6.14-rc4-mm1 Clean
Order:                 10
Allocation type:       HighMem
Attempted allocations: 160
Success allocs:        22
Failed allocs:         138
DMA zone allocs:       1
Normal zone allocs:    5
HighMem zone allocs:   16
% Success:            13

2.6.14-rc4-mm1 MBuddy V18
Order:                 10
Allocation type:       HighMem
Attempted allocations: 160
Success allocs:        41
Failed allocs:         119
DMA zone allocs:       0
Normal zone allocs:    5
HighMem zone allocs:   36
% Success:            25

One thing that had to be changed in the 2.6.14-rc4--mm1 clean test was to
disable the OOM killer. During one test, the OOM killer had better results
but invoked the OOM killer a very large number of times to achieve it. The
patch with the placement policy never invoked the OOM killer.

The above results are not very dramatic but the affect is very noticeable when
the system is at rest after the test completes. After the test, the standard
allocator was able to allocate 42 order-10 pages and the modified allocator
allocated 152. The ability to allocate large pages under load depend heavily
on the decisions of kswapd so there can be large variances in results but
that is a separate problem.

The results show that the modified allocator has comparable speed, has no
adverse cache effects but is far less fragmented and in a better position
to satisfy high-order allocations.
-- 
Mel Gorman
Part-time Phd Student                          Java Applications Developer
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
