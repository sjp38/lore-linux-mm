Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id D81EB6B0031
	for <linux-mm@kvack.org>; Fri, 20 Dec 2013 10:52:18 -0500 (EST)
Received: by mail-pd0-f170.google.com with SMTP id g10so2690979pdj.29
        for <linux-mm@kvack.org>; Fri, 20 Dec 2013 07:52:18 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [143.182.124.37])
        by mx.google.com with ESMTP id dv5si5568856pbb.13.2013.12.20.07.51.51
        for <linux-mm@kvack.org>;
        Fri, 20 Dec 2013 07:51:52 -0800 (PST)
Date: Fri, 20 Dec 2013 23:51:43 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [PATCH 0/4] Fix ebizzy performance regression due to X86 TLB
 range flush v2
Message-ID: <20131220155143.GA22595@localhost>
References: <1386964870-6690-1-git-send-email-mgorman@suse.de>
 <20131218072814.GA798@localhost>
 <20131219143449.GN11295@suse.de>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="WIyZ46R2i8wDzkSu"
Content-Disposition: inline
In-Reply-To: <20131219143449.GN11295@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Alex Shi <alex.shi@linaro.org>, Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, H Peter Anvin <hpa@zytor.com>, Linux-X86 <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>


--WIyZ46R2i8wDzkSu
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Dec 19, 2013 at 02:34:50PM +0000, Mel Gorman wrote:
> On Wed, Dec 18, 2013 at 03:28:14PM +0800, Fengguang Wu wrote:
> > Hi Mel,
> > 
> > I'd like to share some test numbers with your patches applied on top of v3.13-rc3.
> > 
> > Basically there are
> > 
> > 1) no big performance changes
> > 
> >   76628486           -0.7%   76107841       TOTAL vm-scalability.throughput
> >     407038           +1.2%     412032       TOTAL hackbench.throughput
> >      50307           -1.5%      49549       TOTAL ebizzy.throughput
> > 
> 
> I'm assuming this was an ivybridge processor.

The test boxes brickland2 and lkp-ib03 are ivybridge; lkp-snb01 is sandybridge.

> How many threads were ebizzy tested with?

The below case has params string "400%-5-30", which means

        nr_threads = 400% * nr_cpu = 4 * 48 = 192
        iterations = 5
        duration = 30

      v3.13-rc3       eabb1f89905a0c809d13
---------------  -------------------------  
     50307 ~ 1%      -1.5%      49549 ~ 0%  lkp-ib03/micro/ebizzy/400%-5-30
     50307           -1.5%      49549       TOTAL ebizzy.throughput

> The memory ranges used by the vm scalability benchmarks are
> probably too large to be affected by the series but I'm guessing.

Do you mean these lines?

   3345155 ~ 0%      -0.3%    3335172 ~ 0%  brickland2/micro/vm-scalability/16G-shm-pread-rand-mt
  33249939 ~ 0%      +3.3%   34336155 ~ 1%  brickland2/micro/vm-scalability/1T-shm-pread-seq     

The two cases run 128 threads/processes, each accessing randomly/sequentially
a 64GB shm file concurrently. Sorry the 16G/1T prefixes are somehow misleading.

> I doubt hackbench is doing any flushes and the 1.2% is noise.

Here are the proc-vmstat.nr_tlb_remote_flush numbers for hackbench:

       513 ~ 3%  +4.3e+16%  2.192e+17 ~85%  lkp-nex05/micro/hackbench/800%-process-pipe
       603 ~ 3%  +7.7e+16%  4.669e+17 ~13%  lkp-nex05/micro/hackbench/800%-process-socket
      6124 ~17%  +5.7e+15%  3.474e+17 ~26%  lkp-nex05/micro/hackbench/800%-threads-pipe
      7565 ~49%  +5.5e+15%  4.128e+17 ~68%  lkp-nex05/micro/hackbench/800%-threads-socket
     21252 ~ 6%  +1.3e+15%  2.728e+17 ~39%  lkp-snb01/micro/hackbench/1600%-threads-pipe
     24516 ~16%  +8.3e+14%  2.034e+17 ~53%  lkp-snb01/micro/hackbench/1600%-threads-socket

I tried rebuild kernels with distclean and this time got the below
hackbench changes. I'll queue the hackbench test in all our test boxes
to get a more complete evaluation.

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
    232925 ~ 0%      -8.4%     213339 ~ 5%  lkp-snb01/micro/hackbench/1600%-process-pipe
    232925           -8.4%     213339       TOTAL hackbench.throughput

This time, the ebizzy params are refreshed and the test case is
exercised in all our test machines. The results that have changed are:

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
       873 ~ 0%      +0.7%        879 ~ 0%  lkp-a03/micro/ebizzy/200%-100-10
       873 ~ 0%      +0.7%        879 ~ 0%  lkp-a04/micro/ebizzy/200%-100-10
       873 ~ 0%      +0.8%        880 ~ 0%  lkp-a06/micro/ebizzy/200%-100-10
     49242 ~ 0%      -1.2%      48650 ~ 0%  lkp-ib03/micro/ebizzy/200%-100-10
     26176 ~ 0%      -1.6%      25760 ~ 0%  lkp-sbx04/micro/ebizzy/200%-100-10
      2738 ~ 0%      +0.2%       2744 ~ 0%  lkp-t410/micro/ebizzy/200%-100-10
     80776           -1.2%      79793       TOTAL ebizzy.throughput

The full change set is attached.

> > 2) huge proc-vmstat.nr_tlb_* increases
> > 
> >   99986527         +3e+14%  2.988e+20       TOTAL proc-vmstat.nr_tlb_local_flush_one
> >  3.812e+08       +2.2e+13%  8.393e+19       TOTAL proc-vmstat.nr_tlb_remote_flush_received
> >  3.301e+08       +2.2e+13%  7.241e+19       TOTAL proc-vmstat.nr_tlb_remote_flush
> >    5990864       +1.2e+15%  7.032e+19       TOTAL proc-vmstat.nr_tlb_local_flush_all
> > 
> 
> The accounting changes can be mostly explained by "x86: mm: Clean up
> inconsistencies when flushing TLB ranges". flush_all was simply not
> being counted before so I would claim that the old figure was simply
> wrong and did not reflect reality.
> 
> Alterations on when range versus global flushes would affect the other
> counters but arguably it's now behaving as originally intended by the tlb
> flush shift.

OK.

> > Here are the detailed numbers. eabb1f89905a0c809d13 is the HEAD commit
> > with 4 patches applied. The "~ N%" notations are the stddev percent.
> > The "[+-] N%" notations are the increase/decrease percent. The
> > brickland2, lkp-snb01, lkp-ib03 etc. are testbox names.
> > 
> 
> Are positive numbers always better?

Not necessarily. A positive change merely means the absolute numbers
of hackbench.throughput, ebizzy.throughput, etc. are increased in the
new kernel. But yes, for the above stats, it happen to be "the higher,
the better".

> If so, most of these figures look good to me and support the series
> being merged. Please speak up if that is in error.

Agreed, except that I'll need to re-evaluate the hackbench test case.

> I do see a few major regressions like this
> 
> >     324497 ~ 0%    -100.0%          0 ~ 0%  brickland2/micro/vm-scalability/16G-truncate
> 
> but I have no idea what the test is doing and whether something happened
> that the test broke that time or if it's something to be really
> concerned about.

This test case simply creates sparse files, populate them with zeros,
then delete them in parallel. Here $mem is physical memory size 128G,
$nr_cpu is 120.

for i in `seq $nr_cpu`
do      
        create_sparse_file $SPARSE_FILE-$i $((mem / nr_cpu))
        cp $SPARSE_FILE-$i /dev/null
done

for i in `seq $nr_cpu`
do      
        rm $SPARSE_FILE-$i &
done

Thanks,
Fengguang

