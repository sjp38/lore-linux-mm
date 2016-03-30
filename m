Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id EF17C6B025F
	for <linux-mm@kvack.org>; Wed, 30 Mar 2016 05:24:41 -0400 (EDT)
Received: by mail-wm0-f50.google.com with SMTP id r72so90560585wmg.0
        for <linux-mm@kvack.org>; Wed, 30 Mar 2016 02:24:41 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id z126si3592342wmz.77.2016.03.30.02.24.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Mar 2016 02:24:40 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id p65so12837256wmp.1
        for <linux-mm@kvack.org>; Wed, 30 Mar 2016 02:24:40 -0700 (PDT)
Date: Wed, 30 Mar 2016 11:24:38 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/highmem: simplify is_highmem()
Message-ID: <20160330092438.GG30729@dhcp22.suse.cz>
References: <1459313022-11750-1-git-send-email-chanho.min@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1459313022-11750-1-git-send-email-chanho.min@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chanho Min <chanho.min@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Dan Williams <dan.j.williams@intel.com>, Zhang Zhen <zhenzhang.zhang@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Gunho Lee <gunho.lee@lge.com>

On Wed 30-03-16 13:43:42, Chanho Min wrote:
> The is_highmem() is can be simplified by use of is_highmem_idx().
> This patch removes redundant code and will make it easier to maintain
> if the zone policy is changed or a new zone is added.
> 
> Signed-off-by: Chanho Min <chanho.min@lge.com>
> ---
>  include/linux/mmzone.h |    5 +----
>  1 file changed, 1 insertion(+), 4 deletions(-)
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index e23a9e7..9ac90c3 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -817,10 +817,7 @@ static inline int is_highmem_idx(enum zone_type idx)
>  static inline int is_highmem(struct zone *zone)
>  {
>  #ifdef CONFIG_HIGHMEM
> -	int zone_off = (char *)zone - (char *)zone->zone_pgdat->node_zones;
> -	return zone_off == ZONE_HIGHMEM * sizeof(*zone) ||
> -	       (zone_off == ZONE_MOVABLE * sizeof(*zone) &&
> -		zone_movable_is_highmem());
> +	return is_highmem_idx(zone_idx(zone));

This will reintroduce the pointer arithmetic removed by ddc81ed2c5d4
("remove sparse warning for mmzone.h") AFAICS. I have no idea how much
that matters though. The mentioned commit doesn't tell much about saves
except for
"
	On X86_32 this saves a sar, but code size increases by one byte per
        is_highmem() use due to 32-bit cmps rather than 16 bit cmps.
"

>  #else
>  	return 0;
>  #endif
> -- 
> 1.7.9.5
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
