Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 822466B0038
	for <linux-mm@kvack.org>; Wed,  3 Dec 2014 02:46:32 -0500 (EST)
Received: by mail-pd0-f169.google.com with SMTP id fp1so14843955pdb.28
        for <linux-mm@kvack.org>; Tue, 02 Dec 2014 23:46:32 -0800 (PST)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id do6si9085864pdb.34.2014.12.02.23.46.29
        for <linux-mm@kvack.org>;
        Tue, 02 Dec 2014 23:46:30 -0800 (PST)
Date: Wed, 3 Dec 2014 16:49:57 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: isolate_freepages_block and excessive CPU usage by OSD process
Message-ID: <20141203074957.GA6276@js1304-P5Q-DELUXE>
References: <546D2366.1050506@suse.cz>
 <20141121023554.GA24175@cucumber.bridge.anchor.net.au>
 <20141123093348.GA16954@cucumber.anchor.net.au>
 <CABYiri8LYukujETMCb4gHUQd=J-MQ8m=rGRiEkTD1B42Jh=Ksg@mail.gmail.com>
 <20141128080331.GD11802@js1304-P5Q-DELUXE>
 <54783FB7.4030502@suse.cz>
 <20141201083118.GB2499@js1304-P5Q-DELUXE>
 <20141202014724.GA22239@cucumber.bridge.anchor.net.au>
 <20141202045324.GC6268@js1304-P5Q-DELUXE>
 <547DDED9.6080105@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <547DDED9.6080105@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org

On Tue, Dec 02, 2014 at 04:46:33PM +0100, Vlastimil Babka wrote:
> On 12/02/2014 05:53 AM, Joonsoo Kim wrote:
> >On Tue, Dec 02, 2014 at 12:47:24PM +1100, Christian Marie wrote:
> >>On 28.11.2014 9:03, Joonsoo Kim wrote:
> >>>Hello,
> >>>
> >>>I didn't follow-up this discussion, but, at glance, this excessive CPU
> >>>usage by compaction is related to following fixes.
> >>>
> >>>Could you test following two patches?
> >>>
> >>>If these fixes your problem, I will resumit patches with proper commit
> >>>description.
> >>>
> >>>-------- 8< ---------
> >>
> >>
> >>Thanks for looking into this. Running 3.18-rc5 kernel with your patches has
> >>produced some interesting results.
> >>
> >>Load average still spikes to around 2000-3000 with the processors spinning 100%
> >>doing compaction related things when min_free_kbytes is left at the default.
> >>
> >>However, unlike before, the system is now completely stable. Pre-patch it would
> >>be almost completely unresponsive (having to wait 30 seconds to establish an
> >>SSH connection and several seconds to send a character).
> >>
> >>Is it reasonable to guess that ipoib is giving compaction a hard time and
> >>fixing this bug has allowed the system to at least not lock up?
> >>
> >>I will try back-porting this to 3.10 and seeing if it is stable under these
> >>strange conditions also.
> >
> >Hello,
> >
> >Good to hear!
> 
> Indeed, although I somehow doubt your first patch could have made
> such difference. It only matters when you have a whole pageblock
> free. Without the patch, the particular compaction attempt that
> managed to free the block might not be terminated ASAP, but then the
> free pageblock is still allocatable by the following allocation
> attempts, so it shouldn't result in a stream of complete
> compactions.

High-order freepage made by compaction could be broken by other
order-0 allocation attempts, so following high-order allocation attempts
could result in new compaction. It would be dependent on workload.

Anyway, we should fix cc->order to order. :)

> 
> So I would expect it's either a fluke, or the second patch made the
> difference, to either SLUB or something else making such
> fallback-able allocations.
> 
> But hmm, I've never considered the implications of
> compact_finished() migratetypes handling on unmovable allocations.
> Regardless of cc->order, it often has to free a whole pageblock to
> succeed, as it's unlikely it will succeed compacting within a
> pageblock already marked as UNMOVABLE. Guess it's to prevent further
> fragmentation and that makes sense, but it does make high-order
> unmovable allocations problematic. At least the watermark checks for
> allowing compaction in the first place are then wrong - we decide
> that based on cc->order, but in we fact need at least a pageblock
> worth of space free to actually succeed.

I think that watermark check is okay but we need a elegant way to decide
the best timing compaction should be stopped. I made following two patches
about this. This patch would make non-movable compaction less
aggressive. This is just draft so ignore my poor description. :)

Could you comment it?

--------->8-----------------
