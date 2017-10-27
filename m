Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9BB936B025F
	for <linux-mm@kvack.org>; Fri, 27 Oct 2017 13:02:06 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id m82so2419272wmd.19
        for <linux-mm@kvack.org>; Fri, 27 Oct 2017 10:02:06 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id q6si2143040edk.452.2017.10.27.10.02.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 27 Oct 2017 10:02:05 -0700 (PDT)
Date: Fri, 27 Oct 2017 13:01:56 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: Simplify and batch working set shadow pages LRU
 isolation locking
Message-ID: <20171027170156.GA1743@cmpxchg.org>
References: <20171026234854.25764-1-andi@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171026234854.25764-1-andi@firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>

On Thu, Oct 26, 2017 at 04:48:54PM -0700, Andi Kleen wrote:
>  static unsigned long scan_shadow_nodes(struct shrinker *shrinker,
>  				       struct shrink_control *sc)
>  {
> +	struct list_head *tmp, *pos;
>  	unsigned long ret;
> +	LIST_HEAD(nodes);
> +	spinlock_t *lock = NULL;
>  
> -	/* list_lru lock nests inside IRQ-safe mapping->tree_lock */
> +	ret = list_lru_shrink_walk(&shadow_nodes, sc, shadow_lru_isolate, &nodes);
>  	local_irq_disable();
> -	ret = list_lru_shrink_walk(&shadow_nodes, sc, shadow_lru_isolate, NULL);
> +	list_for_each_safe (pos, tmp, &nodes)
> +		free_shadow_node(pos, &lock);

The nlru->lock in list_lru_shrink_walk() is the only thing that keeps
truncation blocked on workingset_update_node() -> list_lru_del() and
so ultimately keeping it from freeing the radix tree node.

It's not safe to access the nodes on the private list after that.

Batching mapping->tree_lock is possible, but you have to keep the
lock-handoff scheme. Pass a &mapping to list_lru_shrink_walk() and
only unlock and spin_trylock(&mapping->tree_lock) if it changes?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
