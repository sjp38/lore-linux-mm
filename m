Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 9CC946B0032
	for <linux-mm@kvack.org>; Thu,  4 Dec 2014 20:04:14 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id kx10so19138902pab.2
        for <linux-mm@kvack.org>; Thu, 04 Dec 2014 17:04:14 -0800 (PST)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id pm2si42191496pdb.18.2014.12.04.17.04.10
        for <linux-mm@kvack.org>;
        Thu, 04 Dec 2014 17:04:12 -0800 (PST)
Date: Fri, 5 Dec 2014 10:07:33 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: isolate_freepages_block and excessive CPU usage by OSD process
Message-ID: <20141205010733.GA13751@js1304-P5Q-DELUXE>
References: <20141123093348.GA16954@cucumber.anchor.net.au>
 <CABYiri8LYukujETMCb4gHUQd=J-MQ8m=rGRiEkTD1B42Jh=Ksg@mail.gmail.com>
 <20141128080331.GD11802@js1304-P5Q-DELUXE>
 <54783FB7.4030502@suse.cz>
 <20141201083118.GB2499@js1304-P5Q-DELUXE>
 <20141202014724.GA22239@cucumber.bridge.anchor.net.au>
 <20141202045324.GC6268@js1304-P5Q-DELUXE>
 <20141202050608.GA11051@cucumber.bridge.anchor.net.au>
 <20141203075747.GB6276@js1304-P5Q-DELUXE>
 <20141204073045.GA2960@cucumber.anchor.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141204073045.GA2960@cucumber.anchor.net.au>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

On Thu, Dec 04, 2014 at 06:30:45PM +1100, Christian Marie wrote:
> On Wed, Dec 03, 2014 at 04:57:47PM +0900, Joonsoo Kim wrote:
> > It'd be very helpful to get output of
> > "trace_event=compaction:*,kmem:mm_page_alloc_extfrag" on the kernel
> > with my tracepoint patches below.
> > 
> > See following link. There is 3 patches.
> > 
> > https://lkml.org/lkml/2014/12/3/71
> 
> I have just finished testing 3.18rc5 with both of the small patches mentioned
> earlier in this thread and 2/3 of your event patches. The second patch
> (https://lkml.org/lkml/2014/12/3/72) did not apply due to compaction_suitable
> being different (am I missing another patch you are basing this off?).

In fact, I'm using next-20141124 kernel, not just mainline one. There
is a lot of fixes from Vlastimil and it may cause the applying failure.
But, it's not that important in this case. I have gotten enough information
about this problem on your below log.

> 
> My compaction_suitable is:
> 
> 	unsigned long compaction_suitable(struct zone *zone, int order)
> 
> Results without that second event patch are as follows:
> 
> Trace under heavy load but before any spiking system usage or significant
> compaction spinning:
> 
> http://ponies.io/raw/compaction_events/before.gz
> 
> Trace during 100% cpu utilization, much of which was in system:
> 
> http://ponies.io/raw/compaction_events/during.gz

It looks that there is no stop condition in isolate_freepages(). In
this period, your system have not enough freepage and many processes
try to find freepage for compaction. Because there is no stop
condition, they iterate almost all memory range every time. At the
bottom of this mail, I attach one more fix although I don't test it
yet. It will cause a lot of allocation failure that your network layer
need. It is order 5 allocation request and with __GFP_NOWARN gfp flag,
so I assume that there is no problem if allocation request is failed,
but, I'm not sure.

watermark check on this patch needs cc->classzone_idx, cc->alloc_flags
that comes from Vlastimil's recent change. If you want to test it with
3.18rc5, please remove it. It doesn't much matter.

Anyway, I hope it also helps you.

> perf report at the time of during.gz:
> 
> http://ponies.io/raw/compaction_events/perf.png

By judging from this perf report, my second patch would have no impact
to your system. I thought that this excessive cpu usage is started from
the SLUB, but, order 5 kmalloc request is just forwarded to page
allocator in current SLUB implementation, so patch 2 from me would not
work on this problem.

By the way, is it common that network layer needs order 5 allocation?
IMHO, it'd be better to avoid this highorder request, because the kernel
easily fail to handle this kind of request.

Thanks.

> 
> Interested to see what you make of the limited information. I may be able to
> try all of your patches some time next week against whatever they apply cleanly
> to. If that is needed.

------------>8-----------------
