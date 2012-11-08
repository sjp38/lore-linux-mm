Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id C5A1A6B0044
	for <linux-mm@kvack.org>; Thu,  8 Nov 2012 10:35:18 -0500 (EST)
Date: Thu, 8 Nov 2012 16:35:12 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 1/2] mm, oom: change type of oom_score_adj to short
Message-ID: <20121108153512.GM31821@dhcp22.suse.cz>
References: <alpine.DEB.2.00.1211080125150.3450@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1211080125150.3450@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Anton Vorontsov <anton.vorontsov@linaro.org>, Oleg Nesterov <oleg@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu 08-11-12 01:26:57, David Rientjes wrote:
> The maximum oom_score_adj is 1000 and the minimum oom_score_adj is -1000,
> so this range can be represented by the signed short type with no
> functional change.  The extra space this frees up in struct signal_struct
> will be used for per-thread oom kill flags in the next patch.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

Reviewed-by: Michal Hocko <mhocko@suse.cz>

> ---
>  drivers/staging/android/lowmemorykiller.c |   16 ++++++++--------
>  fs/proc/base.c                            |   10 +++++-----
>  include/linux/oom.h                       |    4 ++--
>  include/linux/sched.h                     |    6 +++---
>  include/trace/events/oom.h                |    4 ++--
>  include/trace/events/task.h               |    8 ++++----
>  mm/ksm.c                                  |    2 +-
>  mm/oom_kill.c                             |   10 +++++-----
>  mm/swapfile.c                             |    2 +-
>  9 files changed, 31 insertions(+), 31 deletions(-)
> 
> diff --git a/drivers/staging/android/lowmemorykiller.c b/drivers/staging/android/lowmemorykiller.c
> --- a/drivers/staging/android/lowmemorykiller.c
> +++ b/drivers/staging/android/lowmemorykiller.c
> @@ -40,7 +40,7 @@
>  #include <linux/notifier.h>
>  
>  static uint32_t lowmem_debug_level = 2;
> -static int lowmem_adj[6] = {
> +static short lowmem_adj[6] = {
>  	0,
>  	1,
>  	6,
> @@ -70,9 +70,9 @@ static int lowmem_shrink(struct shrinker *s, struct shrink_control *sc)
>  	int rem = 0;
>  	int tasksize;
>  	int i;
> -	int min_score_adj = OOM_SCORE_ADJ_MAX + 1;
> +	short min_score_adj = OOM_SCORE_ADJ_MAX + 1;
>  	int selected_tasksize = 0;
> -	int selected_oom_score_adj;
> +	short selected_oom_score_adj;
>  	int array_size = ARRAY_SIZE(lowmem_adj);
>  	int other_free = global_page_state(NR_FREE_PAGES);
>  	int other_file = global_page_state(NR_FILE_PAGES) -
> @@ -90,7 +90,7 @@ static int lowmem_shrink(struct shrinker *s, struct shrink_control *sc)
>  		}
>  	}
>  	if (sc->nr_to_scan > 0)
> -		lowmem_print(3, "lowmem_shrink %lu, %x, ofree %d %d, ma %d\n",
> +		lowmem_print(3, "lowmem_shrink %lu, %x, ofree %d %d, ma %hd\n",
>  				sc->nr_to_scan, sc->gfp_mask, other_free,
>  				other_file, min_score_adj);
>  	rem = global_page_state(NR_ACTIVE_ANON) +
> @@ -107,7 +107,7 @@ static int lowmem_shrink(struct shrinker *s, struct shrink_control *sc)
>  	rcu_read_lock();
>  	for_each_process(tsk) {
>  		struct task_struct *p;
> -		int oom_score_adj;
> +		short oom_score_adj;
>  
>  		if (tsk->flags & PF_KTHREAD)
>  			continue;
> @@ -141,11 +141,11 @@ static int lowmem_shrink(struct shrinker *s, struct shrink_control *sc)
>  		selected = p;
>  		selected_tasksize = tasksize;
>  		selected_oom_score_adj = oom_score_adj;
> -		lowmem_print(2, "select %d (%s), adj %d, size %d, to kill\n",
> +		lowmem_print(2, "select %d (%s), adj %hd, size %d, to kill\n",
>  			     p->pid, p->comm, oom_score_adj, tasksize);
>  	}
>  	if (selected) {
> -		lowmem_print(1, "send sigkill to %d (%s), adj %d, size %d\n",
> +		lowmem_print(1, "send sigkill to %d (%s), adj %hd, size %d\n",
>  			     selected->pid, selected->comm,
>  			     selected_oom_score_adj, selected_tasksize);
>  		lowmem_deathpending_timeout = jiffies + HZ;
> @@ -176,7 +176,7 @@ static void __exit lowmem_exit(void)
>  }
>  
>  module_param_named(cost, lowmem_shrinker.seeks, int, S_IRUGO | S_IWUSR);
> -module_param_array_named(adj, lowmem_adj, int, &lowmem_adj_size,
> +module_param_array_named(adj, lowmem_adj, short, &lowmem_adj_size,
>  			 S_IRUGO | S_IWUSR);
>  module_param_array_named(minfree, lowmem_minfree, uint, &lowmem_minfree_size,
>  			 S_IRUGO | S_IWUSR);
> diff --git a/fs/proc/base.c b/fs/proc/base.c
> --- a/fs/proc/base.c
> +++ b/fs/proc/base.c
> @@ -878,7 +878,7 @@ static ssize_t oom_score_adj_read(struct file *file, char __user *buf,
>  {
>  	struct task_struct *task = get_proc_task(file->f_path.dentry->d_inode);
>  	char buffer[PROC_NUMBUF];
> -	int oom_score_adj = OOM_SCORE_ADJ_MIN;
> +	short oom_score_adj = OOM_SCORE_ADJ_MIN;
>  	unsigned long flags;
>  	size_t len;
>  
> @@ -889,7 +889,7 @@ static ssize_t oom_score_adj_read(struct file *file, char __user *buf,
>  		unlock_task_sighand(task, &flags);
>  	}
>  	put_task_struct(task);
> -	len = snprintf(buffer, sizeof(buffer), "%d\n", oom_score_adj);
> +	len = snprintf(buffer, sizeof(buffer), "%hd\n", oom_score_adj);
>  	return simple_read_from_buffer(buf, count, ppos, buffer, len);
>  }
>  
> @@ -936,15 +936,15 @@ static ssize_t oom_score_adj_write(struct file *file, const char __user *buf,
>  		goto err_task_lock;
>  	}
>  
> -	if (oom_score_adj < task->signal->oom_score_adj_min &&
> +	if ((short)oom_score_adj < task->signal->oom_score_adj_min &&
>  			!capable(CAP_SYS_RESOURCE)) {
>  		err = -EACCES;
>  		goto err_sighand;
>  	}
>  
> -	task->signal->oom_score_adj = oom_score_adj;
> +	task->signal->oom_score_adj = (short)oom_score_adj;
>  	if (has_capability_noaudit(current, CAP_SYS_RESOURCE))
> -		task->signal->oom_score_adj_min = oom_score_adj;
> +		task->signal->oom_score_adj_min = (short)oom_score_adj;
>  	trace_oom_score_adj_update(task);
>  
>  err_sighand:
> diff --git a/include/linux/oom.h b/include/linux/oom.h
> --- a/include/linux/oom.h
> +++ b/include/linux/oom.h
> @@ -29,8 +29,8 @@ enum oom_scan_t {
>  	OOM_SCAN_SELECT,	/* always select this thread first */
>  };
>  
> -extern void compare_swap_oom_score_adj(int old_val, int new_val);
> -extern int test_set_oom_score_adj(int new_val);
> +extern void compare_swap_oom_score_adj(short old_val, short new_val);
> +extern short test_set_oom_score_adj(short new_val);
>  
>  extern unsigned long oom_badness(struct task_struct *p,
>  		struct mem_cgroup *memcg, const nodemask_t *nodemask,
> diff --git a/include/linux/sched.h b/include/linux/sched.h
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -631,9 +631,9 @@ struct signal_struct {
>  	struct rw_semaphore group_rwsem;
>  #endif
>  
> -	int oom_score_adj;	/* OOM kill score adjustment */
> -	int oom_score_adj_min;	/* OOM kill score adjustment minimum value.
> -				 * Only settable by CAP_SYS_RESOURCE. */
> +	short oom_score_adj;		/* OOM kill score adjustment */
> +	short oom_score_adj_min;	/* OOM kill score adjustment min value.
> +					 * Only settable by CAP_SYS_RESOURCE. */
>  
>  	struct mutex cred_guard_mutex;	/* guard against foreign influences on
>  					 * credential calculations
> diff --git a/include/trace/events/oom.h b/include/trace/events/oom.h
> --- a/include/trace/events/oom.h
> +++ b/include/trace/events/oom.h
> @@ -14,7 +14,7 @@ TRACE_EVENT(oom_score_adj_update,
>  	TP_STRUCT__entry(
>  		__field(	pid_t,	pid)
>  		__array(	char,	comm,	TASK_COMM_LEN )
> -		__field(	 int,	oom_score_adj)
> +		__field(	short,	oom_score_adj)
>  	),
>  
>  	TP_fast_assign(
> @@ -23,7 +23,7 @@ TRACE_EVENT(oom_score_adj_update,
>  		__entry->oom_score_adj = task->signal->oom_score_adj;
>  	),
>  
> -	TP_printk("pid=%d comm=%s oom_score_adj=%d",
> +	TP_printk("pid=%d comm=%s oom_score_adj=%hd",
>  		__entry->pid, __entry->comm, __entry->oom_score_adj)
>  );
>  
> diff --git a/include/trace/events/task.h b/include/trace/events/task.h
> --- a/include/trace/events/task.h
> +++ b/include/trace/events/task.h
> @@ -15,7 +15,7 @@ TRACE_EVENT(task_newtask,
>  		__field(	pid_t,	pid)
>  		__array(	char,	comm, TASK_COMM_LEN)
>  		__field( unsigned long, clone_flags)
> -		__field(	int,    oom_score_adj)
> +		__field(	short,	oom_score_adj)
>  	),
>  
>  	TP_fast_assign(
> @@ -25,7 +25,7 @@ TRACE_EVENT(task_newtask,
>  		__entry->oom_score_adj = task->signal->oom_score_adj;
>  	),
>  
> -	TP_printk("pid=%d comm=%s clone_flags=%lx oom_score_adj=%d",
> +	TP_printk("pid=%d comm=%s clone_flags=%lx oom_score_adj=%hd",
>  		__entry->pid, __entry->comm,
>  		__entry->clone_flags, __entry->oom_score_adj)
>  );
> @@ -40,7 +40,7 @@ TRACE_EVENT(task_rename,
>  		__field(	pid_t,	pid)
>  		__array(	char, oldcomm,  TASK_COMM_LEN)
>  		__array(	char, newcomm,  TASK_COMM_LEN)
> -		__field(	int, oom_score_adj)
> +		__field(	short,	oom_score_adj)
>  	),
>  
>  	TP_fast_assign(
> @@ -50,7 +50,7 @@ TRACE_EVENT(task_rename,
>  		__entry->oom_score_adj = task->signal->oom_score_adj;
>  	),
>  
> -	TP_printk("pid=%d oldcomm=%s newcomm=%s oom_score_adj=%d",
> +	TP_printk("pid=%d oldcomm=%s newcomm=%s oom_score_adj=%hd",
>  		__entry->pid, __entry->oldcomm,
>  		__entry->newcomm, __entry->oom_score_adj)
>  );
> diff --git a/mm/ksm.c b/mm/ksm.c
> --- a/mm/ksm.c
> +++ b/mm/ksm.c
> @@ -1929,7 +1929,7 @@ static ssize_t run_store(struct kobject *kobj, struct kobj_attribute *attr,
>  	if (ksm_run != flags) {
>  		ksm_run = flags;
>  		if (flags & KSM_RUN_UNMERGE) {
> -			int oom_score_adj;
> +			short oom_score_adj;
>  
>  			oom_score_adj = test_set_oom_score_adj(OOM_SCORE_ADJ_MAX);
>  			err = unmerge_and_remove_all_rmap_items();
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -53,7 +53,7 @@ static DEFINE_SPINLOCK(zone_scan_lock);
>   * @old_val.  Usually used to reinstate a previous value to prevent racing with
>   * userspacing tuning the value in the interim.
>   */
> -void compare_swap_oom_score_adj(int old_val, int new_val)
> +void compare_swap_oom_score_adj(short old_val, short new_val)
>  {
>  	struct sighand_struct *sighand = current->sighand;
>  
> @@ -72,7 +72,7 @@ void compare_swap_oom_score_adj(int old_val, int new_val)
>   * synchronization and returns the old value.  Usually used to temporarily
>   * set a value, save the old value in the caller, and then reinstate it later.
>   */
> -int test_set_oom_score_adj(int new_val)
> +short test_set_oom_score_adj(short new_val)
>  {
>  	struct sighand_struct *sighand = current->sighand;
>  	int old_val;
> @@ -193,7 +193,7 @@ unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
>  	if (!p)
>  		return 0;
>  
> -	adj = p->signal->oom_score_adj;
> +	adj = (long)p->signal->oom_score_adj;
>  	if (adj == OOM_SCORE_ADJ_MIN) {
>  		task_unlock(p);
>  		return 0;
> @@ -412,7 +412,7 @@ static void dump_tasks(const struct mem_cgroup *memcg, const nodemask_t *nodemas
>  			continue;
>  		}
>  
> -		pr_info("[%5d] %5d %5d %8lu %8lu %7lu %8lu         %5d %s\n",
> +		pr_info("[%5d] %5d %5d %8lu %8lu %7lu %8lu         %5hd %s\n",
>  			task->pid, from_kuid(&init_user_ns, task_uid(task)),
>  			task->tgid, task->mm->total_vm, get_mm_rss(task->mm),
>  			task->mm->nr_ptes,
> @@ -428,7 +428,7 @@ static void dump_header(struct task_struct *p, gfp_t gfp_mask, int order,
>  {
>  	task_lock(current);
>  	pr_warning("%s invoked oom-killer: gfp_mask=0x%x, order=%d, "
> -		"oom_score_adj=%d\n",
> +		"oom_score_adj=%hd\n",
>  		current->comm, gfp_mask, order,
>  		current->signal->oom_score_adj);
>  	cpuset_print_task_mems_allowed(current);
> diff --git a/mm/swapfile.c b/mm/swapfile.c
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -1484,7 +1484,7 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
>  	struct address_space *mapping;
>  	struct inode *inode;
>  	struct filename *pathname;
> -	int oom_score_adj;
> +	short oom_score_adj;
>  	int i, type, prev;
>  	int err;
>  

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
