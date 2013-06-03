Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 1F0746B0034
	for <linux-mm@kvack.org>; Mon,  3 Jun 2013 11:34:35 -0400 (EDT)
Date: Mon, 3 Jun 2013 17:34:32 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch] mm, memcg: add oom killer delay
Message-ID: <20130603153432.GC18588@dhcp22.suse.cz>
References: <alpine.DEB.2.02.1305291817280.520@chino.kir.corp.google.com>
 <20130530150539.GA18155@dhcp22.suse.cz>
 <alpine.DEB.2.02.1305301338430.20389@chino.kir.corp.google.com>
 <20130531081052.GA32491@dhcp22.suse.cz>
 <alpine.DEB.2.02.1305310316210.27716@chino.kir.corp.google.com>
 <20130531112116.GC32491@dhcp22.suse.cz>
 <alpine.DEB.2.02.1305311224330.3434@chino.kir.corp.google.com>
 <20130601061151.GC15576@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130601061151.GC15576@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Sat 01-06-13 02:11:51, Johannes Weiner wrote:
[...]
> From: Johannes Weiner <hannes@cmpxchg.org>
> Subject: [PATCH] memcg: more robust oom handling
> 
> The memcg OOM handling is incredibly fragile because once a memcg goes
> OOM, one task (kernel or userspace) is responsible for resolving the
> situation.  Every other task that gets caught trying to charge memory
> gets stuck in a waitqueue while potentially holding various filesystem
> and mm locks on which the OOM handling task may now deadlock.
> 
> Do two things to charge attempts under OOM:
> 
> 1. Do not trap system calls (buffered IO and friends), just return
>    -ENOMEM.  Userspace should be able to handle this... right?
> 
> 2. Do not trap page faults directly in the charging context.  Instead,
>    remember the OOMing memcg in the task struct and fully unwind the
>    page fault stack first.  Then synchronize the memcg OOM from
>    pagefault_out_of_memory()

I think this should work and I really like it! Nice work Johannes, I
never dared to go that deep and my opposite approach was also much more
fragile.

I am just afraid about all the other archs that do not support (from
quick grep it looks like: blackfin, c6x, h8300, metag, mn10300,
openrisc, score and tile). What would be an alternative for them?
#ifdefs for the old code (something like ARCH_HAS_FAULT_OOM_RETRY)? This
would be acceptable for me.

Few comments bellow.
 
