Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3E8106B0005
	for <linux-mm@kvack.org>; Wed, 11 May 2016 08:40:43 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id e201so41117950wme.1
        for <linux-mm@kvack.org>; Wed, 11 May 2016 05:40:43 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id q4si9141898wjx.148.2016.05.11.05.40.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 May 2016 05:40:41 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id w143so9139056wmw.3
        for <linux-mm@kvack.org>; Wed, 11 May 2016 05:40:41 -0700 (PDT)
Date: Wed, 11 May 2016 14:40:40 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC 01/13] mm, compaction: don't isolate PageWriteback pages in
 MIGRATE_SYNC_LIGHT mode
Message-ID: <20160511124039.GL16677@dhcp22.suse.cz>
References: <1462865763-22084-1-git-send-email-vbabka@suse.cz>
 <1462865763-22084-2-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1462865763-22084-2-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>

On Tue 10-05-16 09:35:51, Vlastimil Babka wrote:
> From: Hugh Dickins <hughd@google.com>
> 
> At present MIGRATE_SYNC_LIGHT is allowing __isolate_lru_page() to
> isolate a PageWriteback page, which __unmap_and_move() then rejects
> with -EBUSY: of course the writeback might complete in between, but
> that's not what we usually expect, so probably better not to isolate it.

this makes a lot of sense regardless the rest of the series. I will have
a look at the rest tomorrow more closely.

> 
> Signed-off-by: Hugh Dickins <hughd@google.com>
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/compaction.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index c72987603343..481004c73c90 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -1146,7 +1146,7 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
>  	struct page *page;
>  	const isolate_mode_t isolate_mode =
>  		(sysctl_compact_unevictable_allowed ? ISOLATE_UNEVICTABLE : 0) |
> -		(cc->mode == MIGRATE_ASYNC ? ISOLATE_ASYNC_MIGRATE : 0);
> +		(cc->mode != MIGRATE_SYNC ? ISOLATE_ASYNC_MIGRATE : 0);
>  
>  	/*
>  	 * Start at where we last stopped, or beginning of the zone as
> -- 
> 2.8.2

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
