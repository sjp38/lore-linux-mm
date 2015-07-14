Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id DDA66280257
	for <linux-mm@kvack.org>; Tue, 14 Jul 2015 12:52:34 -0400 (EDT)
Received: by padck2 with SMTP id ck2so8462900pad.0
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 09:52:34 -0700 (PDT)
Received: from mail-pd0-x233.google.com (mail-pd0-x233.google.com. [2607:f8b0:400e:c02::233])
        by mx.google.com with ESMTPS id rp5si2761981pab.52.2015.07.14.09.52.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Jul 2015 09:52:33 -0700 (PDT)
Received: by pdjr16 with SMTP id r16so8764084pdj.3
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 09:52:33 -0700 (PDT)
Date: Wed, 15 Jul 2015 01:52:24 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 0/3] zsmalloc: small compaction improvements
Message-ID: <20150714165224.GA384@blaptop>
References: <1436607932-7116-1-git-send-email-sergey.senozhatsky@gmail.com>
 <20150713233602.GA31822@blaptop.AC68U>
 <20150714003132.GA2463@swordfish>
 <20150714005459.GA12786@blaptop.AC68U>
 <20150714122932.GA597@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150714122932.GA597@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Sergey,

On Tue, Jul 14, 2015 at 09:29:32PM +0900, Sergey Senozhatsky wrote:
> On (07/14/15 09:55), Minchan Kim wrote:
> > > It depends on 'big overhead' definition, of course. We don't care
> > > that much when compaction is issued by the shrinker, because things
> > > are getting bad and we can sacrifice performance. But user triggered
> > > compaction on a I/O pressured device can needlessly slow things down,
> > > especially now, when we drain ALMOST_FULL classes.
> > 
> > You mean performance overhead by additional alloc_pages?
> 
> not only performance, but yes, performance mostly.
> 
> > If so, you mean ALMOST_EMPTY|ALMOST_FULL, not only ALMOST_FULL?
> 
> of course, I meant your recent patch here. should have been 'we _ALSO_
> drain ALMOST_FULL classes'
> 
> > 
> > So, it's performance enhance patch?
> > Please give the some number to justify patchset.
> 
> alrighty... again...
> 
> > > 
> > > /sys/block/zram<id>/compact is a black box. We provide it, we don't
> > > throttle it in the kernel, and user space is absolutely clueless when
> > > it invokes compaction. From some remote (or alternative) point of
> > 
> > But we have zs_can_compact so it can effectively skip the class if it
> > is not proper class.
> 
> user triggered compaction can compact too much.
> in its current state triggering a compaction from user space is like
> playing a lottery or a russian roulette.

We were on different page.

I thought the motivation from this patchset is to prevent compaction
overhead by frequent user-driven compaction request because user
don't know how they can get free pages by compaction so they should
ask compact frequently with blind.
That's why I mentioned zs_can_compact which can skip compaction
effectively.

But your montivation is too much drain so loses performance.

First of all, user-triggered compaction should be highly avoided
because we introduced auto-compaction now so it should be enough.
If auto-compaction has trobule with someone's requirement,
we should fix/enhance it rather than enhancing manual compact.

For example, if there is some problems in compaction of VM, we don't
enhance manual compact(ie, /proc/sys/vm/compact_memory). Instead,
we enhance dynamic compaction.
If there is some problems in reclaim algorithm, we don't enhance
/proc/sys/vm/drop_caches but fixes alrogithm itself.
Because it's really hard for user to decide when/how it triggers
and even every system doesn't have such userspace program.

If user want to compact by manual, we should catch up the voice
from them and try to find why they are not enough with auto-compaction
and fix it rather than relying on user's decision with manual compaction.

Nonetheless, if user decied to trigger manual compaction, he should
have a cost(ie, performance lose). It's natural for all caches that
performance and cache size is proportional.

If you have a concern about too much drain, we should fix auto-compaction
which can reclaim pages as many as VM request, rather than every zspages
of all classes.

