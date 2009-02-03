Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id DB4755F0001
	for <linux-mm@kvack.org>; Tue,  3 Feb 2009 05:12:10 -0500 (EST)
Date: Tue, 3 Feb 2009 10:12:06 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [patch] SLQB slab allocator (try 2)
Message-ID: <20090203101205.GF9840@csn.ul.ie>
References: <20090123154653.GA14517@wotan.suse.de> <1232959706.21504.7.camel@penberg-laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1232959706.21504.7.camel@penberg-laptop>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Lin Ming <ming.m.lin@intel.com>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jan 26, 2009 at 10:48:26AM +0200, Pekka Enberg wrote:
> Hi Nick,
> 
> On Fri, 2009-01-23 at 16:46 +0100, Nick Piggin wrote:
> > Since last time, fixed bugs pointed out by Hugh and Andi, cleaned up the
> > code suggested by Ingo (haven't yet incorporated Ingo's last patch).
> > 
> > Should have fixed the crash reported by Yanmin (I was able to reproduce it
> > on an ia64 system and fix it).
> > 
> > Significantly reduced static footprint of init arrays, thanks to Andi's
> > suggestion.
> > 
> > Please consider for trial merge for linux-next.
> 
> I merged a the one you resent privately as this one didn't apply at all.
> The code is in topic/slqb/core branch of slab.git and should appear in
> linux-next tomorrow.
> 
> Testing and especially performance testing is welcome. If any of the HPC
> people are reading this, please do give SLQB a good beating as Nick's
> plan is to replace both, SLAB and SLUB, with it in the long run.As
> Christoph has expressed concerns over latency issues of SLQB, I suppose
> it would be interesting to hear if it makes any difference to the
> real-time folks.
> 

The HPC folks care about a few different workloads but speccpu is one that
shows up. I was in the position to run tests because I had put together
the test harness for a paper I spent the last month writing. This mail
shows a comparison between slab, slub and slqb for speccpu2006 running a
single thread and sysbench ranging clients from 1 to 4*num_online_cpus()
(16 in both cases). Additional tests were not run because just these two
take one day per kernel to complete. Results are ratios to the SLAB figures
and based on an x86-64 and ppc64 machine.

X86-64 Test machine
        CPU		AMD Phenom 9950 Quad-Core
        CPU Frequency   1.3GHz
        Physical CPUs	1 (4 cores)
        L1 Cache        64K Data, 64K Instruction per core
        L2 Cache        512K Unified per core
        L3 Cache        2048K Unified Shared per chip
        Main Memory     8 GB
        Mainboard       Gigabyte GA-MA78GM-S2H
        Machine Model   Custom built from parts

SPEC CPU 2006
-------------
Integer tests
SPEC test       slab         slub       slqb
400.perlbench   1.0000     1.0016     1.0064
401.bzip2       1.0000     0.9804     1.0011
403.gcc         1.0000     1.0023     0.9965
429.mcf         1.0000     1.0022     0.9963
445.gobmk       1.0000     0.9944     0.9986
456.hmmer       1.0000     0.9792     0.9701
458.sjeng       1.0000     0.9989     1.0133
462.libquantum  1.0000     0.9905     0.9981
464.h264ref     1.0000     0.9877     1.0058
471.omnetpp     1.0000     0.9893     1.0993
473.astar       1.0000     0.9542     0.9596
483.xalancbmk   1.0000     0.9547     0.9982
---------------
specint geomean 1.0000     0.9862     1.0031

Floating Point Tests
SPEC test       slab         slub       slqb
410.bwaves      1.0000     0.9939     1.0005
416.gamess      1.0000     1.0040     0.9984
433.milc        1.0000     0.9865     0.9865
434.zeusmp      1.0000     0.9810     0.9879
435.gromacs     1.0000     0.9854     1.0125
436.cactusADM   1.0000     1.0467     1.0294
437.leslie3d    1.0000     0.9846     0.9963
444.namd        1.0000     1.0000     1.0000
447.dealII      1.0000     0.9913     0.9957
450.soplex      1.0000     0.9940     1.0015
453.povray      1.0000     0.9904     1.0197
454.calculix    1.0000     0.9937     1.0000
459.GemsFDTD    1.0000     1.0061     1.0000
465.tonto       1.0000     0.9979     0.9989
470.lbm         1.0000     1.0099     1.0212
481.wrf         1.0000     1.0000     1.0045
482.sphinx3     1.0000     1.0047     1.0068
---------------
specfp geomean  1.0000     0.9981     1.0035

Sysbench - Postgres
-------------------
Client            slab       slub       slqb
     1          1.0000     0.9484     0.9804
     2          1.0000     1.0069     0.9994
     3          1.0000     1.0064     0.9994
     4          1.0000     0.9900     0.9904
     5          1.0000     1.0023     0.9869
     6          1.0000     1.0139     1.0069
     7          1.0000     0.9973     0.9991
     8          1.0000     1.0206     1.0197
     9          1.0000     0.9884     0.9817
    10          1.0000     0.9980     1.0135
    11          1.0000     0.9959     1.0164
    12          1.0000     0.9978     0.9953
    13          1.0000     1.0024     0.9942
    14          1.0000     0.9975     0.9808
    15          1.0000     0.9914     0.9933
    16          1.0000     0.9767     0.9726
--------------
Geometric mean  1.0000     0.9957     0.9955

