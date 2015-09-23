Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	by kanga.kvack.org (Postfix) with ESMTP id 373B56B0253
	for <linux-mm@kvack.org>; Wed, 23 Sep 2015 17:57:31 -0400 (EDT)
Received: by qgx61 with SMTP id 61so30950288qgx.3
        for <linux-mm@kvack.org>; Wed, 23 Sep 2015 14:57:31 -0700 (PDT)
Received: from smtp.variantweb.net (smtp.variantweb.net. [104.131.104.118])
        by mx.google.com with ESMTPS id z62si8804429qhd.36.2015.09.23.14.57.30
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Sep 2015 14:57:30 -0700 (PDT)
Date: Wed, 23 Sep 2015 16:57:26 -0500
From: Seth Jennings <sjennings@variantweb.net>
Subject: Re: [PATCH v2] zbud: allow up to PAGE_SIZE allocations
Message-ID: <20150923215726.GA17171@cerebellum.local.variantweb.net>
References: <20150922141733.d7d97f59f207d0655c3b881d@gmail.com>
 <20150923031845.GA31207@cerebellum.local.variantweb.net>
 <CAMJBoFOEYv05FZqDER9hw79re4vrc3wKwGeuL=uoGbCnwodH8Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAMJBoFOEYv05FZqDER9hw79re4vrc3wKwGeuL=uoGbCnwodH8Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Wool <vitalywool@gmail.com>
Cc: Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Wed, Sep 23, 2015 at 09:54:02AM +0200, Vitaly Wool wrote:
> On Wed, Sep 23, 2015 at 5:18 AM, Seth Jennings <sjennings@variantweb.net> wrote:
> > On Tue, Sep 22, 2015 at 02:17:33PM +0200, Vitaly Wool wrote:
> >> Currently zbud is only capable of allocating not more than
> >> PAGE_SIZE - ZHDR_SIZE_ALIGNED - CHUNK_SIZE. This is okay as
> >> long as only zswap is using it, but other users of zbud may
> >> (and likely will) want to allocate up to PAGE_SIZE. This patch
> >> addresses that by skipping the creation of zbud internal
> >> structure in the beginning of an allocated page (such pages are
> >> then called 'headless').
> >
> > I guess I'm having trouble with this.  If you store a PAGE_SIZE
> > allocation in zbud, then the zpage can only have one allocation as there
> > is no room for a buddy.  Sooooo... we have an allocator for that: the
> > page allocator.
> >
> > zbud doesn't support this by design because, if you are only storing one
> > allocation per page, you don't gain anything.
> >
> > This functionality creates many new edge cases for the code.
> >
> > What is this use case you envision?  I think we need to discuss
> > whether the use case exists and if it justifies the added complexity.
> 
> The use case is to use zram with zbud as allocator via the common
> zpool api. Sometimes determinism and better worst-case time are more
> important than high compression ratio.
> As far as I can see, I'm not the only one who wants this case
> supported in mainline.

Ok, I can see that having the allocator backends for zpool 
have the same set of constraints is nice.

I'll look at your latest patch.

Thanks,
Seth

> 
> > We are crossing a boundary into zsmalloc style complexity with storing
> > stuff in the struct page, something I really didn't want to do in zbud.
> 
> Well, the thing is we need PAGE_SIZE allocations supported to use zram
> with zbud. I can of course add the code handling this in zpool but I
> am quite sure doing that in zbud directly is a better idea. I'm very
> keen on keeping the complexity down as much as possible though.
> 
> > zbud is the simple one, zsmalloc is the complex one.  I'd hate to have
> > two complex ones :-/
> 
> Who am I to disagree :) Keeping zbud simple is my goal, too, but once
> again, I'd really like it to support PAGE_SIZE allocations. And if it
> doesn't, the whole zpool thing for it becomes useless, since there
> will hardly be any zbud users other than zswap.
> 
> ~vitaly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
