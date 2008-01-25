Date: Fri, 25 Jan 2008 11:03:07 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 1/4] mmu_notifier: Core code
In-Reply-To: <20080125185646.GQ3058@sgi.com>
Message-ID: <Pine.LNX.4.64.0801251058170.3198@schroedinger.engr.sgi.com>
References: <20080125055606.102986685@sgi.com> <20080125055801.212744875@sgi.com>
 <20080125183934.GO26420@sgi.com> <Pine.LNX.4.64.0801251041040.672@schroedinger.engr.sgi.com>
 <20080125185646.GQ3058@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Andrea Arcangeli <andrea@qumranet.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, Nick Piggin <npiggin@suse.de>, kvm-devel@lists.sourceforge.net, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Fri, 25 Jan 2008, Robin Holt wrote:

> > > > +void mmu_notifier_release(struct mm_struct *mm)
> > > > +{
> > > > +	struct mmu_notifier *mn;
> > > > +	struct hlist_node *n;
> > > > +
> > > > +	if (unlikely(!hlist_empty(&mm->mmu_notifier.head))) {
> > > > +		rcu_read_lock();
> > > > +		hlist_for_each_entry_rcu(mn, n,
> > > > +					  &mm->mmu_notifier.head, hlist) {
> > > > +			if (mn->ops->release)
> > > > +				mn->ops->release(mn, mm);
> > > > +			hlist_del(&mn->hlist);
> > > 
> > > I think the hlist_del needs to be before the function callout so we can free
> > > the structure without a use-after-free issue.
> > 
> > The list head is in the mm_struct. This will be freed later.
> > 
> 
> I meant the structure pointed to by &mn.  I assume it is intended that
> structure be kmalloc'd as part of a larger structure.  The driver is the
> entity which created that structure and should be the one to free it.

mn will be pointing to the listhead in the mm_struct one after the other. 
You mean the ops structure?

> > > > +void mmu_notifier_register(struct mmu_notifier *mn, struct mm_struct *mm)
> > > > +{
> > > > +	spin_lock(&mmu_notifier_list_lock);
> > > 
> > > Shouldn't this really be protected by the down_write(mmap_sem)?  Maybe:
> > 
> > Ok. We could switch this to mmap_sem protection for the mm_struct but the 
> > rmap notifier is not associated with an mm_struct. So we would need to 
> > keep it there. Since we already have a spinlock: Just use it for both to 
> > avoid further complications.
> 
> But now you are putting a global lock in where it is inappropriate.

The lock is only used during register and unregister. Very low level 
usage.

> > > XPMEM, would also benefit from a call early.  We could make all the
> > > segments as being torn down and start the recalls.  We already have
> > > this code in and working (have since it was first written 6 years ago).
> > > In this case, all segments are torn down with a single message to each
> > > of the importing partitions.  In contrast, the teardown code which would
> > > happen now would be one set of messages for each vma.
> > 
> > So we need an additional global teardown call? Then we'd need to switch 
> > off the vma based invalidate_range()?
> 
> No, EXACTLY what I originally was asking for, either move this call site
> up, introduce an additional mmu_notifier op, or place this one in two
> locations with a flag indicating which call is being made.

Add a new invalidate_all() call? Then on exit we do

1. invalidate_all()

2. invalidate_range() for each vma

3. release()

We cannot simply move the call up because there will be future range 
callbacks on vma invalidation.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
