Date: Thu, 30 Mar 2000 14:14:53 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Reply-To: riel@nl.linux.org
Subject: Re: shrink_mmap SMP race fix
In-Reply-To: <Pine.LNX.4.21.0003301639540.368-100000@alpha.random>
Message-ID: <Pine.LNX.4.21.0003301406530.1104-100000@duckman.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, MOLNAR Ingo <mingo@chiara.csoma.elte.hu>
List-ID: <linux-mm.kvack.org>

On Thu, 30 Mar 2000, Andrea Arcangeli wrote:

> This third patch removes a path that makes no sense to me. If
> you have an explanation for it it's very welcome. The page aging
> happens very earlier not before such place.

Sorry, but if page aging happens elsewhere, why do we go through
the trouble of maintaining an LRU list in the first place?

The answer is that the one-bit "page aging" (NRU replacement) of
pages in the page tables simply isn't enough. I agree that the
current 'magic number' approach isn't ideal and I welcome you to
come up with something better.

> I don't see the connection between the priority and a fixed
> level of lru-cache. If something the higher is the priority the
> harder we should shrink the cache (that's the opposite that the
> patch achieves). Usually priority is always zero and the below
> check has no effect.

The idea of this approach is that we need the LRU cache to do some
aging on pages we're about to free. We absolutely need this because
otherwise the system will be thrashing much earlier than needed.
Good page replacement simply is a must.

Since priority starts at 6 and only goes down in absolute
emergencies, this approach allows us to have a minimum number
of pages we age we can do better page aging when the system
isn't under too much stress.

The only big problem is that we seem to keep pages in the
LRU cache that are also mapped in processes. This makes us
do a lot of unneeded work on pages (though I hope I've
overlooked something and the LRU cache only contains unmapped
pages).

> I have algorithms completly autotuning (they happened to be in
> the 2.2.x-andrea patches somewhere in ftp.suse.com, there were
> many benchmarks also posted on l-k at that time), they don't add
> anything fixed like the above and I strongly believe the
> responsiveness under swap will be amazing as soon as I'll port
> them to the new kernels.

That would be great!

I also have some ideas about how to make the LRU cache better,
but the changes needed to get that right are IMHO a bit too big
to do now that we've started on 2.4 pre...

(my idea is very much like the 'free' list on BSD systems, where
 we reclaim pages in FIFO order from the list, but give applications
 the chance to reclaim them while they're on the list. The size of
 the list is varied depending on the ratio between freed pages and
 reclaimed pages)

kind regards,

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
