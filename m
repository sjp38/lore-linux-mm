Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 6611D6B0044
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 00:57:41 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nA65vcBk030781
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 6 Nov 2009 14:57:38 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 866AE45DE7B
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 14:57:37 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4D09045DE4D
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 14:57:37 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id B830AE1800F
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 14:57:36 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id DB1FE1DB803F
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 14:57:31 +0900 (JST)
Date: Fri, 6 Nov 2009 14:54:59 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH -mmotm 2/8] memcg: move memcg_tasklist mutex
Message-Id: <20091106145459.351b407f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091106141149.9c7e94d5.nishimura@mxp.nes.nec.co.jp>
References: <20091106141011.3ded1551.nishimura@mxp.nes.nec.co.jp>
	<20091106141149.9c7e94d5.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>
List-ID: <linux-mm.kvack.org>

On Fri, 6 Nov 2009 14:11:49 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> memcg_tasklist was introduced to serialize mem_cgroup_out_of_memory() and
> mem_cgroup_move_task() to ensure tasks cannot be moved to another cgroup
> during select_bad_process().
> 
> task_in_mem_cgroup(), which can be called by select_bad_process(), will check
> whether a task is in the mem_cgroup or not by dereferencing task->cgroups
> ->subsys[]. So, it would be desirable to change task->cgroups
> (rcu_assign_pointer() in cgroup_attach_task() does it) with memcg_tasklist held.
> 
> Now that we can define cancel_attach(), we can safely release memcg_tasklist
> on fail path even if we hold memcg_tasklist in can_attach(). So let's move
> mutex_lock/unlock() of memcg_tasklist.
> 
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> ---
>  mm/memcontrol.c |   22 ++++++++++++++++++++--
>  1 files changed, 20 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 4bd3451..d3b2ac0 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3395,18 +3395,34 @@ static int mem_cgroup_populate(struct cgroup_subsys *ss,
>  	return ret;
>  }
>  
> +static int mem_cgroup_can_attach(struct cgroup_subsys *ss,
> +				struct cgroup *cgroup,
> +				struct task_struct *p,
> +				bool threadgroup)
> +{
> +	mutex_lock(&memcg_tasklist);
> +	return 0;
> +}

Hmm...Is this lock really necessary ?
IOW, can't we just remove memcg_tasklist mutex ?
What kind of bad race happens when we remove this ?

Thanks,
-Kame

> +
> +static void mem_cgroup_cancel_attach(struct cgroup_subsys *ss,
> +				struct cgroup *cgroup,
> +				struct task_struct *p,
> +				bool threadgroup)
> +{
> +	mutex_unlock(&memcg_tasklist);
> +}
> +
>  static void mem_cgroup_move_task(struct cgroup_subsys *ss,
>  				struct cgroup *cont,
>  				struct cgroup *old_cont,
>  				struct task_struct *p,
>  				bool threadgroup)
>  {
> -	mutex_lock(&memcg_tasklist);
> +	mutex_unlock(&memcg_tasklist);
>  	/*
>  	 * FIXME: It's better to move charges of this process from old
>  	 * memcg to new memcg. But it's just on TODO-List now.
>  	 */
> -	mutex_unlock(&memcg_tasklist);
>  }
>  
>  struct cgroup_subsys mem_cgroup_subsys = {
> @@ -3416,6 +3432,8 @@ struct cgroup_subsys mem_cgroup_subsys = {
>  	.pre_destroy = mem_cgroup_pre_destroy,
>  	.destroy = mem_cgroup_destroy,
>  	.populate = mem_cgroup_populate,
> +	.can_attach = mem_cgroup_can_attach,
> +	.cancel_attach = mem_cgroup_cancel_attach,
>  	.attach = mem_cgroup_move_task,
>  	.early_init = 0,
>  	.use_id = 1,


Thanks,
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
