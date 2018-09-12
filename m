Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8CA928E0001
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 09:50:02 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id s54-v6so908856eda.20
        for <linux-mm@kvack.org>; Wed, 12 Sep 2018 06:50:02 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p33-v6si5278edc.147.2018.09.12.06.50.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Sep 2018 06:50:01 -0700 (PDT)
Date: Wed, 12 Sep 2018 15:49:59 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] memcg: remove congestion wait when force empty
Message-ID: <20180912134959.GK10951@dhcp22.suse.cz>
References: <1536743960-19703-1-git-send-email-lirongqing@baidu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1536743960-19703-1-git-send-email-lirongqing@baidu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li RongQing <lirongqing@baidu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, hannes@cmpxchg.org, vdavydov.dev@gmail.com

On Wed 12-09-18 17:19:20, Li RongQing wrote:
> memory.force_empty is used to empty a memory cgoup memory before
> rmdir it, avoid to charge those memory into parent cgroup

We do not reparent LRU pages on the memcg removal. We just keep
those pages around and reclaim them on the memory pressure. So the above
is not true anymore. You can use force_empty to release those pages
earlier though.

> when try_to_free_mem_cgroup_pages returns 0, guess there maybe be
> lots of writeback, so wait. but the waiting and sleep will called
> in shrink_inactive_list, based on numbers of isolated page, so
> remove this wait to reduce unnecessary delay

Have you ever seen this congestion_wait to be actually harmful?
You are right that the reclaim path already does sleep and we even wait
for pages under writeback for memcg v1. But there might be other reasons
why no pages are reclaimable at the moment and this congestion_wait is
meant to sleep for a while before retrying and running out of retries
too early.

That being said, the current code is not really great but could you
describe the actual problem you are seeing? 

> Signed-off-by: Li RongQing <lirongqing@baidu.com>
> ---
>  mm/memcontrol.c | 6 +-----
>  1 file changed, 1 insertion(+), 5 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 4ead5a4817de..35bd43eaa97e 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2897,12 +2897,8 @@ static int mem_cgroup_force_empty(struct mem_cgroup *memcg)
>  
>  		progress = try_to_free_mem_cgroup_pages(memcg, 1,
>  							GFP_KERNEL, true);
> -		if (!progress) {
> +		if (!progress)
>  			nr_retries--;
> -			/* maybe some writeback is necessary */
> -			congestion_wait(BLK_RW_ASYNC, HZ/10);
> -		}
> -
>  	}
>  
>  	return 0;
> -- 
> 2.16.2

-- 
Michal Hocko
SUSE Labs
