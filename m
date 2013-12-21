Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id BC2026B0031
	for <linux-mm@kvack.org>; Sat, 21 Dec 2013 10:49:41 -0500 (EST)
Received: by mail-pd0-f175.google.com with SMTP id w10so3674713pde.34
        for <linux-mm@kvack.org>; Sat, 21 Dec 2013 07:49:41 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id v7si8051923pbi.308.2013.12.21.07.49.39
        for <linux-mm@kvack.org>;
        Sat, 21 Dec 2013 07:49:40 -0800 (PST)
Date: Sat, 21 Dec 2013 23:49:25 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [PATCH 0/4] Fix ebizzy performance regression due to X86 TLB
 range flush v2
Message-ID: <20131221154925.GA7450@localhost>
References: <1386964870-6690-1-git-send-email-mgorman@suse.de>
 <20131218072814.GA798@localhost>
 <20131219143449.GN11295@suse.de>
 <20131220155143.GA22595@localhost>
 <20131220164426.GD11295@suse.de>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="ibTvN161/egqYuK8"
Content-Disposition: inline
In-Reply-To: <20131220164426.GD11295@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Alex Shi <alex.shi@linaro.org>, Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, H Peter Anvin <hpa@zytor.com>, Linux-X86 <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>


--ibTvN161/egqYuK8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Mel,

On Fri, Dec 20, 2013 at 04:44:26PM +0000, Mel Gorman wrote:
> On Fri, Dec 20, 2013 at 11:51:43PM +0800, Fengguang Wu wrote:
> > On Thu, Dec 19, 2013 at 02:34:50PM +0000, Mel Gorman wrote:
[snip]
> > > I doubt hackbench is doing any flushes and the 1.2% is noise.
> > 
> > Here are the proc-vmstat.nr_tlb_remote_flush numbers for hackbench:
> > 
> >        513 ~ 3%  +4.3e+16%  2.192e+17 ~85%  lkp-nex05/micro/hackbench/800%-process-pipe
> >        603 ~ 3%  +7.7e+16%  4.669e+17 ~13%  lkp-nex05/micro/hackbench/800%-process-socket
> >       6124 ~17%  +5.7e+15%  3.474e+17 ~26%  lkp-nex05/micro/hackbench/800%-threads-pipe
> >       7565 ~49%  +5.5e+15%  4.128e+17 ~68%  lkp-nex05/micro/hackbench/800%-threads-socket
> >      21252 ~ 6%  +1.3e+15%  2.728e+17 ~39%  lkp-snb01/micro/hackbench/1600%-threads-pipe
> >      24516 ~16%  +8.3e+14%  2.034e+17 ~53%  lkp-snb01/micro/hackbench/1600%-threads-socket
> > 
> 
> This is a surprise. The differences I can understand because of changes
> in accounting but not the flushes themselves. The only flushes I would
> expect are when the process exits and the regions are torn down.
> 
> The exception would be if automatic NUMA balancing was enabled and this
> was a NUMA machine. In that case, NUMA hinting faults could be migrating
> memory and triggering flushes.

You are right, the kconfig (attached) does have

CONFIG_NUMA_BALANCING=y

and lkp-nex05 is a 4-socket NHM-EX machine; lkp-snb01 is a 2-socket
SNB machine.

> Could you do something like
> 
> # perf probe native_flush_tlb_others
> # cd /sys/kernel/debug/tracing
> # echo sym-offset > trace_options
> # echo sym-addr > trace_options
> # echo stacktrace > trace_options
> # echo 1 > events/probe/native_flush_tlb_others/enable
> # cat trace_pipe > /tmp/log
> 
> and get a breakdown of what the source of these remote flushes are
> please?

Sure. Attached is the log file.

> > This time, the ebizzy params are refreshed and the test case is
> > exercised in all our test machines. The results that have changed are:
> > 
> >       v3.13-rc3       eabb1f89905a0c809d13  
> > ---------------  -------------------------  
> >        873 ~ 0%      +0.7%        879 ~ 0%  lkp-a03/micro/ebizzy/200%-100-10
> >        873 ~ 0%      +0.7%        879 ~ 0%  lkp-a04/micro/ebizzy/200%-100-10
> >        873 ~ 0%      +0.8%        880 ~ 0%  lkp-a06/micro/ebizzy/200%-100-10
> >      49242 ~ 0%      -1.2%      48650 ~ 0%  lkp-ib03/micro/ebizzy/200%-100-10
> >      26176 ~ 0%      -1.6%      25760 ~ 0%  lkp-sbx04/micro/ebizzy/200%-100-10
> >       2738 ~ 0%      +0.2%       2744 ~ 0%  lkp-t410/micro/ebizzy/200%-100-10
> >      80776           -1.2%      79793       TOTAL ebizzy.throughput
> > 
> 
> No change on lkp-ib03 which I would have expected some difference. Thing
> is, for ebizzy to notice the number of TLB entries matter. On both
> machines I tested, the last level TLB had 512 entries. How many entries
> are on the last level TLB on lkp-ib03?

[    0.116154] Last level iTLB entries: 4KB 512, 2MB 0, 4MB 0
[    0.116154] Last level dTLB entries: 4KB 512, 2MB 0, 4MB 0

> > > I do see a few major regressions like this
> > > 
> > > >     324497 ~ 0%    -100.0%          0 ~ 0%  brickland2/micro/vm-scalability/16G-truncate
> > > 
> > > but I have no idea what the test is doing and whether something happened
> > > that the test broke that time or if it's something to be really
> > > concerned about.
> > 
> > This test case simply creates sparse files, populate them with zeros,
> > then delete them in parallel. Here $mem is physical memory size 128G,
> > $nr_cpu is 120.
> > 
> > for i in `seq $nr_cpu`
> > do      
> >         create_sparse_file $SPARSE_FILE-$i $((mem / nr_cpu))
> >         cp $SPARSE_FILE-$i /dev/null
> > done
> > 
> > for i in `seq $nr_cpu`
> > do      
> >         rm $SPARSE_FILE-$i &
> > done
> > 
> 
> In itself, that does not explain why the result was 0 with the series
> applied. The 3.13-rc3 result was "324497". 324497 what?

It's the proc-vmstat.nr_tlb_local_flush_one number, which is showed in the end
of every "TOTAL" line:

      v3.13-rc3       eabb1f89905a0c809d13
---------------  -------------------------  
...
    324497 ~ 0%    -100.0%          0 ~ 0%  brickland2/micro/vm-scalability/16G-truncate
...
  99986527         +3e+14%  2.988e+20       TOTAL proc-vmstat.nr_tlb_local_flush_one
                                                  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

btw, I've got the full test results for hackbench. Attached are the
new comparison results. There are small ups and downs, overall no big
regressions.

Thanks,
Fengguang

--ibTvN161/egqYuK8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=perf-probe

Added new event:
  probe:native_flush_tlb_others (on native_flush_tlb_others)

