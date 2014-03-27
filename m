Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f177.google.com (mail-we0-f177.google.com [74.125.82.177])
	by kanga.kvack.org (Postfix) with ESMTP id E5E296B0036
	for <linux-mm@kvack.org>; Thu, 27 Mar 2014 16:42:01 -0400 (EDT)
Received: by mail-we0-f177.google.com with SMTP id u57so2091772wes.8
        for <linux-mm@kvack.org>; Thu, 27 Mar 2014 13:42:01 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id ea8si5847478wib.23.2014.03.27.13.41.58
        for <linux-mm@kvack.org>;
        Thu, 27 Mar 2014 13:41:59 -0700 (PDT)
Message-ID: <53348D09.3060802@redhat.com>
Date: Thu, 27 Mar 2014 16:41:45 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: Only force scan in reclaim when none of the LRUs
 are big enough.
References: <alpine.LSU.2.11.1403151957160.21388@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1403151957160.21388@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>
Cc: Suleiman Souhlal <suleiman@google.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rafael Aquini <aquini@redhat.com>, Michal Hocko <mhocko@suse.cz>, Yuanhan Liu <yuanhan.liu@linux.intel.com>, Seth Jennings <sjennings@variantweb.net>, Bob Liu <bob.liu@oracle.com>, Minchan Kim <minchan@kernel.org>, Luigi Semenzato <semenzato@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 03/15/2014 11:36 PM, Hugh Dickins wrote:
> From: Suleiman Souhlal <suleiman@google.com>
>
> Prior to this change, we would decide whether to force scan a LRU
> during reclaim if that LRU itself was too small for the current
> priority. However, this can lead to the file LRU getting force
> scanned even if there are a lot of anonymous pages we can reclaim,
> leading to hot file pages getting needlessly reclaimed.
>
> To address this, we instead only force scan when none of the
> reclaimable LRUs are big enough.
>
> Gives huge improvements with zswap. For example, when doing -j20
> kernel build in a 500MB container with zswap enabled, runtime (in
> seconds) is greatly reduced:
>
> x without this change
> + with this change
>      N           Min           Max        Median           Avg        Stddev
> x   5       700.997       790.076       763.928        754.05      39.59493
> +   5       141.634       197.899       155.706         161.9     21.270224
> Difference at 95.0% confidence
>          -592.15 +/- 46.3521
>          -78.5293% +/- 6.14709%
>          (Student's t, pooled s = 31.7819)
>
> Should also give some improvements in regular (non-zswap) swap cases.
>
> Yes, hughd found significant speedup using regular swap, with several
> memcgs under pressure; and it should also be effective in the non-memcg
> case, whenever one or another zone LRU is forced too small.
>
> Signed-off-by: Suleiman Souhlal <suleiman@google.com>
> Signed-off-by: Hugh Dickins <hughd@google.com>

Acked-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
