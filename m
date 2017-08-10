Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id D9F726B0292
	for <linux-mm@kvack.org>; Thu, 10 Aug 2017 00:20:42 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id r13so82470839pfd.14
        for <linux-mm@kvack.org>; Wed, 09 Aug 2017 21:20:42 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id f22si3837462plk.492.2017.08.09.21.20.41
        for <linux-mm@kvack.org>;
        Wed, 09 Aug 2017 21:20:41 -0700 (PDT)
Date: Thu, 10 Aug 2017 13:20:40 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [lkp-robot] [mm]  7674270022:  will-it-scale.per_process_ops
 -19.3% regression
Message-ID: <20170810042040.GA2249@bbox>
References: <20170802000818.4760-7-namit@vmware.com>
 <20170808011923.GE25554@yexl-desktop>
 <20170808022830.GA28570@bbox>
 <93CA4B47-95C2-43A2-8E92-B142CAB1DAF7@gmail.com>
 <970B5DC5-BFC2-461E-AC46-F71B3691D301@gmail.com>
 <20170808080821.GA31730@bbox>
 <20170809025902.GA17616@yexl-desktop>
 <20170810041353.GB2042@bbox>
 <80589593-6F0E-4421-9279-681D5B388100@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <80589593-6F0E-4421-9279-681D5B388100@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <nadav.amit@gmail.com>
Cc: Ye Xiaolong <xiaolong.ye@intel.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, Russell King <linux@armlinux.org.uk>, Tony Luck <tony.luck@intel.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, "David S. Miller" <davem@davemloft.net>, Heiko Carstens <heiko.carstens@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Jeff Dike <jdike@addtoit.com>, linux-arch@vger.kernel.org, lkp@01.org

On Wed, Aug 09, 2017 at 09:14:50PM -0700, Nadav Amit wrote:

Hi Nadav,

< snip >

> >>>>> According to the description it is "testcase:brk increase/decrease of one
> >>>>> pagea??. According to the mode it spawns multiple processes, not threads.
> >>>>> 
> >>>>> Since a single page is unmapped each time, and the iTLB-loads increase
> >>>>> dramatically, I would suspect that for some reason a full TLB flush is
> >>>>> caused during do_munmap().
> >>>>> 
> >>>>> If I find some free time, Ia??ll try to profile the workload - but feel free
> >>>>> to beat me to it.
> >>>> 
> >>>> The root-cause appears to be that tlb_finish_mmu() does not call
> >>>> dec_tlb_flush_pending() - as it should. Any chance you can take care of it?
> >>> 
> >>> Oops, but with second looking, it seems it's not my fault. ;-)
> >>> https://marc.info/?l=linux-mm&m=150156699114088&w=2
> >>> 
> >>> Anyway, thanks for the pointing out.
> >>> xiaolong.ye, could you retest with this fix?
> >> 
> >> I've queued tests for 5 times and results show this patch (e8f682574e4 "mm:
> >> decrease tlb flush pending count in tlb_finish_mmu") does help recover the
> >> performance back.
> >> 
> >> 378005bdbac0a2ec  76742700225cad9df49f053993  e8f682574e45b6406dadfffeb4  
> >> ----------------  --------------------------  --------------------------  
> >>         %stddev      change         %stddev      change         %stddev
> >>             \          |                \          |                \  
> >>   3405093             -19%    2747088              -2%    3348752        will-it-scale.per_process_ops
> >>      1280 A+-  3%        -2%       1257 A+-  3%        -6%       1207        vmstat.system.cs
> >>      2702 A+- 18%        11%       3002 A+- 19%        17%       3156 A+- 18%  numa-vmstat.node0.nr_mapped
> >>     10765 A+- 18%        11%      11964 A+- 19%        17%      12588 A+- 18%  numa-meminfo.node0.Mapped
> >>      0.00 A+- 47%       -40%       0.00 A+- 45%       -84%       0.00 A+- 42%  mpstat.cpu.soft%
> >> 
> >> Thanks,
> >> Xiaolong
> > 
> > Thanks for the testing!
> 
> Sorry again for screwing your patch, Minchan.

Never mind! It always happens. :)
In this chance, I really appreciates your insight/testing/cooperation!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
