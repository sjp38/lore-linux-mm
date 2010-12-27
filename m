Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 93CF16B00A2
	for <linux-mm@kvack.org>; Sun, 26 Dec 2010 19:58:28 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oBR0wPHt016222
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 27 Dec 2010 09:58:25 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4463A45DE81
	for <linux-mm@kvack.org>; Mon, 27 Dec 2010 09:58:25 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2BD8945DE80
	for <linux-mm@kvack.org>; Mon, 27 Dec 2010 09:58:25 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1A58AEF8005
	for <linux-mm@kvack.org>; Mon, 27 Dec 2010 09:58:25 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id CFF541DB803F
	for <linux-mm@kvack.org>; Mon, 27 Dec 2010 09:58:24 +0900 (JST)
Date: Mon, 27 Dec 2010 09:52:25 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch v2] memcg: add oom killer delay
Message-Id: <20101227095225.2cf907a3.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1012221443540.2612@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1012212318140.22773@chino.kir.corp.google.com>
	<20101221235924.b5c1aecc.akpm@linux-foundation.org>
	<alpine.DEB.2.00.1012220031010.24462@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1012221443540.2612@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Divyesh Shah <dpshah@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 22 Dec 2010 14:45:05 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> Completely disabling the oom killer for a memcg is problematic if
> userspace is unable to address the condition itself, usually because
> userspace is unresponsive.  This scenario creates a memcg livelock:
> tasks are continuously trying to allocate memory and nothing is getting
> killed, so memory freeing is impossible since reclaim has failed, and
> all work stalls with no remedy in sight.
> 
> This patch adds an oom killer delay so that a memcg may be configured to
> wait at least a pre-defined number of milliseconds before calling the
> oom killer.  If the oom condition persists for this number of
> milliseconds, the oom killer will be called the next time the memory
> controller attempts to charge a page (and memory.oom_control is set to
> 0).  This allows userspace to have a short period of time to respond to
> the condition before timing out and deferring to the kernel to kill a
> task.
> 
> Admins may set the oom killer timeout using the new interface:
> 
> 	# echo 60000 > memory.oom_delay
> 
> This will defer oom killing to the kernel only after 60 seconds has
> elapsed.  When setting memory.oom_delay, all pending timeouts are
> restarted.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

I dislike this feature but if someone other than goole want this, I'll ack.
some comments below.


