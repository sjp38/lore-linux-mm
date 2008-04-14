Date: Mon, 14 Apr 2008 12:57:00 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 2 of 9] Core of mmu notifiers
In-Reply-To: <baceb322b45ed4328065.1207669445@duo.random>
Message-ID: <Pine.LNX.4.64.0804141250590.7803@schroedinger.engr.sgi.com>
References: <baceb322b45ed4328065.1207669445@duo.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: akpm@linux-foundation.org, Nick Piggin <npiggin@suse.de>, Steve Wise <swise@opengridcomputing.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Jack Steiner <steiner@sgi.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Tue, 8 Apr 2008, Andrea Arcangeli wrote:

> +	/*
> +	 * Called when nobody can register any more notifier in the mm
> +	 * and after the "mn" notifier has been disarmed already.
> +	 */
> +	void (*release)(struct mmu_notifier *mn,
> +			struct mm_struct *mm);

Hmmm... The unregister function does not call this. Guess driver calls
unregister function and does release like stuff on its own.

> +	/*
> +	 * invalidate_range_start() and invalidate_range_end() must be
> +	 * paired. Multiple invalidate_range_start/ends may be nested
> +	 * or called concurrently.
> +	 */

How could they be nested or called concurrently?


> +/*
> + * mm_users can't go down to zero while mmu_notifier_unregister()
> + * runs or it can race with ->release. So a mm_users pin must
> + * be taken by the caller (if mm can be different from current->mm).
> + */
> +int mmu_notifier_unregister(struct mmu_notifier *mn, struct mm_struct *mm)
> +{
> +	struct mm_lock_data *data;
> +
> +	BUG_ON(!atomic_read(&mm->mm_users));
> +
> +	data = mm_lock(mm);
> +	if (unlikely(IS_ERR(data)))
> +		return PTR_ERR(data);
> +	hlist_del(&mn->hlist);
> +	mm_unlock(mm, data);
> +	return 0;

Hmmm.. Ok, the user of the notifier does not get notified that it was 
unregistered.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
