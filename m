Received: from toomuch.toronto.redhat.com (toomuch.toronto.redhat.com [172.16.14.22])
	by lacrosse.corp.redhat.com (8.9.3/8.9.3) with ESMTP id WAA11328
	for <linux-mm@kvack.org>; Sun, 8 Jul 2001 22:45:27 -0400
Date: Thu, 5 Jul 2001 16:41:58 -0400 (EDT)
From: Ben LaHaise <bcrl@redhat.com>
Subject: Re: Large PAGE_SIZE
In-Reply-To: <Pine.LNX.4.33.0107051148430.22414-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.33.0107051613540.1702-100000@toomuch.toronto.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
ReSent-To: <linux-mm@kvack.org>
ReSent-Message-ID: <Pine.LNX.4.33.0107082244130.30164@toomuch.toronto.redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Thu, 5 Jul 2001, Linus Torvalds wrote:

> > It may come down to Ben having 2**N more struct pages than I do:
> > greater flexibility, but significant waste of kernel virtual.
>
> The waste of kernel virtual memory space is actually a good point. Already
> on big x86 machines the "struct page[]" array is a big memory-user. That
> may indeed be the biggest argument for increasing PAGE_SIZE.

I think the two patches will be complementary as they have different
effects.  Basically, we want to limit the degree which PAGE_SIZE increases
as increasing it too much can result in increased memory usage and
overhead for COW.  PAGE_CACHE_SIZE probably wants to be increased further,
simply to improve io efficiency.

On the topic of struct page size, yes it is too large.  There are a few
things we can do here to make things more efficient, like seperating the
notition of struct page and the page cache, but we have to be careful not
to split things up too much as 64 bytes is ideal for processors like the
Athlon, whereas the P4 really wants 128 byte to avoid false cache line
sharing on SMP.  I've got a few ideas on the page cache front to explore
in the next month or two that could result in another 12 bytes of savings
per page, plus we can look into other things like reducing the overhead of
the wait queue and the other contents of struct page.

		-ben

ps, would you mind if I forward the messages in this thread to linux-mm so
that other people can see the discussion?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
