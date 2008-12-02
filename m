Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mB27GYot016558
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 2 Dec 2008 16:16:35 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id B6FF545DD72
	for <linux-mm@kvack.org>; Tue,  2 Dec 2008 16:16:34 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 981FD45DE51
	for <linux-mm@kvack.org>; Tue,  2 Dec 2008 16:16:34 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 77FBF1DB8044
	for <linux-mm@kvack.org>; Tue,  2 Dec 2008 16:16:34 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 2CD271DB803F
	for <linux-mm@kvack.org>; Tue,  2 Dec 2008 16:16:34 +0900 (JST)
Date: Tue, 2 Dec 2008 16:15:45 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/2] memcg: mem_cgroup->prev_priority protected by lock.
Message-Id: <20081202161545.abb884e8.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081202160949.1CFE.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20081202160949.1CFE.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue,  2 Dec 2008 16:11:07 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> 
> Currently, mem_cgroup doesn't have own lock and almost its member doesn't need.
>  (e.g. info is protected by zone lock, stat is per cpu variable)
> 
> However, there is one explict exception. mem_cgroup->prev_priorit need lock,
> but doesn't protect.
> Luckly, this is NOT bug because prev_priority isn't used for current reclaim code.
> 
> However, we plan to use prev_priority future again.
> Therefore, fixing is better.
> 
> 
> In addision, we plan to reuse this lock for another member.
> Then "misc_lock" name is better than "prev_priority_lock".
> 
please use better name...reclaim_param_lock or some ?

-Kame


> 
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> ---
>  mm/memcontrol.c |   20 +++++++++++++++++++-
>  1 file changed, 19 insertions(+), 1 deletion(-)
> 
> Index: b/mm/memcontrol.c
> ===================================================================
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -142,6 +142,13 @@ struct mem_cgroup {
>  	 */
>  	struct mem_cgroup_lru_info info;
>  
> +	/*
> +	  Almost mem_cgroup member doesn't need lock.
> +	  (e.g. info is protected by zone lock, stat is per cpu variable)
> +	  However, rest few member need explict lock.
> +	*/
> +	spinlock_t misc_lock;
> +
>  	int	prev_priority;	/* for recording reclaim priority */
>  
>  	/*
> @@ -393,18 +400,28 @@ int mem_cgroup_calc_mapped_ratio(struct 
>   */
>  int mem_cgroup_get_reclaim_priority(struct mem_cgroup *mem)
>  {
> -	return mem->prev_priority;
> +	int prev_priority;
> +
> +	spin_lock(&mem->misc_lock);
> +	prev_priority = mem->prev_priority;
> +	spin_unlock(&mem->misc_lock);
> +
> +	return prev_priority;
>  }
>  
>  void mem_cgroup_note_reclaim_priority(struct mem_cgroup *mem, int priority)
>  {
> +	spin_lock(&mem->misc_lock);
>  	if (priority < mem->prev_priority)
>  		mem->prev_priority = priority;
> +	spin_unlock(&mem->misc_lock);
>  }
>  
>  void mem_cgroup_record_reclaim_priority(struct mem_cgroup *mem, int priority)
>  {
> +	spin_lock(&mem->misc_lock);
>  	mem->prev_priority = priority;
> +	spin_unlock(&mem->misc_lock);
>  }
>  
>  /*
> @@ -1967,6 +1984,7 @@ mem_cgroup_create(struct cgroup_subsys *
>  	}
>  
>  	mem->last_scanned_child = NULL;
> +	spin_lock_init(&mem->misc_lock);
>  
>  	return &mem->css;
>  free_out:
> 
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
