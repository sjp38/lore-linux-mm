Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id C0C286B0255
	for <linux-mm@kvack.org>; Wed, 23 Sep 2015 03:54:03 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so226489666wic.0
        for <linux-mm@kvack.org>; Wed, 23 Sep 2015 00:54:03 -0700 (PDT)
Received: from mail-wi0-x22f.google.com (mail-wi0-x22f.google.com. [2a00:1450:400c:c05::22f])
        by mx.google.com with ESMTPS id r14si7782558wjw.64.2015.09.23.00.54.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Sep 2015 00:54:02 -0700 (PDT)
Received: by wiclk2 with SMTP id lk2so226489272wic.0
        for <linux-mm@kvack.org>; Wed, 23 Sep 2015 00:54:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150923031845.GA31207@cerebellum.local.variantweb.net>
References: <20150922141733.d7d97f59f207d0655c3b881d@gmail.com>
	<20150923031845.GA31207@cerebellum.local.variantweb.net>
Date: Wed, 23 Sep 2015 09:54:02 +0200
Message-ID: <CAMJBoFOEYv05FZqDER9hw79re4vrc3wKwGeuL=uoGbCnwodH8Q@mail.gmail.com>
Subject: Re: [PATCH v2] zbud: allow up to PAGE_SIZE allocations
From: Vitaly Wool <vitalywool@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjennings@variantweb.net>
Cc: Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Wed, Sep 23, 2015 at 5:18 AM, Seth Jennings <sjennings@variantweb.net> wrote:
> On Tue, Sep 22, 2015 at 02:17:33PM +0200, Vitaly Wool wrote:
>> Currently zbud is only capable of allocating not more than
>> PAGE_SIZE - ZHDR_SIZE_ALIGNED - CHUNK_SIZE. This is okay as
>> long as only zswap is using it, but other users of zbud may
>> (and likely will) want to allocate up to PAGE_SIZE. This patch
>> addresses that by skipping the creation of zbud internal
>> structure in the beginning of an allocated page (such pages are
>> then called 'headless').
>
> I guess I'm having trouble with this.  If you store a PAGE_SIZE
> allocation in zbud, then the zpage can only have one allocation as there
> is no room for a buddy.  Sooooo... we have an allocator for that: the
> page allocator.
>
> zbud doesn't support this by design because, if you are only storing one
> allocation per page, you don't gain anything.
>
> This functionality creates many new edge cases for the code.
>
> What is this use case you envision?  I think we need to discuss
> whether the use case exists and if it justifies the added complexity.

The use case is to use zram with zbud as allocator via the common
zpool api. Sometimes determinism and better worst-case time are more
important than high compression ratio.
As far as I can see, I'm not the only one who wants this case
supported in mainline.

> We are crossing a boundary into zsmalloc style complexity with storing
> stuff in the struct page, something I really didn't want to do in zbud.

Well, the thing is we need PAGE_SIZE allocations supported to use zram
with zbud. I can of course add the code handling this in zpool but I
am quite sure doing that in zbud directly is a better idea. I'm very
keen on keeping the complexity down as much as possible though.

> zbud is the simple one, zsmalloc is the complex one.  I'd hate to have
> two complex ones :-/

Who am I to disagree :) Keeping zbud simple is my goal, too, but once
again, I'd really like it to support PAGE_SIZE allocations. And if it
doesn't, the whole zpool thing for it becomes useless, since there
will hardly be any zbud users other than zswap.

~vitaly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
