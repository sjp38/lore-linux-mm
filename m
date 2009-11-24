Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8E9AD6B009C
	for <linux-mm@kvack.org>; Tue, 24 Nov 2009 16:47:48 -0500 (EST)
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by e6.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id nAOLrQvp024045
	for <linux-mm@kvack.org>; Tue, 24 Nov 2009 16:53:26 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nAOLlfSS1896516
	for <linux-mm@kvack.org>; Tue, 24 Nov 2009 16:47:41 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nAOLleYS008557
	for <linux-mm@kvack.org>; Tue, 24 Nov 2009 16:47:41 -0500
Date: Tue, 24 Nov 2009 13:47:40 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: lockdep complaints in slab allocator
Message-ID: <20091124214740.GJ6831@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20091118181202.GA12180@linux.vnet.ibm.com> <84144f020911192249l6c7fa495t1a05294c8f5b6ac8@mail.gmail.com> <1258709153.11284.429.camel@laptop> <84144f020911200238w3d3ecb38k92ca595beee31de5@mail.gmail.com> <1258714328.11284.522.camel@laptop> <4B067816.6070304@cs.helsinki.fi> <1258729748.4104.223.camel@laptop> <1259002800.5630.1.camel@penberg-laptop> <20091124162311.GA8679@linux.vnet.ibm.com> <84144f020911241259r3a604b29yb59902655ec03a20@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <84144f020911241259r3a604b29yb59902655ec03a20@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Peter Zijlstra <peterz@infradead.org>, linux-mm@kvack.org, cl@linux-foundation.org, mpm@selenic.com, LKML <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Tue, Nov 24, 2009 at 10:59:44PM +0200, Pekka Enberg wrote:
> On Tue, Nov 24, 2009 at 6:23 PM, Paul E. McKenney
> <paulmck@linux.vnet.ibm.com> wrote:
> > On Mon, Nov 23, 2009 at 09:00:00PM +0200, Pekka Enberg wrote:
> >> Hi Peter,
> >>
> >> On Fri, 2009-11-20 at 16:09 +0100, Peter Zijlstra wrote:
> >> > > Uh, ok, so apparently I was right after all. There's a comment in
> >> > > free_block() above the slab_destroy() call that refers to the comment
> >> > > above alloc_slabmgmt() function definition which explains it all.
> >> > >
> >> > > Long story short: ->slab_cachep never points to the same kmalloc cache
> >> > > we're allocating or freeing from. Where do we need to put the
> >> > > spin_lock_nested() annotation? Would it be enough to just use it in
> >> > > cache_free_alien() for alien->lock or do we need it in
> >> > > cache_flusharray() as well?
> >> >
> >> > You'd have to somehow push the nested state down from the
> >> > kmem_cache_free() call in slab_destroy() to all nc->lock sites below.
> >>
> >> That turns out to be _very_ hard. How about something like the following
> >> untested patch which delays slab_destroy() while we're under nc->lock.
> >>
> >>                       Pekka
> >
> > Preliminary tests look good!  The test was a ten-hour rcutorture run on
> > an 8-CPU Power system with a half-second delay between randomly chosen
> > CPU-hotplug operations.  No lockdep warnings.  ;-)
> >
> > Will keep hammering on it.
> 
> Thanks! Please let me know when you're hammered it enough :-). Peter,
> may I have your ACK or NAK on the patch, please?

I expect to hammer it over the USA Thanksgiving holiday Thu-Sun this week.
It is like this, Pekka: since I don't drink, it is instead your code
that is going to get hammered this weekend!

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
