From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 1 of 9] Lock the entire mm to prevent any mmu related operation to happen
Date: Tue, 22 Apr 2008 15:06:24 +1000
References: <ec6d8f91b299cf26cce5.1207669444@duo.random>
In-Reply-To: <ec6d8f91b299cf26cce5.1207669444@duo.random>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200804221506.26226.rusty@rustcorp.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Christoph Lameter <clameter@sgi.com>, akpm@linux-foundation.org, Nick Piggin <npiggin@suse.de>, Steve Wise <swise@opengridcomputing.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Jack Steiner <steiner@sgi.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Wednesday 09 April 2008 01:44:04 Andrea Arcangeli wrote:
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1050,6 +1050,15 @@
>  				   unsigned long addr, unsigned long len,
>  				   unsigned long flags, struct page **pages);
>
> +struct mm_lock_data {
> +	spinlock_t **i_mmap_locks;
> +	spinlock_t **anon_vma_locks;
> +	unsigned long nr_i_mmap_locks;
> +	unsigned long nr_anon_vma_locks;
> +};
> +extern struct mm_lock_data *mm_lock(struct mm_struct * mm);
> +extern void mm_unlock(struct mm_struct *mm, struct mm_lock_data *data);

As far as I can tell you don't actually need to expose this struct at all?

> +		data->i_mmap_locks = vmalloc(nr_i_mmap_locks *
> +					     sizeof(spinlock_t));

This is why non-typesafe allocators suck.  You want 'sizeof(spinlock_t *)' 
here.

> +		data->anon_vma_locks = vmalloc(nr_anon_vma_locks *
> +					       sizeof(spinlock_t));

and here.

> +	err = -EINTR;
> +	i_mmap_lock_last = NULL;
> +	nr_i_mmap_locks = 0;
> +	for (;;) {
> +		spinlock_t *i_mmap_lock = (spinlock_t *) -1UL;
> +		for (vma = mm->mmap; vma; vma = vma->vm_next) {
...
> +		data->i_mmap_locks[nr_i_mmap_locks++] = i_mmap_lock;
> +	}
> +	data->nr_i_mmap_locks = nr_i_mmap_locks;

How about you track your running counter in data->nr_i_mmap_locks, leave 
nr_i_mmap_locks alone, and BUG_ON(data->nr_i_mmap_locks != nr_i_mmap_locks)?

Even nicer would be to wrap this in a "get_sorted_mmap_locks()" function.

Similarly for anon_vma locks.

Unfortunately, I just don't think we can fail locking like this.  In your next 
patch unregistering a notifier can fail because of it: that not usable.

I think it means you need to add a linked list element to the vma for the 
CONFIG_MMU_NOTIFIER case.  Or track the max number of vmas for any mm, and 
keep a pool to handle mm_lock for this number (ie. if you can't enlarge the 
pool, fail the vma allocation).  

Both have their problems though...
Rusty.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
