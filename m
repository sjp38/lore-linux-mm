Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 11E416B0003
	for <linux-mm@kvack.org>; Tue, 13 Nov 2018 08:17:54 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id h25-v6so6433234eds.21
        for <linux-mm@kvack.org>; Tue, 13 Nov 2018 05:17:54 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v15-v6si130706ejh.87.2018.11.13.05.17.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Nov 2018 05:17:52 -0800 (PST)
Date: Tue, 13 Nov 2018 14:17:51 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/slub: skip node in case there is no slab to acquire
Message-ID: <20181113131751.GC16182@dhcp22.suse.cz>
References: <20181108011204.9491-1-richard.weiyang@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181108011204.9491-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: cl@linux.com, penberg@kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org

On Thu 08-11-18 09:12:04, Wei Yang wrote:
> for_each_zone_zonelist() iterates the zonelist one by one, which means
> it will iterate on zones on the same node. While get_partial_node()
> checks available slab on node base instead of zone.
> 
> This patch skip a node in case get_partial_node() fails to acquire slab
> on that node.

If this is an optimization then it should be accompanied by some
numbers.

> @@ -1882,6 +1882,9 @@ static void *get_any_partial(struct kmem_cache *s, gfp_t flags,
>  	enum zone_type high_zoneidx = gfp_zone(flags);
>  	void *object;
>  	unsigned int cpuset_mems_cookie;
> +	nodemask_t nmask = node_states[N_MEMORY];

This will allocate a large bitmask on the stack and that is no-go for
something that might be called from a potentially deep call stack
already. Also are you sure that the micro-optimization offsets the
copying overhead?

-- 
Michal Hocko
SUSE Labs
