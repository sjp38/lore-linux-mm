Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 07A9E6B0038
	for <linux-mm@kvack.org>; Thu, 12 Nov 2015 23:53:42 -0500 (EST)
Received: by padhx2 with SMTP id hx2so88034392pad.1
        for <linux-mm@kvack.org>; Thu, 12 Nov 2015 20:53:41 -0800 (PST)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com. [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id t13si24718086pas.21.2015.11.12.20.53.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Nov 2015 20:53:41 -0800 (PST)
Received: by padhx2 with SMTP id hx2so88034095pad.1
        for <linux-mm@kvack.org>; Thu, 12 Nov 2015 20:53:41 -0800 (PST)
Message-ID: <1447390418.22599.34.camel@edumazet-glaptop2.roam.corp.google.com>
Subject: Re: [PATCH 08/14] net: tcp_memcontrol: sanitize tcp memory
 accounting callbacks
From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 12 Nov 2015 20:53:38 -0800
In-Reply-To: <1447371693-25143-9-git-send-email-hannes@cmpxchg.org>
References: <1447371693-25143-1-git-send-email-hannes@cmpxchg.org>
	 <1447371693-25143-9-git-send-email-hannes@cmpxchg.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Thu, 2015-11-12 at 18:41 -0500, Johannes Weiner wrote:


> @@ -711,6 +705,12 @@ static inline void mem_cgroup_wb_stats(struct bdi_writeback *wb,
>  struct sock;
>  void sock_update_memcg(struct sock *sk);
>  void sock_release_memcg(struct sock *sk);
> +bool mem_cgroup_charge_skmem(struct cg_proto *proto, unsigned int nr_pages);
> +void mem_cgroup_uncharge_skmem(struct cg_proto *proto, unsigned int nr_pages);
> +static inline bool mem_cgroup_under_socket_pressure(struct cg_proto *proto)
> +{
> +	return proto->memory_pressure;
> +}
>  #endif /* CONFIG_INET && CONFIG_MEMCG_KMEM */
>  
>  #ifdef CONFIG_MEMCG_KMEM
> diff --git a/include/net/sock.h b/include/net/sock.h
> index 2eefc99..8cc7613 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -1126,8 +1126,8 @@ static inline bool sk_under_memory_pressure(const struct sock *sk)
>  	if (!sk->sk_prot->memory_pressure)
>  		return false;
>  
> -	if (mem_cgroup_sockets_enabled && sk->sk_cgrp)
> -		return !!sk->sk_cgrp->memory_pressure;
> +	if (mem_cgroup_sockets_enabled && sk->sk_cgrp &&
> +	    mem_cgroup_under_socket_pressure(sk->sk_cgrp))
>  
>  	return !!*sk->sk_prot->memory_pressure;
>  }


This looks wrong ?

if (A && B && C)
    return !!*sk->sk_prot->memory_pressure;

<compiler should eventually barf, 
as this function should not return void>
}







--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
