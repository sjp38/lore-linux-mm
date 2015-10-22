Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f47.google.com (mail-lf0-f47.google.com [209.85.215.47])
	by kanga.kvack.org (Postfix) with ESMTP id 589066B0038
	for <linux-mm@kvack.org>; Thu, 22 Oct 2015 14:49:08 -0400 (EDT)
Received: by lffv3 with SMTP id v3so58827950lff.0
        for <linux-mm@kvack.org>; Thu, 22 Oct 2015 11:49:07 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id jv8si10447147lbc.86.2015.10.22.11.49.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Oct 2015 11:49:07 -0700 (PDT)
Date: Thu, 22 Oct 2015 21:48:53 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 7/8] mm: vmscan: report vmpressure at the level of
 reclaim activity
Message-ID: <20151022184852.GP18351@esperanza>
References: <1445487696-21545-1-git-send-email-hannes@cmpxchg.org>
 <1445487696-21545-8-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1445487696-21545-8-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: "David S. Miller" <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Tejun Heo <tj@kernel.org>, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Oct 22, 2015 at 12:21:35AM -0400, Johannes Weiner wrote:
...
> @@ -2437,6 +2439,10 @@ static bool shrink_zone(struct zone *zone, struct scan_control *sc,
>  				}
>  			}
>  
> +			vmpressure(sc->gfp_mask, memcg,
> +				   sc->nr_scanned - scanned,
> +				   sc->nr_reclaimed - reclaimed);
> +
>  			/*
>  			 * Direct reclaim and kswapd have to scan all memory
>  			 * cgroups to fulfill the overall scan target for the
> @@ -2454,10 +2460,6 @@ static bool shrink_zone(struct zone *zone, struct scan_control *sc,
>  			}
>  		} while ((memcg = mem_cgroup_iter(root, memcg, &reclaim)));
>  
> -		vmpressure(sc->gfp_mask, sc->target_mem_cgroup,
> -			   sc->nr_scanned - nr_scanned,
> -			   sc->nr_reclaimed - nr_reclaimed);
> -
>  		if (sc->nr_reclaimed - nr_reclaimed)
>  			reclaimable = true;
>  

I may be mistaken, but AFAIU this patch subtly changes the behavior of
vmpressure visible from the userspace: w/o this patch a userspace
process will only receive a notification for a memory cgroup only if
*this* memory cgroup calls reclaimer; with this patch userspace
notification will be issued even if reclaimer is invoked by any cgroup
up the hierarchy.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
