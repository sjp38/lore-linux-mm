Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f174.google.com (mail-ea0-f174.google.com [209.85.215.174])
	by kanga.kvack.org (Postfix) with ESMTP id 6BD066B0031
	for <linux-mm@kvack.org>; Fri, 20 Dec 2013 11:44:33 -0500 (EST)
Received: by mail-ea0-f174.google.com with SMTP id b10so1175371eae.33
        for <linux-mm@kvack.org>; Fri, 20 Dec 2013 08:44:32 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r9si9526872eeo.107.2013.12.20.08.44.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 20 Dec 2013 08:44:32 -0800 (PST)
Date: Fri, 20 Dec 2013 16:44:26 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 0/4] Fix ebizzy performance regression due to X86 TLB
 range flush v2
Message-ID: <20131220164426.GD11295@suse.de>
References: <1386964870-6690-1-git-send-email-mgorman@suse.de>
 <20131218072814.GA798@localhost>
 <20131219143449.GN11295@suse.de>
 <20131220155143.GA22595@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20131220155143.GA22595@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Alex Shi <alex.shi@linaro.org>, Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, H Peter Anvin <hpa@zytor.com>, Linux-X86 <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Dec 20, 2013 at 11:51:43PM +0800, Fengguang Wu wrote:
> On Thu, Dec 19, 2013 at 02:34:50PM +0000, Mel Gorman wrote:
> > On Wed, Dec 18, 2013 at 03:28:14PM +0800, Fengguang Wu wrote:
> > > Hi Mel,
> > > 
> > > I'd like to share some test numbers with your patches applied on top of v3.13-rc3.
> > > 
> > > Basically there are
> > > 
> > > 1) no big performance changes
> > > 
> > >   76628486           -0.7%   76107841       TOTAL vm-scalability.throughput
> > >     407038           +1.2%     412032       TOTAL hackbench.throughput
> > >      50307           -1.5%      49549       TOTAL ebizzy.throughput
> > > 
> > 
> > I'm assuming this was an ivybridge processor.
> 
> The test boxes brickland2 and lkp-ib03 are ivybridge; lkp-snb01 is sandybridge.
> 

Ok.

> > How many threads were ebizzy tested with?
> 
> The below case has params string "400%-5-30", which means
> 
>         nr_threads = 400% * nr_cpu = 4 * 48 = 192
>         iterations = 5
>         duration = 30
> 
>       v3.13-rc3       eabb1f89905a0c809d13
> ---------------  -------------------------  
>      50307 ~ 1%      -1.5%      49549 ~ 0%  lkp-ib03/micro/ebizzy/400%-5-30
>      50307           -1.5%      49549       TOTAL ebizzy.throughput
> 

That is a limited range of threads to test with but ok.

> > The memory ranges used by the vm scalability benchmarks are
> > probably too large to be affected by the series but I'm guessing.
> 
> Do you mean these lines?
> 
>    3345155 ~ 0%      -0.3%    3335172 ~ 0%  brickland2/micro/vm-scalability/16G-shm-pread-rand-mt
>   33249939 ~ 0%      +3.3%   34336155 ~ 1%  brickland2/micro/vm-scalability/1T-shm-pread-seq     
> 
> The two cases run 128 threads/processes, each accessing randomly/sequentially
> a 64GB shm file concurrently. Sorry the 16G/1T prefixes are somehow misleading.
> 

It's ok, the conclusion is still the same. The regions are still too
large to be really affected the series.

> > I doubt hackbench is doing any flushes and the 1.2% is noise.
> 
> Here are the proc-vmstat.nr_tlb_remote_flush numbers for hackbench:
> 
>        513 ~ 3%  +4.3e+16%  2.192e+17 ~85%  lkp-nex05/micro/hackbench/800%-process-pipe
>        603 ~ 3%  +7.7e+16%  4.669e+17 ~13%  lkp-nex05/micro/hackbench/800%-process-socket
>       6124 ~17%  +5.7e+15%  3.474e+17 ~26%  lkp-nex05/micro/hackbench/800%-threads-pipe
>       7565 ~49%  +5.5e+15%  4.128e+17 ~68%  lkp-nex05/micro/hackbench/800%-threads-socket
>      21252 ~ 6%  +1.3e+15%  2.728e+17 ~39%  lkp-snb01/micro/hackbench/1600%-threads-pipe
>      24516 ~16%  +8.3e+14%  2.034e+17 ~53%  lkp-snb01/micro/hackbench/1600%-threads-socket
> 

This is a surprise. The differences I can understand because of changes
in accounting but not the flushes themselves. The only flushes I would
expect are when the process exits and the regions are torn down.

The exception would be if automatic NUMA balancing was enabled and this
was a NUMA machine. In that case, NUMA hinting faults could be migrating
memory and triggering flushes.

Could you do something like

# perf probe native_flush_tlb_others
# cd /sys/kernel/debug/tracing
# echo sym-offset > trace_options
# echo sym-addr > trace_options
# echo stacktrace > trace_options
# echo 1 > events/probe/native_flush_tlb_others/enable
# cat trace_pipe > /tmp/log

and get a breakdown of what the source of these remote flushes are
please?

> This time, the ebizzy params are refreshed and the test case is
> exercised in all our test machines. The results that have changed are:
> 
>       v3.13-rc3       eabb1f89905a0c809d13  
> ---------------  -------------------------  
>        873 ~ 0%      +0.7%        879 ~ 0%  lkp-a03/micro/ebizzy/200%-100-10
>        873 ~ 0%      +0.7%        879 ~ 0%  lkp-a04/micro/ebizzy/200%-100-10
>        873 ~ 0%      +0.8%        880 ~ 0%  lkp-a06/micro/ebizzy/200%-100-10
>      49242 ~ 0%      -1.2%      48650 ~ 0%  lkp-ib03/micro/ebizzy/200%-100-10
>      26176 ~ 0%      -1.6%      25760 ~ 0%  lkp-sbx04/micro/ebizzy/200%-100-10
>       2738 ~ 0%      +0.2%       2744 ~ 0%  lkp-t410/micro/ebizzy/200%-100-10
>      80776           -1.2%      79793       TOTAL ebizzy.throughput
> 

No change on lkp-ib03 which I would have expected some difference. Thing
is, for ebizzy to notice the number of TLB entries matter. On both
machines I tested, the last level TLB had 512 entries. How many entries
are on the last level TLB on lkp-ib03?

> > I do see a few major regressions like this
> > 
> > >     324497 ~ 0%    -100.0%          0 ~ 0%  brickland2/micro/vm-scalability/16G-truncate
> > 
> > but I have no idea what the test is doing and whether something happened
> > that the test broke that time or if it's something to be really
> > concerned about.
> 
> This test case simply creates sparse files, populate them with zeros,
> then delete them in parallel. Here $mem is physical memory size 128G,
> $nr_cpu is 120.
> 
> for i in `seq $nr_cpu`
> do      
>         create_sparse_file $SPARSE_FILE-$i $((mem / nr_cpu))
>         cp $SPARSE_FILE-$i /dev/null
> done
> 
> for i in `seq $nr_cpu`
> do      
>         rm $SPARSE_FILE-$i &
> done
> 

In itself, that does not explain why the result was 0 with the series
applied. The 3.13-rc3 result was "324497". 324497 what?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
