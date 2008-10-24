Date: Fri, 24 Oct 2008 03:28:31 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [RFC][PATCH] lru_add_drain_all() don't use schedule_on_each_cpu()
Message-ID: <20081024012831.GE5004@wotan.suse.de>
References: <2f11576a0810210851g6e0d86benef5d801871886dd7@mail.gmail.com> <2f11576a0810211018g5166c1byc182f1194cfdd45d@mail.gmail.com> <20081023235425.9C40.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081023235425.9C40.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>, linux-kernel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, Oct 24, 2008 at 12:00:17AM +0900, KOSAKI Motohiro wrote:
> It because following three circular locking dependency.
> 
> Some VM place has
>       mmap_sem -> kevent_wq via lru_add_drain_all()
> 
> net/core/dev.c::dev_ioctl()  has
>      rtnl_lock  ->  mmap_sem        (*) the ioctl has copy_from_user() and it can do page fault.
> 
> linkwatch_event has
>      kevent_wq -> rtnl_lock
> 
> 
> Actually, schedule_on_each_cpu() is very problematic function.
> it introduce the dependency of all worker on keventd_wq, 
> but we can't know what lock held by worker in kevend_wq because
> keventd_wq is widely used out of kernel drivers too.
> 
> So, the task of any lock held shouldn't wait on keventd_wq.
> Its task should use own special purpose work queue.

I don't see a better way to solve it, other than avoiding lru_add_drain_all


> 
> 
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Reported-by: Heiko Carstens <heiko.carstens@de.ibm.com>
> CC: Christoph Lameter <cl@linux-foundation.org>
> CC: Nick Piggin <npiggin@suse.de>
> CC: Hugh Dickins <hugh@veritas.com>,
> CC: Andrew Morton <akpm@linux-foundation.org>,
> CC: Linus Torvalds <torvalds@linux-foundation.org>,
> CC: Rik van Riel <riel@redhat.com>,
> CC: Lee Schermerhorn <lee.schermerhorn@hp.com>,
> 
>  linux-2.6.27-git10-vm_wq/include/linux/workqueue.h |    1 
>  linux-2.6.27-git10-vm_wq/kernel/workqueue.c        |   37 +++++++++++++++++++++
>  linux-2.6.27-git10-vm_wq/mm/swap.c                 |    8 +++-
>  3 files changed, 45 insertions(+), 1 deletion(-)
> 
> Index: linux-2.6.27-git10-vm_wq/include/linux/workqueue.h
> ===================================================================
> --- linux-2.6.27-git10-vm_wq.orig/include/linux/workqueue.h	2008-10-23 21:01:38.000000000 +0900
> +++ linux-2.6.27-git10-vm_wq/include/linux/workqueue.h	2008-10-23 22:34:20.000000000 +0900
> @@ -195,6 +195,7 @@ extern int schedule_delayed_work(struct 
>  extern int schedule_delayed_work_on(int cpu, struct delayed_work *work,
>  					unsigned long delay);
>  extern int schedule_on_each_cpu(work_func_t func);
> +int queue_work_on_each_cpu(struct workqueue_struct *wq, work_func_t func);
>  extern int current_is_keventd(void);
>  extern int keventd_up(void);
>  
> Index: linux-2.6.27-git10-vm_wq/kernel/workqueue.c
> ===================================================================
> --- linux-2.6.27-git10-vm_wq.orig/kernel/workqueue.c	2008-10-23 21:01:38.000000000 +0900
> +++ linux-2.6.27-git10-vm_wq/kernel/workqueue.c	2008-10-23 22:34:20.000000000 +0900
> @@ -674,6 +674,8 @@ EXPORT_SYMBOL(schedule_delayed_work_on);
>   * Returns -ve errno on failure.
>   *
>   * schedule_on_each_cpu() is very slow.
> + * caller should NOT held any lock, otherwise flush_work(keventd_wq) can
> + * cause dead-lock.
>   */
>  int schedule_on_each_cpu(work_func_t func)
>  {
> @@ -698,6 +700,41 @@ int schedule_on_each_cpu(work_func_t fun
>  	return 0;
>  }
>  
> +/**
> + * queue_work_on_each_cpu - call a function on each online CPU
> + *
> + * @wq:   the workqueue
> + * @func: the function to call
> + *
> + * Returns zero on success.
> + * Returns -ve errno on failure.
> + *
> + * similar to schedule_on_each_cpu(), but wq argument is there.
> + * queue_work_on_each_cpu() is very slow.
> + */
> +int queue_work_on_each_cpu(struct workqueue_struct *wq, work_func_t func)
> +{
> +	int cpu;
> +	struct work_struct *works;
> +
> +	works = alloc_percpu(struct work_struct);
> +	if (!works)
> +		return -ENOMEM;
> +
> +	get_online_cpus();
> +	for_each_online_cpu(cpu) {
> +		struct work_struct *work = per_cpu_ptr(works, cpu);
> +
> +		INIT_WORK(work, func);
> +		queue_work_on(cpu, wq, work);
> +	}
> +	for_each_online_cpu(cpu)
> +		flush_work(per_cpu_ptr(works, cpu));
> +	put_online_cpus();
> +	free_percpu(works);
> +	return 0;
> +}
> +
>  void flush_scheduled_work(void)
>  {
>  	flush_workqueue(keventd_wq);
> Index: linux-2.6.27-git10-vm_wq/mm/swap.c
> ===================================================================
> --- linux-2.6.27-git10-vm_wq.orig/mm/swap.c	2008-10-23 21:01:38.000000000 +0900
> +++ linux-2.6.27-git10-vm_wq/mm/swap.c	2008-10-23 22:53:27.000000000 +0900
> @@ -39,6 +39,8 @@ int page_cluster;
>  static DEFINE_PER_CPU(struct pagevec[NR_LRU_LISTS], lru_add_pvecs);
>  static DEFINE_PER_CPU(struct pagevec, lru_rotate_pvecs);
>  
> +static struct workqueue_struct *vm_wq __read_mostly;
> +
>  /*
>   * This path almost never happens for VM activity - pages are normally
>   * freed via pagevecs.  But it gets used by networking.
> @@ -310,7 +312,7 @@ static void lru_add_drain_per_cpu(struct
>   */
>  int lru_add_drain_all(void)
>  {
> -	return schedule_on_each_cpu(lru_add_drain_per_cpu);
> +	return queue_work_on_each_cpu(vm_wq, lru_add_drain_per_cpu);
>  }
>  
>  #else
> @@ -611,4 +613,8 @@ void __init swap_setup(void)
>  #ifdef CONFIG_HOTPLUG_CPU
>  	hotcpu_notifier(cpu_swap_callback, 0);
>  #endif
> +
> +	vm_wq = create_workqueue("vm_work");
> +	BUG_ON(!vm_wq);
> +
>  }
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
