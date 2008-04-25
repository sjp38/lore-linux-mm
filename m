Date: Fri, 25 Apr 2008 18:56:40 +0200
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [PATCH 1 of 9] Lock the entire mm to prevent any mmu related
	operation to happen
Message-ID: <20080425165639.GA23300@duo.random>
References: <ec6d8f91b299cf26cce5.1207669444@duo.random> <200804221506.26226.rusty@rustcorp.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200804221506.26226.rusty@rustcorp.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rusty Russell <rusty@rustcorp.com.au>
Cc: Christoph Lameter <clameter@sgi.com>, akpm@linux-foundation.org, Nick Piggin <npiggin@suse.de>, Steve Wise <swise@opengridcomputing.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Jack Steiner <steiner@sgi.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

I somehow lost missed this email in my inbox, found it now because it
was strangely still unread... Sorry for the late reply!

On Tue, Apr 22, 2008 at 03:06:24PM +1000, Rusty Russell wrote:
> On Wednesday 09 April 2008 01:44:04 Andrea Arcangeli wrote:
> > --- a/include/linux/mm.h
> > +++ b/include/linux/mm.h
> > @@ -1050,6 +1050,15 @@
> >  				   unsigned long addr, unsigned long len,
> >  				   unsigned long flags, struct page **pages);
> >
> > +struct mm_lock_data {
> > +	spinlock_t **i_mmap_locks;
> > +	spinlock_t **anon_vma_locks;
> > +	unsigned long nr_i_mmap_locks;
> > +	unsigned long nr_anon_vma_locks;
> > +};
> > +extern struct mm_lock_data *mm_lock(struct mm_struct * mm);
> > +extern void mm_unlock(struct mm_struct *mm, struct mm_lock_data *data);
> 
> As far as I can tell you don't actually need to expose this struct at all?

Yes, it should be possible to only expose 'struct mm_lock_data;'.

> > +		data->i_mmap_locks = vmalloc(nr_i_mmap_locks *
> > +					     sizeof(spinlock_t));
> 
> This is why non-typesafe allocators suck.  You want 'sizeof(spinlock_t *)' 
> here.
> 
> > +		data->anon_vma_locks = vmalloc(nr_anon_vma_locks *
> > +					       sizeof(spinlock_t));
> 
> and here.

Great catch! (it was temporarily wasting some ram which isn't nice at all)

> > +	err = -EINTR;
> > +	i_mmap_lock_last = NULL;
> > +	nr_i_mmap_locks = 0;
> > +	for (;;) {
> > +		spinlock_t *i_mmap_lock = (spinlock_t *) -1UL;
> > +		for (vma = mm->mmap; vma; vma = vma->vm_next) {
> ...
> > +		data->i_mmap_locks[nr_i_mmap_locks++] = i_mmap_lock;
> > +	}
> > +	data->nr_i_mmap_locks = nr_i_mmap_locks;
> 
> How about you track your running counter in data->nr_i_mmap_locks, leave 
> nr_i_mmap_locks alone, and BUG_ON(data->nr_i_mmap_locks != nr_i_mmap_locks)?
> 
> Even nicer would be to wrap this in a "get_sorted_mmap_locks()" function.

I'll try to clean this up further and I'll make a further update for review.

> Unfortunately, I just don't think we can fail locking like this.  In your next 
> patch unregistering a notifier can fail because of it: that not usable.

Fortunately I figured out we don't really need mm_lock in unregister
because it's ok to unregister in the middle of the range_begin/end
critical section (that's definitely not ok for register that's why
register needs mm_lock). And it's perfectly ok to fail in register().

Also it wasn't ok to unpin the module count in ->release as ->release
needs to 'ret' to get back to the mmu notifier code. And without any
unregister at all, the module can't be unloaded at all which
is quite unacceptable...

The logic is to prevent mmu_notifier_register to race with
mmu_notifier_release because it takes the mm_users pin (implicit or
explicit, and then mmput just after mmu_notifier_register
returns). Then _register serializes against all the mmu notifier
methods (except ->release) with srcu (->release can't run thanks to
the mm_users pin). The mmu_notifier_mm->lock then serializes the
modification on the list (register vs unregister) and it ensures one
and only one between _unregister and _releases calls ->release before
_unregister returns. All other methods runs freely with srcu. Having
the guarante that ->release is called just before all pages are freed
or inside _unregister, allows the module to zap and freeze its
secondary mmu inside ->release with the race condition of exit()
against mmu_notifier_unregister internally by the mmu notifier code
and without dependency on exit_files/exit_mm ordering depending if the
fd of the driver is open the filetables or in the vma only. The
mmu_notifier_mm can be reset to 0 only after the last mmdrop.

About the mm_count refcounting for _release and _unregiste: no mmu
notifier and not even mmu_notifier_unregister and _release can cope
with mmu_notfier_mm list and srcu structures going away out of
order. exit_mmap is safe as it holds an mm_count implicitly because
mmdrop is run after exit_mmap returns. mmu_notifier_unregister is safe
too as _register takes the mm_count pin. We can't prevent
mmu_notifer_mm to go away with mm_users as that will screwup the vma
filedescriptor closure that only happens inside exit_mmap (mm_users
pinned prevents exit_mmap to run, and it can only be taken temporarily
until _register returns).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
