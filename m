Date: Tue, 3 Jun 2008 09:26:05 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 001/001] mmu-notifier-core v17
In-Reply-To: <20080509193230.GH7710@duo.random>
Message-ID: <alpine.LFD.1.10.0806030909030.3473@woody.linux-foundation.org>
References: <20080509193230.GH7710@duo.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, Robin Holt <holt@sgi.com>, Nick Piggin <npiggin@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm-devel@lists.sourceforge.net, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Steve Wise <swise@opengridcomputing.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, linux-mm@kvack.org, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>, Rusty Russell <rusty@rustcorp.com.au>, Anthony Liguori <aliguori@us.ibm.com>, Chris Wright <chrisw@redhat.com>, Marcelo Tosatti <marcelo@kvack.org>, Eric Dumazet <dada1@cosmosbay.com>, "Paul E. McKenney" <paulmck@us.ibm.com>
List-ID: <linux-mm.kvack.org>


On Fri, 9 May 2008, Andrea Arcangeli wrote:
> 
> At least for KVM without this patch it's impossible to swap guests
> reliably. And having this feature and removing the page pin allows
> several other optimizations that simplify life considerably.

Ok, this looks ok as far as I'm concerned. I did not look at any details, 
so obviously other VM people need to ack the parts they care about, but at 
least I think this one is fine from a "big picture".

I do have some small nits that are just about trivial stuff.

> 1) Introduces list_del_init_rcu and documents it (fixes a comment for
>    list_del_rcu too)

I think this should go in separately, and be split up into a patch of its 
own, just because it's really an independent area. So make it [1/3].

> 2) mm_take_all_locks() to register the mmu notifier when the whole VM
>    isn't doing anything with "mm". This allows mmu notifier users to
>    keep track if the VM is in the middle of the
>    invalidate_range_begin/end critical section with an atomic counter
>    incraese in range_begin and decreased in range_end.

Similarly, even without any users, I think this can be posted as an 
independent patch, just for setting things up, and to make the whole thing 
easier to look through and review. So make this [2/3].

But before doing that, can you split up the low-level single-vma anon/file 
locking/unlocking, please?

In other words, your 'mm_take_all_locks()' rigth now looks like it _works_ 
correctly, but it nests too deeply considering the complexity of it. 
There's really subtle things going on inside that for-loop, and I think it 
would be much better to split those low-level locking rules out.

IOW, instead of:

> +int mm_take_all_locks(struct mm_struct *mm)
> +{
> +	struct vm_area_struct *vma;
> +	int ret = -EINTR;
> +
> +	BUG_ON(down_read_trylock(&mm->mmap_sem));
> +
> +	mutex_lock(&mm_all_locks_mutex);
> +
> +	for (vma = mm->mmap; vma; vma = vma->vm_next) {
> +		struct file *filp;
> +		if (signal_pending(current))
> +			goto out_unlock;
> +		if (vma->anon_vma && !test_bit(0, (unsigned long *)
> +					       &vma->anon_vma->head.next)) {
> +			/*
> +			 * The LSB of head.next can't change from
> +			 * under us because we hold the
> +			 * global_mm_spinlock.
> +			 */
> +			spin_lock(&vma->anon_vma->lock);
...

ie, can you please make it be

	for (vma = mm->mmap; vma; vma = vma->vm_next) {
		if (signal_pending(current))
			goto out_unlock;
		if (vma->anon_vma)
			vm_lock_anon_vma(vma->anon_vma);
		if (vma->vm_file && vma->vm_file->f_mapping)
			vm_lock_mapping(vma->vm_file->f_mapping);
	}

and the same thing for unlocking.. Doesn't that look more obvious and 
easier to understand from a high-level standpoing (and then the individual 
locking rules for mappings/anon_vma's will also be more obvious, just 
because they are separated from the higher-level code).

The comments are fine, but even with the comments I'd prefer you to write 
the code so that you don't need to break up the conditionals over multiple 
lines etc.

Anyway - I didn't look very much at the actual _notifier_ stuff (ie the 
thing that I think should be [patch 3/3]), so I don't have any real 
comments about that part - but I don't really care either. Becasue as long 
as it doesn't mess up the core VM logic, I no longer have any real 
objections.

I'd obviously want to see ack's by people like Andrew, Hugh and Nick, but 
as far as I am concerned, if you just do the trivial cleanup/split, you 
can add an "Acked-by: Linus Torvalds <torvalds@linux-foundation.org>" to 
at least the two first patches of the split-up series.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
