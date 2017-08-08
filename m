Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id C3D086B025F
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 04:08:25 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id w187so27757070pgb.10
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 01:08:25 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id 3si555253plm.81.2017.08.08.01.08.23
        for <linux-mm@kvack.org>;
        Tue, 08 Aug 2017 01:08:24 -0700 (PDT)
Date: Tue, 8 Aug 2017 17:08:21 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [lkp-robot] [mm]  7674270022:  will-it-scale.per_process_ops
 -19.3% regression
Message-ID: <20170808080821.GA31730@bbox>
References: <20170802000818.4760-7-namit@vmware.com>
 <20170808011923.GE25554@yexl-desktop>
 <20170808022830.GA28570@bbox>
 <93CA4B47-95C2-43A2-8E92-B142CAB1DAF7@gmail.com>
 <970B5DC5-BFC2-461E-AC46-F71B3691D301@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <970B5DC5-BFC2-461E-AC46-F71B3691D301@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <nadav.amit@gmail.com>
Cc: kernel test robot <xiaolong.ye@intel.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, Russell King <linux@armlinux.org.uk>, Tony Luck <tony.luck@intel.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, "David S. Miller" <davem@davemloft.net>, Heiko Carstens <heiko.carstens@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Jeff Dike <jdike@addtoit.com>, linux-arch@vger.kernel.org, lkp@01.org

On Mon, Aug 07, 2017 at 10:51:00PM -0700, Nadav Amit wrote:
> Nadav Amit <nadav.amit@gmail.com> wrote:
> 
> > Minchan Kim <minchan@kernel.org> wrote:
> > 
> >> Hi,
> >> 
> >> On Tue, Aug 08, 2017 at 09:19:23AM +0800, kernel test robot wrote:
> >>> Greeting,
> >>> 
> >>> FYI, we noticed a -19.3% regression of will-it-scale.per_process_ops due to commit:
> >>> 
> >>> 
> >>> commit: 76742700225cad9df49f05399381ac3f1ec3dc60 ("mm: fix MADV_[FREE|DONTNEED] TLB flush miss problem")
> >>> url: https://github.com/0day-ci/linux/commits/Nadav-Amit/mm-migrate-prevent-racy-access-to-tlb_flush_pending/20170802-205715
> >>> 
> >>> 
> >>> in testcase: will-it-scale
> >>> on test machine: 88 threads Intel(R) Xeon(R) CPU E5-2699 v4 @ 2.20GHz with 64G memory
> >>> with following parameters:
> >>> 
> >>> 	nr_task: 16
> >>> 	mode: process
> >>> 	test: brk1
> >>> 	cpufreq_governor: performance
> >>> 
> >>> test-description: Will It Scale takes a testcase and runs it from 1 through to n parallel copies to see if the testcase will scale. It builds both a process and threads based test in order to see any differences between the two.
> >>> test-url: https://github.com/antonblanchard/will-it-scale
> >> 
> >> Thanks for the report.
> >> Could you explain what kinds of workload you are testing?
> >> 
> >> Does it calls frequently madvise(MADV_DONTNEED) in parallel on multiple
> >> threads?
> > 
> > According to the description it is "testcase:brk increase/decrease of one
> > pagea??. According to the mode it spawns multiple processes, not threads.
> > 
> > Since a single page is unmapped each time, and the iTLB-loads increase
> > dramatically, I would suspect that for some reason a full TLB flush is
> > caused during do_munmap().
> > 
> > If I find some free time, Ia??ll try to profile the workload - but feel free
> > to beat me to it.
> 
> The root-cause appears to be that tlb_finish_mmu() does not call
> dec_tlb_flush_pending() - as it should. Any chance you can take care of it?

Oops, but with second looking, it seems it's not my fault. ;-)
https://marc.info/?l=linux-mm&m=150156699114088&w=2

Anyway, thanks for the pointing out.
xiaolong.ye, could you retest with this fix?
