Date: Mon, 15 May 2000 16:27:38 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [patch] VM stable again?
In-Reply-To: <Pine.LNX.4.10.10005152122580.8896-100000@elte.hu>
Message-ID: <Pine.LNX.4.21.0005151625290.20410-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 15 May 2000, Ingo Molnar wrote:
> On Mon, 15 May 2000, Rik van Riel wrote:
> 
> > I've thought about this but it doesn't seem worth the extra complexity
> > to me. Just making sure that while our task is freeing pages nobody
> > else will grab those pages without having also freed some pages seems
> > to be enough to me.
> 
> actually wouldnt it be simpler to always call
> try_to_free_pages() when the zone is low on memory? This will
> keep the pressure on the system to recover from the low memory
> situation, and it reuses the low_on_memory flag. The new
> free_before_allocate flag is a 'now we are really low on memory'
> flag.

This would disturb the balancing between zones. We do not
want to have this flag per-zone since it would return us
to the "16/64MB unused" problem (and I believe you've seen
it too with highmem).

> > Furthermore, the "SMP locality" you talk about will probably be
> > completely overshadowed by the non-locality of the VM freeing code
> > anyway...
> 
> But it would be a performance optimization for sure, a
> __free_pages() + __alloc_pages() is saved - this can make a big
> difference if (a mostly clean) pagecache is shrunk.

But we shrink 'count' pages at the same time. It would only save
2 operations out of a *lot*. A much bigger win could be had if
the list operations in shrink_mmap() would be made simpler or
lower overhead...

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