On this particular x86-64, slab is on average faster for sysbench but
by a very small margin, less then 0.5%. I wasn't doing multiple runs for
each client number to see if this is within the noise but generally these
figures are quite stable. SPEC CPU is more interesting. Both SLUB and SLQB
regress on a number of the benchmarks although on average SLQB is very
marginally faster than SLAB (approx 0.3% faster) where SLUB is between
around 1% slower. Both SLUB and SLQB show big regressions on some tests:
hmmer, astar. omnetpp is also interesting in that SLUB regresses a little
and SLQB gains considerably. This is likely due to luck in cache placement.

Overall, while the regressions where they exist are troublesome, they are
also small and I strongly suspect there are far greater variances between
kernel releases due to changes other than the allocators. SLQB is the
winner, but by a minimal margin.

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
SPEC test       slab         slub       slqb
400.perlbench   1.0000     1.0497     1.0497
401.bzip2       1.0000     1.0496     1.0489
403.gcc         1.0000     1.0509     1.0509
429.mcf         1.0000     1.0554     1.0549
445.gobmk       1.0000     1.0535     1.0556
456.hmmer       1.0000     1.0651     1.0566
458.sjeng       1.0000     1.0612     1.0564
462.libquantum  1.0000     1.0389     1.0396
464.h264ref     1.0000     1.0517     1.0503
471.omnetpp     1.0000     1.0555     1.0574
473.astar       1.0000     1.0508     1.0521
483.xalancbmk   1.0000     1.0594     1.0584
---------------
specint geomean 1.0000     1.0534     1.0525

Floating Point Tests
SPEC test       slab         slub       slqb
410.bwaves      1.0000     1.0381     1.0367
416.gamess      1.0000     1.0550     1.0550
433.milc        1.0000     1.0464     1.0450
434.zeusmp      1.0000     1.0510     1.0528
435.gromacs     1.0000     1.0461     1.0445
436.cactusADM   1.0000     1.0457     1.0450
437.leslie3d    1.0000     1.0437     1.0428
444.namd        1.0000     1.0482     1.0496
447.dealII      1.0000     1.0505     1.0505
450.soplex      1.0000     1.0522     1.0499
453.povray      1.0000     1.0513     1.0534
454.calculix    1.0000     1.0374     1.0357
459.GemsFDTD    1.0000     1.0465     1.0465
465.tonto       1.0000     1.0488     1.0456
470.lbm         1.0000     1.0438     1.0452
481.wrf         1.0000     1.0423     1.0429
482.sphinx3     1.0000     1.0464     1.0479
---------------
specfp geomean  1.0000     1.0467     1.0464

Sysbench - Postgres
-------------------
Client            slab       slub       slqb
     1          1.0000     1.0153     1.0051
     2          1.0000     1.0273     1.0269
     3          1.0000     1.0299     1.0234
     4          1.0000     1.0159     1.0146
     5          1.0000     1.0232     1.0264
     6          1.0000     1.0238     1.0088
     7          1.0000     1.0240     1.0076
     8          1.0000     1.0134     1.0024
     9          1.0000     1.0154     1.0077
    10          1.0000     1.0126     1.0009
    11          1.0000     1.0100     0.9933
    12          1.0000     1.0112     0.9993
    13          1.0000     1.0131     1.0035
    14          1.0000     1.0237     1.0071
    15          1.0000     1.0098     0.9997
    16          1.0000     1.0110     0.9994
Geometric mean  1.0000     1.0175     1.0078

Unlike x86-64, ppc64 sees a consistent gain with with SLUB or SLQB and
the difference between SLUB and SLQB negligible on average with speccpu.
However, it is very noticeable sysbench where SLUB is generally a win in the
1% range over SLQB and SLQB regressed very marginally in a few instances. The
three benchmarks showing odd behaviour on x86-64, hmmer aster and omnetpp,
do not show similar weirdness on ppc64.

Overall on ppc64, SLUB is the winner by a clearer margin.

Summary
-------
The decision on whether to use SLUB, SLAB or SLQB for either speccpu 2006
and sysbench is not very clearcut. The win on ppc64 would imply SLUB is the
way to go but it is also clear that different architectures will produce
different results which needs to be taken into account when trying to
reproduce figures from other people.  I stronly suspect variations of the
same architecture will also show different results. Things like omnetpp on
x86-64 imply that how cache is used is a factor but it's down to luck how
what the result will be.

Downsides
---------
The SPEC CPU tests were not parallelised so there is no indication as to which
allocator might scale better to the number of CPUs. The test machines were
not NUMA so there is also no indication on which might be better there. There
wasn't a means of measuring allocator jitter. Queue cleaning means that some
allocations might stall, something that SLUB is expected to be immune to,
doesn't have a clear way of measuring but something other allocators could
potentially "cheat" on by postponing cleaning to a time when performance
is not being measured.  I wasn't tracking to see which consumed the least
memory so we don't know which is more memory efficient either.

The OLTP workload results could indicate a downside with using sysbench
although it could also be hardware. The reports from the Intel guys have been
pretty clear-cut that SLUB is a loser but sysbench-postgres on these test
machines at least do not agree. Of course their results are perfectly valid
but the discrepency needs to be explained or there will be a disconnect
between developers and the performance people.  Something important is
missing that means sysbench-postgres *may* not be a reliable indicator of
TPC-C performance.  It could easily be down to the hardware as their tests
are on a mega-large machine with oodles of disks and probably NUMA where
the test machine used for this is a lot less respectable.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
