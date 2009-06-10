Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 83C636B0082
	for <linux-mm@kvack.org>; Wed, 10 Jun 2009 04:37:10 -0400 (EDT)
Date: Wed, 10 Jun 2009 16:38:03 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] [13/16] HWPOISON: The high level memory error handler
	in the VM v5
Message-ID: <20090610083803.GE6597@localhost>
References: <20090603846.816684333@firstfloor.org> <20090603184648.2E2131D028F@basil.firstfloor.org> <20090609100922.GF14820@wotan.suse.de> <Pine.LNX.4.64.0906091637430.13213@sister.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0906091637430.13213@sister.anvils>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Nick Piggin <npiggin@suse.de>, Andi Kleen <andi@firstfloor.org>, "riel@redhat.com" <riel@redhat.com>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Jun 10, 2009 at 12:05:53AM +0800, Hugh Dickins wrote:
> On Tue, 9 Jun 2009, Nick Piggin wrote:
> > On Wed, Jun 03, 2009 at 08:46:47PM +0200, Andi Kleen wrote:
> > 
> > Why not have this in rmap.c and not export the locking?
> > I don't know.. does Hugh care?
> 
> Thanks for catching my eye with this, Nick.
> 
> As I've said to Andi, I don't actually have time to study all this.
> To me, it's just another layer of complexity and maintenance burden
> that one special-interest group is imposing upon mm, and I can't
> keep up with it myself.
> 
> But looking at this one set of extracts: you're right that I'm much
> happier when page_lock_anon_vma() isn't leaked outside of mm/rmap.c,
> though I'd probably hate this whichever way round it was; and I
> share your lock ordering concern.

The lock ordering is now fixed :)

> However, if I'm interpreting these extracts correctly, the whole
> thing looks very misguided to me.  Are we really going to kill any
> process that has a cousin who might once have mapped the page that's
> been found hwpoisonous?  The hwpoison secret police are dangerously
> out of control, I'd say.

Good catch! It escaped our previous reviews.

I can add the missing page_mapped_in_vma() calls as well as move the
functions to rmap.c.

> The usual use of rmap lookup loops is to go on to look into the page
> table to see whether the page is actually mapped: I see no attempt
> at that here, just an assumption that anyone on the list is guilty
> of mapping the page and must be killed.  And even if it did go on

Right, processes that didn't map the page shall not be killed (at
least by default).

I don't know if the hardware can guarantee to detect a corrupted page 
when a process is accessing it (or a device is accessing it via DMA).

If not, then there are a lot more possibilities:

It's possible that a process mapped a corrupted page, consumed the
data, and then the page get unmapped by kswapd, in the process the
hardware didn't know that it's actually a corrupted page.  Some time
later the hardware found that and triggered an exception.  In this
case, for max safety, we may kill the app whose vma covers the
corrupted file page but does not actually map it. Though that is not
a suitable default policy.

We may also have to define multiple level of kill policies.

- kill affected application as early as possible?
- kill all mmap() users or only active ones?
- kill clean page users or only dirty page users?

We'd better check out the hardware capabilities first..

> to check if the page is there, maybe the process lost interest in
> that page several weeks ago, why kill it?

Yes, maybe.

> At least in the file's prio_tree case, we'll only be killing those
> who mmapped the range which happens to include the page.  But in the
> anon case, remember the anon_vma is just a bundle of "related" vmas
> outside of which the page will not be found; so if one process got a
> poisonous page through COW, all the other processes which happen to
> be sharing that anon_vma through fork or through adjacent merging,
> are going to get killed too.
>
> Guilty by association.

Agreed.

> I think a much more sensible approach would be to follow the page
> migration technique of replacing the page's ptes by a special swap-like
> entry, then do the killing from do_swap_page() if a process actually
> tries to access the page.

We call that "late kill" and will be enabled when
sysctl_memory_failure_early_kill=0. Its default value is 1.

> But perhaps that has already been discussed and found impossible,
> or I'm taking "kill" too seriously and other checks are done
> elsewhere, or...

You are right. We should implement different kill policies and let the
user decide the one good for him.

Thanks,
Fengguang

