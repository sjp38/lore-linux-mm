Received: from haymarket.ed.ac.uk (haymarket.ed.ac.uk [129.215.128.53])
	by kvack.org (8.8.7/8.8.7) with ESMTP id SAA18937
	for <linux-mm@kvack.org>; Mon, 23 Mar 1998 18:05:46 -0500
Date: Mon, 23 Mar 1998 22:49:27 GMT
Message-Id: <199803232249.WAA02431@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Lazy page reclamation on SMP machines: memory barriers
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org, linux-smp@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Hi,

I am currently finalising some work on lazy page reclamation for the 2.1
kernels.  The basic mechanism involves spinlocking the page cache
linkages, and allowing pages in the cache to be removed and placed on
the free list even from within interrupt context.  

We keep a queue of pages which have been scavenged by the page stealers
(vmscan and shrink_mmap).  Pages on this lazy reclamation queue have a
PG_lazy bit set in the page flags, so they can be safely avoided by
shrink_mmap().  By making a design decision to clear this lazy bit as
the very last step in freeing a lazy page, and by ensuring that the bit
is otherwise only ever set or tested under the page cache spinlock, we
can safely make a test of the lazy bit without taking both that spinlock
and the global kernel lock (which we hold for most VM operations
anyway).  If the lazy bit is clear, then we know, for sure, that no
other CPU can be in the process of freeing up that cached page.

The problem with this scheme is that although it avoids unnecessary page
cache spinlocking, it does rely on memory ordering.  In particular,
there are problems with interactions between one CPU testing the lazy
bit with the kernel spinlock held, and another CPU in interrupt context
freeing the page and then clearing the lazy bit with the page cache
spinlock held.  If any of the memory operations on the second CPU are
reordered on the first, either because writes have been reordered on the
freeing CPU or reads have been reordered on the scanning CPU, then the
protection has failed.

In other words, safety requires that I can guarantee:

In interrupt context:

	spin_lock(&page_cache_lock);
	free_page_from_page_cache(page);

	write_barrier();

	clear_bit(PG_lazy, &page->flags);
	spin_unlock(&page_cache_lock);

and with the kernel lock held in process context:

	if (!test_bit(PG_lazy, &page_flags)) {

		read_barrier();

		if (test_page()) {
			spin_lock_irqsave(&page_cache_lock, flags);
			do_something();
			spin_unlock_irqrestore(&page_cache_lock, flags);
		}
	}		

The cost of taking the spinlock for every page scanned in the second
section would be prohibitive.  With the barriers in place, the kernel
spinlock protects the second section from other CPUs trying to set the
lazy bit unexpectedly, but only the ordering guarantee on the lazy bit
protects it from another CPU freeing the page.  If the clearing of the
lazy bit is visible early on the testing CPU, then we the test_page() or
do_something() calls may not be safe.

Are there barrier constructs available to do this?  I believe the answer
to be no, based on the recent thread concerning the use of inline asm
cpuid instructions as a barrier on Intel machines.  Alternatively, does
Intel provide any ordering guarantees which may help?

Finally, I looked quickly at the kernel's spinlock primitives, and they
also seem unprotected by memory barriers on Intel.  Is this really safe?

--Stephen
