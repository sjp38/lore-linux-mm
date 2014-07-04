Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id D01EC6B0035
	for <linux-mm@kvack.org>; Fri,  4 Jul 2014 01:48:31 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id hz1so1440045pad.38
        for <linux-mm@kvack.org>; Thu, 03 Jul 2014 22:48:31 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id so9si33533953pac.191.2014.07.03.22.48.29
        for <linux-mm@kvack.org>;
        Thu, 03 Jul 2014 22:48:30 -0700 (PDT)
Date: Fri, 4 Jul 2014 14:49:57 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: zsmalloc failure issue in low memory conditions
Message-ID: <20140704054957.GG2939@bbox>
References: <77956EDC1B917843AC9B7965A3BD78B06ACB34DB39@SC-VEXCH2.marvell.com>
 <53B61E6B.1030406@vflare.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <53B61E6B.1030406@vflare.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nitin Gupta <ngupta@vflare.org>
Cc: Yonghai Huang <huangyh@marvell.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, Jul 03, 2014 at 08:24:27PM -0700, Nitin Gupta wrote:
> Hi Yonghai,
> 
> CC'ing the current maintainer, Minchan Kim.

Thanks for Ccing me, Nitin.

> 
> Thanks,
> Nitin
> 
> On 7/3/14, 5:03 PM, Yonghai Huang wrote:
> >
> >Hi, nugpta and all:
> >
> >Sorry to distribute you, now I met zsmalloc failure issue in very
> >low memory conditions, and i found someone already have met such
> >issue, and have had discussions, but looks like no final patch for
> >it, i don't know whether there are patches to fix it. could you
> >give some advice on it?
> >
> >Below is discussion link for it:
> >
> >
> >  http://linux-kernel.2935.n7.nabble.com/zram-zsmalloc-issues-in-very-low-memory-conditions-td742009.html
> >

At that time, I didn't have a time to look at it by biz trip but
reported twice until now so I'd like to bring up the issue.

zRAM works with reserved memory(ex, zone->low - zone->min) so
if you increased min_free_kbytes, maybe the problem would be gone
but it's not a proper fix, I think because if some of other(ex,
proprietary driver) deplete the reserved memory with __GFP_MEMALLOC
or PF_MEMALLOC, zsmalloc could be failed although it's rare
in current mainline but VM can reclaim file-backed pages still
so system can go without OOM kill while swap layer can emit lots
of warning message about failing write. :(

For me, ideal solution is to need to feedback loop from zram block
driver to VM via congestion control(Currently, reclaim of VM doesn't
consider swap backend's congestion state but not too hard to fix)
as Olav suggested but it has another issue to update uncongestion
state from zram side but finally we could find a solution, I believe. :)

But before diving into the implementation, I need to reproduce
the problem and maybe it would be helpful if you says your enviroment.

1. CPU
2. RAM size
3. zram disksize
4. /proc/sys/vm/page-cluster
5. /sys/block/zram0/max_comp_streams
6. what workload do you have?
7. /proc/zoneinfo
8. What kinds of file system do you use?
9. What kinds of workload do you have when the problem happens?
10. It would be really helpful if you can get /proc/vmstat when the problem happened.

Anyway, I will have a time to reproduce/investigate the problem next week
and get back to you.

Thanks for the report!

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
