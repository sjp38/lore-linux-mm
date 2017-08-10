Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id C69416B0292
	for <linux-mm@kvack.org>; Thu, 10 Aug 2017 00:13:55 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id k190so84756072pge.9
        for <linux-mm@kvack.org>; Wed, 09 Aug 2017 21:13:55 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id v6si1959103plg.1000.2017.08.09.21.13.53
        for <linux-mm@kvack.org>;
        Wed, 09 Aug 2017 21:13:54 -0700 (PDT)
Date: Thu, 10 Aug 2017 13:13:53 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [lkp-robot] [mm]  7674270022:  will-it-scale.per_process_ops
 -19.3% regression
Message-ID: <20170810041353.GB2042@bbox>
References: <20170802000818.4760-7-namit@vmware.com>
 <20170808011923.GE25554@yexl-desktop>
 <20170808022830.GA28570@bbox>
 <93CA4B47-95C2-43A2-8E92-B142CAB1DAF7@gmail.com>
 <970B5DC5-BFC2-461E-AC46-F71B3691D301@gmail.com>
 <20170808080821.GA31730@bbox>
 <20170809025902.GA17616@yexl-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170809025902.GA17616@yexl-desktop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ye Xiaolong <xiaolong.ye@intel.com>
Cc: Nadav Amit <nadav.amit@gmail.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, Russell King <linux@armlinux.org.uk>, Tony Luck <tony.luck@intel.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, "David S. Miller" <davem@davemloft.net>, Heiko Carstens <heiko.carstens@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Jeff Dike <jdike@addtoit.com>, linux-arch@vger.kernel.org, lkp@01.org

On Wed, Aug 09, 2017 at 10:59:02AM +0800, Ye Xiaolong wrote:
> On 08/08, Minchan Kim wrote:
> >On Mon, Aug 07, 2017 at 10:51:00PM -0700, Nadav Amit wrote:
> >> Nadav Amit <nadav.amit@gmail.com> wrote:
> >> 
> >> > Minchan Kim <minchan@kernel.org> wrote:
> >> > 
> >> >> Hi,
> >> >> 
> >> >> On Tue, Aug 08, 2017 at 09:19:23AM +0800, kernel test robot wrote:
> >> >>> Greeting,
> >> >>> 
> >> >>> FYI, we noticed a -19.3% regression of will-it-scale.per_process_ops due to commit:
> >> >>> 
> >> >>> 
> >> >>> commit: 76742700225cad9df49f05399381ac3f1ec3dc60 ("mm: fix MADV_[FREE|DONTNEED] TLB flush miss problem")
> >> >>> url: https://github.com/0day-ci/linux/commits/Nadav-Amit/mm-migrate-prevent-racy-access-to-tlb_flush_pending/20170802-205715
> >> >>> 
> >> >>> 
> >> >>> in testcase: will-it-scale
> >> >>> on test machine: 88 threads Intel(R) Xeon(R) CPU E5-2699 v4 @ 2.20GHz with 64G memory
> >> >>> with following parameters:
> >> >>> 
> >> >>> 	nr_task: 16
> >> >>> 	mode: process
> >> >>> 	test: brk1
> >> >>> 	cpufreq_governor: performance
> >> >>> 
> >> >>> test-description: Will It Scale takes a testcase and runs it from 1 through to n parallel copies to see if the testcase will scale. It builds both a process and threads based test in order to see any differences between the two.
> >> >>> test-url: https://github.com/antonblanchard/will-it-scale
> >> >> 
> >> >> Thanks for the report.
> >> >> Could you explain what kinds of workload you are testing?
> >> >> 
> >> >> Does it calls frequently madvise(MADV_DONTNEED) in parallel on multiple
> >> >> threads?
> >> > 
> >> > According to the description it is "testcase:brk increase/decrease of one
> >> > pagea??. According to the mode it spawns multiple processes, not threads.
> >> > 
> >> > Since a single page is unmapped each time, and the iTLB-loads increase
> >> > dramatically, I would suspect that for some reason a full TLB flush is
> >> > caused during do_munmap().
> >> > 
> >> > If I find some free time, Ia??ll try to profile the workload - but feel free
> >> > to beat me to it.
> >> 
> >> The root-cause appears to be that tlb_finish_mmu() does not call
> >> dec_tlb_flush_pending() - as it should. Any chance you can take care of it?
> >
> >Oops, but with second looking, it seems it's not my fault. ;-)
> >https://marc.info/?l=linux-mm&m=150156699114088&w=2
> >
> >Anyway, thanks for the pointing out.
> >xiaolong.ye, could you retest with this fix?
> >
> 
> I've queued tests for 5 times and results show this patch (e8f682574e4 "mm:
> decrease tlb flush pending count in tlb_finish_mmu") does help recover the
> performance back.
> 
> 378005bdbac0a2ec  76742700225cad9df49f053993  e8f682574e45b6406dadfffeb4  
> ----------------  --------------------------  --------------------------  
>          %stddev      change         %stddev      change         %stddev
>              \          |                \          |                \  
>    3405093             -19%    2747088              -2%    3348752        will-it-scale.per_process_ops
>       1280 A+-  3%        -2%       1257 A+-  3%        -6%       1207        vmstat.system.cs
>       2702 A+- 18%        11%       3002 A+- 19%        17%       3156 A+- 18%  numa-vmstat.node0.nr_mapped
>      10765 A+- 18%        11%      11964 A+- 19%        17%      12588 A+- 18%  numa-meminfo.node0.Mapped
>       0.00 A+- 47%       -40%       0.00 A+- 45%       -84%       0.00 A+- 42%  mpstat.cpu.soft%
> 
> Thanks,
> Xiaolong

Thanks for the testing!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
