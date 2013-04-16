Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 0D31A6B0002
	for <linux-mm@kvack.org>; Tue, 16 Apr 2013 05:31:32 -0400 (EDT)
Date: Tue, 16 Apr 2013 04:31:31 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: [PATCH] mm: mmu_notifier: re-fix freed page still mapped in
 secondary MMU
Message-ID: <20130416093131.GJ3658@sgi.com>
References: <516CF235.4060103@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <516CF235.4060103@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Marcelo Tosatti <mtosatti@redhat.com>, Gleb Natapov <gleb@redhat.com>, Avi Kivity <avi.kivity@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Robin Holt <holt@sgi.com>, LKML <linux-kernel@vger.kernel.org>, KVM <kvm@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On Tue, Apr 16, 2013 at 02:39:49PM +0800, Xiao Guangrong wrote:
> The commit 751efd8610d3 (mmu_notifier_unregister NULL Pointer deref
> and multiple ->release()) breaks the fix:
>     3ad3d901bbcfb15a5e4690e55350db0899095a68
>     (mm: mmu_notifier: fix freed page still mapped in secondary MMU)

Can you describe how the page is still mapped?  I thought I had all
cases covered.  Whichever call hits first, I thought we had one callout
to the registered notifiers.  Are you saying we need multiple callouts?

Also, shouldn't you be asking for a revert commit and then supply a
subsequent commit for the real fix?  I thought that was the process for
doing a revert.

Thanks,
Robin Holt

