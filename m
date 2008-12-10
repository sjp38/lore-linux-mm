Date: Wed, 10 Dec 2008 15:19:48 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC][RFT] memcg fix cgroup_mutex deadlock when cpuset reclaims
 memory
Message-Id: <20081210151948.9a83f70a.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20081210051947.GH7593@balbir.in.ibm.com>
References: <20081210051947.GH7593@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: menage@google.com, KAMEZAWA Hiroyuki <kamezawa.hiroyuki@jp.fujitsu.com>, Daisuke Miyakawa <dmiyakawa@google.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, nishimura@mxp.nes.nec.co.jp
List-ID: <linux-mm.kvack.org>

On Wed, 10 Dec 2008 10:49:47 +0530, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> Hi,
> 
> Here is a proposed fix for the memory controller cgroup_mutex deadlock
> reported. It is lightly tested and reviewed. I need help with review
> and test. Is the reported deadlock reproducible after this patch? A
> careful review of the cpuset impact will also be highly appreciated.
> 
> From: Balbir Singh <balbir@linux.vnet.ibm.com>
> 
> cpuset_migrate_mm() holds cgroup_mutex throughout the duration of
> do_migrate_pages(). The issue with that is that
> 
> 1. It can lead to deadlock with memcg, as do_migrate_pages()
>    enters reclaim
> 2. It can lead to long latencies, preventing users from creating/
>    destroying other cgroups anywhere else
> 
> The patch holds callback_mutex through the duration of cpuset_migrate_mm() and
> gives up cgroup_mutex while doing so.
> 
I agree changing cpuset_migrate_mm not to hold cgroup_mutex to fix the dead lock
is one choice, and it looks good to me at the first impression.

But I'm not sure it's good to change cpuset(other subsystem) code because of memcg.

Anyway, I'll test this patch and report the result tomorrow.
(Sorry, I don't have enough time today.)


Thanks,
Daisuke Nishimura.

> Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> ---
> 
>  include/linux/cpuset.h |   13 ++++++++++++-
>  kernel/cpuset.c        |   23 ++++++++++++-----------
>  2 files changed, 24 insertions(+), 12 deletions(-)
> 
> diff -puN kernel/cgroup.c~cpuset-remove-cgroup-mutex-from-update-path kernel/cgroup.c
> diff -puN kernel/cpuset.c~cpuset-remove-cgroup-mutex-from-update-path kernel/cpuset.c
> --- a/kernel/cpuset.c~cpuset-remove-cgroup-mutex-from-update-path
> +++ a/kernel/cpuset.c
> @@ -369,7 +369,7 @@ static void guarantee_online_mems(const 
>   * task has been modifying its cpuset.
>   */
>  
> -void cpuset_update_task_memory_state(void)
> +void __cpuset_update_task_memory_state(bool held)
>  {
>  	int my_cpusets_mem_gen;
>  	struct task_struct *tsk = current;
> @@ -380,7 +380,8 @@ void cpuset_update_task_memory_state(voi
>  	rcu_read_unlock();
>  
>  	if (my_cpusets_mem_gen != tsk->cpuset_mems_generation) {
> -		mutex_lock(&callback_mutex);
> +		if (!held)
> +			mutex_lock(&callback_mutex);
>  		task_lock(tsk);
>  		cs = task_cs(tsk); /* Maybe changed when task not locked */
>  		guarantee_online_mems(cs, &tsk->mems_allowed);
> @@ -394,7 +395,8 @@ void cpuset_update_task_memory_state(voi
>  		else
>  			tsk->flags &= ~PF_SPREAD_SLAB;
>  		task_unlock(tsk);
> -		mutex_unlock(&callback_mutex);
> +		if (!held)
> +			mutex_unlock(&callback_mutex);
>  		mpol_rebind_task(tsk, &tsk->mems_allowed);
>  	}
>  }
> @@ -949,13 +951,15 @@ static int update_cpumask(struct cpuset 
>   *    so that the migration code can allocate pages on these nodes.
>   *
>   *    Call holding cgroup_mutex, so current's cpuset won't change
> - *    during this call, as manage_mutex holds off any cpuset_attach()
> + *    during this call, as callback_mutex holds off any cpuset_attach()
>   *    calls.  Therefore we don't need to take task_lock around the
>   *    call to guarantee_online_mems(), as we know no one is changing
>   *    our task's cpuset.
>   *
>   *    Hold callback_mutex around the two modifications of our tasks
> - *    mems_allowed to synchronize with cpuset_mems_allowed().
> + *    mems_allowed to synchronize with cpuset_mems_allowed(). Give
> + *    up cgroup_mutex to avoid deadlocking with other subsystems
> + *    as we enter reclaim from do_migrate_pages().
>   *
>   *    While the mm_struct we are migrating is typically from some
>   *    other task, the task_struct mems_allowed that we are hacking
> @@ -976,17 +980,14 @@ static void cpuset_migrate_mm(struct mm_
>  {
>  	struct task_struct *tsk = current;
>  
> -	cpuset_update_task_memory_state();
> -
> +	cgroup_unlock();
>  	mutex_lock(&callback_mutex);
> +	cpuset_update_task_memory_state_locked();
>  	tsk->mems_allowed = *to;
> -	mutex_unlock(&callback_mutex);
> -
>  	do_migrate_pages(mm, from, to, MPOL_MF_MOVE_ALL);
> -
> -	mutex_lock(&callback_mutex);
>  	guarantee_online_mems(task_cs(tsk),&tsk->mems_allowed);
>  	mutex_unlock(&callback_mutex);
> +	cgroup_lock();
>  }
>  
>  static void *cpuset_being_rebound;
> diff -puN include/linux/cpuset.h~cpuset-remove-cgroup-mutex-from-update-path include/linux/cpuset.h
> --- a/include/linux/cpuset.h~cpuset-remove-cgroup-mutex-from-update-path
> +++ a/include/linux/cpuset.h
> @@ -25,7 +25,18 @@ extern void cpuset_cpus_allowed_locked(s
>  extern nodemask_t cpuset_mems_allowed(struct task_struct *p);
>  #define cpuset_current_mems_allowed (current->mems_allowed)
>  void cpuset_init_current_mems_allowed(void);
> -void cpuset_update_task_memory_state(void);
> +extern void __cpuset_update_task_memory_state(bool locked);
> +
> +static void inline cpuset_update_task_memory_state(void)
> +{
> +	__cpuset_update_task_memory_state(false);
> +}
> +
> +static void inline cpuset_update_task_memory_state_locked(void)
> +{
> +	__cpuset_update_task_memory_state(true);
> +}
> +
>  int cpuset_nodemask_valid_mems_allowed(nodemask_t *nodemask);
>  
>  extern int __cpuset_zone_allowed_softwall(struct zone *z, gfp_t gfp_mask);
> _
> 
> -- 
> 	Balbir
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
