Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f51.google.com (mail-qg0-f51.google.com [209.85.192.51])
	by kanga.kvack.org (Postfix) with ESMTP id E766F6B0038
	for <linux-mm@kvack.org>; Wed,  9 Sep 2015 14:44:23 -0400 (EDT)
Received: by qgx61 with SMTP id 61so15915574qgx.3
        for <linux-mm@kvack.org>; Wed, 09 Sep 2015 11:44:23 -0700 (PDT)
Received: from e31.co.us.ibm.com (e31.co.us.ibm.com. [32.97.110.149])
        by mx.google.com with ESMTPS id m110si9404647qge.25.2015.09.09.11.44.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Wed, 09 Sep 2015 11:44:23 -0700 (PDT)
Received: from /spool/local
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Wed, 9 Sep 2015 12:44:22 -0600
Received: from b03cxnp08027.gho.boulder.ibm.com (b03cxnp08027.gho.boulder.ibm.com [9.17.130.19])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id DA3E81FF0050
	for <linux-mm@kvack.org>; Wed,  9 Sep 2015 12:35:27 -0600 (MDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by b03cxnp08027.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t89IiHgS19267668
	for <linux-mm@kvack.org>; Wed, 9 Sep 2015 11:44:17 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t89IiHhb028917
	for <linux-mm@kvack.org>; Wed, 9 Sep 2015 12:44:17 -0600
Date: Wed, 9 Sep 2015 11:44:15 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: Is it OK to pass non-acquired objects to kfree?
Message-ID: <20150909184415.GJ4029@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <CACT4Y+bt4mBzQZDTjJDQFtOs463QFUt7-OJWEABCocNzork8Ww@mail.gmail.com>
 <alpine.DEB.2.11.1509081205120.25526@east.gentwo.org>
 <CACT4Y+bvaJ6cC_=A1VGx=cT_bkB-teXNud0Wgt33E1AtBYNTSg@mail.gmail.com>
 <alpine.DEB.2.11.1509090901480.18992@east.gentwo.org>
 <CACT4Y+ZpToAmaboGDvFhgWUqtnUcJACprg=XSTkrJYE4DQ1jcA@mail.gmail.com>
 <alpine.DEB.2.11.1509090930510.19262@east.gentwo.org>
 <CACT4Y+b_wDnC3mONjmq+F9kaw1_L_8z=E__1n25ZgLhx-biEmQ@mail.gmail.com>
 <alpine.DEB.2.11.1509091036590.19663@east.gentwo.org>
 <CACT4Y+a6rjbEoP7ufgyJimjx3qVh81TToXjL9Rnj-bHNregZXg@mail.gmail.com>
 <alpine.DEB.2.11.1509091251150.20311@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1509091251150.20311@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Dmitry Vyukov <dvyukov@google.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrey Konovalov <andreyknvl@google.com>, Alexander Potapenko <glider@google.com>

On Wed, Sep 09, 2015 at 12:56:20PM -0500, Christoph Lameter wrote:
> On Wed, 9 Sep 2015, Dmitry Vyukov wrote:
> 
> > > Guess this means that cachelines (A) may not have been be written back to
> > > memory when the pointer to the object is written to another cacheline(B)
> > > and that cacheline B arrives at the other processor first which has
> > > outdated cachelines A in its cache? So the other processor uses the
> > > contents of B to get to the pointer to A but then accesses outdated
> > > information since the object contents cachelines (A) have not arrive there
> > > yet?
> >
> > That's one example.
> > Another example will be that kfree reads size from the object _before_
> > the object to the pointer is read. That sounds crazy, but it as
> > actually possible on Alpha processors.
> 
> The size is encoded in the kmem_cache structure which is not changed. How
> can that be relevant?

IIRC, at one point some of the Linux-kernel allocators stored some
state in the object itself.  What is the current state?

> > Another example will be that C compiler lets a store to the object in
> > kmalloc sink below the store of the pointer to the object into global.
> 
> Well if the pointer is used nakedly to communicate between threads the
> barriers need to be used but what does this have to do with slabs?

It certainly is something that the users of slabs need to know.
In particular, what exactly are the synchronization requirements that
the slabs place on their users?  Dmitry needs to know this because he
is constructing a tool that automatically locates race conditions, and
he needs to know who to complain to when he finds a race condition that
involves slabs and their users.

Here are some of my guesses, but you are the maintainer, not me.  ;-)

