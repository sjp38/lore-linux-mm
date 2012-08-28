Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id C64EA6B0068
	for <linux-mm@kvack.org>; Tue, 28 Aug 2012 13:37:32 -0400 (EDT)
Date: Tue, 28 Aug 2012 14:37:13 -0300
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH v9 3/5] virtio_balloon: introduce migration primitives to
 balloon pages
Message-ID: <20120828173713.GA1750@t510.redhat.com>
References: <cover.1345869378.git.aquini@redhat.com>
 <a1ceca79d95bc7de2a6b62a2e565b95286dbdf75.1345869378.git.aquini@redhat.com>
 <20120826074244.GC19551@redhat.com>
 <20120827194713.GA6517@t510.redhat.com>
 <20120828155410.GE2903@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120828155410.GE2903@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>, Peter Zijlstra <peterz@infradead.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Tue, Aug 28, 2012 at 06:54:10PM +0300, Michael S. Tsirkin wrote:
> On Mon, Aug 27, 2012 at 04:47:13PM -0300, Rafael Aquini wrote:
> > On Sun, Aug 26, 2012 at 10:42:44AM +0300, Michael S. Tsirkin wrote:
> > > 
> > > Reading two atomics and doing math? Result can even be negative.
> > > I did not look at use closely but it looks suspicious.
> > Doc on atomic_read says:
> > "
> > The read is atomic in that the return value is guaranteed to be one of the
> > values initialized or modified with the interface operations if a proper
> > implicit or explicit memory barrier is used after possible runtime
> > initialization by any other thread and the value is modified only with the
> > interface operations.
> > "
> > 
> > There's no runtime init by other thread than balloon's itself at device register,
> > and the operations (inc, dec) are made by the proper interface operations
> > only when protected by the spinlock pages_lock. It does not look suspicious, IMHO.
> 
> Any use of multiple atomics is suspicious.
> Please just avoid it if you can. What's wrong with locking?
> 
> > I'm failing to see how it could become a negative on that case, since you cannot
> > isolate more pages than what was previoulsy inflated to balloon's list.
> 
> There is no order guarantee. So in
> A - B you can read B long after both A and B has been incremented.
> Maybe it is safe in this case but it needs careful documentation
> to explain how ordering works. Much easier to keep it all simple.
> 
> > 
> > > It's already the case everywhere except __wait_on_isolated_pages,
> > > so just fix that, and then we can keep using int instead of atomics.
> > > 
> > Sorry, I quite didn't get you here. fix what?
> 
> It's in the text you removed above. Access values under lock.
>

So, you prefer this way:

/*
 * __wait_on_isolated_pages - check if leak_balloon() must wait on isolated
 *                            pages before proceeding with the page release.
 * @vb         : pointer to the struct virtio_balloon describing this device.
 * @leak_target: how many pages we are attempting to release this round.
 */
static inline void __wait_on_isolated_pages(struct virtio_balloon *vb,
                                            size_t leak_target)
{
        unsigned int num_pages, isolated_pages;
        spin_lock(&vb->pages_lock);
        num_pages = vb->num_pages;
        isolated_pages = vb->num_isolated_pages;
        spin_unlock(&vb->pages_lock);
        /*
         * If isolated pages are making our leak target bigger than the
         * total pages that we can release this round. Let's wait for
         * migration returning enough pages back to balloon's list.
         */
        wait_event(vb->config_change,
                   (!isolated_pages ||
                    leak_target <= (num_pages - isolated_pages)));
}

?

> >  
> > > That's 1K on stack - and can become more if we increase
> > > VIRTIO_BALLOON_ARRAY_PFNS_MAX.  Probably too much - this is the reason
> > > we use vb->pfns.
> > >
> > If we want to use vb->pfns we'll have to make leak_balloon mutual exclusive with
> > page migration (as it was before), but that will inevictably bring us back to
> > the discussion on breaking the loop when isolated pages make leak_balloon find
> > less pages than it wants to release at each leak round.
> > 
> 
> I don't think this is an issue. The issue was busy waiting in that case.
>
But, in fact, it is. 
As we couldn't drop the mutex that prevents migration from happening, otherwise
the migration threads would screw up with our vb->pfns array, there will be no point
on keep waiting for isolated pages being reinserted on balloon's list, cause the
migration threads that will accomplish that task are also waiting on us dropping
the mutex.

You may argue that we could flag virtballoon_migratepage() to give up and return
before even trying to aquire the mutex, if a leak is ongoing -- deferring work
to virtballoon_putbackpage(). However, I'm eager to think that for this case,
the CPU time we spent isolating pages for compaction would be simply wasted and,
 perhaps, no effective compaction was even reached.
And that makes me think it would have been better to stick with the old logics of
breaking the loop since leak_balloon(), originally, also remains busy waiting
while pursuing its target, anyway.

That's the trade here, IMO. If one really wants to wait on potentially isolated
pages getting back to the list before proceeding, we'll have to burn a little
more stack space with local variables, unfortunately.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
