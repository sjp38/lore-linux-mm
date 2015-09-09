Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f43.google.com (mail-oi0-f43.google.com [209.85.218.43])
	by kanga.kvack.org (Postfix) with ESMTP id 9005C6B0038
	for <linux-mm@kvack.org>; Wed,  9 Sep 2015 16:36:49 -0400 (EDT)
Received: by oiev17 with SMTP id v17so12916223oie.1
        for <linux-mm@kvack.org>; Wed, 09 Sep 2015 13:36:49 -0700 (PDT)
Received: from e39.co.us.ibm.com (e39.co.us.ibm.com. [32.97.110.160])
        by mx.google.com with ESMTPS id b9si5616011oel.9.2015.09.09.13.36.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Wed, 09 Sep 2015 13:36:48 -0700 (PDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Wed, 9 Sep 2015 14:36:47 -0600
Received: from b03cxnp07029.gho.boulder.ibm.com (b03cxnp07029.gho.boulder.ibm.com [9.17.130.16])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id D92963E40047
	for <linux-mm@kvack.org>; Wed,  9 Sep 2015 14:36:44 -0600 (MDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by b03cxnp07029.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t89KaieH42205294
	for <linux-mm@kvack.org>; Wed, 9 Sep 2015 13:36:44 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t89KaikV019018
	for <linux-mm@kvack.org>; Wed, 9 Sep 2015 14:36:44 -0600
Date: Wed, 9 Sep 2015 13:36:42 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: Is it OK to pass non-acquired objects to kfree?
Message-ID: <20150909203642.GO4029@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <CACT4Y+bvaJ6cC_=A1VGx=cT_bkB-teXNud0Wgt33E1AtBYNTSg@mail.gmail.com>
 <alpine.DEB.2.11.1509090901480.18992@east.gentwo.org>
 <CACT4Y+ZpToAmaboGDvFhgWUqtnUcJACprg=XSTkrJYE4DQ1jcA@mail.gmail.com>
 <alpine.DEB.2.11.1509090930510.19262@east.gentwo.org>
 <CACT4Y+b_wDnC3mONjmq+F9kaw1_L_8z=E__1n25ZgLhx-biEmQ@mail.gmail.com>
 <alpine.DEB.2.11.1509091036590.19663@east.gentwo.org>
 <CACT4Y+a6rjbEoP7ufgyJimjx3qVh81TToXjL9Rnj-bHNregZXg@mail.gmail.com>
 <alpine.DEB.2.11.1509091251150.20311@east.gentwo.org>
 <20150909184415.GJ4029@linux.vnet.ibm.com>
 <alpine.DEB.2.11.1509091346230.20665@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1509091346230.20665@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Dmitry Vyukov <dvyukov@google.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrey Konovalov <andreyknvl@google.com>, Alexander Potapenko <glider@google.com>

On Wed, Sep 09, 2015 at 02:01:40PM -0500, Christoph Lameter wrote:
> On Wed, 9 Sep 2015, Paul E. McKenney wrote:
> 
> > > The size is encoded in the kmem_cache structure which is not changed. How
> > > can that be relevant?
> >
> > IIRC, at one point some of the Linux-kernel allocators stored some
> > state in the object itself.  What is the current state?
> 
> SLUB stores the link to the next object most of the time in the first word
> of the object. But then this is mostly done for per cpu lists. Another
> processor would access another linked list.

OK, good to know.

> > > Well if the pointer is used nakedly to communicate between threads the
> > > barriers need to be used but what does this have to do with slabs?
> >
> > It certainly is something that the users of slabs need to know.
> 
> Well no this is general synchronization.

Either way, Dmitry's tool got a hit on real code using the slab
allocators.  If that hit is a false positive, then clearly Dmitry
needs to fix his tool, however, I am not (yet) convinced that it is a
false positive.  If it is not a false positive, we might well need to
articulate the rules for use of the slab allocators.

> > In particular, what exactly are the synchronization requirements that
> > the slabs place on their users?  Dmitry needs to know this because he
> > is constructing a tool that automatically locates race conditions, and
> > he needs to know who to complain to when he finds a race condition that
> > involves slabs and their users.
> >
> > Here are some of my guesses, but you are the maintainer, not me.  ;-)
> >
> > 1.	Do there need to be any compiler or CPU barriers between
> > 	last use and free on a single thread?  Here is an example:
> >
> > 	p = kmalloc(sizeof(*p), GFP_KERNEL);
> > 	if (!p)
> > 		return NULL;
> > 	initialize_me(p);
> > 	if (do_not_really_need_it(p)) {
> > 		kfree(p);
> > 		return NULL;
> > 	}
> > 	return p;
> >
> > 	Suppose that both initialize_me() and do_not_really_need_it()
> > 	are static inline functions, so that all of their loads and
> > 	stores to the structure referenced by p are visible to the
> > 	compiler.  Is the above code correct, or is the user required
> > 	to place something like barrier() before the call to kfree()?
> >
> > 	I would hope that the caller of kfree() need not invoke barrier()
> > 	beforehand, but it is your decision.  If the caller need not
> > 	invoke barrier(), then it might (or might not) need to be supplied
> > 	by the kfree() implementation.	From what I understand, Dmitry's
> > 	tool indicated a barrier() is needed somewhere in this code path.
> 
> This would all use per cpu data. As soon as a handoff is required within
> the allocators locks are being used. So I would say no.

As in "no, it is not necessary for the caller of kfree() to invoke barrier()
in this example", right?

> > 2.	Is it OK to do a hot handoff from kmalloc() on one thread to
> > 	kfree on another?
> >
> > 	Thread 0:
> >
> > 		gp = kmalloc(sizeof(*gp), GFP_KERNEL);
> >
> > 	Thread 1:
> >
> > 		p = READ_ONCE(gp);
> > 		if (gp)
> > 			kfree(gp);
> >
> > 	I would be strongly tempted to just say "no" to this use case
> > 	on the grounds that it is pointless, but you know your users
> > 	better than do I.
> 
> Its pointless since you cannot use gp in thread 0 to dereference the
> object given the race condition that thread 1 creates. There is always
> the potential of a use after free.

I like that approach!  ;-)

