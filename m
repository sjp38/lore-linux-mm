Date: Mon, 15 May 2000 11:29:36 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [patch] VM stable again?
In-Reply-To: <Pine.LNX.4.21.0005151157240.20410-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.10.10005151122300.3637-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Mon, 15 May 2000, Rik van Riel wrote:
> 
> the patch below makes sure processes won't "eat" the pages
> another process is freeing and seems to avoid the nasty
> out of memory situations that people have seen.

Hmm.. The patch has an obvious leak: if the allocation ever fails, every
single allocator ever afterwards will be forced to try to free stuff,
simply because "free_before_allocate" wasn't decremented correctly. Which
is certainly not the right behaviour.

Also, this seems to assume that the regular reason for "out of memory" is
that the free lists emptied up while we were paging stuff out, which I do
not think is necessarily the full truth. I've definitely seen the simpler
case: just an overly eager failure from "try_to_free_pages()", which this
patch does not address.

That said, I think this patch is definitely conceptually the right thing:
it just says that while somebody else (not kswapd) is trying to free up
memory, nobody else should starve him out. I like the concept. 

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
