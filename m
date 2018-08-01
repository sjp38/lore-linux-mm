Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id BCF376B0005
	for <linux-mm@kvack.org>; Wed,  1 Aug 2018 07:03:58 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id l16-v6so2900727edq.18
        for <linux-mm@kvack.org>; Wed, 01 Aug 2018 04:03:58 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l6-v6si2658189edc.305.2018.08.01.04.03.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Aug 2018 04:03:57 -0700 (PDT)
Date: Wed, 1 Aug 2018 13:03:56 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm: add a function to return a bdi_writeback dirty
 page statistic
Message-ID: <20180801110356.GH16767@dhcp22.suse.cz>
References: <1533120516-18279-1-git-send-email-lirongqing@baidu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1533120516-18279-1-git-send-email-lirongqing@baidu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li RongQing <lirongqing@baidu.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

On Wed 01-08-18 18:48:35, Li RongQing wrote:
> this is a preparation to optimise a full writeback
> when reclaim memory

Please do not add unused functions. This makes review harder without a
good reason. Besides that we already have mem_cgroup_wb_stats. Why
cannot you reuse it?

> Signed-off-by: Zhang Yu <zhangyu31@baidu.com>
> Signed-off-by: Li RongQing <lirongqing@baidu.com>
> ---
>  include/linux/memcontrol.h | 2 +-
>  mm/memcontrol.c            | 6 ++++++
>  2 files changed, 7 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 6c6fb116e925..58e29555ac81 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -1141,7 +1141,7 @@ struct wb_domain *mem_cgroup_wb_domain(struct bdi_writeback *wb);
>  void mem_cgroup_wb_stats(struct bdi_writeback *wb, unsigned long *pfilepages,
>  			 unsigned long *pheadroom, unsigned long *pdirty,
>  			 unsigned long *pwriteback);
> -
> +unsigned long mem_cgroup_wb_dirty_stats(struct bdi_writeback *wb);
>  #else	/* CONFIG_CGROUP_WRITEBACK */
>  
>  static inline struct wb_domain *mem_cgroup_wb_domain(struct bdi_writeback *wb)
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 8c0280b3143e..82d3061e91d1 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3640,6 +3640,12 @@ void mem_cgroup_wb_stats(struct bdi_writeback *wb, unsigned long *pfilepages,
>  	}
>  }
>  
> +unsigned long mem_cgroup_wb_dirty_stats(struct bdi_writeback *wb)
> +{
> +	struct mem_cgroup *memcg = mem_cgroup_from_css(wb->memcg_css);
> +
> +	return memcg_page_state(memcg, NR_FILE_DIRTY);
> +}
>  #else	/* CONFIG_CGROUP_WRITEBACK */
>  
>  static int memcg_wb_domain_init(struct mem_cgroup *memcg, gfp_t gfp)
> -- 
> 2.16.2

-- 
Michal Hocko
SUSE Labs
