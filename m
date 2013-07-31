Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id E8B886B0031
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 04:02:26 -0400 (EDT)
Date: Wed, 31 Jul 2013 10:02:25 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 2/4] memcg: rename RESOURCE_MAX to RES_COUNTER_MAX
Message-ID: <20130731080225.GF30514@dhcp22.suse.cz>
References: <1375255885-10648-1-git-send-email-h.huangqiang@huawei.com>
 <1375255885-10648-3-git-send-email-h.huangqiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1375255885-10648-3-git-send-email-h.huangqiang@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qiang Huang <h.huangqiang@huawei.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, handai.szj@taobao.com, lizefan@huawei.com, nishimura@mxp.nes.nec.co.jp, akpm@linux-foundation.org, jeff.liu@oracle.com

On Wed 31-07-13 15:31:23, Qiang Huang wrote:
> RESOURCE_MAX is far too general name, change it to RES_COUNTER_MAX.
> 
> Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
> Signed-off-by: Qiang Huang <h.huangqiang@huawei.com>

Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  include/linux/res_counter.h |  2 +-
>  kernel/res_counter.c        |  8 ++++----
>  mm/memcontrol.c             |  4 ++--
>  net/ipv4/tcp_memcontrol.c   | 10 +++++-----
>  4 files changed, 12 insertions(+), 12 deletions(-)
> 
> diff --git a/include/linux/res_counter.h b/include/linux/res_counter.h
> index 586bc7c..201a697 100644
> --- a/include/linux/res_counter.h
> +++ b/include/linux/res_counter.h
> @@ -54,7 +54,7 @@ struct res_counter {
>  	struct res_counter *parent;
>  };
>  
> -#define RESOURCE_MAX ULLONG_MAX
> +#define RES_COUNTER_MAX ULLONG_MAX
>  
>  /**
>   * Helpers to interact with userspace
> diff --git a/kernel/res_counter.c b/kernel/res_counter.c
> index ff55247..3f0417f 100644
> --- a/kernel/res_counter.c
> +++ b/kernel/res_counter.c
> @@ -17,8 +17,8 @@
>  void res_counter_init(struct res_counter *counter, struct res_counter *parent)
>  {
>  	spin_lock_init(&counter->lock);
> -	counter->limit = RESOURCE_MAX;
> -	counter->soft_limit = RESOURCE_MAX;
> +	counter->limit = RES_COUNTER_MAX;
> +	counter->soft_limit = RES_COUNTER_MAX;
>  	counter->parent = parent;
>  }
>  
> @@ -182,12 +182,12 @@ int res_counter_memparse_write_strategy(const char *buf,
>  {
>  	char *end;
>  
> -	/* return RESOURCE_MAX(unlimited) if "-1" is specified */
> +	/* return RES_COUNTER_MAX(unlimited) if "-1" is specified */
>  	if (*buf == '-') {
>  		*res = simple_strtoull(buf + 1, &end, 10);
>  		if (*res != 1 || *end != '\0')
>  			return -EINVAL;
> -		*res = RESOURCE_MAX;
> +		*res = RES_COUNTER_MAX;
>  		return 0;
>  	}
>  
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 1947218..f621cf5 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -5117,7 +5117,7 @@ static int memcg_update_kmem_limit(struct cgroup *cont, u64 val)
>  	 */
>  	mutex_lock(&memcg_create_mutex);
>  	mutex_lock(&set_limit_mutex);
> -	if (!memcg->kmem_account_flags && val != RESOURCE_MAX) {
> +	if (!memcg->kmem_account_flags && val != RES_COUNTER_MAX) {
>  		if (cgroup_task_count(cont) || memcg_has_children(memcg)) {
>  			ret = -EBUSY;
>  			goto out;
> @@ -5127,7 +5127,7 @@ static int memcg_update_kmem_limit(struct cgroup *cont, u64 val)
>  
>  		ret = memcg_update_cache_sizes(memcg);
>  		if (ret) {
> -			res_counter_set_limit(&memcg->kmem, RESOURCE_MAX);
> +			res_counter_set_limit(&memcg->kmem, RES_COUNTER_MAX);
>  			goto out;
>  		}
>  		static_key_slow_inc(&memcg_kmem_enabled_key);
> diff --git a/net/ipv4/tcp_memcontrol.c b/net/ipv4/tcp_memcontrol.c
> index da14436..90550f4 100644
> --- a/net/ipv4/tcp_memcontrol.c
> +++ b/net/ipv4/tcp_memcontrol.c
> @@ -87,8 +87,8 @@ static int tcp_update_limit(struct mem_cgroup *memcg, u64 val)
>  	if (!cg_proto)
>  		return -EINVAL;
>  
> -	if (val > RESOURCE_MAX)
> -		val = RESOURCE_MAX;
> +	if (val > RES_COUNTER_MAX)
> +		val = RES_COUNTER_MAX;
>  
>  	tcp = tcp_from_cgproto(cg_proto);
>  
> @@ -101,9 +101,9 @@ static int tcp_update_limit(struct mem_cgroup *memcg, u64 val)
>  		tcp->tcp_prot_mem[i] = min_t(long, val >> PAGE_SHIFT,
>  					     net->ipv4.sysctl_tcp_mem[i]);
>  
> -	if (val == RESOURCE_MAX)
> +	if (val == RES_COUNTER_MAX)
>  		clear_bit(MEMCG_SOCK_ACTIVE, &cg_proto->flags);
> -	else if (val != RESOURCE_MAX) {
> +	else if (val != RES_COUNTER_MAX) {
>  		/*
>  		 * The active bit needs to be written after the static_key
>  		 * update. This is what guarantees that the socket activation
> @@ -187,7 +187,7 @@ static u64 tcp_cgroup_read(struct cgroup *cont, struct cftype *cft)
>  
>  	switch (cft->private) {
>  	case RES_LIMIT:
> -		val = tcp_read_stat(memcg, RES_LIMIT, RESOURCE_MAX);
> +		val = tcp_read_stat(memcg, RES_LIMIT, RES_COUNTER_MAX);
>  		break;
>  	case RES_USAGE:
>  		val = tcp_read_usage(memcg);
> -- 
> 1.8.3
> 
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
