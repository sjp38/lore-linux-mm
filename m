Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id BFDA46B0033
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 07:46:01 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id t18so2786555wmt.7
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 04:46:01 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x200si2269471wme.45.2017.01.18.04.46.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 18 Jan 2017 04:46:00 -0800 (PST)
Date: Wed, 18 Jan 2017 13:45:55 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [Update][PATCH v5 7/9] mm/swap: Add cache for swap slots
 allocation
Message-ID: <20170118124555.GQ7015@dhcp22.suse.cz>
References: <cover.1484082593.git.tim.c.chen@linux.intel.com>
 <35de301a4eaa8daa2977de6e987f2c154385eb66.1484082593.git.tim.c.chen@linux.intel.com>
 <87tw8ymm2z.fsf_-_@yhuang-dev.intel.com>
 <20170117214234.GA14383@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170117214234.GA14383@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, dave.hansen@intel.com, ak@linux.intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Jonathan Corbet <corbet@lwn.net>, Tim C Chen <tim.c.chen@intel.com>

On Tue 17-01-17 13:42:35, Tim Chen wrote:
[...]
> Date: Tue, 17 Jan 2017 12:57:00 -0800
> Subject: [PATCH] mm/swap: Use raw_cpu_ptr over this_cpu_ptr for swap slots
>  access
> To: Andrew Morton <akpm@linux-foundation.org>
> Cc: Ying Huang <ying.huang@intel.com>, dave.hansen@intel.com, ak@linux.intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Kirill A . Shutemov <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Jonathan Corbet <corbet@lwn.net>
> 
> From: "Huang, Ying" <ying.huang@intel.com>
> 
> The usage of this_cpu_ptr in get_swap_page causes a bug warning
> as it is used in pre-emptible code.
> 
> [   57.812314] BUG: using smp_processor_id() in preemptible [00000000] code: kswapd0/527
> [   57.814360] caller is debug_smp_processor_id+0x17/0x19
> [   57.815237] CPU: 1 PID: 527 Comm: kswapd0 Tainted: G        W 4.9.0-mmotm-00135-g4e9a9895ebef #1042
> [   57.816019] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.1-1 04/01/2014
> [   57.816019]  ffffc900001939c0 ffffffff81329c60 0000000000000001 ffffffff81a0ce06
> [   57.816019]  ffffc900001939f0 ffffffff81343c2a 00000000000137a0 ffffea0000dfd2a0
> [   57.816019]  ffff88003c49a700 ffffc90000193b10 ffffc90000193a00 ffffffff81343c53
> [   57.816019] Call Trace:
> [   57.816019]  [<ffffffff81329c60>] dump_stack+0x68/0x92
> [   57.816019]  [<ffffffff81343c2a>] check_preemption_disabled+0xce/0xe0
> [   57.816019]  [<ffffffff81343c53>] debug_smp_processor_id+0x17/0x19
> [   57.816019]  [<ffffffff8115f06f>] get_swap_page+0x19/0x183
> [   57.816019]  [<ffffffff8114e01d>] shmem_writepage+0xce/0x38c
> [   57.816019]  [<ffffffff81148916>] shrink_page_list+0x81f/0xdbf
> [   57.816019]  [<ffffffff81149652>] shrink_inactive_list+0x2ab/0x594
> [   57.816019]  [<ffffffff8114a22f>] shrink_node_memcg+0x4c7/0x673
> [   57.816019]  [<ffffffff8114a49f>] shrink_node+0xc4/0x282
> [   57.816019]  [<ffffffff8114a49f>] ? shrink_node+0xc4/0x282
> [   57.816019]  [<ffffffff8114b8cb>] kswapd+0x656/0x834
> 
> Logic wise, We do allow pre-emption as per cpu ptr cache->slots is
> protected by the mutex cache->alloc_lock.  We switch the
> inappropriately used this_cpu_ptr to raw_cpu_ptr for per cpu ptr
> access of cache->slots.

OK, that looks better. I would still appreciate something like the
following folded in
diff --git a/include/linux/swap_slots.h b/include/linux/swap_slots.h
index fb907346c5c6..0afe748453a7 100644
--- a/include/linux/swap_slots.h
+++ b/include/linux/swap_slots.h
@@ -11,6 +11,7 @@
 
 struct swap_slots_cache {
 	bool		lock_initialized;
+	/* protects slots, nr, cur */
 	struct mutex	alloc_lock;
 	swp_entry_t	*slots;
 	int		nr;

> 
> Reported-by: Michal Hocko <mhocko@kernel.org>
> Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
> Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>

Reviewed-by: Michal Hocko <mhocko@suse.com>

Thanks!

> ---
>  mm/swap_slots.c | 11 ++++++++++-
>  1 file changed, 10 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/swap_slots.c b/mm/swap_slots.c
> index 8cf941e..9b5bc86 100644
> --- a/mm/swap_slots.c
> +++ b/mm/swap_slots.c
> @@ -303,7 +303,16 @@ swp_entry_t get_swap_page(void)
>  	swp_entry_t entry, *pentry;
>  	struct swap_slots_cache *cache;
>  
> -	cache = this_cpu_ptr(&swp_slots);
> +	/*
> +	 * Preemption is allowed here, because we may sleep
> +	 * in refill_swap_slots_cache().  But it is safe, because
> +	 * accesses to the per-CPU data structure are protected by the
> +	 * mutex cache->alloc_lock.
> +	 *
> +	 * The alloc path here does not touch cache->slots_ret
> +	 * so cache->free_lock is not taken.
> +	 */
> +	cache = raw_cpu_ptr(&swp_slots);
>  
>  	entry.val = 0;
>  	if (check_cache_active()) {
> -- 
> 2.5.5
> 



-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
