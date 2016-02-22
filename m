Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f182.google.com (mail-pf0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 041C36B0009
	for <linux-mm@kvack.org>; Sun, 21 Feb 2016 20:57:57 -0500 (EST)
Received: by mail-pf0-f182.google.com with SMTP id q63so83718707pfb.0
        for <linux-mm@kvack.org>; Sun, 21 Feb 2016 17:57:56 -0800 (PST)
Received: from mail-pf0-x22e.google.com (mail-pf0-x22e.google.com. [2607:f8b0:400e:c00::22e])
        by mx.google.com with ESMTPS id 70si36030190pfk.205.2016.02.21.17.57.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 Feb 2016 17:57:55 -0800 (PST)
Received: by mail-pf0-x22e.google.com with SMTP id e127so83908606pfe.3
        for <linux-mm@kvack.org>; Sun, 21 Feb 2016 17:57:55 -0800 (PST)
Date: Mon, 22 Feb 2016 10:59:12 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [RFC][PATCH v2 2/3] zram: use zs_get_huge_class_size_watermark()
Message-ID: <20160222015912.GA488@swordfish>
References: <1456061274-20059-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1456061274-20059-3-git-send-email-sergey.senozhatsky@gmail.com>
 <20160222000436.GA21710@bbox>
 <20160222004047.GA4958@swordfish>
 <20160222012758.GA27829@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160222012758.GA27829@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On (02/22/16 10:27), Minchan Kim wrote:
[..]
> > zram asks to store a PAGE_SIZE sized object, what zsmalloc can
> > possible do about this?
> 
> zsmalloc can increase ZS_MAX_ZSPAGE_ORDER or can save metadata in
> the extra space. In fact, I tried interlink approach long time ago.
> For example, class-A -> class-B 
> 
>         A = x, B = (4096 - y) >= x
>
> The problem was class->B zspage consumes memory although there is
> no object in the zspage because class-A object in the extra space
> of class-B pin the class-B zspage.

I thought about it too -- utilizing 'unused space' to store there
smaller objects. and I think it potentially has more problems.
compaction (and everything) seem to be much simpler when we have only
objects of size-X in class_size X.

> I prefer your ZS_MAX_ZSPAGE_ORDER increaing approach but as I told
> in that thread, we should prepare dynamic creating of sub-page
> in zspage.

I agree that in general dynamic class page allocation sounds
interesting enough.

> > > Having said that, I agree your claim that uncompressible pages
> > > are pain. I want to handle the problem as multiple-swap apparoach.
> > 
> > zram is not just for swapping. as simple as that.
> 
> Yes, I mean if we have backing storage, we could mitigate the problem
> like the mentioned approach. Otherwise, we should solve it in allocator
> itself and you suggested the idea and I commented first step.
> What's the problem, now?

well, I didn't say I have problems.
so you want a backing device that will keep only 'bad compression'
objects and use zsmalloc to keep there only 'good compression' objects?
IOW, no huge classes in zsmalloc at all? well, that can work out. it's
a bit strange though that to solve zram-zsmalloc issues we would ask
someone to create a additional device. it looks (at least for now) that
we can address those issues in zram-zsmalloc entirely; w/o user
intervention or a 3rd party device.

> > > For that, we should introduce new knob in zram layer like Nitin
> > > did and make it configurable so we could solve the problem of
> > > single zram-swap system as well as multiple swap system.
> > 
> > a 'bad compression' watermark knob? isn't it an absolutely low level
> > thing no one ever should see?
> 
> It's a knob to determine that how to handle incompressible page
> in zram layer. For example, admin can tune it to 2048. It means
> if we have backing store and compressed ratio is under 50%,
> admin want to pass the page into swap storage. If the system
> is no backed store, it means admin want to avoid decompress
> overhead if the ratio is smaller.

I see your point.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
