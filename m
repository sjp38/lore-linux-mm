Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 3138E6B0024
	for <linux-mm@kvack.org>; Mon, 16 May 2011 16:26:24 -0400 (EDT)
Message-Id: <20110516202605.274023469@linux.com>
Date: Mon, 16 May 2011 15:26:05 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [slubllv5 00/25] SLUB: Lockless freelists for objects V5
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: David Rientjes <rientjes@google.com>, Eric Dumazet <eric.dumazet@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>

V4->V5	- More cleanup. Remove gotos from __slab_alloc and __slab_free
	- Some structural changes to alloc and free to clean up the code
	- Statistics modifications folded in other patches.
	- Fixes to patches already in Pekka's slabnext.
	- Include missing upstream fixes

V3->V4	- Diffed against Pekka's slab/next tree.
	- Numerous cleanups in particular as a result of the removal of the
	  #ifdef CMPXCHG_LOCAL stuff.
	- Smaller cleanups whereever I saw something.

V2->V3
	- Provide statistics
	- Fallback logic to page lock if cmpxchg16b is not available.
	- Better counter support
	- More cleanups and clarifications

Well here is another result of my obsession with SLAB allocators. There must be
some way to get an allocator done that is faster without queueing and I hope
that we are now there (maybe only almost...). Any help with cleaning up the
rough edges would be appreciated.

This patchset implement wider lockless operations in slub affecting most of the
slowpaths. In particular the patch decreases the overhead in the performance
critical section of __slab_free.

One test that I ran was "hackbench 200 process 200" on 2.6.29-rc3 under KVM

Run	SLAB	SLUB	SLUB LL
1st	35.2	35.9	31.9
2nd	34.6	30.8	27.9
3rd	33.8	29.9	28.8

Note that the SLUB version in 2.6.29-rc1 already has an optimized allocation
and free path using this_cpu_cmpxchg_double(). SLUB LL takes it to new heights
by also using cmpxchg_double() in the slowpaths (especially in the kfree()
case where we frequently cannot use the fastpath because there is no queue).

The patch uses a cmpxchg_double (also introduced here) to do an atomic change
on the state of a slab page that includes the following pieces of information:

1. Freelist pointer
2. Number of objects inuse
3. Frozen state of a slab

Disabling of interrupts (which is a significant latency in the
allocator paths) is avoided in the __slab_free case.

There are some concerns with this patch. The use of cmpxchg_double on
fields of the page struct requires alignment of the fields to double
word boundaries. That can only be accomplished by adding some padding
to struct page which blows it up to 64 byte (on x86_64). Comments
in the source describe these things in more detail.

The cmpxchg_double() operation introduced here could also be used to
update other doublewords in the page struct in a lockless fashion. One
can envision page state changes that involved flags and mappings or
maybe do list operations locklessly (but with the current scheme we
would need to update two other words elsewhere at the same time too,
so another scheme would be needed).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
