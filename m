Date: Mon, 25 Sep 2000 15:39:51 +0200 (CEST)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: mingo@elte.hu
Subject: Re: the new VM
In-Reply-To: <20000925153050.C22882@athlon.random>
Message-ID: <Pine.LNX.4.21.0009251529010.6224-100000@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 25 Sep 2000, Andrea Arcangeli wrote:

> And if the careful limit avoids the deadlock in the layer above
> alloc_pages, then it will also avoid alloc_pages to return NULL and
> you won't need an infinite loop in first place (unless the memory
> balancing is buggy).

yes i like this property very much because it unearths VM balancing bugs,
which plagued us for so long and are so hard to detect. But statistically
it's also possible that try_to_free_pages() frees a page and alloc_pages()
done on another CPU (or in IRQ context) 'steals' the page. This can
happen, because the VM right now guarantees no straight path from
deallocator to allocator. (and it's not necessery to guarantee it, given
the varying nature of allocation requests.)

> GFP should return NULL only if the machine is out of memory. The
> kernel can be written in a way that never deadlocks when the machine
> is out of memory just checking the GFP retval. I don't think any
> in-kernel resource limit is necessary to have things reliable and
> fast. [...]

Andrea, if you really mean this then you should not be let near the VM
balancing code :-)

> Most dynamic big caches and kernel data can be shrinked dynamically
> during memory pressure (pheraps except skbs and I agree that for skbs
> on gigabit ethernet the thing is a little different).

a big 'except'. You dont need gigabit for that, to the contrary, if the
network is slow it's easier to overallocate within the kernel. Ask Alan
about how many D.O.S. attacks there are possible without implicit or
explicit bean counting.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