You can now use it in all perf tools, such as:

	perf record -e probe:native_flush_tlb_others -aR sleep 1

         wrapper-4253  [000] d..2    26.132316: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
         wrapper-4253  [000] d..2    26.132324: <stack trace>
 => dup_mm+0x37e/0x480 <ffffffff810c1829>
 => copy_process.part.30+0xa58/0x11ee <ffffffff810c23ae>
 => do_fork+0xba/0x2ac <ffffffff810c2ce1>
 => SyS_clone+0x16/0x18 <ffffffff810c2f4d>
 => stub_clone+0x69/0x90 <ffffffff81a07969>
        basename-4278  [018] d..2    26.138846: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
        basename-4278  [018] d..2    26.138852: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
           mkdir-4286  [019] d..2    26.140542: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           mkdir-4286  [019] d..2    26.140546: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
            sort-4284  [015] d..2    26.141105: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
            sort-4284  [015] d..2    26.141108: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => unmap_region+0xdd/0xef <ffffffff8118d0ff>
 => do_munmap+0x250/0x2e3 <ffffffff8118ea85>
 => vm_munmap+0x42/0x5b <ffffffff8118eb5a>
 => SyS_munmap+0x23/0x29 <ffffffff8118eb96>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
             cat-4290  [025] d..2    26.142846: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
             cat-4290  [025] d..2    26.142850: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
              ln-4293  [025] d..2    26.143633: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
              ln-4293  [025] d..2    26.143636: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
            uniq-4309  [027] d..2    26.149232: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
            uniq-4309  [027] d..2    26.149236: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
            grep-4312  [027] d..2    26.150960: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
            grep-4312  [027] d..2    26.150964: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
             cat-4313  [018] d..2    26.151684: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
             cat-4313  [018] d..2    26.151688: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
             cat-4316  [018] d..2    26.152445: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
             cat-4316  [018] d..2    26.152449: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
 cat-proc-vmstat-4321  [026] d..2    26.154806: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
 cat-proc-vmstat-4321  [026] d..2    26.154810: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
         wrapper-4322  [025] d..2    26.155261: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
         wrapper-4322  [025] d..2    26.155266: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => load_script+0x1be/0x1dc <ffffffff81204e18>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
         run-job-4179  [005] d..3    26.163530: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
         run-job-4179  [005] d..3    26.163534: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
            date-4342  [026] d..2    26.165310: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
            date-4342  [026] d..2    26.165313: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
           sleep-4346  [017] d..2    26.167062: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           sleep-4346  [017] d..2    26.167066: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
              ln-4350  [025] d..2    26.169556: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
              ln-4350  [025] d..2    26.169559: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
            grep-4351  [025] d..2    26.170301: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
            grep-4351  [025] d..2    26.170304: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
   gzip-slabinfo-4352  [019] d..2    26.171114: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
   gzip-slabinfo-4352  [019] d..2    26.171118: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
              ln-4365  [017] d..2    26.177229: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
              ln-4365  [017] d..2    26.177233: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
              ln-4366  [017] d..2    26.177977: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
              ln-4366  [017] d..2    26.177981: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
            grep-4367  [017] d..2    26.178749: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
            grep-4367  [017] d..2    26.178753: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
  gzip-buddyinfo-4368  [027] d..2    26.179567: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
  gzip-buddyinfo-4368  [027] d..2    26.179570: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
         run-job-4179  [006] d..3    26.180522: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
         run-job-4179  [006] d..3    26.180526: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       lock_stat-4412  [017] d..2    26.206810: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       lock_stat-4412  [017] d..2    26.206815: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => load_script+0x1be/0x1dc <ffffffff81204e18>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
   gzip-softirqs-4427  [019] d..2    26.212948: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
   gzip-softirqs-4427  [019] d..2    26.212952: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
        softirqs-4423  [011] d..2    26.216181: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
        softirqs-4423  [011] d..2    26.216184: <stack trace>
 => dup_mm+0x37e/0x480 <ffffffff810c1829>
 => copy_process.part.30+0xa58/0x11ee <ffffffff810c23ae>
 => do_fork+0xba/0x2ac <ffffffff810c2ce1>
 => SyS_clone+0x16/0x18 <ffffffff810c2f4d>
 => stub_clone+0x69/0x90 <ffffffff81a07969>
              ln-4451  [025] d..2    26.226603: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
              ln-4451  [025] d..2    26.226607: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
              ln-4452  [025] d..2    26.227228: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
              ln-4452  [025] d..2    26.227231: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
            grep-4453  [025] d..2    26.227897: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
            grep-4453  [025] d..2    26.227900: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
      cat-pmeter-4454  [025] d..2    26.228929: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
      cat-pmeter-4454  [025] d..2    26.228932: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
         run-job-4179  [012] d..3    26.229339: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
         run-job-4179  [012] d..3    26.229350: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
            date-5800  [027] d..2    27.144834: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
            date-5800  [027] d..2    27.144842: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
             cat-5814  [018] d..2    27.145746: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
             cat-5814  [018] d..2    27.145753: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
            date-6393  [018] d..2    27.184725: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
            date-6393  [018] d..2    27.184730: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
       hackbench-24991 [001] d..3    41.384620: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-24991 [001] d..3    41.384625: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-24992 [004] d..2    41.384729: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-24992 [004] d..2    41.384731: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => do_exit+0x38b/0x989 <ffffffff810c5a31>
 => do_group_exit+0x44/0xac <ffffffff810c60a9>
 => __wake_up_parent+0x0/0x28 <ffffffff810c6125>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
       hackbench-24994 [008] d..2    41.384734: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-24994 [008] d..2    41.384737: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => do_exit+0x38b/0x989 <ffffffff810c5a31>
 => do_group_exit+0x44/0xac <ffffffff810c60a9>
 => __wake_up_parent+0x0/0x28 <ffffffff810c6125>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
       hackbench-24987 [009] d..2    41.384745: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-24987 [009] d..2    41.384751: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => do_exit+0x38b/0x989 <ffffffff810c5a31>
 => do_group_exit+0x44/0xac <ffffffff810c60a9>
 => __wake_up_parent+0x0/0x28 <ffffffff810c6125>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
       hackbench-24998 [007] d..2    41.384786: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-24998 [007] d..2    41.384788: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => do_exit+0x38b/0x989 <ffffffff810c5a31>
 => do_group_exit+0x44/0xac <ffffffff810c60a9>
 => __wake_up_parent+0x0/0x28 <ffffffff810c6125>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
       hackbench-25005 [001] d..3    41.384887: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-25004 [008] d..3    41.384887: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-25004 [008] d..3    41.384889: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-25005 [001] d..3    41.384889: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-25006 [002] d..3    41.384894: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-25006 [002] d..3    41.384897: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-4486  [000] d..2    41.385039: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-4486  [000] d..2    41.385042: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => unmap_region+0xdd/0xef <ffffffff8118d0ff>
 => do_munmap+0x250/0x2e3 <ffffffff8118ea85>
 => vm_munmap+0x42/0x5b <ffffffff8118eb5a>
 => SyS_munmap+0x23/0x29 <ffffffff8118eb96>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
            date-25181 [025] d..2    41.385873: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
            date-25181 [025] d..2    41.385876: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
           <...>-36771 [018] d..2    42.173860: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-36771 [018] d..2    42.173866: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
           <...>-36845 [018] d..2    42.178786: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-36845 [018] d..2    42.178789: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
           <...>-37739 [018] d..2    42.240031: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-37739 [018] d..2    42.240037: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
           <...>-37824 [021] d..2    42.245561: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-37824 [021] d..2    42.245573: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
           <...>-38027 [018] d..2    42.259586: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-38027 [018] d..2    42.259589: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
           <...>-38037 [018] d..2    42.260263: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-38037 [018] d..2    42.260266: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
       hackbench-1955  [012] d..2    50.059494: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-1955  [012] d..2    50.059502: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => do_exit+0x38b/0x989 <ffffffff810c5a31>
 => do_group_exit+0x44/0xac <ffffffff810c60a9>
 => __wake_up_parent+0x0/0x28 <ffffffff810c6125>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
       hackbench-25433 [013] d..2    58.301248: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-25433 [013] d..2    58.301255: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => do_exit+0x38b/0x989 <ffffffff810c5a31>
 => do_group_exit+0x44/0xac <ffffffff810c60a9>
 => __wake_up_parent+0x0/0x28 <ffffffff810c6125>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
       hackbench-26510 [011] d..3    58.317961: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-26510 [011] d..3    58.317965: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-26324 [014] d..3    58.320884: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-26324 [014] d..3    58.320888: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-26318 [002] d..2    58.320890: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-26318 [002] d..2    58.320895: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => do_exit+0x38b/0x989 <ffffffff810c5a31>
 => do_group_exit+0x44/0xac <ffffffff810c60a9>
 => __wake_up_parent+0x0/0x28 <ffffffff810c6125>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
            date-5425  [017] d..2    58.330333: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
            date-5425  [017] d..2    58.330336: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
       hackbench-8204  [002] d..3    58.514084: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-8204  [002] d..3    58.514089: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
            date-16143 [018] d..2    59.069695: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
            date-16143 [018] d..2    59.069701: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
             cat-16150 [019] d..2    59.069929: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
             cat-16150 [019] d..2    59.069932: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
             cat-25756 [019] d..2    59.759720: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
             cat-25756 [019] d..2    59.759725: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
       hackbench-13288 [015] d..2    73.980401: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-13288 [015] d..2    73.980409: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => do_exit+0x38b/0x989 <ffffffff810c5a31>
 => do_group_exit+0x44/0xac <ffffffff810c60a9>
 => __wake_up_parent+0x0/0x28 <ffffffff810c6125>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
       hackbench-25763 [013] d..3    73.994915: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-25764 [025] d..3    73.994918: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-25763 [013] d..3    73.994918: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-25764 [025] d..3    73.994922: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-25908 [004] d..3    74.010041: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-25909 [000] d..3    74.010045: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-25908 [004] d..3    74.010046: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-25909 [000] d..3    74.010048: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-25922 [003] d..3    74.010285: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-25922 [003] d..3    74.010288: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-25927 [006] d..3    74.010291: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-25928 [007] d..3    74.010292: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-25927 [006] d..3    74.010294: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-25928 [007] d..3    74.010295: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-5426  [001] d..2    74.010515: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-5426  [001] d..2    74.010518: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => unmap_region+0xdd/0xef <ffffffff8118d0ff>
 => do_munmap+0x250/0x2e3 <ffffffff8118ea85>
 => vm_munmap+0x42/0x5b <ffffffff8118eb5a>
 => SyS_munmap+0x23/0x29 <ffffffff8118eb96>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
           <...>-35081 [018] d..2    74.688851: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-35081 [018] d..2    74.688868: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
           <...>-36129 [018] d..2    74.769295: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-36129 [018] d..2    74.769300: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
           <...>-38228 [018] d..2    74.925695: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-38228 [018] d..2    74.925700: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
           sleep-6273  [031] d..2    83.266936: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           sleep-6273  [031] d..2    83.266944: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
             cat-6275  [030] d..2    83.273009: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
             cat-6275  [030] d..2    83.273014: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
           <...>-37050 [011] d..2    94.044471: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-37050 [011] d..2    94.044477: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => do_exit+0x38b/0x989 <ffffffff810c5a31>
 => do_group_exit+0x44/0xac <ffffffff810c60a9>
 => __wake_up_parent+0x0/0x28 <ffffffff810c6125>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
       hackbench-2701  [018] d..3    94.062167: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-2701  [018] d..3    94.062173: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-2702  [006] d..3    94.062311: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-2702  [006] d..3    94.062314: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-2703  [018] d..3    94.062314: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-2703  [018] d..3    94.062317: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-6035  [008] d..3    94.066102: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-6035  [008] d..3    94.066105: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-6047  [002] d..3    94.066208: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-6048  [008] d..3    94.066211: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-6047  [002] d..3    94.066212: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-6048  [008] d..3    94.066213: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-6048  [003] d..2    94.066311: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-6048  [003] d..2    94.066313: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => do_exit+0x38b/0x989 <ffffffff810c5a31>
 => do_group_exit+0x44/0xac <ffffffff810c60a9>
 => __wake_up_parent+0x0/0x28 <ffffffff810c6125>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
       hackbench-6050  [004] d..3    94.066346: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-6052  [008] d..3    94.066349: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-6050  [004] d..3    94.066349: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-6052  [008] d..3    94.066351: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
            date-6516  [017] d..2    94.068870: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
            date-6516  [017] d..2    94.068873: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
       hackbench-6519  [025] d..2    94.071850: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-6519  [025] d..2    94.071856: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
             cat-6885  [021] d..2    94.094650: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
             cat-6885  [021] d..2    94.094655: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
             cat-16166 [018] d..2    94.725582: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
             cat-16166 [018] d..2    94.725588: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
           sleep-16180 [018] d..2    94.726505: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           sleep-16180 [018] d..2    94.726508: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
            date-27059 [029] d..2    95.744435: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
            date-27059 [029] d..2    95.744444: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
       hackbench-18038 [010] d..2   103.488759: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-18038 [010] d..2   103.488766: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => do_exit+0x38b/0x989 <ffffffff810c5a31>
 => do_group_exit+0x44/0xac <ffffffff810c60a9>
 => __wake_up_parent+0x0/0x28 <ffffffff810c6125>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
            date-27101 [031] d..2   104.152293: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
            date-27101 [031] d..2   104.152301: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
             cat-27102 [015] d..2   104.153279: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
             cat-27102 [015] d..2   104.153282: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
           sleep-27103 [031] d..2   104.154353: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           sleep-27103 [031] d..2   104.154356: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
       hackbench-23802 [022] d..3   109.609822: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-23802 [022] d..3   109.609828: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-27009 [013] d..3   109.638428: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-27009 [013] d..3   109.638434: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-27016 [015] d..3   109.638530: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-27016 [015] d..3   109.638533: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-27016 [001] d..2   109.638620: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-27016 [001] d..2   109.638622: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => do_exit+0x38b/0x989 <ffffffff810c5a31>
 => do_group_exit+0x44/0xac <ffffffff810c60a9>
 => __wake_up_parent+0x0/0x28 <ffffffff810c6125>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
       hackbench-27020 [014] d..3   109.638658: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-27020 [014] d..3   109.638661: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-6519  [001] d..2   109.638933: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-6519  [001] d..2   109.638935: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => unmap_region+0xdd/0xef <ffffffff8118d0ff>
 => do_munmap+0x250/0x2e3 <ffffffff8118ea85>
 => vm_munmap+0x42/0x5b <ffffffff8118eb5a>
 => SyS_munmap+0x23/0x29 <ffffffff8118eb96>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
           <...>-33101 [022] d..2   110.025868: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-33101 [022] d..2   110.025873: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
             cat-337   [018] d..2   110.561646: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
             cat-337   [018] d..2   110.561651: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
           sleep-346   [018] d..2   110.562326: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           sleep-346   [018] d..2   110.562341: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
             cat-7347  [010] d..2   115.462617: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
             cat-7347  [010] d..2   115.462625: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
             cat-7386  [030] d..2   117.003703: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
             cat-7386  [030] d..2   117.003712: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
           sleep-7521  [025] d..2   123.071016: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           sleep-7521  [025] d..2   123.071025: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
           <...>-34786 [014] d..2   131.534288: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-34786 [014] d..2   131.534295: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => do_exit+0x38b/0x989 <ffffffff810c5a31>
 => do_group_exit+0x44/0xac <ffffffff810c60a9>
 => __wake_up_parent+0x0/0x28 <ffffffff810c6125>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
       hackbench-311   [001] d..2   131.606508: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-32103 [004] d..2   131.606509: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-32103 [004] d..2   131.606514: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => do_exit+0x38b/0x989 <ffffffff810c5a31>
 => do_group_exit+0x44/0xac <ffffffff810c60a9>
 => __wake_up_parent+0x0/0x28 <ffffffff810c6125>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
       hackbench-311   [001] d..2   131.606514: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => do_exit+0x38b/0x989 <ffffffff810c5a31>
 => do_group_exit+0x44/0xac <ffffffff810c60a9>
 => __wake_up_parent+0x0/0x28 <ffffffff810c6125>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
           <...>-37587 [003] d..2   131.607612: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-37587 [003] d..2   131.607614: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => do_exit+0x38b/0x989 <ffffffff810c5a31>
 => do_group_exit+0x44/0xac <ffffffff810c60a9>
 => __wake_up_parent+0x0/0x28 <ffffffff810c6125>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
       hackbench-32259 [026] d..2   131.608986: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-32259 [026] d..2   131.608992: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => do_exit+0x38b/0x989 <ffffffff810c5a31>
 => do_group_exit+0x44/0xac <ffffffff810c60a9>
 => __wake_up_parent+0x0/0x28 <ffffffff810c6125>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
       hackbench-7229  [006] d..3   131.610144: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-7229  [006] d..3   131.610146: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
            date-7683  [022] d..2   131.611850: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
            date-7683  [022] d..2   131.611853: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
             cat-9996  [018] d..2   131.779603: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
             cat-9996  [018] d..2   131.779608: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
             cat-10006 [018] d..2   131.780217: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
             cat-10006 [018] d..2   131.780220: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
           sleep-10015 [018] d..2   131.780784: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           sleep-10015 [018] d..2   131.780787: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
             cat-10312 [018] d..2   131.800862: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
             cat-10312 [018] d..2   131.800865: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
           sleep-10324 [018] d..2   131.801643: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           sleep-10324 [018] d..2   131.801646: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
             cat-17878 [018] d..2   132.351484: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
             cat-17878 [018] d..2   132.351490: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
            date-23526 [018] d..2   132.781301: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
            date-23526 [018] d..2   132.781307: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
             cat-23539 [018] d..2   132.782127: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
             cat-23539 [018] d..2   132.782131: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
             cat-23550 [018] d..2   132.782825: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
             cat-23550 [018] d..2   132.782829: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
           sleep-23560 [018] d..2   132.783523: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           sleep-23560 [018] d..2   132.783527: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
            date-23793 [018] d..2   132.802025: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
            date-23793 [018] d..2   132.802029: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
             cat-23806 [018] d..2   132.802726: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
             cat-23806 [018] d..2   132.802730: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
           sleep-23825 [018] d..2   132.803977: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           sleep-23825 [018] d..2   132.803980: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
             cat-28313 [000] d..2   141.203886: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
             cat-28313 [000] d..2   141.203894: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
       hackbench-8852  [015] d..2   149.901367: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-8852  [015] d..2   149.901374: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => do_exit+0x38b/0x989 <ffffffff810c5a31>
 => do_group_exit+0x44/0xac <ffffffff810c60a9>
 => __wake_up_parent+0x0/0x28 <ffffffff810c6125>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
       hackbench-19078 [010] d..3   149.902214: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-19078 [010] d..3   149.902216: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-15270 [005] d..3   149.904612: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-15270 [005] d..3   149.904617: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
             cmd-28526 [000] d..2   149.922783: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
             cmd-28526 [000] d..2   149.922787: <stack trace>
 => dup_mm+0x37e/0x480 <ffffffff810c1829>
 => copy_process.part.30+0xa58/0x11ee <ffffffff810c23ae>
 => do_fork+0xba/0x2ac <ffffffff810c2ce1>
 => SyS_clone+0x16/0x18 <ffffffff810c2f4d>
 => stub_clone+0x69/0x90 <ffffffff81a07969>
           <...>-38073 [018] d..2   150.593573: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-38073 [018] d..2   150.593579: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
           <...>-39281 [028] d..2   166.599214: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-39281 [028] d..2   166.599221: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => do_exit+0x38b/0x989 <ffffffff810c5a31>
 => do_group_exit+0x44/0xac <ffffffff810c60a9>
 => __wake_up_parent+0x0/0x28 <ffffffff810c6125>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
           <...>-37747 [022] d..3   166.619673: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-37747 [022] d..3   166.619678: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-28812 [028] d..2   166.629939: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-28812 [028] d..2   166.629944: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => do_exit+0x38b/0x989 <ffffffff810c5a31>
 => do_group_exit+0x44/0xac <ffffffff810c60a9>
 => __wake_up_parent+0x0/0x28 <ffffffff810c6125>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
            date-8769  [025] d..2   166.636621: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
            date-8769  [025] d..2   166.636625: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
             cmd-8770  [000] d..2   166.639407: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
             cmd-8770  [000] d..2   166.639410: <stack trace>
 => dup_mm+0x37e/0x480 <ffffffff810c1829>
 => copy_process.part.30+0xa58/0x11ee <ffffffff810c23ae>
 => do_fork+0xba/0x2ac <ffffffff810c2ce1>
 => SyS_clone+0x16/0x18 <ffffffff810c2f4d>
 => stub_clone+0x69/0x90 <ffffffff81a07969>
            date-17790 [018] d..2   167.265466: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
            date-17790 [018] d..2   167.265472: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
             cat-17806 [018] d..2   167.266216: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
             cat-17806 [018] d..2   167.266219: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
           sleep-17817 [018] d..2   167.266836: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           sleep-17817 [018] d..2   167.266839: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
             cat-20623 [018] d..2   167.469762: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
             cat-20623 [018] d..2   167.469767: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
             cat-20634 [018] d..2   167.470426: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
             cat-20634 [018] d..2   167.470429: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
           sleep-20645 [018] d..2   167.471021: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           sleep-20645 [018] d..2   167.471025: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
             cat-29342 [009] d..2   176.505998: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
             cat-29342 [009] d..2   176.506007: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
       hackbench-8792  [030] d..2   183.412856: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-8792  [030] d..2   183.412864: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => do_exit+0x38b/0x989 <ffffffff810c5a31>
 => do_group_exit+0x44/0xac <ffffffff810c60a9>
 => __wake_up_parent+0x0/0x28 <ffffffff810c6125>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
       hackbench-14313 [006] d..3   183.441887: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-14313 [006] d..3   183.441894: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-29252 [000] d..3   183.455644: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-29252 [000] d..3   183.455649: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-29254 [015] d..3   183.455650: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-29254 [015] d..3   183.455653: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-29270 [015] d..3   183.455972: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-29270 [015] d..3   183.455974: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-8772  [001] d..2   183.457256: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-8772  [001] d..2   183.457259: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => unmap_region+0xdd/0xef <ffffffff8118d0ff>
 => do_munmap+0x250/0x2e3 <ffffffff8118ea85>
 => vm_munmap+0x42/0x5b <ffffffff8118eb5a>
 => SyS_munmap+0x23/0x29 <ffffffff8118eb96>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
             cmd-29494 [002] d..2   183.460944: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
             cmd-29494 [002] d..2   183.460946: <stack trace>
 => dup_mm+0x37e/0x480 <ffffffff810c1829>
 => copy_process.part.30+0xa58/0x11ee <ffffffff810c23ae>
 => do_fork+0xba/0x2ac <ffffffff810c2ce1>
 => SyS_clone+0x16/0x18 <ffffffff810c2f4d>
 => stub_clone+0x69/0x90 <ffffffff81a07969>
           <...>-39001 [027] d..2   184.106091: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-39001 [027] d..2   184.106098: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
           <...>-39035 [026] d..2   184.108017: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-39035 [026] d..2   184.108021: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
           <...>-39343 [026] d..2   184.131157: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-39343 [026] d..2   184.131161: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
           sleep-9606  [022] d..2   192.775662: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           sleep-9606  [022] d..2   192.775668: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
       diskstats-9617  [022] d..2   193.302132: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       diskstats-9617  [022] d..2   193.302138: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
    pagetypeinfo-9626  [018] dN.2   193.647370: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
    pagetypeinfo-9626  [018] dN.2   193.647377: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
       buddyinfo-9634  [022] d..2   193.964587: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       buddyinfo-9634  [022] d..2   193.964594: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
     proc-vmstat-9684  [016] d..2   195.804034: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
     proc-vmstat-9684  [016] d..2   195.804041: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
     numa-vmstat-9697  [018] d..2   196.157195: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
     numa-vmstat-9697  [018] d..2   196.157202: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
   numa-numastat-9737  [019] d..2   197.747432: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
   numa-numastat-9737  [019] d..2   197.747439: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
       hackbench-9457  [009] d..3   202.166188: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-9456  [000] d..3   202.166188: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-9456  [000] d..3   202.166195: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-9457  [009] d..3   202.166195: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-9461  [001] d..3   202.166203: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-9461  [001] d..3   202.166208: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-9466  [026] d..3   202.166295: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-9466  [026] d..3   202.166299: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-9473  [014] d..3   202.166426: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-9473  [014] d..3   202.166429: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-29496 [027] d..2   202.166622: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-29496 [027] d..2   202.166625: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => unmap_region+0xdd/0xef <ffffffff8118d0ff>
 => do_munmap+0x250/0x2e3 <ffffffff8118ea85>
 => vm_munmap+0x42/0x5b <ffffffff8118eb5a>
 => SyS_munmap+0x23/0x29 <ffffffff8118eb96>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
       hackbench-4478  [000] d..2   202.167970: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-4478  [000] d..2   202.167972: <stack trace>
 => dup_mm+0x37e/0x480 <ffffffff810c1829>
 => copy_process.part.30+0xa58/0x11ee <ffffffff810c23ae>
 => do_fork+0xba/0x2ac <ffffffff810c2ce1>
 => SyS_clone+0x16/0x18 <ffffffff810c2f4d>
 => stub_clone+0x69/0x90 <ffffffff81a07969>
             cmd-9815  [017] d..2   202.168153: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
             cmd-9815  [017] d..2   202.168157: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => load_script+0x1be/0x1dc <ffffffff81204e18>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
             cmd-9815  [000] d..2   202.171340: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
             cmd-9815  [000] d..2   202.171342: <stack trace>
 => dup_mm+0x37e/0x480 <ffffffff810c1829>
 => copy_process.part.30+0xa58/0x11ee <ffffffff810c23ae>
 => do_fork+0xba/0x2ac <ffffffff810c2ce1>
 => SyS_clone+0x16/0x18 <ffffffff810c2f4d>
 => stub_clone+0x69/0x90 <ffffffff81a07969>
       hackbench-9817  [025] d..2   202.171499: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-9817  [025] d..2   202.171502: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
           sleep-17046 [018] d..2   202.635324: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           sleep-17046 [018] d..2   202.635329: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
            date-17801 [018] d..2   202.686913: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
            date-17801 [018] d..2   202.686919: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
             cat-21179 [018] d..2   202.924592: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
             cat-21179 [018] d..2   202.924598: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
             cat-23892 [018] d..2   203.114688: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
             cat-23892 [018] d..2   203.114694: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
            date-30428 [026] d..2   211.708403: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
            date-30428 [026] d..2   211.708412: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
       hackbench-10107 [014] d..3   220.316928: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-10107 [014] d..3   220.316934: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-10111 [024] d..3   220.317044: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-10111 [024] d..3   220.317047: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-26460 [018] d..2   220.329147: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-26460 [018] d..2   220.329153: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => do_exit+0x38b/0x989 <ffffffff810c5a31>
 => do_group_exit+0x44/0xac <ffffffff810c60a9>
 => __wake_up_parent+0x0/0x28 <ffffffff810c6125>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
       hackbench-30262 [008] d..3   220.330323: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-30262 [008] d..3   220.330326: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-30264 [006] d..3   220.330329: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-30266 [003] d..3   220.330330: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-30264 [006] d..3   220.330332: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-30266 [003] d..3   220.330332: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-30268 [006] d..3   220.330459: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-30269 [008] d..3   220.330460: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-30268 [006] d..3   220.330462: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-30269 [008] d..3   220.330463: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-28978 [020] d..3   220.330606: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-28978 [020] d..3   220.330609: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-28985 [002] d..3   220.330829: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-28986 [004] d..3   220.330831: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-28987 [007] d..3   220.330831: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-28985 [002] d..3   220.330832: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-28987 [007] d..3   220.330834: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-28986 [004] d..3   220.330834: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-28988 [006] d..3   220.330838: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-28988 [006] d..3   220.330841: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
            date-30628 [017] d..2   220.333146: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
            date-30628 [017] d..2   220.333149: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
             cmd-30629 [000] d..2   220.339082: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
             cmd-30629 [000] d..2   220.339085: <stack trace>
 => dup_mm+0x37e/0x480 <ffffffff810c1829>
 => copy_process.part.30+0xa58/0x11ee <ffffffff810c23ae>
 => do_fork+0xba/0x2ac <ffffffff810c2ce1>
 => SyS_clone+0x16/0x18 <ffffffff810c2f4d>
 => stub_clone+0x69/0x90 <ffffffff81a07969>
            date-10694 [030] d..2   230.623859: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
            date-10694 [030] d..2   230.623868: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
            date-10703 [011] d..2   230.849553: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
            date-10703 [011] d..2   230.849561: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
     proc-vmstat-10725 [027] d..2   231.633076: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
     proc-vmstat-10725 [027] d..2   231.633085: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
           <...>-39616 [030] d..2   236.263770: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-39616 [030] d..2   236.263778: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => do_exit+0x38b/0x989 <ffffffff810c5a31>
 => do_group_exit+0x44/0xac <ffffffff810c60a9>
 => __wake_up_parent+0x0/0x28 <ffffffff810c6125>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
           <...>-34838 [000] d..2   236.265072: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-34838 [000] d..2   236.265076: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => do_exit+0x38b/0x989 <ffffffff810c5a31>
 => do_group_exit+0x44/0xac <ffffffff810c60a9>
 => __wake_up_parent+0x0/0x28 <ffffffff810c6125>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
       hackbench-10367 [006] d..3   236.281621: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-10367 [006] d..3   236.281627: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-10605 [023] d..3   236.306679: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-10605 [023] d..3   236.306683: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-10614 [003] d..3   236.306871: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-10614 [003] d..3   236.306874: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-10613 [000] d..3   236.306877: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-10616 [007] d..3   236.306880: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-10613 [000] d..3   236.306882: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-10616 [007] d..3   236.306883: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-10615 [006] d..3   236.306913: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-10615 [006] d..3   236.306916: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-30631 [007] d..2   236.307066: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-30631 [007] d..2   236.307068: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => unmap_region+0xdd/0xef <ffffffff8118d0ff>
 => do_munmap+0x250/0x2e3 <ffffffff8118ea85>
 => vm_munmap+0x42/0x5b <ffffffff8118eb5a>
 => SyS_munmap+0x23/0x29 <ffffffff8118eb96>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
            date-10829 [025] d..2   236.307914: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
            date-10829 [025] d..2   236.307917: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
             cmd-10830 [000] d..2   236.408599: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
             cmd-10830 [000] d..2   236.408604: <stack trace>
 => dup_mm+0x37e/0x480 <ffffffff810c1829>
 => copy_process.part.30+0xa58/0x11ee <ffffffff810c23ae>
 => do_fork+0xba/0x2ac <ffffffff810c2ce1>
 => SyS_clone+0x16/0x18 <ffffffff810c2f4d>
 => stub_clone+0x69/0x90 <ffffffff81a07969>
             cat-19468 [018] d..2   237.027290: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
             cat-19468 [018] d..2   237.027296: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
       buddyinfo-4364  [005] d..2   237.027836: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       buddyinfo-4364  [005] d..2   237.027838: <stack trace>
 => dup_mm+0x37e/0x480 <ffffffff810c1829>
 => copy_process.part.30+0xa58/0x11ee <ffffffff810c23ae>
 => do_fork+0xba/0x2ac <ffffffff810c2ce1>
 => SyS_clone+0x16/0x18 <ffffffff810c2f4d>
 => stub_clone+0x69/0x90 <ffffffff81a07969>
             cat-19913 [018] d..2   237.060094: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
             cat-19913 [018] d..2   237.060098: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
            date-19925 [018] d..2   237.061048: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
            date-19925 [018] d..2   237.061051: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
             cat-19930 [019] d..2   237.061263: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
             cat-19930 [019] d..2   237.061267: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
            date-20206 [018] d..2   237.082837: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
            date-20206 [018] d..2   237.082840: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
             cat-22452 [018] d..2   237.246747: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
             cat-22452 [018] d..2   237.246753: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
           sleep-22463 [018] d..2   237.247508: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           sleep-22463 [018] d..2   237.247511: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
       hackbench-29880 [007] d..3   255.449246: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-29880 [007] d..3   255.449252: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-31308 [005] d..3   255.469525: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-31310 [008] d..3   255.469526: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-31308 [005] d..3   255.469528: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-31312 [001] d..3   255.469529: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-31310 [008] d..3   255.469529: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-31312 [001] d..3   255.469531: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-31314 [003] d..3   255.469533: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-31314 [003] d..3   255.469536: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-31318 [007] d..3   255.469635: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-31318 [007] d..3   255.469638: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-31319 [001] d..3   255.469761: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-31319 [001] d..3   255.469763: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-31323 [002] d..3   255.469768: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-31324 [003] d..3   255.469770: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-31323 [002] d..3   255.469771: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-31324 [003] d..3   255.469772: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-31327 [022] d..3   255.469779: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-31327 [022] d..3   255.469782: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-10832 [000] d..2   255.469973: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-10832 [000] d..2   255.469978: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => unmap_region+0xdd/0xef <ffffffff8118d0ff>
 => do_munmap+0x250/0x2e3 <ffffffff8118ea85>
 => vm_munmap+0x42/0x5b <ffffffff8118eb5a>
 => SyS_munmap+0x23/0x29 <ffffffff8118eb96>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
            date-31663 [025] d..2   255.470867: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
            date-31663 [025] d..2   255.470871: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
           <...>-35594 [019] d..2   255.739725: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-35594 [019] d..2   255.739731: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
           <...>-35605 [018] d..2   255.740454: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-35605 [018] d..2   255.740458: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
           <...>-37646 [019] d..2   255.884609: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-37646 [019] d..2   255.884614: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
           <...>-37658 [018] d..2   255.885286: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-37658 [018] d..2   255.885289: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
           <...>-37670 [018] d..2   255.885905: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-37670 [018] d..2   255.885908: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
             cat-2404  [018] d..2   256.255378: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
             cat-2404  [018] d..2   256.255384: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
             cat-2416  [018] d..2   256.256043: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
             cat-2416  [018] d..2   256.256047: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
           sleep-2428  [018] d..2   256.256711: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           sleep-2428  [018] d..2   256.256715: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
            date-4067  [018] d..2   256.372788: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
            date-4067  [018] d..2   256.372794: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
            date-9358  [018] d..2   256.740999: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
            date-9358  [018] d..2   256.741005: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
             cat-9374  [018] d..2   256.741755: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
             cat-9374  [018] d..2   256.741759: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
           sleep-9386  [018] d..2   256.742415: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           sleep-9386  [018] d..2   256.742418: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
            date-11389 [018] d..2   256.886437: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
            date-11389 [018] d..2   256.886443: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
             cat-11403 [018] d..2   256.887254: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
             cat-11403 [018] d..2   256.887258: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
             cat-11413 [018] d..2   256.887971: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
             cat-11413 [018] d..2   256.887974: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
           sleep-11424 [018] d..2   256.888671: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           sleep-11424 [018] d..2   256.888674: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
       hackbench-31673 [010] d..2   272.051664: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-31673 [010] d..2   272.051671: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => do_exit+0x38b/0x989 <ffffffff810c5a31>
 => do_group_exit+0x44/0xac <ffffffff810c60a9>
 => __wake_up_parent+0x0/0x28 <ffffffff810c6125>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
       hackbench-11519 [006] d..2   272.086419: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-11519 [006] d..2   272.086425: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => do_exit+0x38b/0x989 <ffffffff810c5a31>
 => do_group_exit+0x44/0xac <ffffffff810c60a9>
 => __wake_up_parent+0x0/0x28 <ffffffff810c6125>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
       hackbench-11640 [000] d..3   272.100364: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-11640 [000] d..3   272.100367: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-11641 [009] d..3   272.100376: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-11641 [009] d..3   272.100379: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-11652 [014] d..3   272.100559: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-11653 [000] d..3   272.100560: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-11652 [014] d..3   272.100562: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
           <...>-11653 [000] d..3   272.100562: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-11655 [010] d..3   272.100563: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-11655 [010] d..3   272.100566: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-11656 [029] d..3   272.100566: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-11656 [029] d..3   272.100570: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-11649 [028] d..2   272.100576: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-11649 [028] d..2   272.100579: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => do_exit+0x38b/0x989 <ffffffff810c5a31>
 => do_group_exit+0x44/0xac <ffffffff810c60a9>
 => __wake_up_parent+0x0/0x28 <ffffffff810c6125>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
       hackbench-31666 [014] d..2   272.100762: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-31666 [014] d..2   272.100764: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => unmap_region+0xdd/0xef <ffffffff8118d0ff>
 => do_munmap+0x250/0x2e3 <ffffffff8118ea85>
 => vm_munmap+0x42/0x5b <ffffffff8118eb5a>
 => SyS_munmap+0x23/0x29 <ffffffff8118eb96>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
             cmd-11883 [000] d..2   272.105257: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
             cmd-11883 [000] d..2   272.105259: <stack trace>
 => dup_mm+0x37e/0x480 <ffffffff810c1829>
 => copy_process.part.30+0xa58/0x11ee <ffffffff810c23ae>
 => do_fork+0xba/0x2ac <ffffffff810c2ce1>
 => SyS_clone+0x16/0x18 <ffffffff810c2f4d>
 => stub_clone+0x69/0x90 <ffffffff81a07969>
           sleep-19207 [018] d..2   272.611303: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           sleep-19207 [018] d..2   272.611308: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
    numa-meminfo-4291  [012] d..2   272.836792: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
    numa-meminfo-4291  [012] d..2   272.836807: <stack trace>
 => dup_mm+0x37e/0x480 <ffffffff810c1829>
 => copy_process.part.30+0xa58/0x11ee <ffffffff810c23ae>
 => do_fork+0xba/0x2ac <ffffffff810c2ce1>
 => SyS_clone+0x16/0x18 <ffffffff810c2f4d>
 => stub_clone+0x69/0x90 <ffffffff81a07969>
            date-23794 [018] d..2   272.934305: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
            date-23794 [018] d..2   272.934310: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
            date-32462 [009] d..2   281.808680: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
            date-32462 [009] d..2   281.808688: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
         meminfo-32496 [028] dN.2   283.043054: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
         meminfo-32496 [028] dN.2   283.043063: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
       hackbench-17774 [014] d..2   288.706883: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-17774 [014] d..2   288.706891: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => do_exit+0x38b/0x989 <ffffffff810c5a31>
 => do_group_exit+0x44/0xac <ffffffff810c60a9>
 => __wake_up_parent+0x0/0x28 <ffffffff810c6125>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
       hackbench-23725 [023] d..3   288.723303: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-23725 [023] d..3   288.723308: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-23731 [008] d..3   288.723541: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-23731 [008] d..3   288.723543: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-23732 [001] d..3   288.723628: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-23732 [001] d..3   288.723631: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-32245 [014] d..3   288.724604: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-32245 [014] d..3   288.724607: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-32242 [009] d..2   288.724724: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-32242 [009] d..2   288.724727: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => do_exit+0x38b/0x989 <ffffffff810c5a31>
 => do_group_exit+0x44/0xac <ffffffff810c60a9>
 => __wake_up_parent+0x0/0x28 <ffffffff810c6125>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
       hackbench-32245 [010] d..2   288.724727: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-32245 [010] d..2   288.724730: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => do_exit+0x38b/0x989 <ffffffff810c5a31>
 => do_group_exit+0x44/0xac <ffffffff810c60a9>
 => __wake_up_parent+0x0/0x28 <ffffffff810c6125>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
       hackbench-32246 [014] d..2   288.724737: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-32246 [014] d..2   288.724739: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => do_exit+0x38b/0x989 <ffffffff810c5a31>
 => do_group_exit+0x44/0xac <ffffffff810c60a9>
 => __wake_up_parent+0x0/0x28 <ffffffff810c6125>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
       hackbench-32257 [024] d..2   288.724907: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-32257 [024] d..2   288.724911: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => do_exit+0x38b/0x989 <ffffffff810c5a31>
 => do_group_exit+0x44/0xac <ffffffff810c60a9>
 => __wake_up_parent+0x0/0x28 <ffffffff810c6125>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
            date-32628 [017] d..2   288.733944: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
            date-32628 [017] d..2   288.733948: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
             cmd-32629 [000] d..2   288.736797: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
             cmd-32629 [000] d..2   288.736800: <stack trace>
 => dup_mm+0x37e/0x480 <ffffffff810c1829>
 => copy_process.part.30+0xa58/0x11ee <ffffffff810c23ae>
 => do_fork+0xba/0x2ac <ffffffff810c2ce1>
 => SyS_clone+0x16/0x18 <ffffffff810c2f4d>
 => stub_clone+0x69/0x90 <ffffffff81a07969>
    pagetypeinfo-4380  [005] d..2   289.186152: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
    pagetypeinfo-4380  [005] d..2   289.186157: <stack trace>
 => dup_mm+0x37e/0x480 <ffffffff810c1829>
 => copy_process.part.30+0xa58/0x11ee <ffffffff810c23ae>
 => do_fork+0xba/0x2ac <ffffffff810c2ce1>
 => SyS_clone+0x16/0x18 <ffffffff810c2f4d>
 => stub_clone+0x69/0x90 <ffffffff81a07969>
           <...>-39703 [019] d..2   289.218423: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-39703 [019] d..2   289.218428: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
     proc-vmstat-4314  [001] d..2   289.442694: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
     proc-vmstat-4314  [001] d..2   289.442699: <stack trace>
 => dup_mm+0x37e/0x480 <ffffffff810c1829>
 => copy_process.part.30+0xa58/0x11ee <ffffffff810c23ae>
 => do_fork+0xba/0x2ac <ffffffff810c2ce1>
 => SyS_clone+0x16/0x18 <ffffffff810c2f4d>
 => stub_clone+0x69/0x90 <ffffffff81a07969>
       hackbench-10481 [011] d..3   305.039025: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-10481 [011] d..3   305.039032: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
            date-12874 [017] d..2   305.043240: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
            date-12874 [017] d..2   305.043245: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
             cmd-12875 [000] d..2   305.046024: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
             cmd-12875 [000] d..2   305.046027: <stack trace>
 => dup_mm+0x37e/0x480 <ffffffff810c1829>
 => copy_process.part.30+0xa58/0x11ee <ffffffff810c23ae>
 => do_fork+0xba/0x2ac <ffffffff810c2ce1>
 => SyS_clone+0x16/0x18 <ffffffff810c2f4d>
 => stub_clone+0x69/0x90 <ffffffff81a07969>
            date-22820 [018] d..2   305.722376: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
            date-22820 [018] d..2   305.722382: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
            date-24198 [018] d..2   305.820638: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
            date-24198 [018] d..2   305.820644: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
            date-25007 [018] d..2   305.877738: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
            date-25007 [018] d..2   305.877742: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
            date-26583 [018] d..2   305.989942: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
            date-26583 [018] d..2   305.989947: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
           sleep-26603 [018] d..2   305.991566: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           sleep-26603 [018] d..2   305.991569: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
           <...>-33489 [029] d..2   316.200806: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-33489 [029] d..2   316.200814: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
       hackbench-24052 [021] d..3   320.411188: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-24052 [021] d..3   320.411194: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-13327 [005] d..2   320.412872: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-13327 [005] d..2   320.412875: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => do_exit+0x38b/0x989 <ffffffff810c5a31>
 => do_group_exit+0x44/0xac <ffffffff810c60a9>
 => __wake_up_parent+0x0/0x28 <ffffffff810c6125>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
       hackbench-17774 [011] d..2   320.413096: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-17774 [011] d..2   320.413101: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => do_exit+0x38b/0x989 <ffffffff810c5a31>
 => do_group_exit+0x44/0xac <ffffffff810c60a9>
 => __wake_up_parent+0x0/0x28 <ffffffff810c6125>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
       hackbench-18175 [029] d..3   320.414436: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-18175 [029] d..3   320.414440: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-18173 [010] d..3   320.414469: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-18173 [010] d..3   320.414472: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-18177 [001] d..2   320.414596: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-18177 [001] d..2   320.414598: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => do_exit+0x38b/0x989 <ffffffff810c5a31>
 => do_group_exit+0x44/0xac <ffffffff810c60a9>
 => __wake_up_parent+0x0/0x28 <ffffffff810c6125>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
           <...>-33587 [017] d..2   320.428289: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-33587 [017] d..2   320.428293: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
           <...>-33588 [000] d..2   320.431108: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-33588 [000] d..2   320.431113: <stack trace>
 => dup_mm+0x37e/0x480 <ffffffff810c1829>
 => copy_process.part.30+0xa58/0x11ee <ffffffff810c23ae>
 => do_fork+0xba/0x2ac <ffffffff810c2ce1>
 => SyS_clone+0x16/0x18 <ffffffff810c2f4d>
 => stub_clone+0x69/0x90 <ffffffff81a07969>
            date-5492  [018] d..2   321.285665: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
            date-5492  [018] d..2   321.285671: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
             cat-5852  [018] d..2   321.312094: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
             cat-5852  [018] d..2   321.312098: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
             cat-5864  [018] d..2   321.312794: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
             cat-5864  [018] d..2   321.312797: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
           sleep-5877  [018] d..2   321.313547: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           sleep-5877  [018] d..2   321.313551: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
             cat-6426  [019] d..2   321.351980: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
             cat-6426  [019] d..2   321.351986: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
             cat-13625 [009] d..2   330.712911: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
             cat-13625 [009] d..2   330.712920: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
       hackbench-11999 [020] d..2   334.714576: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-11999 [020] d..2   334.714583: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => do_exit+0x38b/0x989 <ffffffff810c5a31>
 => do_group_exit+0x44/0xac <ffffffff810c60a9>
 => __wake_up_parent+0x0/0x28 <ffffffff810c6125>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
       hackbench-3568  [024] d..2   335.906807: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-3568  [024] d..2   335.906815: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => do_exit+0x38b/0x989 <ffffffff810c5a31>
 => do_group_exit+0x44/0xac <ffffffff810c60a9>
 => __wake_up_parent+0x0/0x28 <ffffffff810c6125>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
       hackbench-1396  [013] d..2   335.910351: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-1396  [013] d..2   335.910355: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => do_exit+0x38b/0x989 <ffffffff810c5a31>
 => do_group_exit+0x44/0xac <ffffffff810c60a9>
 => __wake_up_parent+0x0/0x28 <ffffffff810c6125>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
       hackbench-13547 [000] d..3   335.945106: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-13546 [009] d..3   335.945106: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-13545 [010] d..3   335.945108: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-13547 [000] d..3   335.945112: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-13546 [009] d..3   335.945112: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-13545 [010] d..3   335.945112: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-13556 [031] d..3   335.945127: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-13556 [031] d..3   335.945130: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-13561 [011] d..3   335.945238: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-13561 [011] d..3   335.945242: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-13564 [013] d..3   335.945305: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-13564 [013] d..3   335.945308: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
           <...>-33590 [001] d..2   335.951758: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-33590 [001] d..2   335.951762: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => unmap_region+0xdd/0xef <ffffffff8118d0ff>
 => do_munmap+0x250/0x2e3 <ffffffff8118ea85>
 => vm_munmap+0x42/0x5b <ffffffff8118eb5a>
 => SyS_munmap+0x23/0x29 <ffffffff8118eb96>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
            date-13757 [025] d..2   335.952581: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
            date-13757 [025] d..2   335.952585: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
             cmd-13758 [025] d..2   335.953308: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
             cmd-13758 [025] d..2   335.953311: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => load_script+0x1be/0x1dc <ffffffff81204e18>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
            date-13759 [025] d..2   335.954381: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
            date-13759 [025] d..2   335.954384: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
             cmd-13758 [002] d..2   335.956561: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
             cmd-13758 [002] d..2   335.956564: <stack trace>
 => dup_mm+0x37e/0x480 <ffffffff810c1829>
 => copy_process.part.30+0xa58/0x11ee <ffffffff810c23ae>
 => do_fork+0xba/0x2ac <ffffffff810c2ce1>
 => SyS_clone+0x16/0x18 <ffffffff810c2f4d>
 => stub_clone+0x69/0x90 <ffffffff81a07969>
            date-23531 [014] d..2   336.679319: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
            date-23531 [014] d..2   336.679325: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => do_exit+0x38b/0x989 <ffffffff810c5a31>
 => do_group_exit+0x44/0xac <ffffffff810c60a9>
 => __wake_up_parent+0x0/0x28 <ffffffff810c6125>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
            date-24701 [026] d..2   336.767783: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
            date-24701 [026] d..2   336.767790: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
           <...>-34302 [001] d..2   345.336043: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-34302 [001] d..2   345.336049: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
           <...>-34312 [019] d..2   345.884490: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-34312 [019] d..2   345.884496: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
           <...>-34320 [006] dN.2   346.238729: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-34320 [006] dN.2   346.238736: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
           <...>-34368 [018] d..2   348.109540: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-34368 [018] d..2   348.109546: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
           <...>-34394 [023] d..2   349.121762: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-34394 [023] d..2   349.121768: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
       hackbench-31437 [017] d..2   353.114041: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-31437 [017] d..2   353.114047: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => do_exit+0x38b/0x989 <ffffffff810c5a31>
 => do_group_exit+0x44/0xac <ffffffff810c60a9>
 => __wake_up_parent+0x0/0x28 <ffffffff810c6125>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
       hackbench-25405 [011] d..2   353.221349: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-25405 [011] d..2   353.221357: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => do_exit+0x38b/0x989 <ffffffff810c5a31>
 => do_group_exit+0x44/0xac <ffffffff810c60a9>
 => __wake_up_parent+0x0/0x28 <ffffffff810c6125>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
       hackbench-14761 [019] d..3   353.236477: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-14761 [019] d..3   353.236483: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-25030 [000] d..3   353.268911: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-25030 [000] d..3   353.268914: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-25035 [002] d..3   353.268922: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-25035 [002] d..3   353.268926: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-25044 [000] d..3   353.269021: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-25045 [004] d..3   353.269022: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-25044 [000] d..3   353.269023: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-25045 [004] d..3   353.269025: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-25029 [008] d..2   353.269127: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-25029 [008] d..2   353.269130: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => do_exit+0x38b/0x989 <ffffffff810c5a31>
 => do_group_exit+0x44/0xac <ffffffff810c60a9>
 => __wake_up_parent+0x0/0x28 <ffffffff810c6125>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
       hackbench-13760 [000] d..2   353.269311: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-13760 [000] d..2   353.269312: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => unmap_region+0xdd/0xef <ffffffff8118d0ff>
 => do_munmap+0x250/0x2e3 <ffffffff8118ea85>
 => vm_munmap+0x42/0x5b <ffffffff8118eb5a>
 => SyS_munmap+0x23/0x29 <ffffffff8118eb96>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
            date-1784  [018] d..2   353.816400: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
            date-1784  [018] d..2   353.816405: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
           sleep-2610  [018] d..2   353.876294: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           sleep-2610  [018] d..2   353.876300: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
             cat-3423  [019] d..2   353.935421: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
             cat-3423  [019] d..2   353.935427: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
            date-5514  [018] d..2   354.076524: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
            date-5514  [018] d..2   354.076530: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
           sleep-6174  [018] d..2   354.122191: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           sleep-6174  [018] d..2   354.122196: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
           <...>-34575 [001] d..3   370.587044: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-34575 [001] d..3   370.587049: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
           <...>-34478 [001] d..3   370.590777: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-34478 [001] d..3   370.590780: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
           <...>-34488 [008] d..3   370.590937: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-34489 [001] d..3   370.590939: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-34488 [008] d..3   370.590940: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
           <...>-34489 [001] d..3   370.590941: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
           <...>-34491 [002] d..3   370.590942: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-34493 [005] d..3   370.590943: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-34491 [002] d..3   370.590945: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
           <...>-34493 [005] d..3   370.590946: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
           <...>-34495 [003] d..3   370.590957: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-34496 [018] d..3   370.590957: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-34495 [003] d..3   370.590960: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
           <...>-34496 [018] d..3   370.590960: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
             cat-25052 [018] d..2   371.316744: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
             cat-25052 [018] d..2   371.316749: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
           sleep-25062 [018] d..2   371.317396: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           sleep-25062 [018] d..2   371.317399: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
             cat-26028 [018] d..2   371.384824: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
             cat-26028 [018] d..2   371.384829: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
           sleep-26042 [018] d..2   371.385594: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           sleep-26042 [018] d..2   371.385598: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
       hackbench-26125 [009] d..2   387.211207: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-26134 [000] d..2   387.211207: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-26134 [000] d..2   387.211213: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => do_exit+0x38b/0x989 <ffffffff810c5a31>
 => do_group_exit+0x44/0xac <ffffffff810c60a9>
 => __wake_up_parent+0x0/0x28 <ffffffff810c6125>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
       hackbench-26125 [009] d..2   387.211213: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => do_exit+0x38b/0x989 <ffffffff810c5a31>
 => do_group_exit+0x44/0xac <ffffffff810c60a9>
 => __wake_up_parent+0x0/0x28 <ffffffff810c6125>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
           <...>-33741 [024] d..3   387.229243: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-33741 [024] d..3   387.229247: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
           <...>-35169 [004] d..3   387.249125: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-35165 [002] d..3   387.249125: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-35169 [004] d..3   387.249130: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
           <...>-35165 [002] d..3   387.249130: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
           <...>-35176 [005] d..3   387.249227: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-35176 [005] d..3   387.249230: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
           <...>-35178 [001] d..3   387.249247: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-35178 [001] d..3   387.249250: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
           <...>-35176 [006] d..2   387.249361: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-35176 [006] d..2   387.249363: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => do_exit+0x38b/0x989 <ffffffff810c5a31>
 => do_group_exit+0x44/0xac <ffffffff810c60a9>
 => __wake_up_parent+0x0/0x28 <ffffffff810c6125>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
       hackbench-14689 [000] d..2   387.249634: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-14689 [000] d..2   387.249636: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => unmap_region+0xdd/0xef <ffffffff8118d0ff>
 => do_munmap+0x250/0x2e3 <ffffffff8118ea85>
 => vm_munmap+0x42/0x5b <ffffffff8118eb5a>
 => SyS_munmap+0x23/0x29 <ffffffff8118eb96>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
           <...>-35414 [000] d..2   387.253798: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-35414 [000] d..2   387.253800: <stack trace>
 => dup_mm+0x37e/0x480 <ffffffff810c1829>
 => copy_process.part.30+0xa58/0x11ee <ffffffff810c23ae>
 => do_fork+0xba/0x2ac <ffffffff810c2ce1>
 => SyS_clone+0x16/0x18 <ffffffff810c2f4d>
 => stub_clone+0x69/0x90 <ffffffff81a07969>
           <...>-38160 [019] d..2   387.434742: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-38160 [019] d..2   387.434748: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
            date-5187  [018] d..2   387.963000: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
            date-5187  [018] d..2   387.963006: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
            date-6902  [018] d..2   388.085003: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
            date-6902  [018] d..2   388.085009: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
             cat-7171  [018] d..2   388.104827: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
             cat-7171  [018] d..2   388.104831: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
       hackbench-9143  [010] d..3   403.332935: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-9143  [010] d..3   403.332942: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-1823  [003] d..3   403.341238: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-1823  [003] d..3   403.341243: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-1839  [001] d..3   403.341443: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-1839  [001] d..3   403.341446: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
            date-15633 [017] d..2   403.349788: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
            date-15633 [017] d..2   403.349792: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
             cmd-15634 [017] d..2   403.350472: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
             cmd-15634 [017] d..2   403.350476: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => load_script+0x1be/0x1dc <ffffffff81204e18>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
             cmd-15634 [000] d..2   403.353760: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
             cmd-15634 [000] d..2   403.353764: <stack trace>
 => dup_mm+0x37e/0x480 <ffffffff810c1829>
 => copy_process.part.30+0xa58/0x11ee <ffffffff810c23ae>
 => do_fork+0xba/0x2ac <ffffffff810c2ce1>
 => SyS_clone+0x16/0x18 <ffffffff810c2f4d>
 => stub_clone+0x69/0x90 <ffffffff81a07969>
            date-27186 [017] d..2   404.136325: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
            date-27186 [017] d..2   404.136331: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
            date-27849 [018] d..2   404.182313: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
            date-27849 [018] d..2   404.182319: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
           sleep-28224 [018] d..2   404.208279: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           sleep-28224 [018] d..2   404.208283: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
           <...>-36281 [028] d..2   415.353277: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-36281 [028] d..2   415.353286: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
       hackbench-23696 [021] d..3   419.678000: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-23696 [021] d..3   419.678006: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
           <...>-35673 [013] d..2   419.678891: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-35673 [013] d..2   419.678896: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => do_exit+0x38b/0x989 <ffffffff810c5a31>
 => do_group_exit+0x44/0xac <ffffffff810c60a9>
 => __wake_up_parent+0x0/0x28 <ffffffff810c6125>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
       hackbench-26161 [018] d..2   419.701866: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-26161 [018] d..2   419.701869: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => do_exit+0x38b/0x989 <ffffffff810c5a31>
 => do_group_exit+0x44/0xac <ffffffff810c60a9>
 => __wake_up_parent+0x0/0x28 <ffffffff810c6125>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
       hackbench-26170 [008] d..3   419.701999: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-26169 [006] d..3   419.702000: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-26170 [008] d..3   419.702002: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-26169 [006] d..3   419.702002: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-26175 [003] d..3   419.702121: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-26175 [003] d..3   419.702123: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-26177 [007] d..3   419.702125: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-26178 [008] d..3   419.702126: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-26177 [007] d..3   419.702128: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-26178 [008] d..3   419.702128: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-15636 [001] d..2   419.708291: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-15636 [001] d..2   419.708293: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => unmap_region+0xdd/0xef <ffffffff8118d0ff>
 => do_munmap+0x250/0x2e3 <ffffffff8118ea85>
 => vm_munmap+0x42/0x5b <ffffffff8118eb5a>
 => SyS_munmap+0x23/0x29 <ffffffff8118eb96>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
             cat-5788  [026] d..2   420.420661: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
             cat-5788  [026] d..2   420.420668: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
           sleep-5804  [026] d..2   420.421581: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           sleep-5804  [026] d..2   420.421584: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
            date-6580  [026] d..2   420.477573: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
            date-6580  [026] d..2   420.477579: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
           sleep-6601  [026] d..2   420.478917: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           sleep-6601  [026] d..2   420.478920: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
            date-16487 [021] d..2   429.066880: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
            date-16487 [021] d..2   429.066887: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
            date-16490 [019] d..2   429.088763: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
            date-16490 [019] d..2   429.088767: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
     numa-vmstat-16501 [006] d..2   429.153385: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
     numa-vmstat-16501 [006] d..2   429.153391: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
        slabinfo-16504 [021] d..2   429.790110: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
        slabinfo-16504 [021] d..2   429.790117: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
       diskstats-16512 [021] dN.2   429.905224: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       diskstats-16512 [021] dN.2   429.905229: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
       hackbench-5821  [013] d..2   438.998932: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-5821  [013] d..2   438.998940: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => do_exit+0x38b/0x989 <ffffffff810c5a31>
 => do_group_exit+0x44/0xac <ffffffff810c60a9>
 => __wake_up_parent+0x0/0x28 <ffffffff810c6125>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
       hackbench-16187 [006] d..2   439.009408: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-16187 [006] d..2   439.009414: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => do_exit+0x38b/0x989 <ffffffff810c5a31>
 => do_group_exit+0x44/0xac <ffffffff810c60a9>
 => __wake_up_parent+0x0/0x28 <ffffffff810c6125>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
       hackbench-12599 [024] d..2   439.018669: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-12594 [015] d..2   439.018672: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-12599 [024] d..2   439.018674: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => do_exit+0x38b/0x989 <ffffffff810c5a31>
 => do_group_exit+0x44/0xac <ffffffff810c60a9>
 => __wake_up_parent+0x0/0x28 <ffffffff810c6125>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
       hackbench-12594 [015] d..2   439.018675: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => do_exit+0x38b/0x989 <ffffffff810c5a31>
 => do_group_exit+0x44/0xac <ffffffff810c60a9>
 => __wake_up_parent+0x0/0x28 <ffffffff810c6125>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
       hackbench-13701 [015] d..3   439.021600: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-13701 [015] d..3   439.021602: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-13712 [012] d..3   439.021726: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-13712 [012] d..3   439.021729: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-1072  [006] d..3   439.022104: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-1072  [006] d..3   439.022107: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-1071  [031] d..3   439.022108: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-1071  [031] d..3   439.022110: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
            date-16712 [017] d..2   439.026648: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
            date-16712 [017] d..2   439.026652: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
             cmd-16713 [000] d..2   439.029424: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
             cmd-16713 [000] d..2   439.029426: <stack trace>
 => dup_mm+0x37e/0x480 <ffffffff810c1829>
 => copy_process.part.30+0xa58/0x11ee <ffffffff810c23ae>
 => do_fork+0xba/0x2ac <ffffffff810c2ce1>
 => SyS_clone+0x16/0x18 <ffffffff810c2f4d>
 => stub_clone+0x69/0x90 <ffffffff81a07969>
             cat-20281 [027] d..2   439.261883: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
             cat-20281 [027] d..2   439.261891: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
             cat-25484 [018] d..2   439.625854: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
             cat-25484 [018] d..2   439.625860: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
           sleep-25496 [018] d..2   439.626604: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           sleep-25496 [018] d..2   439.626607: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
            date-28685 [018] d..2   439.855131: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
            date-28685 [018] d..2   439.855137: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
             cat-28703 [018] d..2   439.856016: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
             cat-28703 [018] d..2   439.856020: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
             cat-28724 [019] d..2   439.857427: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
             cat-28724 [019] d..2   439.857442: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
           sleep-28738 [018] d..2   439.858151: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           sleep-28738 [018] d..2   439.858154: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
       hackbench-16729 [011] d..2   454.397346: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-16729 [011] d..2   454.397353: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => do_exit+0x38b/0x989 <ffffffff810c5a31>
 => do_group_exit+0x44/0xac <ffffffff810c60a9>
 => __wake_up_parent+0x0/0x28 <ffffffff810c6125>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
       hackbench-17331 [000] d..3   454.399006: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-17331 [000] d..3   454.399009: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-16715 [000] d..2   454.415822: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-16715 [000] d..2   454.415826: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => unmap_region+0xdd/0xef <ffffffff8118d0ff>
 => do_munmap+0x250/0x2e3 <ffffffff8118ea85>
 => vm_munmap+0x42/0x5b <ffffffff8118eb5a>
 => SyS_munmap+0x23/0x29 <ffffffff8118eb96>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
           <...>-37432 [025] d..2   454.416663: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-37432 [025] d..2   454.416666: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
           <...>-37433 [000] d..2   454.419520: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-37433 [000] d..2   454.419522: <stack trace>
 => dup_mm+0x37e/0x480 <ffffffff810c1829>
 => copy_process.part.30+0xa58/0x11ee <ffffffff810c23ae>
 => do_fork+0xba/0x2ac <ffffffff810c2ce1>
 => SyS_clone+0x16/0x18 <ffffffff810c2f4d>
 => stub_clone+0x69/0x90 <ffffffff81a07969>
           <...>-38412 [019] d..2   454.480947: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-38412 [019] d..2   454.480952: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
           sleep-6420  [018] d..2   455.056449: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           sleep-6420  [018] d..2   455.056456: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
     numa-vmstat-17528 [012] d..2   464.636584: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
     numa-vmstat-17528 [012] dn.2   464.636593: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
       hackbench-8750  [011] d..2   471.391914: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-8750  [011] d..2   471.391922: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => do_exit+0x38b/0x989 <ffffffff810c5a31>
 => do_group_exit+0x44/0xac <ffffffff810c60a9>
 => __wake_up_parent+0x0/0x28 <ffffffff810c6125>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
       hackbench-8674  [028] d..2   471.405240: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-8674  [028] d..2   471.405245: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => do_exit+0x38b/0x989 <ffffffff810c5a31>
 => do_group_exit+0x44/0xac <ffffffff810c60a9>
 => __wake_up_parent+0x0/0x28 <ffffffff810c6125>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
       hackbench-17410 [007] d..3   471.414603: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-17410 [007] d..3   471.414608: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-17417 [004] d..3   471.414727: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-17418 [021] d..3   471.414728: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-17419 [008] d..3   471.414729: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-17417 [004] d..3   471.414730: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-17418 [021] d..3   471.414731: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-17419 [008] d..3   471.414732: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
            date-17686 [017] d..2   471.417906: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
            date-17686 [017] d..2   471.417910: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
       hackbench-17689 [025] d..2   471.421910: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-17689 [025] d..2   471.421915: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
           sleep-27181 [018] d..2   472.077665: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           sleep-27181 [018] d..2   472.077671: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
            date-28065 [018] d..2   472.139008: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
            date-28065 [018] d..2   472.139014: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
            date-28356 [018] d..2   472.159720: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
            date-28356 [018] d..2   472.159723: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
           sleep-28404 [018] d..2   472.163164: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           sleep-28404 [018] d..2   472.163167: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
            date-28673 [018] d..2   472.183239: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
            date-28673 [018] d..2   472.183243: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
           <...>-38249 [030] d..2   481.601517: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-38249 [030] d..2   481.601527: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
       hackbench-19653 [014] d..2   487.770502: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-19653 [014] d..2   487.770509: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => do_exit+0x38b/0x989 <ffffffff810c5a31>
 => do_group_exit+0x44/0xac <ffffffff810c60a9>
 => __wake_up_parent+0x0/0x28 <ffffffff810c6125>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
           <...>-38162 [001] d..3   487.801321: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-38163 [002] d..3   487.801321: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-38163 [002] d..3   487.801326: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
           <...>-38162 [001] d..3   487.801326: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
           <...>-38166 [000] d..3   487.801330: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-38166 [000] d..3   487.801335: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
           <...>-38173 [023] d..3   487.801526: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-38173 [023] d..3   487.801529: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
           <...>-38178 [004] d..3   487.801654: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-38178 [004] d..3   487.801657: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-17689 [000] d..2   487.801848: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-17689 [000] d..2   487.801850: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => unmap_region+0xdd/0xef <ffffffff8118d0ff>
 => do_munmap+0x250/0x2e3 <ffffffff8118ea85>
 => vm_munmap+0x42/0x5b <ffffffff8118eb5a>
 => SyS_munmap+0x23/0x29 <ffffffff8118eb96>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
            date-9301  [018] d..2   488.610320: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
            date-9301  [018] d..2   488.610326: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
       hackbench-17968 [030] d..2   503.299042: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-17968 [030] d..2   503.299049: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => do_exit+0x38b/0x989 <ffffffff810c5a31>
 => do_group_exit+0x44/0xac <ffffffff810c60a9>
 => __wake_up_parent+0x0/0x28 <ffffffff810c6125>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
       hackbench-18369 [012] d..3   503.302507: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-18369 [012] d..3   503.302510: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-18376 [009] d..3   503.302605: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-18376 [009] d..3   503.302608: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-18378 [015] d..3   503.302735: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-18378 [015] d..3   503.302738: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-18377 [004] d..3   503.302744: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-18377 [004] d..3   503.302749: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
            date-18621 [017] d..2   503.304094: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
            date-18621 [017] d..2   503.304098: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
             cmd-18622 [017] d..2   503.304787: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
             cmd-18622 [017] d..2   503.304791: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => load_script+0x1be/0x1dc <ffffffff81204e18>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
             cmd-18622 [000] d..2   503.306864: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
             cmd-18622 [000] d..2   503.306867: <stack trace>
 => dup_mm+0x37e/0x480 <ffffffff810c1829>
 => copy_process.part.30+0xa58/0x11ee <ffffffff810c23ae>
 => do_fork+0xba/0x2ac <ffffffff810c2ce1>
 => SyS_clone+0x16/0x18 <ffffffff810c2f4d>
 => stub_clone+0x69/0x90 <ffffffff81a07969>
           sleep-22911 [018] d..2   503.590304: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           sleep-22911 [018] d..2   503.590309: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
             cat-23271 [018] d..2   503.616071: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
             cat-23271 [018] d..2   503.616075: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
           sleep-28957 [018] d..2   504.014071: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           sleep-28957 [018] d..2   504.014076: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
            date-29137 [018] d..2   504.026857: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
            date-29137 [018] d..2   504.026860: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
             cat-32411 [018] d..2   504.259520: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
             cat-32411 [018] d..2   504.259525: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
             cat-32423 [018] d..2   504.260170: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
             cat-32423 [018] d..2   504.260173: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
           sleep-32434 [018] d..2   504.260796: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           sleep-32434 [018] d..2   504.260800: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
           <...>-37040 [018] d..2   504.591363: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-37040 [018] d..2   504.591369: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
           <...>-37050 [018] d..2   504.592002: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-37050 [018] d..2   504.592006: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
           <...>-39272 [026] d..2   510.774177: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-39272 [026] d..2   510.774184: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
       hackbench-18919 [020] d..3   525.327423: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-18919 [020] d..3   525.327429: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-18921 [002] d..3   525.327556: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-18920 [005] d..3   525.327556: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-18921 [002] d..3   525.327558: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-18920 [005] d..3   525.327559: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-18923 [005] d..3   525.327694: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-18924 [020] d..3   525.327695: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-18923 [005] d..3   525.327697: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-18924 [020] d..3   525.327698: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
           <...>-37603 [007] d..2   525.329785: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-37603 [007] d..2   525.329788: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => do_exit+0x38b/0x989 <ffffffff810c5a31>
 => do_group_exit+0x44/0xac <ffffffff810c60a9>
 => __wake_up_parent+0x0/0x28 <ffffffff810c6125>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
           <...>-39577 [017] d..2   525.338675: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-39577 [017] d..2   525.338678: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
            date-10856 [018] d..2   526.208864: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
            date-10856 [018] d..2   526.208871: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
             cat-10870 [018] d..2   526.209663: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
             cat-10870 [018] d..2   526.209667: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
             cat-10881 [018] d..2   526.210409: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
             cat-10881 [018] d..2   526.210413: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
           sleep-10893 [018] d..2   526.211100: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           sleep-10893 [018] d..2   526.211104: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
             cat-11650 [018] d..2   526.267404: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
             cat-11650 [018] d..2   526.267409: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
           sleep-11660 [018] d..2   526.268093: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           sleep-11660 [018] d..2   526.268097: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
       hackbench-2492  [012] d..3   541.156654: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-2492  [012] d..3   541.156661: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-19351 [000] d..2   541.160888: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-19351 [000] d..2   541.160891: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => do_exit+0x38b/0x989 <ffffffff810c5a31>
 => do_group_exit+0x44/0xac <ffffffff810c60a9>
 => __wake_up_parent+0x0/0x28 <ffffffff810c6125>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
       hackbench-19357 [010] d..3   541.160894: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-19357 [010] d..3   541.160897: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
            date-19804 [017] d..2   541.185425: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
            date-19804 [017] d..2   541.185430: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
           <...>-40436 [000] d..2   553.570201: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-40436 [000] d..2   553.570209: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
       hackbench-20062 [010] d..2   557.104493: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-20062 [010] d..2   557.104501: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => do_exit+0x38b/0x989 <ffffffff810c5a31>
 => do_group_exit+0x44/0xac <ffffffff810c60a9>
 => __wake_up_parent+0x0/0x28 <ffffffff810c6125>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
           <...>-40250 [011] d..3   557.120655: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-40250 [011] d..3   557.120661: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
           <...>-40255 [011] d..3   557.120785: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-40254 [010] d..3   557.120787: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-40255 [011] d..3   557.120787: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
           <...>-40254 [010] d..3   557.120789: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
           <...>-40259 [030] d..3   557.120795: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-40259 [030] d..3   557.120799: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
           <...>-40293 [011] d..3   557.127072: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-40292 [010] d..3   557.127074: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-40293 [011] d..3   557.127075: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
           <...>-40292 [010] d..3   557.127077: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
            date-9676  [019] d..2   557.792696: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
            date-9676  [019] d..2   557.792702: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
           sleep-9709  [018] d..2   557.794744: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           sleep-9709  [018] d..2   557.794747: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
           sleep-12583 [018] d..2   557.999609: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           sleep-12583 [018] d..2   557.999615: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
             cat-13335 [018] d..2   558.053559: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
             cat-13335 [018] d..2   558.053564: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
         meminfo-20548 [024] dN.2   559.205383: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
         meminfo-20548 [024] dN.2   559.205391: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
         meminfo-20581 [014] d..2   566.213924: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
         meminfo-20581 [014] d..2   566.213932: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
       hackbench-20041 [027] d..2   574.935680: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-20041 [027] d..2   574.935687: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => do_exit+0x38b/0x989 <ffffffff810c5a31>
 => do_group_exit+0x44/0xac <ffffffff810c60a9>
 => __wake_up_parent+0x0/0x28 <ffffffff810c6125>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
       hackbench-20509 [022] d..3   574.943152: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-20509 [022] d..3   574.943158: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-20015 [029] d..3   574.943570: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-20015 [029] d..3   574.943574: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-20023 [014] d..2   574.943774: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-20023 [014] d..2   574.943776: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => do_exit+0x38b/0x989 <ffffffff810c5a31>
 => do_group_exit+0x44/0xac <ffffffff810c60a9>
 => __wake_up_parent+0x0/0x28 <ffffffff810c6125>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
       hackbench-20028 [010] d..3   574.943806: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-20028 [010] d..3   574.943809: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
           <...>-40535 [001] d..2   574.944045: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-40535 [001] d..2   574.944048: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => unmap_region+0xdd/0xef <ffffffff8118d0ff>
 => do_munmap+0x250/0x2e3 <ffffffff8118ea85>
 => vm_munmap+0x42/0x5b <ffffffff8118eb5a>
 => SyS_munmap+0x23/0x29 <ffffffff8118eb96>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
            date-20774 [018] d..2   574.945073: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
            date-20774 [018] d..2   574.945076: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
       hackbench-4478  [010] d..2   574.945471: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-4478  [010] d..2   574.945473: <stack trace>
 => dup_mm+0x37e/0x480 <ffffffff810c1829>
 => copy_process.part.30+0xa58/0x11ee <ffffffff810c23ae>
 => do_fork+0xba/0x2ac <ffffffff810c2ce1>
 => SyS_clone+0x16/0x18 <ffffffff810c2f4d>
 => stub_clone+0x69/0x90 <ffffffff81a07969>
             cmd-20775 [017] d..2   574.945643: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
             cmd-20775 [017] d..2   574.945647: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => load_script+0x1be/0x1dc <ffffffff81204e18>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
             cat-20776 [018] d..2   574.945804: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
             cat-20776 [018] d..2   574.945807: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
             cat-20777 [018] d..2   574.946398: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
             cat-20777 [018] d..2   574.946401: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
            date-20778 [017] d..2   574.946680: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
            date-20778 [017] d..2   574.946683: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
            date-25954 [031] d..2   575.299137: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
            date-25954 [031] d..2   575.299144: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
            date-30421 [031] d..2   575.618382: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
            date-30421 [031] d..2   575.618389: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
             cat-30441 [018] d..2   575.619326: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
             cat-30441 [018] d..2   575.619331: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
           <...>-33622 [026] d..2   575.847838: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-33622 [026] d..2   575.847846: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
             cat-755   [003] d..2   586.162355: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
             cat-755   [003] d..2   586.162362: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
           <...>-36949 [003] d..3   591.923411: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-36950 [005] d..3   591.923411: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-36949 [003] d..3   591.923416: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
           <...>-36950 [005] d..3   591.923416: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
           <...>-36947 [002] d..2   591.923521: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-36947 [002] d..2   591.923523: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => do_exit+0x38b/0x989 <ffffffff810c5a31>
 => do_group_exit+0x44/0xac <ffffffff810c60a9>
 => __wake_up_parent+0x0/0x28 <ffffffff810c6125>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
           <...>-38106 [014] d..2   591.923797: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-38106 [014] d..2   591.923803: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => do_exit+0x38b/0x989 <ffffffff810c5a31>
 => do_group_exit+0x44/0xac <ffffffff810c60a9>
 => __wake_up_parent+0x0/0x28 <ffffffff810c6125>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
             cmd-884   [000] d..2   591.942744: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
             cmd-884   [000] d..2   591.942747: <stack trace>
 => dup_mm+0x37e/0x480 <ffffffff810c1829>
 => copy_process.part.30+0xa58/0x11ee <ffffffff810c23ae>
 => do_fork+0xba/0x2ac <ffffffff810c2ce1>
 => SyS_clone+0x16/0x18 <ffffffff810c2f4d>
 => stub_clone+0x69/0x90 <ffffffff81a07969>
            date-14857 [018] d..2   592.893222: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
            date-14857 [018] d..2   592.893227: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
       hackbench-13947 [029] d..2   607.926390: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-13947 [029] d..2   607.926398: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => do_exit+0x38b/0x989 <ffffffff810c5a31>
 => do_group_exit+0x44/0xac <ffffffff810c60a9>
 => __wake_up_parent+0x0/0x28 <ffffffff810c6125>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
       hackbench-21504 [001] d..2   608.104614: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-21504 [001] d..2   608.104618: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => do_exit+0x38b/0x989 <ffffffff810c5a31>
 => do_group_exit+0x44/0xac <ffffffff810c60a9>
 => __wake_up_parent+0x0/0x28 <ffffffff810c6125>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
       hackbench-887   [027] d..3   608.109310: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-887   [027] d..3   608.109316: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-893   [012] d..3   608.109323: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-898   [026] d..3   608.109324: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-893   [012] d..3   608.109327: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-898   [026] d..3   608.109328: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-904   [015] d..3   608.109484: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-906   [000] d..3   608.109487: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-904   [015] d..3   608.109487: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-906   [000] d..3   608.109490: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
            date-21754 [017] d..2   608.113636: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
            date-21754 [017] d..2   608.113639: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
             cmd-21755 [000] d..2   608.117241: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
             cmd-21755 [000] d..2   608.117243: <stack trace>
 => dup_mm+0x37e/0x480 <ffffffff810c1829>
 => copy_process.part.30+0xa58/0x11ee <ffffffff810c23ae>
 => do_fork+0xba/0x2ac <ffffffff810c2ce1>
 => SyS_clone+0x16/0x18 <ffffffff810c2f4d>
 => stub_clone+0x69/0x90 <ffffffff81a07969>
           <...>-33501 [018] d..2   608.948750: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-33501 [018] d..2   608.948756: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
           <...>-34109 [016] d..2   608.991902: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-34109 [016] d..2   608.991907: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
           <...>-37454 [019] d..2   609.244419: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-37454 [019] d..2   609.244425: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
           <...>-34765 [015] d..2   628.488220: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-34765 [015] d..2   628.488227: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => do_exit+0x38b/0x989 <ffffffff810c5a31>
 => do_group_exit+0x44/0xac <ffffffff810c60a9>
 => __wake_up_parent+0x0/0x28 <ffffffff810c6125>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
           <...>-32820 [027] d..3   628.494492: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           <...>-32820 [027] d..3   628.494495: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-23685 [004] d..3   628.507366: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-23685 [004] d..3   628.507371: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-23691 [017] d..3   628.507564: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-23690 [006] d..3   628.507565: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-23691 [017] d..3   628.507567: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-23690 [006] d..3   628.507569: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-23693 [001] d..2   628.507665: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-23693 [001] d..2   628.507668: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => do_exit+0x38b/0x989 <ffffffff810c5a31>
 => do_group_exit+0x44/0xac <ffffffff810c60a9>
 => __wake_up_parent+0x0/0x28 <ffffffff810c6125>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
       hackbench-1616  [007] d..3   628.512842: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-1616  [007] d..3   628.512845: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-1618  [001] d..3   628.512990: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-1618  [001] d..3   628.512992: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-1620  [002] d..3   628.512994: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-1623  [006] d..3   628.512997: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-1620  [002] d..3   628.512997: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-1623  [006] d..3   628.512999: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-1625  [007] d..3   628.513003: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-1625  [007] d..3   628.513006: <stack trace>
 => ptep_clear_flush+0x36/0x40 <ffffffff81196fbc>
 => do_wp_page+0x685/0x7c1 <ffffffff811877c2>
 => handle_mm_fault+0x9e9/0xc9c <ffffffff8118a32f>
 => __do_page_fault+0x3b6/0x504 <ffffffff81a03b0e>
 => do_page_fault+0xe/0x10 <ffffffff81a03c6a>
 => page_fault+0x28/0x30 <ffffffff81a00858>
       hackbench-21757 [017] d..2   628.513245: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
       hackbench-21757 [017] d..2   628.513247: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => unmap_region+0xdd/0xef <ffffffff8118d0ff>
 => do_munmap+0x250/0x2e3 <ffffffff8118ea85>
 => vm_munmap+0x42/0x5b <ffffffff8118eb5a>
 => SyS_munmap+0x23/0x29 <ffffffff8118eb96>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
            date-2059  [025] d..2   628.514066: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
            date-2059  [025] d..2   628.514070: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
         run-job-4175  [001] d..2   628.781525: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
         run-job-4175  [001] d..2   628.781527: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => unmap_region+0xdd/0xef <ffffffff8118d0ff>
 => do_munmap+0x250/0x2e3 <ffffffff8118ea85>
 => vm_munmap+0x42/0x5b <ffffffff8118eb5a>
 => SyS_munmap+0x23/0x29 <ffffffff8118eb96>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
           sleep-2068  [026] d..2   628.784172: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           sleep-2068  [026] d..2   628.784178: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
            date-2066  [029] d..2   628.784225: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
            date-2066  [029] d..2   628.784229: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
             cat-2071  [025] d..2   628.784987: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
             cat-2071  [025] d..2   628.784990: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
           sleep-2088  [025] d..2   629.021982: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
           sleep-2088  [025] d..2   629.021987: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
            wget-2113  [017] d..2   629.792738: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
            wget-2113  [017] d..2   629.792742: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>
              cp-2118  [000] d..2   630.035622: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
              cp-2118  [000] d..2   630.035627: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => unmap_region+0xdd/0xef <ffffffff8118d0ff>
 => do_munmap+0x250/0x2e3 <ffffffff8118ea85>
 => vm_munmap+0x42/0x5b <ffffffff8118eb5a>
 => SyS_munmap+0x23/0x29 <ffffffff8118eb96>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
            lsof-2130  [012] d..2   631.125170: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
            lsof-2130  [012] d..2   631.125174: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => unmap_region+0xdd/0xef <ffffffff8118d0ff>
 => do_munmap+0x250/0x2e3 <ffffffff8118ea85>
 => vm_munmap+0x42/0x5b <ffffffff8118eb5a>
 => SyS_munmap+0x23/0x29 <ffffffff8118eb96>
 => system_call_fastpath+0x16/0x1b <ffffffff81a07669>
    wd_keepalive-2236  [025] d..2   641.795155: native_flush_tlb_others: (native_flush_tlb_others+0x0/0x30 <ffffffff8106c861>)
    wd_keepalive-2236  [025] d..2   641.795165: <stack trace>
 => tlb_flush_mmu+0x47/0x75 <ffffffff81185e9a>
 => tlb_finish_mmu+0x14/0x39 <ffffffff81185edc>
 => exit_mmap+0x9b/0x12c <ffffffff8118ec37>
 => mmput+0x74/0x109 <ffffffff810c1222>
 => flush_old_exec+0x6fe/0x76b <ffffffff811c6027>
 => load_elf_binary+0x2b9/0x16c4 <ffffffff812064de>
 => search_binary_handler+0x70/0x168 <ffffffff811c53ed>
 => do_execve_common.isra.22+0x42d/0x645 <ffffffff811c690f>
 => do_execve+0x18/0x1a <ffffffff811c6b3f>
 => SyS_execve+0x3b/0x51 <ffffffff811c6d6a>
 => stub_execve+0x69/0xa0 <ffffffff81a07bb9>

