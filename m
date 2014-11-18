Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id 1DB156B0038
	for <linux-mm@kvack.org>; Tue, 18 Nov 2014 18:01:42 -0500 (EST)
Received: by mail-ig0-f178.google.com with SMTP id hl2so5141734igb.5
        for <linux-mm@kvack.org>; Tue, 18 Nov 2014 15:01:41 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 14si17743050iog.87.2014.11.18.15.01.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Nov 2014 15:01:41 -0800 (PST)
Date: Tue, 18 Nov 2014 15:01:38 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] zsmalloc: correct fragile [kmap|kunmap]_atomic use
Message-Id: <20141118150138.668c81fda55c3ce39d7b2aac@linux-foundation.org>
In-Reply-To: <20141114150732.GA2402@cerebellum.variantweb.net>
References: <1415927461-14220-1-git-send-email-minchan@kernel.org>
	<20141114150732.GA2402@cerebellum.variantweb.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjennings@variantweb.net>
Cc: Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Dan Streetman <ddstreet@ieee.org>, Jerome Marchand <jmarchan@redhat.com>

On Fri, 14 Nov 2014 09:07:32 -0600 Seth Jennings <sjennings@variantweb.net> wrote:

> On Fri, Nov 14, 2014 at 10:11:01AM +0900, Minchan Kim wrote:
> > The kunmap_atomic should use virtual address getting by kmap_atomic.
> > However, some pieces of code in zsmalloc uses modified address,
> > not the one got by kmap_atomic for kunmap_atomic.
> > 
> > It's okay for working because zsmalloc modifies the address
> > inner PAGE_SIZE bounday so it works with current kmap_atomic's
> > implementation. But it's still fragile with potential changing
> > of kmap_atomic so let's correct it.

It is a bit alarming, but I've seen code elsewhere in which a modified
pointer is passed to kunmap_atomic().  So the kunmap_atomic() interface
is "kvaddr should point somewhere into the page" and that won't be
changing without a big effort.

> Seems like you could just use PAGE_MASK to get the base page address
> from link like this:

I think Minchan's approach is better: it explicitly retains the
kmap_atomic() return value for passing to kunmap_atomic().  That's
nicer than modifying it and then setting it back again.

I mean, a cleaner way of implementing your suggestion would be

void kunmap_atomic_unaligned(void *p)
{
	kunmap_atomic(void *)((unsigned long)p & PAGE_MASK);
}

but then one looks at

void __kunmap_atomic(void *kvaddr)
{
	unsigned long vaddr = (unsigned long) kvaddr & PAGE_MASK;

and asks "what the heck".


So I dunno.  We could leave the code as-is.  I have no strong feelings
either way.  Minchan's patch has no effect on zsmalloc.o section sizes
with my compiler.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
