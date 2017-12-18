Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3B73F6B0033
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 18:09:45 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id n31so13548126qtc.2
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 15:09:45 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id z11si16243qta.149.2017.12.18.15.09.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Dec 2017 15:09:43 -0800 (PST)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id vBIN9Mvf096854
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 18:09:43 -0500
Received: from e13.ny.us.ibm.com (e13.ny.us.ibm.com [129.33.205.203])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2exjf8jhph-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 18:09:43 -0500
Received: from localhost
	by e13.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Mon, 18 Dec 2017 18:09:42 -0500
Date: Mon, 18 Dec 2017 15:09:45 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH -V3 -mm] mm, swap: Fix race between swapoff and some swap
 operations
Reply-To: paulmck@linux.vnet.ibm.com
References: <20171218073424.29647-1-ying.huang@intel.com>
 <877etkwki2.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <877etkwki2.fsf@yhuang-dev.intel.com>
Message-Id: <20171218230945.GX7829@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Tim Chen <tim.c.chen@linux.intel.com>, Shaohua Li <shli@fb.com>, Mel Gorman <mgorman@techsingularity.net>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Michal Hocko <mhocko@suse.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Dave Jiang <dave.jiang@intel.com>, Aaron Lu <aaron.lu@intel.com>

On Mon, Dec 18, 2017 at 03:41:41PM +0800, Huang, Ying wrote:
> "Huang, Ying" <ying.huang@intel.com> writes:
> 
> > From: Huang Ying <ying.huang@intel.com>
> >
> > When the swapin is performed, after getting the swap entry information
> > from the page table, system will swap in the swap entry, without any
> > lock held to prevent the swap device from being swapoff.  This may
> > cause the race like below,
> >
> > CPU 1				CPU 2
> > -----				-----
> > 				do_swap_page
> > 				  swapin_readahead
> > 				    __read_swap_cache_async
> > swapoff				      swapcache_prepare
> >   p->swap_map = NULL		        __swap_duplicate
> > 					  p->swap_map[?] /* !!! NULL pointer access */
> >
> > Because swapoff is usually done when system shutdown only, the race
> > may not hit many people in practice.  But it is still a race need to
> > be fixed.
> >
> > To fix the race, get_swap_device() is added to check whether the
> > specified swap entry is valid in its swap device.  If so, it will keep
> > the swap entry valid via preventing the swap device from being
> > swapoff, until put_swap_device() is called.
> >
> > Because swapoff() is very race code path, to make the normal path runs
> > as fast as possible, RCU instead of reference count is used to
> > implement get/put_swap_device().  From get_swap_device() to
> > put_swap_device(), the RCU read lock is held, so synchronize_rcu() in
> > swapoff() will wait until put_swap_device() is called.
> >
> > In addition to swap_map, cluster_info, etc. data structure in the
> > struct swap_info_struct, the swap cache radix tree will be freed after
> > swapoff, so this patch fixes the race between swap cache looking up
> > and swapoff too.
> >
> > Cc: Hugh Dickins <hughd@google.com>
> > Cc: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> > Cc: Minchan Kim <minchan@kernel.org>
> > Cc: Johannes Weiner <hannes@cmpxchg.org>
> > Cc: Tim Chen <tim.c.chen@linux.intel.com>
> > Cc: Shaohua Li <shli@fb.com>
> > Cc: Mel Gorman <mgorman@techsingularity.net>
> > Cc: "Jerome Glisse" <jglisse@redhat.com>
> > Cc: Michal Hocko <mhocko@suse.com>
> > Cc: Andrea Arcangeli <aarcange@redhat.com>
> > Cc: David Rientjes <rientjes@google.com>
> > Cc: Rik van Riel <riel@redhat.com>
> > Cc: Jan Kara <jack@suse.cz>
> > Cc: Dave Jiang <dave.jiang@intel.com>
> > Cc: Aaron Lu <aaron.lu@intel.com>
> > Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
> >
> > Changelog:
> >
> > v3:
> >
> > - Re-implemented with RCU to reduce the overhead of normal paths
> >
> > v2:
> >
> > - Re-implemented with SRCU to reduce the overhead of normal paths.
> >
> > - Avoid to check whether the swap device has been swapoff in
> >   get_swap_device().  Because we can check the origin of the swap
> >   entry to make sure the swap device hasn't bee swapoff.
> 
> A version implemented via stop_machine() could be gotten via a small
> patch as below.  If you still prefer stop_machine(), I can resend a
> version implemented with stop_machine().
> 
> And, it appears that if we replace smp_wmb() in _enable_swap_info() with
> stop_machine() in some way, we can avoid smp_rmb() in get_swap_device().
> This can reduce overhead in normal path further.  Can we get same effect
> with RCU?  For example, use synchronize_rcu() instead of stop_machine()?
> 
> Hi, Paul, can you help me on this?

If the key loads before and after the smp_rmb() are within the same
RCU read-side critical section, -and- if one of the critical writes is
before the synchronize_rcu() and the other critical write is after the
synchronize_rcu(), then you normally don't need the smp_rmb().

Otherwise, you likely do still need the smp_rmb().

							Thanx, Paul

> Best Regards,
> Huang, Ying
> 
> ----------------8<------------------------------
> ---
>  include/linux/swap.h |  2 +-
>  mm/swapfile.c        | 12 +++++++++---
>  2 files changed, 10 insertions(+), 4 deletions(-)
> 
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index f7e8f26cf07f..1027169d5a04 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -475,7 +475,7 @@ extern struct swap_info_struct *get_swap_device(swp_entry_t entry);
> 
>  static inline void put_swap_device(struct swap_info_struct *si)
>  {
> -	rcu_read_unlock();
> +	preempt_enable();
>  }
> 
>  #else /* CONFIG_SWAP */
> diff --git a/mm/swapfile.c b/mm/swapfile.c
> index ca7b4c5ebe34..feb13ce01045 100644
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -38,6 +38,7 @@
>  #include <linux/export.h>
>  #include <linux/swap_slots.h>
>  #include <linux/sort.h>
> +#include <linux/stop_machine.h>
> 
>  #include <asm/pgtable.h>
>  #include <asm/tlbflush.h>
> @@ -1125,7 +1126,7 @@ struct swap_info_struct *get_swap_device(swp_entry_t entry)
>  		goto bad_nofile;
>  	si = swap_info[type];
> 
> -	rcu_read_lock();
> +	preempt_disable();
>  	if (!(si->flags & SWP_VALID))
>  		goto unlock_out;
>  	/*
> @@ -1143,7 +1144,7 @@ struct swap_info_struct *get_swap_device(swp_entry_t entry)
>  out:
>  	return NULL;
>  unlock_out:
> -	rcu_read_unlock();
> +	preempt_enable();
>  	return NULL;
>  }
> 
> @@ -2581,6 +2582,11 @@ bool has_usable_swap(void)
>  	return ret;
>  }
> 
> +static int swapoff_stop(void *arg)
> +{
> +	return 0;
> +}
> +
>  SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
>  {
>  	struct swap_info_struct *p = NULL;
> @@ -2677,7 +2683,7 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
>  	 * wait for swap operations protected by get/put_swap_device()
>  	 * to complete
>  	 */
> -	synchronize_rcu();
> +	stop_machine(swapoff_stop, NULL, cpu_online_mask);
> 
>  	flush_work(&p->discard_work);
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
