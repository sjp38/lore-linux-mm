Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id 98D5B6B029D
	for <linux-mm@kvack.org>; Tue, 13 Dec 2011 20:07:17 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 8D79B3EE0BD
	for <linux-mm@kvack.org>; Wed, 14 Dec 2011 10:07:15 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 718F645DF59
	for <linux-mm@kvack.org>; Wed, 14 Dec 2011 10:07:15 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3C1EA45DF58
	for <linux-mm@kvack.org>; Wed, 14 Dec 2011 10:07:15 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2374C1DB803F
	for <linux-mm@kvack.org>; Wed, 14 Dec 2011 10:07:15 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C0808E08001
	for <linux-mm@kvack.org>; Wed, 14 Dec 2011 10:07:14 +0900 (JST)
Date: Wed, 14 Dec 2011 10:06:00 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch] oom, memcg: fix exclusion of memcg threads after they
 have detached their mm
Message-Id: <20111214100600.6f5975ba.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1112131659100.32369@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1112131659100.32369@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org

On Tue, 13 Dec 2011 16:59:32 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> The oom killer relies on logic that identifies threads that have already
> been oom killed when scanning the tasklist and, if found, deferring until
> such threads have exited.  This is done by checking for any candidate
> threads that have the TIF_MEMDIE bit set.
> 
> For memcg ooms, candidate threads are first found by calling
> task_in_mem_cgroup() since the oom killer should not defer if there's an
> oom killed thread in another memcg.
> 
> Unfortunately, task_in_mem_cgroup() excludes threads if they have
> detached their mm in the process of exiting so TIF_MEMDIE is never
> detected for such conditions.  This is different for global, mempolicy,
> and cpuset oom conditions where a detached mm is only excluded after
> checking for TIF_MEMDIE and deferring, if necessary, in
> select_bad_process().
> 
> The fix is to return true if a task has a detached mm but is still in the
> memcg that is currently oom.  This will allow the oom killer to
> appropriately defer rather than kill unnecessarily or, in the worst case,
> panic the machine if nothing else is available to kill.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  mm/memcontrol.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1110,7 +1110,7 @@ int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *memcg)
>  
>  	p = find_lock_task_mm(task);
>  	if (!p)
> -		return 0;
> +		return mem_cgroup_from_task(task) == memcg;
>  	curr = try_get_mem_cgroup_from_mm(p->mm);
>  	task_unlock(p);
>  	if (!curr)

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
