Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 23DD26B0038
	for <linux-mm@kvack.org>; Mon, 16 Oct 2017 20:15:35 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id g128so301277itb.5
        for <linux-mm@kvack.org>; Mon, 16 Oct 2017 17:15:35 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id v4sor3807289itd.95.2017.10.16.17.15.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 16 Oct 2017 17:15:34 -0700 (PDT)
Date: Mon, 16 Oct 2017 17:15:31 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 3/3] mm: oom: show unreclaimable slab info when unreclaimable
 slabs > user memory
In-Reply-To: <1507656303-103845-4-git-send-email-yang.s@alibaba-inc.com>
Message-ID: <alpine.DEB.2.10.1710161709460.140151@chino.kir.corp.google.com>
References: <1507656303-103845-1-git-send-email-yang.s@alibaba-inc.com> <1507656303-103845-4-git-send-email-yang.s@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.s@alibaba-inc.com>
Cc: cl@linux.com, penberg@kernel.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, mhocko@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 11 Oct 2017, Yang Shi wrote:

> @@ -161,6 +162,25 @@ static bool oom_unkillable_task(struct task_struct *p,
>  	return false;
>  }
>  
> +/*
> + * Print out unreclaimble slabs info when unreclaimable slabs amount is greater
> + * than all user memory (LRU pages)
> + */
> +static bool is_dump_unreclaim_slabs(void)
> +{
> +	unsigned long nr_lru;
> +
> +	nr_lru = global_node_page_state(NR_ACTIVE_ANON) +
> +		 global_node_page_state(NR_INACTIVE_ANON) +
> +		 global_node_page_state(NR_ACTIVE_FILE) +
> +		 global_node_page_state(NR_INACTIVE_FILE) +
> +		 global_node_page_state(NR_ISOLATED_ANON) +
> +		 global_node_page_state(NR_ISOLATED_FILE) +
> +		 global_node_page_state(NR_UNEVICTABLE);
> +
> +	return (global_node_page_state(NR_SLAB_UNRECLAIMABLE) > nr_lru);
> +}

I think this is an excessive requirement to meet to dump potentially very 
helpful information to the kernel log.  On my 256GB system, this would 
probably require >128GB of unreclaimable slab to trigger.  If a single 
slab cache leaker were to blame for this excessive usage, it would suffice 
to only print a single line showing the slab cache with the greatest 
memory footprint.

It also prevents us from diagnosing issues where reclaimable slab isn't 
actually reclaimed as expected, so the scope is too narrow.

Previous iterations of this patchset were actually better because it 
presented useful data that wasn't restricted to excessive requirements for 
a very narrow scope.

Please simply dump statistics for all slab caches where the memory 
footprint is greater than 5% of system memory.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
