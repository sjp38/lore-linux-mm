Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 87CAA6B0033
	for <linux-mm@kvack.org>; Tue, 10 Jan 2017 16:00:36 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id s10so83883042itb.7
        for <linux-mm@kvack.org>; Tue, 10 Jan 2017 13:00:36 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id 135si3004692ioz.251.2017.01.10.13.00.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Jan 2017 13:00:35 -0800 (PST)
Date: Tue, 10 Jan 2017 22:00:38 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v4 04/15] lockdep: Add a function building a chain
 between two classes
Message-ID: <20170110210038.GF3092@twins.programming.kicks-ass.net>
References: <1481260331-360-1-git-send-email-byungchul.park@lge.com>
 <1481260331-360-5-git-send-email-byungchul.park@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1481260331-360-5-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com

On Fri, Dec 09, 2016 at 02:12:00PM +0900, Byungchul Park wrote:
> add_chain_cache() should be used in the context where the hlock is
> owned since it might be racy in another context. However crossrelease
> feature needs to build a chain between two locks regardless of context.
> So introduce a new function making it possible.
> 
> Signed-off-by: Byungchul Park <byungchul.park@lge.com>
> ---
>  kernel/locking/lockdep.c | 56 ++++++++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 56 insertions(+)
> 
> diff --git a/kernel/locking/lockdep.c b/kernel/locking/lockdep.c
> index 5df56aa..111839f 100644
> --- a/kernel/locking/lockdep.c
> +++ b/kernel/locking/lockdep.c
> @@ -2105,6 +2105,62 @@ static int check_no_collision(struct task_struct *curr,
>  	return 1;
>  }
>  
> +/*
> + * This is for building a chain between just two different classes,
> + * instead of adding a new hlock upon current, which is done by
> + * add_chain_cache().
> + *
> + * This can be called in any context with two classes, while
> + * add_chain_cache() must be done within the lock owener's context
> + * since it uses hlock which might be racy in another context.
> + */
> +static inline int add_chain_cache_classes(unsigned int prev,
> +					  unsigned int next,
> +					  unsigned int irq_context,
> +					  u64 chain_key)
> +{
> +	struct hlist_head *hash_head = chainhashentry(chain_key);
> +	struct lock_chain *chain;
> +
> +	/*
> +	 * Allocate a new chain entry from the static array, and add
> +	 * it to the hash:
> +	 */
> +
> +	/*
> +	 * We might need to take the graph lock, ensure we've got IRQs
> +	 * disabled to make this an IRQ-safe lock.. for recursion reasons
> +	 * lockdep won't complain about its own locking errors.
> +	 */
> +	if (DEBUG_LOCKS_WARN_ON(!irqs_disabled()))
> +		return 0;
> +
> +	if (unlikely(nr_lock_chains >= MAX_LOCKDEP_CHAINS)) {
> +		if (!debug_locks_off_graph_unlock())
> +			return 0;
> +
> +		print_lockdep_off("BUG: MAX_LOCKDEP_CHAINS too low!");
> +		dump_stack();
> +		return 0;
> +	}
> +
> +	chain = lock_chains + nr_lock_chains++;
> +	chain->chain_key = chain_key;
> +	chain->irq_context = irq_context;
> +	chain->depth = 2;
> +	if (likely(nr_chain_hlocks + chain->depth <= MAX_LOCKDEP_CHAIN_HLOCKS)) {
> +		chain->base = nr_chain_hlocks;
> +		nr_chain_hlocks += chain->depth;
> +		chain_hlocks[chain->base] = prev - 1;
> +		chain_hlocks[chain->base + 1] = next -1;
> +	}

You didn't copy this part right. There is no error when >
MAX_LOCKDEP_CHAIN_HLOCKS.


> +	hlist_add_head_rcu(&chain->entry, hash_head);
> +	debug_atomic_inc(chain_lookup_misses);
> +	inc_chains();
> +
> +	return 1;
> +}
> +
>  static inline int add_chain_cache(struct task_struct *curr,
>  				  struct held_lock *hlock,
>  				  u64 chain_key)
> -- 
> 1.9.1
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
