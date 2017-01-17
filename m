Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id DCF726B0033
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 20:06:09 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id t6so85862863pgt.6
        for <linux-mm@kvack.org>; Mon, 16 Jan 2017 17:06:09 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id v66si23132157pfd.284.2017.01.16.17.06.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jan 2017 17:06:08 -0800 (PST)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH v5 0/9] mm/swap: Regular page swap optimizations
References: <cover.1484082593.git.tim.c.chen@linux.intel.com>
	<20170116120236.GG13641@dhcp22.suse.cz>
Date: Tue, 17 Jan 2017 09:06:04 +0800
In-Reply-To: <20170116120236.GG13641@dhcp22.suse.cz> (Michal Hocko's message
	of "Mon, 16 Jan 2017 13:02:36 +0100")
Message-ID: <878tqapkar.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Ying Huang <ying.huang@intel.com>, dave.hansen@intel.com, ak@linux.intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Jonathan Corbet <corbet@lwn.net>

Michal Hocko <mhocko@kernel.org> writes:

> Hi,
> I am seeing a lot of preempt unsafe warnings with the current mmotm and
> I assume that this patchset has introduced the issue. I haven't checked
> more closely but get_swap_page didn't use this_cpu_ptr before "mm/swap:
> add cache for swap slots allocation"
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
> [   57.816019]  [<ffffffff8114b275>] ? mem_cgroup_shrink_node+0x2e1/0x2e1
> [   57.816019]  [<ffffffff81069fb4>] ? call_usermodehelper_exec_async+0x124/0x12d
> [   57.816019]  [<ffffffff81073621>] kthread+0xf9/0x101
> [   57.816019]  [<ffffffff81660198>] ? _raw_spin_unlock_irq+0x2c/0x4a
> [   57.816019]  [<ffffffff81073528>] ? kthread_park+0x5a/0x5a
> [   57.816019]  [<ffffffff81069e90>] ? umh_complete+0x25/0x25
> [   57.816019]  [<ffffffff81660b07>] ret_from_fork+0x27/0x40

Sorry for bothering, we should have tested this before.

> I thought a simple 
> diff --git a/mm/swap_slots.c b/mm/swap_slots.c
> index 8cf941e09941..732194de58a4 100644
> --- a/mm/swap_slots.c
> +++ b/mm/swap_slots.c
> @@ -303,7 +303,7 @@ swp_entry_t get_swap_page(void)
>  	swp_entry_t entry, *pentry;
>  	struct swap_slots_cache *cache;
>  
> -	cache = this_cpu_ptr(&swp_slots);
> +	cache = &get_cpu_var(swp_slots);
>  
>  	entry.val = 0;
>  	if (check_cache_active()) {
> @@ -322,11 +322,13 @@ swp_entry_t get_swap_page(void)
>  		}
>  		mutex_unlock(&cache->alloc_lock);
>  		if (entry.val)
> -			return entry;
> +			goto out;
>  	}
>  
>  	get_swap_pages(1, &entry);
>  
> +out:
> +	put_cpu_var(swp_slots);
>  	return entry;
>  }
>  
>
> would be a way to go but the function takes a sleeping lock so disabling
> the preemption is not a way forward. So this is either preempt safe
> for some reason - which should be IMHO documented in a comment - and
> raw_cpu_ptr can be used or this needs a deeper thought.

Thanks for pointing out this.

We think this is preempt safe.  During the development, we have
considered the possible preemption between getting the per-CPU pointer
and its usage, and implemented the code to make it work at that
situation.  We will change the code to use raw_cpu_ptr() and add a
comment for it.

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