--ibTvN161/egqYuK8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="config-3.13.0-rc3-00004-geabb1f8"

#
# Automatically generated file; DO NOT EDIT.
# Linux/x86_64 3.13.0-rc3 Kernel Configuration
#
CONFIG_64BIT=y
CONFIG_X86_64=y
CONFIG_X86=y
CONFIG_INSTRUCTION_DECODER=y
CONFIG_OUTPUT_FORMAT="elf64-x86-64"
CONFIG_ARCH_DEFCONFIG="arch/x86/configs/x86_64_defconfig"
CONFIG_LOCKDEP_SUPPORT=y
CONFIG_STACKTRACE_SUPPORT=y
CONFIG_HAVE_LATENCYTOP_SUPPORT=y
CONFIG_MMU=y
CONFIG_NEED_DMA_MAP_STATE=y
CONFIG_NEED_SG_DMA_LENGTH=y
CONFIG_GENERIC_ISA_DMA=y
CONFIG_GENERIC_BUG=y
CONFIG_GENERIC_BUG_RELATIVE_POINTERS=y
CONFIG_GENERIC_HWEIGHT=y
CONFIG_ARCH_MAY_HAVE_PC_FDC=y
CONFIG_RWSEM_XCHGADD_ALGORITHM=y
CONFIG_GENERIC_CALIBRATE_DELAY=y
CONFIG_ARCH_HAS_CPU_RELAX=y
CONFIG_ARCH_HAS_CACHE_LINE_SIZE=y
CONFIG_ARCH_HAS_CPU_AUTOPROBE=y
CONFIG_HAVE_SETUP_PER_CPU_AREA=y
CONFIG_NEED_PER_CPU_EMBED_FIRST_CHUNK=y
CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK=y
CONFIG_ARCH_HIBERNATION_POSSIBLE=y
CONFIG_ARCH_SUSPEND_POSSIBLE=y
CONFIG_ARCH_WANT_HUGE_PMD_SHARE=y
CONFIG_ARCH_WANT_GENERAL_HUGETLB=y
CONFIG_ZONE_DMA32=y
CONFIG_AUDIT_ARCH=y
CONFIG_ARCH_SUPPORTS_OPTIMIZED_INLINING=y
CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC=y
CONFIG_X86_64_SMP=y
CONFIG_X86_HT=y
CONFIG_ARCH_HWEIGHT_CFLAGS="-fcall-saved-rdi -fcall-saved-rsi -fcall-saved-rdx -fcall-saved-rcx -fcall-saved-r8 -fcall-saved-r9 -fcall-saved-r10 -fcall-saved-r11"
CONFIG_ARCH_SUPPORTS_UPROBES=y
CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"
CONFIG_IRQ_WORK=y
CONFIG_BUILDTIME_EXTABLE_SORT=y

#
# General setup
#
CONFIG_INIT_ENV_ARG_LIMIT=32
CONFIG_CROSS_COMPILE=""
# CONFIG_COMPILE_TEST is not set
CONFIG_LOCALVERSION=""
CONFIG_LOCALVERSION_AUTO=y
CONFIG_HAVE_KERNEL_GZIP=y
CONFIG_HAVE_KERNEL_BZIP2=y
CONFIG_HAVE_KERNEL_LZMA=y
CONFIG_HAVE_KERNEL_XZ=y
CONFIG_HAVE_KERNEL_LZO=y
CONFIG_HAVE_KERNEL_LZ4=y
CONFIG_KERNEL_GZIP=y
# CONFIG_KERNEL_BZIP2 is not set
# CONFIG_KERNEL_LZMA is not set
# CONFIG_KERNEL_XZ is not set
# CONFIG_KERNEL_LZO is not set
# CONFIG_KERNEL_LZ4 is not set
CONFIG_DEFAULT_HOSTNAME="(none)"
CONFIG_SWAP=y
CONFIG_SYSVIPC=y
CONFIG_SYSVIPC_SYSCTL=y
CONFIG_POSIX_MQUEUE=y
CONFIG_POSIX_MQUEUE_SYSCTL=y
# CONFIG_FHANDLE is not set
# CONFIG_AUDIT is not set

#
# IRQ subsystem
#
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_GENERIC_IRQ_SHOW=y
CONFIG_GENERIC_PENDING_IRQ=y
CONFIG_IRQ_DOMAIN=y
# CONFIG_IRQ_DOMAIN_DEBUG is not set
CONFIG_IRQ_FORCED_THREADING=y
CONFIG_SPARSE_IRQ=y
CONFIG_CLOCKSOURCE_WATCHDOG=y
CONFIG_ARCH_CLOCKSOURCE_DATA=y
CONFIG_GENERIC_TIME_VSYSCALL=y
CONFIG_GENERIC_CLOCKEVENTS=y
CONFIG_GENERIC_CLOCKEVENTS_BUILD=y
CONFIG_GENERIC_CLOCKEVENTS_BROADCAST=y
CONFIG_GENERIC_CLOCKEVENTS_MIN_ADJUST=y
CONFIG_GENERIC_CMOS_UPDATE=y

#
# Timers subsystem
#
CONFIG_TICK_ONESHOT=y
CONFIG_NO_HZ_COMMON=y
# CONFIG_HZ_PERIODIC is not set
CONFIG_NO_HZ_IDLE=y
# CONFIG_NO_HZ_FULL is not set
CONFIG_NO_HZ=y
CONFIG_HIGH_RES_TIMERS=y

#
# CPU/Task time and stats accounting
#
CONFIG_TICK_CPU_ACCOUNTING=y
# CONFIG_VIRT_CPU_ACCOUNTING_GEN is not set
# CONFIG_IRQ_TIME_ACCOUNTING is not set
CONFIG_BSD_PROCESS_ACCT=y
CONFIG_BSD_PROCESS_ACCT_V3=y
CONFIG_TASKSTATS=y
CONFIG_TASK_DELAY_ACCT=y
CONFIG_TASK_XACCT=y
CONFIG_TASK_IO_ACCOUNTING=y

#
# RCU Subsystem
#
CONFIG_TREE_RCU=y
# CONFIG_PREEMPT_RCU is not set
CONFIG_RCU_STALL_COMMON=y
# CONFIG_RCU_USER_QS is not set
CONFIG_RCU_FANOUT=64
CONFIG_RCU_FANOUT_LEAF=16
# CONFIG_RCU_FANOUT_EXACT is not set
CONFIG_RCU_FAST_NO_HZ=y
# CONFIG_TREE_RCU_TRACE is not set
# CONFIG_RCU_NOCB_CPU is not set
CONFIG_IKCONFIG=y
CONFIG_IKCONFIG_PROC=y
CONFIG_LOG_BUF_SHIFT=20
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
CONFIG_ARCH_SUPPORTS_NUMA_BALANCING=y
CONFIG_ARCH_WANTS_PROT_NUMA_PROT_NONE=y
CONFIG_ARCH_USES_NUMA_PROT_NONE=y
# CONFIG_NUMA_BALANCING_DEFAULT_ENABLED is not set
CONFIG_NUMA_BALANCING=y
CONFIG_CGROUPS=y
# CONFIG_CGROUP_DEBUG is not set
CONFIG_CGROUP_FREEZER=y
CONFIG_CGROUP_DEVICE=y
CONFIG_CPUSETS=y
CONFIG_PROC_PID_CPUSET=y
# CONFIG_CGROUP_CPUACCT is not set
CONFIG_RESOURCE_COUNTERS=y
CONFIG_MEMCG=y
CONFIG_MEMCG_SWAP=y
CONFIG_MEMCG_SWAP_ENABLED=y
CONFIG_MEMCG_KMEM=y
CONFIG_CGROUP_HUGETLB=y
CONFIG_CGROUP_PERF=y
CONFIG_CGROUP_SCHED=y
CONFIG_FAIR_GROUP_SCHED=y
# CONFIG_CFS_BANDWIDTH is not set
# CONFIG_RT_GROUP_SCHED is not set
CONFIG_BLK_CGROUP=y
# CONFIG_DEBUG_BLK_CGROUP is not set
CONFIG_CHECKPOINT_RESTORE=y
CONFIG_NAMESPACES=y
CONFIG_UTS_NS=y
CONFIG_IPC_NS=y
CONFIG_USER_NS=y
CONFIG_PID_NS=y
CONFIG_NET_NS=y
CONFIG_UIDGID_STRICT_TYPE_CHECKS=y
# CONFIG_SCHED_AUTOGROUP is not set
CONFIG_MM_OWNER=y
# CONFIG_SYSFS_DEPRECATED is not set
CONFIG_RELAY=y
CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE=""
CONFIG_RD_GZIP=y
CONFIG_RD_BZIP2=y
CONFIG_RD_LZMA=y
CONFIG_RD_XZ=y
CONFIG_RD_LZO=y
CONFIG_RD_LZ4=y
CONFIG_CC_OPTIMIZE_FOR_SIZE=y
CONFIG_SYSCTL=y
CONFIG_ANON_INODES=y
CONFIG_HAVE_UID16=y
CONFIG_SYSCTL_EXCEPTION_TRACE=y
CONFIG_HAVE_PCSPKR_PLATFORM=y
CONFIG_EXPERT=y
CONFIG_UID16=y
# CONFIG_SYSCTL_SYSCALL is not set
CONFIG_KALLSYMS=y
# CONFIG_KALLSYMS_ALL is not set
CONFIG_PRINTK=y
CONFIG_BUG=y
CONFIG_ELF_CORE=y
CONFIG_PCSPKR_PLATFORM=y
CONFIG_BASE_FULL=y
CONFIG_FUTEX=y
CONFIG_EPOLL=y
CONFIG_SIGNALFD=y
CONFIG_TIMERFD=y
CONFIG_EVENTFD=y
CONFIG_SHMEM=y
CONFIG_AIO=y
CONFIG_PCI_QUIRKS=y
# CONFIG_EMBEDDED is not set
CONFIG_HAVE_PERF_EVENTS=y