> 
> This patch reverts the commit and simply fix the bug spotted
> by that patch
> 
> This bug is spotted by commit 751efd8610d3:
> ======
> There is a race condition between mmu_notifier_unregister() and
> __mmu_notifier_release().
> 
> Assume two tasks, one calling mmu_notifier_unregister() as a result of a
> filp_close() ->flush() callout (task A), and the other calling
> mmu_notifier_release() from an mmput() (task B).
> 
>                     A                               B
> t1                                              srcu_read_lock()
> t2              if (!hlist_unhashed())
> t3                                              srcu_read_unlock()
> t4              srcu_read_lock()
> t5                                              hlist_del_init_rcu()
> t6                                              synchronize_srcu()
> t7              srcu_read_unlock()
> t8              hlist_del_rcu()  <--- NULL pointer deref.
> ======
> 
> This can be fixed by using hlist_del_init_rcu instead of hlist_del_rcu.
> 
> The another issue spotted in the commit is
> "multiple ->release() callouts", we needn't care it too much because
> it is really rare (e.g, can not happen on kvm since mmu-notify is unregistered
> after exit_mmap()) and the later call of multiple ->release should be
> fast since all the pages have already been released by the first call.
> 
> Signed-off-by: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
> ---
>  mm/mmu_notifier.c |   81 +++++++++++++++++++++++++++--------------------------
>  1 files changed, 41 insertions(+), 40 deletions(-)
> 
> diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
> index be04122..606777a 100644
> --- a/mm/mmu_notifier.c
> +++ b/mm/mmu_notifier.c
> @@ -40,48 +40,45 @@ void __mmu_notifier_release(struct mm_struct *mm)
>  	int id;
> 
>  	/*
> -	 * srcu_read_lock() here will block synchronize_srcu() in
> -	 * mmu_notifier_unregister() until all registered
> -	 * ->release() callouts this function makes have
> -	 * returned.
> +	 * SRCU here will block mmu_notifier_unregister until
> +	 * ->release returns.
>  	 */
>  	id = srcu_read_lock(&srcu);
> +	hlist_for_each_entry_rcu(mn, &mm->mmu_notifier_mm->list, hlist)
> +		/*
> +		 * if ->release runs before mmu_notifier_unregister it
> +		 * must be handled as it's the only way for the driver
> +		 * to flush all existing sptes and stop the driver
> +		 * from establishing any more sptes before all the
> +		 * pages in the mm are freed.
> +		 */
> +		if (mn->ops->release)
> +			mn->ops->release(mn, mm);
> +	srcu_read_unlock(&srcu, id);
> +
>  	spin_lock(&mm->mmu_notifier_mm->lock);
>  	while (unlikely(!hlist_empty(&mm->mmu_notifier_mm->list))) {
>  		mn = hlist_entry(mm->mmu_notifier_mm->list.first,
>  				 struct mmu_notifier,
>  				 hlist);
> -
>  		/*
> -		 * Unlink.  This will prevent mmu_notifier_unregister()
> -		 * from also making the ->release() callout.
> +		 * We arrived before mmu_notifier_unregister so
> +		 * mmu_notifier_unregister will do nothing other than
> +		 * to wait ->release to finish and
> +		 * mmu_notifier_unregister to return.
>  		 */
>  		hlist_del_init_rcu(&mn->hlist);
> -		spin_unlock(&mm->mmu_notifier_mm->lock);
> -
> -		/*
> -		 * Clear sptes. (see 'release' description in mmu_notifier.h)
> -		 */
> -		if (mn->ops->release)
> -			mn->ops->release(mn, mm);
> -
> -		spin_lock(&mm->mmu_notifier_mm->lock);
>  	}
>  	spin_unlock(&mm->mmu_notifier_mm->lock);
> 
>  	/*
> -	 * All callouts to ->release() which we have done are complete.
> -	 * Allow synchronize_srcu() in mmu_notifier_unregister() to complete
> -	 */
> -	srcu_read_unlock(&srcu, id);
> -
> -	/*
> -	 * mmu_notifier_unregister() may have unlinked a notifier and may
> -	 * still be calling out to it.	Additionally, other notifiers
> -	 * may have been active via vmtruncate() et. al. Block here
> -	 * to ensure that all notifier callouts for this mm have been
> -	 * completed and the sptes are really cleaned up before returning
> -	 * to exit_mmap().
> +	 * synchronize_srcu here prevents mmu_notifier_release to
> +	 * return to exit_mmap (which would proceed freeing all pages
> +	 * in the mm) until the ->release method returns, if it was
> +	 * invoked by mmu_notifier_unregister.
> +	 *
> +	 * The mmu_notifier_mm can't go away from under us because one
> +	 * mm_count is hold by exit_mmap.
>  	 */
>  	synchronize_srcu(&srcu);
>  }
> @@ -292,31 +289,35 @@ void mmu_notifier_unregister(struct mmu_notifier *mn, struct mm_struct *mm)
>  {
>  	BUG_ON(atomic_read(&mm->mm_count) <= 0);
> 
> -	spin_lock(&mm->mmu_notifier_mm->lock);
>  	if (!hlist_unhashed(&mn->hlist)) {
> +		/*
> +		 * SRCU here will force exit_mmap to wait ->release to finish
> +		 * before freeing the pages.
> +		 */
>  		int id;
> 
> +		id = srcu_read_lock(&srcu);
>  		/*
> -		 * Ensure we synchronize up with __mmu_notifier_release().
> +		 * exit_mmap will block in mmu_notifier_release to
> +		 * guarantee ->release is called before freeing the
> +		 * pages.
>  		 */
> -		id = srcu_read_lock(&srcu);
> -
> -		hlist_del_rcu(&mn->hlist);
> -		spin_unlock(&mm->mmu_notifier_mm->lock);
> -
>  		if (mn->ops->release)
>  			mn->ops->release(mn, mm);
> +		srcu_read_unlock(&srcu, id);
> 
> +		spin_lock(&mm->mmu_notifier_mm->lock);
>  		/*
> -		 * Allow __mmu_notifier_release() to complete.
> +		 * Can not use list_del_rcu() since __mmu_notifier_release
> +		 * can delete it before we hold the lock.
>  		 */
> -		srcu_read_unlock(&srcu, id);
> -	} else
> +		hlist_del_init_rcu(&mn->hlist);
>  		spin_unlock(&mm->mmu_notifier_mm->lock);
> +	}
> 
>  	/*
> -	 * Wait for any running method to finish, including ->release() if it
> -	 * was run by __mmu_notifier_release() instead of us.
> +	 * Wait any running method to finish, of course including
> +	 * ->release if it was run by mmu_notifier_relase instead of us.
>  	 */
>  	synchronize_srcu(&srcu);
> 
> -- 
> 1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
