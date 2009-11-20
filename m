Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 4F72F6B00AC
	for <linux-mm@kvack.org>; Fri, 20 Nov 2009 04:26:04 -0500 (EST)
Subject: Re: lockdep complaints in slab allocator
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <84144f020911192249l6c7fa495t1a05294c8f5b6ac8@mail.gmail.com>
References: <20091118181202.GA12180@linux.vnet.ibm.com>
	 <84144f020911192249l6c7fa495t1a05294c8f5b6ac8@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 20 Nov 2009 10:25:53 +0100
Message-ID: <1258709153.11284.429.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: paulmck@linux.vnet.ibm.com, linux-mm@kvack.org, cl@linux-foundation.org, mpm@selenic.com, LKML <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Fri, 2009-11-20 at 08:49 +0200, Pekka Enberg wrote:
> Hi Paul,
> 
> On Wed, Nov 18, 2009 at 8:12 PM, Paul E. McKenney
> <paulmck@linux.vnet.ibm.com> wrote:
> > I am seeing some lockdep complaints in rcutorture runs that include
> > frequent CPU-hotplug operations.  The tests are otherwise successful.
> > My first thought was to send a patch that gave each array_cache
> > structure's ->lock field its own struct lock_class_key, but you already
> > have a init_lock_keys() that seems to be intended to deal with this.
> >
> > So, please see below for the lockdep complaint and the .config file.
> >
> >                                                        Thanx, Paul
> >
> > ------------------------------------------------------------------------
> >
> > =============================================
> > [ INFO: possible recursive locking detected ]
> > 2.6.32-rc4-autokern1 #1
> > ---------------------------------------------
> > syslogd/2908 is trying to acquire lock:
> >  (&nc->lock){..-...}, at: [<c0000000001407f4>] .kmem_cache_free+0x118/0x2d4
> >
> > but task is already holding lock:
> >  (&nc->lock){..-...}, at: [<c0000000001411bc>] .kfree+0x1f0/0x324
> >
> > other info that might help us debug this:
> > 3 locks held by syslogd/2908:
> >  #0:  (&u->readlock){+.+.+.}, at: [<c0000000004556f8>] .unix_dgram_recvmsg+0x70/0x338
> >  #1:  (&nc->lock){..-...}, at: [<c0000000001411bc>] .kfree+0x1f0/0x324
> >  #2:  (&parent->list_lock){-.-...}, at: [<c000000000140f64>] .__drain_alien_cache+0x50/0xb8
> 
> I *think* this is a false positive. The nc->lock in slab_destroy()
> should always be different from the one we took in kfree() because
> it's a per-struct kmem_cache "slab cache". Peter, what do you think?
> If my analysis is correct, any suggestions how to fix lockdep
> annotations in slab?

Did anything change recently? git-log mm/slab.c doesn't show anything
obvious, although ec5a36f94e7ca4b1f28ae4dd135cd415a704e772 has the exact
same lock recursion msg ;-)

So basically its this stupid recursion issue where you allocate the slab
meta structure using the slab allocator, and now have to free while
freeing, right?

/me gets lost in slab, tries again..

The code in kmem_cache_create() suggests its not even fixed size, so
there is no single cache backing all this OFF_SLAB muck :-(

It does appear to be limited to the kmalloc slabs..

There's a few possible solutions -- in order of preference:

 1) do the great slab cleanup now and remove slab.c, this will avoid any
further waste of manhours and braincells trying to make slab limp along.

 2) propagate the nesting information and user spin_lock_nested(), given
that slab is already a rat's nest, this won't make it any less obvious.

 3) Give each kmalloc cache its own lock class.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
