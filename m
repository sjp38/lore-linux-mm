Date: Wed, 16 May 2001 10:54:12 -0700 (PDT)
From: Matt Dillon <dillon@earth.backplane.com>
Message-Id: <200105161754.f4GHsCd73025@earth.backplane.com>
Subject: Re: RE: on load control / process swapping
References: <Pine.LNX.4.33.0105161439140.18102-100000@duckman.distro.conectiva>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Charles Randall <crandall@matchlogic.com>, Roger Larsson <roger.larsson@norran.net>, arch@FreeBSD.ORG, linux-mm@kvack.org, sfkaplan@cs.amherst.edu
List-ID: <linux-mm.kvack.org>

    It's not dropping the data, it's dropping the priority.  And yes, it
    does penalize the data somewhat.  On the otherhand if the data happens
    to still be in the cache and you scan it a second time, the page priority
    gets bumped up relative to what it already was so the net effect is
    that the data becomes high priority after a few passes.

:Maybe it would be better to only do drop-behind when we're
:actually allocating new memory for the vnode in question and
:let re-use of already present memory go "unpunished" ?

    You get an equivalent effect even without dropping the priority,
    because you blow away prior pages when reading a file that is
    larger then main memory so they don't exist at all when you re-read.
    But you do not get the expected 'recycling' characteristics verses
    the rest of the system if you do not make a distinction between
    sequential and random access.  You want to slightly depress the priority
    behind a sequential access because the 'cost' of re-reading the disk
    sequentially is nothing compared to the cost of re-reading the disk
    randomly (by about a 30:1 ratio!).  So keeping randomly seek/read data
    is more important by degrees then keeping sequentially read data.

    This isn't to say that it isn't important to try to cache sequentially
    read data, just that the cost of throwing away sequentially read data
    is much lower then the cost of throwing away randomly read data on
    a general purpose machine.

    Terry's description of 'ld' mmap()ing and doing all sorts of random
    seeking causing most UNIXes, including FreeBSD, to have a brainfart of
    the dataset is too big to fit in the cache is true as far as it goes,
    but there really isn't much we can do about that situation
    'automatically'.  Without hints, the system can't predict the fact that
    it should be trying to cache the whole of the object files being accessed
    randomly.  A hint could make performance much better... a simple 
    madvise(... MADV_SEQUENTIAL) on the mapped memory inside LD would 
    probably be beneficial, as would madvise(... MADV_WILLNEED).

					-Matt

:Hmmm, now that I think about this more, it _could_ introduce
:some different fairness issues. Darn ;)
:
:regards,
:
:Rik
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
