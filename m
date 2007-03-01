Date: Thu, 1 Mar 2007 10:12:50 +0000
Subject: The performance and behaviour of the anti-fragmentation related patches
Message-ID: <20070301101249.GA29351@skynet.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org, npiggin@suse.de, clameter@engr.sgi.com, mingo@elte.hu, jschopp@austin.ibm.com, arjan@infradead.org, torvalds@osdl.org, mbligh@mbligh.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi all,

I've posted up patches that implement the two generally accepted approaches
for reducing external fragmentation in the buddy allocator. The first
(list-based) works by grouping pages of related mobility together, across
all existing zones.  The second (zone-based) creates a zone where only pages
that can be migrated or reclaimed are allocated from.

List-based requires no configuration other than setting min_free_kbytes to
16384, but workloads might exist that break it down, such that different
page types become badly mixed. It was suggested that zones should instead
be used to partition memory between the types to avoid this breakdown. This
works well and it's behaviour is predictable, but it requires configuration at
boot time and that is a lot less flexible than the list-based approach. Both
approaches had their proponents and detractors.

Hence, the two patchsets posted are no longer mutually exclusive and will work
together when they are both applied.  This means that without configuration,
external fragmentation will be reduced as much as possible. However,
if the system administrator has a workload which requires higher levels
of availability or is using varying numbers of huge pages between jobs,
ZONE_MOVABLE can be configured to be the maximum number of huge pages
required by any job.

This mail is intended to describe more about how the patches actually work
and provide some performance figures to the people who have made serious
comments about the patches in the past, mainly at VM Summit. I hope it will
help solidify discussions on these patch sets and ultimately lead to a decision
on which method or methods are worthy of merging to -mm for wider exposure.

In the past, it has been pointed out that the code is complicated and it is not
particularly clear what the end effect of the patches is or why they work. To
give people a better understanding of what the patches are actually doing,
some tools were put together by myself and Andy that can graph how pages of
different mobility types are distributed in memory. An example image from
an x86_64 machine is

http://www.skynet.ie/~mel/anti-frag/2007-02-28/page_type_distribution.jpg

Each pixel represents a page of memory, each block represents
MAX_ORDER_NR_PAGES number of pages. The color of a pixel indicates the
mobility type of the page.  In most cases, one box is one huge page. On
x86_64 and some x86, half a box will be a huge page. The legend for colors
is at the top but for further clarification;

ZoneBoundary 	- A black outline to the left and above a box implies a zone
		  starts there
Movable 	- __GFP_MOVABLE pages
Reclaimable 	- __GFP_RECLAIMABLE pages
Pinned		- Bootmem allocated pages and unmovable pages are these
per-cpu		- These are allocated pages with no mappings or count. They are usually
		  per-cpu pages but a high-order allocation can appear like this too.
Movable-under-reclaim - These are __GFP_MOVABLE pages but IO is being performed

During tests, the data required to generate this image is collected every
2 seconds. At the end of the test, all the samples are gathered together
and a video is created. The video shows over time an approximate view of
the memory fragmentation, this very clearly shows trends in locations of
allocations and areas under reclaim.

This is a video[*] of the vanilla kernel running a series of benchmarks on a
ppc64 machine.

video:  http://www.skynet.ie/~mel/anti-frag/2007-02-28/examplevideo-ppc64-2.6.20-mm2-vanilla.avi
frames: http://www.skynet.ie/~mel/anti-frag/2007-02-28/exampleframes-ppc64-2.6.20-mm2-vanilla.tar.gz


Notice that pages of different mobility types get scattered all over the
physical address space on the vanilla kernel because there is no effort made
to place the pages.  2% of memory was kept free with min_free_kbytes and this
results in the free block of pages towards the start of memory. Notice
also that the huge page allocations always come from here as well. *This* is
why setting min_free_kbytes to a high value allows higher-order allocations
work for a period of time! As the buddy allocator favours small blocks for
allocation, the pages kept free were contiguous to begin with. It works
until that block gets split due to excessive memory pressure and after that,
high-order allocations start failing again. If min_free_kbytes was set to
a higher value once the system had been running for some time, high-order
allocations would continue to fail. This is why I've asserted before that
setting min_free_kbytes is not a fix for external fragmentation problems.

Next is a video of a kernel patched with both list-based and zone-based
patches applied.

video:  http://www.skynet.ie/~mel/anti-frag/2007-02-28/examplevideo-ppc64-2.6.20-mm2-antifrag.avi
frames: http://www.skynet.ie/~mel/anti-frag/2007-02-28/exampleframes-ppc64-2.6.20-mm2-antifrag.tar.gz

kernelcore has been set to 60% of memory so you'll see where the black
line indicating the zone is starting. Note how the higher zone is always
green (indicating it is being used for movable pages) - this is how
zone-based works.  In the remaining portions of memory, you'll see how
the boxes (i.e. MAX_ORDER areas) remain as solid colors the majority of
the time. this is the effect of list-based as it groups pages together of
similar mobility. Note how when allocating huge pages under load as well,
it fails to use all of ZONE_MOVABLE. This is a problem with reclaim which
patches from Andy Whitcroft aim to fix up. Two sets of figures are posted
below. The first set is just anti-frag related and the second test includes
patches from Andy.

