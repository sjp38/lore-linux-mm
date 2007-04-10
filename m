Date: Tue, 10 Apr 2007 14:40:40 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [SLUB 3/5] Validation of slabs (metadata and guard zones)
In-Reply-To: <20070410133137.e366a16b.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0704101423050.9522@schroedinger.engr.sgi.com>
References: <20070410191910.8011.76133.sendpatchset@schroedinger.engr.sgi.com>
 <20070410191921.8011.16929.sendpatchset@schroedinger.engr.sgi.com>
 <20070410133137.e366a16b.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 10 Apr 2007, Andrew Morton wrote:

> I didn't immediately locate any description of what slab_lock() and
> slab->list_lock are protecting, nor of the irq-safeness requirements upon
> them.  That's important info.

SLUB: Add explanation for locking

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.21-rc6/mm/slub.c
===================================================================
--- linux-2.6.21-rc6.orig/mm/slub.c	2007-04-10 14:23:41.000000000 -0700
+++ linux-2.6.21-rc6/mm/slub.c	2007-04-10 14:38:25.000000000 -0700
@@ -26,6 +26,42 @@
  *   1. slab_lock(page)
  *   2. slab->list_lock
  *
+ *   The slab_lock protects operations on the object of a particular
+ *   slab and its metadata in the page struct. If the slab lock
+ *   has been taken the no allocations nor frees can be performed
+ *   on the objects in the slab nor can the slab be added or removed
+ *   from the partial or full lists since this would mean modifying
+ *   the page_struct of the slab.
+ *
+ *   The list_lock protects the partial and full list on each node and
+ *   the partial slab counter. If taken then no new slabs may be added or
+ *   removed from the lists nor make the number of partial slabs be modified.
+ *   (Note that the total number of slabs is an atomic value that may be
+ *   modified without taking the list lock).
+ *   The list_lock is a centralized lock and thus we avoid taking it as
+ *   much as possible. As long as SLUB does not have to handle partial
+ *   slabs operations can continue without any centralized lock. F.e.
+ *   allocating a long series of objects that fill up slabs does not require
+ *   the list lock.
+ *
+ *   The lock order is sometimes inverted when we are trying to get a slab
+ *   off a list. We take the list_lock and then look for a page on the list
+ *   to use. While we do that objects in the slabs may be freed so we can
+ *   only operate on the slab if we have also taken the slab_lock. So we use
+ *   a slab_try_lock() on the page. If trylock was successful then no frees
+ *   can occur anymore and we can use the slab for allocations etc. If the
+ *   slab_try_lock does not succeed then frees are occur to the slab and
+ *   we better stay away from it for awhile since we may cause a bouncing
+ *   cacheline if we would try to acquire the lock. So go onto the next slab.
+ *   If all pages are busy then we may allocate a new slab instead of reusing
+ *   a partial slab. A new slab has no one operating on it and thus there is
+ *   no danger of cacheline contention.
+ *
+ *   Interrupts are disabled during allocation and deallocation in order to
+ *   make the slab allocator safe to use in the context of an irq. In addition
+ *   interrupts are disabled to insure that the processor does not change
+ *   while handling per_cpu slabs.
+ *
  * SLUB assigns one slab for allocation to each processor.
  * Allocations only occur from these slabs called cpu slabs.
  *

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
