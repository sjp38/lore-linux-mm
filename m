Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 99B1F6B043D
	for <linux-mm@kvack.org>; Fri, 10 Mar 2017 02:30:04 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id w37so27521285wrc.2
        for <linux-mm@kvack.org>; Thu, 09 Mar 2017 23:30:04 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v2si11826057wrd.12.2017.03.09.23.30.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 09 Mar 2017 23:30:03 -0800 (PST)
Subject: Re: [RFC] mm/compaction: ignore block suitable after check large free
 page
References: <1489119648-59583-1-git-send-email-xieyisheng1@huawei.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <eb3bbece-77ea-b88f-d4bf-dbf9bdf7f413@suse.cz>
Date: Fri, 10 Mar 2017 08:30:00 +0100
MIME-Version: 1.0
In-Reply-To: <1489119648-59583-1-git-send-email-xieyisheng1@huawei.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yisheng Xie <xieyisheng1@huawei.com>, akpm@linux-foundation.org, mhocko@suse.com, mgorman@techsingularity.net, iamjoonsoo.kim@lge.com, rientjes@google.com, minchan@kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, guohanjun@huawei.com, qiuxishi@huawei.com, liubo95@huawei.com

On 03/10/2017 05:20 AM, Yisheng Xie wrote:
> If the migrate target is a large free page and we ignore suitable,
> it may not good for defrag. So move the ignore block suitable after
> check large free page.

Right. But in practice I expect close to no impact, because direct
compaction shouldn't have to be called if there's a >=pageblock_order
page already available.

> Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>
> ---
>  mm/compaction.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 0fdfde0..4bf2a5d 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -991,9 +991,6 @@ static bool too_many_isolated(struct zone *zone)
>  static bool suitable_migration_target(struct compact_control *cc,
>  							struct page *page)
>  {
> -	if (cc->ignore_block_suitable)
> -		return true;
> -
>  	/* If the page is a large free page, then disallow migration */
>  	if (PageBuddy(page)) {
>  		/*
> @@ -1005,6 +1002,9 @@ static bool suitable_migration_target(struct compact_control *cc,
>  			return false;
>  	}
>  
> +	if (cc->ignore_block_suitable)
> +		return true;
> +
>  	/* If the block is MIGRATE_MOVABLE or MIGRATE_CMA, allow migration */
>  	if (migrate_async_suitable(get_pageblock_migratetype(page)))
>  		return true;
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
