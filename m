Date: Wed, 12 Sep 2007 05:30:22 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 09 of 24] fallback killing more tasks if tif-memdie
 doesn't go away
Message-Id: <20070912053022.b7d152c3.akpm@linux-foundation.org>
In-Reply-To: <9bf6a66eab3c52327daa.1187786936@v2.random>
References: <patchbomb.1187786927@v2.random>
	<9bf6a66eab3c52327daa.1187786936@v2.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Wed, 22 Aug 2007 14:48:56 +0200 Andrea Arcangeli <andrea@suse.de> wrote:

> # HG changeset patch
> # User Andrea Arcangeli <andrea@suse.de>
> # Date 1187778125 -7200
> # Node ID 9bf6a66eab3c52327daa831ef101d7802bc71791
> # Parent  ffdc30241856d7155ceedd4132eef684f7cc7059
> fallback killing more tasks if tif-memdie doesn't go away
> 
> Waiting indefinitely for a TIF_MEMDIE task to go away will deadlock. Two
> tasks reading from the same inode at the same time and both going out of
> memory inside a read(largebuffer) syscall, will even deadlock through
> contention over the PG_locked bitflag. The task holding the semaphore
> detects oom but the oom killer decides to kill the task blocked in
> wait_on_page_locked(). The task holding the semaphore will hang inside
> alloc_pages that will never return because it will wait the TIF_MEMDIE
> task to go away, but the TIF_MEMDIE task can't go away until the task
> holding the semaphore is killed in the first place.

hrm, OK, that's not nice

> It's quite unpractical to teach the oom killer the locking dependencies
> across running tasks, so the feasible fix is to develop a logic that
> after waiting a long time for a TIF_MEMDIE tasks goes away, fallbacks
> on killing one more task. This also eliminates the possibility of
> suprious oom killage (i.e. two tasks killed despite only one had to be
> killed). It's not a math guarantee because we can't demonstrate that if
> a TIF_MEMDIE SIGKILLED task didn't mange to complete do_exit within
> 10sec, it never will. But the current probability of suprious oom
> killing is sure much higher than the probability of suprious oom killing
> with this patch applied.
> 
> The whole locking is around the tasklist_lock. On one side do_exit reads
> TIF_MEMDIE and clears VM_is_OOM under the lock, on the other side the
> oom killer accesses VM_is_OOM and TIF_MEMDIE under the lock. This is a
> read_lock in the oom killer but it's actually a write lock thanks to the
> OOM_lock semaphore running one oom killer at once (the locking rule is,
> either use write_lock_irq or read_lock+OOM_lock).
> 


