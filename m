Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f171.google.com (mail-yk0-f171.google.com [209.85.160.171])
	by kanga.kvack.org (Postfix) with ESMTP id ADA2B6B0038
	for <linux-mm@kvack.org>; Fri, 18 Sep 2015 11:59:23 -0400 (EDT)
Received: by ykdt18 with SMTP id t18so50523636ykd.3
        for <linux-mm@kvack.org>; Fri, 18 Sep 2015 08:59:23 -0700 (PDT)
Received: from mail-yk0-x232.google.com (mail-yk0-x232.google.com. [2607:f8b0:4002:c07::232])
        by mx.google.com with ESMTPS id n195si4413866ywn.87.2015.09.18.08.59.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Sep 2015 08:59:23 -0700 (PDT)
Received: by ykdg206 with SMTP id g206so50545109ykd.1
        for <linux-mm@kvack.org>; Fri, 18 Sep 2015 08:59:22 -0700 (PDT)
Date: Fri, 18 Sep 2015 11:59:19 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH -mm] vmscan: fix sane_reclaim helper for legacy memcg
Message-ID: <20150918155919.GC4065@mtj.duckdns.org>
References: <1442580480-30829-1-git-send-email-vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1442580480-30829-1-git-send-email-vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello,

On Fri, Sep 18, 2015 at 03:48:00PM +0300, Vladimir Davydov wrote:
> The sane_reclaim() helper is supposed to return false for memcg reclaim
> if the legacy hierarchy is used, because the latter lacks dirty
> throttling mechanism, and so it did before it was accidentally broken by
> commit 33398cf2f360c ("memcg: export struct mem_cgroup"). Fix it.
> 
> Fixes: 33398cf2f360c ("memcg: export struct mem_cgroup")
> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
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

Just a heads-up.  I'm applying a patch which replaces cgroup_on_dfl()
with cgroup_subsys_on_dfl() to cgroup/for-4.4, so this patch would
need to be adjusted to do cgroup_subsys_on_dfl(memory_cgrp_subsys)
instead.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
