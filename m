Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f48.google.com (mail-oa0-f48.google.com [209.85.219.48])
	by kanga.kvack.org (Postfix) with ESMTP id 319406B0035
	for <linux-mm@kvack.org>; Thu, 31 Oct 2013 01:15:42 -0400 (EDT)
Received: by mail-oa0-f48.google.com with SMTP id m17so2568411oag.35
        for <linux-mm@kvack.org>; Wed, 30 Oct 2013 22:15:41 -0700 (PDT)
Received: from psmtp.com ([74.125.245.111])
        by mx.google.com with SMTP id f9si857772obe.19.2013.10.30.22.15.41
        for <linux-mm@kvack.org>;
        Wed, 30 Oct 2013 22:15:41 -0700 (PDT)
Received: by mail-qa0-f47.google.com with SMTP id k15so4278952qaq.20
        for <linux-mm@kvack.org>; Wed, 30 Oct 2013 22:15:39 -0700 (PDT)
Message-ID: <5271E77A.7080701@gmail.com>
Date: Thu, 31 Oct 2013 01:15:38 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: __rmqueue_fallback() should respect pageblock type
References: <1383193489-27331-1-git-send-email-kosaki.motohiro@gmail.com>
In-Reply-To: <1383193489-27331-1-git-send-email-kosaki.motohiro@gmail.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>

(10/31/13 12:24 AM), kosaki.motohiro@gmail.com wrote:
> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> 
> When __rmqueue_fallback() don't find out a free block with the same size
> of required, it splits a larger page and puts back rest peiece of the page
> to free list.
> 
> But it has one serious mistake. When putting back, __rmqueue_fallback()
> always use start_migratetype if type is not CMA. However, __rmqueue_fallback()
> is only called when all of start_migratetype queue are empty. That said,
> __rmqueue_fallback always put back memory to wrong queue except
> try_to_steal_freepages() changed pageblock type (i.e. requested size is
> smaller than half of page block). Finally, antifragmentation framework
> increase fragmenation instead of decrease.
> 
> Mel's original anti fragmentation do the right thing. But commit 47118af076
> (mm: mmzone: MIGRATE_CMA migration type added) broke it.
> 
> This patch restores sane and old behavior.
> 
> Cc: Mel Gorman <mgorman@suse.de>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> ---
>   mm/page_alloc.c |    2 +-
>   1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index dd886fa..ea7bb9a 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1101,7 +1101,7 @@ __rmqueue_fallback(struct zone *zone, int order, int start_migratetype)
>   			 */
>   			expand(zone, page, order, current_order, area,
>   			       is_migrate_cma(migratetype)
> -			     ? migratetype : start_migratetype);
> +			     ? migratetype : new_type);

Oops, this can be simplified to following because try_to_steal_freepages() has cma check.


-                       expand(zone, page, order, current_order, area,
-                              is_migrate_cma(migratetype)
-                            ? migratetype : start_migratetype);
+                       expand(zone, page, order, current_order, area, new_type);



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
