Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id BF9656B004F
	for <linux-mm@kvack.org>; Tue, 13 Jan 2009 03:34:09 -0500 (EST)
Message-ID: <496C51C8.5040900@cn.fujitsu.com>
Date: Tue, 13 Jan 2009 16:33:12 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 3/4] memcg: fix OOM KILL under hierarchy
References: <20090108182556.621e3ee6.kamezawa.hiroyu@jp.fujitsu.com> <20090108183207.26d88794.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090108183207.26d88794.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "menage@google.com" <menage@google.com>
List-ID: <linux-mm.kvack.org>

> -int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *mem)
> +static int
> +mm_match_cgroup_hierarchy(struct mm_struct *mm, struct mem_cgroup *mem)
> +{
> +	struct mem_cgroup *curr;
> +	int ret;
> +
> +	if (!mm)
> +		return 0;
> +	rcu_read_lock();
> +	curr = mem_cgroup_from_task(mm->owner);

curr can be NULL ?

> +	if (mem->use_hierarchy)
> +		ret = css_is_ancestor(&curr->css, &mem->css);
> +	else
> +		ret = (curr == mem);
> +	rcu_read_unlock();
> +	return ret;
> +}
> +

...

> +void mem_cgroup_update_oom_jiffies(struct mem_cgroup *mem)
> +{
> +	struct mem_cgroup *cur;
> +	struct cgroup_subsys_state *css;
> +	int id, found;
> +
> +	if (!mem->use_hierarchy) {
> +		mem->last_oom_jiffies = jiffies;
> +		return;
> +	}
> +
> +	id = 0;
> +	rcu_read_lock();
> +	while (1) {
> +		css = css_get_next(&mem_cgroup_subsys, id, &mem->css, &found);
> +		if (!css)
> +			break;
> +		if (css_tryget(css)) {
> +			cur = container_of(css, struct mem_cgroup, css);
> +			cur->last_oom_jiffies = jiffies;
> +			css_put(css);
> +		}
> +		id = found + 1;
> +	}
> +	rcu_read_unlock();
> +	return;

redundant "return"

> +}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