#
# Kernel Performance Events And Counters
#
CONFIG_PERF_EVENTS=y
# CONFIG_DEBUG_PERF_USE_VMALLOC is not set
CONFIG_VM_EVENT_COUNTERS=y
CONFIG_SLUB_DEBUG=y
# CONFIG_COMPAT_BRK is not set
# CONFIG_SLAB is not set
CONFIG_SLUB=y
# CONFIG_SLOB is not set
CONFIG_SLUB_CPU_PARTIAL=y
CONFIG_PROFILING=y
CONFIG_TRACEPOINTS=y
# CONFIG_OPROFILE is not set
CONFIG_HAVE_OPROFILE=y
CONFIG_OPROFILE_NMI_TIMER=y
CONFIG_KPROBES=y
# CONFIG_JUMP_LABEL is not set
CONFIG_OPTPROBES=y
CONFIG_KPROBES_ON_FTRACE=y
CONFIG_UPROBES=y
# CONFIG_HAVE_64BIT_ALIGNED_ACCESS is not set
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
CONFIG_ARCH_USE_BUILTIN_BSWAP=y
CONFIG_KRETPROBES=y
CONFIG_USER_RETURN_NOTIFIER=y
CONFIG_HAVE_IOREMAP_PROT=y
CONFIG_HAVE_KPROBES=y
CONFIG_HAVE_KRETPROBES=y
CONFIG_HAVE_OPTPROBES=y
CONFIG_HAVE_KPROBES_ON_FTRACE=y
CONFIG_HAVE_ARCH_TRACEHOOK=y
CONFIG_HAVE_DMA_ATTRS=y
CONFIG_GENERIC_SMP_IDLE_THREAD=y
CONFIG_HAVE_REGS_AND_STACK_ACCESS_API=y
CONFIG_HAVE_DMA_API_DEBUG=y
CONFIG_HAVE_HW_BREAKPOINT=y
CONFIG_HAVE_MIXED_BREAKPOINTS_REGS=y
CONFIG_HAVE_USER_RETURN_NOTIFIER=y
CONFIG_HAVE_PERF_EVENTS_NMI=y
CONFIG_HAVE_PERF_REGS=y
CONFIG_HAVE_PERF_USER_STACK_DUMP=y
CONFIG_HAVE_ARCH_JUMP_LABEL=y
CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG=y
CONFIG_HAVE_ALIGNED_STRUCT_PAGE=y
CONFIG_HAVE_CMPXCHG_LOCAL=y
CONFIG_HAVE_CMPXCHG_DOUBLE=y
CONFIG_ARCH_WANT_COMPAT_IPC_PARSE_VERSION=y
CONFIG_ARCH_WANT_OLD_COMPAT_IPC=y
CONFIG_HAVE_ARCH_SECCOMP_FILTER=y
CONFIG_SECCOMP_FILTER=y
CONFIG_HAVE_CONTEXT_TRACKING=y
CONFIG_HAVE_VIRT_CPU_ACCOUNTING_GEN=y
CONFIG_HAVE_IRQ_TIME_ACCOUNTING=y
CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE=y
CONFIG_HAVE_ARCH_SOFT_DIRTY=y
CONFIG_MODULES_USE_ELF_RELA=y
CONFIG_HAVE_IRQ_EXIT_ON_IRQ_STACK=y
CONFIG_OLD_SIGSUSPEND3=y
CONFIG_COMPAT_OLD_SIGACTION=y

#
# GCOV-based kernel profiling
#
# CONFIG_GCOV_KERNEL is not set
# CONFIG_HAVE_GENERIC_DMA_COHERENT is not set
CONFIG_SLABINFO=y
CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=0
# CONFIG_SYSTEM_TRUSTED_KEYRING is not set
CONFIG_MODULES=y
# CONFIG_MODULE_FORCE_LOAD is not set
CONFIG_MODULE_UNLOAD=y
# CONFIG_MODULE_FORCE_UNLOAD is not set
CONFIG_MODVERSIONS=y
CONFIG_MODULE_SRCVERSION_ALL=y
# CONFIG_MODULE_SIG is not set
CONFIG_STOP_MACHINE=y
CONFIG_BLOCK=y
CONFIG_BLK_DEV_BSG=y
CONFIG_BLK_DEV_BSGLIB=y
CONFIG_BLK_DEV_INTEGRITY=y
CONFIG_BLK_DEV_THROTTLING=y
# CONFIG_BLK_CMDLINE_PARSER is not set

#
# Partition Types
#
CONFIG_PARTITION_ADVANCED=y
# CONFIG_ACORN_PARTITION is not set
# CONFIG_AIX_PARTITION is not set
CONFIG_OSF_PARTITION=y
CONFIG_AMIGA_PARTITION=y
# CONFIG_ATARI_PARTITION is not set
CONFIG_MAC_PARTITION=y
CONFIG_MSDOS_PARTITION=y
CONFIG_BSD_DISKLABEL=y
CONFIG_MINIX_SUBPARTITION=y
CONFIG_SOLARIS_X86_PARTITION=y
CONFIG_UNIXWARE_DISKLABEL=y
# CONFIG_LDM_PARTITION is not set
CONFIG_SGI_PARTITION=y
# CONFIG_ULTRIX_PARTITION is not set
CONFIG_SUN_PARTITION=y
CONFIG_KARMA_PARTITION=y
CONFIG_EFI_PARTITION=y
# CONFIG_SYSV68_PARTITION is not set
# CONFIG_CMDLINE_PARTITION is not set
CONFIG_BLOCK_COMPAT=y

#
# IO Schedulers
#
CONFIG_IOSCHED_NOOP=y
CONFIG_IOSCHED_DEADLINE=y
CONFIG_IOSCHED_CFQ=y
CONFIG_CFQ_GROUP_IOSCHED=y
# CONFIG_DEFAULT_DEADLINE is not set
CONFIG_DEFAULT_CFQ=y
# CONFIG_DEFAULT_NOOP is not set
CONFIG_DEFAULT_IOSCHED="cfq"
CONFIG_PREEMPT_NOTIFIERS=y
CONFIG_PADATA=y
CONFIG_INLINE_SPIN_UNLOCK_IRQ=y
CONFIG_INLINE_READ_UNLOCK=y
CONFIG_INLINE_READ_UNLOCK_IRQ=y
CONFIG_INLINE_WRITE_UNLOCK=y
CONFIG_INLINE_WRITE_UNLOCK_IRQ=y
CONFIG_MUTEX_SPIN_ON_OWNER=y
CONFIG_FREEZER=y

#
# Processor type and features
#
CONFIG_ZONE_DMA=y
CONFIG_SMP=y
CONFIG_X86_MPPARSE=y
CONFIG_X86_EXTENDED_PLATFORM=y
# CONFIG_X86_VSMP is not set
# CONFIG_X86_INTEL_LPSS is not set
CONFIG_X86_SUPPORTS_MEMORY_FAILURE=y
# CONFIG_SCHED_OMIT_FRAME_POINTER is not set
CONFIG_HYPERVISOR_GUEST=y
CONFIG_PARAVIRT=y
# CONFIG_PARAVIRT_DEBUG is not set
# CONFIG_PARAVIRT_SPINLOCKS is not set
# CONFIG_XEN is not set
# CONFIG_XEN_PRIVILEGED_GUEST is not set
CONFIG_KVM_GUEST=y
# CONFIG_KVM_DEBUG_FS is not set
# CONFIG_PARAVIRT_TIME_ACCOUNTING is not set
CONFIG_PARAVIRT_CLOCK=y
CONFIG_NO_BOOTMEM=y
# CONFIG_MEMTEST is not set
# CONFIG_MK8 is not set
# CONFIG_MPSC is not set
# CONFIG_MCORE2 is not set
# CONFIG_MATOM is not set
CONFIG_GENERIC_CPU=y
CONFIG_X86_INTERNODE_CACHE_SHIFT=6
CONFIG_X86_L1_CACHE_SHIFT=6
CONFIG_X86_TSC=y
CONFIG_X86_CMPXCHG64=y
CONFIG_X86_CMOV=y
CONFIG_X86_MINIMUM_CPU_FAMILY=64
CONFIG_X86_DEBUGCTLMSR=y
# CONFIG_PROCESSOR_SELECT is not set
CONFIG_CPU_SUP_INTEL=y
CONFIG_CPU_SUP_AMD=y
CONFIG_CPU_SUP_CENTAUR=y
CONFIG_HPET_TIMER=y
CONFIG_HPET_EMULATE_RTC=y
CONFIG_DMI=y
CONFIG_GART_IOMMU=y
# CONFIG_CALGARY_IOMMU is not set
CONFIG_SWIOTLB=y
CONFIG_IOMMU_HELPER=y
# CONFIG_MAXSMP is not set
CONFIG_NR_CPUS=512
CONFIG_SCHED_SMT=y
CONFIG_SCHED_MC=y
# CONFIG_PREEMPT_NONE is not set
CONFIG_PREEMPT_VOLUNTARY=y
# CONFIG_PREEMPT is not set
CONFIG_PREEMPT_COUNT=y
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS=y
CONFIG_X86_MCE=y
CONFIG_X86_MCE_INTEL=y
# CONFIG_X86_MCE_AMD is not set
CONFIG_X86_MCE_THRESHOLD=y
CONFIG_X86_MCE_INJECT=m
CONFIG_X86_THERMAL_VECTOR=y
CONFIG_I8K=m
CONFIG_MICROCODE=m
CONFIG_MICROCODE_INTEL=y
CONFIG_MICROCODE_AMD=y
CONFIG_MICROCODE_OLD_INTERFACE=y
CONFIG_MICROCODE_INTEL_LIB=y
# CONFIG_MICROCODE_INTEL_EARLY is not set
# CONFIG_MICROCODE_AMD_EARLY is not set
CONFIG_X86_MSR=m
CONFIG_X86_CPUID=m
CONFIG_ARCH_PHYS_ADDR_T_64BIT=y
CONFIG_ARCH_DMA_ADDR_T_64BIT=y
CONFIG_DIRECT_GBPAGES=y
CONFIG_NUMA=y
CONFIG_AMD_NUMA=y
CONFIG_X86_64_ACPI_NUMA=y
CONFIG_NODES_SPAN_OTHER_NODES=y
# CONFIG_NUMA_EMU is not set
CONFIG_NODES_SHIFT=6
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SPARSEMEM_DEFAULT=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
CONFIG_ARCH_MEMORY_PROBE=y
CONFIG_ARCH_PROC_KCORE_TEXT=y
CONFIG_ILLEGAL_POINTER_VALUE=0xdead000000000000
CONFIG_SELECT_MEMORY_MODEL=y
CONFIG_SPARSEMEM_MANUAL=y
CONFIG_SPARSEMEM=y
CONFIG_NEED_MULTIPLE_NODES=y
CONFIG_HAVE_MEMORY_PRESENT=y
CONFIG_SPARSEMEM_EXTREME=y
CONFIG_SPARSEMEM_VMEMMAP_ENABLE=y
CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER=y
CONFIG_SPARSEMEM_VMEMMAP=y
CONFIG_HAVE_MEMBLOCK=y
CONFIG_HAVE_MEMBLOCK_NODE_MAP=y
CONFIG_ARCH_DISCARD_MEMBLOCK=y
CONFIG_MEMORY_ISOLATION=y
# CONFIG_MOVABLE_NODE is not set
CONFIG_HAVE_BOOTMEM_INFO_NODE=y
CONFIG_MEMORY_HOTPLUG=y
CONFIG_MEMORY_HOTPLUG_SPARSE=y
CONFIG_MEMORY_HOTREMOVE=y
CONFIG_PAGEFLAGS_EXTENDED=y
CONFIG_SPLIT_PTLOCK_CPUS=4
CONFIG_ARCH_ENABLE_SPLIT_PMD_PTLOCK=y
CONFIG_BALLOON_COMPACTION=y
CONFIG_COMPACTION=y
CONFIG_MIGRATION=y
CONFIG_PHYS_ADDR_T_64BIT=y
CONFIG_ZONE_DMA_FLAG=1
CONFIG_BOUNCE=y
CONFIG_NEED_BOUNCE_POOL=y
CONFIG_VIRT_TO_BUS=y
CONFIG_MMU_NOTIFIER=y
CONFIG_KSM=y
CONFIG_DEFAULT_MMAP_MIN_ADDR=65536
CONFIG_ARCH_SUPPORTS_MEMORY_FAILURE=y
CONFIG_MEMORY_FAILURE=y
CONFIG_HWPOISON_INJECT=m
CONFIG_TRANSPARENT_HUGEPAGE=y
# CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS is not set
CONFIG_TRANSPARENT_HUGEPAGE_MADVISE=y
CONFIG_CROSS_MEMORY_ATTACH=y
# CONFIG_CLEANCACHE is not set
# CONFIG_FRONTSWAP is not set
# CONFIG_CMA is not set
# CONFIG_ZBUD is not set
# CONFIG_MEM_SOFT_DIRTY is not set
CONFIG_X86_CHECK_BIOS_CORRUPTION=y
CONFIG_X86_BOOTPARAM_MEMORY_CORRUPTION_CHECK=y
CONFIG_X86_RESERVE_LOW=64
CONFIG_MTRR=y
CONFIG_MTRR_SANITIZER=y
CONFIG_MTRR_SANITIZER_ENABLE_DEFAULT=0
CONFIG_MTRR_SANITIZER_SPARE_REG_NR_DEFAULT=1
CONFIG_X86_PAT=y
CONFIG_ARCH_USES_PG_UNCACHED=y
CONFIG_ARCH_RANDOM=y
CONFIG_X86_SMAP=y
CONFIG_EFI=y
CONFIG_EFI_STUB=y
CONFIG_SECCOMP=y
CONFIG_CC_STACKPROTECTOR=y
# CONFIG_HZ_100 is not set
CONFIG_HZ_250=y
# CONFIG_HZ_300 is not set
# CONFIG_HZ_1000 is not set
CONFIG_HZ=250
CONFIG_SCHED_HRTICK=y
CONFIG_KEXEC=y
CONFIG_CRASH_DUMP=y
CONFIG_KEXEC_JUMP=y
CONFIG_PHYSICAL_START=0x1000000
CONFIG_RELOCATABLE=y
CONFIG_PHYSICAL_ALIGN=0x1000000
CONFIG_HOTPLUG_CPU=y
# CONFIG_BOOTPARAM_HOTPLUG_CPU0 is not set
# CONFIG_DEBUG_HOTPLUG_CPU0 is not set
CONFIG_COMPAT_VDSO=y
# CONFIG_CMDLINE_BOOL is not set
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y
CONFIG_ARCH_ENABLE_MEMORY_HOTREMOVE=y
CONFIG_USE_PERCPU_NUMA_NODE_ID=y

#
# Power management and ACPI options
#
CONFIG_ARCH_HIBERNATION_HEADER=y
CONFIG_SUSPEND=y
CONFIG_SUSPEND_FREEZER=y
CONFIG_HIBERNATE_CALLBACKS=y
CONFIG_HIBERNATION=y
CONFIG_PM_STD_PARTITION=""
CONFIG_PM_SLEEP=y
CONFIG_PM_SLEEP_SMP=y
CONFIG_PM_AUTOSLEEP=y
# CONFIG_PM_WAKELOCKS is not set
CONFIG_PM_RUNTIME=y
CONFIG_PM=y
CONFIG_PM_DEBUG=y
CONFIG_PM_ADVANCED_DEBUG=y
# CONFIG_PM_TEST_SUSPEND is not set
CONFIG_PM_SLEEP_DEBUG=y
# CONFIG_DPM_WATCHDOG is not set
# CONFIG_PM_TRACE_RTC is not set
# CONFIG_WQ_POWER_EFFICIENT_DEFAULT is not set
CONFIG_ACPI=y
CONFIG_ACPI_SLEEP=y
# CONFIG_ACPI_PROCFS is not set
# CONFIG_ACPI_EC_DEBUGFS is not set
CONFIG_ACPI_AC=y
CONFIG_ACPI_BATTERY=y
CONFIG_ACPI_BUTTON=y
CONFIG_ACPI_FAN=y
CONFIG_ACPI_DOCK=y
CONFIG_ACPI_PROCESSOR=m
# CONFIG_ACPI_IPMI is not set
CONFIG_ACPI_HOTPLUG_CPU=y
CONFIG_ACPI_PROCESSOR_AGGREGATOR=m
CONFIG_ACPI_THERMAL=m
CONFIG_ACPI_NUMA=y
# CONFIG_ACPI_CUSTOM_DSDT is not set
# CONFIG_ACPI_INITRD_TABLE_OVERRIDE is not set
# CONFIG_ACPI_DEBUG is not set
CONFIG_ACPI_PCI_SLOT=y
CONFIG_X86_PM_TIMER=y
CONFIG_ACPI_CONTAINER=y
# CONFIG_ACPI_HOTPLUG_MEMORY is not set
# CONFIG_ACPI_SBS is not set
CONFIG_ACPI_HED=y
# CONFIG_ACPI_CUSTOM_METHOD is not set
# CONFIG_ACPI_BGRT is not set
CONFIG_ACPI_APEI=y
CONFIG_ACPI_APEI_GHES=y
CONFIG_ACPI_APEI_PCIEAER=y
CONFIG_ACPI_APEI_MEMORY_FAILURE=y
CONFIG_ACPI_APEI_EINJ=y
# CONFIG_ACPI_APEI_ERST_DEBUG is not set
# CONFIG_ACPI_EXTLOG is not set
# CONFIG_SFI is not set

#
# CPU Frequency scaling
#
CONFIG_CPU_FREQ=y
CONFIG_CPU_FREQ_GOV_COMMON=y
CONFIG_CPU_FREQ_STAT=y
CONFIG_CPU_FREQ_STAT_DETAILS=y
# CONFIG_CPU_FREQ_DEFAULT_GOV_PERFORMANCE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_POWERSAVE is not set
CONFIG_CPU_FREQ_DEFAULT_GOV_USERSPACE=y
# CONFIG_CPU_FREQ_DEFAULT_GOV_ONDEMAND is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_CONSERVATIVE is not set
CONFIG_CPU_FREQ_GOV_PERFORMANCE=y
CONFIG_CPU_FREQ_GOV_POWERSAVE=y
CONFIG_CPU_FREQ_GOV_USERSPACE=y
CONFIG_CPU_FREQ_GOV_ONDEMAND=y
CONFIG_CPU_FREQ_GOV_CONSERVATIVE=y

#
# x86 CPU frequency scaling drivers
#
CONFIG_X86_INTEL_PSTATE=y
CONFIG_X86_PCC_CPUFREQ=m
CONFIG_X86_ACPI_CPUFREQ=m
CONFIG_X86_ACPI_CPUFREQ_CPB=y
CONFIG_X86_POWERNOW_K8=m
# CONFIG_X86_AMD_FREQ_SENSITIVITY is not set
CONFIG_X86_SPEEDSTEP_CENTRINO=m
# CONFIG_X86_P4_CLOCKMOD is not set

#
# shared options
#
# CONFIG_X86_SPEEDSTEP_LIB is not set

#
# CPU Idle
#
CONFIG_CPU_IDLE=y
# CONFIG_CPU_IDLE_MULTIPLE_DRIVERS is not set
CONFIG_CPU_IDLE_GOV_LADDER=y
CONFIG_CPU_IDLE_GOV_MENU=y
# CONFIG_ARCH_NEEDS_CPU_IDLE_COUPLED is not set
CONFIG_INTEL_IDLE=y

#
# Memory power savings
#
# CONFIG_I7300_IDLE is not set

#
# Bus options (PCI etc.)
#
CONFIG_PCI=y
CONFIG_PCI_DIRECT=y
CONFIG_PCI_MMCONFIG=y
CONFIG_PCI_DOMAINS=y
# CONFIG_PCI_CNB20LE_QUIRK is not set
CONFIG_PCIEPORTBUS=y
CONFIG_HOTPLUG_PCI_PCIE=y
CONFIG_PCIEAER=y
# CONFIG_PCIE_ECRC is not set
# CONFIG_PCIEAER_INJECT is not set
CONFIG_PCIEASPM=y
# CONFIG_PCIEASPM_DEBUG is not set
CONFIG_PCIEASPM_DEFAULT=y
# CONFIG_PCIEASPM_POWERSAVE is not set
# CONFIG_PCIEASPM_PERFORMANCE is not set
CONFIG_PCIE_PME=y
CONFIG_PCI_MSI=y
# CONFIG_PCI_DEBUG is not set
CONFIG_PCI_REALLOC_ENABLE_AUTO=y
CONFIG_PCI_STUB=m
CONFIG_HT_IRQ=y
CONFIG_PCI_ATS=y
CONFIG_PCI_IOV=y
CONFIG_PCI_PRI=y
CONFIG_PCI_PASID=y
CONFIG_PCI_IOAPIC=y
CONFIG_PCI_LABEL=y

#
# PCI host controller drivers
#
CONFIG_ISA_DMA_API=y
CONFIG_AMD_NB=y
CONFIG_PCCARD=y
CONFIG_PCMCIA=y
CONFIG_PCMCIA_LOAD_CIS=y
CONFIG_CARDBUS=y

#
# PC-card bridges
#
CONFIG_YENTA=y
CONFIG_YENTA_O2=y
CONFIG_YENTA_RICOH=y
CONFIG_YENTA_TI=y
CONFIG_YENTA_ENE_TUNE=y
CONFIG_YENTA_TOSHIBA=y
# CONFIG_PD6729 is not set
# CONFIG_I82092 is not set
CONFIG_PCCARD_NONSTATIC=y
CONFIG_HOTPLUG_PCI=y
CONFIG_HOTPLUG_PCI_ACPI=y
# CONFIG_HOTPLUG_PCI_ACPI_IBM is not set
# CONFIG_HOTPLUG_PCI_CPCI is not set
# CONFIG_HOTPLUG_PCI_SHPC is not set
# CONFIG_RAPIDIO is not set
# CONFIG_X86_SYSFB is not set

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=y
CONFIG_COMPAT_BINFMT_ELF=y
CONFIG_ARCH_BINFMT_ELF_RANDOMIZE_PIE=y
# CONFIG_CORE_DUMP_DEFAULT_ELF_HEADERS is not set
CONFIG_BINFMT_SCRIPT=y
# CONFIG_HAVE_AOUT is not set
CONFIG_BINFMT_MISC=y
CONFIG_COREDUMP=y
CONFIG_IA32_EMULATION=y
CONFIG_IA32_AOUT=y
# CONFIG_X86_X32 is not set
CONFIG_COMPAT=y
CONFIG_COMPAT_FOR_U64_ALIGNMENT=y
CONFIG_SYSVIPC_COMPAT=y
CONFIG_KEYS_COMPAT=y
CONFIG_X86_DEV_DMA_OPS=y
CONFIG_NET=y

#
# Networking options
#
CONFIG_PACKET=y
CONFIG_PACKET_DIAG=m
CONFIG_UNIX=y
CONFIG_UNIX_DIAG=m
CONFIG_XFRM=y
CONFIG_XFRM_ALGO=y
CONFIG_XFRM_USER=y
# CONFIG_XFRM_SUB_POLICY is not set
# CONFIG_XFRM_MIGRATE is not set
# CONFIG_XFRM_STATISTICS is not set
# CONFIG_NET_KEY is not set
CONFIG_INET=y
CONFIG_IP_MULTICAST=y
CONFIG_IP_ADVANCED_ROUTER=y
# CONFIG_IP_FIB_TRIE_STATS is not set
CONFIG_IP_MULTIPLE_TABLES=y
CONFIG_IP_ROUTE_MULTIPATH=y
CONFIG_IP_ROUTE_VERBOSE=y
CONFIG_IP_PNP=y
CONFIG_IP_PNP_DHCP=y
CONFIG_IP_PNP_BOOTP=y
CONFIG_IP_PNP_RARP=y
# CONFIG_NET_IPIP is not set
# CONFIG_NET_IPGRE_DEMUX is not set
CONFIG_NET_IP_TUNNEL=y
CONFIG_IP_MROUTE=y
# CONFIG_IP_MROUTE_MULTIPLE_TABLES is not set
CONFIG_IP_PIMSM_V1=y
CONFIG_IP_PIMSM_V2=y
CONFIG_SYN_COOKIES=y
# CONFIG_INET_AH is not set
# CONFIG_INET_ESP is not set
# CONFIG_INET_IPCOMP is not set
# CONFIG_INET_XFRM_TUNNEL is not set
CONFIG_INET_TUNNEL=y
# CONFIG_INET_XFRM_MODE_TRANSPORT is not set
# CONFIG_INET_XFRM_MODE_TUNNEL is not set
CONFIG_INET_XFRM_MODE_BEET=y
# CONFIG_INET_LRO is not set
# CONFIG_INET_DIAG is not set
CONFIG_TCP_CONG_ADVANCED=y
CONFIG_TCP_CONG_BIC=y
# CONFIG_TCP_CONG_CUBIC is not set
# CONFIG_TCP_CONG_WESTWOOD is not set
# CONFIG_TCP_CONG_HTCP is not set
# CONFIG_TCP_CONG_HSTCP is not set
# CONFIG_TCP_CONG_HYBLA is not set
# CONFIG_TCP_CONG_VEGAS is not set
# CONFIG_TCP_CONG_SCALABLE is not set
# CONFIG_TCP_CONG_LP is not set
# CONFIG_TCP_CONG_VENO is not set
# CONFIG_TCP_CONG_YEAH is not set
# CONFIG_TCP_CONG_ILLINOIS is not set
CONFIG_DEFAULT_BIC=y
# CONFIG_DEFAULT_RENO is not set
CONFIG_DEFAULT_TCP_CONG="bic"
# CONFIG_TCP_MD5SIG is not set
CONFIG_IPV6=y
# CONFIG_IPV6_ROUTER_PREF is not set
# CONFIG_IPV6_OPTIMISTIC_DAD is not set
# CONFIG_INET6_AH is not set
# CONFIG_INET6_ESP is not set
# CONFIG_INET6_IPCOMP is not set
# CONFIG_IPV6_MIP6 is not set
# CONFIG_INET6_XFRM_TUNNEL is not set
# CONFIG_INET6_TUNNEL is not set
CONFIG_INET6_XFRM_MODE_TRANSPORT=y
CONFIG_INET6_XFRM_MODE_TUNNEL=y
CONFIG_INET6_XFRM_MODE_BEET=y
# CONFIG_INET6_XFRM_MODE_ROUTEOPTIMIZATION is not set
# CONFIG_IPV6_VTI is not set
CONFIG_IPV6_SIT=y
# CONFIG_IPV6_SIT_6RD is not set
CONFIG_IPV6_NDISC_NODETYPE=y
# CONFIG_IPV6_TUNNEL is not set
# CONFIG_IPV6_GRE is not set
# CONFIG_IPV6_MULTIPLE_TABLES is not set
# CONFIG_IPV6_MROUTE is not set
CONFIG_NETWORK_SECMARK=y
# CONFIG_NETWORK_PHY_TIMESTAMPING is not set
# CONFIG_NETFILTER is not set
# CONFIG_IP_DCCP is not set
CONFIG_IP_SCTP=y
# CONFIG_NET_SCTPPROBE is not set
# CONFIG_SCTP_DBG_OBJCNT is not set
CONFIG_SCTP_DEFAULT_COOKIE_HMAC_MD5=y
# CONFIG_SCTP_DEFAULT_COOKIE_HMAC_SHA1 is not set
# CONFIG_SCTP_DEFAULT_COOKIE_HMAC_NONE is not set
CONFIG_SCTP_COOKIE_HMAC_MD5=y
# CONFIG_SCTP_COOKIE_HMAC_SHA1 is not set
# CONFIG_RDS is not set
# CONFIG_TIPC is not set
# CONFIG_ATM is not set
# CONFIG_L2TP is not set
# CONFIG_BRIDGE is not set
CONFIG_HAVE_NET_DSA=y
CONFIG_VLAN_8021Q=y
# CONFIG_VLAN_8021Q_GVRP is not set
# CONFIG_VLAN_8021Q_MVRP is not set
# CONFIG_DECNET is not set
# CONFIG_LLC2 is not set
# CONFIG_IPX is not set
# CONFIG_ATALK is not set
# CONFIG_X25 is not set
# CONFIG_LAPB is not set
# CONFIG_PHONET is not set
# CONFIG_IEEE802154 is not set
# CONFIG_NET_SCHED is not set
# CONFIG_DCB is not set
CONFIG_DNS_RESOLVER=y
# CONFIG_BATMAN_ADV is not set
# CONFIG_OPENVSWITCH is not set
# CONFIG_VSOCKETS is not set
# CONFIG_NETLINK_MMAP is not set
# CONFIG_NETLINK_DIAG is not set
# CONFIG_NET_MPLS_GSO is not set
# CONFIG_HSR is not set
CONFIG_RPS=y
CONFIG_RFS_ACCEL=y
CONFIG_XPS=y
# CONFIG_NETPRIO_CGROUP is not set
CONFIG_NET_RX_BUSY_POLL=y
CONFIG_BQL=y
# CONFIG_BPF_JIT is not set
CONFIG_NET_FLOW_LIMIT=y

#
# Network testing
#
# CONFIG_NET_PKTGEN is not set
# CONFIG_NET_TCPPROBE is not set
# CONFIG_NET_DROP_MONITOR is not set
# CONFIG_HAMRADIO is not set
# CONFIG_CAN is not set
# CONFIG_IRDA is not set
# CONFIG_BT is not set
# CONFIG_AF_RXRPC is not set
CONFIG_FIB_RULES=y
CONFIG_WIRELESS=y
# CONFIG_CFG80211 is not set
# CONFIG_LIB80211 is not set

#
# CFG80211 needs to be enabled for MAC80211
#
# CONFIG_WIMAX is not set
# CONFIG_RFKILL is not set
# CONFIG_NET_9P is not set
# CONFIG_CAIF is not set
# CONFIG_CEPH_LIB is not set
# CONFIG_NFC is not set
CONFIG_HAVE_BPF_JIT=y

#
# Device Drivers
#

#
# Generic Driver Options
#
CONFIG_UEVENT_HELPER_PATH="/sbin/hotplug"
CONFIG_DEVTMPFS=y
# CONFIG_DEVTMPFS_MOUNT is not set
CONFIG_STANDALONE=y
CONFIG_PREVENT_FIRMWARE_BUILD=y
CONFIG_FW_LOADER=y
CONFIG_FIRMWARE_IN_KERNEL=y
CONFIG_EXTRA_FIRMWARE=""
CONFIG_FW_LOADER_USER_HELPER=y
# CONFIG_DEBUG_DRIVER is not set
# CONFIG_DEBUG_DEVRES is not set
# CONFIG_SYS_HYPERVISOR is not set
# CONFIG_GENERIC_CPU_DEVICES is not set
# CONFIG_DMA_SHARED_BUFFER is not set

#
# Bus devices
#
CONFIG_CONNECTOR=y
CONFIG_PROC_EVENTS=y
# CONFIG_MTD is not set
# CONFIG_PARPORT is not set
CONFIG_ARCH_MIGHT_HAVE_PC_PARPORT=y
CONFIG_PNP=y
CONFIG_PNP_DEBUG_MESSAGES=y

#
# Protocols
#
CONFIG_PNPACPI=y
CONFIG_BLK_DEV=y
# CONFIG_BLK_DEV_NULL_BLK is not set
# CONFIG_BLK_DEV_FD is not set
# CONFIG_BLK_DEV_PCIESSD_MTIP32XX is not set
# CONFIG_BLK_CPQ_CISS_DA is not set
# CONFIG_BLK_DEV_DAC960 is not set
# CONFIG_BLK_DEV_UMEM is not set
# CONFIG_BLK_DEV_COW_COMMON is not set
CONFIG_BLK_DEV_LOOP=y
CONFIG_BLK_DEV_LOOP_MIN_COUNT=8
# CONFIG_BLK_DEV_CRYPTOLOOP is not set
# CONFIG_BLK_DEV_DRBD is not set
# CONFIG_BLK_DEV_NBD is not set
# CONFIG_BLK_DEV_NVME is not set
# CONFIG_BLK_DEV_SKD is not set
# CONFIG_BLK_DEV_SX8 is not set
CONFIG_BLK_DEV_RAM=y
CONFIG_BLK_DEV_RAM_COUNT=16
CONFIG_BLK_DEV_RAM_SIZE=16384
# CONFIG_BLK_DEV_XIP is not set
# CONFIG_CDROM_PKTCDVD is not set
# CONFIG_ATA_OVER_ETH is not set
CONFIG_VIRTIO_BLK=y
# CONFIG_BLK_DEV_HD is not set
# CONFIG_BLK_DEV_RBD is not set
# CONFIG_BLK_DEV_RSXX is not set

#
# Misc devices
#
# CONFIG_SENSORS_LIS3LV02D is not set
# CONFIG_AD525X_DPOT is not set
# CONFIG_DUMMY_IRQ is not set
# CONFIG_IBM_ASM is not set
# CONFIG_PHANTOM is not set
# CONFIG_SGI_IOC4 is not set
# CONFIG_TIFM_CORE is not set
# CONFIG_ICS932S401 is not set
# CONFIG_ATMEL_SSC is not set
# CONFIG_ENCLOSURE_SERVICES is not set
# CONFIG_HP_ILO is not set
# CONFIG_APDS9802ALS is not set
# CONFIG_ISL29003 is not set
# CONFIG_ISL29020 is not set
# CONFIG_SENSORS_TSL2550 is not set
# CONFIG_SENSORS_BH1780 is not set
# CONFIG_SENSORS_BH1770 is not set
# CONFIG_SENSORS_APDS990X is not set
# CONFIG_HMC6352 is not set
# CONFIG_DS1682 is not set
# CONFIG_VMWARE_BALLOON is not set
# CONFIG_BMP085_I2C is not set
# CONFIG_PCH_PHUB is not set
# CONFIG_USB_SWITCH_FSA9480 is not set
# CONFIG_SRAM is not set
# CONFIG_C2PORT is not set

#
# EEPROM support
#
# CONFIG_EEPROM_AT24 is not set
# CONFIG_EEPROM_LEGACY is not set
# CONFIG_EEPROM_MAX6875 is not set
# CONFIG_EEPROM_93CX6 is not set
# CONFIG_CB710_CORE is not set

#
# Texas Instruments shared transport line discipline
#
# CONFIG_SENSORS_LIS3_I2C is not set

