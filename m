Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id DD98F6B0267
	for <linux-mm@kvack.org>; Tue, 26 Apr 2016 10:27:43 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id k200so14712702lfg.1
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 07:27:43 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z126si3570766wmz.77.2016.04.26.07.27.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 26 Apr 2016 07:27:42 -0700 (PDT)
Subject: Re: [PATCH 17/28] mm, page_alloc: Check once if a zone has isolated
 pageblocks
References: <1460710760-32601-1-git-send-email-mgorman@techsingularity.net>
 <1460711275-1130-1-git-send-email-mgorman@techsingularity.net>
 <1460711275-1130-5-git-send-email-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <571F7AD8.10301@suse.cz>
Date: Tue, 26 Apr 2016 16:27:36 +0200
MIME-Version: 1.0
In-Reply-To: <1460711275-1130-5-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 04/15/2016 11:07 AM, Mel Gorman wrote:
> When bulk freeing pages from the per-cpu lists the zone is checked
> for isolated pageblocks on every release. This patch checks it once
> per drain. Technically this is race-prone but so is the existing
> code.

No, existing code is protected by zone->lock. Both checking and manipulating the
variable zone->nr_isolate_pageblock should happen under the lock, as correct
accounting depends on it.

Luckily, the patch could be simply fixed by removing last changelog sentence and:

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 49aabfb39ff1..7de04bdd8c67 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -831,9 +831,10 @@ static void free_pcppages_bulk(struct zone *zone, int count,
        int batch_free = 0;
        int to_free = count;
        unsigned long nr_scanned;
-       bool isolated_pageblocks = has_isolate_pageblock(zone);
+       bool isolated_pageblocks;
 
        spin_lock(&zone->lock);
+       isolated_pageblocks = has_isolate_pageblock(zone);
        nr_scanned = zone_page_state(zone, NR_PAGES_SCANNED);
        if (nr_scanned)
                __mod_zone_page_state(zone, NR_PAGES_SCANNED, -nr_scanned);

> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> ---
>   mm/page_alloc.c | 3 ++-
>   1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 4a364e318873..835a1c434832 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -831,6 +831,7 @@ static void free_pcppages_bulk(struct zone *zone, int count,
>   	int batch_free = 0;
>   	int to_free = count;
>   	unsigned long nr_scanned;
> +	bool isolated_pageblocks = has_isolate_pageblock(zone);
>   
>   	spin_lock(&zone->lock);
>   	nr_scanned = zone_page_state(zone, NR_PAGES_SCANNED);
> @@ -870,7 +871,7 @@ static void free_pcppages_bulk(struct zone *zone, int count,
>   			/* MIGRATE_ISOLATE page should not go to pcplists */
>   			VM_BUG_ON_PAGE(is_migrate_isolate(mt), page);
>   			/* Pageblock could have been isolated meanwhile */
> -			if (unlikely(has_isolate_pageblock(zone)))
> +			if (unlikely(isolated_pageblocks))
>   				mt = get_pageblock_migratetype(page);
>   
>   			__free_one_page(page, page_to_pfn(page), zone, 0, mt);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
