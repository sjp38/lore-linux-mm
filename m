Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f198.google.com (mail-ig0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6CF846B0005
	for <linux-mm@kvack.org>; Sun, 12 Jun 2016 03:33:40 -0400 (EDT)
Received: by mail-ig0-f198.google.com with SMTP id 2so56596357igy.1
        for <linux-mm@kvack.org>; Sun, 12 Jun 2016 00:33:40 -0700 (PDT)
Received: from out4434.biz.mail.alibaba.com (out4434.biz.mail.alibaba.com. [47.88.44.34])
        by mx.google.com with ESMTP id f11si1129495itb.95.2016.06.12.00.33.38
        for <linux-mm@kvack.org>;
        Sun, 12 Jun 2016 00:33:39 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <02ed01d1c47a$49fbfbc0$ddf3f340$@alibaba-inc.com>
In-Reply-To: <02ed01d1c47a$49fbfbc0$ddf3f340$@alibaba-inc.com>
Subject: Re: [PATCH 04/27] mm, vmscan: Begin reclaiming pages on a per-node basis
Date: Sun, 12 Jun 2016 15:33:25 +0800
Message-ID: <02f101d1c47c$b4bae0f0$1e30a2d0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Mel Gorman' <mgorman@techsingularity.net>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

> @@ -3207,15 +3228,14 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
>  			sc.may_writepage = 1;
> 
>  		/*
> -		 * Now scan the zone in the dma->highmem direction, stopping
> -		 * at the last zone which needs scanning.
> -		 *
> -		 * We do this because the page allocator works in the opposite
> -		 * direction.  This prevents the page allocator from allocating
> -		 * pages behind kswapd's direction of progress, which would
> -		 * cause too much scanning of the lower zones.
> +		 * Continue scanning in the highmem->dma direction stopping at
> +		 * the last zone which needs scanning. This may reclaim lowmem
> +		 * pages that are not necessary for zone balancing but it
> +		 * preserves LRU ordering. It is assumed that the bulk of
> +		 * allocation requests can use arbitrary zones with the
> +		 * possible exception of big highmem:lowmem configurations.
>  		 */
> -		for (i = 0; i <= end_zone; i++) {
> +		for (i = end_zone; i >= end_zone; i--) {

s/i >= end_zone;/i >= 0;/ ?

>  			struct zone *zone = pgdat->node_zones + i;
> 
>  			if (!populated_zone(zone))


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