#
# Altera FPGA firmware download module
#
# CONFIG_ALTERA_STAPL is not set
# CONFIG_INTEL_MEI is not set
# CONFIG_INTEL_MEI_ME is not set
# CONFIG_VMWARE_VMCI is not set

#
# Intel MIC Host Driver
#
# CONFIG_INTEL_MIC_HOST is not set

#
# Intel MIC Card Driver
#
# CONFIG_INTEL_MIC_CARD is not set
CONFIG_HAVE_IDE=y
# CONFIG_IDE is not set

#
# SCSI device support
#
CONFIG_SCSI_MOD=y
CONFIG_RAID_ATTRS=y
CONFIG_SCSI=y
CONFIG_SCSI_DMA=y
# CONFIG_SCSI_TGT is not set
CONFIG_SCSI_NETLINK=y
CONFIG_SCSI_PROC_FS=y

#
# SCSI support type (disk, tape, CD-ROM)
#
CONFIG_BLK_DEV_SD=y
# CONFIG_CHR_DEV_ST is not set
# CONFIG_CHR_DEV_OSST is not set
# CONFIG_BLK_DEV_SR is not set
CONFIG_CHR_DEV_SG=y
# CONFIG_CHR_DEV_SCH is not set
CONFIG_SCSI_MULTI_LUN=y
CONFIG_SCSI_CONSTANTS=y
CONFIG_SCSI_LOGGING=y
CONFIG_SCSI_SCAN_ASYNC=y

#
# SCSI Transports
#
CONFIG_SCSI_SPI_ATTRS=y
CONFIG_SCSI_FC_ATTRS=y
CONFIG_SCSI_ISCSI_ATTRS=y
CONFIG_SCSI_SAS_ATTRS=y
CONFIG_SCSI_SAS_LIBSAS=y
# CONFIG_SCSI_SAS_ATA is not set
CONFIG_SCSI_SAS_HOST_SMP=y
# CONFIG_SCSI_SRP_ATTRS is not set
CONFIG_SCSI_LOWLEVEL=y
# CONFIG_ISCSI_TCP is not set
# CONFIG_ISCSI_BOOT_SYSFS is not set
# CONFIG_SCSI_CXGB3_ISCSI is not set
# CONFIG_SCSI_CXGB4_ISCSI is not set
# CONFIG_SCSI_BNX2_ISCSI is not set
# CONFIG_SCSI_BNX2X_FCOE is not set
# CONFIG_BE2ISCSI is not set
# CONFIG_BLK_DEV_3W_XXXX_RAID is not set
# CONFIG_SCSI_HPSA is not set
# CONFIG_SCSI_3W_9XXX is not set
# CONFIG_SCSI_3W_SAS is not set
CONFIG_SCSI_ACARD=y
CONFIG_SCSI_AACRAID=y
CONFIG_SCSI_AIC7XXX=y
CONFIG_AIC7XXX_CMDS_PER_DEVICE=4
CONFIG_AIC7XXX_RESET_DELAY_MS=15000
CONFIG_AIC7XXX_DEBUG_ENABLE=y
CONFIG_AIC7XXX_DEBUG_MASK=0
# CONFIG_AIC7XXX_REG_PRETTY_PRINT is not set
CONFIG_SCSI_AIC7XXX_OLD=y
CONFIG_SCSI_AIC79XX=y
CONFIG_AIC79XX_CMDS_PER_DEVICE=4
CONFIG_AIC79XX_RESET_DELAY_MS=15000
CONFIG_AIC79XX_DEBUG_ENABLE=y
CONFIG_AIC79XX_DEBUG_MASK=0
# CONFIG_AIC79XX_REG_PRETTY_PRINT is not set
CONFIG_SCSI_AIC94XX=y
# CONFIG_AIC94XX_DEBUG is not set
# CONFIG_SCSI_MVSAS is not set
# CONFIG_SCSI_MVUMI is not set
# CONFIG_SCSI_DPT_I2O is not set
# CONFIG_SCSI_ADVANSYS is not set
# CONFIG_SCSI_ARCMSR is not set
# CONFIG_SCSI_ESAS2R is not set
CONFIG_MEGARAID_NEWGEN=y
CONFIG_MEGARAID_MM=y
CONFIG_MEGARAID_MAILBOX=y
CONFIG_MEGARAID_LEGACY=y
CONFIG_MEGARAID_SAS=y
CONFIG_SCSI_MPT2SAS=m
CONFIG_SCSI_MPT2SAS_MAX_SGE=128
# CONFIG_SCSI_MPT2SAS_LOGGING is not set
CONFIG_SCSI_MPT3SAS=m
CONFIG_SCSI_MPT3SAS_MAX_SGE=128
# CONFIG_SCSI_MPT3SAS_LOGGING is not set
# CONFIG_SCSI_UFSHCD is not set
CONFIG_SCSI_HPTIOP=y
CONFIG_SCSI_BUSLOGIC=y
# CONFIG_SCSI_FLASHPOINT is not set
# CONFIG_VMWARE_PVSCSI is not set
# CONFIG_LIBFC is not set
# CONFIG_LIBFCOE is not set
# CONFIG_FCOE is not set
# CONFIG_FCOE_FNIC is not set
# CONFIG_SCSI_DMX3191D is not set
# CONFIG_SCSI_EATA is not set
# CONFIG_SCSI_FUTURE_DOMAIN is not set
CONFIG_SCSI_GDTH=y
CONFIG_SCSI_ISCI=m
# CONFIG_SCSI_IPS is not set
# CONFIG_SCSI_INITIO is not set
# CONFIG_SCSI_INIA100 is not set
# CONFIG_SCSI_STEX is not set
# CONFIG_SCSI_SYM53C8XX_2 is not set
# CONFIG_SCSI_IPR is not set
CONFIG_SCSI_QLOGIC_1280=y
CONFIG_SCSI_QLA_FC=y
# CONFIG_SCSI_QLA_ISCSI is not set
# CONFIG_SCSI_LPFC is not set
# CONFIG_SCSI_DC395x is not set
# CONFIG_SCSI_DC390T is not set
# CONFIG_SCSI_DEBUG is not set
# CONFIG_SCSI_PMCRAID is not set
# CONFIG_SCSI_PM8001 is not set
# CONFIG_SCSI_SRP is not set
# CONFIG_SCSI_BFA_FC is not set
CONFIG_SCSI_VIRTIO=y
# CONFIG_SCSI_CHELSIO_FCOE is not set
# CONFIG_SCSI_LOWLEVEL_PCMCIA is not set
# CONFIG_SCSI_DH is not set
# CONFIG_SCSI_OSD_INITIATOR is not set
CONFIG_ATA=y
# CONFIG_ATA_NONSTANDARD is not set
CONFIG_ATA_VERBOSE_ERROR=y
CONFIG_ATA_ACPI=y
# CONFIG_SATA_ZPODD is not set
CONFIG_SATA_PMP=y

#
# Controllers with non-SFF native interface
#
CONFIG_SATA_AHCI=y
# CONFIG_SATA_AHCI_PLATFORM is not set
# CONFIG_SATA_INIC162X is not set
# CONFIG_SATA_ACARD_AHCI is not set
# CONFIG_SATA_SIL24 is not set
CONFIG_ATA_SFF=y

#
# SFF controllers with custom DMA interface
#
# CONFIG_PDC_ADMA is not set
# CONFIG_SATA_QSTOR is not set
# CONFIG_SATA_SX4 is not set
CONFIG_ATA_BMDMA=y

#
# SATA SFF controllers with BMDMA
#
CONFIG_ATA_PIIX=y
# CONFIG_SATA_HIGHBANK is not set
# CONFIG_SATA_MV is not set
# CONFIG_SATA_NV is not set
# CONFIG_SATA_PROMISE is not set
# CONFIG_SATA_RCAR is not set
# CONFIG_SATA_SIL is not set
# CONFIG_SATA_SIS is not set
# CONFIG_SATA_SVW is not set
# CONFIG_SATA_ULI is not set
# CONFIG_SATA_VIA is not set
# CONFIG_SATA_VITESSE is not set

#
# PATA SFF controllers with BMDMA
#
# CONFIG_PATA_ALI is not set
# CONFIG_PATA_AMD is not set
# CONFIG_PATA_ARTOP is not set
# CONFIG_PATA_ATIIXP is not set
# CONFIG_PATA_ATP867X is not set
# CONFIG_PATA_CMD64X is not set
# CONFIG_PATA_CS5520 is not set
# CONFIG_PATA_CS5530 is not set
# CONFIG_PATA_CS5536 is not set
# CONFIG_PATA_CYPRESS is not set
# CONFIG_PATA_EFAR is not set
# CONFIG_PATA_HPT366 is not set
# CONFIG_PATA_HPT37X is not set
# CONFIG_PATA_HPT3X2N is not set
# CONFIG_PATA_HPT3X3 is not set
# CONFIG_PATA_IT8213 is not set
# CONFIG_PATA_IT821X is not set
# CONFIG_PATA_JMICRON is not set
# CONFIG_PATA_MARVELL is not set
# CONFIG_PATA_NETCELL is not set
# CONFIG_PATA_NINJA32 is not set
# CONFIG_PATA_NS87415 is not set
# CONFIG_PATA_OLDPIIX is not set
# CONFIG_PATA_OPTIDMA is not set
# CONFIG_PATA_PDC2027X is not set
# CONFIG_PATA_PDC_OLD is not set
# CONFIG_PATA_RADISYS is not set
# CONFIG_PATA_RDC is not set
# CONFIG_PATA_SC1200 is not set
# CONFIG_PATA_SCH is not set
# CONFIG_PATA_SERVERWORKS is not set
# CONFIG_PATA_SIL680 is not set
# CONFIG_PATA_SIS is not set
# CONFIG_PATA_TOSHIBA is not set
# CONFIG_PATA_TRIFLEX is not set
# CONFIG_PATA_VIA is not set
# CONFIG_PATA_WINBOND is not set

#
# PIO-only SFF controllers
#
# CONFIG_PATA_CMD640_PCI is not set
# CONFIG_PATA_MPIIX is not set
# CONFIG_PATA_NS87410 is not set
# CONFIG_PATA_OPTI is not set
# CONFIG_PATA_PCMCIA is not set
# CONFIG_PATA_PLATFORM is not set
# CONFIG_PATA_RZ1000 is not set

#
# Generic fallback / legacy drivers
#
# CONFIG_PATA_ACPI is not set
# CONFIG_ATA_GENERIC is not set
# CONFIG_PATA_LEGACY is not set
CONFIG_MD=y
CONFIG_BLK_DEV_MD=y
# CONFIG_MD_AUTODETECT is not set
CONFIG_MD_LINEAR=y
CONFIG_MD_RAID0=y
CONFIG_MD_RAID1=y
CONFIG_MD_RAID10=y
CONFIG_MD_RAID456=y
CONFIG_MD_MULTIPATH=y
CONFIG_MD_FAULTY=y
CONFIG_BCACHE=y
# CONFIG_BCACHE_DEBUG is not set
# CONFIG_BCACHE_CLOSURES_DEBUG is not set
CONFIG_BLK_DEV_DM=y
# CONFIG_DM_DEBUG is not set
CONFIG_DM_BUFIO=y
CONFIG_DM_BIO_PRISON=y
CONFIG_DM_PERSISTENT_DATA=y
CONFIG_DM_CRYPT=y
CONFIG_DM_SNAPSHOT=y
# CONFIG_DM_THIN_PROVISIONING is not set
CONFIG_DM_CACHE=y
CONFIG_DM_CACHE_MQ=y
CONFIG_DM_CACHE_CLEANER=y
CONFIG_DM_MIRROR=y
# CONFIG_DM_LOG_USERSPACE is not set
# CONFIG_DM_RAID is not set
CONFIG_DM_ZERO=y
CONFIG_DM_MULTIPATH=y
# CONFIG_DM_MULTIPATH_QL is not set
# CONFIG_DM_MULTIPATH_ST is not set
CONFIG_DM_DELAY=y
# CONFIG_DM_UEVENT is not set
CONFIG_DM_FLAKEY=y
# CONFIG_DM_VERITY is not set
# CONFIG_DM_SWITCH is not set
# CONFIG_TARGET_CORE is not set
CONFIG_FUSION=y
CONFIG_FUSION_SPI=y
CONFIG_FUSION_FC=y
CONFIG_FUSION_SAS=y
CONFIG_FUSION_MAX_SGE=40
CONFIG_FUSION_CTL=y
# CONFIG_FUSION_LOGGING is not set

#
# IEEE 1394 (FireWire) support
#
# CONFIG_FIREWIRE is not set
# CONFIG_FIREWIRE_NOSY is not set
# CONFIG_I2O is not set
# CONFIG_MACINTOSH_DRIVERS is not set
CONFIG_NETDEVICES=y
CONFIG_MII=y
CONFIG_NET_CORE=y
# CONFIG_BONDING is not set
# CONFIG_DUMMY is not set
# CONFIG_EQUALIZER is not set
# CONFIG_NET_FC is not set
# CONFIG_NET_TEAM is not set
# CONFIG_MACVLAN is not set
# CONFIG_VXLAN is not set
# CONFIG_NETCONSOLE is not set
# CONFIG_NETPOLL is not set
# CONFIG_NET_POLL_CONTROLLER is not set
CONFIG_TUN=y
# CONFIG_VETH is not set
CONFIG_VIRTIO_NET=y
# CONFIG_NLMON is not set
# CONFIG_ARCNET is not set

#
# CAIF transport drivers
#
CONFIG_VHOST_NET=y
CONFIG_VHOST_RING=y
CONFIG_VHOST=y

#
# Distributed Switch Architecture drivers
#
# CONFIG_NET_DSA_MV88E6XXX is not set
# CONFIG_NET_DSA_MV88E6060 is not set
# CONFIG_NET_DSA_MV88E6XXX_NEED_PPU is not set
# CONFIG_NET_DSA_MV88E6131 is not set
# CONFIG_NET_DSA_MV88E6123_61_65 is not set
CONFIG_ETHERNET=y
CONFIG_MDIO=y
# CONFIG_NET_VENDOR_3COM is not set
CONFIG_NET_VENDOR_ADAPTEC=y
# CONFIG_ADAPTEC_STARFIRE is not set
CONFIG_NET_VENDOR_ALTEON=y
CONFIG_ACENIC=y
# CONFIG_ACENIC_OMIT_TIGON_I is not set
CONFIG_NET_VENDOR_AMD=y
CONFIG_AMD8111_ETH=y
CONFIG_PCNET32=y
# CONFIG_PCMCIA_NMCLAN is not set
CONFIG_NET_VENDOR_ARC=y
CONFIG_NET_VENDOR_ATHEROS=y
CONFIG_ATL2=y
CONFIG_ATL1=y
CONFIG_ATL1E=y
CONFIG_ATL1C=y
# CONFIG_ALX is not set
CONFIG_NET_CADENCE=y
# CONFIG_ARM_AT91_ETHER is not set
# CONFIG_MACB is not set
CONFIG_NET_VENDOR_BROADCOM=y
# CONFIG_B44 is not set
CONFIG_BNX2=y
# CONFIG_CNIC is not set
CONFIG_TIGON3=y
# CONFIG_BNX2X is not set
CONFIG_NET_VENDOR_BROCADE=y
# CONFIG_BNA is not set
# CONFIG_NET_CALXEDA_XGMAC is not set
CONFIG_NET_VENDOR_CHELSIO=y
# CONFIG_CHELSIO_T1 is not set
# CONFIG_CHELSIO_T3 is not set
# CONFIG_CHELSIO_T4 is not set
# CONFIG_CHELSIO_T4VF is not set
CONFIG_NET_VENDOR_CISCO=y
# CONFIG_ENIC is not set
# CONFIG_DNET is not set
CONFIG_NET_VENDOR_DEC=y
CONFIG_NET_TULIP=y
# CONFIG_DE2104X is not set
CONFIG_TULIP=y
# CONFIG_TULIP_MWI is not set
# CONFIG_TULIP_MMIO is not set
# CONFIG_TULIP_NAPI is not set
CONFIG_DE4X5=y
CONFIG_WINBOND_840=y
CONFIG_DM9102=y
CONFIG_ULI526X=y
# CONFIG_PCMCIA_XIRCOM is not set
CONFIG_NET_VENDOR_DLINK=y
CONFIG_DL2K=y
# CONFIG_SUNDANCE is not set
CONFIG_NET_VENDOR_EMULEX=y
# CONFIG_BE2NET is not set
CONFIG_NET_VENDOR_EXAR=y
# CONFIG_S2IO is not set
# CONFIG_VXGE is not set
CONFIG_NET_VENDOR_FUJITSU=y
# CONFIG_PCMCIA_FMVJ18X is not set
CONFIG_NET_VENDOR_HP=y
# CONFIG_HP100 is not set
CONFIG_NET_VENDOR_INTEL=y
CONFIG_E100=y
CONFIG_E1000=y
CONFIG_E1000E=y
CONFIG_IGB=y
CONFIG_IGB_HWMON=y
# CONFIG_IGBVF is not set
CONFIG_IXGB=y
CONFIG_IXGBE=y
CONFIG_IXGBE_HWMON=y
# CONFIG_IXGBEVF is not set
# CONFIG_I40E is not set
CONFIG_NET_VENDOR_I825XX=y
# CONFIG_IP1000 is not set
# CONFIG_JME is not set
CONFIG_NET_VENDOR_MARVELL=y
# CONFIG_MVMDIO is not set
CONFIG_SKGE=y
# CONFIG_SKGE_DEBUG is not set
# CONFIG_SKGE_GENESIS is not set
CONFIG_SKY2=y
# CONFIG_SKY2_DEBUG is not set
CONFIG_NET_VENDOR_MELLANOX=y
# CONFIG_MLX4_EN is not set
# CONFIG_MLX4_CORE is not set
# CONFIG_MLX5_CORE is not set
CONFIG_NET_VENDOR_MICREL=y
# CONFIG_KS8851_MLL is not set
# CONFIG_KSZ884X_PCI is not set
CONFIG_NET_VENDOR_MYRI=y
# CONFIG_MYRI10GE is not set
# CONFIG_FEALNX is not set
CONFIG_NET_VENDOR_NATSEMI=y
# CONFIG_NATSEMI is not set
# CONFIG_NS83820 is not set
CONFIG_NET_VENDOR_8390=y
# CONFIG_PCMCIA_AXNET is not set
CONFIG_NE2K_PCI=y
# CONFIG_PCMCIA_PCNET is not set
CONFIG_NET_VENDOR_NVIDIA=y
CONFIG_FORCEDETH=y
CONFIG_NET_VENDOR_OKI=y
# CONFIG_PCH_GBE is not set
# CONFIG_ETHOC is not set
# CONFIG_NET_PACKET_ENGINE is not set
CONFIG_NET_VENDOR_QLOGIC=y
# CONFIG_QLA3XXX is not set
# CONFIG_QLCNIC is not set
# CONFIG_QLGE is not set
# CONFIG_NETXEN_NIC is not set
CONFIG_NET_VENDOR_REALTEK=y
CONFIG_8139CP=y
CONFIG_8139TOO=y
CONFIG_8139TOO_PIO=y
# CONFIG_8139TOO_TUNE_TWISTER is not set
# CONFIG_8139TOO_8129 is not set
# CONFIG_8139_OLD_RX_RESET is not set
CONFIG_R8169=y
# CONFIG_SH_ETH is not set
CONFIG_NET_VENDOR_RDC=y
# CONFIG_R6040 is not set
CONFIG_NET_VENDOR_SEEQ=y
CONFIG_NET_VENDOR_SILAN=y
# CONFIG_SC92031 is not set
CONFIG_NET_VENDOR_SIS=y
CONFIG_SIS900=y
# CONFIG_SIS190 is not set
# CONFIG_SFC is not set
CONFIG_NET_VENDOR_SMSC=y
# CONFIG_PCMCIA_SMC91C92 is not set
# CONFIG_EPIC100 is not set
# CONFIG_SMSC911X is not set
# CONFIG_SMSC9420 is not set
CONFIG_NET_VENDOR_STMICRO=y
# CONFIG_STMMAC_ETH is not set
CONFIG_NET_VENDOR_SUN=y
# CONFIG_HAPPYMEAL is not set
# CONFIG_SUNGEM is not set
# CONFIG_CASSINI is not set
# CONFIG_NIU is not set
CONFIG_NET_VENDOR_TEHUTI=y
# CONFIG_TEHUTI is not set
CONFIG_NET_VENDOR_TI=y
# CONFIG_TLAN is not set
CONFIG_NET_VENDOR_VIA=y
CONFIG_VIA_RHINE=y
# CONFIG_VIA_RHINE_MMIO is not set
CONFIG_VIA_VELOCITY=y
CONFIG_NET_VENDOR_WIZNET=y
# CONFIG_WIZNET_W5100 is not set
# CONFIG_WIZNET_W5300 is not set
CONFIG_NET_VENDOR_XIRCOM=y
# CONFIG_PCMCIA_XIRC2PS is not set
# CONFIG_FDDI is not set
# CONFIG_HIPPI is not set
# CONFIG_NET_SB1000 is not set
CONFIG_PHYLIB=y

#
# MII PHY device drivers
#
# CONFIG_AT803X_PHY is not set
# CONFIG_AMD_PHY is not set
# CONFIG_MARVELL_PHY is not set
# CONFIG_DAVICOM_PHY is not set
# CONFIG_QSEMI_PHY is not set
# CONFIG_LXT_PHY is not set
# CONFIG_CICADA_PHY is not set
# CONFIG_VITESSE_PHY is not set
# CONFIG_SMSC_PHY is not set
CONFIG_BROADCOM_PHY=y
# CONFIG_BCM87XX_PHY is not set
# CONFIG_ICPLUS_PHY is not set
# CONFIG_REALTEK_PHY is not set
# CONFIG_NATIONAL_PHY is not set
# CONFIG_STE10XP is not set
# CONFIG_LSI_ET1011C_PHY is not set
# CONFIG_MICREL_PHY is not set
# CONFIG_FIXED_PHY is not set
# CONFIG_MDIO_BITBANG is not set
# CONFIG_PPP is not set
# CONFIG_SLIP is not set

#
# USB Network Adapters
#
CONFIG_USB_CATC=y
CONFIG_USB_KAWETH=y
CONFIG_USB_PEGASUS=y
CONFIG_USB_RTL8150=y
# CONFIG_USB_RTL8152 is not set
CONFIG_USB_USBNET=y
CONFIG_USB_NET_AX8817X=y
CONFIG_USB_NET_AX88179_178A=y
CONFIG_USB_NET_CDCETHER=y
CONFIG_USB_NET_CDC_EEM=y
CONFIG_USB_NET_CDC_NCM=y
# CONFIG_USB_NET_HUAWEI_CDC_NCM is not set
# CONFIG_USB_NET_CDC_MBIM is not set
CONFIG_USB_NET_DM9601=y
# CONFIG_USB_NET_SR9700 is not set
CONFIG_USB_NET_SMSC75XX=y
CONFIG_USB_NET_SMSC95XX=y
CONFIG_USB_NET_GL620A=y
CONFIG_USB_NET_NET1080=y
CONFIG_USB_NET_PLUSB=y
CONFIG_USB_NET_MCS7830=y
CONFIG_USB_NET_RNDIS_HOST=y
CONFIG_USB_NET_CDC_SUBSET=y
CONFIG_USB_ALI_M5632=y
CONFIG_USB_AN2720=y
CONFIG_USB_BELKIN=y
CONFIG_USB_ARMLINUX=y
CONFIG_USB_EPSON2888=y
CONFIG_USB_KC2190=y
CONFIG_USB_NET_ZAURUS=y
# CONFIG_USB_NET_CX82310_ETH is not set
# CONFIG_USB_NET_KALMIA is not set
# CONFIG_USB_NET_QMI_WWAN is not set
CONFIG_USB_NET_INT51X1=y
CONFIG_USB_IPHETH=y
CONFIG_USB_SIERRA_NET=y
# CONFIG_USB_VL600 is not set
CONFIG_WLAN=y
# CONFIG_PCMCIA_RAYCS is not set
# CONFIG_AIRO is not set
# CONFIG_ATMEL is not set
# CONFIG_AIRO_CS is not set
# CONFIG_PCMCIA_WL3501 is not set
# CONFIG_PRISM54 is not set
# CONFIG_USB_ZD1201 is not set
# CONFIG_HOSTAP is not set
# CONFIG_WL_TI is not set

#
# Enable WiMAX (Networking options) to see the WiMAX drivers
#
# CONFIG_WAN is not set
# CONFIG_VMXNET3 is not set
# CONFIG_ISDN is not set

#
# Input device support
#
CONFIG_INPUT=y
CONFIG_INPUT_FF_MEMLESS=y
# CONFIG_INPUT_POLLDEV is not set
# CONFIG_INPUT_SPARSEKMAP is not set
# CONFIG_INPUT_MATRIXKMAP is not set

#
# Userland interfaces
#
CONFIG_INPUT_MOUSEDEV=y
# CONFIG_INPUT_MOUSEDEV_PSAUX is not set
CONFIG_INPUT_MOUSEDEV_SCREEN_X=1024
CONFIG_INPUT_MOUSEDEV_SCREEN_Y=768
# CONFIG_INPUT_JOYDEV is not set
CONFIG_INPUT_EVDEV=y
# CONFIG_INPUT_EVBUG is not set

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=y
# CONFIG_KEYBOARD_ADP5588 is not set
# CONFIG_KEYBOARD_ADP5589 is not set
CONFIG_KEYBOARD_ATKBD=y
# CONFIG_KEYBOARD_QT1070 is not set
# CONFIG_KEYBOARD_QT2160 is not set
# CONFIG_KEYBOARD_LKKBD is not set
# CONFIG_KEYBOARD_TCA6416 is not set
# CONFIG_KEYBOARD_TCA8418 is not set
# CONFIG_KEYBOARD_LM8333 is not set
# CONFIG_KEYBOARD_MAX7359 is not set
# CONFIG_KEYBOARD_MCS is not set
# CONFIG_KEYBOARD_MPR121 is not set
# CONFIG_KEYBOARD_NEWTON is not set
# CONFIG_KEYBOARD_OPENCORES is not set
# CONFIG_KEYBOARD_STOWAWAY is not set
# CONFIG_KEYBOARD_SUNKBD is not set
# CONFIG_KEYBOARD_XTKBD is not set
CONFIG_INPUT_MOUSE=y
CONFIG_MOUSE_PS2=y
CONFIG_MOUSE_PS2_ALPS=y
CONFIG_MOUSE_PS2_LOGIPS2PP=y
CONFIG_MOUSE_PS2_SYNAPTICS=y
CONFIG_MOUSE_PS2_CYPRESS=y
CONFIG_MOUSE_PS2_LIFEBOOK=y
CONFIG_MOUSE_PS2_TRACKPOINT=y
# CONFIG_MOUSE_PS2_ELANTECH is not set
# CONFIG_MOUSE_PS2_SENTELIC is not set
# CONFIG_MOUSE_PS2_TOUCHKIT is not set
CONFIG_MOUSE_SERIAL=y
# CONFIG_MOUSE_APPLETOUCH is not set
# CONFIG_MOUSE_BCM5974 is not set
# CONFIG_MOUSE_CYAPA is not set
# CONFIG_MOUSE_VSXXXAA is not set
# CONFIG_MOUSE_SYNAPTICS_I2C is not set
# CONFIG_MOUSE_SYNAPTICS_USB is not set
# CONFIG_INPUT_JOYSTICK is not set
# CONFIG_INPUT_TABLET is not set
# CONFIG_INPUT_TOUCHSCREEN is not set
CONFIG_INPUT_MISC=y
# CONFIG_INPUT_AD714X is not set
# CONFIG_INPUT_BMA150 is not set
# CONFIG_INPUT_PCSPKR is not set
# CONFIG_INPUT_MMA8450 is not set
# CONFIG_INPUT_MPU3050 is not set
# CONFIG_INPUT_ATLAS_BTNS is not set
# CONFIG_INPUT_ATI_REMOTE2 is not set
# CONFIG_INPUT_KEYSPAN_REMOTE is not set
# CONFIG_INPUT_KXTJ9 is not set
# CONFIG_INPUT_POWERMATE is not set
# CONFIG_INPUT_YEALINK is not set
# CONFIG_INPUT_CM109 is not set
# CONFIG_INPUT_UINPUT is not set
# CONFIG_INPUT_PCF8574 is not set
# CONFIG_INPUT_ADXL34X is not set
# CONFIG_INPUT_CMA3000 is not set
# CONFIG_INPUT_IDEAPAD_SLIDEBAR is not set

#
# Hardware I/O ports
#
CONFIG_SERIO=y
CONFIG_SERIO_I8042=y
CONFIG_SERIO_SERPORT=y
# CONFIG_SERIO_CT82C710 is not set
# CONFIG_SERIO_PCIPS2 is not set
CONFIG_SERIO_LIBPS2=y
# CONFIG_SERIO_RAW is not set
# CONFIG_SERIO_ALTERA_PS2 is not set
# CONFIG_SERIO_PS2MULT is not set
# CONFIG_SERIO_ARC_PS2 is not set
# CONFIG_GAMEPORT is not set

#
# Character devices
#
CONFIG_TTY=y
CONFIG_VT=y
CONFIG_CONSOLE_TRANSLATIONS=y
CONFIG_VT_CONSOLE=y
CONFIG_VT_CONSOLE_SLEEP=y
CONFIG_HW_CONSOLE=y
CONFIG_VT_HW_CONSOLE_BINDING=y
CONFIG_UNIX98_PTYS=y
# CONFIG_DEVPTS_MULTIPLE_INSTANCES is not set
# CONFIG_LEGACY_PTYS is not set
CONFIG_SERIAL_NONSTANDARD=y
# CONFIG_ROCKETPORT is not set
# CONFIG_CYCLADES is not set
# CONFIG_MOXA_INTELLIO is not set
# CONFIG_MOXA_SMARTIO is not set
# CONFIG_SYNCLINK is not set
# CONFIG_SYNCLINKMP is not set
# CONFIG_SYNCLINK_GT is not set
# CONFIG_NOZOMI is not set
# CONFIG_ISI is not set
# CONFIG_N_HDLC is not set
# CONFIG_N_GSM is not set
# CONFIG_TRACE_SINK is not set
CONFIG_DEVKMEM=y

#
# Serial drivers
#
CONFIG_SERIAL_8250=y
CONFIG_SERIAL_8250_DEPRECATED_OPTIONS=y
CONFIG_SERIAL_8250_PNP=y
CONFIG_SERIAL_8250_CONSOLE=y
CONFIG_FIX_EARLYCON_MEM=y
CONFIG_SERIAL_8250_PCI=y
# CONFIG_SERIAL_8250_CS is not set
CONFIG_SERIAL_8250_NR_UARTS=32
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
CONFIG_SERIAL_8250_EXTENDED=y
CONFIG_SERIAL_8250_MANY_PORTS=y
CONFIG_SERIAL_8250_SHARE_IRQ=y
CONFIG_SERIAL_8250_DETECT_IRQ=y
CONFIG_SERIAL_8250_RSA=y
# CONFIG_SERIAL_8250_DW is not set

#
# Non-8250 serial port support
#
# CONFIG_SERIAL_MFD_HSU is not set
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
# CONFIG_SERIAL_JSM is not set
# CONFIG_SERIAL_SCCNXP is not set
# CONFIG_SERIAL_TIMBERDALE is not set
# CONFIG_SERIAL_ALTERA_JTAGUART is not set
# CONFIG_SERIAL_ALTERA_UART is not set
# CONFIG_SERIAL_PCH_UART is not set
# CONFIG_SERIAL_ARC is not set
# CONFIG_SERIAL_RP2 is not set
# CONFIG_SERIAL_FSL_LPUART is not set
# CONFIG_TTY_PRINTK is not set
CONFIG_HVC_DRIVER=y
CONFIG_VIRTIO_CONSOLE=y
CONFIG_IPMI_HANDLER=m
# CONFIG_IPMI_PANIC_EVENT is not set
CONFIG_IPMI_DEVICE_INTERFACE=m
CONFIG_IPMI_SI=m
CONFIG_IPMI_WATCHDOG=m
CONFIG_IPMI_POWEROFF=m
CONFIG_HW_RANDOM=y
# CONFIG_HW_RANDOM_TIMERIOMEM is not set
CONFIG_HW_RANDOM_INTEL=y
CONFIG_HW_RANDOM_AMD=y
CONFIG_HW_RANDOM_VIA=y
CONFIG_HW_RANDOM_VIRTIO=y
CONFIG_NVRAM=y
# CONFIG_R3964 is not set
# CONFIG_APPLICOM is not set

#
# PCMCIA character devices
#
# CONFIG_SYNCLINK_CS is not set
# CONFIG_CARDMAN_4000 is not set
# CONFIG_CARDMAN_4040 is not set
# CONFIG_IPWIRELESS is not set
# CONFIG_MWAVE is not set
# CONFIG_RAW_DRIVER is not set
CONFIG_HPET=y
# CONFIG_HPET_MMAP is not set
# CONFIG_HANGCHECK_TIMER is not set
# CONFIG_TCG_TPM is not set
# CONFIG_TELCLOCK is not set
CONFIG_DEVPORT=y
CONFIG_I2C=y
CONFIG_I2C_BOARDINFO=y
CONFIG_I2C_COMPAT=y
# CONFIG_I2C_CHARDEV is not set
# CONFIG_I2C_MUX is not set
CONFIG_I2C_HELPER_AUTO=y
CONFIG_I2C_ALGOBIT=y

#
# I2C Hardware Bus support
#

