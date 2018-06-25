Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id B05D56B0008
	for <linux-mm@kvack.org>; Mon, 25 Jun 2018 06:36:24 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id z11-v6so6977704pfn.1
        for <linux-mm@kvack.org>; Mon, 25 Jun 2018 03:36:24 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0114.outbound.protection.outlook.com. [104.47.1.114])
        by mx.google.com with ESMTPS id j84-v6si13835127pfj.79.2018.06.25.03.36.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 25 Jun 2018 03:36:23 -0700 (PDT)
Subject: Re: [PATCH 1/3] mm: workingset: remove local_irq_disable() from
 count_shadow_nodes()
References: <20180622151221.28167-1-bigeasy@linutronix.de>
 <20180622151221.28167-2-bigeasy@linutronix.de>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <0a44a872-eef1-6b4d-0344-7521c4ccc966@virtuozzo.com>
Date: Mon, 25 Jun 2018 13:36:08 +0300
MIME-Version: 1.0
In-Reply-To: <20180622151221.28167-2-bigeasy@linutronix.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>, linux-mm@kvack.org
Cc: tglx@linutronix.de, Andrew Morton <akpm@linux-foundation.org>

On 22.06.2018 18:12, Sebastian Andrzej Siewior wrote:
> In commit 0c7c1bed7e13 ("mm: make counting of list_lru_one::nr_items
> lockless") the
> 	spin_lock(&nlru->lock);
> 
> statement was replaced with
> 	rcu_read_lock();
> 
> in __list_lru_count_one(). The comment in count_shadow_nodes() says that
> the local_irq_disable() is required because the lock must be acquired
> with disabled interrupts and (spin_lock()) does not do so.
> Since the lock is replaced with rcu_read_lock() the local_irq_disable()
> is no longer needed. The code path is
>   list_lru_shrink_count()
>     -> list_lru_count_one()
>       -> __list_lru_count_one()
>         -> rcu_read_lock()
>         -> list_lru_from_memcg_idx()
>         -> rcu_read_unlock()
> 
> Remove the local_irq_disable() statement.
> 
> Cc: Kirill Tkhai <ktkhai@virtuozzo.com>
> Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>

Looks good for me.

Reviewed-by: Kirill Tkhai <ktkhai@virtuozzo.com>

> ---
>  mm/workingset.c | 3 ---
>  1 file changed, 3 deletions(-)
> 
> diff --git a/mm/workingset.c b/mm/workingset.c
> index 40ee02c83978..ed8151180899 100644
> --- a/mm/workingset.c
> +++ b/mm/workingset.c
> @@ -366,10 +366,7 @@ static unsigned long count_shadow_nodes(struct shrinker *shrinker,
>  	unsigned long nodes;
>  	unsigned long cache;
>  
> -	/* list_lru lock nests inside the IRQ-safe i_pages lock */
> -	local_irq_disable();
>  	nodes = list_lru_shrink_count(&shadow_nodes, sc);
> -	local_irq_enable();
>  
>  	/*
>  	 * Approximate a reasonable limit for the radix tree nodes
> 
