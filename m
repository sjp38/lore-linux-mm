Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 7A3A46B025C
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 09:38:41 -0500 (EST)
Received: by wmec201 with SMTP id c201so76468638wme.1
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 06:38:41 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id b20si11634357wjr.226.2015.12.09.06.38.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Dec 2015 06:38:40 -0800 (PST)
Date: Wed, 9 Dec 2015 09:38:32 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH -mm] net: drop tcp_memcontrol.c
Message-ID: <20151209143832.GB21506@cmpxchg.org>
References: <1449665400-23013-1-git-send-email-vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1449665400-23013-1-git-send-email-vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org

On Wed, Dec 09, 2015 at 03:50:00PM +0300, Vladimir Davydov wrote:
> tcp_memcontrol.c only contains legacy memory.tcp.kmem.* file definitions
> and mem_cgroup->tcp_mem init/destroy stuff. This doesn't belong to
> network subsys. Let's move it to memcontrol.c. This also allows us to
> reuse generic code for handling legacy memcg files.
> 
> Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>

This looks great, the legacy code really doesn't get in the way.

I'm sure the network folks appreciate this as well. CC'd and full
quote below.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

> ---
>  include/net/tcp_memcontrol.h |   7 --
>  mm/memcontrol.c              | 104 +++++++++++++++++++---
>  net/ipv4/Makefile            |   1 -
>  net/ipv4/sysctl_net_ipv4.c   |   1 -
>  net/ipv4/tcp_ipv4.c          |   1 -
>  net/ipv4/tcp_memcontrol.c    | 200 -------------------------------------------
>  net/ipv6/tcp_ipv6.c          |   1 -
>  7 files changed, 93 insertions(+), 222 deletions(-)
>  delete mode 100644 include/net/tcp_memcontrol.h
>  delete mode 100644 net/ipv4/tcp_memcontrol.c
> 
> diff --git a/include/net/tcp_memcontrol.h b/include/net/tcp_memcontrol.h
> deleted file mode 100644
> index dc2da2f8c8b2..000000000000
> --- a/include/net/tcp_memcontrol.h
> +++ /dev/null
> @@ -1,7 +0,0 @@
> -#ifndef _TCP_MEMCG_H
> -#define _TCP_MEMCG_H
> -
> -int tcp_init_cgroup(struct mem_cgroup *memcg);
> -void tcp_destroy_cgroup(struct mem_cgroup *memcg);
> -
> -#endif /* _TCP_MEMCG_H */
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 810ba0929a18..7f5c6abf5421 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -66,7 +66,6 @@
>  #include "internal.h"
>  #include <net/sock.h>
>  #include <net/ip.h>
> -#include <net/tcp_memcontrol.h>
>  #include "slab.h"
>  
>  #include <asm/uaccess.h>
> @@ -242,6 +241,7 @@ enum res_type {
>  	_MEMSWAP,
>  	_OOM_TYPE,
>  	_KMEM,
> +	_TCP,
>  };
>  
>  #define MEMFILE_PRIVATE(x, val)	((x) << 16 | (val))
> @@ -2816,6 +2816,11 @@ static u64 mem_cgroup_read_u64(struct cgroup_subsys_state *css,
>  	case _KMEM:
>  		counter = &memcg->kmem;
>  		break;
> +#if defined(CONFIG_MEMCG_LEGACY_KMEM) && defined(CONFIG_INET)
> +	case _TCP:
> +		counter = &memcg->tcp_mem.memory_allocated;
> +		break;
> +#endif
>  	default:
>  		BUG();
>  	}
> @@ -2988,6 +2993,48 @@ static int memcg_update_kmem_limit(struct mem_cgroup *memcg,
>  }
>  #endif /* CONFIG_MEMCG_LEGACY_KMEM */
>  
> +#if defined(CONFIG_MEMCG_LEGACY_KMEM) && defined(CONFIG_INET)
> +static int memcg_update_tcp_limit(struct mem_cgroup *memcg, unsigned long limit)
> +{
> +	int ret;
> +
> +	mutex_lock(&memcg_limit_mutex);
> +
> +	ret = page_counter_limit(&memcg->tcp_mem.memory_allocated, limit);
> +	if (ret)
> +		goto out;
> +
> +	if (!memcg->tcp_mem.active) {
> +		/*
> +		 * The active flag needs to be written after the static_key
> +		 * update. This is what guarantees that the socket activation
> +		 * function is the last one to run. See sock_update_memcg() for
> +		 * details, and note that we don't mark any socket as belonging
> +		 * to this memcg until that flag is up.
> +		 *
> +		 * We need to do this, because static_keys will span multiple
> +		 * sites, but we can't control their order. If we mark a socket
> +		 * as accounted, but the accounting functions are not patched in
> +		 * yet, we'll lose accounting.
> +		 *
> +		 * We never race with the readers in sock_update_memcg(),
> +		 * because when this value change, the code to process it is not
> +		 * patched in yet.
> +		 */
> +		static_branch_inc(&memcg_sockets_enabled_key);
> +		memcg->tcp_mem.active = true;
> +	}
> +out:
> +	mutex_unlock(&memcg_limit_mutex);
> +	return ret;
> +}
> +#else
> +static int memcg_update_tcp_limit(struct mem_cgroup *memcg, unsigned long limit)
> +{
> +	return -EINVAL;
> +}
> +#endif /* CONFIG_MEMCG_LEGACY_KMEM && CONFIG_INET */
> +
>  /*
>   * The user of this function is...
>   * RES_LIMIT.
> @@ -3020,6 +3067,9 @@ static ssize_t mem_cgroup_write(struct kernfs_open_file *of,
>  		case _KMEM:
>  			ret = memcg_update_kmem_limit(memcg, nr_pages);
>  			break;
> +		case _TCP:
> +			ret = memcg_update_tcp_limit(memcg, nr_pages);
> +			break;
>  		}
>  		break;
>  	case RES_SOFT_LIMIT:
> @@ -3046,6 +3096,11 @@ static ssize_t mem_cgroup_reset(struct kernfs_open_file *of, char *buf,
>  	case _KMEM:
>  		counter = &memcg->kmem;
>  		break;
> +#if defined(CONFIG_MEMCG_LEGACY_KMEM) && defined(CONFIG_INET)
> +	case _TCP:
> +		counter = &memcg->tcp_mem.memory_allocated;
> +		break;
> +#endif
>  	default:
>  		BUG();
>  	}
> @@ -4031,6 +4086,31 @@ static struct cftype mem_cgroup_legacy_files[] = {
>  		.seq_show = memcg_slab_show,
>  	},
>  #endif
> +#ifdef CONFIG_INET
> +	{
> +		.name = "kmem.tcp.limit_in_bytes",
> +		.private = MEMFILE_PRIVATE(_TCP, RES_LIMIT),
> +		.write = mem_cgroup_write,
> +		.read_u64 = mem_cgroup_read_u64,
> +	},
> +	{
> +		.name = "kmem.tcp.usage_in_bytes",
> +		.private = MEMFILE_PRIVATE(_TCP, RES_USAGE),
> +		.read_u64 = mem_cgroup_read_u64,
> +	},
> +	{
> +		.name = "kmem.tcp.failcnt",
> +		.private = MEMFILE_PRIVATE(_TCP, RES_FAILCNT),
> +		.write = mem_cgroup_reset,
> +		.read_u64 = mem_cgroup_read_u64,
> +	},
> +	{
> +		.name = "kmem.tcp.max_usage_in_bytes",
> +		.private = MEMFILE_PRIVATE(_TCP, RES_MAX_USAGE),
> +		.write = mem_cgroup_reset,
> +		.read_u64 = mem_cgroup_read_u64,
> +	},
> +#endif
>  #endif
>  	{ },	/* terminate */
>  };
> @@ -4198,6 +4278,10 @@ mem_cgroup_css_online(struct cgroup_subsys_state *css)
>  		memcg->soft_limit = PAGE_COUNTER_MAX;
>  		page_counter_init(&memcg->memsw, &parent->memsw);
>  		page_counter_init(&memcg->kmem, &parent->kmem);
> +#if defined(CONFIG_MEMCG_LEGACY_KMEM) && defined(CONFIG_INET)
> +		page_counter_init(&memcg->tcp_mem.memory_allocated,
> +				  &parent->tcp_mem.memory_allocated);
> +#endif
>  
>  		/*
>  		 * No need to take a reference to the parent because cgroup
> @@ -4209,6 +4293,9 @@ mem_cgroup_css_online(struct cgroup_subsys_state *css)
>  		memcg->soft_limit = PAGE_COUNTER_MAX;
>  		page_counter_init(&memcg->memsw, NULL);
>  		page_counter_init(&memcg->kmem, NULL);
> +#if defined(CONFIG_MEMCG_LEGACY_KMEM) && defined(CONFIG_INET)
> +		page_counter_init(&memcg->tcp_mem.memory_allocated, NULL);
> +#endif
>  		/*
>  		 * Deeper hierachy with use_hierarchy == false doesn't make
>  		 * much sense so let cgroup subsystem know about this
> @@ -4223,12 +4310,6 @@ mem_cgroup_css_online(struct cgroup_subsys_state *css)
>  	if (ret)
>  		return ret;
>  
> -#ifdef CONFIG_MEMCG_LEGACY_KMEM
> -	ret = tcp_init_cgroup(memcg);
> -	if (ret)
> -		return ret;
> -#endif
> -
>  #ifdef CONFIG_INET
>  	if (cgroup_subsys_on_dfl(memory_cgrp_subsys) && !cgroup_memory_nosocket)
>  		static_branch_inc(&memcg_sockets_enabled_key);
> @@ -4277,12 +4358,13 @@ static void mem_cgroup_css_free(struct cgroup_subsys_state *css)
>  		static_branch_dec(&memcg_sockets_enabled_key);
>  #endif
>  
> -	memcg_free_kmem(memcg);
> -
> -#ifdef CONFIG_MEMCG_LEGACY_KMEM
> -	tcp_destroy_cgroup(memcg);
> +#if defined(CONFIG_MEMCG_LEGACY_KMEM) && defined(CONFIG_INET)
> +	if (memcg->tcp_mem.active)
> +		static_branch_dec(&memcg_sockets_enabled_key);
>  #endif
>  
> +	memcg_free_kmem(memcg);
> +
>  	__mem_cgroup_free(memcg);
>  }
>  
> diff --git a/net/ipv4/Makefile b/net/ipv4/Makefile
> index bee5055832a1..62c049b647e9 100644
> --- a/net/ipv4/Makefile
> +++ b/net/ipv4/Makefile
> @@ -56,7 +56,6 @@ obj-$(CONFIG_TCP_CONG_SCALABLE) += tcp_scalable.o
>  obj-$(CONFIG_TCP_CONG_LP) += tcp_lp.o
>  obj-$(CONFIG_TCP_CONG_YEAH) += tcp_yeah.o
>  obj-$(CONFIG_TCP_CONG_ILLINOIS) += tcp_illinois.o
> -obj-$(CONFIG_MEMCG_LEGACY_KMEM) += tcp_memcontrol.o
>  obj-$(CONFIG_NETLABEL) += cipso_ipv4.o
>  
>  obj-$(CONFIG_XFRM) += xfrm4_policy.o xfrm4_state.o xfrm4_input.o \
> diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
> index a0bd7a55193e..108105570106 100644
> --- a/net/ipv4/sysctl_net_ipv4.c
> +++ b/net/ipv4/sysctl_net_ipv4.c
> @@ -24,7 +24,6 @@
>  #include <net/cipso_ipv4.h>
>  #include <net/inet_frag.h>
>  #include <net/ping.h>
> -#include <net/tcp_memcontrol.h>
>  
>  static int zero;
>  static int one = 1;
> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
> index 34c26782e114..88019dc902d7 100644
> --- a/net/ipv4/tcp_ipv4.c
> +++ b/net/ipv4/tcp_ipv4.c
> @@ -73,7 +73,6 @@
>  #include <net/timewait_sock.h>
>  #include <net/xfrm.h>
>  #include <net/secure_seq.h>
> -#include <net/tcp_memcontrol.h>
>  #include <net/busy_poll.h>
>  
>  #include <linux/inet.h>
> diff --git a/net/ipv4/tcp_memcontrol.c b/net/ipv4/tcp_memcontrol.c
> deleted file mode 100644
> index 133eb5eac49f..000000000000
> --- a/net/ipv4/tcp_memcontrol.c
> +++ /dev/null
> @@ -1,200 +0,0 @@
> -#include <net/tcp.h>
> -#include <net/tcp_memcontrol.h>
> -#include <net/sock.h>
> -#include <net/ip.h>
> -#include <linux/nsproxy.h>
> -#include <linux/memcontrol.h>
> -#include <linux/module.h>
> -
> -int tcp_init_cgroup(struct mem_cgroup *memcg)
> -{
> -	struct mem_cgroup *parent = parent_mem_cgroup(memcg);
> -	struct page_counter *counter_parent = NULL;
> -	/*
> -	 * The root cgroup does not use page_counters, but rather,
> -	 * rely on the data already collected by the network
> -	 * subsystem
> -	 */
> -	if (memcg == root_mem_cgroup)
> -		return 0;
> -
> -	memcg->tcp_mem.memory_pressure = 0;
> -
> -	if (parent)
> -		counter_parent = &parent->tcp_mem.memory_allocated;
> -
> -	page_counter_init(&memcg->tcp_mem.memory_allocated, counter_parent);
> -
> -	return 0;
> -}
> -
> -void tcp_destroy_cgroup(struct mem_cgroup *memcg)
> -{
> -	if (memcg == root_mem_cgroup)
> -		return;
> -
> -	if (memcg->tcp_mem.active)
> -		static_branch_dec(&memcg_sockets_enabled_key);
> -}
> -
> -static int tcp_update_limit(struct mem_cgroup *memcg, unsigned long nr_pages)
> -{
> -	int ret;
> -
> -	if (memcg == root_mem_cgroup)
> -		return -EINVAL;
> -
> -	ret = page_counter_limit(&memcg->tcp_mem.memory_allocated, nr_pages);
> -	if (ret)
> -		return ret;
> -
> -	if (!memcg->tcp_mem.active) {
> -		/*
> -		 * The active flag needs to be written after the static_key
> -		 * update. This is what guarantees that the socket activation
> -		 * function is the last one to run. See sock_update_memcg() for
> -		 * details, and note that we don't mark any socket as belonging
> -		 * to this memcg until that flag is up.
> -		 *
> -		 * We need to do this, because static_keys will span multiple
> -		 * sites, but we can't control their order. If we mark a socket
> -		 * as accounted, but the accounting functions are not patched in
> -		 * yet, we'll lose accounting.
> -		 *
> -		 * We never race with the readers in sock_update_memcg(),
> -		 * because when this value change, the code to process it is not
> -		 * patched in yet.
> -		 */
> -		static_branch_inc(&memcg_sockets_enabled_key);
> -		memcg->tcp_mem.active = true;
> -	}
> -
> -	return 0;
> -}
> -
> -enum {
> -	RES_USAGE,
> -	RES_LIMIT,
> -	RES_MAX_USAGE,
> -	RES_FAILCNT,
> -};
> -
> -static DEFINE_MUTEX(tcp_limit_mutex);
> -
> -static ssize_t tcp_cgroup_write(struct kernfs_open_file *of,
> -				char *buf, size_t nbytes, loff_t off)
> -{
> -	struct mem_cgroup *memcg = mem_cgroup_from_css(of_css(of));
> -	unsigned long nr_pages;
> -	int ret = 0;
> -
> -	buf = strstrip(buf);
> -
> -	switch (of_cft(of)->private) {
> -	case RES_LIMIT:
> -		/* see memcontrol.c */
> -		ret = page_counter_memparse(buf, "-1", &nr_pages);
> -		if (ret)
> -			break;
> -		mutex_lock(&tcp_limit_mutex);
> -		ret = tcp_update_limit(memcg, nr_pages);
> -		mutex_unlock(&tcp_limit_mutex);
> -		break;
> -	default:
> -		ret = -EINVAL;
> -		break;
> -	}
> -	return ret ?: nbytes;
> -}
> -
> -static u64 tcp_cgroup_read(struct cgroup_subsys_state *css, struct cftype *cft)
> -{
> -	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
> -	u64 val;
> -
> -	switch (cft->private) {
> -	case RES_LIMIT:
> -		if (memcg == root_mem_cgroup)
> -			val = PAGE_COUNTER_MAX;
> -		else
> -			val = memcg->tcp_mem.memory_allocated.limit;
> -		val *= PAGE_SIZE;
> -		break;
> -	case RES_USAGE:
> -		if (memcg == root_mem_cgroup)
> -			val = atomic_long_read(&tcp_memory_allocated);
> -		else
> -			val = page_counter_read(&memcg->tcp_mem.memory_allocated);
> -		val *= PAGE_SIZE;
> -		break;
> -	case RES_FAILCNT:
> -		if (memcg == root_mem_cgroup)
> -			return 0;
> -		val = memcg->tcp_mem.memory_allocated.failcnt;
> -		break;
> -	case RES_MAX_USAGE:
> -		if (memcg == root_mem_cgroup)
> -			return 0;
> -		val = memcg->tcp_mem.memory_allocated.watermark;
> -		val *= PAGE_SIZE;
> -		break;
> -	default:
> -		BUG();
> -	}
> -	return val;
> -}
> -
> -static ssize_t tcp_cgroup_reset(struct kernfs_open_file *of,
> -				char *buf, size_t nbytes, loff_t off)
> -{
> -	struct mem_cgroup *memcg;
> -
> -	memcg = mem_cgroup_from_css(of_css(of));
> -	if (memcg == root_mem_cgroup)
> -		return nbytes;
> -
> -	switch (of_cft(of)->private) {
> -	case RES_MAX_USAGE:
> -		page_counter_reset_watermark(&memcg->tcp_mem.memory_allocated);
> -		break;
> -	case RES_FAILCNT:
> -		memcg->tcp_mem.memory_allocated.failcnt = 0;
> -		break;
> -	}
> -
> -	return nbytes;
> -}
> -
> -static struct cftype tcp_files[] = {
> -	{
> -		.name = "kmem.tcp.limit_in_bytes",
> -		.write = tcp_cgroup_write,
> -		.read_u64 = tcp_cgroup_read,
> -		.private = RES_LIMIT,
> -	},
> -	{
> -		.name = "kmem.tcp.usage_in_bytes",
> -		.read_u64 = tcp_cgroup_read,
> -		.private = RES_USAGE,
> -	},
> -	{
> -		.name = "kmem.tcp.failcnt",
> -		.private = RES_FAILCNT,
> -		.write = tcp_cgroup_reset,
> -		.read_u64 = tcp_cgroup_read,
> -	},
> -	{
> -		.name = "kmem.tcp.max_usage_in_bytes",
> -		.private = RES_MAX_USAGE,
> -		.write = tcp_cgroup_reset,
> -		.read_u64 = tcp_cgroup_read,
> -	},
> -	{ }	/* terminate */
> -};
> -
> -static int __init tcp_memcontrol_init(void)
> -{
> -	WARN_ON(cgroup_add_legacy_cftypes(&memory_cgrp_subsys, tcp_files));
> -	return 0;
> -}
> -__initcall(tcp_memcontrol_init);
> diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
> index 1bfb68203f92..894fbfb903af 100644
> --- a/net/ipv6/tcp_ipv6.c
> +++ b/net/ipv6/tcp_ipv6.c
> @@ -61,7 +61,6 @@
>  #include <net/timewait_sock.h>
>  #include <net/inet_common.h>
>  #include <net/secure_seq.h>
> -#include <net/tcp_memcontrol.h>
>  #include <net/busy_poll.h>
>  
>  #include <linux/proc_fs.h>
> -- 
> 2.1.4
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
