Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 91F096B0038
	for <linux-mm@kvack.org>; Fri, 18 Sep 2015 10:09:00 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so32660674wic.0
        for <linux-mm@kvack.org>; Fri, 18 Sep 2015 07:09:00 -0700 (PDT)
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com. [209.85.212.179])
        by mx.google.com with ESMTPS id o1si11499719wia.25.2015.09.18.07.08.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Sep 2015 07:08:59 -0700 (PDT)
Received: by wiclk2 with SMTP id lk2so66191725wic.0
        for <linux-mm@kvack.org>; Fri, 18 Sep 2015 07:08:58 -0700 (PDT)
Date: Fri, 18 Sep 2015 16:08:57 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH -mm] vmscan: fix sane_reclaim helper for legacy memcg
Message-ID: <20150918140857.GA17606@dhcp22.suse.cz>
References: <1442580480-30829-1-git-send-email-vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1442580480-30829-1-git-send-email-vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 18-09-15 15:48:00, Vladimir Davydov wrote:
> The sane_reclaim() helper is supposed to return false for memcg reclaim
> if the legacy hierarchy is used, because the latter lacks dirty
> throttling mechanism, and so it did before it was accidentally broken by
> commit 33398cf2f360c ("memcg: export struct mem_cgroup"). Fix it.
> 
> Fixes: 33398cf2f360c ("memcg: export struct mem_cgroup")
> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>

Acked-by: Michal Hocko <mhocko@suse.com>

Thanks for catching this up!

> ---
>  mm/vmscan.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index db5339dd4a32..dbc3b3ae48de 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -175,7 +175,7 @@ static bool sane_reclaim(struct scan_control *sc)
>  	if (!memcg)
>  		return true;
>  #ifdef CONFIG_CGROUP_WRITEBACK
> -	if (memcg->css.cgroup)
> +	if (cgroup_on_dfl(memcg->css.cgroup))
>  		return true;
>  #endif
>  	return false;
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
