Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 3C5986B0009
	for <linux-mm@kvack.org>; Sun, 21 Feb 2016 19:39:31 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id ho8so83486695pac.2
        for <linux-mm@kvack.org>; Sun, 21 Feb 2016 16:39:31 -0800 (PST)
Received: from mail-pf0-x22d.google.com (mail-pf0-x22d.google.com. [2607:f8b0:400e:c00::22d])
        by mx.google.com with ESMTPS id o12si35562924pfa.162.2016.02.21.16.39.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 Feb 2016 16:39:30 -0800 (PST)
Received: by mail-pf0-x22d.google.com with SMTP id c10so85507615pfc.2
        for <linux-mm@kvack.org>; Sun, 21 Feb 2016 16:39:30 -0800 (PST)
Date: Mon, 22 Feb 2016 09:40:47 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [RFC][PATCH v2 2/3] zram: use zs_get_huge_class_size_watermark()
Message-ID: <20160222004047.GA4958@swordfish>
References: <1456061274-20059-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1456061274-20059-3-git-send-email-sergey.senozhatsky@gmail.com>
 <20160222000436.GA21710@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160222000436.GA21710@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On (02/22/16 09:04), Minchan Kim wrote:
[..]
> max_zpage_size was there since zram's grandpa(ie, ramzswap).
> AFAIR, at that time, it works to forward incompressible
> (e.g, PAGE_SIZE/2) page to backing swap if it presents.
> If it doesn't have any backing swap and it's incompressbile
> (e.g, PAGE_SIZE*3/4), it stores it as uncompressed page
> to avoid *decompress* overhead later.

"PAGE_SIZE * 3 / 4" introduces a bigger memory overhead than
decompression of 3K bytes later.

> And Nitin want to make it as tunable parameter. I agree the
> approach because I don't want to make coupling between zram
> and allocator as far as possible.
> 
> If huge class is pain

they are.

> it's allocator problem, not zram stuff.

the allocator's problems start at the point where zram begins to have
opinion on what should be stored as ->huge object and what should not.
it's not up to zram to enforce this.


> I think we should try to remove such problem in zsmalloc layer,
> firstly.

zram asks to store a PAGE_SIZE sized object, what zsmalloc can
possible do about this?


> Having said that, I agree your claim that uncompressible pages
> are pain. I want to handle the problem as multiple-swap apparoach.

zram is not just for swapping. as simple as that.


and enforcing a multi-swap approach on folks who use zram for swap
doesn't look right to me.


> For that, we should introduce new knob in zram layer like Nitin
> did and make it configurable so we could solve the problem of
> single zram-swap system as well as multiple swap system.

a 'bad compression' watermark knob? isn't it an absolutely low level
thing no one ever should see?

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
