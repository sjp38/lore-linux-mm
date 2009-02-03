Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id DE6BF5F0001
	for <linux-mm@kvack.org>; Tue,  3 Feb 2009 06:22:30 -0500 (EST)
Date: Tue, 3 Feb 2009 11:22:26 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [patch] SLQB slab allocator (try 2)
Message-ID: <20090203112226.GG9840@csn.ul.ie>
References: <20090123154653.GA14517@wotan.suse.de> <1232959706.21504.7.camel@penberg-laptop> <20090203101205.GF9840@csn.ul.ie> <200902032136.26022.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <200902032136.26022.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Lin Ming <ming.m.lin@intel.com>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, Feb 03, 2009 at 09:36:24PM +1100, Nick Piggin wrote:
> On Tuesday 03 February 2009 21:12:06 Mel Gorman wrote:
> > On Mon, Jan 26, 2009 at 10:48:26AM +0200, Pekka Enberg wrote:
> > > Hi Nick,
> > >
> > > On Fri, 2009-01-23 at 16:46 +0100, Nick Piggin wrote:
> > > > Since last time, fixed bugs pointed out by Hugh and Andi, cleaned up
> > > > the code suggested by Ingo (haven't yet incorporated Ingo's last
> > > > patch).
> > > >
> > > > Should have fixed the crash reported by Yanmin (I was able to reproduce
> > > > it on an ia64 system and fix it).
> > > >
> > > > Significantly reduced static footprint of init arrays, thanks to Andi's
> > > > suggestion.
> > > >
> > > > Please consider for trial merge for linux-next.
> > >
> > > I merged a the one you resent privately as this one didn't apply at all.
> > > The code is in topic/slqb/core branch of slab.git and should appear in
> > > linux-next tomorrow.
> > >
> > > Testing and especially performance testing is welcome. If any of the HPC
> > > people are reading this, please do give SLQB a good beating as Nick's
> > > plan is to replace both, SLAB and SLUB, with it in the long run.As
> > > Christoph has expressed concerns over latency issues of SLQB, I suppose
> > > it would be interesting to hear if it makes any difference to the
> > > real-time folks.
> >
> > The HPC folks care about a few different workloads but speccpu is one that
> > shows up. I was in the position to run tests because I had put together
> > the test harness for a paper I spent the last month writing. This mail
> > shows a comparison between slab, slub and slqb for speccpu2006 running a
> > single thread and sysbench ranging clients from 1 to 4*num_online_cpus()
> > (16 in both cases). Additional tests were not run because just these two
> > take one day per kernel to complete. Results are ratios to the SLAB figures
> > and based on an x86-64 and ppc64 machine.
> 
> Hi Mel,
> 
> This is very nice, thanks for testing.

Sure. It's been on my TODO list for long enough :). I should have been
clear that the ratios are performance improvements based on wall time.
A result of 0.9862 implies a performance regression of 1.38% in comparison
to SLAB. 1.0031 implies a performance gain of 0.31% etc.

> SLQB and SLUB are quite similar
> in a lot of cases, which indeed could be explained by cacheline placement
> (both of these can allocate down to much smaller sizes, and both of them
> also put metadata directly in free object memory rather than external
> locations).
> 

Indeed. I know from other tests that poor cacheline placement can crucify
performance. My current understanding is we don't notice as data and metadata
are effectively using random cache lines.

> But it will be interesting to try looking at some of the tests where
> SLQB has larger regressions, so that might give me something to go on
> if I can lay my hands on speccpu2006...
> 

I can generate profile runs although it'll take 3 days to gather it all
together unless I target specific tests (the worst ones to start with
obviously). The suite has a handy feature called monitor hooks that allows
a pre and post script to run for each test which I use it to start/stop
oprofile and gather one report per benchmark. I didn't use it for this run
as profiling affects the outcome (7-9% overhead).

I do have detailed profile data available for sysbench, both per thread run
and the entire run but with the instruction-level included, it's a lot of
data to upload. If you still want it, I'll start it going and it'll get up
there eventually.