> > 
> > > +/*
> > > + * Collect processes when the error hit an anonymous page.
> > > + */
> > > +static void collect_procs_anon(struct page *page, struct list_head *to_kill,
> > > +			      struct to_kill **tkc)
> > > +{
> > > +	struct vm_area_struct *vma;
> > > +	struct task_struct *tsk;
> > > +	struct anon_vma *av = page_lock_anon_vma(page);
> > > +
> > > +	if (av == NULL)	/* Not actually mapped anymore */
> > > +		return;
> > > +
> > > +	read_lock(&tasklist_lock);
> > > +	for_each_process (tsk) {
> > > +		if (!tsk->mm)
> > > +			continue;
> > > +		list_for_each_entry (vma, &av->head, anon_vma_node) {
> > > +			if (vma->vm_mm == tsk->mm)
> > > +				add_to_kill(tsk, page, vma, to_kill, tkc);
> > > +		}
> > > +	}
> > > +	page_unlock_anon_vma(av);
> > > +	read_unlock(&tasklist_lock);
> > > +}
> > > +
> > > +/*
> > > + * Collect processes when the error hit a file mapped page.
> > > + */
> > > +static void collect_procs_file(struct page *page, struct list_head *to_kill,
> > > +			      struct to_kill **tkc)
> > > +{
> > > +	struct vm_area_struct *vma;
> > > +	struct task_struct *tsk;
> > > +	struct prio_tree_iter iter;
> > > +	struct address_space *mapping = page_mapping(page);
> > > +
> > > +	/*
> > > +	 * A note on the locking order between the two locks.
> > > +	 * We don't rely on this particular order.
> > > +	 * If you have some other code that needs a different order
> > > +	 * feel free to switch them around. Or add a reverse link
> > > +	 * from mm_struct to task_struct, then this could be all
> > > +	 * done without taking tasklist_lock and looping over all tasks.
> > > +	 */
> > > +
> > > +	read_lock(&tasklist_lock);
> > > +	spin_lock(&mapping->i_mmap_lock);
> > 
> > This still has my original complaint that it nests tasklist lock inside
> > anon vma lock and outside inode mmap lock (and anon_vma nests inside i_mmap).
> > I guess the property of our current rw locks means that does not matter,
> > but it could if we had "fair" rw locks, or some tree (-rt tree maybe)
> > changed rw lock to a plain exclusive lock.
> > 
> > 
> > > +	for_each_process(tsk) {
> > > +		pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
> > > +
> > > +		if (!tsk->mm)
> > > +			continue;
> > > +
> > > +		vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff,
> > > +				      pgoff)
> > > +			if (vma->vm_mm == tsk->mm)
> > > +				add_to_kill(tsk, page, vma, to_kill, tkc);
> > > +	}
> > > +	spin_unlock(&mapping->i_mmap_lock);
> > > +	read_unlock(&tasklist_lock);
> > > +}
> > > +
> > > +/*
> > > + * Collect the processes who have the corrupted page mapped to kill.
> > > + * This is done in two steps for locking reasons.
> > > + * First preallocate one tokill structure outside the spin locks,
> > > + * so that we can kill at least one process reasonably reliable.
> > > + */
> > > +static void collect_procs(struct page *page, struct list_head *tokill)
> > > +{
> > > +	struct to_kill *tk;
> > > +
> > > +	tk = kmalloc(sizeof(struct to_kill), GFP_KERNEL);
> > > +	/* memory allocation failure is implicitly handled */
> > > +	if (PageAnon(page))
> > > +		collect_procs_anon(page, tokill, &tk);
> > > +	else
> > > +		collect_procs_file(page, tokill, &tk);
> > > +	kfree(tk);
> > > +}
> > 
> > > Index: linux/mm/filemap.c
> > > ===================================================================
> > > --- linux.orig/mm/filemap.c	2009-06-03 19:37:38.000000000 +0200
> > > +++ linux/mm/filemap.c	2009-06-03 20:13:43.000000000 +0200
> > > @@ -105,6 +105,10 @@
> > >   *
> > >   *  ->task->proc_lock
> > >   *    ->dcache_lock		(proc_pid_lookup)
> > > + *
> > > + *  (code doesn't rely on that order, so you could switch it around)
> > > + *  ->tasklist_lock             (memory_failure, collect_procs_ao)
> > > + *    ->i_mmap_lock
> > >   */
> > >  
> > >  /*
> > > Index: linux/mm/rmap.c
> > > ===================================================================
> > > --- linux.orig/mm/rmap.c	2009-06-03 19:37:38.000000000 +0200
> > > +++ linux/mm/rmap.c	2009-06-03 20:13:43.000000000 +0200
> > > @@ -36,6 +36,10 @@
> > >   *                 mapping->tree_lock (widely used, in set_page_dirty,
> > >   *                           in arch-dependent flush_dcache_mmap_lock,
> > >   *                           within inode_lock in __sync_single_inode)
> > > + *
> > > + * (code doesn't rely on that order so it could be switched around)
> > > + * ->tasklist_lock
> > > + *   anon_vma->lock      (memory_failure, collect_procs_anon)
> > >   */
> > >  
> > >  #include <linux/mm.h>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
