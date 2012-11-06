Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 142806B005A
	for <linux-mm@kvack.org>; Mon,  5 Nov 2012 19:23:32 -0500 (EST)
Date: Mon, 5 Nov 2012 16:23:30 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v6 18/29] Allocate memory for memcg caches whenever a
 new memcg appears
Message-Id: <20121105162330.4aa629f8.akpm@linux-foundation.org>
In-Reply-To: <1351771665-11076-19-git-send-email-glommer@parallels.com>
References: <1351771665-11076-1-git-send-email-glommer@parallels.com>
	<1351771665-11076-19-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Suleiman Souhlal <suleiman@google.com>

On Thu,  1 Nov 2012 16:07:34 +0400
Glauber Costa <glommer@parallels.com> wrote:

> Every cache that is considered a root cache (basically the "original" caches,
> tied to the root memcg/no-memcg) will have an array that should be large enough
> to store a cache pointer per each memcg in the system.
> 
> Theoreticaly, this is as high as 1 << sizeof(css_id), which is currently in the
> 64k pointers range. Most of the time, we won't be using that much.
> 
> What goes in this patch, is a simple scheme to dynamically allocate such an
> array, in order to minimize memory usage for memcg caches. Because we would
> also like to avoid allocations all the time, at least for now, the array will
> only grow. It will tend to be big enough to hold the maximum number of
> kmem-limited memcgs ever achieved.
> 
> We'll allocate it to be a minimum of 64 kmem-limited memcgs. When we have more
> than that, we'll start doubling the size of this array every time the limit is
> reached.
> 
> Because we are only considering kmem limited memcgs, a natural point for this
> to happen is when we write to the limit. At that point, we already have
> set_limit_mutex held, so that will become our natural synchronization
> mechanism.
> 
> ...
>
> +static struct ida kmem_limited_groups;

Could use DEFINE_IDA() here

>
> ...
>
>  static int memcg_init_kmem(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
>  {
> +	int ret;
> +
>  	memcg->kmemcg_id = -1;
> -	memcg_propagate_kmem(memcg);
> +	ret = memcg_propagate_kmem(memcg);
> +	if (ret)
> +		return ret;
> +
> +	if (mem_cgroup_is_root(memcg))
> +		ida_init(&kmem_limited_groups);

and zap this?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