It should be clear from the videos how and why anti-frag is successful at
what it does. To get higher success rates, defragmentation is needed to move
movable pages from sparsely populated hugepages to densely populated ones.
It should also be clear that slab reclaim needs to be a bit smarter because
you'll see in the videos the "blue" pages that are very sparsely populated
but not being reclaimed.

However, as anti-frag currently stands, it's very effective. Improvements
are logical progressions instead of problems with the fundamental idea. For
example, on gekko-lp4, 1% of memory can be allocated as a huge page which
represents min_free_kbytes. With both patches applied, 51% of memory can be
allocated as huge pages.

The following are performance figures based on a number of tests with
different machines

Kernbench Total CPU Time
                          Vanilla Kernel   List-base Kernel  Zone-base Kernel  Combined Kernel
Machine       Arch           Seconds           Seconds           Seconds          Seconds
-------     ---------     --------------   ----------------  ----------------  ---------------
bl6-13      x86_64              121.34          119.00            119.60           ---    
elm3b14     x86-numaq          1527.57         1530.80           1529.26          1530.64 
elm3b245    x86_64              346.95          346.48            347.18           346.67  
gekko-lp1   ppc64               323.66          323.80            323.67           323.58  
gekko-lp4   ppc64               319.61          320.25            319.49           319.58  


Kernbench Total Elapsed Time
                          Vanilla Kernel   List-base Kernel  Zone-base Kernel  Combined Kernel
Machine       Arch           Seconds           Seconds           Seconds          Seconds
-------     ---------     --------------   ----------------  ----------------  ---------------
bl6-13      x86_64              36.32           37.78             35.14            ---    
elm3b14     x86-numaq          426.08          427.34            426.76           427.73  
elm3b245    x86_64              96.50           96.03             96.34            96.11   
gekko-lp1   ppc64              172.17          171.74            172.06           171.73  
gekko-lp4   ppc64              325.38          326.26            324.90           324.83  


Percentage of memory allocated as huge pages under load
                          Vanilla Kernel   List-base Kernel  Zone-base Kernel  Combined Kernel
Machine       Arch          Percentage       Percentage         Percentage       Percentage
-------     ---------     --------------   ----------------  ----------------  ---------------
bl6-13      x86_64              10              75                 17             0  
elm3b14     x86-numaq           21              27                 19             25 
elm3b245    x86_64              34              66                 27             62 
gekko-lp1   ppc64               2               14                 4              20 
gekko-lp4   ppc64               1               24                 3              17 


Percentage of memory allocated as huge pages at rest at end of test
                          Vanilla Kernel   List-base Kernel  Zone-base Kernel  Combined Kernel
Machine       Arch          Percentage       Percentage         Percentage       Percentage
-------     ---------     --------------   ----------------  ----------------  ---------------
bl6-13      x86_64              17              76                 22             0  
elm3b14     x86-numaq           69              84                 55             82 
elm3b245    x86_64              41              82                 44             82 
gekko-lp1   ppc64               3               61                 9              69 
gekko-lp4   ppc64               1               32                 4              51 

These are figures based on kernels patches with Andy Whitcrofts reclaim
patches. You will see that the zone-based kernel is getting success rates
closer to 40% as one would expect although there is still something amiss.

Kernbench Total CPU Time        
                          Vanilla Kernel   List-base Kernel  Zone-base Kernel  Combined Kernel
Machine       Arch           Seconds           Seconds           Seconds          Seconds
-------     ---------     --------------   ----------------  ----------------  ---------------
elm3b14     x86-numaq           1528.42         1531.25           1528.48          1531.04 
elm3b245    x86_64              347.48          346.09            346.67           346.04  
gekko-lp1   ppc64               323.74          323.79            323.45           323.77  
gekko-lp4   ppc64               319.65          319.72            319.74           319.70  
                                
                                
Kernbench Total Elapsed Time    
                          Vanilla Kernel   List-base Kernel  Zone-base Kernel  Combined Kernel
Machine       Arch           Seconds           Seconds           Seconds          Seconds
-------     ---------     --------------   ----------------  ----------------  ---------------
elm3b14     x86-numaq           427.00          427.85            426.18           427.42  
elm3b245    x86_64              96.72           96.03             96.58            96.27   
gekko-lp1   ppc64               172.07          172.07            171.96           172.72  
gekko-lp4   ppc64               325.41          324.97            325.71           324.94  
                                
                                
Percentage of memory allocated as huge pages under load
                          Vanilla Kernel   List-base Kernel  Zone-base Kernel  Combined Kernel
