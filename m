Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 663726B0038
	for <linux-mm@kvack.org>; Tue, 18 Nov 2014 18:21:12 -0500 (EST)
Received: by mail-pd0-f182.google.com with SMTP id r10so40080pdi.41
        for <linux-mm@kvack.org>; Tue, 18 Nov 2014 15:21:12 -0800 (PST)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id gz1si67876pbc.65.2014.11.18.15.21.08
        for <linux-mm@kvack.org>;
        Tue, 18 Nov 2014 15:21:10 -0800 (PST)
Date: Wed, 19 Nov 2014 08:21:39 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] zsmalloc: correct fragile [kmap|kunmap]_atomic use
Message-ID: <20141118232139.GA7393@bbox>
References: <1415927461-14220-1-git-send-email-minchan@kernel.org>
 <20141114150732.GA2402@cerebellum.variantweb.net>
 <20141118150138.668c81fda55c3ce39d7b2aac@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20141118150138.668c81fda55c3ce39d7b2aac@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Seth Jennings <sjennings@variantweb.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Dan Streetman <ddstreet@ieee.org>, Jerome Marchand <jmarchan@redhat.com>

Hello Andrew,

On Tue, Nov 18, 2014 at 03:01:38PM -0800, Andrew Morton wrote:
> On Fri, 14 Nov 2014 09:07:32 -0600 Seth Jennings <sjennings@variantweb.net> wrote:
> 
> > On Fri, Nov 14, 2014 at 10:11:01AM +0900, Minchan Kim wrote:
> > > The kunmap_atomic should use virtual address getting by kmap_atomic.
> > > However, some pieces of code in zsmalloc uses modified address,
> > > not the one got by kmap_atomic for kunmap_atomic.
> > > 
> > > It's okay for working because zsmalloc modifies the address
> > > inner PAGE_SIZE bounday so it works with current kmap_atomic's
> > > implementation. But it's still fragile with potential changing
> > > of kmap_atomic so let's correct it.
> 
> It is a bit alarming, but I've seen code elsewhere in which a modified
> pointer is passed to kunmap_atomic().  So the kunmap_atomic() interface
> is "kvaddr should point somewhere into the page" and that won't be
> changing without a big effort.
> 
> > Seems like you could just use PAGE_MASK to get the base page address
> > from link like this:
> 
> I think Minchan's approach is better: it explicitly retains the
> kmap_atomic() return value for passing to kunmap_atomic().  That's
> nicer than modifying it and then setting it back again.
> 
> I mean, a cleaner way of implementing your suggestion would be
> 
> void kunmap_atomic_unaligned(void *p)
> {
> 	kunmap_atomic(void *)((unsigned long)p & PAGE_MASK);
> }
> 
> but then one looks at
> 
> void __kunmap_atomic(void *kvaddr)
> {
> 	unsigned long vaddr = (unsigned long) kvaddr & PAGE_MASK;
> 
> and asks "what the heck".
> 
> 
> So I dunno.  We could leave the code as-is.  I have no strong feelings
> either way.  Minchan's patch has no effect on zsmalloc.o section sizes
> with my compiler.

I hope to merge my patch.

Main reason I sent the patch is I got a subtle bug when I implement
new feature of zsmalloc(ie, compaction) due to link's mishandling
(ie, link was over page boundary by my fault).
Although it was totally my mistake, it took time for a while
to find a root cause because unpredictable kmapped address should
be unmapped so it's almost random crash.

IOW, it's fragile to depend on kunmap_atomic's internal and at least,
I wanted to make zram code more robust.

Thanks.

> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
