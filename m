Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f177.google.com (mail-ig0-f177.google.com [209.85.213.177])
	by kanga.kvack.org (Postfix) with ESMTP id 3BA3A6B0254
	for <linux-mm@kvack.org>; Sun, 21 Feb 2016 21:56:56 -0500 (EST)
Received: by mail-ig0-f177.google.com with SMTP id hb3so68474452igb.0
        for <linux-mm@kvack.org>; Sun, 21 Feb 2016 18:56:56 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id t7si5557088igk.68.2016.02.21.18.56.54
        for <linux-mm@kvack.org>;
        Sun, 21 Feb 2016 18:56:55 -0800 (PST)
Date: Mon, 22 Feb 2016 11:57:09 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC][PATCH v2 2/3] zram: use zs_get_huge_class_size_watermark()
Message-ID: <20160222025709.GD27829@bbox>
References: <1456061274-20059-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1456061274-20059-3-git-send-email-sergey.senozhatsky@gmail.com>
 <20160222000436.GA21710@bbox>
 <20160222004047.GA4958@swordfish>
 <20160222012758.GA27829@bbox>
 <20160222015912.GA488@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160222015912.GA488@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Feb 22, 2016 at 10:59:12AM +0900, Sergey Senozhatsky wrote:
> On (02/22/16 10:27), Minchan Kim wrote:
> [..]
> > > zram asks to store a PAGE_SIZE sized object, what zsmalloc can
> > > possible do about this?
> > 
> > zsmalloc can increase ZS_MAX_ZSPAGE_ORDER or can save metadata in
> > the extra space. In fact, I tried interlink approach long time ago.
> > For example, class-A -> class-B 
> > 
> >         A = x, B = (4096 - y) >= x
> >
> > The problem was class->B zspage consumes memory although there is
> > no object in the zspage because class-A object in the extra space
> > of class-B pin the class-B zspage.
> 
> I thought about it too -- utilizing 'unused space' to store there
> smaller objects. and I think it potentially has more problems.
> compaction (and everything) seem to be much simpler when we have only
> objects of size-X in class_size X.
> 
> > I prefer your ZS_MAX_ZSPAGE_ORDER increaing approach but as I told
> > in that thread, we should prepare dynamic creating of sub-page
> > in zspage.
> 
> I agree that in general dynamic class page allocation sounds
> interesting enough.
> 
> > > > Having said that, I agree your claim that uncompressible pages
> > > > are pain. I want to handle the problem as multiple-swap apparoach.
> > > 
> > > zram is not just for swapping. as simple as that.
> > 
> > Yes, I mean if we have backing storage, we could mitigate the problem
> > like the mentioned approach. Otherwise, we should solve it in allocator
> > itself and you suggested the idea and I commented first step.
> > What's the problem, now?
> 
> well, I didn't say I have problems.
> so you want a backing device that will keep only 'bad compression'
> objects and use zsmalloc to keep there only 'good compression' objects?
> IOW, no huge classes in zsmalloc at all? well, that can work out. it's
> a bit strange though that to solve zram-zsmalloc issues we would ask
> someone to create a additional device. it looks (at least for now) that
> we can address those issues in zram-zsmalloc entirely; w/o user
> intervention or a 3rd party device.

Agree. That's what I want. zram shouldn't be aware of allocator's
internal implementation. IOW, zsmalloc should handle it without
exposing any internal limitation.
Backing device issue is orthogonal but what I said about thing
was it could solve the issue too without exposing zsmalloc's
limitation to the zram.

Let's summary my points in here.

Let's make zsmalloc smarter to reduce wasted space. One of option is
dynamic page creation which I agreed.

Before the feature, we should test how memory footprint is bigger
without the feature if we increase ZS_MAX_ZSPAGE_ORDER.
If it's not big, we could go with your patch easily without adding
more complex stuff(i.e, dynamic page creation).

Please, check max_used_pages rather than mem_used_total for seeing
memory footprint at the some moment and test very fragmented scenario
(creating files and free part of files) rather than just full coping.

If memory footprint is high, we can decide to go dynamic page
creation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
