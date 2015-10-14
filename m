Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 5020A6B0253
	for <linux-mm@kvack.org>; Tue, 13 Oct 2015 21:26:51 -0400 (EDT)
Received: by pabrc13 with SMTP id rc13so37430828pab.0
        for <linux-mm@kvack.org>; Tue, 13 Oct 2015 18:26:51 -0700 (PDT)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com. [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id nn10si9052858pbc.131.2015.10.13.18.26.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Oct 2015 18:26:50 -0700 (PDT)
Received: by padcn9 with SMTP id cn9so6322974pad.2
        for <linux-mm@kvack.org>; Tue, 13 Oct 2015 18:26:50 -0700 (PDT)
Date: Wed, 14 Oct 2015 10:27:42 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCHv2 0/3] align zpool/zbud/zsmalloc on the api
Message-ID: <20151014012742.GB1505@swordfish>
References: <20150926100401.96a36c7cd3c913b063887466@gmail.com>
 <CALZtONAbX4dzGnhcO6s7aMP9VU8+FeQqYS33u+XdUv2noAvePA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALZtONAbX4dzGnhcO6s7aMP9VU8+FeQqYS33u+XdUv2noAvePA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Vitaly Wool <vitalywool@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Seth Jennings <sjennings@variantweb.net>, Minchan Kim <minchan@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

Sorry for long reply.

On (10/09/15 08:36), Dan Streetman wrote:
[..]
> Specifically regarding the determinism of each; obviously compaction
> will have an impact, since it takes cpu cycles to do the compaction.
> I don't know how much impact, but I think at minimum it would make
> sense to add a module param to zsmalloc to allow disabling compaction.

Well, this was on my list of things TODO; and, BTW, this was *ONE OF*
the reason I added bool flag `->shrinker_enabled'.

static unsigned long zs_shrinker_count(struct shrinker *shrinker,
		struct shrink_control *sc)
{
	...
	if (!pool->shrinker_enabled)
		return 0;
	...
}

So, technically, it's easy. I'm not sure, though, that I want to export
this low level knob. It sort of makes sense, but at the same time a bit
tricky.

> But even without compaction, there is an important difference between
> zbud and zsmalloc; zbud will never alloc more than 1 page when it
> needs more storage, while zsmalloc will alloc between 1 and
> ZS_MAX_PAGES_PER_ZSPAGE (currently 4) pages when it needs more
> storage.  So in the worst case (if memory is tight and alloc_page()
> takes a while), zsmalloc could take up to 4 times as long as zbud to
> store a page.
>

hm... zsmalloc release zspage once it becomes empty, which happens:
a) when zspage receives 'final' zs_free() (no more objects in use)
   and turns into a ZS_EMPTY zspage
b) when compaction moves all of its object to other zspages and, thus,
   the zspage becomes ZS_EMPTY

And, basically, this `allocate ZS_MAX_PAGES_PER_ZSPAGE pages' penalty
hits (to some degree) us even if we are not so tight on memory.


So... *May be* it makes some sense to guarantee (well, via a special
knob) that each class has no less than N unused objects (hot-cache),
which may be (but not necessarily is) an equivalent of keeping M
ZS_EMPTY zspage(-s) in the class. IOW, avoid free_zspage() if that will
result in K alloc_page() shortly, simply because we end up having just
1 or 2 unused objects in the class.

I can understand that some workloads care less about memory efficiency.


Looks like I finally have more time this week so I'll try to take a
look why zsmalloc makes Vitaly so unhappy.

	-ss

> Now, that should average out, where zsmalloc doesn't
> need to alloc as many times as zbud (since it allocs more at once),
> but on the small scale there will be less consistency of page storage
> times with zsmalloc than zbud; at least, theoretically ;-)
> 
> I suggest you work with Minchan to find out what comparison data he
> wants to see, to prove zbud is more stable/consistent under a certain
> workload (and/or across kernel versions).
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
