Date: Thu, 30 Mar 2000 16:34:54 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Reply-To: riel@nl.linux.org
Subject: Re: shrink_mmap SMP race fix
In-Reply-To: <Pine.LNX.4.21.0003302042030.8695-100000@alpha.random>
Message-ID: <Pine.LNX.4.21.0003301628260.1104-100000@duckman.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, MOLNAR Ingo <mingo@chiara.csoma.elte.hu>
List-ID: <linux-mm.kvack.org>

On Thu, 30 Mar 2000, Andrea Arcangeli wrote:
> On Thu, 30 Mar 2000, Rik van Riel wrote:

> >The idea of this approach is that we need the LRU cache to do some
> >aging on pages we're about to free. We absolutely need this because
> >otherwise the system will be thrashing much earlier than needed.
> >Good page replacement simply is a must.
> 
> I really don't think aging is the problem. If you want I can
> send you the patch to replace the test_and_set_bit(PG_referenced)
> with a perfect and costly roll of the lru list. That's almost
> trivial patch. But I'm 99& sure you'll get the same swap
> behaviour.

I'm sorry I didn't explain clearly. Of course it doesn't matter
if we do perfect LRU sorting or second-chance behaviour.

What matters is that the pages should spend _enough time_ in the
LRU list for them to have a chance to be reclaimed by the original
application. If we maintain a too small list, pages don't get
enough of a chance to be reclaimed by their application and the
"extra aging" benefit is minimal.

> The _real_ problem is that we have to split the LRU in
> page/buffer-cache LRU and swap-cache LRU.

> Shrinking the unused swap cache first is the way to go.

NOOOOOO!!  The only reason that the current VM behaves decently
at all is that all pages are treated equally. We _need_ to reclaim
all pages in the same way and in the same queue because only then
we achieve automatic balancing between the different memory uses
in an efficient way.

> >That would be great!
> 
> Do you think we should do that for 2.4.x? How is the current
> swap behaviour with low mem? It doesn't feel bad to me while
> pushing 100mbyte on swap in 2.3.99-pre4-pre1 + the latest posted
> patches

It's certainly not bad. In fact, current VM behaviour is good enough
that I'd rather not touch it before 2.5... In the past we had some
very bad problems with VM behaviour just before a stable release,
now things seem to work quite well.

I propose we leave the VM subsystem alone for 2.4.

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