> > 3.	The case that Dmitry pointed out was something like the following:
> >
> > 	Thread 0:
> >
> > 		p = kmalloc(sizeof(*p), GFP_KERNEL);
> > 		if (!p)
> > 			return NULL;
> 
> I guess p is a global. p exists with p->rc having a random value afer the
> kmalloc. Since you access p at random times this is a bad(tm) idea. Use
> kzalloc at least?

Ah, I clearly made this example too minimal.  My intent was that p is
a local, and is returned to the caller.  The caller can hand it off,
but each thread having a reference must have that reference recorded
in p->rc.  Let me try redoing this example below.

> > 		atomic_set(&p->rc, 1);
> > 		return p;
> >
> > 	Thread 1:
> >
> > 		WARN_ON(!p->rc);  /* Must own ref to take another. */
> 
> This definitely can occur given the above code.
> 
> > 		atomic_inc(&p->rc);
> >
> > 	Thread 2:
> >
> > 		if (p->rc == 1 ||
> > 		    atomic_dec_and_test(&p->rc))
> > 		    	kfree(p);
> >
> > 	This ends up really being the same as #1 above.
> 
> This is all screwed if p is a global variable. Typically one would expose
> p in a safe way by first storing the address in a local variable,
> populating the contents of the object and then ensuring that the
> cachelines are written back before storing the address into p.

OK, trying again...

	struct foo *alloc_it(void)
	{
		struct foo *p;

		p = kmalloc(sizeof(*p), GFP_KERNEL);
		if (!p)
			return NULL;
		atomic_set(&p->rc, 1);
		return p;
	}

	void get_ref(struct foo *p)
	{
		WARN_ON(!p->rc);  /* Must own ref to take another. */
		atomic_inc(&p->rc);
	}

	void put_ref(struct foo *p)
	{
		if (p->rc == 1 ||
		    atomic_dec_and_test(&p->rc))
		    	kfree(p);
	}

	Thread 0:
		p = alloc_it();  /* p is a local. */
		get_ref(p);  /* Get reference for thread 1. */
		smp_store_release(&thread1_p, p);  /* only threads 0 and 1. */
		do_something();
		put_ref(p);  /* Thread 1 now has the only reference. */

	Thread 1:
		p = smp_load_acquire(&thread1_p);
		do_something_else(p);
		put_ref(p);

	The second-to-last reference used the fully ordered
	atomic_dec_and_test() to release the reference, so there should
	be no cross-thread references.

	So I believe that this ends up really being the same as #1 above.

