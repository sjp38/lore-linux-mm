Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id EBD016B0033
	for <linux-mm@kvack.org>; Wed, 11 Jan 2017 20:46:00 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id z128so15752664pfb.4
        for <linux-mm@kvack.org>; Wed, 11 Jan 2017 17:46:00 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id w61si7484925plb.328.2017.01.11.17.45.57
        for <linux-mm@kvack.org>;
        Wed, 11 Jan 2017 17:45:58 -0800 (PST)
Date: Thu, 12 Jan 2017 10:41:01 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH v4 04/15] lockdep: Add a function building a chain
 between two classes
Message-ID: <20170112014101.GV2279@X58A-UD3R>
References: <1481260331-360-1-git-send-email-byungchul.park@lge.com>
 <1481260331-360-5-git-send-email-byungchul.park@lge.com>
 <20170110210038.GF3092@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170110210038.GF3092@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com

On Tue, Jan 10, 2017 at 10:00:38PM +0100, Peter Zijlstra wrote:
> > +static inline int add_chain_cache_classes(unsigned int prev,
> > +					  unsigned int next,
> > +					  unsigned int irq_context,
> > +					  u64 chain_key)
> > +{
> > +	struct hlist_head *hash_head = chainhashentry(chain_key);
> > +	struct lock_chain *chain;
> > +
> > +	/*
> > +	 * Allocate a new chain entry from the static array, and add
> > +	 * it to the hash:
> > +	 */
> > +
> > +	/*
> > +	 * We might need to take the graph lock, ensure we've got IRQs
> > +	 * disabled to make this an IRQ-safe lock.. for recursion reasons
> > +	 * lockdep won't complain about its own locking errors.
> > +	 */
> > +	if (DEBUG_LOCKS_WARN_ON(!irqs_disabled()))
> > +		return 0;
> > +
> > +	if (unlikely(nr_lock_chains >= MAX_LOCKDEP_CHAINS)) {
> > +		if (!debug_locks_off_graph_unlock())
> > +			return 0;
> > +
> > +		print_lockdep_off("BUG: MAX_LOCKDEP_CHAINS too low!");
> > +		dump_stack();
> > +		return 0;
> > +	}
> > +
> > +	chain = lock_chains + nr_lock_chains++;
> > +	chain->chain_key = chain_key;
> > +	chain->irq_context = irq_context;
> > +	chain->depth = 2;
> > +	if (likely(nr_chain_hlocks + chain->depth <= MAX_LOCKDEP_CHAIN_HLOCKS)) {
> > +		chain->base = nr_chain_hlocks;
> > +		nr_chain_hlocks += chain->depth;
> > +		chain_hlocks[chain->base] = prev - 1;
> > +		chain_hlocks[chain->base + 1] = next -1;
> > +	}
> 
> You didn't copy this part right. There is no error when >
> MAX_LOCKDEP_CHAIN_HLOCKS.

Oh my god! I am sorry. I missed it.

Thank you,
Byungchul

> 
> 
> > +	hlist_add_head_rcu(&chain->entry, hash_head);
> > +	debug_atomic_inc(chain_lookup_misses);
> > +	inc_chains();
> > +
> > +	return 1;
> > +}
> > +
> >  static inline int add_chain_cache(struct task_struct *curr,
> >  				  struct held_lock *hlock,
> >  				  u64 chain_key)
> > -- 
> > 1.9.1
> > 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
