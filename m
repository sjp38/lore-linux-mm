From: "William J. Earl" <wje@cthulhu.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14550.56676.35208.422139@liveoak.engr.sgi.com>
Date: Mon, 20 Mar 2000 18:24:36 -0800 (PST)
Subject: Re: madvise (MADV_FREE)
In-Reply-To: <20000321022053.A4271@pcep-jamie.cern.ch>
References: <20000320135939.A3390@pcep-jamie.cern.ch>
	<Pine.BSO.4.10.10003201318050.23474-100000@funky.monkey.org>
	<20000321022053.A4271@pcep-jamie.cern.ch>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jamie Lokier <jamie.lokier@cern.ch>
Cc: Chuck Lever <cel@monkey.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Jamie Lokier writes:
...
 > You assume a page is not likely to swap, because there's a reasonable
 > chance the application will reallocate it before that happens.  So on
 > balance, giving pages unconditionally to the kernel is a loss.
 > 
 > --> No sane free(3) would call MADV_DONTNEED or msync(MS_INVALIDATE).
 > 
 > A better application allocator would base decisions about when to return
 > pages to the kernel on the likelihood of swapping and measured cost of
 > swapping vs. retaining pages.  Of course that's very difficult and
 > system specific.  And really only the kernel has access to all the
 > information on memory pressure.
...

     I have been asked by some application people to have free() use
MADV_DONTNEED or the equivalent in selected cases, specifically when
the memory allocated is large, in order to free up the physical and
virtual (swap space) memory for other uses.  If the application uses
very large chunks of memory, giving it back entirely is a win.  The
application could be recoded to do its own mmap() of /dev/zero and
munmap(), but would prefer that this behavior be automatic.  Of course,
MADV_DONTNEED does not apply in the case of mmap()/munmap() of /dev/zero,
but it is not implausible to give up virtual memory.  Note that
I am not claiming one should do anything of the sort for small
allocations.

     If you have, say, 256 MB of memory and 256 MB of swap, and you
use 384 MB of memory in your application, you cannot even fork()
without giving up some of it.  Many serious applications at least
reserve large amounts of memory (even if they do not touch all of
it on every run).  
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
