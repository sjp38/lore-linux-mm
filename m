Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6E5136B0003
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 06:43:49 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id n2-v6so3121876edr.5
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 03:43:49 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p3-v6si5201800edj.364.2018.07.19.03.43.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Jul 2018 03:43:48 -0700 (PDT)
Date: Thu, 19 Jul 2018 12:43:45 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: memcg: fix use after free in mem_cgroup_iter()
Message-ID: <20180719104345.GV7193@dhcp22.suse.cz>
References: <1531994807-25639-1-git-send-email-jing.xia@unisoc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1531994807-25639-1-git-send-email-jing.xia@unisoc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jing Xia <jing.xia.mail@gmail.com>
Cc: hannes@cmpxchg.org, vdavydov.dev@gmail.com, chunyan.zhang@unisoc.com, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

[CC Andrew]

On Thu 19-07-18 18:06:47, Jing Xia wrote:
> It was reported that a kernel crash happened in mem_cgroup_iter(),
> which can be triggered if the legacy cgroup-v1 non-hierarchical
> mode is used.
> 
> Unable to handle kernel paging request at virtual address 6b6b6b6b6b6b8f
> ......
> Call trace:
>   mem_cgroup_iter+0x2e0/0x6d4
>   shrink_zone+0x8c/0x324
>   balance_pgdat+0x450/0x640
>   kswapd+0x130/0x4b8
>   kthread+0xe8/0xfc
>   ret_from_fork+0x10/0x20
> 
>   mem_cgroup_iter():
>       ......
>       if (css_tryget(css))    <-- crash here
> 	    break;
>       ......
> 
> The crashing reason is that mem_cgroup_iter() uses the memcg object
> whose pointer is stored in iter->position, which has been freed before
> and filled with POISON_FREE(0x6b).
> 
> And the root cause of the use-after-free issue is that
> invalidate_reclaim_iterators() fails to reset the value of
> iter->position to NULL when the css of the memcg is released in non-
> hierarchical mode.

Well, spotted!

I suspect
Fixes: 6df38689e0e9 ("mm: memcontrol: fix possible memcg leak due to interrupted reclaim")

but maybe it goes further into past. I also suggest
Cc: stable

even though the non-hierarchical mode is strongly discouraged. A lack of
reports for 3 years is encouraging that not many people really use this
mode.

> Signed-off-by: Jing Xia <jing.xia.mail@gmail.com>

Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!
> ---
>  mm/memcontrol.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index e6f0d5e..8c0280b 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -850,7 +850,7 @@ static void invalidate_reclaim_iterators(struct mem_cgroup *dead_memcg)
>  	int nid;
>  	int i;
>  
> -	while ((memcg = parent_mem_cgroup(memcg))) {
> +	for (; memcg; memcg = parent_mem_cgroup(memcg)) {
>  		for_each_node(nid) {
>  			mz = mem_cgroup_nodeinfo(memcg, nid);
>  			for (i = 0; i <= DEF_PRIORITY; i++) {
> -- 
> 1.9.1

-- 
Michal Hocko
SUSE Labs
