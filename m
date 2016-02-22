Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f177.google.com (mail-ig0-f177.google.com [209.85.213.177])
	by kanga.kvack.org (Postfix) with ESMTP id A55D76B0009
	for <linux-mm@kvack.org>; Sun, 21 Feb 2016 23:54:43 -0500 (EST)
Received: by mail-ig0-f177.google.com with SMTP id y8so78550831igp.0
        for <linux-mm@kvack.org>; Sun, 21 Feb 2016 20:54:43 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id uv2si16857220igb.24.2016.02.21.20.54.42
        for <linux-mm@kvack.org>;
        Sun, 21 Feb 2016 20:54:43 -0800 (PST)
Date: Mon, 22 Feb 2016 13:54:58 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC][PATCH v2 2/3] zram: use zs_get_huge_class_size_watermark()
Message-ID: <20160222045458.GF27829@bbox>
References: <1456061274-20059-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1456061274-20059-3-git-send-email-sergey.senozhatsky@gmail.com>
 <20160222000436.GA21710@bbox>
 <20160222004047.GA4958@swordfish>
 <20160222012758.GA27829@bbox>
 <20160222015912.GA488@swordfish>
 <20160222025709.GD27829@bbox>
 <20160222035448.GB11961@swordfish>
MIME-Version: 1.0
In-Reply-To: <20160222035448.GB11961@swordfish>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Feb 22, 2016 at 12:54:48PM +0900, Sergey Senozhatsky wrote:
> On (02/22/16 11:57), Minchan Kim wrote:
> [..]
> > > > Yes, I mean if we have backing storage, we could mitigate the problem
> > > > like the mentioned approach. Otherwise, we should solve it in allocator
> > > > itself and you suggested the idea and I commented first step.
> > > > What's the problem, now?
> > > 
> > > well, I didn't say I have problems.
> > > so you want a backing device that will keep only 'bad compression'
> > > objects and use zsmalloc to keep there only 'good compression' objects?
> > > IOW, no huge classes in zsmalloc at all? well, that can work out. it's
> > > a bit strange though that to solve zram-zsmalloc issues we would ask
> > > someone to create a additional device. it looks (at least for now) that
> > > we can address those issues in zram-zsmalloc entirely; w/o user
> > > intervention or a 3rd party device.
> > 
> > Agree. That's what I want. zram shouldn't be aware of allocator's
> > internal implementation. IOW, zsmalloc should handle it without
> > exposing any internal limitation.
> 
> well, at the same time zram must not dictate what to do. zram simply spoils
> zsmalloc; it does not offer guaranteed good compression, and it does not let
> zsmalloc to do it's job. zram has only excuses to be the way it is.
> the existing zram->zsmalloc dependency looks worse than zsmalloc->zram to me.

I don't get it why you think it's zram->zsmalloc dependency.
I already explained. Here it goes, again.

Long time ago, zram(i.e, ramzswap) can fallback incompressible page to
backed device if it presents and the size was PAGE_SIZE / 2.
IOW, if compress ratio is bad than 50%, zram passes the page to backed
storage to make memory efficiency.
If zram doesn't have backed storage and compress ratio under 25%(ie,
short of memory saving) it store pages as uncompressible for avoiding
additional *decompress* overhead.
Of course, it's arguable whether memory efficiency VS. CPU consumption
so we should handle it as another topic.
What I want to say in here is it's not dependency between zram and
zsmalloc but it was a zram policy for a long time.
If it's not good, we can fix it.
 
> 
> > Backing device issue is orthogonal but what I said about thing
> > was it could solve the issue too without exposing zsmalloc's
> > limitation to the zram.
> 
> well, backing device would not reduce the amount of pages we request.
> and that's the priority issue, especially if we are talking about
> embedded system with a low free pages capability. we would just move huge
> objects from zsmalloc to backing device. other than that we would still
> request 1000 (for example) pages to store 1000 objects. it's zsmalloc's
> "page sharing" that permits us to request less than 1000 pages to store
> 1000 objects.
> 
> so yes, I agree, increasing ZS_MAX_ZSPAGE_ORDER and do more tests is
> the step #1 to take.
> 
> > Let's summary my points in here.
> > 
> > Let's make zsmalloc smarter to reduce wasted space. One of option is
> > dynamic page creation which I agreed.
> >
> > Before the feature, we should test how memory footprint is bigger
> > without the feature if we increase ZS_MAX_ZSPAGE_ORDER.
> > If it's not big, we could go with your patch easily without adding
> > more complex stuff(i.e, dynamic page creation).
> 
> yes, agree. alloc_zspage()/init_zspage() and friends must be the last
> thing to touch. only if increased ZS_MAX_ZSPAGE_ORDER will turn out not
> to be good enough.
> 
> > Please, check max_used_pages rather than mem_used_total for seeing
> > memory footprint at the some moment and test very fragmented scenario
> > (creating files and free part of files) rather than just full coping.
> 
> sure, more tests will follow.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
