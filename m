Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id A360F6B0074
	for <linux-mm@kvack.org>; Wed, 17 Jun 2015 22:40:41 -0400 (EDT)
Received: by pdjn11 with SMTP id n11so55113757pdj.0
        for <linux-mm@kvack.org>; Wed, 17 Jun 2015 19:40:41 -0700 (PDT)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com. [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id bn1si9105512pbc.96.2015.06.17.19.40.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jun 2015 19:40:40 -0700 (PDT)
Received: by padev16 with SMTP id ev16so50167612pad.0
        for <linux-mm@kvack.org>; Wed, 17 Jun 2015 19:40:40 -0700 (PDT)
Date: Thu, 18 Jun 2015 11:41:07 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [RFC][PATCHv2 8/8] zsmalloc: register a shrinker to trigger
 auto-compaction
Message-ID: <20150618023906.GC3422@swordfish>
References: <1433505838-23058-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1433505838-23058-9-git-send-email-sergey.senozhatsky@gmail.com>
 <20150616144730.GD31387@blaptop>
 <20150616154529.GE20596@swordfish>
 <20150618015028.GA2370@bgram>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150618015028.GA2370@bgram>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

Hi,

On (06/18/15 10:50), Minchan Kim wrote:
[..]
> > hm, what's the difference with the existing implementation?
> > The 'new one' aborts when (a) !zs_can_compact() and (b) !migrate_zspage().
> > It holds the class lock less time than current compaction.
> 
> At old, it unlocks periodically(ie, per-zspage migration) so other who
> want to allocate a zspage in the class can have a chance but your patch
> increases lock holding time until all of zspages in the class is done
> so other will be blocked until all of zspage migration in the class is
> done.

ah, I see.
it doesn't hold the lock `until all the pages are done`. it holds it
as long as zs_can_compact() returns > 0. hm, I'm not entirely sure that
this patch set has increased the locking time (in average).


> > 
> > > I will review remain parts tomorrow(I hope) but what I want to say
> > > before going sleep is:
> > > 
> > > I like the idea but still have a concern to lack of fragmented zspages
> > > during memory pressure because auto-compaction will prevent fragment
> > > most of time. Surely, using fragment space as buffer in heavy memory
> > > pressure is not intened design so it could be fragile but I'm afraid
> > > this feature might accelrate it and it ends up having a problem and
> > > change current behavior in zram as swap.
> > 
> > Well, it's nearly impossible to prove anything with the numbers obtained
> > during some particular case. I agree that fragmentation can be both
> > 'good' (depending on IO pattern) and 'bad'.
> 
> Yes, it's not easy and I believe a few artificial testing are not enough
> to prove no regression but we don't have any choice.
> Actually, I think this patchset does make sense. Although it might have
> a problem on situation heavy memory pressure by lacking of fragment space,


I tested exactly this scenario yesterday (and sent an email). We leave `no holes'
in classes only in ~1.35% of cases. so, no, this argument is not valid. we preserve
fragmentation.

	-ss

> I think we should go with this patchset and fix the problem with another way
> (e,g. memory pooling rather than relying on the luck of fragment).
> But I need something to take the risk. That's why I ask the number
> although it's not complete. It can cover a case at least, it is better than
> none. :)
> 
> > 
> > 
> > Auto-compaction of IDLE zram devices certainly makes sense, when system
> > is getting low on memory. zram devices are not always 'busy', serving
> > heavy IO. There may be N idle zram devices simply sitting and wasting
> > memory; or being 'moderately' busy; so compaction will not cause any
> > significant slow down there.
> > 
> > Auto-compaction of BUSY zram devices is less `desired', of course;
> > but not entirely terrible I think (zs_can_compact() can help here a
> > lot).
> 
> My concern is not a compacion overhead but higher memory footprint
> consumed by zram in reserved memory.
> It might hang system if zram used up reserved memory of system with
> ALLOC_NO_WATERMARKS. With auto-compaction, userspace has a higher chance
> to use more memory with uncompressible pages or file-backed pages
> so zram-swap can use more reserved memory. We need to evaluate it, I think.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