> I'd be interested to see how slub performs if booted with slub_min_objects=1
> (which should give similar order pages to SLAB and SLQB).
> 

I'll do this before profiling as only one run is required and should
only take a day.

Making spec actually build is tricky so I've included a sample config for
x86-64 below that uses gcc and the monitor hooks in case someone else is in
the position to repeat the results.

===== Begin sample spec config file =====
# Autogenerated by generate-speccpu.sh

## Base configuration
ignore_errors      = no
tune               = base
ext                = x86_64-m64-gcc42
output_format      = asc, pdf, Screen
reportable         = 1
teeout             = yes
teerunout          = yes
hw_avail           = September 2008
license_num        = 
test_sponsor       = 
prepared_by        = Mel Gorman
tester             = Mel Gorman
test_date          = Dec 2008

## Compiler
CC                 = gcc-4.2
CXX                = g++-4.2
FC                 = gfortran-4.2

## HW config
hw_model           = Gigabyte Technology Co., Ltd. GA-MA78GM-S2H
hw_cpu_name        = AMD Phenom(tm) 9950 Quad-Core Processor
hw_cpu_char        = 
hw_cpu_mhz         = 1300.000
hw_fpu             = Integrated
hw_nchips          = 1
hw_ncores          = 4
hw_ncoresperchip   = 4
hw_nthreadspercore = 1
hw_ncpuorder       = 
hw_pcache          = L1 64K Data, 64K Instruction per core
hw_scache          = L2 512K Unified per core
hw_tcache          = L3 2048K Unified Shared per chip
hw_ocache          = 
hw_memory          = 4594MB
hw_disk            = SATA WD5000AAKS-00A7B0
hw_vendor          = Komplett.ie

## SW config
sw_os              = Debian Lenny Beta for x86_64
sw_file            = ext3
sw_state           = Runlevel [2]
sw_compiler        = gcc, g++ & gfortran 4.2 for x86_64
sw_avail           = Dec 2008
sw_other           = None
sw_auto_parallel   = No
sw_base_ptrsize    = 64-bit
sw_peak_ptrsize    = Not Applicable

## Monitor hooks
monitor_pre_bench = /home/mel/git-public/vmregress/bin/oprofile_start.sh  --event timer --event dtlb_miss; echo iter >> /tmp/OPiter.${lognum}.${size_class}.${benchmark}
monitor_post_bench = opcontrol --stop ; /home/mel/git-public/vmregress/bin/oprofile_report.sh > `dirname ${logname}`/OP.${lognum}.${size_class}.iter`cat /tmp/OPiter.${lognum}.${size_class}.${benchmark} | wc -l`.${benchmark}.txt

## Optimisation
makeflags          = -j4
COPTIMIZE          = -O2 -m64
CXXOPTIMIZE        = -O2 -m64
FOPTIMIZE          = -O2 -m64

notes0100= C base flags: $[COPTIMIZE]
notes0110= C++ base flags: $[CXXOPTIMIZE]
notes0120= Fortran base flags: $[FOPTIMIZE]

## Portability flags - all
default=base=default=default:
notes35            = PORTABILITY=-DSPEC_CPU_LP64 is applied to all benchmarks
PORTABILITY        = -DSPEC_CPU_LP64

## Portability flags - int
400.perlbench=default=default=default:
CPORTABILITY       = -DSPEC_CPU_LINUX_X64
notes35            = 400.perlbench: -DSPEC_CPU_LINUX_X64

462.libquantum=default=default=default:
CPORTABILITY       = -DSPEC_CPU_LINUX
notes60            = 462.libquantum: -DSPEC_CPU_LINUX

483.xalancbmk=default=default=default:
CXXPORTABILITY       = -DSPEC_CPU_LINUX

## Portability flags - flt
481.wrf=default=default=default:
CPORTABILITY      = -DSPEC_CPU_CASE_FLAG -DSPEC_CPU_LINUX

__MD5__

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
