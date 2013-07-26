Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 61AD76B0031
	for <linux-mm@kvack.org>; Fri, 26 Jul 2013 10:43:14 -0400 (EDT)
Date: Fri, 26 Jul 2013 16:43:10 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 6/6] mm: memcg: do not trap chargers with full callstack
 on OOM
Message-ID: <20130726144310.GH17761@dhcp22.suse.cz>
References: <1374791138-15665-1-git-send-email-hannes@cmpxchg.org>
 <1374791138-15665-7-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1374791138-15665-7-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, azurIt <azurit@pobox.sk>, linux-mm@kvack.org, cgroups@vger.kernel.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu 25-07-13 18:25:38, Johannes Weiner wrote:
> The memcg OOM handling is incredibly fragile and can deadlock.  When a
> task fails to charge memory, it invokes the OOM killer and loops right
> there in the charge code until it succeeds.  Comparably, any other
> task that enters the charge path at this point will go to a waitqueue
> right then and there and sleep until the OOM situation is resolved.
> The problem is that these tasks may hold filesystem locks and the
> mmap_sem; locks that the selected OOM victim may need to exit.
> 
> For example, in one reported case, the task invoking the OOM killer
> was about to charge a page cache page during a write(), which holds
> the i_mutex.  The OOM killer selected a task that was just entering
> truncate() and trying to acquire the i_mutex:
> 
> OOM invoking task:
> [<ffffffff8110a9c1>] mem_cgroup_handle_oom+0x241/0x3b0
> [<ffffffff8110b5ab>] T.1146+0x5ab/0x5c0
> [<ffffffff8110c22e>] mem_cgroup_cache_charge+0xbe/0xe0
> [<ffffffff810ca28c>] add_to_page_cache_locked+0x4c/0x140
> [<ffffffff810ca3a2>] add_to_page_cache_lru+0x22/0x50
> [<ffffffff810ca45b>] grab_cache_page_write_begin+0x8b/0xe0
> [<ffffffff81193a18>] ext3_write_begin+0x88/0x270
> [<ffffffff810c8fc6>] generic_file_buffered_write+0x116/0x290
> [<ffffffff810cb3cc>] __generic_file_aio_write+0x27c/0x480
> [<ffffffff810cb646>] generic_file_aio_write+0x76/0xf0           # takes ->i_mutex
> [<ffffffff8111156a>] do_sync_write+0xea/0x130
> [<ffffffff81112183>] vfs_write+0xf3/0x1f0
> [<ffffffff81112381>] sys_write+0x51/0x90
> [<ffffffff815b5926>] system_call_fastpath+0x18/0x1d
> [<ffffffffffffffff>] 0xffffffffffffffff
> 
> OOM kill victim:
> [<ffffffff811109b8>] do_truncate+0x58/0xa0              # takes i_mutex
> [<ffffffff81121c90>] do_last+0x250/0xa30
> [<ffffffff81122547>] path_openat+0xd7/0x440
> [<ffffffff811229c9>] do_filp_open+0x49/0xa0
> [<ffffffff8110f7d6>] do_sys_open+0x106/0x240
> [<ffffffff8110f950>] sys_open+0x20/0x30
> [<ffffffff815b5926>] system_call_fastpath+0x18/0x1d
> [<ffffffffffffffff>] 0xffffffffffffffff
> 
> The OOM handling task will retry the charge indefinitely while the OOM
> killed task is not releasing any resources.
> 
> A similar scenario can happen when the kernel OOM killer for a memcg
> is disabled and a userspace task is in charge of resolving OOM
> situations.  In this case, ALL tasks that enter the OOM path will be
> made to sleep on the OOM waitqueue and wait for userspace to free
> resources or increase the group's limit.  But a userspace OOM handler
> is prone to deadlock itself on the locks held by the waiting tasks.
> For example one of the sleeping tasks may be stuck in a brk() call
> with the mmap_sem held for writing but the userspace handler, in order
> to pick an optimal victim, may need to read files from /proc/<pid>,
> which tries to acquire the same mmap_sem for reading and deadlocks.
> 
> This patch changes the way tasks behave after detecting a memcg OOM
> and makes sure nobody loops or sleeps with locks held:
> 
> 1. When OOMing in a user fault, invoke the OOM killer and restart the
>    fault instead of looping on the charge attempt.  This way, the OOM
>    victim can not get stuck on locks the looping task may hold.
> 
> 2. When OOMing in a user fault but somebody else is handling it
>    (either the kernel OOM killer or a userspace handler), don't go to
>    sleep in the charge context.  Instead, remember the OOMing memcg in
>    the task struct and then fully unwind the page fault stack with
>    -ENOMEM.  pagefault_out_of_memory() will then call back into the
>    memcg code to check if the -ENOMEM came from the memcg, and then
>    either put the task to sleep on the memcg's OOM waitqueue or just
>    restart the fault.  The OOM victim can no longer get stuck on any
>    lock a sleeping task may hold.
> 
> This relies on the memcg OOM killer only being enabled when an
> allocation failure will result in a call to pagefault_out_of_memory().
> 
> While reworking the OOM routine, also remove a needless OOM waitqueue
> wakeup when invoking the killer.  In addition to the wakeup implied in
> the kill signal delivery, only uncharges and limit increases, things
> that actually change the memory situation, should poke the waitqueue.
> 
> Reported-by: Reported-by: azurIt <azurit@pobox.sk>
> Debugged-by: Michal Hocko <mhocko@suse.cz>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Looks good just one remark bellow.

