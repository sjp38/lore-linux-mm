Date: Fri, 15 Feb 2008 19:37:46 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 5/6] mmu_notifier: Support for drivers with revers maps
 (f.e. for XPmem)
Message-Id: <20080215193746.5d823092.akpm@linux-foundation.org>
In-Reply-To: <20080215064933.376635032@sgi.com>
References: <20080215064859.384203497@sgi.com>
	<20080215064933.376635032@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrea Arcangeli <andrea@qumranet.com>, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Thu, 14 Feb 2008 22:49:04 -0800 Christoph Lameter <clameter@sgi.com> wrote:

> These special additional callbacks are required because XPmem (and likely
> other mechanisms) do use their own rmap (multiple processes on a series
> of remote Linux instances may be accessing the memory of a process).
> F.e. XPmem may have to send out notifications to remote Linux instances
> and receive confirmation before a page can be freed.
> 
> So we handle this like an additional Linux reverse map that is walked after
> the existing rmaps have been walked. We leave the walking to the driver that
> is then able to use something else than a spinlock to walk its reverse
> maps. So we can actually call the driver without holding spinlocks while
> we hold the Pagelock.
> 
> However, we cannot determine the mm_struct that a page belongs to at
> that point. The mm_struct can only be determined from the rmaps by the
> device driver.
> 
> We add another pageflag (PageExternalRmap) that is set if a page has
> been remotely mapped (f.e. by a process from another Linux instance).
> We can then only perform the callbacks for pages that are actually in
> remote use.
> 
> Rmap notifiers need an extra page bit and are only available
> on 64 bit platforms. This functionality is not available on 32 bit!
> 
> A notifier that uses the reverse maps callbacks does not need to provide
> the invalidate_page() method that is called when locks are held.
> 

hrm.

> +#define mmu_rmap_notifier(function, args...)				\
> +	do {								\
> +		struct mmu_rmap_notifier *__mrn;			\
> +		struct hlist_node *__n;					\
> +									\
> +		rcu_read_lock();					\
> +		hlist_for_each_entry_rcu(__mrn, __n,			\
> +				&mmu_rmap_notifier_list, hlist)		\
> +			if (__mrn->ops->function)			\
> +				__mrn->ops->function(__mrn, args);	\
> +		rcu_read_unlock();					\
> +	} while (0);
> +

buggy macro: use locals.

> +#define mmu_rmap_notifier(function, args...)				\
> +	do {								\
> +		if (0) {						\
> +			struct mmu_rmap_notifier *__mrn;		\
> +									\
> +			__mrn = (struct mmu_rmap_notifier *)(0x00ff);	\
> +			__mrn->ops->function(__mrn, args);		\
> +		}							\
> +	} while (0);
> +

Same observation as in the other patch.

> ===================================================================
> --- linux-2.6.orig/mm/mmu_notifier.c	2008-02-14 21:17:51.000000000 -0800
> +++ linux-2.6/mm/mmu_notifier.c	2008-02-14 21:21:04.000000000 -0800
> @@ -74,3 +74,37 @@ void mmu_notifier_unregister(struct mmu_
>  }
>  EXPORT_SYMBOL_GPL(mmu_notifier_unregister);
>  
> +#ifdef CONFIG_64BIT
> +static DEFINE_SPINLOCK(mmu_notifier_list_lock);
> +HLIST_HEAD(mmu_rmap_notifier_list);
> +
> +void mmu_rmap_notifier_register(struct mmu_rmap_notifier *mrn)
> +{
> +	spin_lock(&mmu_notifier_list_lock);
> +	hlist_add_head_rcu(&mrn->hlist, &mmu_rmap_notifier_list);
> +	spin_unlock(&mmu_notifier_list_lock);
> +}
> +EXPORT_SYMBOL(mmu_rmap_notifier_register);
> +
> +void mmu_rmap_notifier_unregister(struct mmu_rmap_notifier *mrn)
> +{
> +	spin_lock(&mmu_notifier_list_lock);
> +	hlist_del_rcu(&mrn->hlist);
> +	spin_unlock(&mmu_notifier_list_lock);
> +}
> +EXPORT_SYMBOL(mmu_rmap_notifier_unregister);
>
> +/*
> + * Export a page.
> + *
> + * Pagelock must be held.
> + * Must be called before a page is put on an external rmap.
> + */
> +void mmu_rmap_export_page(struct page *page)
> +{
> +	BUG_ON(!PageLocked(page));
> +	SetPageExternalRmap(page);
> +}
> +EXPORT_SYMBOL(mmu_rmap_export_page);

The other patch used EXPORT_SYMBOL_GPL.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