#
# PC SMBus host controller drivers
#
# CONFIG_I2C_ALI1535 is not set
# CONFIG_I2C_ALI1563 is not set
# CONFIG_I2C_ALI15X3 is not set
# CONFIG_I2C_AMD756 is not set
# CONFIG_I2C_AMD8111 is not set
# CONFIG_I2C_I801 is not set
# CONFIG_I2C_ISCH is not set
# CONFIG_I2C_ISMT is not set
# CONFIG_I2C_PIIX4 is not set
# CONFIG_I2C_NFORCE2 is not set
# CONFIG_I2C_SIS5595 is not set
# CONFIG_I2C_SIS630 is not set
# CONFIG_I2C_SIS96X is not set
# CONFIG_I2C_VIA is not set
# CONFIG_I2C_VIAPRO is not set

#
# ACPI drivers
#
# CONFIG_I2C_SCMI is not set

#
# I2C system bus drivers (mostly embedded / system-on-chip)
#
# CONFIG_I2C_DESIGNWARE_PCI is not set
# CONFIG_I2C_EG20T is not set
# CONFIG_I2C_OCORES is not set
# CONFIG_I2C_PCA_PLATFORM is not set
# CONFIG_I2C_PXA_PCI is not set
# CONFIG_I2C_SIMTEC is not set
# CONFIG_I2C_XILINX is not set

#
# External I2C/SMBus adapter drivers
#
# CONFIG_I2C_DIOLAN_U2C is not set
# CONFIG_I2C_PARPORT_LIGHT is not set
# CONFIG_I2C_TAOS_EVM is not set
# CONFIG_I2C_TINY_USB is not set

#
# Other I2C/SMBus bus drivers
#
# CONFIG_I2C_STUB is not set
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
# CONFIG_SPI is not set
# CONFIG_HSI is not set

#
# PPS support
#
CONFIG_PPS=y
# CONFIG_PPS_DEBUG is not set

#
# PPS clients support
#
# CONFIG_PPS_CLIENT_KTIMER is not set
# CONFIG_PPS_CLIENT_LDISC is not set
# CONFIG_PPS_CLIENT_GPIO is not set

#
# PPS generators support
#

#
# PTP clock support
#
CONFIG_PTP_1588_CLOCK=y

#
# Enable PHYLIB and NETWORK_PHY_TIMESTAMPING to see the additional clocks.
#
# CONFIG_PTP_1588_CLOCK_PCH is not set
CONFIG_ARCH_WANT_OPTIONAL_GPIOLIB=y
# CONFIG_GPIOLIB is not set
# CONFIG_W1 is not set
CONFIG_POWER_SUPPLY=y
# CONFIG_POWER_SUPPLY_DEBUG is not set
# CONFIG_PDA_POWER is not set
# CONFIG_TEST_POWER is not set
# CONFIG_BATTERY_DS2780 is not set
# CONFIG_BATTERY_DS2781 is not set
# CONFIG_BATTERY_DS2782 is not set
# CONFIG_BATTERY_SBS is not set
# CONFIG_BATTERY_BQ27x00 is not set
# CONFIG_BATTERY_MAX17040 is not set
# CONFIG_BATTERY_MAX17042 is not set
# CONFIG_CHARGER_MAX8903 is not set
# CONFIG_CHARGER_LP8727 is not set
# CONFIG_CHARGER_BQ2415X is not set
# CONFIG_CHARGER_SMB347 is not set
# CONFIG_POWER_RESET is not set
# CONFIG_POWER_AVS is not set
CONFIG_HWMON=y
# CONFIG_HWMON_VID is not set
# CONFIG_HWMON_DEBUG_CHIP is not set

#
# Native drivers
#
# CONFIG_SENSORS_ABITUGURU is not set
# CONFIG_SENSORS_ABITUGURU3 is not set
# CONFIG_SENSORS_AD7414 is not set
# CONFIG_SENSORS_AD7418 is not set
# CONFIG_SENSORS_ADM1021 is not set
# CONFIG_SENSORS_ADM1025 is not set
# CONFIG_SENSORS_ADM1026 is not set
# CONFIG_SENSORS_ADM1029 is not set
# CONFIG_SENSORS_ADM1031 is not set
# CONFIG_SENSORS_ADM9240 is not set
# CONFIG_SENSORS_ADT7410 is not set
# CONFIG_SENSORS_ADT7411 is not set
# CONFIG_SENSORS_ADT7462 is not set
# CONFIG_SENSORS_ADT7470 is not set
# CONFIG_SENSORS_ADT7475 is not set
# CONFIG_SENSORS_ASC7621 is not set
# CONFIG_SENSORS_K8TEMP is not set
# CONFIG_SENSORS_K10TEMP is not set
# CONFIG_SENSORS_FAM15H_POWER is not set
# CONFIG_SENSORS_ASB100 is not set
# CONFIG_SENSORS_ATXP1 is not set
# CONFIG_SENSORS_DS620 is not set
# CONFIG_SENSORS_DS1621 is not set
# CONFIG_SENSORS_I5K_AMB is not set
# CONFIG_SENSORS_F71805F is not set
# CONFIG_SENSORS_F71882FG is not set
# CONFIG_SENSORS_F75375S is not set
# CONFIG_SENSORS_FSCHMD is not set
# CONFIG_SENSORS_G760A is not set
# CONFIG_SENSORS_G762 is not set
# CONFIG_SENSORS_GL518SM is not set
# CONFIG_SENSORS_GL520SM is not set
# CONFIG_SENSORS_HIH6130 is not set
# CONFIG_SENSORS_HTU21 is not set
# CONFIG_SENSORS_CORETEMP is not set
# CONFIG_SENSORS_IBMAEM is not set
# CONFIG_SENSORS_IBMPEX is not set
# CONFIG_SENSORS_IT87 is not set
# CONFIG_SENSORS_JC42 is not set
# CONFIG_SENSORS_LINEAGE is not set
# CONFIG_SENSORS_LM63 is not set
# CONFIG_SENSORS_LM73 is not set
# CONFIG_SENSORS_LM75 is not set
# CONFIG_SENSORS_LM77 is not set
# CONFIG_SENSORS_LM78 is not set
# CONFIG_SENSORS_LM80 is not set
# CONFIG_SENSORS_LM83 is not set
# CONFIG_SENSORS_LM85 is not set
# CONFIG_SENSORS_LM87 is not set
# CONFIG_SENSORS_LM90 is not set
# CONFIG_SENSORS_LM92 is not set
# CONFIG_SENSORS_LM93 is not set
# CONFIG_SENSORS_LTC4151 is not set
# CONFIG_SENSORS_LTC4215 is not set
# CONFIG_SENSORS_LTC4245 is not set
# CONFIG_SENSORS_LTC4261 is not set
# CONFIG_SENSORS_LM95234 is not set
# CONFIG_SENSORS_LM95241 is not set
# CONFIG_SENSORS_LM95245 is not set
# CONFIG_SENSORS_MAX16065 is not set
# CONFIG_SENSORS_MAX1619 is not set
# CONFIG_SENSORS_MAX1668 is not set
# CONFIG_SENSORS_MAX197 is not set
# CONFIG_SENSORS_MAX6639 is not set
# CONFIG_SENSORS_MAX6642 is not set
# CONFIG_SENSORS_MAX6650 is not set
# CONFIG_SENSORS_MAX6697 is not set
# CONFIG_SENSORS_MCP3021 is not set
# CONFIG_SENSORS_NCT6775 is not set
# CONFIG_SENSORS_NTC_THERMISTOR is not set
# CONFIG_SENSORS_PC87360 is not set
# CONFIG_SENSORS_PC87427 is not set
# CONFIG_SENSORS_PCF8591 is not set
# CONFIG_PMBUS is not set
# CONFIG_SENSORS_SHT21 is not set
# CONFIG_SENSORS_SIS5595 is not set
# CONFIG_SENSORS_SMM665 is not set
# CONFIG_SENSORS_DME1737 is not set
# CONFIG_SENSORS_EMC1403 is not set
# CONFIG_SENSORS_EMC2103 is not set
# CONFIG_SENSORS_EMC6W201 is not set
# CONFIG_SENSORS_SMSC47M1 is not set
# CONFIG_SENSORS_SMSC47M192 is not set
# CONFIG_SENSORS_SMSC47B397 is not set
# CONFIG_SENSORS_SCH56XX_COMMON is not set
# CONFIG_SENSORS_SCH5627 is not set
# CONFIG_SENSORS_SCH5636 is not set
# CONFIG_SENSORS_ADS1015 is not set
# CONFIG_SENSORS_ADS7828 is not set
# CONFIG_SENSORS_AMC6821 is not set
# CONFIG_SENSORS_INA209 is not set
# CONFIG_SENSORS_INA2XX is not set
# CONFIG_SENSORS_THMC50 is not set
# CONFIG_SENSORS_TMP102 is not set
# CONFIG_SENSORS_TMP401 is not set
# CONFIG_SENSORS_TMP421 is not set
# CONFIG_SENSORS_VIA_CPUTEMP is not set
# CONFIG_SENSORS_VIA686A is not set
# CONFIG_SENSORS_VT1211 is not set
# CONFIG_SENSORS_VT8231 is not set
# CONFIG_SENSORS_W83781D is not set
# CONFIG_SENSORS_W83791D is not set
# CONFIG_SENSORS_W83792D is not set
# CONFIG_SENSORS_W83793 is not set
# CONFIG_SENSORS_W83795 is not set
# CONFIG_SENSORS_W83L785TS is not set
# CONFIG_SENSORS_W83L786NG is not set
# CONFIG_SENSORS_W83627HF is not set
# CONFIG_SENSORS_W83627EHF is not set
# CONFIG_SENSORS_APPLESMC is not set

#
# ACPI drivers
#
# CONFIG_SENSORS_ACPI_POWER is not set
# CONFIG_SENSORS_ATK0110 is not set
CONFIG_THERMAL=y
CONFIG_THERMAL_HWMON=y
CONFIG_THERMAL_DEFAULT_GOV_STEP_WISE=y
# CONFIG_THERMAL_DEFAULT_GOV_FAIR_SHARE is not set
# CONFIG_THERMAL_DEFAULT_GOV_USER_SPACE is not set
# CONFIG_THERMAL_GOV_FAIR_SHARE is not set
CONFIG_THERMAL_GOV_STEP_WISE=y
CONFIG_THERMAL_GOV_USER_SPACE=y
# CONFIG_CPU_THERMAL is not set
# CONFIG_THERMAL_EMULATION is not set
# CONFIG_INTEL_POWERCLAMP is not set
CONFIG_X86_PKG_TEMP_THERMAL=m

#
# Texas Instruments thermal drivers
#
CONFIG_WATCHDOG=y
CONFIG_WATCHDOG_CORE=y
# CONFIG_WATCHDOG_NOWAYOUT is not set

#
# Watchdog Device Drivers
#
CONFIG_SOFT_WATCHDOG=y
# CONFIG_ACQUIRE_WDT is not set
# CONFIG_ADVANTECH_WDT is not set
# CONFIG_ALIM1535_WDT is not set
# CONFIG_ALIM7101_WDT is not set
# CONFIG_F71808E_WDT is not set
# CONFIG_SP5100_TCO is not set
# CONFIG_SC520_WDT is not set
# CONFIG_SBC_FITPC2_WATCHDOG is not set
# CONFIG_EUROTECH_WDT is not set
# CONFIG_IB700_WDT is not set
# CONFIG_IBMASR is not set
# CONFIG_WAFER_WDT is not set
CONFIG_I6300ESB_WDT=y
# CONFIG_IE6XX_WDT is not set
CONFIG_ITCO_WDT=y
CONFIG_ITCO_VENDOR_SUPPORT=y
# CONFIG_IT8712F_WDT is not set
# CONFIG_IT87_WDT is not set
# CONFIG_HP_WATCHDOG is not set
# CONFIG_SC1200_WDT is not set
# CONFIG_PC87413_WDT is not set
# CONFIG_NV_TCO is not set
# CONFIG_60XX_WDT is not set
# CONFIG_SBC8360_WDT is not set
# CONFIG_CPU5_WDT is not set
# CONFIG_SMSC_SCH311X_WDT is not set
# CONFIG_SMSC37B787_WDT is not set
# CONFIG_VIA_WDT is not set
# CONFIG_W83627HF_WDT is not set
# CONFIG_W83697HF_WDT is not set
# CONFIG_W83697UG_WDT is not set
# CONFIG_W83877F_WDT is not set
# CONFIG_W83977F_WDT is not set
# CONFIG_MACHZ_WDT is not set
# CONFIG_SBC_EPX_C3_WATCHDOG is not set

#
# PCI-based Watchdog Cards
#
# CONFIG_PCIPCWATCHDOG is not set
# CONFIG_WDTPCI is not set

#
# USB-based Watchdog Cards
#
# CONFIG_USBPCWATCHDOG is not set
CONFIG_SSB_POSSIBLE=y

#
# Sonics Silicon Backplane
#
# CONFIG_SSB is not set
CONFIG_BCMA_POSSIBLE=y

#
# Broadcom specific AMBA
#
# CONFIG_BCMA is not set

#
# Multifunction device drivers
#
CONFIG_MFD_CORE=y
# CONFIG_MFD_CS5535 is not set
# CONFIG_MFD_AS3711 is not set
# CONFIG_PMIC_ADP5520 is not set
# CONFIG_MFD_CROS_EC is not set
# CONFIG_PMIC_DA903X is not set
# CONFIG_MFD_DA9052_I2C is not set
# CONFIG_MFD_DA9055 is not set
# CONFIG_MFD_DA9063 is not set
# CONFIG_MFD_MC13XXX_I2C is not set
# CONFIG_HTC_PASIC3 is not set
CONFIG_LPC_ICH=y
# CONFIG_LPC_SCH is not set
# CONFIG_MFD_JANZ_CMODIO is not set
# CONFIG_MFD_KEMPLD is not set
# CONFIG_MFD_88PM800 is not set
# CONFIG_MFD_88PM805 is not set
# CONFIG_MFD_88PM860X is not set
# CONFIG_MFD_MAX77686 is not set
# CONFIG_MFD_MAX77693 is not set
# CONFIG_MFD_MAX8907 is not set
# CONFIG_MFD_MAX8925 is not set
# CONFIG_MFD_MAX8997 is not set
# CONFIG_MFD_MAX8998 is not set
# CONFIG_MFD_VIPERBOARD is not set
# CONFIG_MFD_RETU is not set
# CONFIG_MFD_PCF50633 is not set
# CONFIG_MFD_RDC321X is not set
# CONFIG_MFD_RTSX_PCI is not set
# CONFIG_MFD_RC5T583 is not set
# CONFIG_MFD_SEC_CORE is not set
# CONFIG_MFD_SI476X_CORE is not set
# CONFIG_MFD_SM501 is not set
# CONFIG_MFD_SMSC is not set
# CONFIG_ABX500_CORE is not set
# CONFIG_MFD_STMPE is not set
# CONFIG_MFD_SYSCON is not set
# CONFIG_MFD_TI_AM335X_TSCADC is not set
# CONFIG_MFD_LP8788 is not set
# CONFIG_MFD_PALMAS is not set
# CONFIG_TPS6105X is not set
# CONFIG_TPS6507X is not set
# CONFIG_MFD_TPS65090 is not set
# CONFIG_MFD_TPS65217 is not set
# CONFIG_MFD_TPS6586X is not set
# CONFIG_MFD_TPS80031 is not set
# CONFIG_TWL4030_CORE is not set
# CONFIG_TWL6040_CORE is not set
# CONFIG_MFD_WL1273_CORE is not set
# CONFIG_MFD_LM3533 is not set
# CONFIG_MFD_TC3589X is not set
# CONFIG_MFD_TMIO is not set
# CONFIG_MFD_VX855 is not set
# CONFIG_MFD_ARIZONA_I2C is not set
# CONFIG_MFD_WM8400 is not set
# CONFIG_MFD_WM831X_I2C is not set
# CONFIG_MFD_WM8350_I2C is not set
# CONFIG_MFD_WM8994 is not set
# CONFIG_REGULATOR is not set
# CONFIG_MEDIA_SUPPORT is not set

#
# Graphics support
#
# CONFIG_AGP is not set
CONFIG_VGA_ARB=y
CONFIG_VGA_ARB_MAX_GPUS=16
# CONFIG_VGA_SWITCHEROO is not set
# CONFIG_DRM is not set
# CONFIG_VGASTATE is not set
# CONFIG_VIDEO_OUTPUT_CONTROL is not set
# CONFIG_FB is not set
# CONFIG_EXYNOS_VIDEO is not set
# CONFIG_BACKLIGHT_LCD_SUPPORT is not set

#
# Console display driver support
#
CONFIG_VGA_CONSOLE=y
CONFIG_VGACON_SOFT_SCROLLBACK=y
CONFIG_VGACON_SOFT_SCROLLBACK_SIZE=64
CONFIG_DUMMY_CONSOLE=y
# CONFIG_SOUND is not set

#
# HID support
#
CONFIG_HID=y
CONFIG_HID_BATTERY_STRENGTH=y
# CONFIG_HIDRAW is not set
# CONFIG_UHID is not set
CONFIG_HID_GENERIC=y

#
# Special HID drivers
#
CONFIG_HID_A4TECH=y
# CONFIG_HID_ACRUX is not set
CONFIG_HID_APPLE=y
# CONFIG_HID_APPLEIR is not set
# CONFIG_HID_AUREAL is not set
CONFIG_HID_BELKIN=y
CONFIG_HID_CHERRY=y
CONFIG_HID_CHICONY=y
CONFIG_HID_CYPRESS=y
CONFIG_HID_DRAGONRISE=y
# CONFIG_DRAGONRISE_FF is not set
# CONFIG_HID_EMS_FF is not set
# CONFIG_HID_ELECOM is not set
# CONFIG_HID_ELO is not set
CONFIG_HID_EZKEY=y
# CONFIG_HID_HOLTEK is not set
# CONFIG_HID_HUION is not set
# CONFIG_HID_KEYTOUCH is not set
CONFIG_HID_KYE=y
# CONFIG_HID_UCLOGIC is not set
# CONFIG_HID_WALTOP is not set
CONFIG_HID_GYRATION=y
# CONFIG_HID_ICADE is not set
CONFIG_HID_TWINHAN=y
CONFIG_HID_KENSINGTON=y
# CONFIG_HID_LCPOWER is not set
# CONFIG_HID_LENOVO_TPKBD is not set
CONFIG_HID_LOGITECH=y
CONFIG_HID_LOGITECH_DJ=m
CONFIG_LOGITECH_FF=y
# CONFIG_LOGIRUMBLEPAD2_FF is not set
# CONFIG_LOGIG940_FF is not set
CONFIG_LOGIWHEELS_FF=y
# CONFIG_HID_MAGICMOUSE is not set
CONFIG_HID_MICROSOFT=y
CONFIG_HID_MONTEREY=y
# CONFIG_HID_MULTITOUCH is not set
CONFIG_HID_NTRIG=y
CONFIG_HID_ORTEK=y
CONFIG_HID_PANTHERLORD=y
# CONFIG_PANTHERLORD_FF is not set
CONFIG_HID_PETALYNX=y
# CONFIG_HID_PICOLCD is not set
# CONFIG_HID_PRIMAX is not set
# CONFIG_HID_ROCCAT is not set
# CONFIG_HID_SAITEK is not set
CONFIG_HID_SAMSUNG=y
# CONFIG_HID_SPEEDLINK is not set
# CONFIG_HID_STEELSERIES is not set
CONFIG_HID_SUNPLUS=y
CONFIG_HID_GREENASIA=y
# CONFIG_GREENASIA_FF is not set
CONFIG_HID_SMARTJOYPLUS=y
# CONFIG_SMARTJOYPLUS_FF is not set
# CONFIG_HID_TIVO is not set
CONFIG_HID_TOPSEED=y
CONFIG_HID_THRUSTMASTER=y
CONFIG_THRUSTMASTER_FF=y
# CONFIG_HID_XINMO is not set
CONFIG_HID_ZEROPLUS=y
# CONFIG_ZEROPLUS_FF is not set
# CONFIG_HID_ZYDACRON is not set
# CONFIG_HID_SENSOR_HUB is not set

#
# USB HID support
#
CONFIG_USB_HID=y
CONFIG_HID_PID=y
CONFIG_USB_HIDDEV=y

#
# I2C HID support
#
# CONFIG_I2C_HID is not set
CONFIG_USB_OHCI_LITTLE_ENDIAN=y
CONFIG_USB_SUPPORT=y
CONFIG_USB_COMMON=y
CONFIG_USB_ARCH_HAS_HCD=y
CONFIG_USB=y
# CONFIG_USB_DEBUG is not set
# CONFIG_USB_ANNOUNCE_NEW_DEVICES is not set

#
# Miscellaneous USB options
#
CONFIG_USB_DEFAULT_PERSIST=y
# CONFIG_USB_DYNAMIC_MINORS is not set
# CONFIG_USB_OTG is not set
# CONFIG_USB_OTG_WHITELIST is not set
# CONFIG_USB_OTG_BLACKLIST_HUB is not set
CONFIG_USB_MON=y
# CONFIG_USB_WUSB_CBAF is not set

#
# USB Host Controller Drivers
#
# CONFIG_USB_C67X00_HCD is not set
# CONFIG_USB_XHCI_HCD is not set
CONFIG_USB_EHCI_HCD=y
CONFIG_USB_EHCI_ROOT_HUB_TT=y
CONFIG_USB_EHCI_TT_NEWSCHED=y
CONFIG_USB_EHCI_PCI=y
# CONFIG_USB_EHCI_HCD_PLATFORM is not set
# CONFIG_USB_OXU210HP_HCD is not set
# CONFIG_USB_ISP116X_HCD is not set
# CONFIG_USB_ISP1760_HCD is not set
# CONFIG_USB_ISP1362_HCD is not set
# CONFIG_USB_FUSBH200_HCD is not set
# CONFIG_USB_FOTG210_HCD is not set
CONFIG_USB_OHCI_HCD=y
CONFIG_USB_OHCI_HCD_PCI=y
# CONFIG_USB_OHCI_HCD_PLATFORM is not set
CONFIG_USB_UHCI_HCD=y
# CONFIG_USB_SL811_HCD is not set
# CONFIG_USB_R8A66597_HCD is not set
# CONFIG_USB_HCD_TEST_MODE is not set

#
# USB Device Class drivers
#
# CONFIG_USB_ACM is not set
# CONFIG_USB_PRINTER is not set
# CONFIG_USB_WDM is not set
# CONFIG_USB_TMC is not set

#
# NOTE: USB_STORAGE depends on SCSI but BLK_DEV_SD may
#

#
# also be needed; see USB_STORAGE Help for more info
#
CONFIG_USB_STORAGE=y
# CONFIG_USB_STORAGE_DEBUG is not set
# CONFIG_USB_STORAGE_REALTEK is not set
CONFIG_USB_STORAGE_DATAFAB=y
CONFIG_USB_STORAGE_FREECOM=y
CONFIG_USB_STORAGE_ISD200=y
CONFIG_USB_STORAGE_USBAT=y
CONFIG_USB_STORAGE_SDDR09=y
CONFIG_USB_STORAGE_SDDR55=y
CONFIG_USB_STORAGE_JUMPSHOT=y
CONFIG_USB_STORAGE_ALAUDA=y
# CONFIG_USB_STORAGE_ONETOUCH is not set
# CONFIG_USB_STORAGE_KARMA is not set
# CONFIG_USB_STORAGE_CYPRESS_ATACB is not set
# CONFIG_USB_STORAGE_ENE_UB6250 is not set

#
# USB Imaging devices
#
# CONFIG_USB_MDC800 is not set
# CONFIG_USB_MICROTEK is not set
# CONFIG_USB_DWC3 is not set
# CONFIG_USB_CHIPIDEA is not set

#
# USB port drivers
#
# CONFIG_USB_SERIAL is not set

#
# USB Miscellaneous drivers
#
# CONFIG_USB_EMI62 is not set
# CONFIG_USB_EMI26 is not set
# CONFIG_USB_ADUTUX is not set
# CONFIG_USB_SEVSEG is not set
# CONFIG_USB_RIO500 is not set
# CONFIG_USB_LEGOTOWER is not set
# CONFIG_USB_LCD is not set
# CONFIG_USB_LED is not set
# CONFIG_USB_CYPRESS_CY7C63 is not set
# CONFIG_USB_CYTHERM is not set
# CONFIG_USB_IDMOUSE is not set
# CONFIG_USB_FTDI_ELAN is not set
# CONFIG_USB_APPLEDISPLAY is not set
# CONFIG_USB_SISUSBVGA is not set
# CONFIG_USB_LD is not set
# CONFIG_USB_TRANCEVIBRATOR is not set
# CONFIG_USB_IOWARRIOR is not set
CONFIG_USB_TEST=y
# CONFIG_USB_EHSET_TEST_FIXTURE is not set
# CONFIG_USB_ISIGHTFW is not set
# CONFIG_USB_YUREX is not set
# CONFIG_USB_EZUSB_FX2 is not set
# CONFIG_USB_HSIC_USB3503 is not set

#
# USB Physical Layer drivers
#
# CONFIG_USB_PHY is not set
# CONFIG_NOP_USB_XCEIV is not set
# CONFIG_SAMSUNG_USB2PHY is not set
# CONFIG_SAMSUNG_USB3PHY is not set
# CONFIG_USB_ISP1301 is not set
# CONFIG_USB_RCAR_PHY is not set
# CONFIG_USB_GADGET is not set
# CONFIG_UWB is not set
# CONFIG_MMC is not set
# CONFIG_MEMSTICK is not set
# CONFIG_NEW_LEDS is not set
# CONFIG_ACCESSIBILITY is not set
# CONFIG_INFINIBAND is not set
CONFIG_EDAC=y
CONFIG_EDAC_LEGACY_SYSFS=y
# CONFIG_EDAC_DEBUG is not set
CONFIG_EDAC_MM_EDAC=y
CONFIG_EDAC_GHES=y
CONFIG_EDAC_E752X=y
# CONFIG_EDAC_I82975X is not set
# CONFIG_EDAC_I3000 is not set
# CONFIG_EDAC_I3200 is not set
# CONFIG_EDAC_X38 is not set
# CONFIG_EDAC_I5400 is not set
# CONFIG_EDAC_I7CORE is not set
# CONFIG_EDAC_I5000 is not set
# CONFIG_EDAC_I5100 is not set
# CONFIG_EDAC_I7300 is not set
# CONFIG_EDAC_SBRIDGE is not set
CONFIG_RTC_LIB=y
CONFIG_RTC_CLASS=y
CONFIG_RTC_HCTOSYS=y
CONFIG_RTC_SYSTOHC=y
CONFIG_RTC_HCTOSYS_DEVICE="rtc0"
# CONFIG_RTC_DEBUG is not set

#
# RTC interfaces
#
CONFIG_RTC_INTF_SYSFS=y
CONFIG_RTC_INTF_PROC=y
CONFIG_RTC_INTF_DEV=y
# CONFIG_RTC_INTF_DEV_UIE_EMUL is not set
# CONFIG_RTC_DRV_TEST is not set

#
# I2C RTC drivers
#
# CONFIG_RTC_DRV_DS1307 is not set
# CONFIG_RTC_DRV_DS1374 is not set
# CONFIG_RTC_DRV_DS1672 is not set
# CONFIG_RTC_DRV_DS3232 is not set
# CONFIG_RTC_DRV_MAX6900 is not set
# CONFIG_RTC_DRV_RS5C372 is not set
# CONFIG_RTC_DRV_ISL1208 is not set
# CONFIG_RTC_DRV_ISL12022 is not set
# CONFIG_RTC_DRV_X1205 is not set
# CONFIG_RTC_DRV_PCF2127 is not set
# CONFIG_RTC_DRV_PCF8523 is not set
# CONFIG_RTC_DRV_PCF8563 is not set
# CONFIG_RTC_DRV_PCF8583 is not set
# CONFIG_RTC_DRV_M41T80 is not set
# CONFIG_RTC_DRV_BQ32K is not set
# CONFIG_RTC_DRV_S35390A is not set
# CONFIG_RTC_DRV_FM3130 is not set
# CONFIG_RTC_DRV_RX8581 is not set
# CONFIG_RTC_DRV_RX8025 is not set
# CONFIG_RTC_DRV_EM3027 is not set
# CONFIG_RTC_DRV_RV3029C2 is not set

#
# SPI RTC drivers
#

#
# Platform RTC drivers
#
CONFIG_RTC_DRV_CMOS=y
# CONFIG_RTC_DRV_DS1286 is not set
# CONFIG_RTC_DRV_DS1511 is not set
# CONFIG_RTC_DRV_DS1553 is not set
# CONFIG_RTC_DRV_DS1742 is not set
# CONFIG_RTC_DRV_STK17TA8 is not set
# CONFIG_RTC_DRV_M48T86 is not set
# CONFIG_RTC_DRV_M48T35 is not set
# CONFIG_RTC_DRV_M48T59 is not set
# CONFIG_RTC_DRV_MSM6242 is not set
# CONFIG_RTC_DRV_BQ4802 is not set
# CONFIG_RTC_DRV_RP5C01 is not set
# CONFIG_RTC_DRV_V3020 is not set
# CONFIG_RTC_DRV_DS2404 is not set

#
# on-CPU RTC drivers
#
# CONFIG_RTC_DRV_MOXART is not set

#
# HID Sensor RTC drivers
#
# CONFIG_RTC_DRV_HID_SENSOR_TIME is not set
# CONFIG_DMADEVICES is not set
# CONFIG_AUXDISPLAY is not set
# CONFIG_UIO is not set
# CONFIG_VIRT_DRIVERS is not set
CONFIG_VIRTIO=y

#
# Virtio drivers
#
CONFIG_VIRTIO_PCI=y
CONFIG_VIRTIO_BALLOON=y
CONFIG_VIRTIO_MMIO=y
# CONFIG_VIRTIO_MMIO_CMDLINE_DEVICES is not set

#
# Microsoft Hyper-V guest support
#
# CONFIG_HYPERV is not set
# CONFIG_STAGING is not set
CONFIG_X86_PLATFORM_DEVICES=y
# CONFIG_ACERHDF is not set
# CONFIG_ASUS_LAPTOP is not set
# CONFIG_FUJITSU_TABLET is not set
# CONFIG_HP_ACCEL is not set
# CONFIG_THINKPAD_ACPI is not set
# CONFIG_SENSORS_HDAPS is not set
# CONFIG_INTEL_MENLOW is not set
# CONFIG_EEEPC_LAPTOP is not set
# CONFIG_ACPI_WMI is not set
# CONFIG_TOPSTAR_LAPTOP is not set
# CONFIG_TOSHIBA_BT_RFKILL is not set
# CONFIG_ACPI_CMPC is not set
# CONFIG_INTEL_IPS is not set
# CONFIG_IBM_RTL is not set
# CONFIG_XO15_EBOOK is not set
# CONFIG_SAMSUNG_Q10 is not set
# CONFIG_INTEL_RST is not set
# CONFIG_INTEL_SMARTCONNECT is not set
# CONFIG_PVPANIC is not set
# CONFIG_CHROME_PLATFORMS is not set

#
# Hardware Spinlock drivers
#
CONFIG_CLKEVT_I8253=y
CONFIG_I8253_LOCK=y
CONFIG_CLKBLD_I8253=y
# CONFIG_MAILBOX is not set
CONFIG_IOMMU_SUPPORT=y
# CONFIG_AMD_IOMMU is not set
# CONFIG_INTEL_IOMMU is not set
# CONFIG_IRQ_REMAP is not set

#
# Remoteproc drivers
#
# CONFIG_STE_MODEM_RPROC is not set

#
# Rpmsg drivers
#
# CONFIG_PM_DEVFREQ is not set
# CONFIG_EXTCON is not set
# CONFIG_MEMORY is not set
# CONFIG_IIO is not set
# CONFIG_NTB is not set
# CONFIG_VME_BUS is not set
# CONFIG_PWM is not set
# CONFIG_IPACK_BUS is not set
# CONFIG_RESET_CONTROLLER is not set
# CONFIG_FMC is not set

#
# PHY Subsystem
#
# CONFIG_GENERIC_PHY is not set
# CONFIG_PHY_EXYNOS_MIPI_VIDEO is not set
# CONFIG_POWERCAP is not set

#
# Firmware Drivers
#
CONFIG_EDD=y
# CONFIG_EDD_OFF is not set
CONFIG_FIRMWARE_MEMMAP=y
CONFIG_DELL_RBU=y
CONFIG_DCDBAS=y
CONFIG_DMIID=y
# CONFIG_DMI_SYSFS is not set
# CONFIG_ISCSI_IBFT_FIND is not set
# CONFIG_GOOGLE_FIRMWARE is not set

#
# EFI (Extensible Firmware Interface) Support
#
# CONFIG_EFI_VARS is not set
CONFIG_UEFI_CPER=y

