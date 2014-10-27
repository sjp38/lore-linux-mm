Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f173.google.com (mail-lb0-f173.google.com [209.85.217.173])
	by kanga.kvack.org (Postfix) with ESMTP id A30716B0069
	for <linux-mm@kvack.org>; Mon, 27 Oct 2014 06:33:30 -0400 (EDT)
Received: by mail-lb0-f173.google.com with SMTP id l4so383270lbv.18
        for <linux-mm@kvack.org>; Mon, 27 Oct 2014 03:33:29 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id yf4si19186709lbb.124.2014.10.27.03.33.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 27 Oct 2014 03:33:27 -0700 (PDT)
Message-ID: <544E1F70.1030106@suse.cz>
Date: Mon, 27 Oct 2014 11:33:20 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH v4 1/4] mm/page_alloc: fix incorrect isolation behavior
 by rechecking migratetype
References: <1414051821-12769-1-git-send-email-iamjoonsoo.kim@lge.com> <1414051821-12769-2-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1414051821-12769-2-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Wen Congyang <wency@cn.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Laura Abbott <lauraa@codeaurora.org>, Heesub Shin <heesub.shin@samsung.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Ritesh Harjani <ritesh.list@gmail.com>, t.stanislaws@samsung.com, Gioh Kim <gioh.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

On 10/23/2014 10:10 AM, Joonsoo Kim wrote:
> Changes from v3:
> Add one more check in free_one_page() that checks whether migratetype is
> MIGRATE_ISOLATE or not. Without this, abovementioned case 1 could happens.

Good catch.

> Cc: <stable@vger.kernel.org>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

(minor suggestion below)

> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -749,9 +749,16 @@ static void free_one_page(struct zone *zone,
>  	if (nr_scanned)
>  		__mod_zone_page_state(zone, NR_PAGES_SCANNED, -nr_scanned);
>  
> +	if (unlikely(has_isolate_pageblock(zone) ||

Would it make any difference if this was read just once and not in each
loop iteration?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
