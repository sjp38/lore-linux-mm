Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f199.google.com (mail-lb0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7AE146B0253
	for <linux-mm@kvack.org>; Fri, 17 Jun 2016 05:50:34 -0400 (EDT)
Received: by mail-lb0-f199.google.com with SMTP id js8so38176630lbc.2
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 02:50:34 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id b6si11035509wjf.89.2016.06.17.02.50.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Jun 2016 02:50:33 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id 187so15406611wmz.1
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 02:50:33 -0700 (PDT)
Date: Fri, 17 Jun 2016 11:50:31 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/compaction: remove local variable is_lru
Message-ID: <20160617095030.GB21670@dhcp22.suse.cz>
References: <1466155971-6280-1-git-send-email-opensource.ganesh@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1466155971-6280-1-git-send-email-opensource.ganesh@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ganesh Mahendran <opensource.ganesh@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, vbabka@suse.cz, iamjoonsoo.kim@lge.com, hillf.zj@alibaba-inc.com, minchan@kernel.org

On Fri 17-06-16 17:32:51, Ganesh Mahendran wrote:
> local varialbe is_lru was used for tracking non-lru pages(such as
> balloon pages).
> 
> But commit
> 112ea7b668d3 ("mm: migrate: support non-lru movable page migration")

this commit sha is not stable because it is from the linux-next tree.

> introduced a common framework for non-lru page migration and moved
> the compound pages check before non-lru movable pages check.
> 
> So there is no need to use local variable is_lru.
> 
> Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>

Other than that the patch looks ok and maybe it would be worth folding
into the mm-migrate-support-non-lru-movable-page-migration.patch

> ---
>  mm/compaction.c | 4 +---
>  1 file changed, 1 insertion(+), 3 deletions(-)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index fbb7b38..780be7f 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -724,7 +724,6 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
>  
>  	/* Time to isolate some pages for migration */
>  	for (; low_pfn < end_pfn; low_pfn++) {
> -		bool is_lru;
>  
>  		if (skip_on_failure && low_pfn >= next_skip_pfn) {
>  			/*
> @@ -807,8 +806,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
>  		 * It's possible to migrate LRU and non-lru movable pages.
>  		 * Skip any other type of page
>  		 */
> -		is_lru = PageLRU(page);
> -		if (!is_lru) {
> +		if (!PageLRU(page)) {
>  			/*
>  			 * __PageMovable can return false positive so we need
>  			 * to verify it under page_lock.
> -- 
> 1.9.1
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
