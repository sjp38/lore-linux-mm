Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id D7F976B0253
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 09:58:42 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id cy9so5943568pac.0
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 06:58:42 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id m79si10011684pfj.40.2016.01.27.06.58.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jan 2016 06:58:42 -0800 (PST)
Date: Wed, 27 Jan 2016 17:58:27 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 5/5] mm: workingset: per-cgroup cache thrash detection
Message-ID: <20160127145827.GE9623@esperanza>
References: <1453842006-29265-1-git-send-email-hannes@cmpxchg.org>
 <1453842006-29265-6-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1453842006-29265-6-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Tue, Jan 26, 2016 at 04:00:06PM -0500, Johannes Weiner wrote:
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index b14a2bb33514..1cf3065c143b 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -317,6 +317,7 @@ extern void lru_cache_add_active_or_unevictable(struct page *page,
>  
>  /* linux/mm/vmscan.c */
>  extern unsigned long zone_reclaimable_pages(struct zone *zone);
> +extern unsigned long lruvec_lru_size(struct lruvec *lruvec, enum lru_list lru);

Better declare it in mm/internal.h? And is there any point in renaming
it?

> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 953f0f984392..864e237f32d9 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -202,11 +207,20 @@ static void unpack_shadow(void *shadow, struct zone **zonep,
>   */
>  void *workingset_eviction(struct address_space *mapping, struct page *page)
>  {
> +	struct mem_cgroup *memcg = page_memcg(page);
>  	struct zone *zone = page_zone(page);
> +	int memcgid = mem_cgroup_id(memcg);

This will crash in case memcg is disabled via boot param.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
