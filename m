Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id CBEC16B0253
	for <linux-mm@kvack.org>; Thu, 24 Sep 2015 22:12:15 -0400 (EDT)
Received: by igcpb10 with SMTP id pb10so2309779igc.1
        for <linux-mm@kvack.org>; Thu, 24 Sep 2015 19:12:15 -0700 (PDT)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id o186si1193188ioe.63.2015.09.24.19.12.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Sep 2015 19:12:15 -0700 (PDT)
Received: by padhy16 with SMTP id hy16so90255839pad.1
        for <linux-mm@kvack.org>; Thu, 24 Sep 2015 19:12:14 -0700 (PDT)
Date: Fri, 25 Sep 2015 11:13:54 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2] zbud: allow up to PAGE_SIZE allocations
Message-ID: <20150925021325.GA16431@bbox>
References: <20150922141733.d7d97f59f207d0655c3b881d@gmail.com>
 <20150923031845.GA31207@cerebellum.local.variantweb.net>
 <CAMJBoFOEYv05FZqDER9hw79re4vrc3wKwGeuL=uoGbCnwodH8Q@mail.gmail.com>
 <20150923215726.GA17171@cerebellum.local.variantweb.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150923215726.GA17171@cerebellum.local.variantweb.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjennings@variantweb.net>
Cc: Vitaly Wool <vitalywool@gmail.com>, Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

Hello,

On Wed, Sep 23, 2015 at 04:57:26PM -0500, Seth Jennings wrote:
> On Wed, Sep 23, 2015 at 09:54:02AM +0200, Vitaly Wool wrote:
> > On Wed, Sep 23, 2015 at 5:18 AM, Seth Jennings <sjennings@variantweb.net> wrote:
> > > On Tue, Sep 22, 2015 at 02:17:33PM +0200, Vitaly Wool wrote:
> > >> Currently zbud is only capable of allocating not more than
> > >> PAGE_SIZE - ZHDR_SIZE_ALIGNED - CHUNK_SIZE. This is okay as
> > >> long as only zswap is using it, but other users of zbud may
> > >> (and likely will) want to allocate up to PAGE_SIZE. This patch
> > >> addresses that by skipping the creation of zbud internal
> > >> structure in the beginning of an allocated page (such pages are
> > >> then called 'headless').
> > >
> > > I guess I'm having trouble with this.  If you store a PAGE_SIZE
> > > allocation in zbud, then the zpage can only have one allocation as there
> > > is no room for a buddy.  Sooooo... we have an allocator for that: the
> > > page allocator.
> > >
> > > zbud doesn't support this by design because, if you are only storing one
> > > allocation per page, you don't gain anything.
> > >
> > > This functionality creates many new edge cases for the code.
> > >
> > > What is this use case you envision?  I think we need to discuss
> > > whether the use case exists and if it justifies the added complexity.
> > 
> > The use case is to use zram with zbud as allocator via the common
> > zpool api. Sometimes determinism and better worst-case time are more
> > important than high compression ratio.
> > As far as I can see, I'm not the only one who wants this case
> > supported in mainline.
> 
> Ok, I can see that having the allocator backends for zpool 
> have the same set of constraints is nice.

Sorry for delay. I'm on vacation until next week.
It seems Seth was missed in previous discusstion which was not the end.

I already said questions, opinion and concerns but anything is not clear
until now. Only clear thing I could hear is just "compaction stats are
better" which is not enough for me. Sorry.

1) https://lkml.org/lkml/2015/9/15/33
2) https://lkml.org/lkml/2015/9/21/2

Vitally, Please say what's the root cause of your problem and if it
is external fragmentation, what's the problem of my approach?

1) make non-LRU page migrate
2) provide zsmalloc's migratpage

We should provide it for CMA as well as external fragmentation.
I think we could solve your issue with above approach and
it fundamentally makes zsmalloc/zbud happy in future.

Also, please keep it in mind that zram has been in linux kernel for
memory efficiency for a long time and later zswap/zbud was born
for *determinism* at the cost of memory efficiency.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
