Date: Tue, 10 Apr 2007 13:31:37 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [SLUB 3/5] Validation of slabs (metadata and guard zones)
Message-Id: <20070410133137.e366a16b.akpm@linux-foundation.org>
In-Reply-To: <20070410191921.8011.16929.sendpatchset@schroedinger.engr.sgi.com>
References: <20070410191910.8011.76133.sendpatchset@schroedinger.engr.sgi.com>
	<20070410191921.8011.16929.sendpatchset@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 10 Apr 2007 12:19:21 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> This enables validation of slab. Validation means that all objects are checked
> to see if there are redzone violations, if padding has been overwritten or any
> pointers have been corrupted. Also checks the consistency of slab counters.
> 
> Validation enables the detection of metadata corruption without the kernel
> having to execute code that actually uses (allocs/frees) and object. It allows
> one to make sure that the slab metainformation and the guard values around
> an object have not been compromised.
> 
> A single slabcache can be checked by writing a 1 to the "validate" file.
> 
> i.e.
> 
> echo 1 >/sys/slab/kmalloc-128/validate
> 
> or use the slabinfo tool to check all slabs
> 
> slabinfo -v
> 
> Error messages will show up in the syslog.

Neato.

It would be nice to get all this stuff user-documented, so there's one place to
go to work out how to drive slub.

We should force -mm testers to use slub by default, while providing them a
way of going back to slab if they hit problems.  Can you please cook up a
-mm-only patch for that?

Could print_track() be simplified by using -mm's sprint_symbol()?

I didn't immediately locate any description of what slab_lock() and
slab->list_lock are protecting, nor of the irq-safeness requirements upon
them.  That's important info.

How come slab_lock() isn't needed if CONFIG_SMP=n, CONFIG_PREEMPT=y?  I
think that bit_spin_lock() does the right thing, and the #ifdef CONFIG_SMP
in there should be removed.

The use of slab_trylock() could do with some commentary: under what
circumstances can it fail, what action do we take when it fails, why is
this OK, etc.

There are a bunch of functions which need to be called with local irqs
disabled for locking reasons.  Documenting this (perhaps with
VM_BUG_ON(!irqs_disabled()?) would be good.

calculate_order() is an important function.  The mapping between
object-size and what-size-slab-will-use is something which regularly comes
up, as it affects the reliability of the allocations of those objects, and
their cost, and their page allocator fragmentation effects, etc.  Hence I
think calculate_order() needs comprehensive commenting.  Rather than none ;)

What does that 65536 mean in kmem_cache_open? (Needs comment?)

Where do I go to learn what "s->defrag_ratio = 100;" means?

Why is kmem_cache_close() non-static and exported to modules? 

Please check that all printks have suitable facility levels (KERN_FOO).


I queued a pile of little cleanups, which you have been spammed with.  To
resync, a rollup up to and including the slub patches is at
http://userweb.kernel.org/~akpm/cl.gz (against 2.6.21-rc6).


Teeny, teeny maximally-fine-grained little patches from now on, please. 
Otherwise my whole house of cards will collapse.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
