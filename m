Date: Mon, 2 Oct 2000 14:19:30 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [highmem bug report against -test5 and -test6] Re: [PATCH] Re:
 simple FS application that hangs 2.4-test5, mem mgmt problem or FS buffer
 cache mgmt problem? (fwd)
In-Reply-To: <Pine.LNX.4.21.0010022218460.11418-100000@elte.hu>
Message-ID: <Pine.LNX.4.10.10010021417200.826-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>


On Mon, 2 Oct 2000, Ingo Molnar wrote:
> 
> On Mon, 2 Oct 2000, Linus Torvalds wrote:
> 
> > I agree. Most of the time, there's absolutely no point in keeping the
> > buffer heads around. Most pages (and _especially_ the actively mapped
> > ones) do not need the buffer heads at all after creation - once they
> > are uptodate they stay uptodate and we're only interested in the page,
> > not the buffers used to create it.
> 
> except for writes, there we cache the block # in the bh and do not have to
> call the lowlevel FS repeatedly to calculate the FS position of the page.

Oh, I agree 100%.

Note that this is why I think we should just do it the way we used to
handle it: we keep the buffer heads around "indefinitely" (because we
_may_ need them - we don't know a priori one way or the other), but
because they _do_ potentially use up a lot of memory we do free them in
the normal aging process when we're low on memory.

So if we have "lots" of memory, we basically optimize for speed (leave the
cached mapping around), while if we get low on memory we automatically
optimize for space (get rid of bh's when we don't know that we'll need
them).

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
