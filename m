Date: Mon, 8 Jul 2002 07:50:43 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: scalable kmap (was Re: vm lock contention reduction)
Message-ID: <20020708145043.GG25360@holomorphy.com>
References: <3D28042E.B93A318C@zip.com.au> <Pine.LNX.4.44.0207071128170.3271-100000@home.transmeta.com> <3D293E19.2AD24982@zip.com.au> <20020708080953.GC1350@dualathlon.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <20020708080953.GC1350@dualathlon.random>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Andrew Morton <akpm@zip.com.au>, Linus Torvalds <torvalds@transmeta.com>, "Martin J. Bligh" <fletch@aracnet.com>, Rik van Riel <riel@conectiva.com.br>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jul 08, 2002 at 10:09:53AM +0200, Andrea Arcangeli wrote:
> with truncate. The only reason I can imagine rmap useful in todays
> hardware for all kind of vma (what the patch provides compared to what
> we have now) is to more efficiently defragment ram with an algorithm in
> the memory balancing to provide largepages more efficiently from mixed
> zones, if somebody would suggest rmap for this reason (nobody did yet) I
> would have to agree completely that it is very useful for that, OTOH it

A number of uses of reverse mappings come to mind. There is the use of
rmap for Linux running as a guest instance returning memory to host
OS's and/or firmware. This involves evicting specific physically
contiguous regions. I believe UML and some ppc64 ports would like to do
this. I intend to experiment with using rmap for virtual cache
invalidation on some of my sun4c machines in my spare time as well,
though given the general importance of virtual caches that's not likely
to be a good motivator for reverse mapping support. I believe the 2.4.x-
based rmap tree also had a comment suggesting it could be used to more
directly address general multipage allocation failures due to
fragmentation, but I'm unaware of any particular attempts to use them
for general online defragmentation.

While it appears physical scanning could provide some benefit for page
replacement in the presence of large amounts of shared memory, as the
number of virtual pages present across all processes could be a large
multiple of the number of physical pages present in a system, I'll
leave the final judgment of its effectiveness there to those more
frequently involved in page replacement issues.

Perhaps collecting statistics on pte_chain lengths could be useful here,
as that would give some notion of how much additional work is generated
by sharing for the virtual scan algorithm. On the virtual scanning side,
perhaps collecting statistics on how frequently the memclass() check
fails in try_to_swap_out() might give some notion of how advantageous
physical scanning is with respect to being able to pinpoint pressured
regions. Other statistics like the scan rate and so on might be trickier
with the virtual scan since some pages may be scanned multiple times.
Maybe another thing to check is how often a pte is invalidated without
actually being able to evict the page. I did something for several of
these a while ago but am not sure what happened to it. I'll see what I
can brew up today, especially since there are some unanswered questions
still about another scenario I'm able to reproduce involving excess
dirty memory I've been asked to collect more information on.

Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
