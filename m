Date: Fri, 21 Sep 2007 16:15:53 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] hotplug cpu: move tasks in empty cpusets to parent
In-Reply-To: <20070921225327.692FE149779@attica.americas.sgi.com>
Message-ID: <alpine.DEB.0.9999.0709211607180.19770@chino.kir.corp.google.com>
References: <20070921225327.692FE149779@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Cliff Wickman <cpw@sgi.com>
Cc: akpm@linux-foundation.org, pj@sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 21 Sep 2007, Cliff Wickman wrote:

> This patch corrects a situation that occurs when one disables all the cpus
> in a cpuset.
> 
> Currently, the disabled (cpu-less) cpuset inherits the cpus of its parent,
> which may overlap its exclusive sibling.
> (You will get non-removable cpusets -- "Invalid argument")
> 
> Tasks of an empty cpuset should be moved to the cpuset which is the parent
> of their current cpuset. Or if the parent cpuset has no cpus, to its
> parent, etc.
> 
> And the empty cpuset should be removed (if it is flagged notify_on_release).
> 

Again, being flagged notify_on_release does not remove the empty cpuset, 
it simply calls a userspace agent to do cleanup, if such a userspace agent 
exists and notify_on_release is enabled.

Inline comments below.

> Index: linus.070921/kernel/cpuset.c
> ===================================================================
> --- linus.070921.orig/kernel/cpuset.c
> +++ linus.070921/kernel/cpuset.c
> @@ -52,6 +52,8 @@
>  #include <asm/uaccess.h>
>  #include <asm/atomic.h>
>  #include <linux/mutex.h>
> +#include <linux/kfifo.h>
> +#include <linux/workqueue.h>
>  
>  #define CPUSET_SUPER_MAGIC		0x27e0eb
>  
> @@ -109,6 +111,7 @@ typedef enum {
>  	CS_NOTIFY_ON_RELEASE,
>  	CS_SPREAD_PAGE,
>  	CS_SPREAD_SLAB,
> +	CS_RELEASED_RESOURCE,
>  } cpuset_flagbits_t;
>  
>  /* convenient tests for these bits */
> @@ -147,6 +150,11 @@ static inline int is_spread_slab(const s
>  	return test_bit(CS_SPREAD_SLAB, &cs->flags);
>  }
>  
> +static inline int has_released_a_resource(const struct cpuset *cs)
> +{
> +	return test_bit(CS_RELEASED_RESOURCE, &cs->flags);
> +}
> +
>  /*
>   * Increment this integer everytime any cpuset changes its
>   * mems_allowed value.  Users of cpusets can track this generation
> @@ -541,7 +549,7 @@ static void cpuset_release_agent(const c
>  static void check_for_release(struct cpuset *cs, char **ppathbuf)
>  {
>  	if (notify_on_release(cs) && atomic_read(&cs->count) == 0 &&
> -	    list_empty(&cs->children)) {
> +					list_empty(&cs->children)) {
>  		char *buf;
>  
>  		buf = kmalloc(PAGE_SIZE, GFP_KERNEL);

Unnecessary change.

> @@ -1265,6 +1273,7 @@ static int attach_task(struct cpuset *cs
>  
>  	from = oldcs->mems_allowed;
>  	to = cs->mems_allowed;
> +	set_bit(CS_RELEASED_RESOURCE, &oldcs->flags);
>  
>  	mutex_unlock(&callback_mutex);
>  
> @@ -1995,6 +2004,7 @@ static int cpuset_rmdir(struct inode *un
>  	cpuset_d_remove_dir(d);
>  	dput(d);
>  	number_of_cpusets--;
> +	set_bit(CS_RELEASED_RESOURCE, &parent->flags);
>  	mutex_unlock(&callback_mutex);
>  	if (list_empty(&parent->children))
>  		check_for_release(parent, &pathbuf);
> @@ -2062,50 +2072,180 @@ out:
>  }
>  
>  /*
> + * Move every task that is a member of cpuset "from" to cpuset "to".
> + *
> + * Called with both manage_sem and callback_sem held
> + */
> +static void move_member_tasks_to_cpuset(struct cpuset *from, struct cpuset *to)
> +{
> +	int moved=0;
> +	struct task_struct *g, *tsk;
> +
> +	read_lock(&tasklist_lock);
> +	do_each_thread(g, tsk) {
> +		if (tsk->cpuset == from) {
> +			moved++;
> +			task_lock(tsk);
> +			tsk->cpuset = to;
> +			task_unlock(tsk);
> +		}
> +	} while_each_thread(g, tsk);
> +	read_unlock(&tasklist_lock);
> +	atomic_add(moved, &to->count);
> +	atomic_set(&from->count, 0);
> +}
> +

This isn't that simple.  You're missing mpol_rebind_mm() checks, updating 
tsk->mems_allowed, etc.  It's much easier to make 
remove_tasks_in_empty_cpuset() a client of attach_task() by supplying 
pids; this would make it the only function where cpuset assignment 
changes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
