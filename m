Date: Mon, 7 Aug 2000 10:55:58 -0700 (PDT)
From: Matthew Dillon <dillon@apollo.backplane.com>
Message-Id: <200008071755.KAA01590@apollo.backplane.com>
Subject: Re: RFC: design for new VM
References: <Pine.GSO.4.10.10008042211290.7396-100000@weyl.math.psu.edu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alexander Viro <viro@math.psu.edu>
Cc: Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Chris Wedgwood <cw@f00f.org>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

:>     if 300 processes fault on the same backing file offset you are going
:>     to hit a bottleneck with MP locking anyway, just at a deeper level
:>     (the filesystem rather then the VM system).
:
:Erm... I'm not sure about that - for one thing, you are not caching
:results of bmap(). We do. And our VFS is BKL-free, so contention really
:hits only on the VOP_BALLOC() level (that can be fixed too, but that's
:another story).

    Well... actually, a side effect of the FreeBSD buffer cache is to
    cache BMAP translations.

    What we do do, which kinda kills the cacheability aspects of balloc
    in some cases, is VOP_REALLOC() -- that is, the FFS filesystem will
    reallocate blocks to implement on-the-fly defragmentation.  This 
    typically occurs on writes.  It works *very* well.  This is a feature
    that actually used to be in FFS a few years ago but had to be turned off
    due to bugs.  The bugs were fixed about a year ago and realloc was turned
    on by default in 4.x.

					-Matt
					Matthew Dillon 
					<dillon@backplane.com>
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
