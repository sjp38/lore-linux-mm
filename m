Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 713466B0005
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 17:22:16 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id 1-v6so3820985plv.6
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 14:22:16 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a11-v6sor2397374plp.19.2018.03.21.14.22.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 21 Mar 2018 14:22:15 -0700 (PDT)
Date: Wed, 21 Mar 2018 14:22:13 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] memcg, thp: do not invoke oom killer on thp charges
In-Reply-To: <20180321205928.22240-1-mhocko@kernel.org>
Message-ID: <alpine.DEB.2.20.1803211418170.107059@chino.kir.corp.google.com>
References: <20180321205928.22240-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Wed, 21 Mar 2018, Michal Hocko wrote:

> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index d1a917b5b7b7..08accbcd1a18 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1493,7 +1493,7 @@ static void memcg_oom_recover(struct mem_cgroup *memcg)
>  
>  static void mem_cgroup_oom(struct mem_cgroup *memcg, gfp_t mask, int order)
>  {
> -	if (!current->memcg_may_oom)
> +	if (!current->memcg_may_oom || order > PAGE_ALLOC_COSTLY_ORDER)
>  		return;
>  	/*
>  	 * We are in the middle of the charge context here, so we

What bug reports have you received about order-4 and higher order non thp 
charges that this fixes?

The patch title and the changelog specifically single out thp, which I've 
fixed, since it has sane fallback behavior and everything else uses 
__GFP_NORETRY.  I think this is misusing a page allocator heuristic that 
hasn't been applied to the memcg charge path before to address a thp 
regression but generalizing it for all charges.

PAGE_ALLOC_COSTLY_ORDER is a heuristic used by the page allocator because 
it cannot free high-order contiguous memory.  Memcg just needs to reclaim 
a number of pages.  Two order-3 charges can cause a memcg oom kill but now 
an order-4 charge cannot.  It's an unfair bias against high-order charges 
that are not explicitly using __GFP_NORETRY.