> 
> diff --git a/kernel/exit.c b/kernel/exit.c
> --- a/kernel/exit.c
> +++ b/kernel/exit.c
> @@ -849,6 +849,15 @@ static void exit_notify(struct task_stru
>  	if (tsk->exit_signal == -1 && likely(!tsk->ptrace))
>  		state = EXIT_DEAD;
>  	tsk->exit_state = state;
> +
> +	/*
> +	 * Read TIF_MEMDIE and set VM_is_OOM to 0 atomically inside
> +	 * the tasklist_lock_lock.
> +	 */
> +	if (unlikely(test_tsk_thread_flag(tsk, TIF_MEMDIE))) {
> +		extern unsigned long VM_is_OOM;
> +		clear_bit(0, &VM_is_OOM);
> +	}

Please, no externs-in-C, ever.

>  	write_unlock_irq(&tasklist_lock);
>  
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -29,6 +29,9 @@ int sysctl_panic_on_oom;
>  int sysctl_panic_on_oom;
>  /* #define DEBUG */
>  
> +unsigned long VM_is_OOM;

what's with the studlycaps, btw?

> +static unsigned long last_tif_memdie_jiffies;
> +
>  /**
>   * badness - calculate a numeric value for how bad this task has been
>   * @p: task struct of which task we should calculate
> @@ -226,21 +229,14 @@ static struct task_struct *select_bad_pr
>  		if (is_init(p))
>  			continue;
>  
> -		/*
> -		 * This task already has access to memory reserves and is
> -		 * being killed. Don't allow any other task access to the
> -		 * memory reserve.
> -		 *
> -		 * Note: this may have a chance of deadlock if it gets
> -		 * blocked waiting for another task which itself is waiting
> -		 * for memory. Is there a better alternative?
> -		 *
> -		 * Better not to skip PF_EXITING tasks, since they
> -		 * don't have access to the PF_MEMALLOC pool until
> -		 * we select them here first.
> -		 */
> -		if (test_tsk_thread_flag(p, TIF_MEMDIE))
> -			return ERR_PTR(-1UL);
> +		if (unlikely(test_tsk_thread_flag(p, TIF_MEMDIE))) {
> +			/*
> +			 * Either we already waited long enough,
> +			 * or exit_mm already run, so we must
> +			 * try to kill another task.
> +			 */
> +			continue;
> +		}
>  
>  		if (p->oomkilladj == OOM_DISABLE)
>  			continue;
> @@ -277,13 +273,16 @@ static void __oom_kill_task(struct task_
>  	if (verbose)
>  		printk(KERN_ERR "Killed process %d (%s)\n", p->pid, p->comm);
>  
> +	if (!test_and_set_tsk_thread_flag(p, TIF_MEMDIE)) {
> +		last_tif_memdie_jiffies = jiffies;
> +		set_bit(0, &VM_is_OOM);
> +	}

Do we actually need the bitops?  Wouldn't a simple old foo=0 suffice here??

>  	/*
>  	 * We give our sacrificial lamb high priority and access to
>  	 * all the memory it needs. That way it should be able to
>  	 * exit() and clear out its resources quickly...
>  	 */
>  	p->time_slice = HZ;
> -	set_tsk_thread_flag(p, TIF_MEMDIE);
>  
>  	force_sig(SIGKILL, p);
>  }
> @@ -420,6 +419,18 @@ void out_of_memory(struct zonelist *zone
>  	constraint = constrained_alloc(zonelist, gfp_mask);
>  	cpuset_lock();
>  	read_lock(&tasklist_lock);
> +
> +	/*
> +	 * This holds the down(OOM_lock)+read_lock(tasklist_lock), so it's
> +	 * equivalent to write_lock_irq(tasklist_lock) as far as VM_is_OOM
> +	 * is concerned.
> +	 */
> +	if (unlikely(test_bit(0, &VM_is_OOM))) {
> +		if (time_before(jiffies, last_tif_memdie_jiffies + 10*HZ))
> +			goto out;
> +		printk("detected probable OOM deadlock, so killing another task\n");

Please include a facility level in all printks

> +		last_tif_memdie_jiffies = jiffies;
> +	}
>  
>  	switch (constraint) {
>  	case CONSTRAINT_MEMORY_POLICY:
> @@ -441,10 +452,6 @@ retry:
>  		 * issues we may have.
>  		 */
>  		p = select_bad_process(&points);
> -
> -		if (PTR_ERR(p) == -1UL)
> -			goto out;
>  		/* Found nothing?!?! Either we hang forever, or we panic. */
>  		if (!p) {
>  			read_unlock(&tasklist_lock);

Something like this...


 include/linux/swap.h |    1 +
 kernel/exit.c        |   11 +++++------
 mm/oom_kill.c        |   11 ++++++-----
 3 files changed, 12 insertions(+), 11 deletions(-)

diff -puN kernel/exit.c~oom-handling-fallback-killing-more-tasks-if-tif-memdie-doesnt-go-away-fix kernel/exit.c
--- a/kernel/exit.c~oom-handling-fallback-killing-more-tasks-if-tif-memdie-doesnt-go-away-fix
+++ a/kernel/exit.c
@@ -30,6 +30,7 @@
 #include <linux/kthread.h>
 #include <linux/mempolicy.h>
 #include <linux/taskstats_kern.h>
+#include <linux/swap.h>
 #include <linux/delayacct.h>
 #include <linux/freezer.h>
 #include <linux/cpuset.h>
@@ -851,13 +852,11 @@ static void exit_notify(struct task_stru
 	tsk->exit_state = state;
 
 	/*
-	 * Read TIF_MEMDIE and set VM_is_OOM to 0 atomically inside
-	 * the tasklist_lock_lock.
+	 * Read TIF_MEMDIE and set vm_is_oom to 0 atomically inside
+	 * the tasklist_lock.
 	 */
-	if (unlikely(test_tsk_thread_flag(tsk, TIF_MEMDIE))) {
-		extern unsigned long VM_is_OOM;
-		clear_bit(0, &VM_is_OOM);
-	}
+	if (unlikely(test_tsk_thread_flag(tsk, TIF_MEMDIE)))
+		clear_bit(0, &vm_is_oom);
 
 	write_unlock_irq(&tasklist_lock);
 
diff -puN mm/oom_kill.c~oom-handling-fallback-killing-more-tasks-if-tif-memdie-doesnt-go-away-fix mm/oom_kill.c
--- a/mm/oom_kill.c~oom-handling-fallback-killing-more-tasks-if-tif-memdie-doesnt-go-away-fix
+++ a/mm/oom_kill.c
@@ -29,7 +29,7 @@
 int sysctl_panic_on_oom;
 /* #define DEBUG */
 
-unsigned long VM_is_OOM;
+unsigned long vm_is_oom;
 static unsigned long last_tif_memdie_jiffies;
 
 /**
@@ -268,7 +268,7 @@ static void __oom_kill_task(struct task_
 
 	if (!test_and_set_tsk_thread_flag(p, TIF_MEMDIE)) {
 		last_tif_memdie_jiffies = jiffies;
-		set_bit(0, &VM_is_OOM);
+		set_bit(0, &vm_is_oom);
 	}
 	/*
 	 * We give our sacrificial lamb high priority and access to
@@ -415,13 +415,14 @@ void out_of_memory(struct zonelist *zone
 
 	/*
 	 * This holds the down(OOM_lock)+read_lock(tasklist_lock), so it's
-	 * equivalent to write_lock_irq(tasklist_lock) as far as VM_is_OOM
+	 * equivalent to write_lock_irq(tasklist_lock) as far as vm_is_oom
 	 * is concerned.
 	 */
-	if (unlikely(test_bit(0, &VM_is_OOM))) {
+	if (unlikely(test_bit(0, &
 		if (time_before(jiffies, last_tif_memdie_jiffies + 10*HZ))
 			goto out;
-		printk("detected probable OOM deadlock, so killing another task\n");
+		printk(KERN_ERR "detected probable OOM deadlock, so killing "
+				"another task\n");
 		last_tif_memdie_jiffies = jiffies;
 	}
 
diff -puN include/linux/swap.h~oom-handling-fallback-killing-more-tasks-if-tif-memdie-doesnt-go-away-fix include/linux/swap.h
--- a/include/linux/swap.h~oom-handling-fallback-killing-more-tasks-if-tif-memdie-doesnt-go-away-fix
+++ a/include/linux/swap.h
@@ -209,6 +209,7 @@ static inline int zone_reclaim(struct zo
 #endif
 
 extern int kswapd_run(int nid);
+extern unsigned long vm_is_oom;
 
 #ifdef CONFIG_MMU
 /* linux/mm/shmem.c */
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
