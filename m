Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 50EDD6B0055
	for <linux-mm@kvack.org>; Sun, 31 May 2009 13:05:41 -0400 (EDT)
Date: Sun, 31 May 2009 10:05:36 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH] Use kzfree in tty buffer management to enforce data
 sanitization
In-Reply-To: <20090531112630.2c7f4f1d@lxorguk.ukuu.org.uk>
Message-ID: <alpine.LFD.2.01.0905311002010.3435@localhost.localdomain>
References: <20090531015537.GA8941@oblivion.subreption.com> <alpine.LFD.2.01.0905301902530.3435@localhost.localdomain> <84144f020905302324r5e342f2dlfd711241ecfc8374@mail.gmail.com> <20090531112630.2c7f4f1d@lxorguk.ukuu.org.uk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-14
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, "Larry H." <research@subreption.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>



On Sun, 31 May 2009, Alan Cox wrote:

> > >        memset(buf->data, 0, N_TTY_BUF_SIZE);
> > >        if (PAGE_SIZE != N_TTY_BUF_SIZE)
> > >                kfree(...)
> > >        else
> > >                free_page(...)
> > >
> > >
> > > but quite frankly, I'm not convinced about these patches at all.
> > 
> > I wonder why the tty code has that N_TTY_BUF_SIZE special casing in
> > the first place? I think we can probably just get rid of it and thus
> > we can use kzfree() here if we want to.
> 
> Some platforms with very large page sizes override the use of page based
> allocators (eg older ARM would go around allocating 32K). The normal path
> is 4K or 8K page sized buffers.

I think Pekka meant the other way around - why don't we always just use 
kmalloc(N_TTY_BUF_SIZE)/kfree(), and drop the whole conditional "use page 
allocator" entirely?

I suspect the "use page allocator" is historical - ie the tty layer 
originally always did that, and then when people wanted to suppotr smaller 
areas than one page, they added the special case. I have this dim memory 
of the _original_ kmalloc not handling page-sized allocations well (due to 
embedded size/pointer overheads), but I think all current allocators are 
perfectly happy to allocate PAGE_SIZE buffers without slop.

If I'm right, then we could just use kmalloc/kfree unconditionally. Pekka?

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
