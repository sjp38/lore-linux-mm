Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f175.google.com (mail-ie0-f175.google.com [209.85.223.175])
	by kanga.kvack.org (Postfix) with ESMTP id D77016B0039
	for <linux-mm@kvack.org>; Wed, 16 Apr 2014 03:22:13 -0400 (EDT)
Received: by mail-ie0-f175.google.com with SMTP id to1so10091963ieb.20
        for <linux-mm@kvack.org>; Wed, 16 Apr 2014 00:22:13 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id m10si14193134icu.97.2014.04.16.00.22.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Apr 2014 00:22:10 -0700 (PDT)
Date: Wed, 16 Apr 2014 09:22:02 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 03/19] lockdep: improve scenario messages for RECLAIM_FS
 errors.
Message-ID: <20140416072202.GM26782@laptop.programming.kicks-ass.net>
References: <20140416033623.10604.69237.stgit@notabene.brown>
 <20140416040336.10604.19304.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140416040336.10604.19304.stgit@notabene.brown>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: NeilBrown <neilb@suse.de>
Cc: linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@redhat.com>, xfs@oss.sgi.com

On Wed, Apr 16, 2014 at 02:03:36PM +1000, NeilBrown wrote:
> lockdep can check for locking problems involving reclaim using
> the same infrastructure as used for interrupts.
> 
> However a number of the messages still refer to interrupts even
> if it was actually a reclaim-related problem.
> 
> So determine where the problem was caused by reclaim or irq and adjust
> messages accordingly.
> 
> Signed-off-by: NeilBrown <neilb@suse.de>
> ---
>  kernel/locking/lockdep.c |   43 ++++++++++++++++++++++++++++++++-----------
>  1 file changed, 32 insertions(+), 11 deletions(-)
> 
> diff --git a/kernel/locking/lockdep.c b/kernel/locking/lockdep.c
> index e05b82e92373..33d2ac7519dc 100644
> --- a/kernel/locking/lockdep.c
> +++ b/kernel/locking/lockdep.c
> @@ -1423,7 +1423,8 @@ static void
>  print_irq_lock_scenario(struct lock_list *safe_entry,
>  			struct lock_list *unsafe_entry,
>  			struct lock_class *prev_class,
> -			struct lock_class *next_class)
> +			struct lock_class *next_class,
> +			int reclaim)

I would rather we just pass enum lock_usage_bit along from the
callsites.

>  {
>  	struct lock_class *safe_class = safe_entry->class;
>  	struct lock_class *unsafe_class = unsafe_entry->class;

> @@ -1487,6 +1495,8 @@ print_bad_irq_dependency(struct task_struct *curr,
>  			 enum lock_usage_bit bit2,
>  			 const char *irqclass)
>  {
> +	int reclaim = strncmp(irqclass, "RECLAIM", 7) == 0;
> +

irqclass := state_name(bit2), so instead of relying on the unreliable,
why not use the lock_usage_bit ?

>  	if (!debug_locks_off_graph_unlock() || debug_locks_silent)
>  		return 0;
>  
> @@ -1528,7 +1538,7 @@ print_bad_irq_dependency(struct task_struct *curr,
>  
>  	printk("\nother info that might help us debug this:\n\n");
>  	print_irq_lock_scenario(backwards_entry, forwards_entry,
> -				hlock_class(prev), hlock_class(next));
> +				hlock_class(prev), hlock_class(next), reclaim);

So that would become bit2.

>  
>  	lockdep_print_held_locks(curr);
>  
> @@ -2200,7 +2210,7 @@ static void check_chain_key(struct task_struct *curr)
>  }
>  
>  static void
> -print_usage_bug_scenario(struct held_lock *lock)
> +print_usage_bug_scenario(struct held_lock *lock, enum lock_usage_bit new_bit)

Like you did here.

>  {
>  	struct lock_class *class = hlock_class(lock);
>  
> @@ -2210,7 +2220,11 @@ print_usage_bug_scenario(struct held_lock *lock)
>  	printk("  lock(");
>  	__print_lock_name(class);
>  	printk(");\n");
> -	printk("  <Interrupt>\n");
> +	if (new_bit == LOCK_USED_IN_RECLAIM_FS ||
> +	    new_bit == LOCK_USED_IN_RECLAIM_FS_READ)

And if we're going to do this all over, we might want a helper for this
condition.

> +		printk("  <Memory allocation/reclaim>\n");
> +	else
> +		printk("  <Interrupt>\n");
>  	printk("    lock(");
>  	__print_lock_name(class);
>  	printk(");\n");

Same for the rest I think..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
