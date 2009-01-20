Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3C3E76B0044
	for <linux-mm@kvack.org>; Tue, 20 Jan 2009 05:29:21 -0500 (EST)
Subject: Re: [patch][rfc] lockdep: annotate reclaim context (__GFP_NOFS)
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20090120083906.GA19505@wotan.suse.de>
References: <20090120083906.GA19505@wotan.suse.de>
Content-Type: text/plain
Date: Tue, 20 Jan 2009 11:29:14 +0100
Message-Id: <1232447354.4886.47.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, mingo@redhat.com
List-ID: <linux-mm.kvack.org>

On Tue, 2009-01-20 at 09:39 +0100, Nick Piggin wrote:
> Hi,
> 
> I took a bit of time to clean this up since I posted the RFC.
> 
> I don't really know the lockdep code much, so this is about as
> far as I get without asking for review. I don't know if this is
> considered useful, but if it is, then maybe we can merge it and
> then fill in the bits for annotating other reclaim contexts.
> 
> The only problem is the lock usage character string won't scale
> well with more lock contexts. Why not just print out the hex
> value of the flags? Simple and easy to decode and extend.

Right, except that people already have trouble reading lockdep output..
But I see your problem, this state stuff doesn't scale too well
currently.

> ---
> 
> After noticing some code in mm/filemap.c accidentally perform a __GFP_FS
> allocation when it should not have been, I thought it might be a good idea to
> try to catch this kind of thing with lockdep.
> 
> I coded up a little idea that seems to work. It reuses the interrupt context
> discovery and annotation mechanism to reclaim contexts in order to discover
> possible deadlocks without having to actually hit them. If a lock is held
> while performing a __GFP_FS allocation, then that lock must not be taken
> during __GFP_FS reclaim. And vice versa.
> 
> Further possibilities: __GFP_IO, and __GFP_WAIT (without IO or FS). But
> filesystems are probably the most complicated with tricky locking, so let's
> start here first.
> 
> Example output:
> =================================
> [ INFO: inconsistent lock state ]
> 2.6.28-rc6-00007-ged31348-dirty #26
> ---------------------------------
> inconsistent {in-reclaim-W} -> {ov-reclaim-W} usage.
> modprobe/8526 [HC0[0]:SC0[0]:HE1:SE1] takes:
>  (testlock){--..}, at: [<ffffffffa0020055>] brd_init+0x55/0x216 [brd]

Except that with the below patch that would have had to have had 6 usage
chars :-)

> Signed-off-by: Nick Piggin <npiggin@suse.de>
> ---
>  include/linux/lockdep.h |   14 +++
>  include/linux/sched.h   |    1 
>  kernel/lockdep.c        |  186 ++++++++++++++++++++++++++++++++++++++++++++----
>  mm/page_alloc.c         |   13 +++
>  4 files changed, 201 insertions(+), 13 deletions(-)

 
> +#define LOCKDEP_PF_RECLAIM_FS_BIT	1	/* Process is with a GFP_FS
> +						 * allocation context */
> +

s/with/&in/

> Index: linux-2.6/kernel/lockdep.c
> ===================================================================
> --- linux-2.6.orig/kernel/lockdep.c	2009-01-20 18:36:58.000000000 +1100
> +++ linux-2.6/kernel/lockdep.c	2009-01-20 19:19:59.000000000 +1100

