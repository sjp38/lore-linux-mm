Date: Wed, 16 May 2001 11:01:24 -0700 (PDT)
From: Matt Dillon <dillon@earth.backplane.com>
Message-Id: <200105161801.f4GI1Oc73283@earth.backplane.com>
Subject: Re: on load control / process swapping
References: <200105161714.f4GHEFs72217@earth.backplane.com> <Pine.LNX.4.33.0105161439140.18102-100000@duckman.distro.conectiva> <20010516135707.H12365@superconductor.rush.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alfred Perlstein <bright@rush.net>
Cc: Rik van Riel <riel@conectiva.com.br>, Charles Randall <crandall@matchlogic.com>, Roger Larsson <roger.larsson@norran.net>, arch@FreeBSD.ORG, linux-mm@kvack.org, sfkaplan@cs.amherst.edu
List-ID: <linux-mm.kvack.org>

:Both of you guys are missing the point.
:
:The directio interface is meant to reduce the stress of a large
:seqential operation on a file where caching is of no use.
:
:Even if you depress the worthyness of the pages you've still
:blown rather large amounts of unrelated data out of the cache
:in order to allocate new cacheable pages.
:
:A simple solution would involve passing along flags such that if
:the IO occurs to a non-previously-cached page the buf/page is
:immediately placed on the free list upon completion.  That way the
:next IO can pull the now useless bufferspace from the freelist.
:
:Basically you add another buffer queue for "throw away" data that
:exists as a "barely cached" queue.  This way your normal data
:doesn't compete on the LRU with non-cached data.
:
:As a hack one it looks like one could use the QUEUE_EMPTYKVA
:buffer queue under FreeBSD for this, however I think one might
:loose the minimal amount of caching that could be done.
:
:If the direct IO happens to a page that's previously cached
:you adhere to the previous behavior.
:
:A more fancy approach might map in user pages into the kernel to
:do the IO directly, however on large MP this may cause pain because
:the vm may need to issue ipi to invalidate tlb entries.
:
:It's quite simple in theory, the hard part is the code.
:
:-Alfred Perlstein

    I think someone tried to implement O_DIRECT a while back, but it
    was fairly complex to try to do away with caching entirely.

    I think our best bet to 'start' an implementation of O_DIRECT is
    to support the flag in open() and fcntl(), and have it simply
    modify the sequential detection heuristic to throw away pages
    and buffers rather then simply depressing their priority.

    Eventually we can implement the direct-I/O piece of the equation.

    I could do this first part in an hour, I think.  When I get home....

						-Matt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
