Date: Tue, 11 Jul 2000 17:23:08 +0200 (CEST)
From: Richard Guenther <richard.guenther@student.uni-tuebingen.de>
Subject: Re: sys_exit() and zap_page_range()
In-Reply-To: <20000711143558.E1054@redhat.com>
Message-ID: <Pine.LNX.4.21.0007111713580.31978-100000@fs1.dekanat.physik.uni-tuebingen.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Andrew Morton <andrewm@uow.edu.au>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 11 Jul 2000, Stephen C. Tweedie wrote:

> Hi,
> 
> On Tue, Jul 11, 2000 at 09:24:56PM +1000, Andrew Morton wrote:
> > 
> > Nope.  Take out the msyncs and it still does it.
> 
> Unmapping a writable region results in an implicit msync.  That
> includes exit() and munmap().

Can we have some feature like deferred munmap() which recycles
virtual memory space only if needed? I.e. basically an asynchronous
munmap() which allows an already munmapped section to be re-mapped
without having the implicit msync() and future page-ins?

So basically

	mem = mmap(NULL, PAGESIZE, PROT_READ|PROT_WRITE, MAP_SHARED, file,
0);
	/* muck with mem */
	special_munmap(mem, PAGESIZE);

	/* re-map the same memory again - dont care if the resulting
         * virtual address is the same as above. */
	mem = mmap(.....);

	etc.

with the munmap() not causing disk activity, instead the physical page
(or the mapping itself) gets cached and reused by the following mmap().

Of course implementing this via munmap() breaks posix - so we might want
to do it using madvise(,, MADV_LAZY_UNMAP) or the like? Btw. having a
mmap() operation that works recursively, i.e. returns the same virtual
mapping for the same mapping and keeping a reference count, would be cool,
too. [In case you're wondering, I'm doing virtual memory management in
userspace]

Richard.

--
Richard Guenther <richard.guenther@student.uni-tuebingen.de>
WWW: http://www.anatom.uni-tuebingen.de/~richi/
The GLAME Project: http://www.glame.de/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
