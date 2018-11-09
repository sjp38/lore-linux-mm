Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 066816B071E
	for <linux-mm@kvack.org>; Fri,  9 Nov 2018 15:48:11 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id b8-v6so2146703pls.11
        for <linux-mm@kvack.org>; Fri, 09 Nov 2018 12:48:10 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id x33-v6si8670159plb.49.2018.11.09.12.48.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Nov 2018 12:48:10 -0800 (PST)
Date: Fri, 9 Nov 2018 12:48:06 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/slub: skip node in case there is no slab to acquire
Message-Id: <20181109124806.f4f1b85c09b7cd977b5fbe8c@linux-foundation.org>
In-Reply-To: <20181108011204.9491-1-richard.weiyang@gmail.com>
References: <20181108011204.9491-1-richard.weiyang@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: cl@linux.com, penberg@kernel.org, linux-mm@kvack.org

On Thu,  8 Nov 2018 09:12:04 +0800 Wei Yang <richard.weiyang@gmail.com> wrote:

> for_each_zone_zonelist() iterates the zonelist one by one, which means
> it will iterate on zones on the same node. While get_partial_node()
> checks available slab on node base instead of zone.
> 
> This patch skip a node in case get_partial_node() fails to acquire slab
> on that node.

This is rather hard to follow.

I *think* the patch is a performance optimization: prevent
get_any_partial() from checking a node which get_partial_node() has
already looked at?

Could we please have a more complete changelog?

> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -1873,7 +1873,7 @@ static void *get_partial_node(struct kmem_cache *s, struct kmem_cache_node *n,
>   * Get a page from somewhere. Search in increasing NUMA distances.
>   */
>  static void *get_any_partial(struct kmem_cache *s, gfp_t flags,
> -		struct kmem_cache_cpu *c)
> +		struct kmem_cache_cpu *c, int except)
>  {
>  #ifdef CONFIG_NUMA
>  	struct zonelist *zonelist;
> @@ -1882,6 +1882,9 @@ static void *get_any_partial(struct kmem_cache *s, gfp_t flags,
>  	enum zone_type high_zoneidx = gfp_zone(flags);
>  	void *object;
>  	unsigned int cpuset_mems_cookie;
> +	nodemask_t nmask = node_states[N_MEMORY];
> +
> +	node_clear(except, nmask);

And please add a comment describing what's happening here and why it is
done.  Adding a sentence to the block comment over get_any_partial()
would be suitable.
