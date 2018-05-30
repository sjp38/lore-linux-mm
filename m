Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6BEDA6B0005
	for <linux-mm@kvack.org>; Wed, 30 May 2018 11:41:12 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id d4-v6so11485115plr.17
        for <linux-mm@kvack.org>; Wed, 30 May 2018 08:41:12 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id w69-v6si11445624pgd.101.2018.05.30.08.41.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 30 May 2018 08:41:11 -0700 (PDT)
Date: Wed, 30 May 2018 08:41:10 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm: dmapool: Check the dma pool name
Message-ID: <20180530154110.GA22184@bombadil.infradead.org>
References: <59623b15001e5a20ac32b1a393db88722be2e718.1527679621.git.baolin.wang@linaro.org>
 <20180530120133.GC17450@bombadil.infradead.org>
 <CAMz4ku+fBt2uY6MbiMX1X-6jtjdpqp=DWNMrefOG4SsUHWN4kQ@mail.gmail.com>
 <20180530151327.GA13951@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180530151327.GA13951@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Baolin Wang <baolin.wang@linaro.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Mark Brown <broonie@kernel.org>

On Wed, May 30, 2018 at 08:13:27AM -0700, Matthew Wilcox wrote:
> On Wed, May 30, 2018 at 08:14:09PM +0800, Baolin Wang wrote:
> > On 30 May 2018 at 20:01, Matthew Wilcox <willy@infradead.org> wrote:
> > > On Wed, May 30, 2018 at 07:28:43PM +0800, Baolin Wang wrote:
> > >> It will be crash if we pass one NULL name when creating one dma pool,
> > >> so we should check the passing name when copy it to dma pool.
> > >
> > > NAK.  Crashing is the appropriate thing to do.  Fix the caller to not
> > > pass NULL.
> > >
> > > If you permit NULL to be passed then you're inviting crashes or just
> > > bad reporting later when pool->name is printed.
> > 
> > I think it just prints one NULL pool name. Sometimes the device
> > doesn't care the dma pool names, so I think we can make code more
> > solid to valid the passing parameters like other code does.
> > Or can we add check to return NULL when the passing name is NULL
> > instead of crashing the kernel? Thanks.
> 
> No.  Fix your driver.

Let me elaborate on this.  Kernel code is supposed to be "reasonable".
That means we don't check every argument to every function for sanity,
unless it's going to cause trouble later.  Crashing immediately with
a bogus argument is fine; you can see the problem and fix it immediately.
Returning NULL with a bad argument is actually worse; you won't know why
the function returned NULL (maybe we're out of memory?) and you'll have
a more complex debugging experience.

Sometimes it makes sense to accept a NULL pointer and do something
reasonable, like kfree().  In this case, we can eliminate checks in all
the callers.  But we don't, in general, put sanity checks on arguments
without a good reason.

Your reasons aren't good.  "The driver doesn't care" -- well, just pass
the driver's name, then.
