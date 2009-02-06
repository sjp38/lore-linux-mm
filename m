Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 994626B003D
	for <linux-mm@kvack.org>; Thu,  5 Feb 2009 21:08:24 -0500 (EST)
Message-ID: <498B9B6C.3000808@cn.fujitsu.com>
Date: Fri, 06 Feb 2009 10:07:40 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] Reduce size of swap_cgroup by CSS ID
References: <20090205185959.7971dee4.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090205185959.7971dee4.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> +/*
> + * A helper function to get mem_cgroup from ID. must be called under
> + * rcu_read_lock(). Because css_tryget() is called under this, css_put
> + * should be called later.
> + */
> +static struct mem_cgroup *mem_cgroup_lookup_get(unsigned short id)
> +{
> +	struct cgroup_subsys_state *css;
> +
> +	/* ID 0 is unused ID */
> +	if (!id)
> +		return NULL;
> +	css = css_lookup(&mem_cgroup_subsys, id);
> +	if (css && css_tryget(css))
> +		return container_of(css, struct mem_cgroup, css);
> +	return NULL;
> +}

the returned mem_cgroup needn't be protected by rcu_read_lock(), so I
think this is better:
	rcu_read_lock();
	css = css_lookup(&mem_cgroup_subsys, id);
	rcu_read_unlock();
and no lock is needed when calling mem_cgroup_lookup_get().

>   * Returns old value at success, NULL at failure.
>   * (Of course, old value can be NULL.)
>   */
> -struct mem_cgroup *swap_cgroup_record(swp_entry_t ent, struct mem_cgroup *mem)
> +unsigned short swap_cgroup_record(swp_entry_t ent, unsigned short id)

kernel-doc needs to be updated

>   * lookup_swap_cgroup - lookup mem_cgroup tied to swap entry
>   * @ent: swap entry to be looked up.
>   *
> - * Returns pointer to mem_cgroup at success. NULL at failure.
> + * Returns CSS ID of mem_cgroup at success. NULL at failure.

s/NULL/0/

>   */
> -struct mem_cgroup *lookup_swap_cgroup(swp_entry_t ent)
> +unsigned short lookup_swap_cgroup(swp_entry_t ent)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
