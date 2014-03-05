Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id D31536B0037
	for <linux-mm@kvack.org>; Wed,  5 Mar 2014 16:18:00 -0500 (EST)
Received: by mail-pd0-f182.google.com with SMTP id g10so1577104pdj.27
        for <linux-mm@kvack.org>; Wed, 05 Mar 2014 13:18:00 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id ha5si3379266pbc.210.2014.03.05.13.17.59
        for <linux-mm@kvack.org>;
        Wed, 05 Mar 2014 13:17:59 -0800 (PST)
Date: Wed, 5 Mar 2014 13:17:57 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 04/11] mm, memcg: add tunable for oom reserves
Message-Id: <20140305131757.ad538637c096266664c45f04@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.02.1403041955050.8067@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1403041952170.8067@chino.kir.corp.google.com>
	<alpine.DEB.2.02.1403041955050.8067@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Tejun Heo <tj@kernel.org>, Mel Gorman <mgorman@suse.de>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, Tim Hockin <thockin@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-doc@vger.kernel.org

On Tue, 4 Mar 2014 19:59:19 -0800 (PST) David Rientjes <rientjes@google.com> wrote:

> Userspace needs a way to define the amount of memory reserves that
> processes handling oom conditions may utilize.  This patch adds a per-
> memcg oom reserve field and file, memory.oom_reserve_in_bytes, to
> manipulate its value.
> 
> If currently utilized memory reserves are attempted to be reduced by
> writing a smaller value to memory.oom_reserve_in_bytes, it will fail with
> -EBUSY until some memory is uncharged.
> 
> ...
>
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -315,6 +315,9 @@ struct mem_cgroup {
>  	/* OOM-Killer disable */
>  	int		oom_kill_disable;
>  
> +	/* reserves for handling oom conditions, protected by res.lock */
> +	unsigned long long	oom_reserve;

Units?  bytes, I assume.

>  	/* set when res.limit == memsw.limit */
>  	bool		memsw_is_minimum;
>  
> @@ -5936,6 +5939,51 @@ static int mem_cgroup_oom_control_write(struct cgroup_subsys_state *css,
>  	return 0;
>  }
>  
> +static int mem_cgroup_resize_oom_reserve(struct mem_cgroup *memcg,
> +					 unsigned long long new_limit)
> +{
> +	struct res_counter *res = &memcg->res;
> +	u64 limit, usage;
> +	int ret = 0;

The code mixes u64's and unsigned long longs in inexplicable ways. 
Suggest using u64 throughout.

> +	spin_lock(&res->lock);
> +	limit = res->limit;
> +	usage = res->usage;
> +
> +	if (usage > limit && usage - limit > new_limit) {
> +		ret = -EBUSY;
> +		goto out;
> +	}
> +
> +	memcg->oom_reserve = new_limit;
> +out:
> +	spin_unlock(&res->lock);
> +	return ret;
> +}
>
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
