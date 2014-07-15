Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id DF0EB6B0031
	for <linux-mm@kvack.org>; Tue, 15 Jul 2014 15:28:27 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id hz1so3845145pad.8
        for <linux-mm@kvack.org>; Tue, 15 Jul 2014 12:28:27 -0700 (PDT)
Received: from mail-pd0-x236.google.com (mail-pd0-x236.google.com [2607:f8b0:400e:c02::236])
        by mx.google.com with ESMTPS id c4si512103pdk.312.2014.07.15.12.28.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 15 Jul 2014 12:28:27 -0700 (PDT)
Received: by mail-pd0-f182.google.com with SMTP id fp1so4791596pdb.27
        for <linux-mm@kvack.org>; Tue, 15 Jul 2014 12:28:26 -0700 (PDT)
Date: Tue, 15 Jul 2014 12:26:37 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 1/2] shmem: fix faulting into a hole, not taking
 i_mutex
In-Reply-To: <53C551A8.2040400@suse.cz>
Message-ID: <alpine.LSU.2.11.1407151156110.3571@eggly.anvils>
References: <alpine.LSU.2.11.1407150247540.2584@eggly.anvils> <alpine.LSU.2.11.1407150329250.2584@eggly.anvils> <53C551A8.2040400@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michel Lespinasse <walken@google.com>, Lukas Czerner <lczerner@redhat.com>, Dave Jones <davej@redhat.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, 15 Jul 2014, Vlastimil Babka wrote:
> On 07/15/2014 12:31 PM, Hugh Dickins wrote:
> > f00cdc6df7d7 ("shmem: fix faulting into a hole while it's punched") was
> > buggy: Sasha sent a lockdep report to remind us that grabbing i_mutex in
> > the fault path is a no-no (write syscall may already hold i_mutex while
> > faulting user buffer).
> > 
> > We tried a completely different approach (see following patch) but that
> > proved inadequate: good enough for a rational workload, but not good
> > enough against trinity - which forks off so many mappings of the object
> > that contention on i_mmap_mutex while hole-puncher holds i_mutex builds
> > into serious starvation when concurrent faults force the puncher to fall
> > back to single-page unmap_mapping_range() searches of the i_mmap tree.
> > 
> > So return to the original umbrella approach, but keep away from i_mutex
> > this time.  We really don't want to bloat every shmem inode with a new
> > mutex or completion, just to protect this unlikely case from trinity.
> > So extend the original with wait_queue_head on stack at the hole-punch
> > end, and wait_queue item on the stack at the fault end.
> 
> Hi, thanks a lot, I will definitely test it soon, although my reproducer is
> rather limited - it already works fine with the current kernel. Trinity will
> be more useful here.

Yes, 2/2 (minus the page->swap addition) already proved good enough for
your (more realistic than trinity) testcase, and for mine.  And 1/2 (minus
the new waiting) already proved good enough for you too, just more awkward
to backport way back.  I agree that it's trinity we most need, to check
that I didn't mess up 1/2 - though your testing welcome too, thanks.

> But there's something that caught my eye so I though I
> would raise the concern now.

Thank you.

> 
> > @@ -760,7 +760,7 @@ static int shmem_writepage(struct page *
> >   			spin_lock(&inode->i_lock);
> >   			shmem_falloc = inode->i_private;
> 
> Without ACCESS_ONCE, can shmem_falloc potentially become an alias on
> inode->i_private and later become re-read outside of the lock?

No, it could be re-read inside the locked section (which is okay since
the locking ensures the same value would be re-read each time), but it
cannot be re-read after the unlock.  The unlock guarantees that (whereas
an assignment after the unlock might be moved up before the unlock).

I searched for a simple example (preferably not in code written by me!)
to convince you.  I thought it would be easy to find an example of

	spin_lock(&lock);
	thing_to_free = whatever;
	spin_unlock(&lock);
	if (thing_to_free)
		free(thing_to_free);

but everything I hit upon was actually a little more complicated than
than that (e.g. involving whatever(), or setting whatever = NULL after),
and therefore less convincing.  Please hunt around to convince yourself.

> 
> >   			if (shmem_falloc &&
> > -			    !shmem_falloc->mode &&
> > +			    !shmem_falloc->waitq &&
> >   			    index >= shmem_falloc->start &&
> >   			    index < shmem_falloc->next)
> >   				shmem_falloc->nr_unswapped++;
...
> >   	if (unlikely(inode->i_private)) {
> >   		struct shmem_falloc *shmem_falloc;
> > 
> >   		spin_lock(&inode->i_lock);
> >   		shmem_falloc = inode->i_private;
> 
> Same here.

Same here :)

> 
> > -		if (!shmem_falloc ||
> > -		    shmem_falloc->mode != FALLOC_FL_PUNCH_HOLE ||
> > -		    vmf->pgoff < shmem_falloc->start ||
> > -		    vmf->pgoff >= shmem_falloc->next)
> > -			shmem_falloc = NULL;
> > -		spin_unlock(&inode->i_lock);
> > -		/*
> > -		 * i_lock has protected us from taking shmem_falloc seriously
> > -		 * once return from shmem_fallocate() went back up that
> > stack.
> > -		 * i_lock does not serialize with i_mutex at all, but it does
> > -		 * not matter if sometimes we wait unnecessarily, or
> > sometimes
> > -		 * miss out on waiting: we just need to make those cases
> > rare.
> > -		 */
> > -		if (shmem_falloc) {
> > +		if (shmem_falloc &&
> > +		    shmem_falloc->waitq &&
> 
> Here it's operating outside of lock.

No, it's inside the lock: just easier to see from the patched source
than from the patch itself.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
