Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 550366B0055
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 20:30:28 -0500 (EST)
Message-ID: <496FE30C.1090300@cn.fujitsu.com>
Date: Fri, 16 Jan 2009 09:29:48 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/4] memcg: hierarchical reclaim by CSS ID
References: <20090115192120.9956911b.kamezawa.hiroyu@jp.fujitsu.com> <20090115192943.7c1df53a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090115192943.7c1df53a.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "menage@google.com" <menage@google.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

>  /*
> - * Dance down the hierarchy if needed to reclaim memory. We remember the
> - * last child we reclaimed from, so that we don't end up penalizing
> - * one child extensively based on its position in the children list.
> + * Visit the first child (need not be the first child as per the ordering
> + * of the cgroup list, since we track last_scanned_child) of @mem and use
> + * that to reclaim free pages from.
> + */
> +static struct mem_cgroup *
> +mem_cgroup_select_victim(struct mem_cgroup *root_mem)
> +{
> +	struct mem_cgroup *ret = NULL;
> +	struct cgroup_subsys_state *css;
> +	int nextid, found;
> +
> +	if (!root_mem->use_hierarchy) {
> +		spin_lock(&root_mem->reclaim_param_lock);
> +		root_mem->scan_age++;
> +		spin_unlock(&root_mem->reclaim_param_lock);
> +		css_get(&root_mem->css);
> +		ret = root_mem;
> +	}
> +
> +	while (!ret) {
> +		rcu_read_lock();
> +		nextid = root_mem->last_scanned_child + 1;
> +		css = css_get_next(&mem_cgroup_subsys, nextid, &root_mem->css,
> +				   &found);
> +		if (css && css_is_populated(css) && css_tryget(css))

I don't see why you need to check css_is_populated(css) ?

> +			ret = container_of(css, struct mem_cgroup, css);
> +
> +		rcu_read_unlock();
> +		/* Updates scanning parameter */
> +		spin_lock(&root_mem->reclaim_param_lock);
> +		if (!css) {
> +			/* this means start scan from ID:1 */
> +			root_mem->last_scanned_child = 0;
> +			root_mem->scan_age++;
> +		} else
> +			root_mem->last_scanned_child = found;
> +		spin_unlock(&root_mem->reclaim_param_lock);
> +	}
> +
> +	return ret;
> +}
> +

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
