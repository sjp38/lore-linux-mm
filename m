Date: Wed, 24 May 2000 13:57:19 -0700 (PDT)
From: Matthew Dillon <dillon@apollo.backplane.com>
Message-Id: <200005242057.NAA77059@apollo.backplane.com>
Subject: Re: [RFC] 2.3/4 VM queues idea
References: <Pine.LNX.4.21.0005241458250.24993-100000@duckman.distro.conectiva>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

    Virtual page scanning will help with clustering, but unless you
    already have a good page candidate to base your virtual scan on
    you will not be able to *find* a good page candidate to base the
    clustering around.  Or at least not find one easily.  Virtual
    page scanning has severe scaleability problems over physical page
    scanning.  For example, what happens when you have an oracle database
    running with a hundred independant (non-threaded) processes mapping
    300MB+ of shared memory?

    On the swap allocation -- I think there are several approaches to this
    problem, all equally viable.  If you do not do object clustering for
    pageouts then allocating the swap at unmap time is viable -- due to
    the time delay between unmap and the actual I/O & page-selection
    for cleaning, your pageouts will be slower but you *will* get locality
    of reference on your pageins (pageins will be faster).

    If you do object clustering then you get the benefit of both worlds.
    FreeBSD delays swap allocation until it actually decides to swap
    something, which means that it can take a collection of unrelated
    pages to be cleaned and assign contiguous swap to them.  This results
    in a very fast, deterministic pageout capability but, without clustering,
    there will be no locality of reference for pageins.  So pageins would
    be slow.

    With clustering, however, the at-swap-time allocation tends to have more
    locality of reference due to there being additional nearby pages 
    selected from the objects in the mix.  It still does not approach the
    performance you can get from an object-oriented swap allocation scheme,
    but at least it would no longer be considered 'slow'.

    So it can be a toss-up.  I don't think *anyone* (linux, freebsd, solaris,
    or anyone else) has yet written the definitive swap allocation algorithm!

					-Matt
					Matthew Dillon 
					<dillon@backplane.com>
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
