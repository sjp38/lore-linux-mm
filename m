Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate5.de.ibm.com (8.13.8/8.13.8) with ESMTP id m91BcV9e053952
	for <linux-mm@kvack.org>; Wed, 1 Oct 2008 11:38:31 GMT
Received: from d12av04.megacenter.de.ibm.com (d12av04.megacenter.de.ibm.com [9.149.165.229])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m91BcV5i3555448
	for <linux-mm@kvack.org>; Wed, 1 Oct 2008 13:38:31 +0200
Received: from d12av04.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av04.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m91BcOUn017778
	for <linux-mm@kvack.org>; Wed, 1 Oct 2008 13:38:26 +0200
Message-ID: <48E3612E.1020607@fr.ibm.com>
Date: Wed, 01 Oct 2008 13:38:22 +0200
From: Daniel Lezcano <dlezcano@fr.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 18/30] netvm: INET reserves.
References: <20080724140042.408642539@chello.nl> <20080724141530.573585429@chello.nl>
In-Reply-To: <20080724141530.573585429@chello.nl>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no, Pekka Enberg <penberg@cs.helsinki.fi>, Neil Brown <neilb@suse.de>
List-ID: <linux-mm.kvack.org>

> Add reserves for INET.
> 
> The two big users seem to be the route cache and ip-fragment cache.
> 
> Reserve the route cache under generic RX reserve, its usage is bounded by
> the high reclaim watermark, and thus does not need further accounting.
> 
> Reserve the ip-fragement caches under SKB data reserve, these add to the
> SKB RX limit. By ensuring we can at least receive as much data as fits in
> the reassmbly line we avoid fragment attack deadlocks.
> 
> Adds to the reserve tree:
> 
>   total network reserve      
>     network TX reserve       
>       protocol TX pages      
>     network RX reserve       
> +     IPv6 route cache       
> +     IPv4 route cache       
>       SKB data reserve       
> +       IPv6 fragment cache  
> +       IPv4 fragment cache  
> 
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> ---
>  include/net/inet_frag.h  |    7 +++
>  include/net/netns/ipv6.h |    4 ++
>  net/ipv4/inet_fragment.c |    3 +
>  net/ipv4/ip_fragment.c   |   89 +++++++++++++++++++++++++++++++++++++++++++++--
>  net/ipv4/route.c         |   72 +++++++++++++++++++++++++++++++++++++-
>  net/ipv6/af_inet6.c      |   20 +++++++++-
>  net/ipv6/reassembly.c    |   88 +++++++++++++++++++++++++++++++++++++++++++++-
>  net/ipv6/route.c         |   66 ++++++++++++++++++++++++++++++++++
>  8 files changed, 341 insertions(+), 8 deletions(-)
> 

Sorry for the delay ...

[ cut ]

I removed a big portion of code because the remarks below apply to the 
rest of the code.

> +static int sysctl_intvec_route(struct ctl_table *table,
> +		int __user *name, int nlen,
> +		void __user *oldval, size_t __user *oldlenp,
> +		void __user *newval, size_t newlen)
> +{
> +	struct net *net = current->nsproxy->net_ns;

I think you can use the container_of and get rid of using 
current->nsproxy->net_ns.

	struct net *net = container_of(table->data, struct net,
				ipv6.sysctl.ip6_rt_max_size);

Another solution could be to pass directly the sysctl structure pointer 
in the table data instead of
".data = &init_net.ipv6.sysctl.ip6_rt_max_size" when initializing the 
sysctl table below. But you have to set the right field value yourself.

> +	int write = (newval && newlen);
> +	int new_size, ret;
> +
> +	mutex_lock(&net->ipv6.sysctl.ip6_rt_lock);
> +
> +	if (write)
> +		table->data = &new_size;
> +
> +	ret = sysctl_intvec(table, name, nlen, oldval, oldlenp, newval, newlen);
> +
> +	if (!ret && write) {
> +		ret = mem_reserve_kmem_cache_set(&net->ipv6.ip6_rt_reserve,
> +				net->ipv6.ip6_dst_ops.kmem_cachep, new_size);
> +		if (!ret)
> +			net->ipv6.sysctl.ip6_rt_max_size = new_size;
> +	}
> +
> +	if (write)
> +		table->data = &net->ipv6.sysctl.ip6_rt_max_size;
> +
> +	mutex_unlock(&net->ipv6.sysctl.ip6_rt_lock);
> +
> +	return ret;
> +}

Dancing with the table->data looks safe but it is not very nice.
Isn't possible to use a temporary table like in the function 
"ipv4_sysctl_local_port_range" ?

