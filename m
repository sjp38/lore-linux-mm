Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 267DD5F0040
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 21:09:43 -0400 (EDT)
Date: Wed, 20 Oct 2010 09:50:56 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH v3 07/11] memcg: add dirty limits to mem_cgroup
Message-Id: <20101020095056.48098b34.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <1287448784-25684-8-git-send-email-gthelen@google.com>
References: <1287448784-25684-1-git-send-email-gthelen@google.com>
	<1287448784-25684-8-git-send-email-gthelen@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

> +static unsigned long long
> +memcg_hierarchical_free_pages(struct mem_cgroup *mem)
> +{
> +	struct cgroup *cgroup;
> +	unsigned long long min_free, free;
> +
> +	min_free = res_counter_read_u64(&mem->res, RES_LIMIT) -
> +		res_counter_read_u64(&mem->res, RES_USAGE);
> +	cgroup = mem->css.cgroup;
> +	if (!mem->use_hierarchy)
> +		goto out;
> +
> +	while (cgroup->parent) {
> +		cgroup = cgroup->parent;
> +		mem = mem_cgroup_from_cont(cgroup);
> +		if (!mem->use_hierarchy)
> +			break;
> +		free = res_counter_read_u64(&mem->res, RES_LIMIT) -
> +			res_counter_read_u64(&mem->res, RES_USAGE);
> +		min_free = min(min_free, free);
> +	}
> +out:
> +	/* Translate free memory in pages */
> +	return min_free >> PAGE_SHIFT;
> +}
> +
I think you can simplify this function using parent_mem_cgroup().

	unsigned long free, min_free = ULLONG_MAX;

	while (mem) {
		free = res_counter_read_u64(&mem->res, RES_LIMIT) -
			res_counter_read_u64(&mem->res, RES_USAGE);
		min_free = min(min_free, free);
		mem = parent_mem_cgroup();
	}

	/* Translate free memory in pages */
	return min_free >> PAGE_SHIFT;

And, IMHO, we should return min(global_page_state(NR_FREE_PAGES), min_free >> PAGE_SHIFT).
Because we are allowed to set no-limit(or a very big limit) in memcg,
so min_free can be very big if we don't set a limit against all the memcg's in hierarchy.


Thanks,
Dasiuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
