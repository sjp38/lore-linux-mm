Received: from toomuch.toronto.redhat.com (toomuch.toronto.redhat.com [172.16.14.22])
	by lacrosse.corp.redhat.com (8.9.3/8.9.3) with ESMTP id WAA11295
	for <linux-mm@kvack.org>; Sun, 8 Jul 2001 22:45:13 -0400
Date: Thu, 5 Jul 2001 11:53:01 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: Large PAGE_SIZE
In-Reply-To: <Pine.LNX.4.21.0107051911130.2904-100000@localhost.localdomain>
Message-ID: <Pine.LNX.4.33.0107051148430.22414-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
ReSent-To: <linux-mm@kvack.org>
ReSent-Message-ID: <Pine.LNX.4.33.0107082243570.30164@toomuch.toronto.redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Ben LaHaise <bcrl@redhat.com>
List-ID: <linux-mm.kvack.org>

On Thu, 5 Jul 2001, Hugh Dickins wrote:
> On Thu, 5 Jul 2001, Linus Torvalds wrote:
> >
> > Also note that the I/O _would_ happen in PAGE_CACHE_SIZE - you'd never
> > break it into smaller chunks. That's the whole point of having a bigger
> > PAGE_CACHE_SIZE.
>
> Aha, are you saying that a part of the multipage PAGE_CACHE_SIZE project
> is to go through the block layer and driver layer, changing appropriate
> "PAGE_SIZE"s to "PAGE_CACHE_SIZE"s (whereas at present PAGE_CACHE_SIZE
> is pretty much confined to the FS layer), so that the I/O isn't split?

Any block devices that do that are already broken. Block drivers always
get physical addresses, they shouldn't care. The one exception is the kmap
case, where the programmed-IO thing needs the virtual re-mapping, but as I
already stated earlier I think kmap should always map the biggest chunk so
that nobody ever tries to loop over multiple pages if they don't have to.

Of course, the people playing with direct-IO from user space will always
be limited by the mapping size.

So in general, the block layer should not care AT ALL, and just use the
physical addresses passed in to it. For things like bounce buffers, YES,
we should make sure that the bounce buffers are at least the size of
PAGE_CACHE_SIZE.

> It may come down to Ben having 2**N more struct pages than I do:
> greater flexibility, but significant waste of kernel virtual.

The waste of kernel virtual memory space is actually a good point. Already
on big x86 machines the "struct page[]" array is a big memory-user. That
may indeed be the biggest argument for increasing PAGE_SIZE.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
