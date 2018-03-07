Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9004F6B0005
	for <linux-mm@kvack.org>; Wed,  7 Mar 2018 04:07:05 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id v8so763942pgs.9
        for <linux-mm@kvack.org>; Wed, 07 Mar 2018 01:07:05 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h8si13313697pfi.117.2018.03.07.01.07.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 07 Mar 2018 01:07:03 -0800 (PST)
Subject: Re: [PATCH v2] mm: might_sleep warning
References: <20180306224004.25150-1-pasha.tatashin@oracle.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <33e3a3ff-0318-1a07-3c57-6be638046c87@suse.cz>
Date: Wed, 7 Mar 2018 10:06:59 +0100
MIME-Version: 1.0
In-Reply-To: <20180306224004.25150-1-pasha.tatashin@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>, steven.sistare@oracle.com, daniel.m.jordan@oracle.com, m.mizuma@jp.fujitsu.com, akpm@linux-foundation.org, mhocko@suse.com, catalin.marinas@arm.com, takahiro.akashi@linaro.org, gi-oh.kim@profitbricks.com, heiko.carstens@de.ibm.com, baiyaowei@cmss.chinamobile.com, richard.weiyang@gmail.com, paul.burton@mips.com, miles.chen@mediatek.com, mgorman@suse.de, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 03/06/2018 11:40 PM, Pavel Tatashin wrote:
> Robot reported this issue:
> https://lkml.org/lkml/2018/2/27/851
> 
> That is introduced by:
> mm: initialize pages on demand during boot
> 
> The problem is caused by changing static branch value within spin lock.
> Spin lock disables preemption, and changing static branch value takes
> mutex lock in its path, and thus may sleep.
> 
> The fix is to add another boolean variable to avoid the need to change
> static branch within spinlock.
> 
> Also, as noticed by Andrew, change spin_lock to spin_lock_irq, in order
> to disable interrupts and avoid possible deadlock with
> deferred_grow_zone().
> 
> Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
> ---
>  mm/page_alloc.c | 12 +++++++++---
>  1 file changed, 9 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index b337a026007c..5df1ca40a2ff 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1579,6 +1579,7 @@ static int __init deferred_init_memmap(void *data)
>   * page_alloc_init_late() soon after smp_init() is complete.
>   */
>  static __initdata DEFINE_SPINLOCK(deferred_zone_grow_lock);
> +static bool deferred_zone_grow __initdata = true;
>  static DEFINE_STATIC_KEY_TRUE(deferred_pages);
>  
>  /*
> @@ -1616,7 +1617,7 @@ deferred_grow_zone(struct zone *zone, unsigned int order)
>  	 * Bail if we raced with another thread that disabled on demand
>  	 * initialization.
>  	 */
> -	if (!static_branch_unlikely(&deferred_pages)) {
> +	if (!static_branch_unlikely(&deferred_pages) || !deferred_zone_grow) {
>  		spin_unlock_irqrestore(&deferred_zone_grow_lock, flags);
>  		return false;
>  	}
> @@ -1683,10 +1684,15 @@ void __init page_alloc_init_late(void)
>  	/*
>  	 * We are about to initialize the rest of deferred pages, permanently
>  	 * disable on-demand struct page initialization.

Hi,

I've noticed that this function first disables the on-demand
initialization, and then runs the kthreads. Doesn't that leave a window
where allocations can fail? The chances are probably small, but I think
it would be better to avoid it completely, rare failures suck.

Fixing that probably means rethinking the whole synchronization more
dramatically though :/

Vlastimil

> +	 *
> +	 * Note: it is prohibited to modify static branches in non-preemptible
> +	 * context. Since, spin_lock() disables preemption, we must use an
> +	 * extra boolean deferred_zone_grow.
>  	 */
> -	spin_lock(&deferred_zone_grow_lock);
> +	spin_lock_irq(&deferred_zone_grow_lock);
> +	deferred_zone_grow = false;
> +	spin_unlock_irq(&deferred_zone_grow_lock);
>  	static_branch_disable(&deferred_pages);
> -	spin_unlock(&deferred_zone_grow_lock);
>  
>  	/* There will be num_node_state(N_MEMORY) threads */
>  	atomic_set(&pgdat_init_n_undone, num_node_state(N_MEMORY));
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
