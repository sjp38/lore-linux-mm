Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 97DC66B0038
	for <linux-mm@kvack.org>; Tue,  3 Mar 2015 03:28:56 -0500 (EST)
Received: by pdbft15 with SMTP id ft15so24321992pdb.11
        for <linux-mm@kvack.org>; Tue, 03 Mar 2015 00:28:56 -0800 (PST)
Received: from e28smtp04.in.ibm.com (e28smtp04.in.ibm.com. [122.248.162.4])
        by mx.google.com with ESMTPS id rq5si88084pab.103.2015.03.03.00.28.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 03 Mar 2015 00:28:55 -0800 (PST)
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 3 Mar 2015 13:58:51 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 640CC1258044
	for <linux-mm@kvack.org>; Tue,  3 Mar 2015 14:00:10 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay03.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t238SfSd53280798
	for <linux-mm@kvack.org>; Tue, 3 Mar 2015 13:58:41 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t238SlXV024828
	for <linux-mm@kvack.org>; Tue, 3 Mar 2015 13:58:47 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [RFC 13/16] mm/cma: populate ZONE_CMA and use this zone when GFP_HIGHUSERMOVABLE
In-Reply-To: <1423726340-4084-14-git-send-email-iamjoonsoo.kim@lge.com>
References: <1423726340-4084-1-git-send-email-iamjoonsoo.kim@lge.com> <1423726340-4084-14-git-send-email-iamjoonsoo.kim@lge.com>
Date: Tue, 03 Mar 2015 13:58:46 +0530
Message-ID: <87vbiia3i9.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Heesub Shin <heesub.shin@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hui Zhu <zhuhui@xiaomi.com>, Gioh Kim <gioh.kim@lge.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Ritesh Harjani <ritesh.list@gmail.com>, Vlastimil Babka <vbabka@suse.cz>

Joonsoo Kim <iamjoonsoo.kim@lge.com> writes:

> Until now, reserved pages for CMA are managed altogether with normal
> page in the same zone. This approach has numorous problems and fixing
> them isn't easy. To fix this situation, ZONE_CMA is introduced in
> previous patch, but, not yet populated. This patch implement population
> of ZONE_CMA by stealing reserved pages from normal zones. This stealing
> break one uncertain assumption on zone, that is, zone isn't overlapped.
> In the early of this series, some check is inserted to every zone's span
> iterator to handle zone overlap so there would be no problem with
> this assumption break.
>
> To utilize this zone, user should use GFP_HIGHUSERMOVABLE, because
> these pages are only applicable for movable type and ZONE_CMA could
> contain highmem.
>
> Implementation itself is very easy to understand. Do steal when cma
> area is initialized and recalculate values for per zone data structure.
>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> ---
>  include/linux/gfp.h |   10 ++++++++--
>  include/linux/mm.h  |    1 +
>  mm/cma.c            |   23 ++++++++++++++++-------
>  mm/page_alloc.c     |   42 +++++++++++++++++++++++++++++++++++++++---
>  4 files changed, 64 insertions(+), 12 deletions(-)
>
> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index 619eb20..d125440 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -186,6 +186,12 @@ static inline int gfpflags_to_migratetype(const gfp_t gfp_flags)
>  #define OPT_ZONE_DMA32 ZONE_NORMAL
>  #endif
>  
> +#ifdef CONFIG_CMA
> +#define OPT_ZONE_CMA ZONE_CMA
> +#else
> +#define OPT_ZONE_CMA ZONE_MOVABLE
> +#endif
> +

Does that mean with CONFIG_CMA we always try ZONE_CMA first and then
fallback to ZONE_MOVABLE ? If so won't we hit termporary CMA allocation
failures that can result with pinned movable pages ?

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