1.	Do there need to be any compiler or CPU barriers between
	last use and free on a single thread?  Here is an example:

	p = kmalloc(sizeof(*p), GFP_KERNEL);
	if (!p)
		return NULL;
	initialize_me(p);
	if (do_not_really_need_it(p)) {
		kfree(p);
		return NULL;
	}
	return p;

	Suppose that both initialize_me() and do_not_really_need_it()
	are static inline functions, so that all of their loads and
	stores to the structure referenced by p are visible to the
	compiler.  Is the above code correct, or is the user required
	to place something like barrier() before the call to kfree()?

	I would hope that the caller of kfree() need not invoke barrier()
	beforehand, but it is your decision.  If the caller need not
	invoke barrier(), then it might (or might not) need to be supplied
	by the kfree() implementation.	From what I understand, Dmitry's
	tool indicated a barrier() is needed somewhere in this code path.

2.	Is it OK to do a hot handoff from kmalloc() on one thread to
	kfree on another?

	Thread 0:

		gp = kmalloc(sizeof(*gp), GFP_KERNEL);

	Thread 1:

		p = READ_ONCE(gp);
		if (gp)
			kfree(gp);

	I would be strongly tempted to just say "no" to this use case
	on the grounds that it is pointless, but you know your users
	better than do I.

3.	The case that Dmitry pointed out was something like the following:

	Thread 0:

		p = kmalloc(sizeof(*p), GFP_KERNEL);
		if (!p)
			return NULL;
		atomic_set(&p->rc, 1);
		return p;

	Thread 1:

		WARN_ON(!p->rc);  /* Must own ref to take another. */
		atomic_inc(&p->rc);

	Thread 2:

		if (p->rc == 1 ||
		    atomic_dec_and_test(&p->rc))
		    	kfree(p);

	This ends up really being the same as #1 above.

> > > Ok lets say that is the case then any write attempt to A results in an
> > > exclusive cacheline state and at that point the cacheline is going to
> > > reflect current contents. So if kfree would write to the object then it
> > > will have the current information.
> >
> > No, because store to the object can still be pending on another CPU.
> 
> That would violate the cache coherency protocol as far as I can tell?

It would, but there are three cases that neverthess need to be considered:
(1) The pointer is in a different cacheline than is the pointed-to object,
and ordering of accesses to the pointer and object matter, (2) The object
covers more than one cacheline, and the ordering of accesses matters,
and (3) The fields are accessed using non-atomic operations and the
compiler can see into kfree().  I am most worried about #3.

> > So kfree can get the object in E state in cache, but then another CPU
> > will finally issue the store and overwrite the slab freelist.
> 
> Sounds like a broken processor design to me. AFAICT the MESI protocol does
> not allow this.

We really need to focus on specific code sequences.  I suspect that you
guys are talking past each other.

> > > Also what does it matter for kfree since the contents of the object are no
> > > longer in use?
> >
> > I don't understand. First, it is not "not in use" infinitely, it can
> > be in use the very next moment. Also, we don't want corruption of slab
> > freelist as well. And we don't want spurious failure of debug
> > allocator that checks that there no writes after free.
> 
> Slab freelists are protected by locks.

Are these locks acquired on the fastpaths?  I was under the impression
that they are not.  That said, I do believe that these locks fully
protect the case where one CPU does kfree() and some other CPU later
returns that same object from kmalloc().

> A processor that can randomly defer writes to cachelines in the face of
> other processors owning cachelines exclusively does not seem sane to me.
> In fact its no longer exclusive.

Welcome to the wonderful world of store buffers, which are present even
on strongly ordered systems such as x86 and the mainframe.

> > > Could you please come up with a concrete example where there is
> > > brokenness that we need to consider.
> >
> > Well, both examples in the first email are broken according to all of
> > Documentation/memory-barriers.txt, Alpha processor manual and C
> > standard (assuming that object passed to kfree must be in "quiescent"
> > state).
> > If you want a description of an exact scenario of how it can break:
> > building of freelist in kfree can be hoisted above check of
> > atomic_read(&pid->count) == 1 on Alpha processors, then the freelist
> > can become corrupted.
> 
> Sounds like the atomic_read needs more barriers.

We all know that this won't happen.

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
