Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id BB8E36B025E
	for <linux-mm@kvack.org>; Mon, 23 May 2016 13:44:46 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id o70so25139766lfg.1
        for <linux-mm@kvack.org>; Mon, 23 May 2016 10:44:46 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id k6si45600607wji.151.2016.05.23.10.44.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 May 2016 10:44:45 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id q62so17256751wmg.3
        for <linux-mm@kvack.org>; Mon, 23 May 2016 10:44:45 -0700 (PDT)
Date: Mon, 23 May 2016 19:44:43 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: memcontrol: fix possible css ref leak on oom
Message-ID: <20160523174441.GA32715@dhcp22.suse.cz>
References: <1464019330-7579-1-git-send-email-vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1464019330-7579-1-git-send-email-vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 23-05-16 19:02:10, Vladimir Davydov wrote:
> mem_cgroup_oom may be invoked multiple times while a process is handling
> a page fault, in which case current->memcg_in_oom will be overwritten
> leaking the previously taken css reference.

Have you seen this happening? I was under impression that the page fault
paths that have oom enabled will not retry allocations.
 
> Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>

That being said I do not have anything against the patch. It is a good
safety net I am just not sure this might happen right now and so the
patch is not stable candidate.

After clarification
Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/memcontrol.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 5b48cd25951b..ef8797d34039 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1608,7 +1608,7 @@ static void memcg_oom_recover(struct mem_cgroup *memcg)
>  
>  static void mem_cgroup_oom(struct mem_cgroup *memcg, gfp_t mask, int order)
>  {
> -	if (!current->memcg_may_oom)
> +	if (!current->memcg_may_oom || current->memcg_in_oom)
>  		return;
>  	/*
>  	 * We are in the middle of the charge context here, so we
> -- 
> 2.1.4

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
