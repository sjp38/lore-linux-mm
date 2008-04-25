Date: Fri, 25 Apr 2008 06:12:43 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: [PATCH] Minimal mmu notifiers for kvm
Message-ID: <20080425111243.GA17326@sgi.com>
References: <200804250813.00792.rusty@rustcorp.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200804250813.00792.rusty@rustcorp.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rusty Russell <rusty@rustcorp.com.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, Avi Kivity <avi@qumranet.com>, Christoph Lameter <clameter@sgi.com>, Andrea Arcangeli <andrea@qumranet.com>, Robin Holt <holt@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This patch would require GRU to maintain its own page tables and hold
reference counts on the pages.  That seems like a complete waste of
memory compared to Andrea's most recent patch.  The invalidate_range_start
and invalidate_range_end pair is needed to eliminate the page reference
counts.  The _start callout sets an internal structure in a state that
prevents GRU from satisfying faults, then executes the GRU instruction
to flush the TLB entry.  The _end callout releases the block on faults.

On Fri, Apr 25, 2008 at 08:13:00AM +1000, Rusty Russell wrote:
> +static DEFINE_SPINLOCK(notifier_lock);
> +
> +/*
> + * Must not hold mmap_sem nor any other VM related lock when calling
> + * this registration function.
> + */
> +int mm_add_notifier_ops(struct mm_struct *mm,
> +			const struct mmu_notifier_ops *mops)
> +{
> +	int err;
> +
> +	spin_lock(&notifier_lock);

This one global lock will get extremely hot when a 4096 MPI rank job
is starting up and every one of them goes to use the GRU at once.  I am
not sure where x86_64 peaks out, but on ia64 going beyond approx 32 cpus
contending for the same lock made starvation a very important issue.

> +	if (mm->mmu_notifier_ops)
> +		err = -EBUSY;

So we can only use one of KVM or GRU or Quadrix or IB or (later) XPMEM
per mm?

> +	else {
> +		mm->mmu_notifier_ops = mops;
> +		err = 0;
> +	}
> +	spin_unlock(&notifier_lock);
> +	return err;
> +}
> +EXPORT_SYMBOL_GPL(mm_add_notifier_ops);

Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
