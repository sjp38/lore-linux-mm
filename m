Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 3DC796B003D
	for <linux-mm@kvack.org>; Wed,  4 Feb 2009 10:27:14 -0500 (EST)
Date: Wed, 4 Feb 2009 15:27:10 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [patch] SLQB slab allocator (try 2)
Message-ID: <20090204152709.GA4799@csn.ul.ie>
References: <20090123154653.GA14517@wotan.suse.de> <200902032136.26022.nickpiggin@yahoo.com.au> <20090203112226.GG9840@csn.ul.ie> <200902041748.41801.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <200902041748.41801.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Lin Ming <ming.m.lin@intel.com>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, Feb 04, 2009 at 05:48:40PM +1100, Nick Piggin wrote:
> On Tuesday 03 February 2009 22:22:26 Mel Gorman wrote:
> > On Tue, Feb 03, 2009 at 09:36:24PM +1100, Nick Piggin wrote:
> 
> > > But it will be interesting to try looking at some of the tests where
> > > SLQB has larger regressions, so that might give me something to go on
> > > if I can lay my hands on speccpu2006...
> >
> > I can generate profile runs although it'll take 3 days to gather it all
> > together unless I target specific tests (the worst ones to start with
> > obviously). The suite has a handy feature called monitor hooks that allows
> > a pre and post script to run for each test which I use it to start/stop
> > oprofile and gather one report per benchmark. I didn't use it for this run
> > as profiling affects the outcome (7-9% overhead).
> >
> > I do have detailed profile data available for sysbench, both per thread run
> > and the entire run but with the instruction-level included, it's a lot of
> > data to upload. If you still want it, I'll start it going and it'll get up
> > there eventually.
> 
> It couldn't hurt, but it's usually tricky to read anything out of these from
> CPU cycle profiles. Especially if they are due to cache or tlb effects (which
> tend to just get spread out all over the profile).
> 

Indeed. To date, I've used them for comparing relative counts of things like
TLB and cache misses on the basis "relatively more misses running test X is
bad" or working out things like tlb-misses-per-instructions but it's a bit
vague. We might notice if one of the allocators is being particularly cache
unfriendly due to a spike in cache misses.

> slabinfo (for SLUB) and slqbinfo (for SLQB) activity data could be interesting
> (invoke with -AD).
> 

Ok, I butchered Ingo's proc monitoring script to gather /proc/slabinfo,
slabinfo -AD and slqbinfo -AD before and after each speccpu subtest.  The tests
with profiling just started but it will take a few days to complete and thats
assuming I made no mistakes in the automation. I'll be at FOSDEM from Friday
till Monday so may not be able to collect the results until Monday.

> 
> > > I'd be interested to see how slub performs if booted with
> > > slub_min_objects=1 (which should give similar order pages to SLAB and
> > > SLQB).
> >
> > I'll do this before profiling as only one run is required and should
> > only take a day.
> >
> > Making spec actually build is tricky so I've included a sample config for
> > x86-64 below that uses gcc and the monitor hooks in case someone else is in
> > the position to repeat the results.
> 
> Thanks. I don't know if we have a copy of spec 2006 I can use, but I'll ask
> around.
> 

In the meantime, here are the results I have with slub configured  to
use small orders.

X86-64 Test machine
        CPU             AMD Phenom 9950 Quad-Core
        CPU Frequency   1.3GHz
        Physical CPUs   1 (4 cores)
        L1 Cache        64K Data, 64K Instruction per core
        L2 Cache        512K Unified per core
        L3 Cache        2048K Unified Shared per chip
        Main Memory     8 GB
        Mainboard       Gigabyte GA-MA78GM-S2H
        Machine Model   Custom built from parts

