Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 6E5386B0044
	for <linux-mm@kvack.org>; Fri, 19 Dec 2008 10:29:59 -0500 (EST)
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id mBJFVH6I024234
	for <linux-mm@kvack.org>; Fri, 19 Dec 2008 10:31:17 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mBJFW5XL187556
	for <linux-mm@kvack.org>; Fri, 19 Dec 2008 10:32:07 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mBJGWFnt002591
	for <linux-mm@kvack.org>; Fri, 19 Dec 2008 11:32:15 -0500
Subject: Re: [rfc][patch 1/2] mnt_want_write speedup 1
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20081219070311.GA26419@wotan.suse.de>
References: <20081219061937.GA16268@wotan.suse.de>
	 <1229669697.17206.602.camel@nimitz>  <20081219070311.GA26419@wotan.suse.de>
Content-Type: text/plain
Date: Fri, 19 Dec 2008 07:32:01 -0800
Message-Id: <1229700721.17206.634.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 2008-12-19 at 08:03 +0100, Nick Piggin wrote:
> On Thu, Dec 18, 2008 at 10:54:57PM -0800, Dave Hansen wrote:
> > On Fri, 2008-12-19 at 07:19 +0100, Nick Piggin wrote:
> > > @@ -369,24 +283,34 @@ static int mnt_make_readonly(struct vfsm
> > >  {
> > >         int ret = 0;
> > > 
> > > -       lock_mnt_writers();
> > > +       spin_lock(&vfsmount_lock);
> > > +       mnt->mnt_flags |= MNT_WRITE_HOLD;
> > >         /*
> > > -        * With all the locks held, this value is stable
> > > +        * After storing MNT_WRITE_HOLD, we'll read the counters. This store
> > > +        * should be visible before we do.
> > >          */
> > > -       if (atomic_read(&mnt->__mnt_writers) > 0) {
> > > +       smp_mb();
> > > +
> > > +       /*
> > > +        * With writers on hold, if this value is zero, then there are definitely
> > > +        * no active writers (although held writers may subsequently increment
> > > +        * the count, they'll have to wait, and decrement it after seeing
> > > +        * MNT_READONLY).
> > > +        */
> > > +       if (count_mnt_writers(mnt) > 0) {
> > >                 ret = -EBUSY;
> > 
> > OK, I think this is one of the big races inherent with this approach.
> > There's nothing in here to ensure that no one is in the middle of an
> > update during this code.  The preempt_disable() will, of course, reduce
> > the window, but I think there's still a race here.
> 
> MNT_WRITE_HOLD is set, so any writer that has already made it past
> the MNT_WANT_WRITE loop will have its count visible here. Any writer
> that has not made it past that loop will wait until the slowpath
> completes and then the fastpath will go on to check whether the
> mount is still writeable.

Ahh, got it.  I'm slowly absorbing the barriers.  Not the normal way, I
code.

I thought there was another race with MNT_WRITE_HOLD since mnt_flags
isn't really managed atomically.  But, by only modifying with the
vfsmount_lock, I think it is OK.

I also wondered if there was a possibility of getting a spurious -EBUSY
when remounting r/w->r/o.  But, that turned out to just happen when the
fs was *already* r/o.  So that looks good.

While this has cleared out a huge amount of complexity, I can't stop
wondering if this could be done with a wee bit more "normal" operations.
I'm pretty sure I couldn't have come up with this by myself, and I'm a
bit worried that I wouldn't be able to find a race in it if one reared
its ugly head.  

Is there a real good reason to allocate the percpu counters dynamically?
Might as well stick them in the vfsmount and let the one
kmem_cache_zalloc() in alloc_vfsmnt() do a bit larger of an allocation.
Did you think that was going to bloat it to a compound allocation or
something?  I hate the #ifdefs. :)

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
