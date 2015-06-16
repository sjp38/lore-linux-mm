Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 17E396B0038
	for <linux-mm@kvack.org>; Tue, 16 Jun 2015 11:46:15 -0400 (EDT)
Received: by pdbki1 with SMTP id ki1so17061489pdb.1
        for <linux-mm@kvack.org>; Tue, 16 Jun 2015 08:46:14 -0700 (PDT)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com. [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id ca1si1889848pbb.169.2015.06.16.08.46.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jun 2015 08:46:13 -0700 (PDT)
Received: by pacgb13 with SMTP id gb13so15209161pac.1
        for <linux-mm@kvack.org>; Tue, 16 Jun 2015 08:46:13 -0700 (PDT)
Date: Wed, 17 Jun 2015 00:45:29 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [RFC][PATCHv2 8/8] zsmalloc: register a shrinker to trigger
 auto-compaction
Message-ID: <20150616154529.GE20596@swordfish>
References: <1433505838-23058-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1433505838-23058-9-git-send-email-sergey.senozhatsky@gmail.com>
 <20150616144730.GD31387@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150616144730.GD31387@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On (06/16/15 23:47), Minchan Kim wrote:
[..]
> > 
> > Compaction now has a relatively quick pool scan so we are able to
> > estimate the number of pages that will be freed easily, which makes it
> > possible to call this function from a shrinker->count_objects() callback.
> > We also abort compaction as soon as we detect that we can't free any
> > pages any more, preventing wasteful objects migrations. In the example
> > above, "6074 objects were migrated" implies that we actually released
> > zspages back to system.
> > 
> > The initial patch was triggering compaction from zs_free() for
> > every ZS_ALMOST_EMPTY page. Minchan Kim proposed to use a slab
> > shrinker.
> 
> First of all, thanks for mentioning me as proposer.
> However, it's not a helpful comment for other reviewers and
> anonymous people who will review this in future.
> 
> At least, write why I suggested it so others can understand
> the pros/cons.

OK, this one is far from perfect. Will try to improve later.

> > 
> > Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> > Reported-by: Minchan Kim <minchan@kernel.org>
> 
> I didn't report anything. ;-).

:-)

> 
> > ---

[..]

> 
> So should we hold class lock until finishing the compaction of the class?
> It would make horrible latency for other allocation from the class
> in parallel.

hm, what's the difference with the existing implementation?
The 'new one' aborts when (a) !zs_can_compact() and (b) !migrate_zspage().
It holds the class lock less time than current compaction.

> I will review remain parts tomorrow(I hope) but what I want to say
> before going sleep is:
> 
> I like the idea but still have a concern to lack of fragmented zspages
> during memory pressure because auto-compaction will prevent fragment
> most of time. Surely, using fragment space as buffer in heavy memory
> pressure is not intened design so it could be fragile but I'm afraid
> this feature might accelrate it and it ends up having a problem and
> change current behavior in zram as swap.

Well, it's nearly impossible to prove anything with the numbers obtained
during some particular case. I agree that fragmentation can be both
'good' (depending on IO pattern) and 'bad'.


Auto-compaction of IDLE zram devices certainly makes sense, when system
is getting low on memory. zram devices are not always 'busy', serving
heavy IO. There may be N idle zram devices simply sitting and wasting
memory; or being 'moderately' busy; so compaction will not cause any
significant slow down there.

Auto-compaction of BUSY zram devices is less `desired', of course;
but not entirely terrible I think (zs_can_compact() can help here a
lot).

Just an idea
we can move shrinker registration from zsmalloc to zram. zram will be
able to STOP (or forbid) any shrinker activities while it [zram] serves
IO requests (or has requests in its request_queue).

But, again, advocating fragmentation is tricky.


I'll quote from the cover letter

: zsmalloc in some cases can suffer from a notable fragmentation and
: compaction can release some considerable amount of memory. The problem
: here is that currently we fully rely on user space to perform compaction
: when needed. However, performing zsmalloc compaction is not always an
: obvious thing to do. For example, suppose we have a `idle' fragmented
: (compaction was never performed) zram device and system is getting low
: on memory due to some 3rd party user processes (gcc LTO, or firefox, etc.).
: It's quite unlikely that user space will issue zpool compaction in this
: case. Besides, user space cannot tell for sure how badly pool is
: fragmented; however, this info is known to zsmalloc and, hence, to a
: shrinker.


I find this case (a) interesting and (b) quite possible.
/* Besides, this happens on one of my old x86_64 boxen all the time.
 And I do like/appreciate that zram automatically releases some memory. */


> I hope you test this feature with considering my concern.
> Of course, I will test it with enough time.
> 
> Thanks.
> 

sure.

Thanks.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
