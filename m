Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 2385F6B004A
	for <linux-mm@kvack.org>; Mon, 27 Feb 2012 19:13:11 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 14C353EE0AE
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 09:13:09 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id E46E645DE52
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 09:13:08 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id C091F45DE54
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 09:13:08 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id B48091DB8037
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 09:13:08 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6A6E91DB803F
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 09:13:08 +0900 (JST)
Date: Tue, 28 Feb 2012 09:11:44 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v3 02/21] memcg: make mm_match_cgroup() hirarchical
Message-Id: <20120228091144.d174ad7b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120223135146.12988.47611.stgit@zurg>
References: <20120223133728.12988.5432.stgit@zurg>
	<20120223135146.12988.47611.stgit@zurg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>

On Thu, 23 Feb 2012 17:51:46 +0400
Konstantin Khlebnikov <khlebnikov@openvz.org> wrote:

> Check mm-owner cgroup membership hierarchically.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>


Ack. but ... see below.

> ---
>  include/linux/memcontrol.h |   11 ++---------
>  mm/memcontrol.c            |   20 ++++++++++++++++++++
>  2 files changed, 22 insertions(+), 9 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 8c4d74f..4822d53 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -87,15 +87,8 @@ extern struct mem_cgroup *try_get_mem_cgroup_from_mm(struct mm_struct *mm);
>  extern struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *memcg);
>  extern struct mem_cgroup *mem_cgroup_from_cont(struct cgroup *cont);
>  
> -static inline
> -int mm_match_cgroup(const struct mm_struct *mm, const struct mem_cgroup *cgroup)
> -{
> -	struct mem_cgroup *memcg;
> -	rcu_read_lock();
> -	memcg = mem_cgroup_from_task(rcu_dereference((mm)->owner));
> -	rcu_read_unlock();
> -	return cgroup == memcg;
> -}
> +extern int mm_match_cgroup(const struct mm_struct *mm,
> +			   const struct mem_cgroup *cgroup);
>  
>  extern struct cgroup_subsys_state *mem_cgroup_css(struct mem_cgroup *memcg);
>  
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index b8039d2..77f5d48 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -821,6 +821,26 @@ struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p)
>  				struct mem_cgroup, css);
>  }
>  
> +/**
> + * mm_match_cgroup - cgroup hierarchy mm membership test
> + * @mm		mm_struct to test
> + * @cgroup	target cgroup
> + *
> + * Returns true if mm belong this cgroup or any its child in hierarchy

belongs to ?

> + */
> +int mm_match_cgroup(const struct mm_struct *mm, const struct mem_cgroup *cgroup)
> +{

Please use "memcg" for representing "memory cgroup" (other function's arguments uses "memcg")

> +	struct mem_cgroup *memcg;

So, rename this as *cur_memcg or some.

> +
> +	rcu_read_lock();
> +	memcg = mem_cgroup_from_task(rcu_dereference((mm)->owner));
> +	while (memcg != cgroup && memcg && memcg->use_hierarchy)
> +		memcg = parent_mem_cgroup(memcg);

IIUC, parent_mem_cgroup() checks mem->res.parent. mem->res.parent is set only when
parent->use_hierarchy == true. Then, 

	while (memcg != cgroup)
		memcg = parent_mem_cgroup(memcg);

will be enough.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