> @@ -454,6 +456,10 @@ static const char *usage_str[] =
>  	[LOCK_USED_IN_SOFTIRQ_READ] =	"in-softirq-R",
>  	[LOCK_ENABLED_SOFTIRQS_READ] =	"softirq-on-R",
>  	[LOCK_ENABLED_HARDIRQS_READ] =	"hardirq-on-R",
> +	[LOCK_USED_IN_RECLAIM_FS] =	"in-reclaim-W",
> +	[LOCK_USED_IN_RECLAIM_FS_READ] = "in-reclaim-R",
> +	[LOCK_HELD_OVER_RECLAIM_FS] =	"ov-reclaim-W",
> +	[LOCK_HELD_OVER_RECLAIM_FS_READ] = "ov-reclaim-R",
>  };
>  
>  const char * __get_key_name(struct lockdep_subclass_key *key, char *str)
> @@ -462,9 +468,10 @@ const char * __get_key_name(struct lockd
>  }
>  
>  void
> -get_usage_chars(struct lock_class *class, char *c1, char *c2, char *c3, char *c4)
> +get_usage_chars(struct lock_class *class, char *c1, char *c2, char *c3,
> +					char *c4, char *c5, char *c6)
>  {
> -	*c1 = '.', *c2 = '.', *c3 = '.', *c4 = '.';
> +	*c1 = '.', *c2 = '.', *c3 = '.', *c4 = '.', *c5 = '.', *c6 = '.';
>  
>  	if (class->usage_mask & LOCKF_USED_IN_HARDIRQ)
>  		*c1 = '+';
> @@ -493,14 +500,29 @@ get_usage_chars(struct lock_class *class
>  		if (class->usage_mask & LOCKF_ENABLED_SOFTIRQS_READ)
>  			*c4 = '?';
>  	}
> +
> +	if (class->usage_mask & LOCKF_USED_IN_RECLAIM_FS)
> +		*c5 = '+';
> +	else
> +		if (class->usage_mask & LOCKF_HELD_OVER_RECLAIM_FS)
> +			*c5 = '-';
> +
> +	if (class->usage_mask & LOCKF_HELD_OVER_RECLAIM_FS_READ)
> +		*c6 = '-';
> +	if (class->usage_mask & LOCKF_USED_IN_SOFTIRQ_READ) {

s/SOFTIRQ/RECLAIM_FS/

> +		*c6 = '+';
> +		if (class->usage_mask & LOCKF_HELD_OVER_RECLAIM_FS_READ)
> +			*c6 = '?';
> +	}
> +
>  }
>  
>  static void print_lock_name(struct lock_class *class)
>  {
> -	char str[KSYM_NAME_LEN], c1, c2, c3, c4;
> +	char str[KSYM_NAME_LEN], c1, c2, c3, c4, c5, c6;
>  	const char *name;
>  
> -	get_usage_chars(class, &c1, &c2, &c3, &c4);
> +	get_usage_chars(class, &c1, &c2, &c3, &c4, &c5, &c6);
>  
>  	name = class->name;
>  	if (!name) {
> @@ -513,7 +535,7 @@ static void print_lock_name(struct lock_
>  		if (class->subclass)
>  			printk("/%d", class->subclass);
>  	}
> -	printk("){%c%c%c%c}", c1, c2, c3, c4);
> +	printk("){%c%c%c%c%c%c}", c1, c2, c3, c4, c5, c6);
>  }
>  
>  static void print_lockdep_cache(struct lockdep_map *lock)

I think you missed a change to check_prev_add_irq()

> @@ -1949,6 +1971,14 @@ static int softirq_verbose(struct lock_c
>  	return 0;
>  }
>  
> +static int reclaim_verbose(struct lock_class *class)
> +{
> +#if RECLAIM_VERBOSE
> +	return class_filter(class);
> +#endif
> +	return 0;
> +}
> +
>  #define STRICT_READ_CHECKS	1
>  
>  static int mark_lock_irq(struct task_struct *curr, struct held_lock *this,
> @@ -2007,6 +2037,31 @@ static int mark_lock_irq(struct task_str
>  		if (softirq_verbose(hlock_class(this)))
>  			ret = 2;
>  		break;
> +	case LOCK_USED_IN_RECLAIM_FS:
> +		if (!valid_state(curr, this, new_bit, LOCK_HELD_OVER_RECLAIM_FS))
> +			return 0;
> +		if (!valid_state(curr, this, new_bit,
> +				 LOCK_HELD_OVER_RECLAIM_FS_READ))
> +			return 0;
> +		/*
> +		 * just marked it reclaim-fs-safe, check that this lock
> +		 * took no reclaim-fs-unsafe lock in the past:
> +		 */
> +		if (!check_usage_forwards(curr, this,
> +					  LOCK_HELD_OVER_RECLAIM_FS, "reclaim-fs"))
> +			return 0;
> +#if STRICT_READ_CHECKS
> +		/*
> +		 * just marked it reclaim-fs-safe, check that this lock
> +		 * took no reclaim-fs-unsafe-read lock in the past:
> +		 */
> +		if (!check_usage_forwards(curr, this,
> +				LOCK_HELD_OVER_RECLAIM_FS_READ, "reclaim-fs-read"))
> +			return 0;
> +#endif
> +		if (reclaim_verbose(hlock_class(this)))
> +			ret = 2;
> +		break;
>  	case LOCK_USED_IN_HARDIRQ_READ:
>  		if (!valid_state(curr, this, new_bit, LOCK_ENABLED_HARDIRQS))
>  			return 0;
> @@ -2033,6 +2088,19 @@ static int mark_lock_irq(struct task_str
>  		if (softirq_verbose(hlock_class(this)))
>  			ret = 2;
>  		break;
> +	case LOCK_USED_IN_RECLAIM_FS_READ:
> +		if (!valid_state(curr, this, new_bit, LOCK_HELD_OVER_RECLAIM_FS))
> +			return 0;
> +		/*
> +		 * just marked it reclaim-fs-read-safe, check that this lock
> +		 * took no reclaim-fs-unsafe lock in the past:
> +		 */
> +		if (!check_usage_forwards(curr, this,
> +					  LOCK_HELD_OVER_RECLAIM_FS, "reclaim-fs"))
> +			return 0;
> +		if (reclaim_verbose(hlock_class(this)))
> +			ret = 2;
> +		break;
>  	case LOCK_ENABLED_HARDIRQS:
>  		if (!valid_state(curr, this, new_bit, LOCK_USED_IN_HARDIRQ))
>  			return 0;
> @@ -2085,6 +2153,32 @@ static int mark_lock_irq(struct task_str
>  		if (softirq_verbose(hlock_class(this)))
>  			ret = 2;
>  		break;
> +	case LOCK_HELD_OVER_RECLAIM_FS:
> +		if (!valid_state(curr, this, new_bit, LOCK_USED_IN_RECLAIM_FS))
> +			return 0;
> +		if (!valid_state(curr, this, new_bit,
> +				 LOCK_USED_IN_RECLAIM_FS_READ))
> +			return 0;
> +		/*
> +		 * just marked it reclaim-fs-unsafe, check that no reclaim-fs-safe
> +		 * lock in the system ever took it in the past:
> +		 */
> +		if (!check_usage_backwards(curr, this,
> +					   LOCK_USED_IN_RECLAIM_FS, "reclaim-fs"))
> +			return 0;
> +#if STRICT_READ_CHECKS
> +		/*
> +		 * just marked it softirq-unsafe, check that no
> +		 * softirq-safe-read lock in the system ever took
> +		 * it in the past:
> +		 */
> +		if (!check_usage_backwards(curr, this,
> +				   LOCK_USED_IN_RECLAIM_FS_READ, "reclaim-fs-read"))
> +			return 0;
> +#endif
> +		if (reclaim_verbose(hlock_class(this)))
> +			ret = 2;
> +		break;
>  	case LOCK_ENABLED_HARDIRQS_READ:
>  		if (!valid_state(curr, this, new_bit, LOCK_USED_IN_HARDIRQ))
>  			return 0;
> @@ -2115,6 +2209,21 @@ static int mark_lock_irq(struct task_str
>  		if (softirq_verbose(hlock_class(this)))
>  			ret = 2;
>  		break;
> +	case LOCK_HELD_OVER_RECLAIM_FS_READ:
> +		if (!valid_state(curr, this, new_bit, LOCK_USED_IN_RECLAIM_FS))
> +			return 0;
> +#if STRICT_READ_CHECKS
> +		/*
> +		 * just marked it reclaim-fs-read-unsafe, check that no
> +		 * reclaim-fs-safe lock in the system ever took it in the past:
> +		 */
> +		if (!check_usage_backwards(curr, this,
> +					   LOCK_USED_IN_RECLAIM_FS, "reclaim-fs"))
> +			return 0;
> +#endif
> +		if (reclaim_verbose(hlock_class(this)))
> +			ret = 2;
> +		break;
>  	default:
>  		WARN_ON(1);
>  		break;

This function (mark_lock_irq) just begs to be generated, it should
basically read something like this:

#define MARK_LOCK_CASE(__NEW, __EXCL)			\
	case __NEW:					\
		if (!valid_state(,,, __EXCL))		\
			return 0;			\
		if (!valid_state(,,, __EXCL##_READ)) 	\
			return 0;			\
		if (!check_usage_forwards(,, __EXCL))	\
			return 0;			\
		MARK_LOCK_STRICT_READ(__EXCL);		\
		break;					\
	case __NEW##_READ:				\
		if (!valid_state(,,, __EXCL))		\
			return 0;			\
		if (!check_usage_forwards(,, __EXCL))	\
			return 0;			\
		break;

#define MARK_LOCK_IRQ(__STATE)						\
	MARK_LOCK_CASE(LOCK_USED_IN_##__STATE, LOCK_ENABLED_##__STATE)	\
	MARK_LOCK_CASE(LOCK_ENABLED_##__STATE, LOCK_USED_IN_##__STATE)


mark_lock_irq()
{
	switch (new_bit) {
	MARK_LOCK_IRQ(HARDIRQ)
	MARK_LOCK_IRQ(SOFTIRQ)
	MARK_LOCK_IRQ(RECLAIM_FS)
	}
}

You could go one step further and generate more by doing that I did with
sched_features.h, that way you could generate all those flags in
lockdep.h as well, and adding a state is just 1 line in a header.

Lets call it lockdep_state.h

> @@ -2123,11 +2232,17 @@ static int mark_lock_irq(struct task_str
>  	return ret;
>  }
>  
> +enum mark_type {
> +	HARDIRQ,
> +	SOFTIRQ,
> +	RECLAIM_FS,
> +};
> +
>  /*
>   * Mark all held locks with a usage bit:
>   */
>  static int
> -mark_held_locks(struct task_struct *curr, int hardirq)
> +mark_held_locks(struct task_struct *curr, enum mark_type mark)
>  {
>  	enum lock_usage_bit usage_bit;
>  	struct held_lock *hlock;
> @@ -2136,17 +2251,32 @@ mark_held_locks(struct task_struct *curr
>  	for (i = 0; i < curr->lockdep_depth; i++) {
>  		hlock = curr->held_locks + i;
>  
> -		if (hardirq) {
> +		switch (mark) {
> +		case HARDIRQ:
>  			if (hlock->read)
>  				usage_bit = LOCK_ENABLED_HARDIRQS_READ;
>  			else
>  				usage_bit = LOCK_ENABLED_HARDIRQS;
> -		} else {
> +			break;
> +
> +		case SOFTIRQ:
>  			if (hlock->read)
>  				usage_bit = LOCK_ENABLED_SOFTIRQS_READ;
>  			else
>  				usage_bit = LOCK_ENABLED_SOFTIRQS;
> +			break;
> +
> +		case RECLAIM_FS:
> +			if (hlock->read)
> +				usage_bit = LOCK_HELD_OVER_RECLAIM_FS_READ;
> +			else
> +				usage_bit = LOCK_HELD_OVER_RECLAIM_FS;
> +			break;

Would then read something like:

#define LOCKDEP_STATE(__STATE)					\
case __STATE:							\
	if (hlock->read)					\
		usage_bit = LOCK_ENABLED_##__STATE##_READ;	\
	else							\
		usage_bit = LOCK_ENABLED_##__STATE;

#include "lockdep_state.h"
#undef LOCKDEP_STATE

> +		default:
> +			BUG();
>  		}
> +
>  		if (!mark_lock(curr, hlock, usage_bit))
>  			return 0;
>  	}
> @@ -2200,7 +2330,7 @@ void trace_hardirqs_on_caller(unsigned l
>  	 * We are going to turn hardirqs on, so set the
>  	 * usage bit for all held locks:
>  	 */
> -	if (!mark_held_locks(curr, 1))
> +	if (!mark_held_locks(curr, HARDIRQ))
>  		return;
>  	/*
>  	 * If we have softirqs enabled, then set the usage
> @@ -2208,7 +2338,7 @@ void trace_hardirqs_on_caller(unsigned l
>  	 * this bit from being set before)
>  	 */
>  	if (curr->softirqs_enabled)
> -		if (!mark_held_locks(curr, 0))
> +		if (!mark_held_locks(curr, SOFTIRQ))
>  			return;
>  
>  	curr->hardirq_enable_ip = ip;
> @@ -2288,7 +2418,7 @@ void trace_softirqs_on(unsigned long ip)
>  	 * enabled too:
>  	 */
>  	if (curr->hardirqs_enabled)
> -		mark_held_locks(curr, 0);
> +		mark_held_locks(curr, SOFTIRQ);
>  }
>  
>  /*
> @@ -2317,6 +2447,18 @@ void trace_softirqs_off(unsigned long ip
>  		debug_atomic_inc(&redundant_softirqs_off);
>  }
>  
> +void trace_reclaim_fs(void)
> +{
> +	struct task_struct *curr = current;
> +
> +	if (unlikely(!debug_locks))
> +		return;
> +	if (DEBUG_LOCKS_WARN_ON(irqs_disabled()))
> +		return;
> +
> +	mark_held_locks(curr, RECLAIM_FS);
> +}
> +
>  static int mark_irqflags(struct task_struct *curr, struct held_lock *hlock)
>  {
>  	/*
> @@ -2362,6 +2504,22 @@ static int mark_irqflags(struct task_str
>  		}
>  	}
>  
> +	/*
> +	 * We reuse the irq context infrastructure more broadly as a general
> +	 * context checking code. This tests GFP_FS recursion (a lock taken
> +	 * during reclaim for a GFP_FS allocation is held over a GFP_FS
> +	 * allocation).
> +	 */
> +	if (!hlock->trylock && test_bit(LOCKDEP_PF_RECLAIM_FS_BIT,
> +							&curr->lockdep_flags)) {
> +		if (hlock->read)
> +			if (!mark_lock(curr, hlock, LOCK_USED_IN_RECLAIM_FS_READ))
> +					return 0;
> +		else
> +			if (!mark_lock(curr, hlock, LOCK_USED_IN_RECLAIM_FS))
> +					return 0;
> +	}
> +
>  	return 1;
>  }
>  
> @@ -2453,6 +2611,10 @@ static int mark_lock(struct task_struct 
>  	case LOCK_ENABLED_SOFTIRQS:
>  	case LOCK_ENABLED_HARDIRQS_READ:
>  	case LOCK_ENABLED_SOFTIRQS_READ:
> +	case LOCK_USED_IN_RECLAIM_FS:
> +	case LOCK_USED_IN_RECLAIM_FS_READ:
> +	case LOCK_HELD_OVER_RECLAIM_FS:
> +	case LOCK_HELD_OVER_RECLAIM_FS_READ:

#define LOCKDEP_STATE(__STATE)			\
	case LOCK_USED_IN_##__STATE:		\
	case LOCK_USED_IN_##__STATE##_READ:	\
	case LOCK_ENABLED_##__STATE:		\
	case LOCK_ENABLED_##__STATE##_READ:
#include "lockdep_state.h"
#undef LOCKDEP_STATE

>  		ret = mark_lock_irq(curr, this, new_bit);
>  		if (!ret)
>  			return 0;
> Index: linux-2.6/mm/page_alloc.c
> ===================================================================
> --- linux-2.6.orig/mm/page_alloc.c	2009-01-20 18:36:58.000000000 +1100
> +++ linux-2.6/mm/page_alloc.c	2009-01-20 18:37:50.000000000 +1100
> @@ -1479,6 +1479,11 @@ __alloc_pages_internal(gfp_t gfp_mask, u
>  	unsigned long did_some_progress;
>  	unsigned long pages_reclaimed = 0;
>  
> +#ifdef CONFIG_LOCKDEP
> +	if ((gfp_mask & (__GFP_WAIT|__GFP_FS)) == (__GFP_WAIT|__GFP_FS) && !(p->flags & PF_MEMALLOC))
> +		trace_reclaim_fs();
> +#endif
> +
>  	might_sleep_if(wait);
>  
>  	if (should_fail_alloc_page(gfp_mask, order))
> @@ -1578,12 +1583,20 @@ nofail_alloc:
>  	 */
>  	cpuset_update_task_memory_state();
>  	p->flags |= PF_MEMALLOC;
> +#ifdef CONFIG_LOCKDEP
> +	if ((gfp_mask & (__GFP_WAIT|__GFP_FS)) == (__GFP_WAIT|__GFP_FS))
> +		set_bit(LOCKDEP_PF_RECLAIM_FS_BIT, &p->lockdep_flags);
> +#endif

it's impossible to get here without __GFP_WAIT.

>  	reclaim_state.reclaimed_slab = 0;
>  	p->reclaim_state = &reclaim_state;
>  
>  	did_some_progress = try_to_free_pages(zonelist, order, gfp_mask);
>  
>  	p->reclaim_state = NULL;
> +#ifdef CONFIG_LOCKDEP
> +	if ((gfp_mask & (__GFP_WAIT|__GFP_FS)) == (__GFP_WAIT|__GFP_FS))
> +		clear_bit(LOCKDEP_PF_RECLAIM_FS_BIT, &p->lockdep_flags);
> +#endif
>  	p->flags &= ~PF_MEMALLOC;
>  
>  	cond_resched();

#ifdef CONFIG_PROVE_LOCKING
static inline void lockdep_set_gfp_state(gfp_t gfp_mask)
{
	current->lockdep_gfp = gfp_mask;
}

static inline void lockdep_clear_gfp_state(void)
{
	current->lockdep_gfp = 0;
}
#else
static inline void lockdep_set_gfp_state(gfp_t gfp_mask)
{
}

static inline void lockdep_clear_gfp_state(void)
{
}
#endif

?

Maybe also a lockdep_trace_gfp(gfp_t), hmm?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
