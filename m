Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id E55856810B5
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 07:05:19 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id l18so288489wmd.12
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 04:05:19 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 12si1373555wme.229.2017.08.24.04.05.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 24 Aug 2017 04:05:18 -0700 (PDT)
Subject: Re: [PATCH] mm/mlock: use page_zone() instead of page_zone_id()
References: <1503559211-10259-1-git-send-email-iamjoonsoo.kim@lge.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <a8cca363-544d-1b7e-0e93-d7df5c5b6f20@suse.cz>
Date: Thu, 24 Aug 2017 13:05:15 +0200
MIME-Version: 1.0
In-Reply-To: <1503559211-10259-1-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com, Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>

+CC Mel

On 08/24/2017 09:20 AM, js1304@gmail.com wrote:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> page_zone_id() is a specialized function to compare the zone for the pages
> that are within the section range. If the section of the pages are
> different, page_zone_id() can be different even if their zone is the same.
> This wrong usage doesn't cause any actual problem since
> __munlock_pagevec_fill() would be called again with failed index. However,
> it's better to use more appropriate function here.

Hmm using zone id was part of the series making munlock faster. Too bad
it's doing the wrong thing on some memory models. Looks like it wasn't
evaluated in isolation, but only as part of the pagevec usage (commit
7a8010cd36273) but most likely it wasn't contributing too much to the
14% speedup.

> This patch is also preparation for futher change about page_zone_id().

Out of curiosity, what kind of change?

Vlastimil

> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> ---
>  mm/mlock.c | 10 ++++------
>  1 file changed, 4 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/mlock.c b/mm/mlock.c
> index b562b55..dfc6f19 100644
> --- a/mm/mlock.c
> +++ b/mm/mlock.c
> @@ -365,8 +365,8 @@ static void __munlock_pagevec(struct pagevec *pvec, struct zone *zone)
>   * @start + PAGE_SIZE when no page could be added by the pte walk.
>   */
>  static unsigned long __munlock_pagevec_fill(struct pagevec *pvec,
> -		struct vm_area_struct *vma, int zoneid,	unsigned long start,
> -		unsigned long end)
> +			struct vm_area_struct *vma, struct zone *zone,
> +			unsigned long start, unsigned long end)
>  {
>  	pte_t *pte;
>  	spinlock_t *ptl;
> @@ -394,7 +394,7 @@ static unsigned long __munlock_pagevec_fill(struct pagevec *pvec,
>  		 * Break if page could not be obtained or the page's node+zone does not
>  		 * match
>  		 */
> -		if (!page || page_zone_id(page) != zoneid)
> +		if (!page || page_zone(page) != zone)
>  			break;
>  
>  		/*
> @@ -446,7 +446,6 @@ void munlock_vma_pages_range(struct vm_area_struct *vma,
>  		unsigned long page_increm;
>  		struct pagevec pvec;
>  		struct zone *zone;
> -		int zoneid;
>  
>  		pagevec_init(&pvec, 0);
>  		/*
> @@ -481,7 +480,6 @@ void munlock_vma_pages_range(struct vm_area_struct *vma,
>  				 */
>  				pagevec_add(&pvec, page);
>  				zone = page_zone(page);
> -				zoneid = page_zone_id(page);
>  
>  				/*
>  				 * Try to fill the rest of pagevec using fast
> @@ -490,7 +488,7 @@ void munlock_vma_pages_range(struct vm_area_struct *vma,
>  				 * pagevec.
>  				 */
>  				start = __munlock_pagevec_fill(&pvec, vma,
> -						zoneid, start, end);
> +						zone, start, end);
>  				__munlock_pagevec(&pvec, zone);
>  				goto next;
>  			}
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