#
# File systems
#
CONFIG_DCACHE_WORD_ACCESS=y
CONFIG_EXT2_FS=y
CONFIG_EXT2_FS_XATTR=y
CONFIG_EXT2_FS_POSIX_ACL=y
CONFIG_EXT2_FS_SECURITY=y
CONFIG_EXT2_FS_XIP=y
CONFIG_EXT3_FS=y
# CONFIG_EXT3_DEFAULTS_TO_ORDERED is not set
CONFIG_EXT3_FS_XATTR=y
CONFIG_EXT3_FS_POSIX_ACL=y
CONFIG_EXT3_FS_SECURITY=y
CONFIG_EXT4_FS=y
CONFIG_EXT4_FS_POSIX_ACL=y
CONFIG_EXT4_FS_SECURITY=y
# CONFIG_EXT4_DEBUG is not set
CONFIG_FS_XIP=y
CONFIG_JBD=y
# CONFIG_JBD_DEBUG is not set
CONFIG_JBD2=y
# CONFIG_JBD2_DEBUG is not set
CONFIG_FS_MBCACHE=y
CONFIG_REISERFS_FS=y
# CONFIG_REISERFS_CHECK is not set
CONFIG_REISERFS_PROC_INFO=y
CONFIG_REISERFS_FS_XATTR=y
CONFIG_REISERFS_FS_POSIX_ACL=y
CONFIG_REISERFS_FS_SECURITY=y
# CONFIG_JFS_FS is not set
CONFIG_XFS_FS=y
CONFIG_XFS_QUOTA=y
CONFIG_XFS_POSIX_ACL=y
CONFIG_XFS_RT=y
# CONFIG_XFS_WARN is not set
# CONFIG_XFS_DEBUG is not set
# CONFIG_GFS2_FS is not set
# CONFIG_OCFS2_FS is not set
CONFIG_BTRFS_FS=y
CONFIG_BTRFS_FS_POSIX_ACL=y
# CONFIG_BTRFS_FS_CHECK_INTEGRITY is not set
# CONFIG_BTRFS_FS_RUN_SANITY_TESTS is not set
# CONFIG_BTRFS_DEBUG is not set
# CONFIG_BTRFS_ASSERT is not set
# CONFIG_NILFS2_FS is not set
CONFIG_FS_POSIX_ACL=y
CONFIG_EXPORTFS=y
CONFIG_FILE_LOCKING=y
CONFIG_FSNOTIFY=y
CONFIG_DNOTIFY=y
CONFIG_INOTIFY_USER=y
# CONFIG_FANOTIFY is not set
CONFIG_QUOTA=y
# CONFIG_QUOTA_NETLINK_INTERFACE is not set
# CONFIG_PRINT_QUOTA_WARNING is not set
# CONFIG_QUOTA_DEBUG is not set
CONFIG_QUOTA_TREE=y
# CONFIG_QFMT_V1 is not set
CONFIG_QFMT_V2=y
CONFIG_QUOTACTL=y
CONFIG_QUOTACTL_COMPAT=y
CONFIG_AUTOFS4_FS=y
CONFIG_FUSE_FS=y
# CONFIG_CUSE is not set
CONFIG_GENERIC_ACL=y

#
# Caches
#
# CONFIG_FSCACHE is not set

#
# CD-ROM/DVD Filesystems
#
CONFIG_ISO9660_FS=y
CONFIG_JOLIET=y
CONFIG_ZISOFS=y
CONFIG_UDF_FS=y
CONFIG_UDF_NLS=y

#
# DOS/FAT/NT Filesystems
#
CONFIG_FAT_FS=y
CONFIG_MSDOS_FS=y
CONFIG_VFAT_FS=y
CONFIG_FAT_DEFAULT_CODEPAGE=437
CONFIG_FAT_DEFAULT_IOCHARSET="ascii"
# CONFIG_NTFS_FS is not set

#
# Pseudo filesystems
#
CONFIG_PROC_FS=y
CONFIG_PROC_KCORE=y
CONFIG_PROC_VMCORE=y
CONFIG_PROC_SYSCTL=y
CONFIG_PROC_PAGE_MONITOR=y
CONFIG_SYSFS=y
CONFIG_TMPFS=y
CONFIG_TMPFS_POSIX_ACL=y
CONFIG_TMPFS_XATTR=y
CONFIG_HUGETLBFS=y
CONFIG_HUGETLB_PAGE=y
CONFIG_CONFIGFS_FS=y
CONFIG_MISC_FILESYSTEMS=y
# CONFIG_ADFS_FS is not set
# CONFIG_AFFS_FS is not set
# CONFIG_ECRYPT_FS is not set
# CONFIG_HFS_FS is not set
# CONFIG_HFSPLUS_FS is not set
# CONFIG_BEFS_FS is not set
# CONFIG_BFS_FS is not set
# CONFIG_EFS_FS is not set
# CONFIG_LOGFS is not set
# CONFIG_CRAMFS is not set
# CONFIG_SQUASHFS is not set
# CONFIG_VXFS_FS is not set
# CONFIG_MINIX_FS is not set
# CONFIG_OMFS_FS is not set
# CONFIG_HPFS_FS is not set
# CONFIG_QNX4FS_FS is not set
# CONFIG_QNX6FS_FS is not set
CONFIG_ROMFS_FS=y
CONFIG_ROMFS_BACKED_BY_BLOCK=y
CONFIG_ROMFS_ON_BLOCK=y
CONFIG_PSTORE=y
# CONFIG_PSTORE_CONSOLE is not set
# CONFIG_PSTORE_FTRACE is not set
# CONFIG_PSTORE_RAM is not set
# CONFIG_SYSV_FS is not set
# CONFIG_UFS_FS is not set
# CONFIG_F2FS_FS is not set
# CONFIG_EFIVAR_FS is not set
CONFIG_NETWORK_FILESYSTEMS=y
CONFIG_NFS_FS=y
CONFIG_NFS_V2=y
CONFIG_NFS_V3=y
CONFIG_NFS_V3_ACL=y
CONFIG_NFS_V4=y
# CONFIG_NFS_SWAP is not set
CONFIG_NFS_V4_1=y
# CONFIG_NFS_V4_2 is not set
CONFIG_PNFS_FILE_LAYOUT=y
CONFIG_PNFS_BLOCK=y
CONFIG_NFS_V4_1_IMPLEMENTATION_ID_DOMAIN="kernel.org"
# CONFIG_NFS_V4_1_MIGRATION is not set
CONFIG_ROOT_NFS=y
# CONFIG_NFS_USE_LEGACY_DNS is not set
CONFIG_NFS_USE_KERNEL_DNS=y
CONFIG_NFSD=y
CONFIG_NFSD_V2_ACL=y
CONFIG_NFSD_V3=y
CONFIG_NFSD_V3_ACL=y
CONFIG_NFSD_V4=y
# CONFIG_NFSD_FAULT_INJECTION is not set
CONFIG_LOCKD=y
CONFIG_LOCKD_V4=y
CONFIG_NFS_ACL_SUPPORT=y
CONFIG_NFS_COMMON=y
CONFIG_SUNRPC=y
CONFIG_SUNRPC_GSS=y
CONFIG_SUNRPC_BACKCHANNEL=y
CONFIG_RPCSEC_GSS_KRB5=y
# CONFIG_SUNRPC_DEBUG is not set
# CONFIG_CEPH_FS is not set
CONFIG_CIFS=y
# CONFIG_CIFS_STATS is not set
CONFIG_CIFS_WEAK_PW_HASH=y
# CONFIG_CIFS_UPCALL is not set
CONFIG_CIFS_XATTR=y
CONFIG_CIFS_POSIX=y
# CONFIG_CIFS_ACL is not set
CONFIG_CIFS_DEBUG=y
# CONFIG_CIFS_DEBUG2 is not set
# CONFIG_CIFS_DFS_UPCALL is not set
# CONFIG_CIFS_SMB2 is not set
# CONFIG_NCP_FS is not set
# CONFIG_CODA_FS is not set
# CONFIG_AFS_FS is not set
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="utf8"
CONFIG_NLS_CODEPAGE_437=y
# CONFIG_NLS_CODEPAGE_737 is not set
# CONFIG_NLS_CODEPAGE_775 is not set
# CONFIG_NLS_CODEPAGE_850 is not set
# CONFIG_NLS_CODEPAGE_852 is not set
# CONFIG_NLS_CODEPAGE_855 is not set
# CONFIG_NLS_CODEPAGE_857 is not set
# CONFIG_NLS_CODEPAGE_860 is not set
# CONFIG_NLS_CODEPAGE_861 is not set
# CONFIG_NLS_CODEPAGE_862 is not set
# CONFIG_NLS_CODEPAGE_863 is not set
# CONFIG_NLS_CODEPAGE_864 is not set
# CONFIG_NLS_CODEPAGE_865 is not set
# CONFIG_NLS_CODEPAGE_866 is not set
# CONFIG_NLS_CODEPAGE_869 is not set
# CONFIG_NLS_CODEPAGE_936 is not set
# CONFIG_NLS_CODEPAGE_950 is not set
# CONFIG_NLS_CODEPAGE_932 is not set
# CONFIG_NLS_CODEPAGE_949 is not set
# CONFIG_NLS_CODEPAGE_874 is not set
# CONFIG_NLS_ISO8859_8 is not set
# CONFIG_NLS_CODEPAGE_1250 is not set
# CONFIG_NLS_CODEPAGE_1251 is not set
CONFIG_NLS_ASCII=y
CONFIG_NLS_ISO8859_1=y
# CONFIG_NLS_ISO8859_2 is not set
# CONFIG_NLS_ISO8859_3 is not set
# CONFIG_NLS_ISO8859_4 is not set
# CONFIG_NLS_ISO8859_5 is not set
# CONFIG_NLS_ISO8859_6 is not set
# CONFIG_NLS_ISO8859_7 is not set
# CONFIG_NLS_ISO8859_9 is not set
# CONFIG_NLS_ISO8859_13 is not set
# CONFIG_NLS_ISO8859_14 is not set
# CONFIG_NLS_ISO8859_15 is not set
# CONFIG_NLS_KOI8_R is not set
# CONFIG_NLS_KOI8_U is not set
# CONFIG_NLS_MAC_ROMAN is not set
# CONFIG_NLS_MAC_CELTIC is not set
# CONFIG_NLS_MAC_CENTEURO is not set
# CONFIG_NLS_MAC_CROATIAN is not set
# CONFIG_NLS_MAC_CYRILLIC is not set
# CONFIG_NLS_MAC_GAELIC is not set
# CONFIG_NLS_MAC_GREEK is not set
# CONFIG_NLS_MAC_ICELAND is not set
# CONFIG_NLS_MAC_INUIT is not set
# CONFIG_NLS_MAC_ROMANIAN is not set
# CONFIG_NLS_MAC_TURKISH is not set
CONFIG_NLS_UTF8=y
# CONFIG_DLM is not set

#
# Kernel hacking
#
CONFIG_TRACE_IRQFLAGS_SUPPORT=y

#
# printk and dmesg options
#
CONFIG_PRINTK_TIME=y
CONFIG_DEFAULT_MESSAGE_LOGLEVEL=4
# CONFIG_BOOT_PRINTK_DELAY is not set
CONFIG_DYNAMIC_DEBUG=y

#
# Compile-time checks and compiler options
#
# CONFIG_DEBUG_INFO is not set
CONFIG_ENABLE_WARN_DEPRECATED=y
CONFIG_ENABLE_MUST_CHECK=y
CONFIG_FRAME_WARN=2048
# CONFIG_STRIP_ASM_SYMS is not set
# CONFIG_READABLE_ASM is not set
# CONFIG_UNUSED_SYMBOLS is not set
CONFIG_DEBUG_FS=y
# CONFIG_HEADERS_CHECK is not set
# CONFIG_DEBUG_SECTION_MISMATCH is not set
CONFIG_ARCH_WANT_FRAME_POINTERS=y
CONFIG_FRAME_POINTER=y
# CONFIG_DEBUG_FORCE_WEAK_PER_CPU is not set
CONFIG_MAGIC_SYSRQ=y
CONFIG_MAGIC_SYSRQ_DEFAULT_ENABLE=0x1
CONFIG_DEBUG_KERNEL=y

#
# Memory Debugging
#
# CONFIG_DEBUG_PAGEALLOC is not set
# CONFIG_DEBUG_OBJECTS is not set
# CONFIG_SLUB_DEBUG_ON is not set
# CONFIG_SLUB_STATS is not set
CONFIG_HAVE_DEBUG_KMEMLEAK=y
# CONFIG_DEBUG_KMEMLEAK is not set
# CONFIG_DEBUG_STACK_USAGE is not set
# CONFIG_DEBUG_VM is not set
# CONFIG_DEBUG_VIRTUAL is not set
CONFIG_DEBUG_MEMORY_INIT=y
# CONFIG_DEBUG_PER_CPU_MAPS is not set
CONFIG_HAVE_DEBUG_STACKOVERFLOW=y
# CONFIG_DEBUG_STACKOVERFLOW is not set
CONFIG_HAVE_ARCH_KMEMCHECK=y
# CONFIG_DEBUG_SHIRQ is not set

#
# Debug Lockups and Hangs
#
# CONFIG_LOCKUP_DETECTOR is not set
# CONFIG_DETECT_HUNG_TASK is not set
# CONFIG_PANIC_ON_OOPS is not set
CONFIG_PANIC_ON_OOPS_VALUE=0
CONFIG_SCHED_DEBUG=y
# CONFIG_SCHEDSTATS is not set
# CONFIG_TIMER_STATS is not set

#
# Lock Debugging (spinlocks, mutexes, etc...)
#
# CONFIG_DEBUG_RT_MUTEXES is not set
# CONFIG_RT_MUTEX_TESTER is not set
# CONFIG_DEBUG_SPINLOCK is not set
# CONFIG_DEBUG_MUTEXES is not set
# CONFIG_DEBUG_WW_MUTEX_SLOWPATH is not set
# CONFIG_DEBUG_LOCK_ALLOC is not set
# CONFIG_PROVE_LOCKING is not set
# CONFIG_LOCK_STAT is not set
CONFIG_DEBUG_ATOMIC_SLEEP=y
# CONFIG_DEBUG_LOCKING_API_SELFTESTS is not set
CONFIG_TRACE_IRQFLAGS=y
CONFIG_STACKTRACE=y
# CONFIG_DEBUG_KOBJECT is not set
CONFIG_DEBUG_BUGVERBOSE=y
# CONFIG_DEBUG_WRITECOUNT is not set
# CONFIG_DEBUG_LIST is not set
# CONFIG_DEBUG_SG is not set
# CONFIG_DEBUG_NOTIFIERS is not set
# CONFIG_DEBUG_CREDENTIALS is not set

#
# RCU Debugging
#
CONFIG_SPARSE_RCU_POINTER=y
# CONFIG_RCU_TORTURE_TEST is not set
CONFIG_RCU_CPU_STALL_TIMEOUT=60
# CONFIG_RCU_CPU_STALL_INFO is not set
# CONFIG_RCU_TRACE is not set
# CONFIG_DEBUG_BLOCK_EXT_DEVT is not set
# CONFIG_NOTIFIER_ERROR_INJECTION is not set
# CONFIG_FAULT_INJECTION is not set
# CONFIG_LATENCYTOP is not set
CONFIG_ARCH_HAS_DEBUG_STRICT_USER_COPY_CHECKS=y
# CONFIG_DEBUG_STRICT_USER_COPY_CHECKS is not set
CONFIG_USER_STACKTRACE_SUPPORT=y
CONFIG_NOP_TRACER=y
CONFIG_HAVE_FUNCTION_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_FP_TEST=y
CONFIG_HAVE_FUNCTION_TRACE_MCOUNT_TEST=y
CONFIG_HAVE_DYNAMIC_FTRACE=y
CONFIG_HAVE_DYNAMIC_FTRACE_WITH_REGS=y
CONFIG_HAVE_FTRACE_MCOUNT_RECORD=y
CONFIG_HAVE_SYSCALL_TRACEPOINTS=y
CONFIG_HAVE_FENTRY=y
CONFIG_HAVE_C_RECORDMCOUNT=y
CONFIG_TRACER_MAX_TRACE=y
CONFIG_TRACE_CLOCK=y
CONFIG_RING_BUFFER=y
CONFIG_EVENT_TRACING=y
CONFIG_CONTEXT_SWITCH_TRACER=y
CONFIG_RING_BUFFER_ALLOW_SWAP=y
CONFIG_TRACING=y
CONFIG_GENERIC_TRACER=y
CONFIG_TRACING_SUPPORT=y
CONFIG_FTRACE=y
CONFIG_FUNCTION_TRACER=y
CONFIG_FUNCTION_GRAPH_TRACER=y
CONFIG_IRQSOFF_TRACER=y
CONFIG_SCHED_TRACER=y
CONFIG_FTRACE_SYSCALLS=y
CONFIG_TRACER_SNAPSHOT=y
CONFIG_TRACER_SNAPSHOT_PER_CPU_SWAP=y
CONFIG_BRANCH_PROFILE_NONE=y
# CONFIG_PROFILE_ANNOTATED_BRANCHES is not set
# CONFIG_PROFILE_ALL_BRANCHES is not set
# CONFIG_STACK_TRACER is not set
CONFIG_BLK_DEV_IO_TRACE=y
CONFIG_KPROBE_EVENT=y
CONFIG_UPROBE_EVENT=y
CONFIG_PROBE_EVENTS=y
CONFIG_DYNAMIC_FTRACE=y
CONFIG_DYNAMIC_FTRACE_WITH_REGS=y
CONFIG_FUNCTION_PROFILER=y
CONFIG_FTRACE_MCOUNT_RECORD=y
# CONFIG_FTRACE_STARTUP_TEST is not set
CONFIG_MMIOTRACE=y
# CONFIG_MMIOTRACE_TEST is not set
# CONFIG_RING_BUFFER_BENCHMARK is not set
# CONFIG_RING_BUFFER_STARTUP_TEST is not set

#
# Runtime Testing
#
CONFIG_LKDTM=y
# CONFIG_TEST_LIST_SORT is not set
# CONFIG_KPROBES_SANITY_TEST is not set
# CONFIG_BACKTRACE_SELF_TEST is not set
# CONFIG_RBTREE_TEST is not set
# CONFIG_INTERVAL_TREE_TEST is not set
# CONFIG_PERCPU_TEST is not set
CONFIG_ATOMIC64_SELFTEST=y
# CONFIG_ASYNC_RAID6_TEST is not set
# CONFIG_TEST_STRING_HELPERS is not set
# CONFIG_TEST_KSTRTOX is not set
# CONFIG_PROVIDE_OHCI1394_DMA_INIT is not set
# CONFIG_DMA_API_DEBUG is not set
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
# CONFIG_KGDB is not set
# CONFIG_STRICT_DEVMEM is not set
CONFIG_X86_VERBOSE_BOOTUP=y
CONFIG_EARLY_PRINTK=y
# CONFIG_EARLY_PRINTK_DBGP is not set
# CONFIG_EARLY_PRINTK_EFI is not set
# CONFIG_X86_PTDUMP is not set
CONFIG_DEBUG_RODATA=y
CONFIG_DEBUG_RODATA_TEST=y
CONFIG_DEBUG_SET_MODULE_RONX=y
# CONFIG_DEBUG_NX_TEST is not set
CONFIG_DOUBLEFAULT=y
# CONFIG_DEBUG_TLBFLUSH is not set
# CONFIG_IOMMU_DEBUG is not set
# CONFIG_IOMMU_STRESS is not set
CONFIG_HAVE_MMIOTRACE_SUPPORT=y
# CONFIG_X86_DECODER_SELFTEST is not set
CONFIG_IO_DELAY_TYPE_0X80=0
CONFIG_IO_DELAY_TYPE_0XED=1
CONFIG_IO_DELAY_TYPE_UDELAY=2
CONFIG_IO_DELAY_TYPE_NONE=3
CONFIG_IO_DELAY_0X80=y
# CONFIG_IO_DELAY_0XED is not set
# CONFIG_IO_DELAY_UDELAY is not set
# CONFIG_IO_DELAY_NONE is not set
CONFIG_DEFAULT_IO_DELAY_TYPE=0
# CONFIG_DEBUG_BOOT_PARAMS is not set
# CONFIG_CPA_DEBUG is not set
# CONFIG_OPTIMIZE_INLINING is not set
# CONFIG_DEBUG_NMI_SELFTEST is not set
# CONFIG_X86_DEBUG_STATIC_CPU_HAS is not set

#
# Security options
#
CONFIG_KEYS=y
# CONFIG_PERSISTENT_KEYRINGS is not set
# CONFIG_BIG_KEYS is not set
# CONFIG_ENCRYPTED_KEYS is not set
CONFIG_KEYS_DEBUG_PROC_KEYS=y
# CONFIG_SECURITY_DMESG_RESTRICT is not set
# CONFIG_SECURITY is not set
# CONFIG_SECURITYFS is not set
CONFIG_DEFAULT_SECURITY_DAC=y
CONFIG_DEFAULT_SECURITY=""
CONFIG_XOR_BLOCKS=y
CONFIG_ASYNC_CORE=y
CONFIG_ASYNC_MEMCPY=y
CONFIG_ASYNC_XOR=y
CONFIG_ASYNC_PQ=y
CONFIG_ASYNC_RAID6_RECOV=y
CONFIG_CRYPTO=y

#
# Crypto core or helper
#
CONFIG_CRYPTO_ALGAPI=y
CONFIG_CRYPTO_ALGAPI2=y
CONFIG_CRYPTO_AEAD=y
CONFIG_CRYPTO_AEAD2=y
CONFIG_CRYPTO_BLKCIPHER=y
CONFIG_CRYPTO_BLKCIPHER2=y
CONFIG_CRYPTO_HASH=y
CONFIG_CRYPTO_HASH2=y
CONFIG_CRYPTO_RNG=y
CONFIG_CRYPTO_RNG2=y
CONFIG_CRYPTO_PCOMP=y
CONFIG_CRYPTO_PCOMP2=y
CONFIG_CRYPTO_MANAGER=y
CONFIG_CRYPTO_MANAGER2=y
# CONFIG_CRYPTO_USER is not set
CONFIG_CRYPTO_MANAGER_DISABLE_TESTS=y
CONFIG_CRYPTO_GF128MUL=y
CONFIG_CRYPTO_NULL=y
CONFIG_CRYPTO_PCRYPT=y
CONFIG_CRYPTO_WORKQUEUE=y
CONFIG_CRYPTO_CRYPTD=y
CONFIG_CRYPTO_AUTHENC=y
CONFIG_CRYPTO_TEST=m
CONFIG_CRYPTO_ABLK_HELPER=y
CONFIG_CRYPTO_GLUE_HELPER_X86=y

#
# Authenticated Encryption with Associated Data
#
CONFIG_CRYPTO_CCM=y
CONFIG_CRYPTO_GCM=y
CONFIG_CRYPTO_SEQIV=y

#
# Block modes
#
CONFIG_CRYPTO_CBC=y
CONFIG_CRYPTO_CTR=y
CONFIG_CRYPTO_CTS=y
CONFIG_CRYPTO_ECB=y
CONFIG_CRYPTO_LRW=y
CONFIG_CRYPTO_PCBC=y
CONFIG_CRYPTO_XTS=y

#
# Hash modes
#
CONFIG_CRYPTO_CMAC=y
CONFIG_CRYPTO_HMAC=y
CONFIG_CRYPTO_XCBC=y
CONFIG_CRYPTO_VMAC=y

#
# Digest
#
CONFIG_CRYPTO_CRC32C=y
CONFIG_CRYPTO_CRC32C_INTEL=y
CONFIG_CRYPTO_CRC32=y
CONFIG_CRYPTO_CRC32_PCLMUL=y
CONFIG_CRYPTO_CRCT10DIF=y
# CONFIG_CRYPTO_CRCT10DIF_PCLMUL is not set
CONFIG_CRYPTO_GHASH=y
CONFIG_CRYPTO_MD4=y
CONFIG_CRYPTO_MD5=y
CONFIG_CRYPTO_MICHAEL_MIC=y
CONFIG_CRYPTO_RMD128=y
CONFIG_CRYPTO_RMD160=y
CONFIG_CRYPTO_RMD256=y
CONFIG_CRYPTO_RMD320=y
CONFIG_CRYPTO_SHA1=y
CONFIG_CRYPTO_SHA1_SSSE3=y
# CONFIG_CRYPTO_SHA256_SSSE3 is not set
# CONFIG_CRYPTO_SHA512_SSSE3 is not set
CONFIG_CRYPTO_SHA256=y
CONFIG_CRYPTO_SHA512=y
CONFIG_CRYPTO_TGR192=y
CONFIG_CRYPTO_WP512=y
CONFIG_CRYPTO_GHASH_CLMUL_NI_INTEL=y

#
# Ciphers
#
CONFIG_CRYPTO_AES=y
CONFIG_CRYPTO_AES_X86_64=y
CONFIG_CRYPTO_AES_NI_INTEL=y
CONFIG_CRYPTO_ANUBIS=y
CONFIG_CRYPTO_ARC4=y
CONFIG_CRYPTO_BLOWFISH=y
CONFIG_CRYPTO_BLOWFISH_COMMON=y
CONFIG_CRYPTO_BLOWFISH_X86_64=y
CONFIG_CRYPTO_CAMELLIA=y
CONFIG_CRYPTO_CAMELLIA_X86_64=y
CONFIG_CRYPTO_CAMELLIA_AESNI_AVX_X86_64=y
# CONFIG_CRYPTO_CAMELLIA_AESNI_AVX2_X86_64 is not set
CONFIG_CRYPTO_CAST_COMMON=y
CONFIG_CRYPTO_CAST5=y
CONFIG_CRYPTO_CAST5_AVX_X86_64=y
CONFIG_CRYPTO_CAST6=y
CONFIG_CRYPTO_CAST6_AVX_X86_64=y
CONFIG_CRYPTO_DES=y
CONFIG_CRYPTO_FCRYPT=y
CONFIG_CRYPTO_KHAZAD=y
CONFIG_CRYPTO_SALSA20=y
CONFIG_CRYPTO_SALSA20_X86_64=y
CONFIG_CRYPTO_SEED=y
CONFIG_CRYPTO_SERPENT=y
CONFIG_CRYPTO_SERPENT_SSE2_X86_64=y
CONFIG_CRYPTO_SERPENT_AVX_X86_64=y
# CONFIG_CRYPTO_SERPENT_AVX2_X86_64 is not set
CONFIG_CRYPTO_TEA=y
CONFIG_CRYPTO_TWOFISH=y
CONFIG_CRYPTO_TWOFISH_COMMON=y
CONFIG_CRYPTO_TWOFISH_X86_64=y
CONFIG_CRYPTO_TWOFISH_X86_64_3WAY=y
CONFIG_CRYPTO_TWOFISH_AVX_X86_64=y

#
# Compression
#
CONFIG_CRYPTO_DEFLATE=y
CONFIG_CRYPTO_ZLIB=y
CONFIG_CRYPTO_LZO=y
# CONFIG_CRYPTO_LZ4 is not set
# CONFIG_CRYPTO_LZ4HC is not set

#
# Random Number Generation
#
CONFIG_CRYPTO_ANSI_CPRNG=y
CONFIG_CRYPTO_USER_API=y
CONFIG_CRYPTO_USER_API_HASH=y
CONFIG_CRYPTO_USER_API_SKCIPHER=y
CONFIG_CRYPTO_HASH_INFO=y
CONFIG_CRYPTO_HW=y
# CONFIG_CRYPTO_DEV_PADLOCK is not set
CONFIG_ASYMMETRIC_KEY_TYPE=y
CONFIG_ASYMMETRIC_PUBLIC_KEY_SUBTYPE=y
CONFIG_PUBLIC_KEY_ALGO_RSA=y
# CONFIG_X509_CERTIFICATE_PARSER is not set
CONFIG_HAVE_KVM=y
CONFIG_HAVE_KVM_IRQCHIP=y
CONFIG_HAVE_KVM_IRQ_ROUTING=y
CONFIG_HAVE_KVM_EVENTFD=y
CONFIG_KVM_APIC_ARCHITECTURE=y
CONFIG_KVM_MMIO=y
CONFIG_KVM_ASYNC_PF=y
CONFIG_HAVE_KVM_MSI=y
CONFIG_HAVE_KVM_CPU_RELAX_INTERCEPT=y
CONFIG_KVM_VFIO=y
CONFIG_VIRTUALIZATION=y
CONFIG_KVM=y
CONFIG_KVM_INTEL=y
# CONFIG_KVM_AMD is not set
# CONFIG_KVM_MMU_AUDIT is not set
CONFIG_BINARY_PRINTF=y

#
# Library routines
#
CONFIG_RAID6_PQ=y
CONFIG_BITREVERSE=y
CONFIG_GENERIC_STRNCPY_FROM_USER=y
CONFIG_GENERIC_STRNLEN_USER=y
CONFIG_GENERIC_NET_UTILS=y
CONFIG_GENERIC_FIND_FIRST_BIT=y
CONFIG_GENERIC_PCI_IOMAP=y
CONFIG_GENERIC_IOMAP=y
CONFIG_GENERIC_IO=y
CONFIG_PERCPU_RWSEM=y
CONFIG_ARCH_USE_CMPXCHG_LOCKREF=y
CONFIG_CRC_CCITT=y
CONFIG_CRC16=y
CONFIG_CRC_T10DIF=y
CONFIG_CRC_ITU_T=y
CONFIG_CRC32=y
# CONFIG_CRC32_SELFTEST is not set
CONFIG_CRC32_SLICEBY8=y
# CONFIG_CRC32_SLICEBY4 is not set
# CONFIG_CRC32_SARWATE is not set
# CONFIG_CRC32_BIT is not set
# CONFIG_CRC7 is not set
CONFIG_LIBCRC32C=y
# CONFIG_CRC8 is not set
# CONFIG_RANDOM32_SELFTEST is not set
CONFIG_ZLIB_INFLATE=y
CONFIG_ZLIB_DEFLATE=y
CONFIG_LZO_COMPRESS=y
CONFIG_LZO_DECOMPRESS=y
CONFIG_LZ4_DECOMPRESS=y
CONFIG_XZ_DEC=y
CONFIG_XZ_DEC_X86=y
CONFIG_XZ_DEC_POWERPC=y
CONFIG_XZ_DEC_IA64=y
CONFIG_XZ_DEC_ARM=y
CONFIG_XZ_DEC_ARMTHUMB=y
CONFIG_XZ_DEC_SPARC=y
CONFIG_XZ_DEC_BCJ=y
# CONFIG_XZ_DEC_TEST is not set
CONFIG_DECOMPRESS_GZIP=y
CONFIG_DECOMPRESS_BZIP2=y
CONFIG_DECOMPRESS_LZMA=y
CONFIG_DECOMPRESS_XZ=y
CONFIG_DECOMPRESS_LZO=y
CONFIG_DECOMPRESS_LZ4=y
CONFIG_GENERIC_ALLOCATOR=y
CONFIG_ASSOCIATIVE_ARRAY=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT=y
CONFIG_HAS_DMA=y
CONFIG_CPU_RMAP=y
CONFIG_DQL=y
CONFIG_NLATTR=y
CONFIG_ARCH_HAS_ATOMIC64_DEC_IF_POSITIVE=y
# CONFIG_AVERAGE is not set
CONFIG_CLZ_TAB=y
# CONFIG_CORDIC is not set
# CONFIG_DDR is not set
CONFIG_MPILIB=y
CONFIG_OID_REGISTRY=y
CONFIG_UCS2_STRING=y