--WIyZ46R2i8wDzkSu
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=eabb1f89905a0c809d13ec27795ced089c107eb8

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
    232925 ~ 0%      -8.4%     213339 ~ 5%  lkp-snb01/micro/hackbench/1600%-process-pipe
    232925           -8.4%     213339       TOTAL hackbench.throughput

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
    136.87 ~ 1%      +4.4%     142.90 ~ 2%  lkp-nex04/micro/ebizzy/400%-5-30
     32.60 ~ 0%      +0.8%      32.86 ~ 0%  lkp-sb03/micro/ebizzy/200%-100-10
     41.25 ~ 0%      -1.9%      40.48 ~ 0%  lkp-sbx04/micro/ebizzy/200%-100-10
     26.37 ~ 0%      -1.2%      26.06 ~ 0%  xps2/micro/ebizzy/200%-100-10
    237.09           +2.2%     242.29       TOTAL ebizzy.time.user

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
      4934 ~ 0%      +0.7%       4971 ~ 0%  lkp-ib03/micro/netperf/120s-200%-TCP_CRR
     29583 ~ 0%      +2.2%      30237 ~ 0%  lkp-ib03/micro/netperf/120s-200%-TCP_RR
     34517           +2.0%      35208       TOTAL netperf.Throughput_tps

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
       873 ~ 0%      +0.7%        879 ~ 0%  lkp-a03/micro/ebizzy/200%-100-10
       873 ~ 0%      +0.7%        879 ~ 0%  lkp-a04/micro/ebizzy/200%-100-10
       873 ~ 0%      +0.8%        880 ~ 0%  lkp-a06/micro/ebizzy/200%-100-10
     49242 ~ 0%      -1.2%      48650 ~ 0%  lkp-ib03/micro/ebizzy/200%-100-10
     26176 ~ 0%      -1.6%      25760 ~ 0%  lkp-sbx04/micro/ebizzy/200%-100-10
      2738 ~ 0%      +0.2%       2744 ~ 0%  lkp-t410/micro/ebizzy/200%-100-10
     80776           -1.2%      79793       TOTAL ebizzy.throughput

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
     27493 ~ 5%      +4.1%      28614 ~ 0%  lkp-nex05/micro/tlbflush/100%-512-320
     27493           +4.1%      28614       TOTAL tlbflush.mem_acc_time_thread_ms

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
   1770.22 ~ 0%      -0.4%    1763.99 ~ 0%  lkp-nex04/micro/ebizzy/400%-5-30
    286.57 ~ 0%      -0.1%     286.30 ~ 0%  lkp-sb03/micro/ebizzy/200%-100-10
    594.92 ~ 0%      +0.1%     595.68 ~ 0%  lkp-sbx04/micro/ebizzy/200%-100-10
     53.35 ~ 0%      +0.6%      53.67 ~ 0%  xps2/micro/ebizzy/200%-100-10
   2705.06           -0.2%    2699.64       TOTAL ebizzy.time.sys

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
       427 ~16%     -91.7%         35 ~ 3%  avoton1/crypto/tcrypt/2s-505-509
 7.141e+08 ~ 1%  +1.3e+10%  9.593e+16 ~ 8%  grantley/micro/ebizzy/200%-100-10
  23867179 ~ 8%    -100.0%          0 ~ 0%  kbuildx/micro/ebizzy/200%-100-10
   1230047 ~ 0%  +2.6e+12%  3.186e+16 ~61%  lkp-a04/micro/ebizzy/200%-100-10
       256 ~10%  +9.2e+16%  2.349e+17 ~27%  lkp-a04/micro/netperf/120s-200%-TCP_STREAM
 1.158e+09 ~ 0%  +6.3e+09%  7.291e+16 ~45%  lkp-ib03/micro/ebizzy/200%-100-10
      2495 ~40%    +1e+16%  2.545e+17 ~126%  lkp-ib03/micro/netperf/120s-200%-TCP_CRR
      1537 ~ 2%  +3.8e+16%  5.812e+17 ~81%  lkp-ib03/micro/netperf/120s-200%-TCP_MAERTS
      1420 ~ 5%  +5.9e+16%  8.376e+17 ~ 9%  lkp-ib03/micro/netperf/120s-200%-TCP_RR
      1751 ~16%    +1e+18%  1.808e+19 ~ 0%  lkp-ib03/micro/netperf/120s-200%-TCP_SENDFILE
      1392 ~ 4%  +2.4e+16%    3.3e+17 ~75%  lkp-ib03/micro/netperf/120s-200%-TCP_STREAM
      1534 ~ 6%    +2e+16%  3.083e+17 ~76%  lkp-ib03/micro/netperf/120s-200%-UDP_RR
  25457451 ~ 2%  +2.2e+11%  5.683e+16 ~21%  lkp-nex04/micro/tlbflush/200%-512-320
 3.545e+08 ~ 0%  +7.3e+10%  2.601e+17 ~31%  lkp-nex05/micro/ebizzy/200%-100-10
  25434301 ~ 4%  +8.5e+11%  2.173e+17 ~46%  lkp-nex05/micro/tlbflush/100%-512-320
 5.899e+08 ~ 0%  +1.1e+10%  6.465e+16 ~32%  lkp-sb03/micro/ebizzy/200%-100-10
 8.239e+08 ~ 0%  +1.7e+10%  1.426e+17 ~18%  lkp-sbx04/micro/ebizzy/200%-100-10
 5.979e+08 ~ 3%  +1.1e+10%  6.421e+16 ~59%  lkp-snb01/micro/ebizzy/200%-100-10
      2018 ~ 2%  +5.5e+15%  1.108e+17 ~19%  lkp-snb01/micro/hackbench/1600%-process-pipe
      2337 ~ 1%  +6.8e+15%  1.596e+17 ~25%  lkp-snb01/micro/hackbench/1600%-process-socket
    238535 ~22%  +1.1e+14%  2.564e+17 ~13%  lkp-snb01/micro/hackbench/1600%-threads-pipe
    308286 ~ 9%  +5.9e+13%  1.827e+17 ~11%  lkp-snb01/micro/hackbench/1600%-threads-socket
        15 ~ 3%    +8e+16%  1.249e+16 ~70%  lkp-t410/micro/ebizzy/200%-100-10
  21000804 ~ 0%  +1.6e+11%  3.386e+16 ~63%  nhm-white/sysbench/oltp/600s-100%-1000000
 1.621e+08 ~ 0%  +2.9e+10%  4.765e+16 ~42%  nhm8/micro/ebizzy/200%-100-10
  22806224 ~15%    -100.0%          0 ~ 0%  vpx/micro/ebizzy/200%-100-10
  88288455 ~ 0%  +3.9e+10%   3.42e+16 ~47%  xps2/micro/ebizzy/200%-100-10
 4.609e+09       +4.9e+11%  2.247e+19       TOTAL proc-vmstat.nr_tlb_remote_flush_received

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
       140 ~ 6%    -100.0%          0 ~ 0%  avoton1/crypto/tcrypt/2s-505-509
  13005586 ~ 1%  +7.2e+11%  9.398e+16 ~25%  grantley/micro/ebizzy/200%-100-10
   7994499 ~ 8%    -100.0%          0 ~ 0%  kbuildx/micro/ebizzy/200%-100-10
    436762 ~ 0%  +7.3e+12%  3.186e+16 ~61%  lkp-a04/micro/ebizzy/200%-100-10
       188 ~16%    -100.0%          0       lkp-a04/micro/netperf/120s-200%-TCP_RR
  24658539 ~ 0%  +2.3e+11%   5.63e+16 ~26%  lkp-ib03/micro/ebizzy/200%-100-10
       230 ~15%  +1.5e+17%  3.542e+17 ~116%  lkp-ib03/micro/netperf/120s-200%-TCP_CRR
       196 ~10%  +3.3e+17%  6.465e+17 ~51%  lkp-ib03/micro/netperf/120s-200%-TCP_MAERTS
       219 ~ 4%  +7.9e+12%  1.724e+13 ~ 0%  lkp-ib03/micro/netperf/120s-200%-TCP_SENDFILE
       160 ~15%  +1.3e+17%  2.072e+17 ~92%  lkp-ib03/micro/netperf/120s-200%-TCP_STREAM
       192 ~14%  +2.3e+17%  4.365e+17 ~11%  lkp-ib03/micro/netperf/120s-200%-UDP_RR
  20661685 ~ 0%    +5e+10%   1.03e+16 ~70%  lkp-ne04/micro/ebizzy/200%-100-10
    411585 ~ 2%  +9.9e+12%  4.055e+16 ~28%  lkp-nex04/micro/tlbflush/200%-512-320
   5657998 ~ 0%  +3.8e+12%  2.176e+17 ~21%  lkp-nex05/micro/ebizzy/200%-100-10
    420583 ~ 4%  +4.1e+13%  1.719e+17 ~68%  lkp-nex05/micro/tlbflush/100%-512-320
  19058842 ~ 0%  +2.9e+11%  5.576e+16 ~29%  lkp-sb03/micro/ebizzy/200%-100-10
  13106426 ~ 0%  +4.7e+11%  6.199e+16 ~40%  lkp-sbx04/micro/ebizzy/200%-100-10
  19314329 ~ 3%  +2.6e+11%      5e+16 ~20%  lkp-snb01/micro/ebizzy/200%-100-10
       510 ~ 1%  +2.9e+16%  1.468e+17 ~25%  lkp-snb01/micro/hackbench/1600%-process-pipe
       756 ~ 5%  +1.9e+16%  1.424e+17 ~56%  lkp-snb01/micro/hackbench/1600%-process-socket
     19158 ~15%  +1.6e+15%  2.983e+17 ~35%  lkp-snb01/micro/hackbench/1600%-threads-pipe
     20757 ~ 9%  +7.1e+14%  1.478e+17 ~20%  lkp-snb01/micro/hackbench/1600%-threads-socket
   3659073 ~ 0%  +1.1e+11%  4.106e+15 ~141%  nhm-white/sysbench/oltp/600s-100%-1000000
  14767833 ~ 0%  +1.1e+11%  1.698e+16 ~126%  nhm8/micro/ebizzy/200%-100-10
   7639068 ~15%    -100.0%          0 ~ 0%  vpx/micro/ebizzy/200%-100-10
  12652913 ~ 0%  +1.7e+11%  2.104e+16 ~35%  xps2/micro/ebizzy/200%-100-10
 1.635e+08         +2e+12%  3.212e+18       TOTAL proc-vmstat.nr_tlb_remote_flush

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
    269335 ~ 0%    -100.0%          0 ~ 0%  avoton1/crypto/tcrypt/2s-505-509
    617727 ~ 0%  +1.8e+13%  1.108e+17 ~29%  grantley/micro/ebizzy/200%-100-10
    321613 ~ 0%    -100.0%         15 ~60%  kbuildx/micro/ebizzy/200%-100-10
    348216 ~ 0%  +9.2e+12%  3.186e+16 ~61%  lkp-a04/micro/ebizzy/200%-100-10
    104866 ~ 1%    -100.0%          0 ~ 0%  lkp-a04/micro/netperf/120s-200%-TCP_RR
    104585 ~ 0%    -100.0%          0 ~ 0%  lkp-a04/micro/netperf/120s-200%-UDP_RR
    773781 ~ 0%  +7.7e+12%  5.962e+16 ~18%  lkp-ib03/micro/ebizzy/200%-100-10
  29318914 ~ 0%  +1.1e+12%  3.254e+17 ~118%  lkp-ib03/micro/netperf/120s-200%-TCP_CRR
    250366 ~ 0%  +2.6e+14%   6.44e+17 ~53%  lkp-ib03/micro/netperf/120s-200%-TCP_MAERTS
    249838 ~ 0%  +1.2e+14%  2.999e+17 ~41%  lkp-ib03/micro/netperf/120s-200%-TCP_RR
    250035 ~ 0%  +7.2e+15%  1.808e+19 ~ 0%  lkp-ib03/micro/netperf/120s-200%-TCP_SENDFILE
    247778 ~ 2%  +1.2e+14%  2.903e+17 ~105%  lkp-ib03/micro/netperf/120s-200%-TCP_STREAM
    251020 ~ 0%  +1.9e+14%  4.663e+17 ~ 4%  lkp-ib03/micro/netperf/120s-200%-UDP_RR
   1231993 ~ 2%  +4.6e+12%  5.683e+16 ~21%  lkp-nex04/micro/tlbflush/200%-512-320
    842151 ~ 0%  +2.3e+13%   1.94e+17 ~21%  lkp-nex05/micro/ebizzy/200%-100-10
   1327483 ~13%  +1.5e+13%  2.036e+17 ~65%  lkp-nex05/micro/tlbflush/100%-512-320
    770590 ~ 0%  +6.6e+12%  5.098e+16 ~68%  lkp-sb03/micro/ebizzy/200%-100-10
    926878 ~ 0%    +8e+12%   7.44e+16 ~23%  lkp-sbx04/micro/ebizzy/200%-100-10
    787757 ~ 4%  +8.3e+12%  6.524e+16 ~35%  lkp-snb01/micro/ebizzy/200%-100-10
   6467223 ~ 1%  +2.5e+12%  1.607e+17 ~32%  lkp-snb01/micro/hackbench/1600%-process-pipe
   4375452 ~ 1%  +8.2e+12%  3.583e+17 ~14%  lkp-snb01/micro/hackbench/1600%-process-socket
   1382546 ~ 0%    +2e+13%   2.71e+17 ~37%  lkp-snb01/micro/hackbench/1600%-threads-pipe
   1122990 ~ 1%  +4.3e+13%  4.775e+17 ~42%  lkp-snb01/micro/hackbench/1600%-threads-socket
   3781598 ~ 1%  +6.2e+11%  2.342e+16 ~44%  nhm-white/sysbench/oltp/600s-100%-1000000
    320787 ~ 0%    -100.0%         21 ~30%  vpx/micro/ebizzy/200%-100-10
    467399 ~ 0%  +5.9e+12%  2.762e+16 ~30%  xps2/micro/ebizzy/200%-100-10
  56912929       +3.9e+13%  2.227e+19       TOTAL proc-vmstat.nr_tlb_local_flush_one

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
        37 ~68%    +401.8%        185 ~17%  lkp-sbx04/micro/ebizzy/200%-100-10
        37         +401.8%        185       TOTAL pagetypeinfo.Node1.Normal.Unmovable.3

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
        87 ~62%    +171.4%        237 ~13%  lkp-sbx04/micro/ebizzy/200%-100-10
        87         +171.4%        237       TOTAL buddyinfo.Node.1.zone.Normal.3

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
     30206 ~ 0%     -87.5%       3785 ~ 4%  avoton1/crypto/tcrypt/2s-505-509
  13077898 ~ 1%  +7.4e+11%  9.631e+16 ~29%  grantley/micro/ebizzy/200%-100-10
   8072671 ~ 8%     -99.9%       8577 ~17%  kbuildx/micro/ebizzy/200%-100-10
    477416 ~ 0%  +6.7e+12%  3.186e+16 ~61%  lkp-a04/micro/ebizzy/200%-100-10
     10784 ~ 1%     -46.1%       5810 ~ 1%  lkp-a04/micro/netperf/120s-200%-TCP_RR
     10764 ~ 1%     -47.5%       5647 ~ 0%  lkp-a04/micro/netperf/120s-200%-UDP_RR
  24695567 ~ 0%  +2.3e+11%  5.754e+16 ~15%  lkp-ib03/micro/ebizzy/200%-100-10
      9211 ~ 0%  +3.4e+15%  3.086e+17 ~96%  lkp-ib03/micro/netperf/120s-200%-TCP_CRR
      9022 ~ 0%  +6.9e+15%  6.269e+17 ~51%  lkp-ib03/micro/netperf/120s-200%-TCP_MAERTS
      9070 ~ 0%  +1.9e+11%  1.724e+13 ~ 0%  lkp-ib03/micro/netperf/120s-200%-TCP_SENDFILE
      8973 ~ 0%    +4e+15%  3.578e+17 ~71%  lkp-ib03/micro/netperf/120s-200%-TCP_STREAM
      9076 ~ 0%  +3.7e+15%  3.374e+17 ~24%  lkp-ib03/micro/netperf/120s-200%-UDP_RR
    391952 ~ 2%    +1e+13%  4.055e+16 ~28%  lkp-nex04/micro/tlbflush/200%-512-320
   5700945 ~ 0%  +4.2e+12%  2.383e+17 ~24%  lkp-nex05/micro/ebizzy/200%-100-10
    365605 ~ 2%  +5.6e+13%   2.04e+17 ~50%  lkp-nex05/micro/tlbflush/100%-512-320
  19093987 ~ 0%  +2.7e+11%  5.062e+16 ~22%  lkp-sb03/micro/ebizzy/200%-100-10
  13150807 ~ 0%  +4.8e+11%  6.298e+16 ~ 7%  lkp-sbx04/micro/ebizzy/200%-100-10
  19350039 ~ 3%  +2.4e+11%  4.708e+16 ~47%  lkp-snb01/micro/ebizzy/200%-100-10
     14838 ~ 1%  +8.5e+14%   1.26e+17 ~20%  lkp-snb01/micro/hackbench/1600%-process-pipe
     11199 ~ 1%  +1.1e+15%  1.239e+17 ~77%  lkp-snb01/micro/hackbench/1600%-process-socket
     17997 ~ 1%  +1.2e+15%  2.167e+17 ~ 6%  lkp-snb01/micro/hackbench/1600%-threads-pipe
      9182 ~ 3%  +2.5e+15%  2.326e+17 ~51%  lkp-snb01/micro/hackbench/1600%-threads-socket
   2509102 ~ 0%  +1.2e+11%  3.087e+15 ~141%  nhm-white/sysbench/oltp/600s-100%-1000000
  14788965 ~ 0%  +1.2e+11%  1.775e+16 ~118%  nhm8/micro/ebizzy/200%-100-10
   7717200 ~15%     -99.9%       9909 ~12%  vpx/micro/ebizzy/200%-100-10
  12673616 ~ 0%  +1.7e+11%  2.104e+16 ~35%  xps2/micro/ebizzy/200%-100-10
 1.422e+08       +2.3e+12%  3.201e+18       TOTAL proc-vmstat.nr_tlb_local_flush_all

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
       414 ~22%     -44.1%        231 ~13%  grantley/micro/ebizzy/200%-100-10
       211 ~43%     +62.2%        342 ~37%  lkp-nex04/micro/ebizzy/200%-100-10
       272 ~47%     -63.9%         98 ~42%  lkp-sbx04/micro/ebizzy/200%-100-10
       897          -25.1%        672       TOTAL pagetypeinfo.Node0.Normal.Unmovable.2

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
       242 ~21%    +108.5%        504 ~14%  grantley/micro/ebizzy/200%-100-10
       129 ~ 8%    +120.6%        286 ~40%  lkp-sbx04/micro/ebizzy/200%-100-10
       371         +112.7%        790       TOTAL pagetypeinfo.Node1.Normal.Unmovable.1

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
       346 ~34%     -46.2%        186 ~13%  grantley/micro/ebizzy/200%-100-10
       182 ~45%     +77.3%        322 ~33%  lkp-nex04/micro/ebizzy/200%-100-10
       203 ~49%     -60.7%         80 ~14%  lkp-sbx04/micro/ebizzy/200%-100-10
      4006 ~ 3%      +6.1%       4251 ~ 4%  lkp-snb01/micro/hackbench/1600%-process-pipe
      4739           +2.1%       4840       TOTAL pagetypeinfo.Node0.Normal.Unmovable.1

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
        63 ~35%    +161.4%        164 ~43%  lkp-nex04/micro/tlbflush/200%-512-320
        63         +161.4%        164       TOTAL numa-vmstat.node3.nr_dirtied

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
        95 ~42%     +72.0%        164 ~23%  lkp-ib03/micro/netperf/120s-200%-TCP_RR
       409 ~17%     +35.8%        555 ~14%  lkp-nex04/micro/ebizzy/200%-100-10
       504          +42.6%        719       TOTAL buddyinfo.Node.0.zone.Normal.1

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
       194 ~17%    +125.0%        438 ~13%  lkp-ne04/micro/ebizzy/200%-100-10
       194         +125.0%        438       TOTAL slabinfo.ip_fib_trie.num_objs

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
       194 ~17%    +125.0%        438 ~13%  lkp-ne04/micro/ebizzy/200%-100-10
       194         +125.0%        438       TOTAL slabinfo.ip_fib_trie.active_objs

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
       306 ~25%     +72.6%        529 ~14%  grantley/micro/ebizzy/200%-100-10
       209 ~16%     +82.2%        382 ~18%  lkp-sbx04/micro/ebizzy/200%-100-10
       516          +76.5%        911       TOTAL pagetypeinfo.Node1.Normal.Unmovable.2

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
       238 ~20%     +42.9%        340 ~ 7%  kbuildx/micro/ebizzy/200%-100-10
       119 ~20%     +71.4%        204 ~ 0%  xps2/micro/ebizzy/200%-100-10
       357          +52.4%        544       TOTAL slabinfo.Acpi-State.active_objs

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
       238 ~20%     +42.9%        340 ~ 7%  kbuildx/micro/ebizzy/200%-100-10
       119 ~20%     +71.4%        204 ~ 0%  xps2/micro/ebizzy/200%-100-10
       357          +52.4%        544       TOTAL slabinfo.Acpi-State.num_objs

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
       549 ~21%     -35.1%        356 ~ 8%  grantley/micro/ebizzy/200%-100-10
       348 ~24%     +33.4%        465 ~23%  lkp-nex04/micro/ebizzy/200%-100-10
       898           -8.5%        821       TOTAL buddyinfo.Node.0.zone.Normal.2

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
     32543 ~16%     -38.6%      19990 ~10%  lkp-nex04/micro/ebizzy/400%-5-30
     32543          -38.6%      19990       TOTAL numa-meminfo.node2.Active(file)

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
      8135 ~16%     -38.6%       4997 ~10%  lkp-nex04/micro/ebizzy/400%-5-30
      8135          -38.6%       4997       TOTAL numa-vmstat.node2.nr_active_file

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
        59 ~35%    +169.1%        159 ~45%  lkp-nex04/micro/tlbflush/200%-512-320
       123 ~29%     -39.6%         74 ~35%  lkp-sbx04/micro/ebizzy/200%-100-10
       182          +28.3%        234       TOTAL numa-vmstat.node3.nr_written

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
       915 ~23%     +42.8%       1308 ~32%  lkp-ib03/micro/netperf/120s-200%-TCP_RR
       915          +42.8%       1308       TOTAL numa-vmstat.node1.nr_alloc_batch

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
 3.643e+08 ~ 0%     -52.2%  1.741e+08 ~ 2%  lkp-snb01/micro/ebizzy/200%-100-10
  52579091 ~ 1%     -25.3%   39279438 ~13%  lkp-snb01/micro/hackbench/1600%-process-pipe
 4.169e+08          -48.8%  2.133e+08       TOTAL numa-numastat.node0.numa_foreign

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
      5685 ~23%     +50.2%       8539 ~ 5%  lkp-nex04/micro/ebizzy/400%-5-30
      5685          +50.2%       8539       TOTAL numa-vmstat.node3.nr_active_file

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
     22743 ~23%     +50.2%      34158 ~ 5%  lkp-nex04/micro/ebizzy/400%-5-30
     22743          +50.2%      34158       TOTAL numa-meminfo.node3.Active(file)

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
       214 ~21%     -28.1%        154 ~19%  lkp-nex04/micro/ebizzy/400%-5-30
       214          -28.1%        154       TOTAL numa-vmstat.node3.nr_mlock

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
       858 ~21%     -28.0%        618 ~18%  lkp-nex04/micro/ebizzy/400%-5-30
       858          -28.0%        618       TOTAL numa-meminfo.node3.Mlocked

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
       216 ~21%     -28.0%        155 ~18%  lkp-nex04/micro/ebizzy/400%-5-30
       216          -28.0%        155       TOTAL numa-vmstat.node3.nr_unevictable

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
       446 ~18%     +44.7%        645 ~10%  grantley/micro/ebizzy/200%-100-10
       340 ~11%     +60.9%        548 ~16%  lkp-sbx04/micro/ebizzy/200%-100-10
       787          +51.7%       1193       TOTAL buddyinfo.Node.1.zone.Normal.2

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
       865 ~21%     -27.9%        623 ~18%  lkp-nex04/micro/ebizzy/400%-5-30
       865          -27.9%        623       TOTAL numa-meminfo.node3.Unevictable

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
       276 ~ 2%     +32.5%        366 ~ 0%  lkp-ib03/micro/ebizzy/200%-100-10
       132 ~ 0%     +70.0%        225 ~28%  lkp-nex04/micro/tlbflush/200%-512-320
       409          +44.7%        591       TOTAL numa-vmstat.node0.nr_mlock

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
     31124 ~11%     +17.8%      36650 ~ 4%  grantley/micro/kbuild/200%
     10553 ~19%     +40.0%      14769 ~23%  lkp-ib03/micro/netperf/120s-200%-TCP_SENDFILE
     10428 ~ 1%     +69.6%      17686 ~12%  lkp-ne04/micro/ebizzy/200%-100-10
      5602 ~28%     +59.8%       8952 ~ 4%  lkp-nex04/micro/ebizzy/400%-5-30
     14038 ~22%     -33.5%       9341 ~12%  lkp-snb01/micro/hackbench/1600%-process-pipe
     10900 ~ 8%     +39.6%      15214 ~ 9%  lkp-snb01/micro/hackbench/1600%-threads-pipe
     82647          +24.2%     102613       TOTAL numa-vmstat.node1.nr_active_file

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
    124266 ~11%     +17.9%     146470 ~ 4%  grantley/micro/kbuild/200%
     42212 ~19%     +40.0%      59078 ~23%  lkp-ib03/micro/netperf/120s-200%-TCP_SENDFILE
     41715 ~ 1%     +69.6%      70749 ~12%  lkp-ne04/micro/ebizzy/200%-100-10
     22414 ~28%     +59.8%      35810 ~ 4%  lkp-nex04/micro/ebizzy/400%-5-30
     56156 ~22%     -33.5%      37364 ~12%  lkp-snb01/micro/hackbench/1600%-process-pipe
     43599 ~ 8%     +39.6%      60856 ~ 9%  lkp-snb01/micro/hackbench/1600%-threads-pipe
    330364          +24.2%     410329       TOTAL numa-meminfo.node1.Active(file)

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
      1109 ~ 2%     +32.3%       1468 ~ 0%  lkp-ib03/micro/ebizzy/200%-100-10
       532 ~ 0%     +69.4%        901 ~28%  lkp-nex04/micro/tlbflush/200%-512-320
      1642          +44.3%       2370       TOTAL numa-meminfo.node0.Mlocked

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
       402 ~23%     -26.8%        294 ~20%  lkp-nex04/micro/ebizzy/200%-100-10
       402          -26.8%        294       TOTAL pagetypeinfo.Node2.Normal.Unmovable.2

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
       280 ~ 2%     +31.8%        370 ~ 0%  lkp-ib03/micro/ebizzy/200%-100-10
       135 ~ 0%     +67.9%        226 ~27%  lkp-nex04/micro/tlbflush/200%-512-320
       415          +43.5%        596       TOTAL numa-vmstat.node0.nr_unevictable

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
      1124 ~ 2%     +31.7%       1481 ~ 0%  lkp-ib03/micro/ebizzy/200%-100-10
       540 ~ 0%     +68.1%        907 ~27%  lkp-nex04/micro/tlbflush/200%-512-320
      1664          +43.5%       2389       TOTAL numa-meminfo.node0.Unevictable

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
      2159 ~ 5%     +38.2%       2984 ~17%  lkp-nex04/micro/tlbflush/200%-512-320
      2159          +38.2%       2984       TOTAL numa-vmstat.node3.nr_active_anon

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
      8646 ~ 6%     +38.0%      11934 ~17%  lkp-nex04/micro/tlbflush/200%-512-320
      8646          +38.0%      11934       TOTAL numa-meminfo.node3.Active(anon)

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
       232 ~25%     +23.8%        287 ~19%  lkp-ib03/micro/netperf/120s-200%-TCP_MAERTS
       232          +23.8%        287       TOTAL slabinfo.skbuff_fclone_cache.num_slabs

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
       232 ~25%     +23.8%        287 ~19%  lkp-ib03/micro/netperf/120s-200%-TCP_MAERTS
       232          +23.8%        287       TOTAL slabinfo.skbuff_fclone_cache.active_slabs

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
     23452 ~11%    +107.1%      48557 ~53%  lkp-ib03/micro/netperf/120s-200%-TCP_RR
    458900 ~10%     -16.3%     383945 ~ 5%  lkp-nex04/micro/ebizzy/400%-5-30
 1.858e+08 ~ 4%     -53.6%   86284522 ~ 2%  lkp-snb01/micro/ebizzy/200%-100-10
  27227372 ~ 2%     -28.1%   19569200 ~12%  lkp-snb01/micro/hackbench/1600%-process-pipe
 2.135e+08          -50.2%  1.063e+08       TOTAL numa-vmstat.node1.numa_miss

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
    133827 ~10%     -15.3%     113311 ~ 4%  grantley/micro/kbuild/200%
     69106 ~11%     -24.3%      52332 ~25%  lkp-ib03/micro/netperf/120s-200%-TCP_SENDFILE
     70063 ~ 0%     -41.4%      41023 ~22%  lkp-ne04/micro/ebizzy/200%-100-10
     33244 ~19%     -36.9%      20988 ~ 5%  lkp-nex04/micro/ebizzy/400%-5-30
     54487 ~23%     +34.5%      73298 ~ 6%  lkp-snb01/micro/hackbench/1600%-process-pipe
     67116 ~ 5%     -25.8%      49833 ~11%  lkp-snb01/micro/hackbench/1600%-threads-pipe
    427845          -18.0%     350786       TOTAL numa-meminfo.node0.Active(file)

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
     33498 ~10%     -15.4%      28331 ~ 4%  grantley/micro/kbuild/200%
     17276 ~11%     -24.3%      13082 ~25%  lkp-ib03/micro/netperf/120s-200%-TCP_SENDFILE
     17515 ~ 0%     -41.5%      10255 ~22%  lkp-ne04/micro/ebizzy/200%-100-10
      8311 ~19%     -36.9%       5246 ~ 5%  lkp-nex04/micro/ebizzy/400%-5-30
     13621 ~23%     +34.5%      18324 ~ 6%  lkp-snb01/micro/hackbench/1600%-process-pipe
     16778 ~ 5%     -25.8%      12458 ~11%  lkp-snb01/micro/hackbench/1600%-threads-pipe
    107001          -18.0%      87698       TOTAL numa-vmstat.node0.nr_active_file

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
     23452 ~11%    +107.0%      48540 ~53%  lkp-ib03/micro/netperf/120s-200%-TCP_RR
   1097094 ~ 2%     -10.5%     981884 ~ 7%  lkp-nex04/micro/ebizzy/400%-5-30
 1.858e+08 ~ 4%     -53.6%   86281642 ~ 2%  lkp-snb01/micro/ebizzy/200%-100-10
  27218147 ~ 2%     -28.1%   19563337 ~12%  lkp-snb01/micro/hackbench/1600%-process-pipe
 2.142e+08          -50.1%  1.069e+08       TOTAL numa-vmstat.node0.numa_foreign

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
       435 ~14%     +55.3%        676 ~10%  grantley/micro/ebizzy/200%-100-10
       359 ~ 2%     +47.9%        532 ~24%  lkp-sbx04/micro/ebizzy/200%-100-10
       795          +51.9%       1208       TOTAL buddyinfo.Node.1.zone.Normal.1

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
      2298 ~ 7%     +32.2%       3037 ~16%  lkp-nex04/micro/tlbflush/200%-512-320
      2298          +32.2%       3037       TOTAL numa-vmstat.node3.nr_anon_pages

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
      9201 ~ 7%     +32.0%      12148 ~15%  lkp-nex04/micro/tlbflush/200%-512-320
      9201          +32.0%      12148       TOTAL numa-meminfo.node3.AnonPages

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
    912988 ~ 9%     -15.0%     776426 ~ 7%  lkp-nex04/micro/ebizzy/400%-5-30
 3.643e+08 ~ 0%     -52.2%  1.741e+08 ~ 2%  lkp-snb01/micro/ebizzy/200%-100-10
  52579091 ~ 1%     -25.3%   39279464 ~13%  lkp-snb01/micro/hackbench/1600%-process-pipe
 4.178e+08          -48.8%  2.141e+08       TOTAL numa-numastat.node1.numa_miss

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
    912988 ~ 9%     -15.0%     776426 ~ 7%  lkp-nex04/micro/ebizzy/400%-5-30
 3.643e+08 ~ 0%     -52.2%  1.741e+08 ~ 2%  lkp-snb01/micro/ebizzy/200%-100-10
  52579040 ~ 1%     -25.3%   39279457 ~13%  lkp-snb01/micro/hackbench/1600%-process-pipe
 4.178e+08          -48.8%  2.141e+08       TOTAL numa-numastat.node1.other_node

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
       148 ~ 9%     +43.9%        214 ~18%  lkp-sbx04/micro/ebizzy/200%-100-10
       148          +43.9%        214       TOTAL numa-vmstat.node3.nr_kernel_stack

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
      1191 ~ 9%     +43.9%       1714 ~18%  lkp-sbx04/micro/ebizzy/200%-100-10
      1191          +43.9%       1714       TOTAL numa-meminfo.node3.KernelStack

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
       201 ~ 4%     -20.7%        159 ~ 5%  grantley/micro/ebizzy/200%-100-10
       151 ~ 2%     +34.5%        204 ~ 7%  lkp-ib03/micro/ebizzy/200%-100-10
        39 ~17%    +116.8%         86 ~50%  lkp-ib03/micro/netperf/120s-200%-TCP_RR
       106 ~32%     -37.3%         66 ~27%  lkp-ib03/micro/netperf/120s-200%-UDP_RR
       165 ~ 9%     -19.8%        132 ~16%  lkp-sb03/micro/ebizzy/200%-100-10
        59 ~34%     +83.7%        109 ~ 1%  lkp-sbx04/micro/ebizzy/200%-100-10
       148 ~12%     +20.0%        178 ~ 6%  lkp-snb01/micro/ebizzy/200%-100-10
       106 ~14%     +24.1%        132 ~15%  lkp-snb01/micro/hackbench/1600%-threads-pipe
       978           +9.2%       1068       TOTAL numa-vmstat.node1.nr_written

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
       323 ~ 9%     +34.0%        433 ~ 3%  grantley/micro/kbuild/200%
      8187 ~26%     +24.0%      10151 ~20%  lkp-ib03/micro/netperf/120s-200%-TCP_MAERTS
      8510          +24.4%      10585       TOTAL slabinfo.skbuff_fclone_cache.active_objs

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
       547 ~17%     -23.0%        421 ~16%  lkp-nex04/micro/ebizzy/200%-100-10
       240 ~20%     -28.2%        172 ~16%  lkp-nex04/micro/tlbflush/200%-512-320
       787          -24.6%        594       TOTAL buddyinfo.Node.2.zone.Normal.2

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
       323 ~ 9%     +34.0%        433 ~ 3%  grantley/micro/kbuild/200%
      8376 ~25%     +23.7%      10364 ~20%  lkp-ib03/micro/netperf/120s-200%-TCP_MAERTS
      8700          +24.1%      10798       TOTAL slabinfo.skbuff_fclone_cache.num_objs

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
       209 ~ 4%     -20.3%        166 ~ 6%  grantley/micro/ebizzy/200%-100-10
       158 ~ 2%     +33.5%        211 ~ 7%  lkp-ib03/micro/ebizzy/200%-100-10
        43 ~14%    +106.9%         90 ~47%  lkp-ib03/micro/netperf/120s-200%-TCP_RR
       172 ~ 9%     -20.0%        137 ~17%  lkp-sb03/micro/ebizzy/200%-100-10
        61 ~33%     +83.8%        113 ~ 1%  lkp-sbx04/micro/ebizzy/200%-100-10
       154 ~12%     +20.6%        185 ~ 6%  lkp-snb01/micro/ebizzy/200%-100-10
       113 ~13%     +23.5%        140 ~15%  lkp-snb01/micro/hackbench/1600%-threads-pipe
       911          +14.6%       1044       TOTAL numa-vmstat.node1.nr_dirtied

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
       189 ~10%     -31.2%        130 ~18%  lkp-nex04/micro/tlbflush/200%-512-320
       189          -31.2%        130       TOTAL numa-vmstat.node2.nr_written

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
       199 ~10%     -30.9%        137 ~17%  lkp-nex04/micro/tlbflush/200%-512-320
       199          -30.9%        137       TOTAL numa-vmstat.node2.nr_dirtied

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
   1740841 ~ 3%      +8.7%    1891900 ~ 3%  grantley/micro/kbuild/200%
    503223 ~ 8%     -14.9%     427992 ~ 7%  lkp-nex04/micro/ebizzy/400%-5-30
  1.86e+08 ~ 4%     -53.6%   86323165 ~ 2%  lkp-snb01/micro/ebizzy/200%-100-10
  27266340 ~ 2%     -28.1%   19610310 ~12%  lkp-snb01/micro/hackbench/1600%-process-pipe
    164601 ~ 7%     +44.4%     237720 ~21%  lkp-snb01/micro/hackbench/1600%-threads-socket
 2.156e+08          -49.7%  1.085e+08       TOTAL numa-vmstat.node1.numa_other

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
     85188 ~11%     +22.1%     104052 ~10%  lkp-ib03/micro/netperf/120s-200%-TCP_SENDFILE
     62918 ~ 0%     +42.5%      89677 ~12%  lkp-ne04/micro/ebizzy/200%-100-10
     37458 ~15%     +40.2%      52508 ~ 3%  lkp-nex04/micro/ebizzy/400%-5-30
    185564          +32.7%     246238       TOTAL numa-meminfo.node1.Active

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
     11344 ~ 1%     +34.7%      15284 ~ 7%  lkp-ib03/micro/netperf/120s-200%-TCP_CRR
    763742 ~21%     -50.1%     381443 ~57%  lkp-ib03/micro/netperf/120s-200%-TCP_MAERTS
    775086          -48.8%     396727       TOTAL interrupts.RES

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
       135 ~24%     +19.3%        162 ~19%  lkp-a04/micro/netperf/120s-200%-TCP_RR
      1263 ~18%     -19.4%       1018 ~ 0%  lkp-sb03/micro/ebizzy/200%-100-10
      1399          -15.6%       1181       TOTAL uptime.idle

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
     70274 ~15%     -21.8%      54951 ~ 0%  grantley/micro/kbuild/200%
     70274          -21.8%      54951       TOTAL softirqs.SCHED

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
       346 ~14%     +17.7%        407 ~ 8%  lkp-ib03/micro/netperf/120s-200%-TCP_CRR
       456 ~ 7%     -13.5%        394 ~12%  lkp-ib03/micro/netperf/120s-200%-TCP_RR
       421 ~21%     -22.6%        326 ~15%  lkp-ib03/micro/netperf/120s-200%-TCP_STREAM
      1223           -7.8%       1128       TOTAL numa-vmstat.node0.nr_kernel_stack

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
      2772 ~14%     +17.6%       3261 ~ 8%  lkp-ib03/micro/netperf/120s-200%-TCP_CRR
      3649 ~ 7%     -13.5%       3158 ~12%  lkp-ib03/micro/netperf/120s-200%-TCP_RR
      3377 ~21%     -22.6%       2614 ~15%  lkp-ib03/micro/netperf/120s-200%-TCP_STREAM
      9799           -7.8%       9035       TOTAL numa-meminfo.node0.KernelStack

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
       364 ~11%     -15.4%        308 ~ 3%  grantley/micro/ebizzy/200%-100-10
       438 ~11%     -14.1%        376 ~ 8%  lkp-ib03/micro/netperf/120s-200%-TCP_CRR
       364 ~24%     +25.4%        456 ~10%  lkp-ib03/micro/netperf/120s-200%-TCP_STREAM
       124 ~ 2%     -13.4%        108 ~10%  lkp-nex04/micro/ebizzy/400%-5-30
       124 ~ 4%      +9.6%        136 ~ 3%  lkp-nex05/micro/ebizzy/200%-100-10
       192 ~22%     -31.5%        131 ~ 6%  lkp-sbx04/micro/ebizzy/200%-100-10
      1608           -5.7%       1517       TOTAL numa-vmstat.node1.nr_kernel_stack

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
      2916 ~11%     -15.2%       2472 ~ 3%  grantley/micro/ebizzy/200%-100-10
      3514 ~11%     -14.1%       3018 ~ 8%  lkp-ib03/micro/netperf/120s-200%-TCP_CRR
      2916 ~24%     +25.3%       3655 ~10%  lkp-ib03/micro/netperf/120s-200%-TCP_STREAM
      1002 ~ 2%     -13.4%        868 ~10%  lkp-nex04/micro/ebizzy/400%-5-30
      1002 ~ 4%      +9.2%       1094 ~ 3%  lkp-nex05/micro/ebizzy/200%-100-10
      1542 ~22%     -31.5%       1057 ~ 6%  lkp-sbx04/micro/ebizzy/200%-100-10
     12895           -5.7%      12165       TOTAL numa-meminfo.node1.KernelStack

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
    111416 ~ 9%     -17.4%      91975 ~11%  lkp-ib03/micro/netperf/120s-200%-TCP_SENDFILE
     90500 ~ 0%     -29.2%      64086 ~16%  lkp-ne04/micro/ebizzy/200%-100-10
     67113 ~ 8%     -22.4%      52047 ~ 6%  lkp-nex04/micro/ebizzy/400%-5-30
    130343 ~ 4%     -12.8%     113722 ~ 4%  lkp-snb01/micro/hackbench/1600%-threads-pipe
    399373          -19.4%     321832       TOTAL numa-meminfo.node0.Active

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
     62766 ~ 7%     -19.1%      50771 ~ 2%  lkp-nex04/micro/ebizzy/400%-5-30
     62766          -19.1%      50771       TOTAL numa-meminfo.node2.Active

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
      1014 ~ 5%     -17.9%        832 ~ 5%  lkp-ib03/micro/netperf/120s-200%-TCP_CRR
      1014          -17.9%        832       TOTAL slabinfo.blkdev_ioc.num_objs

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
      1014 ~ 5%     -17.9%        832 ~ 5%  lkp-ib03/micro/netperf/120s-200%-TCP_CRR
      1014          -17.9%        832       TOTAL slabinfo.blkdev_ioc.active_objs

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
 2.485e+08 ~ 1%     +28.4%  3.191e+08 ~ 1%  lkp-snb01/micro/ebizzy/200%-100-10
 2.485e+08          +28.4%  3.191e+08       TOTAL numa-numastat.node1.numa_foreign

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
 2.485e+08 ~ 1%     +28.4%  3.191e+08 ~ 1%  lkp-snb01/micro/ebizzy/200%-100-10
 2.485e+08          +28.4%  3.191e+08       TOTAL numa-numastat.node0.numa_miss

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
 2.485e+08 ~ 1%     +28.4%  3.191e+08 ~ 1%  lkp-snb01/micro/ebizzy/200%-100-10
 2.485e+08          +28.4%  3.191e+08       TOTAL numa-numastat.node0.other_node

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
      4809 ~ 7%     +17.1%       5630 ~ 7%  lkp-nex04/micro/ebizzy/200%-100-10
      2118 ~17%     -25.7%       1575 ~18%  lkp-nex04/micro/tlbflush/200%-512-320
      5262 ~ 4%     +23.0%       6471 ~ 4%  lkp-sb03/micro/ebizzy/200%-100-10
     12190          +12.2%      13676       TOTAL numa-vmstat.node0.nr_active_anon

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
     19280 ~ 7%     +16.7%      22504 ~ 7%  lkp-nex04/micro/ebizzy/200%-100-10
      8476 ~17%     -25.6%       6307 ~18%  lkp-nex04/micro/tlbflush/200%-512-320
     21067 ~ 4%     +22.7%      25859 ~ 4%  lkp-sb03/micro/ebizzy/200%-100-10
     48824          +12.0%      54671       TOTAL numa-meminfo.node0.Active(anon)

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
       170 ~ 5%     +23.3%        210 ~ 5%  grantley/micro/ebizzy/200%-100-10
       230 ~ 1%     -20.9%        182 ~ 8%  lkp-ib03/micro/ebizzy/200%-100-10
       149 ~ 3%     -30.4%        104 ~40%  lkp-ib03/micro/netperf/120s-200%-TCP_RR
       195 ~ 8%     +15.2%        225 ~10%  lkp-sb03/micro/ebizzy/200%-100-10
       190 ~ 6%     -23.1%        146 ~ 8%  lkp-snb01/micro/ebizzy/200%-100-10
       936           -7.3%        868       TOTAL numa-vmstat.node0.nr_dirtied

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
       164 ~ 5%     +23.6%        202 ~ 5%  grantley/micro/ebizzy/200%-100-10
       222 ~ 1%     -21.0%        175 ~ 9%  lkp-ib03/micro/ebizzy/200%-100-10
       137 ~ 4%     -33.0%         92 ~46%  lkp-ib03/micro/netperf/120s-200%-TCP_RR
       189 ~ 8%     +14.8%        217 ~10%  lkp-sb03/micro/ebizzy/200%-100-10
       184 ~ 6%     -23.0%        141 ~ 8%  lkp-snb01/micro/ebizzy/200%-100-10
       896           -7.5%        828       TOTAL numa-vmstat.node0.nr_written

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
      1136 ~23%     +24.1%       1409 ~14%  lkp-ib03/micro/netperf/120s-200%-TCP_STREAM
      1607 ~ 1%      +7.8%       1733 ~ 3%  lkp-sb03/micro/ebizzy/200%-100-10
      2743          +14.6%       3142       TOTAL numa-vmstat.node0.nr_alloc_batch

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
     17132 ~ 1%     +27.7%      21870 ~13%  lkp-sbx04/micro/ebizzy/200%-100-10
     17132          +27.7%      21870       TOTAL numa-meminfo.node2.SUnreclaim

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
       576 ~ 9%     -22.2%        448 ~11%  grantley/micro/ebizzy/200%-100-10
       554 ~ 5%     -15.4%        469 ~ 6%  lkp-ib03/micro/netperf/120s-200%-TCP_MAERTS
       896 ~ 5%     +19.0%       1066 ~ 7%  lkp-sbx04/micro/ebizzy/200%-100-10
      2026           -2.1%       1984       TOTAL slabinfo.kmem_cache_node.num_objs

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
      4282 ~ 1%     +27.7%       5467 ~13%  lkp-sbx04/micro/ebizzy/200%-100-10
      4282          +27.7%       5467       TOTAL numa-vmstat.node2.nr_slab_unreclaimable

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
   4797098 ~10%     -21.7%    3756714 ~13%  lkp-snb01/micro/hackbench/1600%-process-pipe
   5147989 ~ 0%     -20.3%    4102144 ~ 0%  lkp-snb01/micro/hackbench/1600%-threads-pipe
   9945088          -21.0%    7858858       TOTAL meminfo.DirectMap2M

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
      3955 ~ 8%     -17.4%       3265 ~12%  avoton1/crypto/tcrypt/2s-200-204
      3955          -17.4%       3265       TOTAL slabinfo.kmalloc-128.active_objs

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
      3991 ~ 8%     -16.9%       3316 ~12%  avoton1/crypto/tcrypt/2s-200-204
      3991          -16.9%       3316       TOTAL slabinfo.kmalloc-128.num_objs

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
      4260 ~ 8%     +19.5%       5092 ~17%  lkp-sbx04/micro/ebizzy/200%-100-10
      4260          +19.5%       5092       TOTAL numa-vmstat.node2.nr_anon_pages

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
     11575 ~14%     -21.6%       9080 ~ 7%  lkp-nex04/micro/ebizzy/200%-100-10
     15044 ~ 3%     +11.0%      16697 ~ 7%  lkp-nex04/micro/ebizzy/400%-5-30
     31418 ~ 3%     -14.7%      26795 ~ 4%  lkp-sb03/micro/ebizzy/200%-100-10
     21917 ~12%     -21.6%      17179 ~ 8%  lkp-sbx04/micro/ebizzy/200%-100-10
     79955          -12.8%      69753       TOTAL numa-meminfo.node1.Active(anon)

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
      2889 ~14%     -21.4%       2270 ~ 7%  lkp-nex04/micro/ebizzy/200%-100-10
      3684 ~ 3%     +13.6%       4185 ~ 8%  lkp-nex04/micro/ebizzy/400%-5-30
      7846 ~ 3%     -14.6%       6698 ~ 4%  lkp-sb03/micro/ebizzy/200%-100-10
      5471 ~13%     -21.2%       4309 ~ 8%  lkp-sbx04/micro/ebizzy/200%-100-10
     19891          -12.2%      17464       TOTAL numa-vmstat.node1.nr_active_anon

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
       476 ~ 1%     -18.8%        386 ~ 0%  lkp-ib03/micro/ebizzy/200%-100-10
       476          -18.8%        386       TOTAL numa-vmstat.node1.nr_mlock

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
      1906 ~ 1%     -18.8%       1548 ~ 0%  lkp-ib03/micro/ebizzy/200%-100-10
      1906          -18.8%       1548       TOTAL numa-meminfo.node1.Mlocked

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
      4818 ~ 2%     -16.5%       4024 ~ 1%  lkp-ib03/micro/netperf/120s-200%-TCP_CRR
      4818          -16.5%       4024       TOTAL proc-vmstat.nr_alloc_batch

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
     29534 ~ 3%     -13.9%      25438 ~ 3%  lkp-a03/micro/ebizzy/200%-100-10
     34986 ~ 7%     -13.7%      30208 ~ 0%  lkp-ib03/micro/netperf/120s-200%-TCP_MAERTS
     29525 ~ 8%     -23.1%      22698 ~ 4%  xps2/micro/ebizzy/200%-100-10
     94046          -16.7%      78345       TOTAL meminfo.DirectMap4k

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
       647 ~ 4%     +22.4%        792 ~ 0%  lkp-a04/micro/netperf/120s-200%-TCP_MAERTS
       767 ~ 9%     -19.6%        616 ~ 0%  lkp-a04/micro/netperf/120s-200%-TCP_RR
      3028 ~ 0%     -13.8%       2612 ~ 0%  lkp-ib03/micro/ebizzy/200%-100-10
      3006 ~ 0%     -14.5%       2569 ~ 1%  lkp-ib03/micro/netperf/120s-200%-TCP_MAERTS
      7449          -11.5%       6591       TOTAL slabinfo.kmalloc-512.active_objs

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
 1.268e+08 ~ 3%     +25.3%  1.589e+08 ~ 1%  lkp-snb01/micro/ebizzy/200%-100-10
  10963052 ~ 5%     +19.5%   13100880 ~11%  lkp-snb01/micro/hackbench/1600%-process-pipe
 1.378e+08          +24.8%   1.72e+08       TOTAL numa-vmstat.node1.numa_foreign

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
 1.268e+08 ~ 3%     +25.3%  1.589e+08 ~ 1%  lkp-snb01/micro/ebizzy/200%-100-10
  10960254 ~ 5%     +19.5%   13096862 ~11%  lkp-snb01/micro/hackbench/1600%-process-pipe
 1.378e+08          +24.8%   1.72e+08       TOTAL numa-vmstat.node0.numa_miss

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
      1920 ~ 1%     -18.5%       1564 ~ 0%  lkp-ib03/micro/ebizzy/200%-100-10
      1920          -18.5%       1564       TOTAL numa-meminfo.node1.Unevictable

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
       479 ~ 1%     -18.5%        391 ~ 0%  lkp-ib03/micro/ebizzy/200%-100-10
       479          -18.5%        391       TOTAL numa-vmstat.node1.nr_unevictable

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
     27938 ~ 1%     +19.4%      33369 ~ 9%  lkp-sbx04/micro/ebizzy/200%-100-10
     27938          +19.4%      33369       TOTAL numa-meminfo.node2.Slab

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
      8307 ~ 7%     +10.2%       9152 ~ 2%  lkp-nex04/micro/ebizzy/400%-5-30
       494 ~ 3%     -18.4%        403 ~ 4%  vpx/micro/ebizzy/200%-100-10
      8801           +8.6%       9555       TOTAL slabinfo.buffer_head.active_objs

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
       609 ~ 4%     +14.0%        694 ~ 4%  lkp-nex04/micro/ebizzy/400%-5-30
       609          +14.0%        694       TOTAL slabinfo.kmem_cache_node.active_objs

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
      2560 ~ 3%     +12.0%       2866 ~ 5%  lkp-a04/micro/netperf/120s-200%-TCP_RR
      2988 ~ 5%     -13.7%       2579 ~ 4%  lkp-a04/micro/netperf/120s-200%-UDP_RR
      2481 ~ 2%     +23.4%       3061 ~ 8%  lkp-a06/micro/ebizzy/200%-100-10
      8029           +5.9%       8507       TOTAL slabinfo.anon_vma.active_objs

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
 6.129e+08 ~ 0%     -19.5%  4.931e+08 ~ 1%  lkp-snb01/micro/ebizzy/200%-100-10
  75210725 ~ 0%     -14.2%   64497421 ~ 9%  lkp-snb01/micro/hackbench/1600%-process-pipe
 6.881e+08          -19.0%  5.576e+08       TOTAL proc-vmstat.numa_miss

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
 6.129e+08 ~ 0%     -19.5%  4.931e+08 ~ 1%  lkp-snb01/micro/ebizzy/200%-100-10
  75210691 ~ 0%     -14.2%   64497437 ~ 9%  lkp-snb01/micro/hackbench/1600%-process-pipe
 6.881e+08          -19.0%  5.576e+08       TOTAL proc-vmstat.numa_other

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
 6.129e+08 ~ 0%     -19.5%  4.931e+08 ~ 1%  lkp-snb01/micro/ebizzy/200%-100-10
  75210581 ~ 0%     -14.2%   64497614 ~ 9%  lkp-snb01/micro/hackbench/1600%-process-pipe
 6.881e+08          -19.0%  5.576e+08       TOTAL proc-vmstat.numa_foreign

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
     11715 ~13%     -20.2%       9346 ~ 8%  lkp-nex04/micro/ebizzy/200%-100-10
     14824 ~ 3%     +12.4%      16655 ~ 8%  lkp-nex04/micro/ebizzy/400%-5-30
     31289 ~ 2%     -15.2%      26527 ~ 4%  lkp-sb03/micro/ebizzy/200%-100-10
     21888 ~12%     -20.8%      17344 ~ 7%  lkp-sbx04/micro/ebizzy/200%-100-10
     26660 ~ 5%      +7.6%      28678 ~ 6%  lkp-snb01/micro/ebizzy/200%-100-10
    106377           -7.4%      98551       TOTAL numa-meminfo.node1.AnonPages

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
      2922 ~13%     -19.8%       2343 ~ 8%  lkp-nex04/micro/ebizzy/200%-100-10
      3628 ~ 3%     +15.0%       4173 ~ 8%  lkp-nex04/micro/ebizzy/400%-5-30
      7816 ~ 2%     -15.2%       6631 ~ 4%  lkp-sb03/micro/ebizzy/200%-100-10
      5461 ~12%     -20.4%       4348 ~ 7%  lkp-sbx04/micro/ebizzy/200%-100-10
      6668 ~ 5%      +7.6%       7175 ~ 6%  lkp-snb01/micro/ebizzy/200%-100-10
     26498           -6.9%      24670       TOTAL numa-vmstat.node1.nr_anon_pages

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
      8580 ~ 4%      +6.7%       9152 ~ 2%  lkp-nex04/micro/ebizzy/400%-5-30
       494 ~ 3%     -18.4%        403 ~ 4%  vpx/micro/ebizzy/200%-100-10
      9074           +5.3%       9555       TOTAL slabinfo.buffer_head.num_objs

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
      2072 ~ 7%     -18.2%       1695 ~ 5%  lkp-sb03/micro/ebizzy/200%-100-10
      2072          -18.2%       1695       TOTAL numa-meminfo.node1.PageTables

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
      2560 ~ 3%     +12.0%       2866 ~ 5%  lkp-a04/micro/netperf/120s-200%-TCP_RR
      2988 ~ 5%     -13.7%       2579 ~ 4%  lkp-a04/micro/netperf/120s-200%-UDP_RR
      2502 ~ 2%     +22.3%       3061 ~ 8%  lkp-a06/micro/ebizzy/200%-100-10
      8051           +5.7%       8507       TOTAL slabinfo.anon_vma.num_objs

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
 1.268e+08 ~ 3%     +25.4%   1.59e+08 ~ 1%  lkp-snb01/micro/ebizzy/200%-100-10
  11036862 ~ 4%     +19.3%   13171551 ~11%  lkp-snb01/micro/hackbench/1600%-process-pipe
    624263 ~ 0%     -11.5%     552390 ~ 6%  lkp-snb01/micro/hackbench/1600%-threads-socket
 1.385e+08          +24.7%  1.727e+08       TOTAL numa-vmstat.node0.numa_other

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
  14552936 ~ 3%     +19.2%   17348365 ~11%  lkp-nex04/micro/ebizzy/200%-100-10
  26307020 ~ 0%      -9.4%   23835777 ~ 5%  lkp-snb01/micro/hackbench/1600%-process-pipe
  40859956           +0.8%   41184142       TOTAL proc-vmstat.pgalloc_dma32

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
       626 ~ 4%     +14.3%        716 ~ 4%  lkp-snb01/micro/hackbench/1600%-process-pipe
       626          +14.3%        716       TOTAL pagetypeinfo.Node1.Normal.Movable.2

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
       936 ~ 3%     -13.9%        806 ~ 8%  lkp-ib03/micro/netperf/120s-200%-TCP_CRR
       936          -13.9%        806       TOTAL slabinfo.bdev_cache.active_objs

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
       936 ~ 3%     -13.9%        806 ~ 8%  lkp-ib03/micro/netperf/120s-200%-TCP_CRR
       936          -13.9%        806       TOTAL slabinfo.bdev_cache.num_objs

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
      1577 ~ 5%      -8.5%       1443 ~ 2%  avoton1/crypto/tcrypt/2s-301-319
      5274 ~ 4%      +6.9%       5637 ~ 4%  grantley/micro/kbuild/200%
       866 ~14%     -25.9%        642 ~14%  lkp-a04/micro/netperf/120s-200%-TCP_STREAM
       791 ~ 9%     +15.8%        916 ~ 3%  lkp-a04/micro/netperf/120s-200%-UDP_RR
      6588 ~ 1%      -9.5%       5960 ~ 1%  lkp-nex05/micro/ebizzy/200%-100-10
     15098           -3.3%      14599       TOTAL slabinfo.proc_inode_cache.active_objs

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
     57253 ~ 7%     +21.3%      69433 ~ 4%  lkp-nex04/micro/ebizzy/400%-5-30
     57253          +21.3%      69433       TOTAL numa-meminfo.node3.Active

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
       884 ~ 1%     +13.8%       1005 ~ 5%  lkp-snb01/micro/hackbench/1600%-process-pipe
       884          +13.8%       1005       TOTAL pagetypeinfo.Node0.DMA32.Unmovable.0

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
     19200 ~ 7%     +17.4%      22541 ~ 7%  lkp-nex04/micro/ebizzy/200%-100-10
     21256 ~ 3%     +23.3%      26218 ~ 4%  lkp-sb03/micro/ebizzy/200%-100-10
     40456          +20.5%      48759       TOTAL numa-meminfo.node0.AnonPages

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
  62905189 ~ 3%     -16.2%   52691612 ~ 7%  lkp-snb01/micro/hackbench/1600%-process-pipe
  62905189          -16.2%   52691612       TOTAL numa-vmstat.node0.numa_local

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
      4789 ~ 7%     +17.6%       5634 ~ 7%  lkp-nex04/micro/ebizzy/200%-100-10
      5317 ~ 4%     +23.4%       6560 ~ 4%  lkp-sb03/micro/ebizzy/200%-100-10
     10107          +20.7%      12195       TOTAL numa-vmstat.node0.nr_anon_pages

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
  62981796 ~ 3%     -16.2%   52766301 ~ 7%  lkp-snb01/micro/hackbench/1600%-process-pipe
  62981796          -16.2%   52766301       TOTAL numa-vmstat.node0.numa_hit

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
       173 ~ 3%     +17.5%        203 ~ 6%  lkp-nex04/micro/tlbflush/200%-512-320
       518 ~ 7%     -18.3%        423 ~ 6%  lkp-sb03/micro/ebizzy/200%-100-10
       691           -9.4%        626       TOTAL numa-vmstat.node1.nr_page_table_pages

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
   1143330 ~ 7%     +18.4%    1353226 ~ 5%  lkp-nex04/micro/tlbflush/200%-512-320
   1143330          +18.4%    1353226       TOTAL numa-vmstat.node2.numa_foreign

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
      1577 ~ 5%      -8.0%       1451 ~ 3%  avoton1/crypto/tcrypt/2s-301-319
      5312 ~ 5%      +7.9%       5731 ~ 3%  grantley/micro/kbuild/200%
       791 ~ 9%     +15.8%        916 ~ 3%  lkp-a04/micro/netperf/120s-200%-UDP_RR
       616 ~ 3%     +21.8%        751 ~ 9%  lkp-a06/micro/ebizzy/200%-100-10
      8297           +6.7%       8849       TOTAL slabinfo.proc_inode_cache.num_objs

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
       489 ~ 3%      -9.5%        442 ~ 1%  lkp-nex04/micro/tlbflush/200%-512-320
       372 ~ 9%     +25.3%        466 ~ 4%  lkp-sb03/micro/ebizzy/200%-100-10
       861           +5.5%        908       TOTAL numa-vmstat.node0.nr_page_table_pages

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
      7508 ~ 1%     -13.3%       6509 ~ 2%  lkp-ne04/micro/ebizzy/200%-100-10
     22870 ~ 5%     +14.9%      26268 ~ 5%  lkp-snb01/micro/hackbench/1600%-threads-pipe
     30379           +7.9%      32778       TOTAL slabinfo.kmalloc-192.active_objs

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
      1421 ~ 6%      -6.1%       1335 ~ 6%  lkp-a04/micro/netperf/120s-200%-TCP_CRR
      2114 ~ 6%     -14.2%       1813 ~ 5%  nhm-white/sysbench/oltp/600s-100%-1000000
      1875 ~ 6%     +23.4%       2313 ~ 2%  xps2/micro/pigz/100%
      5411           +0.9%       5462       TOTAL slabinfo.kmalloc-256.active_objs

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
      2384 ~ 5%      -9.3%       2162 ~ 6%  lkp-a04/micro/netperf/120s-200%-TCP_MAERTS
      7508 ~ 1%     -13.2%       6515 ~ 2%  lkp-ne04/micro/ebizzy/200%-100-10
     23051 ~ 5%     +14.7%      26445 ~ 5%  lkp-snb01/micro/hackbench/1600%-threads-pipe
     32944           +6.6%      35123       TOTAL slabinfo.kmalloc-192.num_objs

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
      1477 ~ 6%     -11.3%       1310 ~ 4%  lkp-nex04/micro/ebizzy/400%-5-30
      1961 ~ 2%      -9.8%       1769 ~ 1%  lkp-nex04/micro/tlbflush/200%-512-320
      1491 ~ 9%     +25.0%       1863 ~ 4%  lkp-sb03/micro/ebizzy/200%-100-10
      4930           +0.3%       4943       TOTAL numa-meminfo.node0.PageTables

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
 1.458e+09 ~ 0%     +13.6%  1.656e+09 ~ 0%  lkp-snb01/micro/ebizzy/200%-100-10
 1.458e+09          +13.6%  1.656e+09       TOTAL numa-numastat.node1.local_node

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
 1.458e+09 ~ 0%     +13.6%  1.656e+09 ~ 0%  lkp-snb01/micro/ebizzy/200%-100-10
 1.458e+09          +13.6%  1.656e+09       TOTAL numa-numastat.node1.numa_hit

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
       952 ~ 2%     -10.7%        850 ~ 6%  lkp-ib03/micro/netperf/120s-200%-TCP_STREAM
       884 ~ 5%     -11.5%        782 ~ 0%  lkp-nex05/micro/ebizzy/200%-100-10
      1836          -11.1%       1632       TOTAL slabinfo.dnotify_mark.num_objs

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
       952 ~ 2%     -10.7%        850 ~ 6%  lkp-ib03/micro/netperf/120s-200%-TCP_STREAM
       884 ~ 5%     -11.5%        782 ~ 0%  lkp-nex05/micro/ebizzy/200%-100-10
      1836          -11.1%       1632       TOTAL slabinfo.dnotify_mark.active_objs

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
       789 ~ 4%     -10.8%        704 ~ 1%  lkp-a04/micro/netperf/120s-200%-TCP_RR
      3221 ~ 2%     -11.6%       2848 ~ 1%  lkp-ib03/micro/ebizzy/200%-100-10
      3242 ~ 0%     -12.8%       2826 ~ 2%  lkp-ib03/micro/netperf/120s-200%-TCP_MAERTS
      7253          -12.1%       6378       TOTAL slabinfo.kmalloc-512.num_objs

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
  7.44e+08 ~ 3%     +10.9%  8.252e+08 ~ 1%  lkp-snb01/micro/ebizzy/200%-100-10
  7.44e+08          +10.9%  8.252e+08       TOTAL numa-vmstat.node1.numa_local

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
 7.442e+08 ~ 3%     +10.9%  8.252e+08 ~ 1%  lkp-snb01/micro/ebizzy/200%-100-10
 7.442e+08          +10.9%  8.252e+08       TOTAL numa-vmstat.node1.numa_hit

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
 1.219e+08 ~ 1%     -14.0%  1.048e+08 ~ 7%  lkp-snb01/micro/hackbench/1600%-process-pipe
 1.219e+08          -14.0%  1.048e+08       TOTAL numa-numastat.node0.local_node

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
 1.219e+08 ~ 1%     -14.0%  1.048e+08 ~ 7%  lkp-snb01/micro/hackbench/1600%-process-pipe
 1.219e+08          -14.0%  1.048e+08       TOTAL numa-numastat.node0.numa_hit

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
     28858 ~ 0%     -10.3%      25873 ~ 2%  lkp-ib03/micro/netperf/120s-200%-TCP_CRR
     28858          -10.3%      25873       TOTAL slabinfo.vm_area_struct.num_objs

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
     46909 ~ 6%     -13.1%      40751 ~ 5%  avoton1/crypto/tcrypt/2s-200-204
     40062 ~ 7%     +10.2%      44164 ~ 7%  lkp-a04/micro/netperf/120s-200%-TCP_STREAM
    549372 ~ 6%      +7.4%     589808 ~ 4%  nhm8/micro/ebizzy/200%-100-10
    636343           +6.0%     674724       TOTAL softirqs.RCU

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
      8164 ~ 6%      +8.0%       8819 ~ 6%  lkp-ib03/micro/netperf/120s-200%-TCP_STREAM
      8164           +8.0%       8819       TOTAL slabinfo.kmalloc-2048.num_objs

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
      8040 ~ 6%      +8.0%       8685 ~ 6%  lkp-ib03/micro/netperf/120s-200%-TCP_STREAM
      8040           +8.0%       8685       TOTAL slabinfo.kmalloc-2048.active_objs

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
      3416 ~ 1%     +12.4%       3840 ~ 7%  lkp-snb01/micro/hackbench/1600%-process-pipe
      3416          +12.4%       3840       TOTAL buddyinfo.Node.1.zone.Normal.0

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
      2617 ~ 2%     +12.9%       2956 ~ 7%  lkp-snb01/micro/hackbench/1600%-process-pipe
      2617          +12.9%       2956       TOTAL pagetypeinfo.Node1.Normal.Unmovable.0

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
     28736 ~ 0%     -10.4%      25734 ~ 2%  lkp-ib03/micro/netperf/120s-200%-TCP_CRR
     29205 ~ 6%      -8.3%      26783 ~ 6%  lkp-ib03/micro/netperf/120s-200%-TCP_RR
     57941           -9.4%      52518       TOTAL slabinfo.vm_area_struct.active_objs

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
 2.661e+08 ~ 0%      -9.5%  2.409e+08 ~ 5%  lkp-snb01/micro/hackbench/1600%-process-pipe
  10511623 ~ 0%      -8.4%    9633555 ~ 6%  nhm-white/sysbench/oltp/600s-100%-1000000
 2.766e+08           -9.4%  2.505e+08       TOTAL proc-vmstat.pgalloc_normal

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
       555 ~ 3%     +11.6%        620 ~ 1%  lkp-nex04/micro/tlbflush/200%-512-320
       555          +11.6%        620       TOTAL numa-vmstat.node3.nr_page_table_pages

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
      1106 ~ 3%      +7.1%       1185 ~ 4%  lkp-snb01/micro/hackbench/1600%-process-pipe
      1106           +7.1%       1185       TOTAL pagetypeinfo.Node0.DMA32.Unmovable.1

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
     39954 ~ 1%     -10.8%      35656 ~ 2%  grantley/micro/ebizzy/200%-100-10
     22284 ~ 5%     -10.0%      20050 ~ 4%  lkp-sbx04/micro/ebizzy/200%-100-10
     62238          -10.5%      55706       TOTAL numa-meminfo.node0.SUnreclaim

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
      9987 ~ 1%     -10.7%       8914 ~ 2%  grantley/micro/ebizzy/200%-100-10
      5571 ~ 5%     -10.0%       5012 ~ 4%  lkp-sbx04/micro/ebizzy/200%-100-10
     15558          -10.5%      13926       TOTAL numa-vmstat.node0.nr_slab_unreclaimable

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
      2218 ~ 3%     +11.5%       2473 ~ 1%  lkp-nex04/micro/tlbflush/200%-512-320
      2218          +11.5%       2473       TOTAL numa-meminfo.node3.PageTables

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
 2.924e+08 ~ 0%      -9.5%  2.647e+08 ~ 5%  lkp-snb01/micro/hackbench/1600%-process-pipe
 2.924e+08           -9.5%  2.647e+08       TOTAL proc-vmstat.pgfree

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
    842138 ~ 4%     +11.3%     937303 ~ 2%  lkp-nex04/micro/tlbflush/200%-512-320
    842138          +11.3%     937303       TOTAL numa-vmstat.node2.numa_local

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
    382783 ~ 0%      -7.7%     353469 ~ 2%  lkp-ne04/micro/ebizzy/200%-100-10
    382783           -7.7%     353469       TOTAL numa-meminfo.node1.Inactive

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
     95668 ~ 0%      -7.7%      88340 ~ 2%  lkp-ne04/micro/ebizzy/200%-100-10
     95668           -7.7%      88340       TOTAL numa-vmstat.node1.nr_inactive_file

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
    382675 ~ 0%      -7.7%     353363 ~ 2%  lkp-ne04/micro/ebizzy/200%-100-10
    382675           -7.7%     353363       TOTAL numa-meminfo.node1.Inactive(file)

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
    354404 ~ 0%      +8.3%     383713 ~ 2%  lkp-ne04/micro/ebizzy/200%-100-10
    354404           +8.3%     383713       TOTAL numa-meminfo.node0.Inactive

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
    354322 ~ 0%      +8.3%     383629 ~ 2%  lkp-ne04/micro/ebizzy/200%-100-10
    354322           +8.3%     383629       TOTAL numa-meminfo.node0.Inactive(file)

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
     88580 ~ 0%      +8.3%      95907 ~ 2%  lkp-ne04/micro/ebizzy/200%-100-10
     88580           +8.3%      95907       TOTAL numa-vmstat.node0.nr_inactive_file

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
         4 ~20%     +50.0%          6 ~ 0%  avoton1/crypto/tcrypt/2s-205-210
      3352 ~ 1%      -1.9%       3287 ~ 1%  grantley/micro/kbuild/200%
      3120 ~ 0%      -0.3%       3110 ~ 0%  lkp-snb01/micro/hackbench/1600%-threads-socket
      6476           -1.1%       6404       TOTAL time.percent_of_cpu_this_job_got

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
     28.56 ~ 1%      +1.9%      29.11 ~ 1%  avoton1/crypto/tcrypt/2s-200-204
     28.34 ~ 0%      +0.9%      28.60 ~ 0%  avoton1/crypto/tcrypt/2s-500-504
     21.53 ~ 0%      +1.2%      21.79 ~ 0%  grantley/micro/ebizzy/200%-100-10
     24.59 ~35%     +27.1%      31.26 ~27%  lkp-a04/micro/netperf/120s-200%-TCP_RR
     18.06 ~ 0%      -2.2%      17.67 ~ 0%  lkp-ib03/micro/ebizzy/200%-100-10
     17.86 ~ 1%      +2.5%      18.30 ~ 2%  lkp-ib03/micro/netperf/120s-200%-TCP_CRR
     17.68 ~ 1%      +3.0%      18.21 ~ 2%  lkp-ib03/micro/netperf/120s-200%-TCP_MAERTS
     18.18 ~ 0%      -0.5%      18.09 ~ 0%  lkp-ib03/micro/netperf/120s-200%-TCP_SENDFILE
     21.53 ~ 3%      +3.5%      22.29 ~ 2%  lkp-nex04/micro/ebizzy/200%-100-10
     21.87 ~ 2%      +3.4%      22.62 ~ 1%  lkp-nex04/micro/ebizzy/400%-5-30
     30.45 ~ 2%      -3.1%      29.51 ~ 0%  lkp-nex05/micro/ebizzy/200%-100-10
     24.54 ~ 0%      -2.5%      23.94 ~ 1%  lkp-sbx04/micro/ebizzy/200%-100-10
     18.22 ~ 1%      -4.2%      17.45 ~ 0%  lkp-snb01/micro/hackbench/1600%-process-pipe
     18.03 ~ 1%      +5.3%      18.99 ~ 1%  lkp-snb01/micro/hackbench/1600%-threads-pipe
      7.27 ~ 0%      -0.4%       7.24 ~ 0%  nhm-white/micro/ebizzy/200%-100-10
      7.26 ~ 0%      -0.3%       7.23 ~ 0%  nhm-white/sysbench/oltp/600s-100%-1000000
      7.46 ~ 0%      -1.2%       7.36 ~ 0%  nhm8/micro/ebizzy/200%-100-10
      8.25 ~14%     -13.1%       7.17 ~ 2%  vpx/micro/ebizzy/200%-100-10
      7.25 ~ 0%      -0.3%       7.23 ~ 0%  xps2/micro/ebizzy/200%-100-10
      7.24 ~ 0%      -0.2%       7.22 ~ 0%  xps2/micro/pigz/100%
    354.17           +2.0%     361.27       TOTAL boottime.dhcp

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
    283.95 ~ 0%      +1.7%     288.80 ~ 0%  avoton1/crypto/tcrypt/2s-200-204
   1507.97 ~ 1%      +3.8%    1565.31 ~ 2%  grantley/micro/ebizzy/200%-100-10
    171.95 ~ 2%      -2.7%     167.30 ~ 0%  lkp-a03/micro/ebizzy/200%-100-10
    177.09 ~ 0%      -3.4%     171.02 ~ 3%  lkp-a04/micro/ebizzy/200%-100-10
    126.52 ~25%     +20.7%     152.67 ~20%  lkp-a04/micro/netperf/120s-200%-TCP_RR
   1268.71 ~ 5%      -6.2%    1190.03 ~ 2%  lkp-ib03/micro/ebizzy/200%-100-10
   1263.97 ~ 1%      -4.0%    1213.81 ~ 2%  lkp-ib03/micro/netperf/120s-200%-TCP_RR
   1450.45 ~21%     -16.6%    1209.06 ~ 1%  lkp-ib03/micro/netperf/120s-200%-TCP_STREAM
   2265.10 ~ 2%      +2.9%    2329.92 ~ 0%  lkp-nex04/micro/ebizzy/200%-100-10
   2200.05 ~ 1%      -2.9%    2135.66 ~ 0%  lkp-nex05/micro/ebizzy/200%-100-10
    701.22 ~ 0%      +3.9%     728.26 ~ 1%  lkp-snb01/micro/hackbench/1600%-threads-pipe
    108.34 ~ 1%     +17.7%     127.56 ~19%  nhm-white/sysbench/oltp/600s-100%-1000000
     55.07 ~ 7%      -6.8%      51.30 ~ 1%  vpx/micro/ebizzy/200%-100-10
  11580.40           -2.2%   11330.71       TOTAL boottime.idle

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
     38.06 ~25%     +41.7%      53.94 ~ 2%  avoton1/crypto/tcrypt/2s-205-210
   8854.64 ~ 0%      -0.4%    8823.52 ~ 0%  lkp-nex04/micro/ebizzy/400%-5-30
   1909.31 ~ 4%      -4.1%    1831.01 ~ 0%  lkp-nex05/micro/tlbflush/100%-512-320
  28660.09 ~ 0%      -0.1%   28633.32 ~ 0%  lkp-sb03/micro/ebizzy/200%-100-10
  59506.46 ~ 0%      +0.1%   59582.11 ~ 0%  lkp-sbx04/micro/ebizzy/200%-100-10
   5491.85 ~ 0%      +0.3%    5510.49 ~ 0%  nhm8/micro/dbench/100%
   5335.66 ~ 0%      +0.6%    5367.23 ~ 0%  xps2/micro/ebizzy/200%-100-10
 109796.06           +0.0%  109801.62       TOTAL time.system_time

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
    302978 ~ 1%      -2.7%     294844 ~ 0%  grantley/micro/kbuild/200%
     10559 ~ 0%      +2.1%      10786 ~ 1%  lkp-a04/micro/ebizzy/200%-100-10
    532425 ~ 0%      +0.8%     536900 ~ 0%  lkp-ib03/micro/ebizzy/200%-100-10
    591175 ~ 2%      -3.6%     569644 ~ 2%  lkp-nex05/micro/ebizzy/200%-100-10
     24107 ~ 0%      +1.7%      24523 ~ 1%  nhm-white/micro/ebizzy/200%-100-10
     24304 ~ 0%      -2.3%      23745 ~ 0%  xps2/micro/ebizzy/200%-100-10
   1485551           -1.7%    1460444       TOTAL time.voluntary_context_switches

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
     39.63 ~ 0%      +1.5%      40.24 ~ 0%  avoton1/crypto/tcrypt/2s-200-204
     39.49 ~ 0%      +0.4%      39.64 ~ 0%  avoton1/crypto/tcrypt/2s-301-319
     41.37 ~ 1%      -2.4%      40.39 ~ 0%  lkp-nex05/micro/ebizzy/200%-100-10
     41.77 ~ 1%      -1.3%      41.24 ~ 1%  lkp-nex05/micro/tlbflush/100%-512-320
     27.55 ~ 2%      -4.2%      26.39 ~ 0%  lkp-snb01/micro/hackbench/1600%-process-pipe
     26.95 ~ 0%      +3.4%      27.87 ~ 0%  lkp-snb01/micro/hackbench/1600%-threads-pipe
     16.91 ~ 0%      -2.2%      16.54 ~ 1%  nhm8/micro/dbench/100%
     16.01 ~ 9%      -8.7%      14.63 ~ 2%  vpx/micro/ebizzy/200%-100-10
    249.69           -1.1%     246.93       TOTAL boottime.boot

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
  84220649 ~ 0%      +0.7%   84794796 ~ 0%  lkp-a03/micro/ebizzy/200%-100-10
  84172596 ~ 0%      +0.7%   84796336 ~ 0%  lkp-a04/micro/ebizzy/200%-100-10
  84173685 ~ 0%      +0.8%   84848135 ~ 0%  lkp-a06/micro/ebizzy/200%-100-10
 4.728e+09 ~ 0%      -1.2%  4.671e+09 ~ 0%  lkp-ib03/micro/ebizzy/200%-100-10
      4884 ~ 0%      -2.0%       4786 ~ 0%  lkp-ib03/micro/netperf/120s-200%-TCP_RR
 2.514e+09 ~ 0%      -1.6%  2.475e+09 ~ 0%  lkp-sbx04/micro/ebizzy/200%-100-10
  51621106 ~ 0%      -8.6%   47164538 ~ 5%  lkp-snb01/micro/hackbench/1600%-process-pipe
 2.632e+08 ~ 0%      +0.2%  2.639e+08 ~ 0%  lkp-t410/micro/ebizzy/200%-100-10
     16342 ~ 0%      +0.4%      16410 ~ 0%  xps2/micro/pigz/100%
 7.809e+09           -1.3%  7.712e+09       TOTAL time.minor_page_faults

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
      2659 ~ 0%      -0.3%       2651 ~ 0%  grantley/micro/kbuild/200%
       686 ~ 1%      +4.4%        716 ~ 2%  lkp-nex04/micro/ebizzy/400%-5-30
      3262 ~ 0%      +0.8%       3288 ~ 0%  lkp-sb03/micro/ebizzy/200%-100-10
      4137 ~ 0%      -1.9%       4059 ~ 0%  lkp-sbx04/micro/ebizzy/200%-100-10
      2228 ~ 0%      -3.0%       2161 ~ 1%  lkp-snb01/micro/hackbench/1600%-process-pipe
      1517 ~ 0%      -0.8%       1505 ~ 0%  lkp-snb01/micro/hackbench/1600%-threads-pipe
      1363 ~ 0%      -2.5%       1330 ~ 1%  lkp-snb01/micro/hackbench/1600%-threads-socket
      3116 ~ 0%      -0.6%       3098 ~ 0%  nhm8/micro/dbench/100%
      2637 ~ 0%      -1.2%       2606 ~ 0%  xps2/micro/ebizzy/200%-100-10
     21609           -0.9%      21418       TOTAL time.user_time

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
      1187 ~ 0%      -0.5%       1181 ~ 0%  avoton1/crypto/tcrypt/2s-500-504
      9501 ~ 1%      -2.1%       9300 ~ 1%  grantley/micro/kbuild/200%
      3340 ~ 0%      +0.8%       3366 ~ 0%  lkp-a03/micro/ebizzy/200%-100-10
      3359 ~ 0%      +0.3%       3369 ~ 0%  lkp-a04/micro/ebizzy/200%-100-10
      3343 ~ 0%      +0.9%       3373 ~ 0%  lkp-a06/micro/ebizzy/200%-100-10
   2048146 ~ 0%      -3.6%    1974295 ~ 3%  lkp-ib03/micro/ebizzy/200%-100-10
     11442 ~ 0%      +0.5%      11502 ~ 0%  lkp-ib03/micro/netperf/120s-200%-TCP_CRR
     17992 ~ 7%     -17.1%      14912 ~11%  lkp-ib03/micro/netperf/120s-200%-TCP_MAERTS
   1477911 ~ 0%      -1.1%    1462062 ~ 0%  lkp-sbx04/micro/ebizzy/200%-100-10
   1427714 ~ 0%      -1.5%    1406534 ~ 0%  lkp-snb01/micro/hackbench/1600%-threads-pipe
   5003938           -2.3%    4889897       TOTAL vmstat.system.in

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
     86.02 ~ 1%      +1.7%      87.46 ~ 1%  grantley/micro/kbuild/200%
    121.15 ~ 0%      +0.1%     121.22 ~ 0%  lkp-a04/micro/netperf/120s-200%-TCP_RR
    207.17           +0.7%     208.69       TOTAL time.elapsed_time

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
       719 ~ 0%      +0.2%        720 ~ 0%  avoton1/crypto/tcrypt/2s-505-509
      9377 ~ 1%      -2.6%       9134 ~ 1%  grantley/micro/kbuild/200%
   1793803 ~ 0%      +1.0%    1811656 ~ 0%  lkp-ib03/micro/netperf/120s-200%-TCP_CRR
   5547967 ~ 0%      +1.9%    5655750 ~ 0%  lkp-ib03/micro/netperf/120s-200%-TCP_RR
      5598 ~ 0%      -0.6%       5567 ~ 0%  lkp-nex05/micro/ebizzy/200%-100-10
      3031 ~ 0%      +0.6%       3051 ~ 0%  lkp-sb03/micro/ebizzy/200%-100-10
      1286 ~ 1%      +1.6%       1307 ~ 1%  nhm8/micro/ebizzy/200%-100-10
   7361784           +1.7%    7487188       TOTAL vmstat.system.cs

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
   4163881 ~ 0%      +0.3%    4174862 ~ 0%  grantley/micro/ebizzy/200%-100-10
   1190689 ~ 0%      +0.4%    1195644 ~ 0%  lkp-ne04/micro/ebizzy/200%-100-10
 9.295e+08 ~ 0%      +0.8%  9.365e+08 ~ 0%  lkp-snb01/micro/hackbench/1600%-threads-pipe
    918867 ~ 1%      +1.1%     928905 ~ 0%  nhm8/micro/ebizzy/200%-100-10
 9.357e+08           +0.8%  9.428e+08       TOTAL time.involuntary_context_switches


--WIyZ46R2i8wDzkSu--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
