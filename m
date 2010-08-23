Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id D2F7A6B0203
	for <linux-mm@kvack.org>; Mon, 23 Aug 2010 01:52:41 -0400 (EDT)
Date: Mon, 23 Aug 2010 14:32:37 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH] memcg: use ID in page_cgroup
Message-Id: <20100823143237.b7822ffc.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20100820190132.43684862.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100820185552.426ff12e.kamezawa.hiroyu@jp.fujitsu.com>
	<20100820190132.43684862.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, gthelen@google.com, m-ikeda@ds.jp.nec.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, kamezawa.hiroyuki@gmail.com, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Fri, 20 Aug 2010 19:01:32 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> 
> I have an idea to remove page_cgroup->page pointer, 8bytes reduction per page.
> But it will be after this work.
Another off topic. I think we can reduce the size of mem_cgroup by packing
some boolean members into one "unsinged long flags".

> @@ -300,12 +300,13 @@ static atomic_t mem_cgroup_num;
>  #define NR_MEMCG_GROUPS (CONFIG_MEM_CGROUP_MAX_GROUPS + 1)
>  static struct mem_cgroup *mem_cgroups[NR_MEMCG_GROUPS] __read_mostly;
>  
> -/* Must be called under rcu_read_lock */
> -static struct mem_cgroup *id_to_memcg(unsigned short id)
> +/* Must be called under rcu_read_lock, set safe==true if under lock */
Do you mean, "Set safe==true if we can ensure by some locks that the id can be
safely dereferenced without rcu_read_lock", right ?

> +static struct mem_cgroup *id_to_memcg(unsigned short id, bool safe)
>  {
>  	struct mem_cgroup *ret;
>  	/* see mem_cgroup_free() */
> -	ret = rcu_dereference_check(mem_cgroups[id], rch_read_lock_held());
> +	ret = rcu_dereference_check(mem_cgroups[id],
> +				rch_read_lock_held() || safe);
>  	if (likely(ret && ret->valid))
>  		return ret;
>  	return NULL;

(snip)
> @@ -723,6 +729,11 @@ static inline bool mem_cgroup_is_root(st
>  	return (mem == root_mem_cgroup);
>  }
>  
> +static inline bool mem_cgroup_is_rootid(unsigned short id)
> +{
> +	return (id == 1);
> +}
> +
It might be better to add

	BUG_ON(newid->id != 1)

in cgroup.c::cgroup_init_idr().


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
