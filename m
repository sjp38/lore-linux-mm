From: "William J. Earl" <wje@cthulhu.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14433.38570.874925.968449@liveoak.engr.sgi.com>
Date: Wed, 22 Dec 1999 19:27:38 -0800 (PST)
Subject: Re: (reiserfs) Re: RFC: Re: journal ports for 2.3?
In-Reply-To: <386153A8.C8366F70@starnet.gov.sg>
References: <Pine.LNX.4.21.9912211056520.24670-100000@Fibonacci.suse.de>
	<Pine.LNX.3.96.991221200955.16115B-100000@kanga.kvack.org>
	<14433.20097.10335.102803@dukat.scot.redhat.com>
	<386153A8.C8366F70@starnet.gov.sg>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Tan Pong Heng <pongheng@starnet.gov.sg>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, "Benjamin C.R. LaHaise" <blah@kvack.org>, Andrea Arcangeli <andrea@suse.de>, Chris Mason <clmsys@osfmail.isc.rit.edu>, reiserfs@devlinux.com, linux-fsdevel@vger.rutgers.edu, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

Tan Pong Heng writes:
...
 > I was thinking that, unless you want to have FS specific buffer/page cache,
 > there is alway a gain for a unified cache for all fs. I think the one piece
 > of functionality missing from the 2.3 implementation is the dependency
 > between the various pages. If you could specify a tree relations between
 > the various subset of the buffer/page and the reclaim machanism honor
 > that everything should be fine. For FS that does not care about ordering,
 > they could simply ignore this capability and the machanism could assume
 > that everything is in one big set and could be reclaimed in any order.
...

      For the XFS port, we have been working on this, since XFS very much
wants to cluster logically adjacent delayed-allocation (and delayed-write) pages
together to optimize writes.  That is, if the someone who wants to write
back a dirty page to disk asks the file system to do so, then the file
system wants to find all nearby pages (nearby in the file, not necessarily
in memory).   The file system looks up the extent in which the page resides,
or allocates an extent if the page is part of a delayed allocation, and
then writes all of the pages in the extent at once.  Given the present
data structures, this is done by probing the page cache for each page
in the extent.  If the page cache were indexed by a per-inode AVL tree
(or other ordered index), then collecting adjacent pages would be cheaper.
Compared to a disk I/O, hash table probes are still relatively low in cost,
but it would be possible to do a bit better with some ordered index.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/