[...]
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 30ae46a..029a3a8 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
[...]
> @@ -2189,31 +2191,20 @@ static void memcg_oom_recover(struct mem_cgroup *memcg)
>  }
>  
>  /*
> - * try to call OOM killer. returns false if we should exit memory-reclaim loop.
> + * try to call OOM killer
>   */
> -static bool mem_cgroup_handle_oom(struct mem_cgroup *memcg, gfp_t mask,
> -				  int order)
> +static void mem_cgroup_oom(struct mem_cgroup *memcg, gfp_t mask, int order)
>  {
> -	struct oom_wait_info owait;
> -	bool locked, need_to_kill;
> +	bool locked, need_to_kill = true;
>  
> -	owait.memcg = memcg;
> -	owait.wait.flags = 0;
> -	owait.wait.func = memcg_oom_wake_function;
> -	owait.wait.private = current;
> -	INIT_LIST_HEAD(&owait.wait.task_list);
> -	need_to_kill = true;
> -	mem_cgroup_mark_under_oom(memcg);

You are marking memcg under_oom only for the sleepers. So if we have
no sleepers then the memcg will never report it is under oom which
is a behavior change. On the other hand who-ever relies on under_oom
under such conditions (it would basically mean a busy loop reading
memory.oom_control) would be racy anyway so it is questionable it
matters at all. At least now when we do not have any active notification
that under_oom has changed.

Anyway, this shouldn't be a part of this patch so if you want it because
it saves a pointless hierarchy traversal then make it a separate patch
with explanation why the new behavior is still OK.

> +	if (!current->memcg_oom.may_oom)
> +		return;
> +
> +	current->memcg_oom.in_memcg_oom = 1;
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
>  	if (!locked || memcg->oom_kill_disable)
>  		need_to_kill = false;
>  	if (locked)
> @@ -2221,24 +2212,100 @@ static bool mem_cgroup_handle_oom(struct mem_cgroup *memcg, gfp_t mask,
>  	spin_unlock(&memcg_oom_lock);
>  
>  	if (need_to_kill) {
> -		finish_wait(&memcg_oom_waitq, &owait.wait);
>  		mem_cgroup_out_of_memory(memcg, mask, order);
>  	} else {
> -		schedule();
> -		finish_wait(&memcg_oom_waitq, &owait.wait);
> +		/*
> +		 * A system call can just return -ENOMEM, but if this
> +		 * is a page fault and somebody else is handling the
> +		 * OOM already, we need to sleep on the OOM waitqueue
> +		 * for this memcg until the situation is resolved.
> +		 * Which can take some time because it might be
> +		 * handled by a userspace task.
> +		 *
> +		 * However, this is the charge context, which means
> +		 * that we may sit on a large call stack and hold
> +		 * various filesystem locks, the mmap_sem etc. and we
> +		 * don't want the OOM handler to deadlock on them
> +		 * while we sit here and wait.  Store the current OOM
> +		 * context in the task_struct, then return -ENOMEM.
> +		 * At the end of the page fault handler, with the
> +		 * stack unwound, pagefault_out_of_memory() will check
> +		 * back with us by calling
> +		 * mem_cgroup_oom_synchronize(), possibly putting the
> +		 * task to sleep.
> +		 */
> +		mem_cgroup_mark_under_oom(memcg);
> +		current->memcg_oom.wakeups = atomic_read(&memcg->oom_wakeups);
> +		css_get(&memcg->css);
> +		current->memcg_oom.wait_on_memcg = memcg;
>  	}
> -	spin_lock(&memcg_oom_lock);
> -	if (locked)
> +
> +	if (locked) {
> +		spin_lock(&memcg_oom_lock);
>  		mem_cgroup_oom_unlock(memcg);
> -	memcg_wakeup_oom(memcg);
> -	spin_unlock(&memcg_oom_lock);
> +		/*
> +		 * Sleeping tasks might have been killed, make sure
> +		 * they get scheduled so they can exit.
> +		 */
> +		if (need_to_kill)
> +			memcg_oom_recover(memcg);
> +		spin_unlock(&memcg_oom_lock);
> +	}
> +}
>  
> -	mem_cgroup_unmark_under_oom(memcg);
[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