--ibTvN161/egqYuK8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=eabb1f89905a0c809d13ec27795ced089c107eb8

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
    231353 ~ 2%      -7.8%     213339 ~ 5%  lkp-snb01/micro/hackbench/1600%-process-pipe
    153062 ~ 0%      +3.2%     157909 ~ 0%  lkp-snb01/micro/hackbench/1600%-process-socket
    155354 ~ 0%      +3.2%     160342 ~ 0%  lkp-snb01/micro/hackbench/1600%-threads-socket
     82183 ~ 0%      -2.9%      79806 ~ 0%  xps2/micro/hackbench/1600%-process-pipe
    621954           -1.7%     611398       TOTAL hackbench.throughput

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
      4916 ~ 0%      +1.1%       4971 ~ 0%  lkp-ib03/micro/netperf/120s-200%-TCP_CRR
      4916           +1.1%       4971       TOTAL netperf.Throughput_tps

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
       409 ~10%     -91.4%         35 ~ 3%  avoton1/crypto/tcrypt/2s-505-509
       268 ~ 4%    -100.0%          0       lkp-a04/micro/netperf/120s-200%-TCP_RR
       276 ~ 3%  +6.5e+18%  1.792e+19 ~ 0%  lkp-a04/micro/netperf/120s-200%-TCP_SENDFILE
       273 ~ 5%    -100.0%          0       lkp-a04/micro/netperf/120s-200%-UDP_RR
      1691 ~56%  +1.5e+16%  2.545e+17 ~126%  lkp-ib03/micro/netperf/120s-200%-TCP_CRR
      1983 ~63%  +1.7e+16%    3.3e+17 ~75%  lkp-ib03/micro/netperf/120s-200%-TCP_STREAM
      2202 ~12%    +5e+15%  1.108e+17 ~19%  lkp-snb01/micro/hackbench/1600%-process-pipe
      2365 ~ 9%  +6.7e+15%  1.596e+17 ~25%  lkp-snb01/micro/hackbench/1600%-process-socket
    261751 ~ 8%  +9.8e+13%  2.564e+17 ~13%  lkp-snb01/micro/hackbench/1600%-threads-pipe
    289394 ~31%  +6.3e+13%  1.827e+17 ~11%  lkp-snb01/micro/hackbench/1600%-threads-socket
       189 ~ 9%  +2.9e+17%  5.462e+17 ~60%  xps2/micro/hackbench/1600%-process-pipe
    560803       +3.5e+15%  1.976e+19       TOTAL proc-vmstat.nr_tlb_remote_flush_received

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
       132 ~ 6%    -100.0%          0 ~ 0%  avoton1/crypto/tcrypt/2s-505-509
       200 ~ 6%    -100.0%          0       lkp-a04/micro/netperf/120s-200%-TCP_RR
       208 ~ 3%  +6.1e+14%   1.27e+15 ~170%  lkp-a04/micro/netperf/120s-200%-TCP_SENDFILE
       203 ~ 8%    -100.0%          0       lkp-a04/micro/netperf/120s-200%-UDP_RR
       191 ~18%  +1.9e+17%  3.542e+17 ~116%  lkp-ib03/micro/netperf/120s-200%-TCP_CRR
       221 ~23%  +9.3e+16%  2.072e+17 ~92%  lkp-ib03/micro/netperf/120s-200%-TCP_STREAM
       512 ~ 7%  +2.9e+16%  1.468e+17 ~25%  lkp-snb01/micro/hackbench/1600%-process-pipe
       751 ~ 6%  +1.9e+16%  1.424e+17 ~56%  lkp-snb01/micro/hackbench/1600%-process-socket
     21802 ~11%  +1.4e+15%  2.983e+17 ~35%  lkp-snb01/micro/hackbench/1600%-threads-pipe
     20953 ~28%  +7.1e+14%  1.478e+17 ~20%  lkp-snb01/micro/hackbench/1600%-threads-socket
        77 ~12%  +4.1e+17%  3.185e+17 ~63%  xps2/micro/hackbench/1600%-process-pipe
     45256       +3.6e+15%  1.616e+18       TOTAL proc-vmstat.nr_tlb_remote_flush

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
    268484 ~ 0%    -100.0%          0 ~ 0%  avoton1/crypto/tcrypt/2s-505-509
    106095 ~ 0%    -100.0%          0 ~ 0%  lkp-a04/micro/netperf/120s-200%-TCP_RR
    105985 ~ 0%  +1.7e+16%  1.792e+19 ~ 0%  lkp-a04/micro/netperf/120s-200%-TCP_SENDFILE
    106475 ~ 1%    -100.0%          0 ~ 0%  lkp-a04/micro/netperf/120s-200%-UDP_RR
  29191378 ~ 0%  +1.1e+12%  3.254e+17 ~118%  lkp-ib03/micro/netperf/120s-200%-TCP_CRR
    251512 ~ 1%  +1.2e+14%  2.903e+17 ~105%  lkp-ib03/micro/netperf/120s-200%-TCP_STREAM
   6265648 ~ 5%  +2.6e+12%  1.607e+17 ~32%  lkp-snb01/micro/hackbench/1600%-process-pipe
   4212742 ~ 1%  +8.5e+12%  3.583e+17 ~14%  lkp-snb01/micro/hackbench/1600%-process-socket
   1366808 ~ 1%    +2e+13%   2.71e+17 ~37%  lkp-snb01/micro/hackbench/1600%-threads-pipe
   1089219 ~ 1%  +4.4e+13%  4.775e+17 ~42%  lkp-snb01/micro/hackbench/1600%-threads-socket
   2313982 ~ 1%  +2.4e+13%  5.462e+17 ~60%  xps2/micro/hackbench/1600%-process-pipe
  45278332       +4.5e+13%  2.035e+19       TOTAL proc-vmstat.nr_tlb_local_flush_one

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
     30228 ~ 0%     -87.5%       3785 ~ 4%  avoton1/crypto/tcrypt/2s-505-509
     10864 ~ 0%     -46.5%       5810 ~ 1%  lkp-a04/micro/netperf/120s-200%-TCP_RR
     10846 ~ 0%  +9.9e+13%  1.075e+16 ~172%  lkp-a04/micro/netperf/120s-200%-TCP_SENDFILE
     10861 ~ 0%     -48.0%       5647 ~ 0%  lkp-a04/micro/netperf/120s-200%-UDP_RR
      9209 ~ 0%  +3.4e+15%  3.086e+17 ~96%  lkp-ib03/micro/netperf/120s-200%-TCP_CRR
      9049 ~ 0%    +4e+15%  3.578e+17 ~71%  lkp-ib03/micro/netperf/120s-200%-TCP_STREAM
     14750 ~ 2%  +8.5e+14%   1.26e+17 ~20%  lkp-snb01/micro/hackbench/1600%-process-pipe
     10943 ~ 3%  +1.1e+15%  1.239e+17 ~77%  lkp-snb01/micro/hackbench/1600%-process-socket
     17832 ~ 1%  +1.2e+15%  2.167e+17 ~ 6%  lkp-snb01/micro/hackbench/1600%-threads-pipe
      8973 ~ 1%  +2.6e+15%  2.326e+17 ~51%  lkp-snb01/micro/hackbench/1600%-threads-socket
      4340 ~ 0%  +7.3e+15%  3.185e+17 ~63%  xps2/micro/hackbench/1600%-process-pipe
    137898       +1.2e+15%  1.695e+18       TOTAL proc-vmstat.nr_tlb_local_flush_all

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
       130 ~ 3%     +35.7%        176 ~18%  lkp-a04/micro/netperf/120s-200%-TCP_CRR
       113 ~ 4%     +43.2%        162 ~19%  lkp-a04/micro/netperf/120s-200%-TCP_RR
       243          +39.2%        339       TOTAL uptime.idle

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
       685 ~11%     -30.2%        478 ~ 4%  xps2/micro/hackbench/1600%-process-pipe
       685          -30.2%        478       TOTAL pagetypeinfo.Node0.DMA32.Unmovable.4

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
       106 ~14%     +24.2%        132 ~15%  lkp-snb01/micro/hackbench/1600%-threads-pipe
       106          +24.2%        132       TOTAL numa-vmstat.node1.nr_written

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
    107323 ~20%     -38.1%      66462 ~ 1%  lkp-snb01/micro/hackbench/1600%-threads-pipe
     10582 ~ 8%     -14.8%       9020 ~ 5%  xps2/micro/hackbench/1600%-process-pipe
    117905          -36.0%      75483       TOTAL interrupts.IWI

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
       112 ~13%     +24.4%        140 ~15%  lkp-snb01/micro/hackbench/1600%-threads-pipe
       112          +24.4%        140       TOTAL numa-vmstat.node1.nr_dirtied

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
       921 ~10%     -27.3%        670 ~ 5%  xps2/micro/hackbench/1600%-process-pipe
       921          -27.3%        670       TOTAL buddyinfo.Node.0.zone.DMA32.4

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
      2503 ~ 3%     +22.4%       3063 ~12%  lkp-snb01/micro/hackbench/1600%-process-pipe
      2503          +22.4%       3063       TOTAL pagetypeinfo.Node0.Normal.Unmovable.0

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
  52716856 ~ 6%     -25.5%   39279457 ~13%  lkp-snb01/micro/hackbench/1600%-process-pipe
  52716856          -25.5%   39279457       TOTAL numa-numastat.node1.other_node

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
  52716864 ~ 6%     -25.5%   39279464 ~13%  lkp-snb01/micro/hackbench/1600%-process-pipe
  52716864          -25.5%   39279464       TOTAL numa-numastat.node1.numa_miss

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
  52716879 ~ 6%     -25.5%   39279438 ~13%  lkp-snb01/micro/hackbench/1600%-process-pipe
  52716879          -25.5%   39279438       TOTAL numa-numastat.node0.numa_foreign

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
       777 ~16%     -23.9%        591 ~ 1%  lkp-a04/micro/netperf/120s-200%-TCP_RR
       725 ~17%     +19.0%        862 ~13%  lkp-a04/micro/netperf/120s-200%-TCP_SENDFILE
      1502           -3.2%       1454       TOTAL slabinfo.proc_inode_cache.num_objs

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
       767 ~17%     -22.9%        591 ~ 1%  lkp-a04/micro/netperf/120s-200%-TCP_RR
       712 ~17%     +21.1%        862 ~13%  lkp-a04/micro/netperf/120s-200%-TCP_SENDFILE
      1479           -1.7%       1454       TOTAL slabinfo.proc_inode_cache.active_objs

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
      1684 ~ 6%     -21.1%       1329 ~ 4%  xps2/micro/hackbench/1600%-process-pipe
      1684          -21.1%       1329       TOTAL pagetypeinfo.Node0.DMA32.Unmovable.3

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
  26518589 ~ 6%     -26.1%   19610310 ~12%  lkp-snb01/micro/hackbench/1600%-process-pipe
  26518589          -26.1%   19610310       TOTAL numa-vmstat.node1.numa_other

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
      9839 ~20%     +33.7%      13155 ~11%  lkp-a04/micro/netperf/120s-200%-UDP_RR
     12772 ~16%     +19.7%      15284 ~ 7%  lkp-ib03/micro/netperf/120s-200%-TCP_CRR
  22161698 ~ 9%     +19.4%   26471094 ~ 6%  lkp-snb01/micro/hackbench/1600%-process-socket
  18580162 ~ 9%     +43.8%   26722959 ~23%  lkp-snb01/micro/hackbench/1600%-threads-socket
  40764472          +30.6%   53222493       TOTAL interrupts.RES

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
  26428479 ~ 6%     -26.0%   19563337 ~12%  lkp-snb01/micro/hackbench/1600%-process-pipe
  26428479          -26.0%   19563337       TOTAL numa-vmstat.node0.numa_foreign

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
  26436285 ~ 6%     -26.0%   19569200 ~12%  lkp-snb01/micro/hackbench/1600%-process-pipe
  26436285          -26.0%   19569200       TOTAL numa-vmstat.node1.numa_miss

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
       413 ~ 6%     +21.3%        501 ~ 4%  lkp-snb01/micro/hackbench/1600%-process-pipe
       413          +21.3%        501       TOTAL pagetypeinfo.Node1.Normal.Unmovable.5

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
      3829 ~10%     -14.7%       3265 ~12%  avoton1/crypto/tcrypt/2s-200-204
      3829          -14.7%       3265       TOTAL slabinfo.kmalloc-128.active_objs

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
      3856 ~10%     -14.0%       3316 ~12%  avoton1/crypto/tcrypt/2s-200-204
      3856          -14.0%       3316       TOTAL slabinfo.kmalloc-128.num_objs

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
       609 ~ 4%     -20.7%        483 ~ 3%  xps2/micro/hackbench/1600%-process-pipe
       609          -20.7%        483       TOTAL buddyinfo.Node.0.zone.Normal.0

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
       545 ~ 7%     +15.0%        627 ~ 5%  lkp-snb01/micro/hackbench/1600%-process-pipe
       545          +15.0%        627       TOTAL buddyinfo.Node.1.zone.Normal.5

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
     53127 ~ 6%     -10.7%      47442 ~ 6%  avoton1/crypto/tcrypt/2s-500-504
     36171 ~ 4%     +19.2%      43113 ~11%  lkp-a04/micro/netperf/120s-200%-TCP_RR
     89298           +1.4%      90555       TOTAL softirqs.RCU

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
       856 ~ 3%     +17.4%       1005 ~ 5%  lkp-snb01/micro/hackbench/1600%-process-pipe
       856          +17.4%       1005       TOTAL pagetypeinfo.Node0.DMA32.Unmovable.0

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
      3209 ~ 3%     +19.7%       3840 ~ 7%  lkp-snb01/micro/hackbench/1600%-process-pipe
      3209          +19.7%       3840       TOTAL buddyinfo.Node.1.zone.Normal.0

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
       627 ~ 3%     +13.1%        710 ~ 8%  lkp-snb01/micro/hackbench/1600%-process-pipe
       627          +13.1%        710       TOTAL pagetypeinfo.Node0.Normal.Movable.2

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
       585 ~ 6%     +13.8%        666 ~ 9%  lkp-snb01/micro/hackbench/1600%-process-pipe
      2180 ~ 7%     -18.7%       1773 ~ 2%  xps2/micro/hackbench/1600%-process-pipe
      2765          -11.8%       2439       TOTAL buddyinfo.Node.0.zone.DMA32.3

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
       616 ~ 4%     +16.1%        716 ~ 4%  lkp-snb01/micro/hackbench/1600%-process-pipe
       616          +16.1%        716       TOTAL pagetypeinfo.Node1.Normal.Movable.2

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
      1574 ~ 1%     -11.4%       1395 ~ 8%  lkp-a04/micro/netperf/120s-200%-TCP_CRR
      1574          -11.4%       1395       TOTAL slabinfo.kmalloc-256.num_objs

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
  75095890 ~ 1%     -14.1%   64497421 ~ 9%  lkp-snb01/micro/hackbench/1600%-process-pipe
  75095890          -14.1%   64497421       TOTAL proc-vmstat.numa_miss

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
  75095891 ~ 1%     -14.1%   64497437 ~ 9%  lkp-snb01/micro/hackbench/1600%-process-pipe
  75095891          -14.1%   64497437       TOTAL proc-vmstat.numa_other

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
  75095926 ~ 1%     -14.1%   64497614 ~ 9%  lkp-snb01/micro/hackbench/1600%-process-pipe
  75095926          -14.1%   64497614       TOTAL proc-vmstat.numa_foreign

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
       738 ~ 5%     +22.4%        904 ~ 4%  lkp-snb01/micro/hackbench/1600%-process-pipe
       738          +22.4%        904       TOTAL pagetypeinfo.Node1.Normal.Movable.0

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
     73344 ~ 0%     +12.7%      82638 ~ 7%  lkp-a04/micro/netperf/120s-200%-TCP_CRR
     73344          +12.7%      82638       TOTAL softirqs.TIMER

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
      1138 ~ 3%     +13.9%       1296 ~ 6%  lkp-snb01/micro/hackbench/1600%-process-pipe
      1138          +13.9%       1296       TOTAL buddyinfo.Node.0.zone.DMA32.0

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
     25786 ~ 6%     +17.7%      30357 ~ 3%  xps2/micro/hackbench/1600%-process-pipe
     25786          +17.7%      30357       TOTAL proc-vmstat.nr_page_table_pages

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
       726 ~ 4%     +19.4%        867 ~ 3%  lkp-snb01/micro/hackbench/1600%-process-pipe
       726          +19.4%        867       TOTAL pagetypeinfo.Node1.Normal.Movable.1

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
      2520 ~ 4%     +17.3%       2956 ~ 7%  lkp-snb01/micro/hackbench/1600%-process-pipe
      2520          +17.3%       2956       TOTAL pagetypeinfo.Node1.Normal.Unmovable.0

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
      3842 ~ 4%     -17.0%       3189 ~ 7%  lkp-a04/micro/netperf/120s-200%-TCP_CRR
      4536 ~ 6%     -11.3%       4024 ~ 1%  lkp-ib03/micro/netperf/120s-200%-TCP_CRR
      8378          -13.9%       7213       TOTAL proc-vmstat.nr_alloc_batch

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
    103132 ~ 2%     +18.8%     122485 ~ 4%  xps2/micro/hackbench/1600%-process-pipe
    103132          +18.8%     122485       TOTAL meminfo.PageTables

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
      1484 ~ 1%     -10.1%       1335 ~ 6%  lkp-a04/micro/netperf/120s-200%-TCP_CRR
      1484          -10.1%       1335       TOTAL slabinfo.kmalloc-256.active_objs

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
      2985 ~ 9%     -13.6%       2579 ~ 4%  lkp-a04/micro/netperf/120s-200%-UDP_RR
     47636 ~ 3%     +12.7%      53700 ~ 1%  xps2/micro/hackbench/1600%-process-pipe
     50621          +11.2%      56279       TOTAL slabinfo.anon_vma.active_objs

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
      1337 ~ 7%      +9.9%       1469 ~ 5%  lkp-snb01/micro/hackbench/1600%-process-pipe
      1337           +9.9%       1469       TOTAL buddyinfo.Node.1.zone.Normal.4

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
       159 ~ 0%     +10.7%        177 ~ 6%  lkp-a04/micro/netperf/120s-200%-TCP_CRR
       155 ~ 0%     +11.3%        173 ~ 6%  lkp-a04/micro/netperf/120s-200%-TCP_RR
       315          +11.0%        350       TOTAL uptime.boot

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
      2585 ~ 5%      +9.7%       2837 ~ 4%  lkp-snb01/micro/hackbench/1600%-process-pipe
      2585           +9.7%       2837       TOTAL buddyinfo.Node.1.zone.Normal.3

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
      1075 ~ 5%     +10.2%       1185 ~ 4%  lkp-snb01/micro/hackbench/1600%-process-pipe
      1075          +10.2%       1185       TOTAL pagetypeinfo.Node0.DMA32.Unmovable.1

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
     76291 ~ 3%     +15.7%      88274 ~ 1%  xps2/micro/hackbench/1600%-process-pipe
     76291          +15.7%      88274       TOTAL slabinfo.vm_area_struct.num_objs

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
      3467 ~ 3%     +15.7%       4012 ~ 1%  xps2/micro/hackbench/1600%-process-pipe
      3467          +15.7%       4012       TOTAL slabinfo.vm_area_struct.active_slabs

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
      3467 ~ 3%     +15.7%       4012 ~ 1%  xps2/micro/hackbench/1600%-process-pipe
      3467          +15.7%       4012       TOTAL slabinfo.vm_area_struct.num_slabs

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
      2985 ~ 9%     -13.6%       2579 ~ 4%  lkp-a04/micro/netperf/120s-200%-UDP_RR
     61060 ~ 3%     +11.0%      67777 ~ 0%  xps2/micro/hackbench/1600%-process-pipe
     64046           +9.9%      70356       TOTAL slabinfo.anon_vma.num_objs

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
      1353 ~ 5%      +9.8%       1486 ~ 6%  lkp-snb01/micro/hackbench/1600%-process-pipe
      1353           +9.8%       1486       TOTAL buddyinfo.Node.0.zone.DMA32.1

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
      1958 ~ 5%     +10.7%       2168 ~ 5%  lkp-snb01/micro/hackbench/1600%-process-pipe
      1958          +10.7%       2168       TOTAL buddyinfo.Node.0.zone.Normal.3

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
     68634 ~ 3%     +15.7%      79397 ~ 2%  xps2/micro/hackbench/1600%-process-pipe
     68634          +15.7%      79397       TOTAL slabinfo.vm_area_struct.active_objs

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
      3131 ~ 4%      +9.6%       3431 ~ 5%  lkp-snb01/micro/hackbench/1600%-process-pipe
      3131           +9.6%       3431       TOTAL buddyinfo.Node.0.zone.Normal.2

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
     35163 ~ 5%     +15.4%      40566 ~ 2%  xps2/micro/hackbench/1600%-process-pipe
     35163          +15.4%      40566       TOTAL proc-vmstat.nr_anon_pages

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
      1782 ~ 3%     +13.8%       2028 ~ 1%  xps2/micro/hackbench/1600%-process-pipe
      1782          +13.8%       2028       TOTAL slabinfo.kmalloc-64.active_slabs

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
      1782 ~ 3%     +13.8%       2028 ~ 1%  xps2/micro/hackbench/1600%-process-pipe
      1782          +13.8%       2028       TOTAL slabinfo.kmalloc-64.num_slabs

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
    114104 ~ 3%     +13.8%     129818 ~ 1%  xps2/micro/hackbench/1600%-process-pipe
    114104          +13.8%     129818       TOTAL slabinfo.kmalloc-64.num_objs

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
     35463 ~ 5%     +15.2%      40850 ~ 2%  xps2/micro/hackbench/1600%-process-pipe
     35463          +15.2%      40850       TOTAL proc-vmstat.nr_active_anon

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
    140672 ~ 1%     +16.4%     163747 ~ 2%  xps2/micro/hackbench/1600%-process-pipe
    140672          +16.4%     163747       TOTAL meminfo.AnonPages

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
     94657 ~ 3%     +14.4%     108326 ~ 1%  xps2/micro/hackbench/1600%-process-pipe
     94657          +14.4%     108326       TOTAL slabinfo.kmalloc-64.active_objs

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
       945 ~ 6%     +11.2%       1051 ~ 5%  lkp-snb01/micro/hackbench/1600%-process-pipe
      3842 ~ 4%      -9.3%       3487 ~ 0%  xps2/micro/hackbench/1600%-process-pipe
      4788           -5.2%       4538       TOTAL buddyinfo.Node.0.zone.DMA32.2

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
       172 ~ 5%      -6.4%        161 ~ 4%  xps2/micro/hackbench/1600%-process-pipe
       172           -6.4%        161       TOTAL proc-vmstat.nr_written

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
    141872 ~ 1%     +16.1%     164766 ~ 2%  xps2/micro/hackbench/1600%-process-pipe
    141872          +16.1%     164766       TOTAL meminfo.Active(anon)

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
    160912 ~ 5%      -9.1%     146302 ~ 5%  lkp-ib03/micro/netperf/120s-200%-TCP_STREAM
   1162879 ~ 2%     +18.7%    1380217 ~ 3%  xps2/micro/hackbench/1600%-process-pipe
   1323791          +15.3%    1526519       TOTAL meminfo.Committed_AS

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
       746 ~ 5%     +11.9%        834 ~ 3%  lkp-snb01/micro/hackbench/1600%-process-pipe
      2955 ~ 4%     -12.4%       2590 ~ 3%  xps2/micro/hackbench/1600%-process-pipe
      3701           -7.5%       3424       TOTAL pagetypeinfo.Node0.DMA32.Unmovable.2

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
    145444 ~ 1%     +15.7%     168230 ~ 2%  xps2/micro/hackbench/1600%-process-pipe
    145444          +15.7%     168230       TOTAL meminfo.Active

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
  61345506 ~ 6%     -14.1%   52691612 ~ 7%  lkp-snb01/micro/hackbench/1600%-process-pipe
  61345506          -14.1%   52691612       TOTAL numa-vmstat.node0.numa_local

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
     37413 ~ 4%     -13.1%      32495 ~ 5%  avoton1/crypto/tcrypt/2s-200-204
     37413          -13.1%      32495       TOTAL meminfo.DirectMap4k

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
  61378936 ~ 6%     -14.0%   52766301 ~ 7%  lkp-snb01/micro/hackbench/1600%-process-pipe
  61378936          -14.0%   52766301       TOTAL numa-vmstat.node0.numa_hit

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
      3756 ~ 5%      +7.4%       4036 ~ 3%  lkp-snb01/micro/hackbench/1600%-process-pipe
      3756           +7.4%       4036       TOTAL buddyinfo.Node.1.zone.Normal.2

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
      3169 ~ 3%     +12.3%       3560 ~ 5%  lkp-ib03/micro/netperf/120s-200%-TCP_STREAM
      3169          +12.3%       3560       TOTAL slabinfo.task_xstate.active_objs

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
      3169 ~ 3%     +12.3%       3560 ~ 5%  lkp-ib03/micro/netperf/120s-200%-TCP_STREAM
      3169          +12.3%       3560       TOTAL slabinfo.task_xstate.num_objs

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
      2305 ~ 4%      -6.8%       2148 ~ 5%  lkp-a04/micro/netperf/120s-200%-TCP_CRR
     23997 ~ 7%     +10.2%      26445 ~ 5%  lkp-snb01/micro/hackbench/1600%-threads-pipe
      4002 ~ 2%      -6.6%       3737 ~ 3%  nhm8/micro/dbench/100%
     30304           +6.7%      32330       TOTAL slabinfo.kmalloc-192.num_objs

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
   1.2e+08 ~ 3%     -12.6%  1.048e+08 ~ 7%  lkp-snb01/micro/hackbench/1600%-process-pipe
   5689883 ~ 3%      +7.8%    6135367 ~ 1%  lkp-snb01/micro/hackbench/1600%-process-socket
 1.257e+08          -11.7%   1.11e+08       TOTAL numa-numastat.node0.local_node

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
   1.2e+08 ~ 3%     -12.6%  1.048e+08 ~ 7%  lkp-snb01/micro/hackbench/1600%-process-pipe
   5689883 ~ 3%      +7.8%    6135379 ~ 1%  lkp-snb01/micro/hackbench/1600%-process-socket
 1.257e+08          -11.7%   1.11e+08       TOTAL numa-numastat.node0.numa_hit

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
    475180 ~ 2%      +8.1%     513474 ~ 3%  lkp-snb01/micro/hackbench/1600%-threads-socket
    475180           +8.1%     513474       TOTAL numa-vmstat.node0.numa_miss

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
    475243 ~ 2%      +8.1%     513568 ~ 3%  lkp-snb01/micro/hackbench/1600%-threads-socket
    475243           +8.1%     513568       TOTAL numa-vmstat.node1.numa_foreign

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
      1895 ~ 3%      -7.4%       1755 ~ 5%  avoton1/crypto/tcrypt/2s-505-509
      1895           -7.4%       1755       TOTAL slabinfo.kmalloc-512.num_objs

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
      3899 ~ 4%      +9.0%       4251 ~ 4%  lkp-snb01/micro/hackbench/1600%-process-pipe
      3899           +9.0%       4251       TOTAL pagetypeinfo.Node0.Normal.Unmovable.1

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
      2281 ~ 5%      -7.8%       2102 ~ 7%  lkp-a04/micro/netperf/120s-200%-TCP_CRR
     23836 ~ 7%     +10.2%      26268 ~ 5%  lkp-snb01/micro/hackbench/1600%-threads-pipe
      4002 ~ 2%      -6.6%       3737 ~ 3%  nhm8/micro/dbench/100%
     30119           +6.6%      32108       TOTAL slabinfo.kmalloc-192.active_objs

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
       953 ~ 3%     +11.0%       1058 ~ 0%  xps2/micro/hackbench/1600%-process-pipe
       953          +11.0%       1058       TOTAL slabinfo.anon_vma.num_slabs

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
       953 ~ 3%     +11.0%       1058 ~ 0%  xps2/micro/hackbench/1600%-process-pipe
       953          +11.0%       1058       TOTAL slabinfo.anon_vma.active_slabs

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
      1822 ~ 3%      -7.0%       1695 ~ 5%  avoton1/crypto/tcrypt/2s-505-509
      1822           -7.0%       1695       TOTAL slabinfo.kmalloc-512.active_objs

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
      2507 ~ 4%      +8.9%       2731 ~ 2%  lkp-snb01/micro/hackbench/1600%-process-pipe
      2507           +8.9%       2731       TOTAL pagetypeinfo.Node0.Normal.Unmovable.2

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
    284.98 ~ 0%      +1.3%     288.80 ~ 0%  avoton1/crypto/tcrypt/2s-200-204
    285.83 ~ 1%      -1.4%     281.86 ~ 0%  avoton1/crypto/tcrypt/2s-205-210
    105.26 ~ 5%     +44.4%     152.00 ~21%  lkp-a04/micro/netperf/120s-200%-TCP_CRR
    104.14 ~ 4%     +46.6%     152.67 ~20%  lkp-a04/micro/netperf/120s-200%-TCP_RR
    719.99 ~ 1%      -4.0%     691.07 ~ 0%  lkp-snb01/micro/hackbench/1600%-process-pipe
    704.05 ~ 2%      +3.4%     728.26 ~ 1%  lkp-snb01/micro/hackbench/1600%-threads-pipe
   2204.24           +4.1%    2294.67       TOTAL boottime.idle

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
     39.75 ~ 0%      +1.2%      40.24 ~ 0%  avoton1/crypto/tcrypt/2s-200-204
     39.85 ~ 1%      -1.3%      39.33 ~ 0%  avoton1/crypto/tcrypt/2s-205-210
     32.93 ~ 4%     +50.3%      49.48 ~23%  lkp-a04/micro/netperf/120s-200%-TCP_CRR
     32.63 ~ 3%     +52.1%      49.61 ~22%  lkp-a04/micro/netperf/120s-200%-TCP_RR
     27.55 ~ 1%      -4.2%      26.39 ~ 0%  lkp-snb01/micro/hackbench/1600%-process-pipe
     26.96 ~ 0%      +3.4%      27.87 ~ 0%  lkp-snb01/micro/hackbench/1600%-threads-pipe
     16.86 ~ 1%      -1.9%      16.54 ~ 1%  nhm8/micro/dbench/100%
    216.53          +15.2%     249.46       TOTAL boottime.boot

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
 6.555e+08 ~ 2%      +8.0%  7.077e+08 ~ 5%  lkp-snb01/micro/hackbench/1600%-process-pipe
  45683455 ~ 6%     +19.7%   54686717 ~ 3%  lkp-snb01/micro/hackbench/1600%-process-socket
  10457165 ~ 5%     +44.2%   15074518 ~ 4%  xps2/micro/hackbench/1600%-process-pipe
 7.116e+08           +9.2%  7.775e+08       TOTAL time.involuntary_context_switches

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
         4 ~14%     +42.9%          6 ~ 0%  avoton1/crypto/tcrypt/2s-205-210
      2839 ~ 0%      -0.8%       2817 ~ 0%  lkp-snb01/micro/hackbench/1600%-process-socket
      3120 ~ 0%      -0.3%       3110 ~ 0%  lkp-snb01/micro/hackbench/1600%-threads-socket
      5964           -0.5%       5934       TOTAL time.percent_of_cpu_this_job_got

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
     28.51 ~ 1%      +2.1%      29.11 ~ 1%  avoton1/crypto/tcrypt/2s-200-204
     28.62 ~ 1%      -1.7%      28.14 ~ 0%  avoton1/crypto/tcrypt/2s-205-210
     24.40 ~ 2%      +0.1%      24.42 ~ 0%  grantley/micro/kbuild/200%
     18.89 ~ 0%     +65.5%      31.26 ~27%  lkp-a04/micro/netperf/120s-200%-TCP_RR
     18.69 ~ 2%      -6.6%      17.45 ~ 0%  lkp-snb01/micro/hackbench/1600%-process-pipe
     18.05 ~ 1%      +5.2%      18.99 ~ 1%  lkp-snb01/micro/hackbench/1600%-threads-pipe
      7.51 ~11%      -3.7%       7.23 ~ 0%  xps2/micro/hackbench/1600%-process-pipe
    144.66           +8.3%     156.61       TOTAL boottime.dhcp

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
      2248 ~ 1%      -3.9%       2161 ~ 1%  lkp-snb01/micro/hackbench/1600%-process-pipe
      1690 ~ 0%     -18.1%       1384 ~ 0%  lkp-snb01/micro/hackbench/1600%-process-socket
      1584 ~ 0%      -5.0%       1505 ~ 0%  lkp-snb01/micro/hackbench/1600%-threads-pipe
      1642 ~ 0%     -19.0%       1330 ~ 1%  lkp-snb01/micro/hackbench/1600%-threads-socket
       730 ~ 0%      +3.2%        753 ~ 0%  xps2/micro/hackbench/1600%-process-pipe
      7895           -9.6%       7136       TOTAL time.user_time

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
     40.18 ~12%     +34.2%      53.94 ~ 2%  avoton1/crypto/tcrypt/2s-205-210
  15681.97 ~ 0%      +3.1%   16160.28 ~ 0%  lkp-snb01/micro/hackbench/1600%-process-socket
  17034.21 ~ 0%      +1.6%   17314.78 ~ 0%  lkp-snb01/micro/hackbench/1600%-threads-pipe
   3471.89 ~ 0%      -1.5%    3418.90 ~ 0%  xps2/micro/hackbench/1600%-process-pipe
  36228.25           +2.0%   36947.89       TOTAL time.system_time

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
   1791178 ~ 0%      +1.1%    1811656 ~ 0%  lkp-ib03/micro/netperf/120s-200%-TCP_CRR
    597537 ~ 3%      +9.2%     652375 ~ 2%  lkp-snb01/micro/hackbench/1600%-process-socket
    528539 ~ 2%      +9.9%     581079 ~ 4%  lkp-snb01/micro/hackbench/1600%-threads-socket
    122230 ~ 2%     +22.4%     149616 ~ 1%  xps2/micro/hackbench/1600%-process-pipe
   3039486           +5.1%    3194728       TOTAL vmstat.system.cs

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
      1103 ~ 1%      +3.3%       1140 ~ 1%  lkp-a04/micro/netperf/120s-200%-UDP_RR
     11480 ~ 0%      +0.2%      11502 ~ 0%  lkp-ib03/micro/netperf/120s-200%-TCP_CRR
     43851 ~ 7%     +14.2%      50073 ~ 5%  lkp-snb01/micro/hackbench/1600%-process-socket
   1370529 ~ 0%      +2.6%    1406534 ~ 0%  lkp-snb01/micro/hackbench/1600%-threads-pipe
     38956 ~ 7%     +35.2%      52666 ~20%  lkp-snb01/micro/hackbench/1600%-threads-socket
   1465920           +3.8%    1521916       TOTAL vmstat.system.in

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
    298932 ~ 1%      -1.4%     294844 ~ 0%  grantley/micro/kbuild/200%
 3.017e+08 ~ 2%      +9.6%  3.307e+08 ~ 1%  lkp-snb01/micro/hackbench/1600%-process-socket
 2.318e+09 ~ 0%      +1.5%  2.354e+09 ~ 0%  lkp-snb01/micro/hackbench/1600%-threads-pipe
 2.768e+08 ~ 1%      +8.0%   2.99e+08 ~ 2%  lkp-snb01/micro/hackbench/1600%-threads-socket
  63163410 ~ 2%     +18.0%   74521593 ~ 0%  xps2/micro/hackbench/1600%-process-pipe
  2.96e+09           +3.3%  3.058e+09       TOTAL time.voluntary_context_switches

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
  50750958 ~ 2%      -7.1%   47164538 ~ 5%  lkp-snb01/micro/hackbench/1600%-process-pipe
  33899807 ~ 0%      +4.4%   35395421 ~ 0%  lkp-snb01/micro/hackbench/1600%-process-socket
   1101815 ~ 0%      +2.7%    1131176 ~ 1%  lkp-snb01/micro/hackbench/1600%-threads-socket
  19183273 ~ 0%      -3.7%   18467806 ~ 0%  xps2/micro/hackbench/1600%-process-pipe
 104935855           -2.6%  102158942       TOTAL time.minor_page_faults

      v3.13-rc4       eabb1f89905a0c809d13  
---------------  -------------------------  
       125 ~ 0%      +0.1%        125 ~ 0%  lkp-a04/micro/netperf/120s-200%-TCP_CRR
       121 ~ 0%      +0.0%        121 ~ 0%  lkp-a04/micro/netperf/120s-200%-TCP_RR
       611 ~ 0%      +1.8%        622 ~ 0%  lkp-snb01/micro/hackbench/1600%-process-socket
       607 ~ 0%      -0.9%        602 ~ 0%  xps2/micro/hackbench/1600%-process-pipe
      1465           +0.4%       1471       TOTAL time.elapsed_time


--ibTvN161/egqYuK8--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