SPEC CPU 2006
-------------
Integer tests
SPEC test       slab                 slub  slub-minorder           slqb
400.perlbench   1.0000             1.0016         0.9921         1.0064
401.bzip2       1.0000             0.9804         0.9858         1.0011
403.gcc         1.0000             1.0023         0.9977         0.9965
429.mcf         1.0000             1.0022         0.9847         0.9963
445.gobmk       1.0000             0.9944         0.9958         0.9986
456.hmmer       1.0000             0.9792         0.9874         0.9701
458.sjeng       1.0000             0.9989         1.0144         1.0133
462.libquantum  1.0000             0.9905         0.9943         0.9981
464.h264ref     1.0000             0.9877         0.9926         1.0058
471.omnetpp     1.0000             0.9893         1.0896         1.0993
473.astar       1.0000             0.9542         0.9930         0.9596
483.xalancbmk   1.0000             0.9547         0.9928         0.9982
---------------
specint geomean 1.0000             0.9862         1.0013         1.0031

Floating Point Tests
SPEC test       slab                 slub  slub-minorder           slqb
410.bwaves      1.0000             0.9939         1.0000         1.0005
416.gamess      1.0000             1.0040         1.0032         0.9984
433.milc        1.0000             0.9865         0.9986         0.9865
434.zeusmp      1.0000             0.9810         0.9980         0.9879
435.gromacs     1.0000             0.9854         1.0100         1.0125
436.cactusADM   1.0000             1.0467         0.9904         1.0294
437.leslie3d    1.0000             0.9846         0.9970         0.9963
444.namd        1.0000             1.0000         0.9986         1.0000
447.dealII      1.0000             0.9913         0.9957         0.9957
450.soplex      1.0000             0.9940         0.9955         1.0015
453.povray      1.0000             0.9904         1.0097         1.0197
454.calculix    1.0000             0.9937         0.9975         1.0000
459.GemsFDTD    1.0000             1.0061         0.9902         1.0000
465.tonto       1.0000             0.9979         1.0000         0.9989
470.lbm         1.0000             1.0099         0.9924         1.0212
481.wrf         1.0000             1.0000         1.0045         1.0045
482.sphinx3     1.0000             1.0047         1.0000         1.0068
---------------
specfp geomean  1.0000             0.9981         0.9989         1.0035

Sysbench-Postgres
-----------------
Client           slab  slub-default  slub-minorder            slqb
     1         1.0000        0.9484         0.9699          0.9804
     2         1.0000        1.0069         1.0036          0.9994
     3         1.0000        1.0064         1.0080          0.9994
     4         1.0000        0.9900         1.0049          0.9904
     5         1.0000        1.0023         1.0144          0.9869
     6         1.0000        1.0139         1.0215          1.0069
     7         1.0000        0.9973         0.9966          0.9991
     8         1.0000        1.0206         1.0223          1.0197
     9         1.0000        0.9884         1.0167          0.9817
    10         1.0000        0.9980         0.9842          1.0135
    11         1.0000        0.9959         1.0036          1.0164
    12         1.0000        0.9978         1.0032          0.9953
    13         1.0000        1.0024         1.0022          0.9942
    14         1.0000        0.9975         1.0064          0.9808
    15         1.0000        0.9914         0.9949          0.9933
    16         1.0000        0.9767         0.9692          0.9726
Geo. mean      1.0000        0.9957         1.0012          0.9955

PPC64 Test Machine
        CPU              PPC970MP, altivec supported
        CPU Frequency    2.5GHz
        Physical CPUs 2 x dual core (4 cores in all)
        L1 Cache         32K Data, 64K Instruction per core
        L2 Cache         1024K Unified per core
        L3 Cache         N/a
        Main Memory      10GB
        Mainboard        Specific to the machine model

