Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f169.google.com (mail-io0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id 72A0282F64
	for <linux-mm@kvack.org>; Wed, 14 Oct 2015 02:01:00 -0400 (EDT)
Received: by iodv82 with SMTP id v82so44843371iod.0
        for <linux-mm@kvack.org>; Tue, 13 Oct 2015 23:01:00 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id y129si5831208iod.100.2015.10.13.23.00.59
        for <linux-mm@kvack.org>;
        Tue, 13 Oct 2015 23:00:59 -0700 (PDT)
Message-ID: <561DEEED.7070609@intel.com>
Date: Wed, 14 Oct 2015 13:58:05 +0800
From: Pan Xinhui <xinhuix.pan@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH] gfp: GFP_RECLAIM_MASK should include __GFP_NO_KSWAPD
References: <561DE9F3.504@intel.com>
In-Reply-To: <561DE9F3.504@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, vbabka@suse.cz, rientjes@google.com, hannes@cmpxchg.org, mhocko@suse.cz, nasa4836@gmail.com, mgorman@suse.de, alexander.h.duyck@redhat.com, aneesh.kumar@linux.vnet.ibm.com, "yanmin_zhang@linux.intel.com" <yanmin_zhang@linux.intel.com>

Hi, all
	I am working on some debug features' development.
I use kmalloc in some places of *scheduler*. And the gfp_flag is GFP_ATOMIC, code looks like 
p = kmalloc(sizeof(*p), GFP_ATOMIC);

however I notice GFP_ATOMIC is still not enough. because when system is at low memory state, slub might try to wakeup kswapd. then some weird issues hit.

for example, this is one bug log.

[   83.713009, 0]BUG: spinlock recursion on CPU#0, rcu_preempt/7
[   83.719463, 0] lock: 0xffff88007ac12140, .magic: dead4ead, .owner: rcu_preempt/7, .owner_cpu: 0
[   83.729211, 0]CPU: 0 PID: 7 Comm: rcu_preempt Tainted: G        W    3.14.37-x86_64-gfa0f236-dirty #364
[   83.739733, 0]Hardware name: Intel Corporation CHERRYVIEW C0 PLATFORM/Cherry Trail FFD, BIOS BYO-P2.X64.0023.R03.1509161045 09/16/2015
[   83.753266, 0] ffff88007ac12140 ffff880074863880 ffffffff8198bca9 ffff8800749118b0
[   83.761871, 0] ffff8800748638a0 ffffffff819886d2 ffff88007ac12140 ffffffff81d89797
[   83.770451, 0] ffff8800748638c0 ffffffff819886fd ffff88007ac12140 ffff880070dc38a8
[   83.779066, 0]Call Trace:
[   83.782014, 0] [<ffffffff8198bca9>] dump_stack+0x4e/0x7a
[   83.787975, 0] [<ffffffff819886d2>] spin_dump+0x91/0x96
[   83.793839, 0] [<ffffffff819886fd>] spin_bug+0x26/0x2b
[   83.799606, 0] [<ffffffff810d3366>] do_raw_spin_lock+0x116/0x140
[   83.806344, 0] [<ffffffff81998d8f>] _raw_spin_lock+0x1f/0x30
[   83.812693, 0] [<ffffffff810bb884>] try_to_wake_up+0x154/0x2c0
[   83.819237, 0] [<ffffffff810bba62>] default_wake_function+0x12/0x20
[   83.826265, 0] [<ffffffff810cb1e8>] autoremove_wake_function+0x18/0x40
[   83.833585, 0] [<ffffffff810caaf8>] __wake_up_common+0x58/0x90
[   83.840128, 0] [<ffffffff810cad29>] __wake_up+0x39/0x50
[   83.845994, 0] [<ffffffff811659cd>] wakeup_kswapd+0xcd/0x140
[   83.852343, 0] [<ffffffff8115cbdd>] __alloc_pages_nodemask+0x95d/0xa30
[   83.859666, 0] [<ffffffff81195d2f>] new_slab+0x6f/0x2b0
[   83.865529, 0] [<ffffffff81989e5d>] __slab_alloc.constprop.64+0x26c/0x49f
[   83.873141, 0] [<ffffffff810af6c5>] ? insert_kill_task+0x25/0xa0
[   83.879880, 0] [<ffffffff81387f54>] ? __list_del_entry+0x14/0xf0
[   83.886618, 0] [<ffffffff811975f4>] kmem_cache_alloc_trace+0x174/0x1b0
[   83.893938, 0] [<ffffffff810af6c5>] ? insert_kill_task+0x25/0xa0
[   83.900677, 0] [<ffffffff810af6c5>] insert_kill_task+0x25/0xa0 //this function is simple, just treat it as kmalloc :)
[   83.907220, 0] [<ffffffff81994846>] __schedule+0x6a6/0x870
[   83.913375, 0] [<ffffffff81994a39>] schedule+0x29/0x70
[   83.919141, 0] [<ffffffff81993b02>] schedule_timeout+0x172/0x310
[   83.925879, 0] [<ffffffff81998e8e>] ? _raw_spin_unlock_irqrestore+0x1e/0x40
[   83.933685, 0] [<ffffffff810937c0>] ? __internal_add_timer+0x130/0x130
[   83.941005, 0] [<ffffffff810cb047>] ? prepare_to_wait_event+0x87/0xf0
[   83.948230, 0] [<ffffffff810e371a>] rcu_gp_kthread+0x40a/0x6e0
[   83.954774, 0] [<ffffffff810cb1d0>] ? abort_exclusive_wait+0xb0/0xb0
[   83.961899, 0] [<ffffffff810e3310>] ? rcu_try_advance_all_cbs+0xf0/0xf0
[   83.969315, 0] [<ffffffff810aa8a4>] kthread+0xe4/0x100
[   83.975081, 0] [<ffffffff810aa7c0>] ? kthread_create_on_node+0x190/0x190
[   83.982596, 0] [<ffffffff819a0f48>] ret_from_fork+0x58/0x90
[   83.988847, 0] [<ffffffff810aa7c0>] ? kthread_create_on_node+0x190/0x190

