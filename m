Date: Thu, 18 Aug 2005 21:29:39 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [RFC] Concept for delayed counter updates in mm_struct
Message-Id: <20050818212939.7dca44c3.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.62.0508182052120.10236@schroedinger.engr.sgi.com>
References: <20050817151723.48c948c7.akpm@osdl.org>
	<20050817174359.0efc7a6a.akpm@osdl.org>
	<Pine.LNX.4.61.0508182116110.11409@goblin.wat.veritas.com>
	<Pine.LNX.4.62.0508182052120.10236@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: hugh@veritas.com, torvalds@osdl.org, nickpiggin@yahoo.com.au, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter <clameter@engr.sgi.com> wrote:
>
> I think there may be an easier way of avoiding atomic increments
> if the page_table_lock is not used than methods that I had proposed last 
> year (building lists of task_structs).
> 
> If we keep deltas in the task_struct then we can at some later point add 
> those to an mm_struct (via calling mm_counter_catchup(mm).
> 
> The main problem in the past with using current for rss information were 
> primarily concerns with get_user_pages(). I hope that the approach here 
> solves the issues neatly. get_user_pages() first shifts any deltas into 
> the current->mm. Then it does the handle_mm_fault() thing which may 
> accumulate new deltas in current. These are stuffed into the target mm 
> after the page_table_lock has been acquired.
> 
> What is missing in this patch are points were mm_counter_catchup can be called.
> These points must be code where the page table lock is held. One way of providing
> these would be to call mm_counter_catchup when a task is in the scheduler.
> 

That sounds sane.

> 
> Index: linux-2.6.13-rc6/kernel/fork.c
> ===================================================================
> --- linux-2.6.13-rc6.orig/kernel/fork.c	2005-08-18 18:10:28.000000000 -0700
> +++ linux-2.6.13-rc6/kernel/fork.c	2005-08-18 20:34:14.000000000 -0700
> @@ -173,6 +173,9 @@ static struct task_struct *dup_task_stru
>  	*tsk = *orig;
>  	tsk->thread_info = ti;
>  	ti->task = tsk;
> +	tsk->delta_rss = 0;
> +	tsk->delta_anon_rss = 0;
> +	tsk->delta_nr_ptes = 0;
>  
>  	/* One for us, one for whoever does the "release_task()" (usually parent) */
>  	atomic_set(&tsk->usage,2);
> Index: linux-2.6.13-rc6/include/linux/sched.h
> ===================================================================
> --- linux-2.6.13-rc6.orig/include/linux/sched.h	2005-08-18 18:10:28.000000000 -0700
> +++ linux-2.6.13-rc6/include/linux/sched.h	2005-08-18 20:15:50.000000000 -0700
> @@ -604,6 +604,15 @@ struct task_struct {
>  	unsigned long flags;	/* per process flags, defined below */
>  	unsigned long ptrace;
>  
> +	/*
> +	 * The counters in the mm_struct require the page table lock
> +	 * These deltas here accumulate changes that are later folded
> +	 * into the corresponding mm_struct counters
> +	 */
> +	long delta_rss;
> +	long delta_anon_rss;
> +	long delta_nr_ptes;
> +
>  	int lock_depth;		/* BKL lock depth */
>  
>  #if defined(CONFIG_SMP) && defined(__ARCH_WANT_UNLOCKED_CTXSW)
> @@ -1347,6 +1356,23 @@ static inline void thaw_processes(void) 
>  static inline int try_to_freeze(void) { return 0; }
>  
>  #endif /* CONFIG_PM */
> +
> +/*
> + * Update mm_struct counters with deltas from task_struct.
> + * Must be called with the page_table_lock held.
> + */
> +inline static void mm_counter_catchup(struct mm_struct *mm)

`static inline', please.

> +{
> +	if (unlikely(current->delta_rss | current->delta_anon_rss | current->delta_nr_ptes)) {
> +		add_mm_counter(mm, rss, current->delta_rss);
> +		add_mm_counter(mm, anon_rss, current->delta_anon_rss);
> +		add_mm_counter(mm, nr_ptes, current->delta_nr_ptes);
> +		current->delta_rss = 0;
> +		current->delta_anon_rss = 0;
> +		current->delta_nr_ptes = 0;
> +	}
> +}

This looks way too big to be inlined.

Also, evaluation of `current' takes ~14 bytes of code on x86 and sometimes
the compiler doesn't CSE it.  This is why we often do

	struct task_struct *tsk = current;

	<use tsk>

> +	if (mm != current->mm) {
> +		/* Insure that there are no deltas for current->mm */

"Ensure" ;)

> @@ -989,6 +996,12 @@ int get_user_pages(struct task_struct *t
>  					BUG();
>  				}
>  				spin_lock(&mm->page_table_lock);
> +				/*
> +				 * Update any counters in the mm handled so that
> +				 * they are not reflected in the mm of the running
> +				 * process
> +				 */

Is ptrace->get_user_pages() the only place where one process pokes
at another process's memory?  I think so..
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