SPEC CPU 2006
-------------
Integer tests
SPEC test       slab                 slub  slub-minorder           slqb
400.perlbench   1.0000             1.0497         1.0515         1.0497
401.bzip2       1.0000             1.0496         1.0496         1.0489
403.gcc         1.0000             1.0509         1.0509         1.0509
429.mcf         1.0000             1.0554         1.0549         1.0549
445.gobmk       1.0000             1.0535         1.0545         1.0556
456.hmmer       1.0000             1.0651         1.0636         1.0566
458.sjeng       1.0000             1.0612         1.0612         1.0564
462.libquantum  1.0000             1.0389         1.0403         1.0396
464.h264ref     1.0000             1.0517         1.0496         1.0503
471.omnetpp     1.0000             1.0555         1.0574         1.0574
473.astar       1.0000             1.0508         1.0514         1.0521
483.xalancbmk   1.0000             1.0594         1.0584         1.0584
---------------
specint geomean 1.0000             1.0534         1.0536         1.0525

Floating Point Tests
SPEC test       slab                 slub  slub-minorder           slqb
410.bwaves      1.0000             1.0381         1.0381         1.0367
416.gamess      1.0000             1.0550         1.0539         1.0550
433.milc        1.0000             1.0464         1.0457         1.0450
434.zeusmp      1.0000             1.0510         1.0482         1.0528
435.gromacs     1.0000             1.0461         1.0437         1.0445
436.cactusADM   1.0000             1.0457         1.0463         1.0450
437.leslie3d    1.0000             1.0437         1.0437         1.0428
444.namd        1.0000             1.0482         1.0482         1.0496
447.dealII      1.0000             1.0505         1.0495         1.0505
450.soplex      1.0000             1.0522         1.0511         1.0499
453.povray      1.0000             1.0513         1.0534         1.0534
454.calculix    1.0000             1.0374         1.0370         1.0357
459.GemsFDTD    1.0000             1.0465         1.0465         1.0465
465.tonto       1.0000             1.0488         1.0494         1.0456
470.lbm         1.0000             1.0438         1.0438         1.0452
481.wrf         1.0000             1.0423         1.0423         1.0429
482.sphinx3     1.0000             1.0464         1.0479         1.0479
---------------
specfp geomean  1.0000             1.0467         1.0464         1.0464

Sysbench-Postgres
-----------------
Client           slab  slub-default  slub-minorder            slqb
     1         1.0000        1.0153         1.0179          1.0051
     2         1.0000        1.0273         1.0181          1.0269
     3         1.0000        1.0299         1.0195          1.0234
     4         1.0000        1.0159         1.0130          1.0146
     5         1.0000        1.0232         1.0192          1.0264
     6         1.0000        1.0238         1.0142          1.0088
     7         1.0000        1.0240         1.0063          1.0076
     8         1.0000        1.0134         0.9842          1.0024
     9         1.0000        1.0154         1.0152          1.0077
    10         1.0000        1.0126         1.0018          1.0009
    11         1.0000        1.0100         0.9971          0.9933
    12         1.0000        1.0112         0.9985          0.9993
    13         1.0000        1.0131         1.0060          1.0035
    14         1.0000        1.0237         1.0074          1.0071
    15         1.0000        1.0098         0.9997          0.9997
    16         1.0000        1.0110         0.9899          0.9994
Geo. mean      1.0000        1.0175         1.0067          1.0078

The order SLUB uses does not make much of a difference to SPEC CPU on
either test machine or sysbench on x86-64. Howeer, on the ppc64 machine, the
performance advantage SLUB has over SLAB appears to be eliminated if high-order
pages are not used. I think I might run SLUB again incase the higher average
performance was a co-incidence due to lucky cache layout. Otherwise, Christoph
can probably put together a plausible theory on this result faster than I can.

On the TLB front, it is perfectly possible that the workloads on x86-64 are
not allocator or memory intensive enough to take advantage of fewer calls to
the page allocator or potentially reduced TLB pressure. As the kernel portion
of the address space already uses huge pages slab objects may have to occupy
a very large percentage of memory before TLB pressure became an issue. The L1
TLBs on both test machines are fully associative making testing reduced TLB
pressure practically impossible. For bonus points, 1G pages are being used on
the x86-64 so I have nowhere near enough memory to put that under TLB pressure.

Measuring reduced metadata overhead is more plausible.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