Machine       Arch          Percentage       Percentage         Percentage       Percentage
-------     ---------     --------------   ----------------  ----------------  ---------------
elm3b14     x86-numaq           24              29                 23             26 
elm3b245    x86_64              33              76                 42             75 
gekko-lp1   ppc64               2               23                 9              29 
gekko-lp4   ppc64               1               24                 24             40 
                                
                                
Percentage of memory allocated as huge pages at rest at end of test
                          Vanilla Kernel   List-base Kernel  Zone-base Kernel  Combined Kernel
Machine       Arch          Percentage       Percentage         Percentage       Percentage
-------     ---------     --------------   ----------------  ----------------  ---------------
elm3b14     x86-numaq           52              84                 64             82 
elm3b245    x86_64              51              87                 44             85 
gekko-lp1   ppc64               7               69                 25             67 
gekko-lp4   ppc64               3               43                 29             53 

The patches go a long way to making sure that high-order allocations work
and particularly that the hugepage pool can be resized once the system has
been running. With the clustering of high-order atomic allocations, I have
some confidence that allocating contiguous jumbo frames will work even with
loads performing lots of IO. I think the videos show how the patches actually
work in the clearest possible manner.

I am of the opinion that both approaches have their advantages and
disadvantages. Given a choice between the two, I prefer list-based
because of it's flexibility and it should also help high-order kernel
allocations. However, by applying both, the disadvantages of list-based are
covered and there still appears to be no performance loss as a result. Hence,
I'd like to see both merged.  Any opinion on merging these patches into -mm
for wider testing?




Here is a list of videos showing different patched kernels on each machine
for the curious. Be warned that they are all pretty large which means the
guys hosting the machine are going to love me.

elm3b14-vanilla       http://www.skynet.ie/~mel/anti-frag/2007-02-28/elm3b14-vanilla.avi
elm3b14-list-based    http://www.skynet.ie/~mel/anti-frag/2007-02-28/elm3b14-listbased.avi
elm3b14-zone-based    http://www.skynet.ie/~mel/anti-frag/2007-02-28/elm3b14-zonebased.avi
elm3b14-combined      http://www.skynet.ie/~mel/anti-frag/2007-02-28/elm3b14-combined.avi

elm3b245-vanilla      http://www.skynet.ie/~mel/anti-frag/2007-02-28/elm3b245-vanilla.avi
elm3b245-list-based   http://www.skynet.ie/~mel/anti-frag/2007-02-28/elm3b245-listbased.avi
elm3b245-zone-based   http://www.skynet.ie/~mel/anti-frag/2007-02-28/elm3b245-zonebased.avi
elm3b245-combined     http://www.skynet.ie/~mel/anti-frag/2007-02-28/elm3b245-combined.avi

gekko-lp1-vanilla     http://www.skynet.ie/~mel/anti-frag/2007-02-28/gekkolp1-vanilla.avi
gekko-lp1-list-based  http://www.skynet.ie/~mel/anti-frag/2007-02-28/gekkolp1-listbased.avi
gekko-lp1-zone-based  http://www.skynet.ie/~mel/anti-frag/2007-02-28/gekkolp1-zonebased.avi
gekko-lp1-combined    http://www.skynet.ie/~mel/anti-frag/2007-02-28/gekkolp1-combined.avi

gekko-lp4-vanilla     http://www.skynet.ie/~mel/anti-frag/2007-02-28/gekkolp4-vanilla.avi
gekko-lp4-list-based  http://www.skynet.ie/~mel/anti-frag/2007-02-28/gekkolp4-listbased.avi
gekko-lp4-zone-based  http://www.skynet.ie/~mel/anti-frag/2007-02-28/gekkolp4-zonebased.avi
gekko-lp4-combined    http://www.skynet.ie/~mel/anti-frag/2007-02-28/gekkolp4-combined.avi

Notes;
1. The performance figures show small variances, both performance gains and
   regressions. The biggest gains tend to be on x86_64.
2. The x86 figures are based on a numaq which is an ancient machine. I didn't
   have a more modern machine available for running these tests on.
3. The Vanilla kernel is an unpatched 2.6.20-mm2 kernel
4. List-base represents the "list-based" patches desribed above which groups
   pages by mobility type.
5. Zone-base represents the "zone-based" patches which groups movable pages
   together in one zone as described.
6. Combined is with both sets of patches applied
7. The kernbench figures are based on an average of 3 iterations. The figures
   always show that the vanilla and patched kernels have similar performance.
   The anti-frag kernels are usually faster on x86_64.
8. The success rates for the allocation of hugepages should always be at least
   40%. Anything lower implies that reclaim is not reclaiming pages that it
   could. I've included figures below based on kernels patches with additional
   fixes to reclaim from Andy.
9. The bl6-13 figures are incomplete because the machine was deleted from
   the test grid and never came back. They're left in because it was a machine
   that showed reliable performance improvements from the patches
10. The videos are a bit blurry due to quality. High-res images can be
   generated

[*] On my Debian Etch system, xine-ui works for playing videos. On other
	systems, I found ffplay from the ffmpeg package worked. If neither
	of these work for you, the tar.gz contains the JPG files making up
	the frames and you can view them with any image viewer.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
