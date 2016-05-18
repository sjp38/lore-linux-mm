Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 71F286B0262
	for <linux-mm@kvack.org>; Wed, 18 May 2016 03:32:56 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id y84so20668226lfc.3
        for <linux-mm@kvack.org>; Wed, 18 May 2016 00:32:56 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id gx6si8669742wjb.76.2016.05.18.00.32.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 May 2016 00:32:55 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id w143so10392951wmw.3
        for <linux-mm@kvack.org>; Wed, 18 May 2016 00:32:55 -0700 (PDT)
Date: Wed, 18 May 2016 09:32:53 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: memcontrol: fix the return in mem_cgroup_margin
Message-ID: <20160518073253.GC21654@dhcp22.suse.cz>
References: <1463556255-31892-1-git-send-email-roy.qing.li@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1463556255-31892-1-git-send-email-roy.qing.li@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: roy.qing.li@gmail.com
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, hannes@cmpxchg.org, vdavydov@virtuozzo.com

On Wed 18-05-16 15:24:15, roy.qing.li@gmail.com wrote:
> From: Li RongQing <roy.qing.li@gmail.com>
> 
> when memory+swap is over limit, return 0
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
> ---
>  mm/memcontrol.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index fe787f5..e9211c2 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1090,6 +1090,8 @@ static unsigned long mem_cgroup_margin(struct mem_cgroup *memcg)
>  		limit = READ_ONCE(memcg->memsw.limit);
>  		if (count <= limit)
>  			margin = min(margin, limit - count);
> +		else
> +			margin = 0;

count should always be smaller than memsw.limit (this is a hard limit).
Even if we have some temporary breach then the code should work as
expected because margin is initialized to 0 and memsw.limit >= limit.

Or have you seen any real problem with this code path?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
