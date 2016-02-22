Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id 3753B6B0009
	for <linux-mm@kvack.org>; Sun, 21 Feb 2016 20:27:43 -0500 (EST)
Received: by mail-ig0-f170.google.com with SMTP id 5so71925743igt.0
        for <linux-mm@kvack.org>; Sun, 21 Feb 2016 17:27:43 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id p66si7290544ioe.77.2016.02.21.17.27.41
        for <linux-mm@kvack.org>;
        Sun, 21 Feb 2016 17:27:42 -0800 (PST)
Date: Mon, 22 Feb 2016 10:27:58 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC][PATCH v2 2/3] zram: use zs_get_huge_class_size_watermark()
Message-ID: <20160222012758.GA27829@bbox>
References: <1456061274-20059-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1456061274-20059-3-git-send-email-sergey.senozhatsky@gmail.com>
 <20160222000436.GA21710@bbox>
 <20160222004047.GA4958@swordfish>
MIME-Version: 1.0
In-Reply-To: <20160222004047.GA4958@swordfish>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Feb 22, 2016 at 09:40:47AM +0900, Sergey Senozhatsky wrote:
> On (02/22/16 09:04), Minchan Kim wrote:
> [..]
> > max_zpage_size was there since zram's grandpa(ie, ramzswap).
> > AFAIR, at that time, it works to forward incompressible
> > (e.g, PAGE_SIZE/2) page to backing swap if it presents.
> > If it doesn't have any backing swap and it's incompressbile
> > (e.g, PAGE_SIZE*3/4), it stores it as uncompressed page
> > to avoid *decompress* overhead later.
> 
> "PAGE_SIZE * 3 / 4" introduces a bigger memory overhead than
> decompression of 3K bytes later.
> 
> > And Nitin want to make it as tunable parameter. I agree the
> > approach because I don't want to make coupling between zram
> > and allocator as far as possible.
> > 
> > If huge class is pain
> 
> they are.
> 
> > it's allocator problem, not zram stuff.
> 
> the allocator's problems start at the point where zram begins to have
> opinion on what should be stored as ->huge object and what should not.
> it's not up to zram to enforce this.
> 
> 
> > I think we should try to remove such problem in zsmalloc layer,
> > firstly.
> 
> zram asks to store a PAGE_SIZE sized object, what zsmalloc can
> possible do about this?

zsmalloc can increase ZS_MAX_ZSPAGE_ORDER or can save metadata in
the extra space. In fact, I tried interlink approach long time ago.
For example, class-A -> class-B 

        A = x, B = (4096 - y) >= x

The problem was class->B zspage consumes memory although there is
no object in the zspage because class-A object in the extra space
of class-B pin the class-B zspage.

I prefer your ZS_MAX_ZSPAGE_ORDER increaing approach but as I told
in that thread, we should prepare dynamic creating of sub-page
in zspage.

> 
> 
> > Having said that, I agree your claim that uncompressible pages
> > are pain. I want to handle the problem as multiple-swap apparoach.
> 
> zram is not just for swapping. as simple as that.

Yes, I mean if we have backing storage, we could mitigate the problem
like the mentioned approach. Otherwise, we should solve it in allocator
itself and you suggested the idea and I commented first step.
What's the problem, now?

> 
> 
> and enforcing a multi-swap approach on folks who use zram for swap
> doesn't look right to me.

Ditto.

> 
> 
> > For that, we should introduce new knob in zram layer like Nitin
> > did and make it configurable so we could solve the problem of
> > single zram-swap system as well as multiple swap system.
> 
> a 'bad compression' watermark knob? isn't it an absolutely low level
> thing no one ever should see?

It's a knob to determine that how to handle incompressible page
in zram layer. For example, admin can tune it to 2048. It means
if we have backing store and compressed ratio is under 50%,
admin want to pass the page into swap storage. If the system
is no backed store, it means admin want to avoid decompress
overhead if the ratio is smaller.

I don't think it's a low level thing.



> 
> 	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
