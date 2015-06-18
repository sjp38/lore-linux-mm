Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id D9DCF6B0074
	for <linux-mm@kvack.org>; Wed, 17 Jun 2015 21:50:39 -0400 (EDT)
Received: by pdjm12 with SMTP id m12so54066742pdj.3
        for <linux-mm@kvack.org>; Wed, 17 Jun 2015 18:50:39 -0700 (PDT)
Received: from mail-pd0-x22c.google.com (mail-pd0-x22c.google.com. [2607:f8b0:400e:c02::22c])
        by mx.google.com with ESMTPS id kt9si8917284pab.169.2015.06.17.18.50.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jun 2015 18:50:38 -0700 (PDT)
Received: by pdbki1 with SMTP id ki1so54127847pdb.1
        for <linux-mm@kvack.org>; Wed, 17 Jun 2015 18:50:38 -0700 (PDT)
Date: Thu, 18 Jun 2015 10:50:28 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC][PATCHv2 8/8] zsmalloc: register a shrinker to trigger
 auto-compaction
Message-ID: <20150618015028.GA2370@bgram>
References: <1433505838-23058-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1433505838-23058-9-git-send-email-sergey.senozhatsky@gmail.com>
 <20150616144730.GD31387@blaptop>
 <20150616154529.GE20596@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150616154529.GE20596@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

Hi Sergey,

On Wed, Jun 17, 2015 at 12:45:29AM +0900, Sergey Senozhatsky wrote:
> On (06/16/15 23:47), Minchan Kim wrote:
> [..]
> > > 
> > > Compaction now has a relatively quick pool scan so we are able to
> > > estimate the number of pages that will be freed easily, which makes it
> > > possible to call this function from a shrinker->count_objects() callback.
> > > We also abort compaction as soon as we detect that we can't free any
> > > pages any more, preventing wasteful objects migrations. In the example
> > > above, "6074 objects were migrated" implies that we actually released
> > > zspages back to system.
> > > 
> > > The initial patch was triggering compaction from zs_free() for
> > > every ZS_ALMOST_EMPTY page. Minchan Kim proposed to use a slab
> > > shrinker.
> > 
> > First of all, thanks for mentioning me as proposer.
> > However, it's not a helpful comment for other reviewers and
> > anonymous people who will review this in future.
> > 
> > At least, write why I suggested it so others can understand
> > the pros/cons.
> 
> OK, this one is far from perfect. Will try to improve later.
> 
> > > 
> > > Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> > > Reported-by: Minchan Kim <minchan@kernel.org>
> > 
> > I didn't report anything. ;-).
> 
> :-)
> 
> > 
> > > ---
> 
> [..]
> 
> > 
> > So should we hold class lock until finishing the compaction of the class?
> > It would make horrible latency for other allocation from the class
> > in parallel.
> 
> hm, what's the difference with the existing implementation?
> The 'new one' aborts when (a) !zs_can_compact() and (b) !migrate_zspage().
> It holds the class lock less time than current compaction.

At old, it unlocks periodically(ie, per-zspage migration) so other who
want to allocate a zspage in the class can have a chance but your patch
increases lock holding time until all of zspages in the class is done
so other will be blocked until all of zspage migration in the class is
done.

> 
> > I will review remain parts tomorrow(I hope) but what I want to say
> > before going sleep is:
> > 
> > I like the idea but still have a concern to lack of fragmented zspages
> > during memory pressure because auto-compaction will prevent fragment
> > most of time. Surely, using fragment space as buffer in heavy memory
> > pressure is not intened design so it could be fragile but I'm afraid
> > this feature might accelrate it and it ends up having a problem and
> > change current behavior in zram as swap.
> 
> Well, it's nearly impossible to prove anything with the numbers obtained
> during some particular case. I agree that fragmentation can be both
> 'good' (depending on IO pattern) and 'bad'.

Yes, it's not easy and I believe a few artificial testing are not enough
to prove no regression but we don't have any choice.
Actually, I think this patchset does make sense. Although it might have
a problem on situation heavy memory pressure by lacking of fragment space,
I think we should go with this patchset and fix the problem with another way
(e,g. memory pooling rather than relying on the luck of fragment).
But I need something to take the risk. That's why I ask the number
although it's not complete. It can cover a case at least, it is better than
none. :)

> 
> 
> Auto-compaction of IDLE zram devices certainly makes sense, when system
> is getting low on memory. zram devices are not always 'busy', serving
> heavy IO. There may be N idle zram devices simply sitting and wasting
> memory; or being 'moderately' busy; so compaction will not cause any
> significant slow down there.
> 
> Auto-compaction of BUSY zram devices is less `desired', of course;
> but not entirely terrible I think (zs_can_compact() can help here a
> lot).

My concern is not a compacion overhead but higher memory footprint
consumed by zram in reserved memory.
It might hang system if zram used up reserved memory of system with
ALLOC_NO_WATERMARKS. With auto-compaction, userspace has a higher chance
to use more memory with uncompressible pages or file-backed pages
so zram-swap can use more reserved memory. We need to evaluate it, I think.

> 
> Just an idea
> we can move shrinker registration from zsmalloc to zram. zram will be
> able to STOP (or forbid) any shrinker activities while it [zram] serves
> IO requests (or has requests in its request_queue).
> 
> But, again, advocating fragmentation is tricky.
> 
> 
> I'll quote from the cover letter
> 
> : zsmalloc in some cases can suffer from a notable fragmentation and
> : compaction can release some considerable amount of memory. The problem
> : here is that currently we fully rely on user space to perform compaction
> : when needed. However, performing zsmalloc compaction is not always an
> : obvious thing to do. For example, suppose we have a `idle' fragmented
> : (compaction was never performed) zram device and system is getting low
> : on memory due to some 3rd party user processes (gcc LTO, or firefox, etc.).
> : It's quite unlikely that user space will issue zpool compaction in this
> : case. Besides, user space cannot tell for sure how badly pool is
> : fragmented; however, this info is known to zsmalloc and, hence, to a
> : shrinker.
> 
> 
> I find this case (a) interesting and (b) quite possible.
> /* Besides, this happens on one of my old x86_64 boxen all the time.
>  And I do like/appreciate that zram automatically releases some memory. */
> 
> 
> > I hope you test this feature with considering my concern.
> > Of course, I will test it with enough time.
> > 
> > Thanks.
> > 
> 
> sure.
> 
> Thanks.
> 
> 	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