> > > > > Ok lets say that is the case then any write attempt to A results in an
> > > > > exclusive cacheline state and at that point the cacheline is going to
> > > > > reflect current contents. So if kfree would write to the object then it
> > > > > will have the current information.
> > > >
> > > > No, because store to the object can still be pending on another CPU.
> > >
> > > That would violate the cache coherency protocol as far as I can tell?
> >
> > It would, but there are three cases that neverthess need to be considered:
> > (1) The pointer is in a different cacheline than is the pointed-to object,
> > and ordering of accesses to the pointer and object matter, (2) The object
> > covers more than one cacheline, and the ordering of accesses matters,
> > and (3) The fields are accessed using non-atomic operations and the
> > compiler can see into kfree().  I am most worried about #3.
> 
> (1) was covered in the discussion and it seems that this is tied to the
> way the global pointer is being used.

I am inclined to agree here.

> (2) If the ordering matters then we need to have proper fences etc.

Including compiler fences when required.

> (3) What does "see" mean? The compiler knows the code of kfree and pulls
> bits of processing out?

Yep, including for example the store adding to the SLUB per-CPU freelist.
Keeping the C aliasing rules in mind.

> > > > So kfree can get the object in E state in cache, but then another CPU
> > > > will finally issue the store and overwrite the slab freelist.
> > >
> > > Sounds like a broken processor design to me. AFAICT the MESI protocol does
> > > not allow this.
> >
> > We really need to focus on specific code sequences.  I suspect that you
> > guys are talking past each other.
> 
> Could be. Lets be clear here.
> 
> > > > > Also what does it matter for kfree since the contents of the object are no
> > > > > longer in use?
> > > >
> > > > I don't understand. First, it is not "not in use" infinitely, it can
> > > > be in use the very next moment. Also, we don't want corruption of slab
> > > > freelist as well. And we don't want spurious failure of debug
> > > > allocator that checks that there no writes after free.
> > >
> > > Slab freelists are protected by locks.
> >
> > Are these locks acquired on the fastpaths?  I was under the impression
> > that they are not.  That said, I do believe that these locks fully
> > protect the case where one CPU does kfree() and some other CPU later
> > returns that same object from kmalloc().
> 
> Fastpaths only do per cpu processing and do not cross boundaries. If
> objects are handed over to other processors queues or concurrent accesses
> occur then locks are used.

Good, then the only issues with the fastpath freelists would involve
compiler optimizations.

> > > A processor that can randomly defer writes to cachelines in the face of
> > > other processors owning cachelines exclusively does not seem sane to me.
> > > In fact its no longer exclusive.
> >
> > Welcome to the wonderful world of store buffers, which are present even
> > on strongly ordered systems such as x86 and the mainframe.
> 
> Store buffers hold complete cachelines that have been written to by a
> processor.

In many cases, partial cachelines.  If the cacheline is not available
locally, the processor cannot know the contents of the rest of the cache
line, only the contents of the portion that it recently stored into.

>            Hmmm... Guess I need to think more about this. Dont know the
> detail here on how they interact with cacheline exclusivity and stuff.

A large number of stores to the same variable can happen concurrently,
and the system can stitch together the order of these stores after
the fact.

> > > Sounds like the atomic_read needs more barriers.
> >
> > We all know that this won't happen.
> 
> Well then welcome to the wonderful world of a broken kernel. Still
> wondering what this has to do with slab allocators.

The concern I have is that the compiler might be able to reorder the
running CPU's last accesses to an object that is to be kfree()ed with
kfree()'s accesses.  The issue being that the compiler is within its
rights to assume pointers to different types don't alias unless one of the
types is char * (or some such, Dmitry can correct me if I am confused).

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
