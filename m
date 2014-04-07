Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f51.google.com (mail-ee0-f51.google.com [74.125.83.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2E7346B0037
	for <linux-mm@kvack.org>; Mon,  7 Apr 2014 10:46:16 -0400 (EDT)
Received: by mail-ee0-f51.google.com with SMTP id c13so689297eek.24
        for <linux-mm@kvack.org>; Mon, 07 Apr 2014 07:46:15 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w48si24189058eel.326.2014.04.07.07.46.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 07 Apr 2014 07:46:14 -0700 (PDT)
Message-ID: <5342BA34.8050006@suse.cz>
Date: Mon, 07 Apr 2014 16:46:12 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] mm/compaction: fix to initialize free scanner properly
References: <1396515424-18794-1-git-send-email-heesub.shin@samsung.com> <1396515424-18794-2-git-send-email-heesub.shin@samsung.com>
In-Reply-To: <1396515424-18794-2-git-send-email-heesub.shin@samsung.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Heesub Shin <heesub.shin@samsung.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Dongjun Shin <d.j.shin@samsung.com>, Sunghwan Yun <sunghwan.yun@samsung.com>

On 04/03/2014 10:57 AM, Heesub Shin wrote:
> Free scanner does not works well on systems having zones which do not
> span to pageblock-aligned boundary.
>
> zone->compact_cached_free_pfn is reset when the migration and free
> scanner across or compaction restarts. After the reset, if end_pfn of
> the zone was not aligned to pageblock_nr_pages, free scanner tries to
> isolate free pages from the middle of pageblock to the end, which can
> be very small range.

Hm good catch. I think that the same problem can happen (at least 
theoretically) through zone->compact_cached_free_pfn with 
CONFIG_HOLES_IN_ZONE enabled. Then compact_cached_free_pfn could be set
to a non-aligned-to-pageblock pfn and spoil scans. I'll send a patch 
that solves it on isolate_freepages() level, which allows further 
simplification of the function.

Vlastimil

> Signed-off-by: Heesub Shin <heesub.shin@samsung.com>
> Cc: Dongjun Shin <d.j.shin@samsung.com>
> Cc: Sunghwan Yun <sunghwan.yun@samsung.com>
> ---
>   mm/compaction.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 1ef9144..fefe1da 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -983,7 +983,7 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
>   	 */
>   	cc->migrate_pfn = zone->compact_cached_migrate_pfn;
>   	cc->free_pfn = zone->compact_cached_free_pfn;
> -	if (cc->free_pfn < start_pfn || cc->free_pfn > end_pfn) {
> +	if (cc->free_pfn < start_pfn || cc->free_pfn >= end_pfn) {
>   		cc->free_pfn = end_pfn & ~(pageblock_nr_pages-1);
>   		zone->compact_cached_free_pfn = cc->free_pfn;
>   	}
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
