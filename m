Date: Sat, 26 Jan 2008 06:01:50 -0600
From: Robin Holt <holt@sgi.com>
Subject: Re: [patch 1/4] mmu_notifier: Core code
Message-ID: <20080126120149.GS3058@sgi.com>
References: <20080125055606.102986685@sgi.com> <20080125055801.212744875@sgi.com> <20080125183934.GO26420@sgi.com> <Pine.LNX.4.64.0801251041040.672@schroedinger.engr.sgi.com> <20080125185646.GQ3058@sgi.com> <Pine.LNX.4.64.0801251058170.3198@schroedinger.engr.sgi.com> <20080125193554.GP26420@sgi.com> <Pine.LNX.4.64.0801251315350.19523@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0801251315350.19523@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Robin Holt <holt@sgi.com>, Andrea Arcangeli <andrea@qumranet.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, Nick Piggin <npiggin@suse.de>, kvm-devel@lists.sourceforge.net, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

>  void mmu_notifier_register(struct mmu_notifier *mn, struct mm_struct *mm)
>  {
> -	spin_lock(&mmu_notifier_list_lock);
> -	hlist_add_head(&mn->hlist, &mm->mmu_notifier.head);
> -	spin_unlock(&mmu_notifier_list_lock);
> +	down_write(&mm->mmap_sem);
> +	__mmu_notifier_register(mn, mm);
> +	up_write(&mm->mmap_sem);
>  }
>  EXPORT_SYMBOL_GPL(mmu_notifier_register);

But what if the caller is already holding the mmap_sem?  Why force the
acquire into this function?  Since we are dealing with a semaphore/mutex,
it is reasonable that other structures are protected by this, more work
will be done, and therefore put the weight of acquiring the sema in the
control of the caller where they can decide if more needs to be completed.

That was why I originally suggested creating a new rwsem_is_write_locked()
function and basing a BUG_ON upon that.

Thanks,
Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
