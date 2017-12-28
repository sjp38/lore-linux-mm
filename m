Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 887BA6B0033
	for <linux-mm@kvack.org>; Wed, 27 Dec 2017 20:53:27 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id z3so22476197plh.18
        for <linux-mm@kvack.org>; Wed, 27 Dec 2017 17:53:27 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id l14si14820795pgc.42.2017.12.27.17.53.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Dec 2017 17:53:26 -0800 (PST)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -V5b -mm] mm, swap: Fix race between swapoff and some swap operations
References: <20171228005805.15632-1-ying.huang@intel.com>
Date: Thu, 28 Dec 2017 09:53:22 +0800
In-Reply-To: <20171228005805.15632-1-ying.huang@intel.com> (Ying Huang's
	message of "Thu, 28 Dec 2017 08:58:05 +0800")
Message-ID: <87d12zsjn1.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Tim Chen <tim.c.chen@linux.intel.com>, Shaohua Li <shli@fb.com>, Mel Gorman <mgorman@techsingularity.net>, =?utf-8?B?SsOp?= =?utf-8?B?csO0bWU=?= Glisse <jglisse@redhat.com>, Michal Hocko <mhocko@suse.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Dave Jiang <dave.jiang@intel.com>, Aaron Lu <aaron.lu@intel.com>

"Huang, Ying" <ying.huang@intel.com> writes:

> From: Huang Ying <ying.huang@intel.com>
>
> When the swapin is performed, after getting the swap entry information
> from the page table, system will swap in the swap entry, without any
> lock held to prevent the swap device from being swapoff.  This may
> cause the race like below,
>
> CPU 1				CPU 2
> -----				-----
> 				do_swap_page
> 				  swapin_readahead
> 				    __read_swap_cache_async
> swapoff				      swapcache_prepare
>   p->swap_map = NULL		        __swap_duplicate
> 					  p->swap_map[?] /* !!! NULL pointer access */
>
> Because swapoff is usually done when system shutdown only, the race
> may not hit many people in practice.  But it is still a race need to
> be fixed.
>
> To fix the race, get_swap_device() is added to check whether the
> specified swap entry is valid in its swap device.  If so, it will keep
> the swap entry valid via preventing the swap device from being
> swapoff, until put_swap_device() is called.
>
> Because swapoff() is very rare code path, to make the normal path runs
> as fast as possible, disabling preemption + stop_machine() instead of
> reference count is used to implement get/put_swap_device().  From
> get_swap_device() to put_swap_device(), the preemption is disabled, so
> stop_machine() in swapoff() will wait until put_swap_device() is
> called.
>
> In addition to swap_map, cluster_info, etc. data structure in the
> struct swap_info_struct, the swap cache radix tree will be freed after
> swapoff, so this patch fixes the race between swap cache looking up
> and swapoff too.
>
> Races between some other swap cache usages protected via disabling
> preemption and swapoff are fixed too via calling stop_machine()
> between clearing PageSwapCache() and freeing swap cache data
> structure.
>
> Alternative implementation could be replacing disable preemption with
> rcu_read_lock_sched and stop_machine() with synchronize_sched().
>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Tim Chen <tim.c.chen@linux.intel.com>
> Cc: Shaohua Li <shli@fb.com>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: "JA(C)rA'me Glisse" <jglisse@redhat.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Jan Kara <jack@suse.cz>
> Cc: Dave Jiang <dave.jiang@intel.com>
> Cc: Aaron Lu <aaron.lu@intel.com>
> Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
>
> Changelog:
>
> v5:
>
> - Replace RCU with stop_machine()

2 versions (-V5a and -V5b) have been sent, one is implemented with
stop_machine(), the other is implemented with RCU-sched.  RCU-sched
based version is better for real time users.  Both are OK for me.

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