Slab shrinker already passes a hint how many objects subsystem should
reclaim so we could stop reclaim at some point, not draining all classes.
But the problem in this approach is we need balance reclaiming for all
classes with round-robin to prevent too much draining from a class,
I think it is not hard but I really suspect we need it in this point.

> 
> a simple script
> 
> for i in {1..1000}; do
>         echo -n 'compact... ';
>         cat /sys/block/zram0/compact;
>         echo 1 > /sys/block/zram0/compact;
>         sleep 1;
> done
> 
> (and this is not so crazy. love it or not, but this is the only way
> how user space can use compaction at the moment).
> 
> the output
> ...
> compact... 0
> compact... 0
> compact... 0
> compact... 0
> compact... 0
> compact... 0
> compact... 409
> compact... 3550
> compact... 0
> compact... 0
> compact... 0
> compact... 2129
> compact... 765
> compact... 0
> compact... 0
> compact... 0
> compact... 784
> compact... 0
> compact... 0
> compact... 0
> compact... 0
> ...
> 
> (f.e., we compacted 3550 pages on device being under I/O pressure.
> that's quite a lot, don't you think so?).
> 
> first	-- no enforced compaction
> second	-- with enforced compaction
> 
> ./iozone -t 8 -R -r 4K -s 200M -I +Z
> 
>                         w/o               w/compaction
> "  Initial write "    549240.49             538710.62
> "        Rewrite "   2447973.19            2442312.38
> "           Read "   5533620.69            5611562.00
> "        Re-read "   5689199.81            4916373.62
> "   Reverse Read "   4094576.16            5280551.56
> "    Stride read "   5382067.75            5395350.00
> "    Random read "   5384945.56            5298079.62
> " Mixed workload "   3986770.06            3918897.78
> "   Random write "   2290869.12            2201346.50
> "         Pwrite "    502619.36             493527.64
> "          Pread "   2675312.28            2732118.19
> "         Fwrite "   4198686.06            3373855.09
> "          Fread "  18054401.25           17895797.00

It seems to be not significant if we consider it's benchmark to
focus to reveal performance and even sometime w/compaction is better.

Although it might be apparenlty slow, it is expected.
Because run-time compaction overhead and small cache size
by compaction will absolutely affect performance so user should
avoid such manual compaction and relies on cache eviction
to VM reclaim. It's true for all caches in current linux kernel.

> 
> 
> > > view compaction can be seen as "zsmalloc's cache flush" (unused objects
> > > make write path quicker - no zspage allocation needed) and it won't
> > > hurt to give user space some numbers so it can decide if the whole
> > > thing is worth it (that decision is, once again, I/O pattern and
> > > setup specific -- some users may be interested in compaction only
> > > if it will reduce zsmalloc's memory consumption by, say, 15%).
> > 
> > Again, your claim is performace so I need number.
> > If it's really horrible, I guess below interface makes user handy
> > without peeking nr_can_compact ad doing compact.
> > 
> >         /* Tell zram to compact if fragment ration is higher 15% */
> >         echo 15% > /sys/block/zram0/compact
> >         or
> >         echo 15% > /sys/block/zram/compact_condition
> 
> no, this is the least of the things we need to do -- enforced and
> pre-defined policy engine in zram/zsmalloc 'that will work for all'.
> user space has almost all the numbers to do it, the only missing bit
> of the puzzle is `nr_can_compact' number. it's up to user space then
> to decide how it wishes things to be done. for example:

I don't think so. It seems you claims kernel should provide basic stat
and user should implement the policy based on it. Normally it might be
true but if kernel can do it better, it's better to handle it in kernel
space.

In case of your interface, every such system should have a userspace manager
to control it. IOW, if there is no such program in the system, the feature
is void. But with my suggestion, we could make default value(ex, 30 or 15)
and user can change it anytime. At least, it will work without any userspace
intervention.

Other flaw of your interface is we cannot provide right vaule from
reading /sys/block/zram0/compact, which is really racy so user's
decision is really fragile to work.
It's bad for kernel to provide such vague value to the user for his
policy decision.

NACK.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
