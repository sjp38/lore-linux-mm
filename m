Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 23B7C6B00C8
	for <linux-mm@kvack.org>; Tue,  6 Jan 2015 09:30:16 -0500 (EST)
Received: by mail-wi0-f174.google.com with SMTP id h11so5463490wiw.1
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 06:30:15 -0800 (PST)
Received: from mail-wi0-x231.google.com (mail-wi0-x231.google.com. [2a00:1450:400c:c05::231])
        by mx.google.com with ESMTPS id u5si24432866wix.101.2015.01.06.06.30.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 Jan 2015 06:30:13 -0800 (PST)
Received: by mail-wi0-f177.google.com with SMTP id l15so5461093wiw.10
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 06:30:13 -0800 (PST)
Date: Tue, 6 Jan 2015 15:30:08 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH V4 1/4] mm: set page->pfmemalloc in prep_new_page()
Message-ID: <20150106143008.GA20860@dhcp22.suse.cz>
References: <1420478263-25207-1-git-send-email-vbabka@suse.cz>
 <1420478263-25207-2-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1420478263-25207-2-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Minchan Kim <minchan@kernel.org>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Mon 05-01-15 18:17:40, Vlastimil Babka wrote:
> The function prep_new_page() sets almost everything in the struct page of the
> page being allocated, except page->pfmemalloc. This is not obvious and has at
> least once led to a bug where page->pfmemalloc was forgotten to be set
> correctly, see commit 8fb74b9fb2b1 ("mm: compaction: partially revert capture
> of suitable high-order page").
> 
> This patch moves the pfmemalloc setting to prep_new_page(), which means it
> needs to gain alloc_flags parameter. The call to prep_new_page is moved from
> buffered_rmqueue() to get_page_from_freelist(), which also leads to simpler
> code. An obsolete comment for buffered_rmqueue() is replaced.
> 
> In addition to better maintainability there is a small reduction of code and
> stack usage for get_page_from_freelist(), which inlines the other functions
> involved.
> 
> add/remove: 0/0 grow/shrink: 0/1 up/down: 0/-145 (-145)
> function                                     old     new   delta
> get_page_from_freelist                      2670    2525    -145
> 
> Stack usage is reduced from 184 to 168 bytes.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Michal Hocko <mhocko@suse.cz>

get_page_from_freelist has grown too hairy. I agree that it is tiny less
confusing now because we are not breaking out of the loop in the
successful case.

Acked-by: Michal Hocko <mhocko@suse.cz>

[...]
> @@ -2177,25 +2181,16 @@ zonelist_scan:
>  try_this_zone:
>  		page = buffered_rmqueue(preferred_zone, zone, order,
>  						gfp_mask, migratetype);
> -		if (page)
> -			break;
> +		if (page) {
> +			if (prep_new_page(page, order, gfp_mask, alloc_flags))
> +				goto try_this_zone;
> +			return page;
> +		}

I would probably liked `do {} while ()' more because it wouldn't use the
goto, but this is up to you:

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1bb65e6f48dd..1682d766cb8e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2175,10 +2175,11 @@ zonelist_scan:
 		}
 
 try_this_zone:
-		page = buffered_rmqueue(preferred_zone, zone, order,
+		do {
+			page = buffered_rmqueue(preferred_zone, zone, order,
 						gfp_mask, migratetype);
-		if (page)
-			break;
+		} while (page && prep_new_page(page, order, gfp_mask,
+					       alloc_flags));
 this_zone_full:
 		if (IS_ENABLED(CONFIG_NUMA) && zlc_active)
 			zlc_mark_zone_full(zonelist, z);

[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
