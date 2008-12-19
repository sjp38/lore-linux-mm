Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 9A97C6B0044
	for <linux-mm@kvack.org>; Fri, 19 Dec 2008 02:01:05 -0500 (EST)
Date: Fri, 19 Dec 2008 08:03:11 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc][patch 1/2] mnt_want_write speedup 1
Message-ID: <20081219070311.GA26419@wotan.suse.de>
References: <20081219061937.GA16268@wotan.suse.de> <1229669697.17206.602.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1229669697.17206.602.camel@nimitz>
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Dec 18, 2008 at 10:54:57PM -0800, Dave Hansen wrote:
> On Fri, 2008-12-19 at 07:19 +0100, Nick Piggin wrote:
> > @@ -369,24 +283,34 @@ static int mnt_make_readonly(struct vfsm
> >  {
> >         int ret = 0;
> > 
> > -       lock_mnt_writers();
> > +       spin_lock(&vfsmount_lock);
> > +       mnt->mnt_flags |= MNT_WRITE_HOLD;
> >         /*
> > -        * With all the locks held, this value is stable
> > +        * After storing MNT_WRITE_HOLD, we'll read the counters. This store
> > +        * should be visible before we do.
> >          */
> > -       if (atomic_read(&mnt->__mnt_writers) > 0) {
> > +       smp_mb();
> > +
> > +       /*
> > +        * With writers on hold, if this value is zero, then there are definitely
> > +        * no active writers (although held writers may subsequently increment
> > +        * the count, they'll have to wait, and decrement it after seeing
> > +        * MNT_READONLY).
> > +        */
> > +       if (count_mnt_writers(mnt) > 0) {
> >                 ret = -EBUSY;
> 
> OK, I think this is one of the big races inherent with this approach.
> There's nothing in here to ensure that no one is in the middle of an
> update during this code.  The preempt_disable() will, of course, reduce
> the window, but I think there's still a race here.

MNT_WRITE_HOLD is set, so any writer that has already made it past
the MNT_WANT_WRITE loop will have its count visible here. Any writer
that has not made it past that loop will wait until the slowpath
completes and then the fastpath will go on to check whether the
mount is still writeable.


> Is this where you wanted to put the synchronize_rcu()?  That's a nice
> touch because although *that* will ensure that no one is in the middle
> of an increment here and that they will, at worst, be blocking on the
> MNT_WRITE_HOLD thing.

Basically the synchronize_rcu would go in place of the smp_mb() here,
and it would automatically eliminate the corresponding smp_mb() in
the fastpath (because a quiescent state on a CPU is guaranteed to
include a barrier).

 
> I kinda remember going down this path a few times, bu you may have
> cracked the problem.  Dunno.  I need to stare at the code a bit more
> before I'm convinced.  I'm optimistic, but a bit skeptical this can
> work. :)
> 
> I am really wondering where all the cost is that you're observing in
> those benchmarks.  Have you captured any profiles by chance?

Yes, as I said, the cycles seem to be in the spin_lock instructions.
It's hard to see _exactly_ what's going on with oprofile and an out
of order CPU, but the cycles as I said are all right after spin_lock
returns. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
