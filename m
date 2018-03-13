Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1A7596B0012
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 09:49:07 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id u188so7473864pfb.6
        for <linux-mm@kvack.org>; Tue, 13 Mar 2018 06:49:07 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e4si188706pfa.103.2018.03.13.06.49.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 13 Mar 2018 06:49:05 -0700 (PDT)
Date: Tue, 13 Mar 2018 14:49:02 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3 1/2] mm: memcg: remote memcg charging for kmem
 allocations
Message-ID: <20180313134902.GW12772@dhcp22.suse.cz>
References: <20180221223757.127213-1-shakeelb@google.com>
 <20180221223757.127213-2-shakeelb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180221223757.127213-2-shakeelb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Jan Kara <jack@suse.cz>, Amir Goldstein <amir73il@gmail.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed 21-02-18 14:37:56, Shakeel Butt wrote:
[...]
> +#ifdef CONFIG_MEMCG
> +static inline struct mem_cgroup *memalloc_memcg_save(struct mem_cgroup *memcg)
> +{
> +	struct mem_cgroup *old_memcg = current->target_memcg;
> +	current->target_memcg = memcg;
> +	return old_memcg;
> +}

So you are relying that the caller will handle the reference counting
properly? I do not think this is a good idea. Also do we need some kind
of debugging facility to detect unbalanced save/restore scopes?

[...]
> @@ -2260,7 +2269,10 @@ struct kmem_cache *memcg_kmem_get_cache(struct kmem_cache *cachep)
>  	if (current->memcg_kmem_skip_account)
>  		return cachep;
>  
> -	memcg = get_mem_cgroup_from_mm(current->mm);
> +	if (current->target_memcg)
> +		memcg = get_mem_cgroup(current->target_memcg);
> +	if (!memcg)
> +		memcg = get_mem_cgroup_from_mm(current->mm);
>  	kmemcg_id = READ_ONCE(memcg->kmemcg_id);
>  	if (kmemcg_id < 0)
>  		goto out;

You are also adding one branch for _each_ charge path even though the
usecase is rather limited.

I will have to think about this approach more. It is clearly less code
than your previous attempt but I cannot say I would be really impressed.
-- 
Michal Hocko
SUSE Labs