>  ctl_table ipv6_route_table_template[] = {
>  	{
>  		.procname	=	"flush",
> @@ -2520,7 +2581,8 @@ ctl_table ipv6_route_table_template[] = 
>  		.data		=	&init_net.ipv6.sysctl.ip6_rt_max_size,
>  		.maxlen		=	sizeof(int),
>  		.mode		=	0644,
> -		.proc_handler	=	&proc_dointvec,
> +		.proc_handler	=	&proc_dointvec_route,
> +		.strategy	= 	&sysctl_intvec_route,
>  	},
>  	{
>  		.ctl_name	=	NET_IPV6_ROUTE_GC_MIN_INTERVAL,
> @@ -2608,6 +2670,8 @@ struct ctl_table *ipv6_route_sysctl_init
>  		table[8].data = &net->ipv6.sysctl.ip6_rt_min_advmss;
>  	}
> 
> +	mutex_init(&net->ipv6.sysctl.ip6_rt_lock);
> +
>  	return table;
>  }
>  #endif
> Index: linux-2.6/include/net/inet_frag.h
> ===================================================================
> --- linux-2.6.orig/include/net/inet_frag.h
> +++ linux-2.6/include/net/inet_frag.h
> @@ -1,6 +1,9 @@
>  #ifndef __NET_FRAG_H__
>  #define __NET_FRAG_H__
> 
> +#include <linux/reserve.h>
> +#include <linux/mutex.h>
> +
>  struct netns_frags {
>  	int			nqueues;
>  	atomic_t		mem;
> @@ -10,6 +13,10 @@ struct netns_frags {
>  	int			timeout;
>  	int			high_thresh;
>  	int			low_thresh;
> +
> +	/* reserves */
> +	struct mutex		lock;
> +	struct mem_reserve	reserve;
>  };
> 
>  struct inet_frag_queue {
> Index: linux-2.6/net/ipv4/inet_fragment.c
> ===================================================================
> --- linux-2.6.orig/net/ipv4/inet_fragment.c
> +++ linux-2.6/net/ipv4/inet_fragment.c
> @@ -19,6 +19,7 @@
>  #include <linux/random.h>
>  #include <linux/skbuff.h>
>  #include <linux/rtnetlink.h>
> +#include <linux/reserve.h>
> 
>  #include <net/inet_frag.h>
> 
> @@ -74,6 +75,8 @@ void inet_frags_init_net(struct netns_fr
>  	nf->nqueues = 0;
>  	atomic_set(&nf->mem, 0);
>  	INIT_LIST_HEAD(&nf->lru_list);
> +	mutex_init(&nf->lock);
> +	mem_reserve_init(&nf->reserve, "IP fragement cache", NULL);
>  }
>  EXPORT_SYMBOL(inet_frags_init_net);
> 
> Index: linux-2.6/include/net/netns/ipv6.h
> ===================================================================
> --- linux-2.6.orig/include/net/netns/ipv6.h
> +++ linux-2.6/include/net/netns/ipv6.h
> @@ -24,6 +24,8 @@ struct netns_sysctl_ipv6 {
>  	int ip6_rt_mtu_expires;
>  	int ip6_rt_min_advmss;
>  	int icmpv6_time;
> +
> +	struct mutex ip6_rt_lock;
>  };
> 
>  struct netns_ipv6 {
> @@ -55,5 +57,7 @@ struct netns_ipv6 {
>  	struct sock             *ndisc_sk;
>  	struct sock             *tcp_sk;
>  	struct sock             *igmp_sk;
> +
> +	struct mem_reserve	ip6_rt_reserve;
>  };
>  #endif
> Index: linux-2.6/net/ipv6/af_inet6.c
> ===================================================================
> --- linux-2.6.orig/net/ipv6/af_inet6.c
> +++ linux-2.6/net/ipv6/af_inet6.c
> @@ -851,6 +851,20 @@ static int inet6_net_init(struct net *ne
>  	net->ipv6.sysctl.ip6_rt_min_advmss = IPV6_MIN_MTU - 20 - 40;
>  	net->ipv6.sysctl.icmpv6_time = 1*HZ;
> 
> +	mem_reserve_init(&net->ipv6.ip6_rt_reserve, "IPv6 route cache",
> +			 &net_rx_reserve);
> +	/*
> +	 * XXX: requires that net->ipv6.ip6_dst_ops is already set-up
> +	 *      but afaikt its impossible to order the various
> +	 *      pernet_subsys calls so that this one is done after
> +	 *      ip6_route_net_init().
> +	 */

As this code seems related to the routes, is there a particular reason 
to not put it at the end of "ip6_route_net_init" function ? You will be 
sure "net->ipv6.ip6_dst_ops is already set-up", no ?

> +	err = mem_reserve_kmem_cache_set(&net->ipv6.ip6_rt_reserve,
> +			net->ipv6.ip6_dst_ops.kmem_cachep,
> +			net->ipv6.sysctl.ip6_rt_max_size);
> +	if (err)
> +		goto reserve_fail;
> +
>  #ifdef CONFIG_PROC_FS
>  	err = udp6_proc_init(net);
>  	if (err)
> @@ -861,8 +875,8 @@ static int inet6_net_init(struct net *ne
>  	err = ac6_proc_init(net);
>  	if (err)
>  		goto proc_ac6_fail;
> -out:
>  #endif
> +out:
>  	return err;
> 
>  #ifdef CONFIG_PROC_FS
> @@ -870,8 +884,10 @@ proc_ac6_fail:
>  	tcp6_proc_exit(net);
>  proc_tcp6_fail:
>  	udp6_proc_exit(net);
> -	goto out;
>  #endif
> +reserve_fail:
> +	mem_reserve_disconnect(&net->ipv6.ip6_rt_reserve);

Idem.

> +	goto out;
>  }
> 
>  static void inet6_net_exit(struct net *net)

Isn't "mem_reserve_disconnect" missing here ? (but going to 
ip6_route_net_exit)


I hope this review helped :)

Thanks
	--Daniel


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
