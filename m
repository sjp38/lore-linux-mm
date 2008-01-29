Date: Tue, 29 Jan 2008 14:59:14 +0100
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [patch 1/6] mmu_notifier: Core code
Message-ID: <20080129135914.GF7233@v2.random>
References: <20080128202840.974253868@sgi.com> <20080128202923.609249585@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080128202923.609249585@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, Nick Piggin <npiggin@suse.de>, kvm-devel@lists.sourceforge.net, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Mon, Jan 28, 2008 at 12:28:41PM -0800, Christoph Lameter wrote:
> +struct mmu_notifier_head {
> +	struct hlist_head head;
> +};
> +
>  struct mm_struct {
>  	struct vm_area_struct * mmap;		/* list of VMAs */
>  	struct rb_root mm_rb;
> @@ -219,6 +223,8 @@ struct mm_struct {
>  	/* aio bits */
>  	rwlock_t		ioctx_list_lock;
>  	struct kioctx		*ioctx_list;
> +
> +	struct mmu_notifier_head mmu_notifier; /* MMU notifier list */
>  };

Not sure why you prefer to waste ram when MMU_NOTIFIER=n, this is a
regression (a minor one though).

> +	/*
> +	 * lock indicates that the function is called under spinlock.
> +	 */
> +	void (*invalidate_range)(struct mmu_notifier *mn,
> +				 struct mm_struct *mm,
> +				 unsigned long start, unsigned long end,
> +				 int lock);
> +};

It's out of my reach how can you be ok with lock=1. You said you have
to block, if you can deal with lock=1 once, why can't you deal with
lock=1 _always_?

> +/*
> + * Note that all notifiers use RCU. The updates are only guaranteed to be
> + * visible to other processes after a RCU quiescent period!
> + */
> +void __mmu_notifier_register(struct mmu_notifier *mn, struct mm_struct *mm)
> +{
> +	hlist_add_head_rcu(&mn->hlist, &mm->mmu_notifier.head);
> +}
> +EXPORT_SYMBOL_GPL(__mmu_notifier_register);
> +
> +void mmu_notifier_register(struct mmu_notifier *mn, struct mm_struct *mm)
> +{
> +	down_write(&mm->mmap_sem);
> +	__mmu_notifier_register(mn, mm);
> +	up_write(&mm->mmap_sem);
> +}
> +EXPORT_SYMBOL_GPL(mmu_notifier_register);

The down_write is garbage. The caller should put it around
mmu_notifier_register if something. The same way the caller should
call synchronize_rcu after mmu_notifier_register if it needs
synchronous behavior from the notifiers. The default version of
mmu_notifier_register shouldn't be cluttered with unnecessary locking.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