> ---
>  v2 of the patch to address your suggestions -- if we _really_ want to
>  leave the kernel open to the possibility of livelock as the result of
>  a userspace bug, then this doesn't need to be merged.  Otherwise, it
>  would be nice to get this support for a more robust memory controller.
> 
>  Documentation/cgroups/memory.txt |   17 +++++++++++
>  mm/memcontrol.c                  |   55 +++++++++++++++++++++++++++++++++----
>  2 files changed, 66 insertions(+), 6 deletions(-)
> 
> diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
> --- a/Documentation/cgroups/memory.txt
> +++ b/Documentation/cgroups/memory.txt
> @@ -68,6 +68,7 @@ Brief summary of control files.
>  				 (See sysctl's vm.swappiness)
>   memory.move_charge_at_immigrate # set/show controls of moving charges
>   memory.oom_control		 # set/show oom controls.
> + memory.oom_delay_millisecs	 # set/show millisecs to wait before oom kill
>  
>  1. History
>  
> @@ -640,6 +641,22 @@ At reading, current status of OOM is shown.
>  	under_oom	 0 or 1 (if 1, the memory cgroup is under OOM, tasks may
>  				 be stopped.)
>  
> +It is also possible to configure an oom killer timeout to prevent the
> +possibility that the memcg will livelock looking for memory if userspace

It's not livelock. It's just 'stop'. No cpu consumption at all even if oom is
disabled.


> +has disabled the oom killer with oom_control but cannot act to fix the
> +condition itself (usually because userspace has become unresponsive).
> +
> +To set an oom killer timeout for a memcg, write the number of milliseconds
> +to wait before killing a task to memory.oom_delay_millisecs:
> +
> +	# echo 60000 > memory.oom_delay_millisecs	# 60 seconds before kill
> +

I wonder whether this should be call as oom_delay you mention this feature as
'timeout' a few times before here. I like 'timeout' rather than 'delay'.
And from this ducument, They are unclear that
  1. what happens when it used with oom_disable.
  2. what kind of timer is this. Is it a one-shot timer ?
  3. how work with hierarchy ?

My suggestion for 1. is:
Please return -EBUSY or some if oom_disable=true and allow set timeout only when
oom_disable=false. Using both of two interface at the same time is too complex.


> +This timeout is reset the next time the memcg successfully charges memory
> +to a task.
> +
> +There is no delay if memory.oom_delay_millisecs is set to 0 (default).
> +
> +
>  11. TODO
>  
>  1. Add support for accounting huge pages (as a separate controller)
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -233,12 +233,16 @@ struct mem_cgroup {
>  	 * Should the accounting and control be hierarchical, per subtree?
>  	 */
>  	bool use_hierarchy;
> +	/* oom_delay has expired and still out of memory? */
> +	bool oom_delay_expired;
>  	atomic_t	oom_lock;
>  	atomic_t	refcnt;
>  
>  	unsigned int	swappiness;
>  	/* OOM-Killer disable */
>  	int		oom_kill_disable;
> +	/* number of ticks to stall before calling oom killer */
> +	int		oom_delay;
>  
>  	/* set when res.limit == memsw.limit */
>  	bool		memsw_is_minimum;
> @@ -1524,6 +1528,7 @@ static void memcg_wakeup_oom(struct mem_cgroup *mem)
>  
>  static void memcg_oom_recover(struct mem_cgroup *mem)
>  {
> +	mem->oom_delay_expired = false;
>  	if (mem && atomic_read(&mem->oom_lock))
>  		memcg_wakeup_oom(mem);
>  }
> @@ -1531,17 +1536,18 @@ static void memcg_oom_recover(struct mem_cgroup *mem)
>  /*
>   * try to call OOM killer. returns false if we should exit memory-reclaim loop.
>   */
> -bool mem_cgroup_handle_oom(struct mem_cgroup *mem, gfp_t mask)
> +static bool mem_cgroup_handle_oom(struct mem_cgroup *mem, gfp_t mask)
>  {
>  	struct oom_wait_info owait;
> -	bool locked, need_to_kill;
> +	bool locked;
> +	bool need_to_kill = true;
> +	bool need_to_delay = false;
>  
>  	owait.mem = mem;
>  	owait.wait.flags = 0;
>  	owait.wait.func = memcg_oom_wake_function;
>  	owait.wait.private = current;
>  	INIT_LIST_HEAD(&owait.wait.task_list);
> -	need_to_kill = true;
>  	/* At first, try to OOM lock hierarchy under mem.*/
>  	mutex_lock(&memcg_oom_mutex);
>  	locked = mem_cgroup_oom_lock(mem);
> @@ -1553,26 +1559,34 @@ bool mem_cgroup_handle_oom(struct mem_cgroup *mem, gfp_t mask)
>  	prepare_to_wait(&memcg_oom_waitq, &owait.wait, TASK_KILLABLE);
>  	if (!locked || mem->oom_kill_disable)
>  		need_to_kill = false;
> -	if (locked)
> +	if (locked) {
>  		mem_cgroup_oom_notify(mem);
> +		if (mem->oom_delay && !mem->oom_delay_expired) {
> +			need_to_kill = false;
> +			need_to_delay = true;
> +		}
> +	}

Hmm. When threads T1 and T2 enters this routine, it seems broken.

Case 1)
	T1                        T2
     lock_oom.
     locked=true                lock_oom.
     oom_notify()               locked = false.    
     wait for msecs.            wait until wakeup.
     ......
     unlock_oom.
     wakes up.
     wake up all threads.
     oom_delay_expired=true.    wakes up.
                                oom_delay_expired=false.
                               
     2nd call of oom.
     lock_oom.
     locked=true.
     oom_notify.
     wait for msecs.
  
Then, oom_notify is duplicated and no OOM happens.
memcg_wakeup_oom() wakes up all threads. So, I guess you should avoid to call
that. But hmm...I think there are other pitfalls.


Assume a hierachy as this.

  A
 / \
 B  C

A.memory.use_hierarchy= 1 and (A,B,C) are under hierarchical control.

At first, oom_disable is allowed to be set only against A. By setting
oom_disable to A, OOM in B and C are disabled, too. For that purpose,
mem_cgroup_oom_lock/unlock is provided.

With your patch, even if oom_delay is set to A, B and C will never delay.
Please fix.


>  	mutex_unlock(&memcg_oom_mutex);
>  
>  	if (need_to_kill) {
>  		finish_wait(&memcg_oom_waitq, &owait.wait);
>  		mem_cgroup_out_of_memory(mem, mask);
>  	} else {
> -		schedule();
> +		schedule_timeout(need_to_delay ? mem->oom_delay :
> +						 MAX_SCHEDULE_TIMEOUT);
>  		finish_wait(&memcg_oom_waitq, &owait.wait);
>  	}
>  	mutex_lock(&memcg_oom_mutex);
>  	mem_cgroup_oom_unlock(mem);
>  	memcg_wakeup_oom(mem);
> +	mem->oom_delay_expired = need_to_delay;


If someone charges successfully, this oom_delay_expired will tunrs back to be false.
I think this is not good....race is complicated.

If I was you, I'll add a function like memcg_oom_recover() to update status. 
(You need somethink like that for supporting hierarchy. I think.)


>  	mutex_unlock(&memcg_oom_mutex);
>  
>  	if (test_thread_flag(TIF_MEMDIE) || fatal_signal_pending(current))
>  		return false;
>  	/* Give chance to dying process */
> -	schedule_timeout(1);
> +	if (!need_to_delay)
> +		schedule_timeout(1);

This is unnecessary. After mem_cgroup_oom_unlock(), memcg_wakeup_oom() is called
and all thread wakes up. I think all other threads than TIF_MEMDIE should
sleep for a while.

>  	return true;
>  }
>  
> @@ -2007,6 +2021,7 @@ again:
>  		refill_stock(mem, csize - PAGE_SIZE);
>  	css_put(&mem->css);
>  done:
> +	mem->oom_delay_expired = false;

Don't add this in 'fast path'. This is too bad.


Have a good new year.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
