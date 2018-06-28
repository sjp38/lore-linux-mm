Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0F9EE6B0010
	for <linux-mm@kvack.org>; Thu, 28 Jun 2018 10:53:05 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id m18-v6so2201014eds.0
        for <linux-mm@kvack.org>; Thu, 28 Jun 2018 07:53:05 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0107.outbound.protection.outlook.com. [104.47.0.107])
        by mx.google.com with ESMTPS id s4-v6si3426192edj.431.2018.06.28.07.53.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 28 Jun 2018 07:53:03 -0700 (PDT)
Subject: Re: [PATCH v2] net, mm: account sock objects to kmemcg
References: <20180627221642.247448-1-shakeelb@google.com>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <6f15cc1b-c026-6df1-19ba-d2396f71b488@virtuozzo.com>
Date: Thu, 28 Jun 2018 17:52:57 +0300
MIME-Version: 1.0
In-Reply-To: <20180627221642.247448-1-shakeelb@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Greg Thelen <gthelen@google.com>, Roman Gushchin <guro@fb.com>, "David S . Miller" <davem@davemloft.net>, Eric Dumazet <edumazet@google.com>, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org

On 28.06.2018 01:16, Shakeel Butt wrote:
> Currently the kernel accounts the memory for network traffic through
> mem_cgroup_[un]charge_skmem() interface. However the memory accounted
> only includes the truesize of sk_buff which does not include the size of
> sock objects. In our production environment, with opt-out kmem
> accounting, the sock kmem caches (TCP[v6], UDP[v6], RAW[v6], UNIX) are
> among the top most charged kmem caches and consume a significant amount
> of memory which can not be left as system overhead. So, this patch
> converts the kmem caches of all sock objects to SLAB_ACCOUNT.
> 
> Signed-off-by: Shakeel Butt <shakeelb@google.com>
> Suggested-by: Eric Dumazet <edumazet@google.com>

Looks good for me.

Reviewed-by: Kirill Tkhai <ktkhai@virtuozzo.com>

> ---
> Changelog since v1:
> - Instead of specific sock kmem_caches, convert all sock kmem_caches to
>   use SLAB_ACCOUNT.
> 
>  net/core/sock.c | 7 +++++--
>  1 file changed, 5 insertions(+), 2 deletions(-)
> 
> diff --git a/net/core/sock.c b/net/core/sock.c
> index bcc41829a16d..9e8f65585b81 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -3243,7 +3243,8 @@ static int req_prot_init(const struct proto *prot)
>  
>  	rsk_prot->slab = kmem_cache_create(rsk_prot->slab_name,
>  					   rsk_prot->obj_size, 0,
> -					   prot->slab_flags, NULL);
> +					   SLAB_ACCOUNT | prot->slab_flags,
> +					   NULL);
>  
>  	if (!rsk_prot->slab) {
>  		pr_crit("%s: Can't create request sock SLAB cache!\n",
> @@ -3258,7 +3259,8 @@ int proto_register(struct proto *prot, int alloc_slab)
>  	if (alloc_slab) {
>  		prot->slab = kmem_cache_create_usercopy(prot->name,
>  					prot->obj_size, 0,
> -					SLAB_HWCACHE_ALIGN | prot->slab_flags,
> +					SLAB_HWCACHE_ALIGN | SLAB_ACCOUNT |
> +					prot->slab_flags,
>  					prot->useroffset, prot->usersize,
>  					NULL);
>  
> @@ -3281,6 +3283,7 @@ int proto_register(struct proto *prot, int alloc_slab)
>  				kmem_cache_create(prot->twsk_prot->twsk_slab_name,
>  						  prot->twsk_prot->twsk_obj_size,
>  						  0,
> +						  SLAB_ACCOUNT |
>  						  prot->slab_flags,
>  						  NULL);
>  			if (prot->twsk_prot->twsk_slab == NULL)
> 
