Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id DC22B6B005A
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 17:34:20 -0400 (EDT)
Received: by dakp5 with SMTP id p5so6010905dak.14
        for <linux-mm@kvack.org>; Fri, 29 Jun 2012 14:34:20 -0700 (PDT)
Date: Fri, 29 Jun 2012 14:34:17 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC][PATCH 1/2] add res_counter_usage_safe
In-Reply-To: <4FEC300A.7040209@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1206291433480.11416@chino.kir.corp.google.com>
References: <4FEC300A.7040209@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>

On Thu, 28 Jun 2012, Kamezawa Hiroyuki wrote:

> diff --git a/include/linux/res_counter.h b/include/linux/res_counter.h
> index 7d7fbe2..a6f8cc5 100644
> --- a/include/linux/res_counter.h
> +++ b/include/linux/res_counter.h
> @@ -226,4 +226,6 @@ res_counter_set_soft_limit(struct res_counter *cnt,
>  	return 0;
>  }
>  
> +u64 res_counter_usage_safe(struct res_counter *cnt);
> +
>  #endif
> diff --git a/kernel/res_counter.c b/kernel/res_counter.c
> index ad581aa..e84149b 100644
> --- a/kernel/res_counter.c
> +++ b/kernel/res_counter.c
> @@ -171,6 +171,21 @@ u64 res_counter_read_u64(struct res_counter *counter, int member)
>  }
>  #endif
>  
> +/*
> + * Returns usage. If usage > limit, limit is returned.
> + * This is useful not to break user experiance if the excess
> + * is temporal.

s/temporal/temporary/

> + */
> +u64 res_counter_usage_safe(struct res_counter *counter)
> +{
> +	u64 usage, limit;
> +
> +	limit = res_counter_read_u64(counter, RES_LIMIT);
> +	usage = res_counter_read_u64(counter, RES_USAGE);
> +
> +	return min(usage, limit);
> +}
> +
>  int res_counter_memparse_write_strategy(const char *buf,
>  					unsigned long long *res)
>  {
> diff --git a/net/ipv4/tcp_memcontrol.c b/net/ipv4/tcp_memcontrol.c
> index b6f3583..a73dce6 100644
> --- a/net/ipv4/tcp_memcontrol.c
> +++ b/net/ipv4/tcp_memcontrol.c
> @@ -180,7 +180,7 @@ static u64 tcp_read_usage(struct mem_cgroup *memcg)
>  		return atomic_long_read(&tcp_memory_allocated) << PAGE_SHIFT;
>  
>  	tcp = tcp_from_cgproto(cg_proto);
> -	return res_counter_read_u64(&tcp->tcp_memory_allocated, RES_USAGE);
> +	return res_counter_usage_safe(&tcp->tcp_memory_allocated);
>  }
>  
>  static u64 tcp_cgroup_read(struct cgroup *cont, struct cftype *cft)

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
