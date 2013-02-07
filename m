Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id AE59B6B0005
	for <linux-mm@kvack.org>; Thu,  7 Feb 2013 03:36:05 -0500 (EST)
Date: Thu, 7 Feb 2013 10:40:26 +0200 (EET)
From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH v2] net: fix functions and variables related to
 netns_ipvs->sysctl_sync_qlen_max
In-Reply-To: <51132A56.60906@cn.fujitsu.com>
Message-ID: <alpine.LFD.2.00.1302070944480.1810@ja.ssi.bg>
References: <51131B88.6040809@cn.fujitsu.com> <51132A56.60906@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, davem@davemloft.net, Simon Horman <horms@verge.net.au>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>


	Hello,

On Thu, 7 Feb 2013, Zhang Yanfei wrote:

> Since the type of netns_ipvs->sysctl_sync_qlen_max has been changed to
> unsigned long, type of its related proc var sync_qlen_max should be changed
> to unsigned long, too. Also the return type of function sysctl_sync_qlen_max().
> 
> Besides, the type of ipvs_master_sync_state->sync_queue_len should also be
> changed to unsigned long.

	v2 looks fine. Thanks! Regarding your question
see below...

> Changelog from V1:
> - change type of ipvs_master_sync_state->sync_queue_len to unsigned long
>   as Simon addressed.
> 
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: David Miller <davem@davemloft.net>
> Cc: Julian Anastasov <ja@ssi.bg>
> Cc: Simon Horman <horms@verge.net.au>
> Signed-off-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
> ---
>  include/net/ip_vs.h            |    6 +++---
>  net/netfilter/ipvs/ip_vs_ctl.c |    4 ++--
>  2 files changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
> index 68c69d5..1d56f92 100644
> --- a/include/net/ip_vs.h
> +++ b/include/net/ip_vs.h
> @@ -874,7 +874,7 @@ struct ip_vs_app {
>  struct ipvs_master_sync_state {
>  	struct list_head	sync_queue;
>  	struct ip_vs_sync_buff	*sync_buff;
> -	int			sync_queue_len;
> +	unsigned long		sync_queue_len;
>  	unsigned int		sync_queue_delay;
>  	struct task_struct	*master_thread;
>  	struct delayed_work	master_wakeup_work;
> @@ -1052,7 +1052,7 @@ static inline int sysctl_sync_ports(struct netns_ipvs *ipvs)
>  	return ACCESS_ONCE(ipvs->sysctl_sync_ports);
>  }
>  
> -static inline int sysctl_sync_qlen_max(struct netns_ipvs *ipvs)
> +static inline unsigned long sysctl_sync_qlen_max(struct netns_ipvs *ipvs)
>  {
>  	return ipvs->sysctl_sync_qlen_max;
>  }
> @@ -1099,7 +1099,7 @@ static inline int sysctl_sync_ports(struct netns_ipvs *ipvs)
>  	return 1;
>  }
>  
> -static inline int sysctl_sync_qlen_max(struct netns_ipvs *ipvs)
> +static inline unsigned long sysctl_sync_qlen_max(struct netns_ipvs *ipvs)
>  {
>  	return IPVS_SYNC_QLEN_MAX;
>  }
> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> index ec664cb..d79a530 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> @@ -1747,9 +1747,9 @@ static struct ctl_table vs_vars[] = {
>  	},
>  	{
>  		.procname	= "sync_qlen_max",
> -		.maxlen		= sizeof(int),
> +		.maxlen		= sizeof(unsigned long),
>  		.mode		= 0644,
> -		.proc_handler	= proc_dointvec,
> +		.proc_handler	= proc_doulongvec_minmax,
>  	},
>  	{
>  		.procname	= "sync_sock_size",
> -- 
> 1.7.1


> Another question about the sysctl_sync_qlen_max:
> This variable is assigned as:
> 
> ipvs->sysctl_sync_qlen_max = nr_free_buffer_pages() / 32;
> 
> The function nr_free_buffer_pages actually means: counts of pages
> which are beyond high watermark within ZONE_DMA and ZONE_NORMAL.
> 
> is it ok to be called here? Some people misused this function because
> the function name was misleading them. I am sorry I am totally not
> familiar with the ipvs code, so I am just asking you about
> this.

	Using nr_free_buffer_pages should be fine here.
We are using it as rough estimation for the number of sync
buffers we can use in NORMAL zones. We are using dev->mtu
for such buffers, so it can take a PAGE_SIZE for a buffer.
We are not interested in HIGHMEM size. high watermarks
should have negliable effect. I'm even not sure whether
we need to clamp it for systems with TBs of memory.

Regards

--
Julian Anastasov <ja@ssi.bg>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
