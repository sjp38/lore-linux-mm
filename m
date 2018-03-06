Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 80AE16B002D
	for <linux-mm@kvack.org>; Tue,  6 Mar 2018 15:37:00 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id o23so14005232wrc.9
        for <linux-mm@kvack.org>; Tue, 06 Mar 2018 12:37:00 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id p38si11639490wrc.266.2018.03.06.12.36.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Mar 2018 12:36:59 -0800 (PST)
Date: Tue, 6 Mar 2018 12:36:55 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: might_sleep warning
Message-Id: <20180306123655.957e5b6b20b200505544ea7a@linux-foundation.org>
In-Reply-To: <20180306192022.28289-1-pasha.tatashin@oracle.com>
References: <20180306192022.28289-1-pasha.tatashin@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, m.mizuma@jp.fujitsu.com, mhocko@suse.com, catalin.marinas@arm.com, takahiro.akashi@linaro.org, gi-oh.kim@profitbricks.com, heiko.carstens@de.ibm.com, baiyaowei@cmss.chinamobile.com, richard.weiyang@gmail.com, paul.burton@mips.com, miles.chen@mediatek.com, vbabka@suse.cz, mgorman@suse.de, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue,  6 Mar 2018 14:20:22 -0500 Pavel Tatashin <pasha.tatashin@oracle.com> wrote:

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
> ...
>
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
> +	 *
> +	 * Note: it is prohibited to modify static branches in non-preemptible
> +	 * context. Since, spin_lock() disables preemption, we must use an
> +	 * extra boolean deferred_zone_grow.
>  	 */
>  	spin_lock(&deferred_zone_grow_lock);
> -	static_branch_disable(&deferred_pages);
> +	deferred_zone_grow = false;
>  	spin_unlock(&deferred_zone_grow_lock);
> +	static_branch_disable(&deferred_pages);
>  
>  	/* There will be num_node_state(N_MEMORY) threads */
>  	atomic_set(&pgdat_init_n_undone, num_node_state(N_MEMORY));

Kinda ugly, but I can see the logic behind the decisions.

Can we instead turn deferred_zone_grow_lock into a mutex?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