After some simple check, I change my codes. this time code looks like:
p = kmalloc(sizeof(*p), GFP_ATOMIC | __GFP_NO_KSWAPD);
I think this flag will forbid slub to call any scheduler codes. But issue still hit. :(

my test result shows that __GFP_NO_KSWAPD is cleared when slub pass gfp_flag to page allocator!!!

at last I found it is clear by codes below.
1441 static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node)
1442 {
1443         if (unlikely(flags & GFP_SLAB_BUG_MASK)) {
1444                 pr_emerg("gfp: %u\n", flags & GFP_SLAB_BUG_MASK);
1445                 BUG();
1446         }
1447 
1448         return allocate_slab(s,
1449                 flags & (GFP_RECLAIM_MASK | GFP_CONSTRAINT_MASK), node);//all other flags will be cleared. my god!!!
1450 }

I think GFP_RECLAIM_MASK should include as many available flags as possible. :)

thanks
xinhui

On 2015a1'10ae??14ae?JPY 13:36, Pan Xinhui wrote:
> From: Pan Xinhui <xinhuix.pan@intel.com>
> 
> GFP_RECLAIM_MASK was introduced in commit 6cb062296f73 ("Categorize GFP
> flags"). In slub subsystem, this macro controls slub's allocation
> behavior. In particular, some flags which are not in GFP_RECLAIM_MASK
> will be cleared. So when slub pass this new gfp_flag into page
> allocator, we might lost some very important flags.
> 
> There are some mistakes when we introduce __GFP_NO_KSWAPD. This flag is
> used to avoid any scheduler-related codes recursive.  But it seems like
> patch author forgot to add it into GFP_RECLAIM_MASK. So lets add it now.
> 
> Signed-off-by: Pan Xinhui <xinhuix.pan@intel.com>
> ---
>  include/linux/gfp.h | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index f92cbd2..9ebad4d 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -130,7 +130,8 @@ struct vm_area_struct;
>  /* Control page allocator reclaim behavior */
>  #define GFP_RECLAIM_MASK (__GFP_WAIT|__GFP_HIGH|__GFP_IO|__GFP_FS|\
>  			__GFP_NOWARN|__GFP_REPEAT|__GFP_NOFAIL|\
> -			__GFP_NORETRY|__GFP_MEMALLOC|__GFP_NOMEMALLOC)
> +			__GFP_NORETRY|__GFP_MEMALLOC|__GFP_NOMEMALLOC|\
> +			__GFP_NO_KSWAPD)
>  
>  /* Control slab gfp mask during early boot */
>  #define GFP_BOOT_MASK (__GFP_BITS_MASK & ~(__GFP_WAIT|__GFP_IO|__GFP_FS))
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
