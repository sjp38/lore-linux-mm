Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9B7226B000C
	for <linux-mm@kvack.org>; Mon, 19 Mar 2018 04:53:58 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id u68so9250917pfk.8
        for <linux-mm@kvack.org>; Mon, 19 Mar 2018 01:53:58 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g8-v6si11747590pln.420.2018.03.19.01.53.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 19 Mar 2018 01:53:57 -0700 (PDT)
Date: Mon, 19 Mar 2018 09:53:55 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/memcontrol.c: speed up to force empty a memory cgroup
Message-ID: <20180319085355.GQ23100@dhcp22.suse.cz>
References: <1521448170-19482-1-git-send-email-lirongqing@baidu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1521448170-19482-1-git-send-email-lirongqing@baidu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li RongQing <lirongqing@baidu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, hannes@cmpxchg.org, Andrey Ryabinin <aryabinin@virtuozzo.com>

On Mon 19-03-18 16:29:30, Li RongQing wrote:
> mem_cgroup_force_empty() tries to free only 32 (SWAP_CLUSTER_MAX) pages
> on each iteration, if a memory cgroup has lots of page cache, it will
> take many iterations to empty all page cache, so increase the reclaimed
> number per iteration to speed it up. same as in mem_cgroup_resize_limit()
> 
> a simple test show:
> 
>   $dd if=aaa  of=bbb  bs=1k count=3886080
>   $rm -f bbb
>   $time echo 100000000 >/cgroup/memory/test/memory.limit_in_bytes
> 
> Before: 0m0.252s ===> after: 0m0.178s

Andrey was proposing something similar [1]. My main objection was that
his approach might lead to over-reclaim. Your approach is more
conservative because it just increases the batch size. The size is still
rather arbitrary. Same as SWAP_CLUSTER_MAX but that one is a commonly
used unit of reclaim in the MM code.

I would be really curious about more detailed explanation why having a
larger batch yields to a better performance because we are doingg
SWAP_CLUSTER_MAX batches at the lower reclaim level anyway.

[1] http://lkml.kernel.org/r/20180119132544.19569-2-aryabinin@virtuozzo.com

> 
> Signed-off-by: Li RongQing <lirongqing@baidu.com>
> ---
>  mm/memcontrol.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 670e99b68aa6..8910d9e8e908 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2480,7 +2480,7 @@ static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
>  		if (!ret)
>  			break;
>  
> -		if (!try_to_free_mem_cgroup_pages(memcg, 1,
> +		if (!try_to_free_mem_cgroup_pages(memcg, 1024,
>  					GFP_KERNEL, !memsw)) {
>  			ret = -EBUSY;
>  			break;
> @@ -2610,7 +2610,7 @@ static int mem_cgroup_force_empty(struct mem_cgroup *memcg)
>  		if (signal_pending(current))
>  			return -EINTR;
>  
> -		progress = try_to_free_mem_cgroup_pages(memcg, 1,
> +		progress = try_to_free_mem_cgroup_pages(memcg, 1024,
>  							GFP_KERNEL, true);
>  		if (!progress) {
>  			nr_retries--;
> -- 
> 2.11.0

-- 
Michal Hocko
SUSE Labs
