Date: Fri, 21 Sep 2007 16:04:36 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: + oom-do-not-take-callback_mutex-fix.patch added to -mm tree
In-Reply-To: <200709212228.l8LMSe9X026574@imap1.linux-foundation.org>
Message-ID: <alpine.DEB.0.9999.0709211600000.19770@chino.kir.corp.google.com>
References: <200709212228.l8LMSe9X026574@imap1.linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Cliff Wickman <cpw@sgi.com>
Cc: Oleg Nesterov <oleg@tv-sign.ru>, Christoph Lameter <clameter@sgi.com>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 21 Sep 2007, akpm@linux-foundation.org wrote:

> The patch titled
>      oom-do-not-take-callback_mutex-fix
> has been added to the -mm tree.  Its filename is
>      oom-do-not-take-callback_mutex-fix.patch
> 
> *** Remember to use Documentation/SubmitChecklist when testing your code ***
> 
> See http://www.zip.com.au/~akpm/linux/patches/stuff/added-to-mm.txt to find
> out what to do about this
> 
> ------------------------------------------------------
> Subject: oom-do-not-take-callback_mutex-fix
> From: Andrew Morton <akpm@linux-foundation.org>
> 
> put this back - hotplug-cpu-migrate-a-task-within-its-cpuset.patch uses it.
> 
> Cc: Andrea Arcangeli <andrea@suse.de>
> Cc: Christoph Lameter <clameter@sgi.com>
> Cc: David Rientjes <rientjes@google.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  include/linux/cpuset.h |    6 ++++++
>  kernel/cpuset.c        |   27 +++++++++++++++++++++++++++
>  2 files changed, 33 insertions(+)
> 
> diff -puN include/linux/cpuset.h~oom-do-not-take-callback_mutex-fix include/linux/cpuset.h
> --- a/include/linux/cpuset.h~oom-do-not-take-callback_mutex-fix
> +++ a/include/linux/cpuset.h
> @@ -59,6 +59,9 @@ extern void __cpuset_memory_pressure_bum
>  extern const struct file_operations proc_cpuset_operations;
>  extern char *cpuset_task_status_allowed(struct task_struct *task, char *buffer);
>  
> +extern void cpuset_lock(void);
> +extern void cpuset_unlock(void);
> +
>  extern int cpuset_mem_spread_node(void);
>  
>  static inline int cpuset_do_page_mem_spread(void)
> @@ -125,6 +128,9 @@ static inline char *cpuset_task_status_a
>  	return buffer;
>  }
>  
> +static inline void cpuset_lock(void) {}
> +static inline void cpuset_unlock(void) {}
> +
>  static inline int cpuset_mem_spread_node(void)
>  {
>  	return 0;
> diff -puN kernel/cpuset.c~oom-do-not-take-callback_mutex-fix kernel/cpuset.c
> --- a/kernel/cpuset.c~oom-do-not-take-callback_mutex-fix
> +++ a/kernel/cpuset.c
> @@ -2521,6 +2521,33 @@ int __cpuset_zone_allowed_hardwall(struc
>  }
>  
>  /**
> + * cpuset_lock - lock out any changes to cpuset structures
> + *
> + * The out of memory (oom) code needs to mutex_lock cpusets
> + * from being changed while it scans the tasklist looking for a
> + * task in an overlapping cpuset.  Expose callback_mutex via this
> + * cpuset_lock() routine, so the oom code can lock it, before
> + * locking the task list.  The tasklist_lock is a spinlock, so
> + * must be taken inside callback_mutex.
> + */
> +
> +void cpuset_lock(void)
> +{
> +	mutex_lock(&callback_mutex);
> +}
> +
> +/**
> + * cpuset_unlock - release lock on cpuset changes
> + *
> + * Undo the lock taken in a previous cpuset_lock() call.
> + */
> +
> +void cpuset_unlock(void)
> +{
> +	mutex_unlock(&callback_mutex);
> +}
> +
> +/**
>   * cpuset_mem_spread_node() - On which node to begin search for a page
>   *
>   * If a task is marked PF_SPREAD_PAGE or PF_SPREAD_SLAB (as for

In reference to hotplug-cpu-migrate-a-task-within-its-cpuset.patch from 
-mm:

I don't understand how cpuset_cpus_allowed_locked(struct task_struct *tsk) 
can't block if it spins on tsk->alloc_lock.  If that spinlock will never 
block here, and that can be proven, it should be exported back up to 
cpuset_cpus_allowed() nested around taking callback_mutex.

Cliff?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