> Not-quite-signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  arch/x86/mm/fault.c        |   2 +
>  include/linux/memcontrol.h |   6 +++
>  include/linux/sched.h      |   6 +++
>  mm/memcontrol.c            | 104 +++++++++++++++++++++++++--------------------
>  mm/oom_kill.c              |   7 ++-
>  5 files changed, 78 insertions(+), 47 deletions(-)
> 
[...]
> diff --git a/include/linux/sched.h b/include/linux/sched.h
> index e692a02..cf60aef 100644
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -1282,6 +1282,8 @@ struct task_struct {
>  				 * execve */
>  	unsigned in_iowait:1;
>  
> +	unsigned in_userfault:1;
> +

[This is more a nit pick but before I forget while I am reading through
the rest of the patch.]

OK there is a lot of room around those bit fields but as this is only
for memcg and you are enlarging the structure by the pointer then you
can reuse bottom bit of memcg pointer.

>  	/* task may not gain privileges */
>  	unsigned no_new_privs:1;
>  
[...]
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index cc3026a..6e13ebe 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
[...]
> @@ -2085,56 +2087,76 @@ static void memcg_oom_recover(struct mem_cgroup *memcg)
>  }
>  
>  /*
> - * try to call OOM killer. returns false if we should exit memory-reclaim loop.
> + * try to call OOM killer
>   */
> -static bool mem_cgroup_handle_oom(struct mem_cgroup *memcg, gfp_t mask,
> -				  int order)
> +static void mem_cgroup_oom(struct mem_cgroup *memcg,
> +			   gfp_t mask, int order,
> +			   bool in_userfault)
>  {
> -	struct oom_wait_info owait;
> -	bool locked, need_to_kill;
> -
> -	owait.memcg = memcg;
> -	owait.wait.flags = 0;
> -	owait.wait.func = memcg_oom_wake_function;
> -	owait.wait.private = current;
> -	INIT_LIST_HEAD(&owait.wait.task_list);
> -	need_to_kill = true;
> -	mem_cgroup_mark_under_oom(memcg);
> +	bool locked, need_to_kill = true;
>  
>  	/* At first, try to OOM lock hierarchy under memcg.*/
>  	spin_lock(&memcg_oom_lock);
>  	locked = mem_cgroup_oom_lock(memcg);
> -	/*
> -	 * Even if signal_pending(), we can't quit charge() loop without
> -	 * accounting. So, UNINTERRUPTIBLE is appropriate. But SIGKILL
> -	 * under OOM is always welcomed, use TASK_KILLABLE here.
> -	 */
> -	prepare_to_wait(&memcg_oom_waitq, &owait.wait, TASK_KILLABLE);
> -	if (!locked || memcg->oom_kill_disable)
> +	if (!locked || memcg->oom_kill_disable) {
>  		need_to_kill = false;
> +		if (in_userfault) {
> +			/*
> +			 * We start sleeping on the OOM waitqueue only
> +			 * after unwinding the page fault stack, so
> +			 * make sure we detect wakeups that happen
> +			 * between now and then.
> +			 */
> +			mem_cgroup_mark_under_oom(memcg);
> +			current->memcg_oom.wakeups =
> +				atomic_read(&memcg->oom_wakeups);
> +			css_get(&memcg->css);
> +			current->memcg_oom.memcg = memcg;
> +		}
> +	}
>  	if (locked)
>  		mem_cgroup_oom_notify(memcg);
>  	spin_unlock(&memcg_oom_lock);
>  
>  	if (need_to_kill) {
> -		finish_wait(&memcg_oom_waitq, &owait.wait);
>  		mem_cgroup_out_of_memory(memcg, mask, order);
> -	} else {
> -		schedule();
> -		finish_wait(&memcg_oom_waitq, &owait.wait);
> +		memcg_oom_recover(memcg);

Why do we need to call memcg_oom_recover here? We do not know that any
charges have been released. Say mem_cgroup_out_of_memory selected a task
which migrated to our group (without its charges) so we would kill the
poor guy and free no memory from this group.
Now you wake up oom waiters to refault but they will end up in the same
situation. I think it should be sufficient to wait for memcg_oom_recover
until the memory is uncharged (which we do already).

>  	}
> -	spin_lock(&memcg_oom_lock);
> -	if (locked)
> +
> +	if (locked) {
> +		spin_lock(&memcg_oom_lock);
>  		mem_cgroup_oom_unlock(memcg);
> -	memcg_wakeup_oom(memcg);
> -	spin_unlock(&memcg_oom_lock);
> +		spin_unlock(&memcg_oom_lock);
> +	}
> +}
>  
> -	mem_cgroup_unmark_under_oom(memcg);
[...]
> @@ -2647,16 +2665,12 @@ again:
>  			css_put(&memcg->css);
>  			goto nomem;
>  		case CHARGE_NOMEM: /* OOM routine works */
> -			if (!oom) {
> +			if (!oom || oom_check) {

OK, this allows us to remove the confusing nr_oom_retries = MEM_CGROUP_RECLAIM_RETRIES
from the branch where oom_check is set to true

>  				css_put(&memcg->css);
>  				goto nomem;
>  			}
> -			/* If oom, we never return -ENOMEM */
>  			nr_oom_retries--;
>  			break;
> -		case CHARGE_OOM_DIE: /* Killed by OOM Killer */
> -			css_put(&memcg->css);
> -			goto bypass;
>  		}
>  	} while (ret != CHARGE_OK);
>  
[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
