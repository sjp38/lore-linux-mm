Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id E6E2C6B0009
	for <linux-mm@kvack.org>; Thu, 28 Jan 2016 10:55:33 -0500 (EST)
Received: by mail-wm0-f53.google.com with SMTP id p63so31061275wmp.1
        for <linux-mm@kvack.org>; Thu, 28 Jan 2016 07:55:33 -0800 (PST)
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com. [74.125.82.47])
        by mx.google.com with ESMTPS id lu1si11685041wjb.170.2016.01.28.07.55.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jan 2016 07:55:32 -0800 (PST)
Received: by mail-wm0-f47.google.com with SMTP id 128so16602319wmz.1
        for <linux-mm@kvack.org>; Thu, 28 Jan 2016 07:55:32 -0800 (PST)
Date: Thu, 28 Jan 2016 16:55:31 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] vmpressure: Fix subtree pressure detection
Message-ID: <20160128155531.GE15948@dhcp22.suse.cz>
References: <1453912137-25473-1-git-send-email-vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1453912137-25473-1-git-send-email-vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 27-01-16 19:28:57, Vladimir Davydov wrote:
> When vmpressure is called for the entire subtree under pressure we
> mistakenly use vmpressure->scanned instead of vmpressure->tree_scanned
> when checking if vmpressure work is to be scheduled. This results in
> suppressing all vmpressure events in the legacy cgroup hierarchy. Fix
> it.
> 
> Fixes: 8e8ae645249b ("mm: memcontrol: hook up vmpressure to socket pressure")
> Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>

a = b += c made me scratch my head for a second but this looks correct

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/vmpressure.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/mm/vmpressure.c b/mm/vmpressure.c
> index 9a6c0704211c..149fdf6c5c56 100644
> --- a/mm/vmpressure.c
> +++ b/mm/vmpressure.c
> @@ -248,9 +248,8 @@ void vmpressure(gfp_t gfp, struct mem_cgroup *memcg, bool tree,
>  
>  	if (tree) {
>  		spin_lock(&vmpr->sr_lock);
> -		vmpr->tree_scanned += scanned;
> +		scanned = vmpr->tree_scanned += scanned;
>  		vmpr->tree_reclaimed += reclaimed;
> -		scanned = vmpr->scanned;
>  		spin_unlock(&vmpr->sr_lock);
>  
>  		if (scanned < vmpressure_win)
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
