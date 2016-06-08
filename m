Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f197.google.com (mail-lb0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id BE13E6B025E
	for <linux-mm@kvack.org>; Wed,  8 Jun 2016 03:25:56 -0400 (EDT)
Received: by mail-lb0-f197.google.com with SMTP id jf8so51667418lbc.3
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 00:25:56 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id y1si38325436wjm.132.2016.06.08.00.25.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Jun 2016 00:25:55 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id r5so612029wmr.0
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 00:25:55 -0700 (PDT)
Date: Wed, 8 Jun 2016 09:25:54 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: memcontrol: remove BUG_ON in uncharge_list
Message-ID: <20160608072554.GD22570@dhcp22.suse.cz>
References: <1465369248-13865-1-git-send-email-roy.qing.li@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1465369248-13865-1-git-send-email-roy.qing.li@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, roy.qing.li@gmail.com, vdavydov@virtuozzo.com

On Wed 08-06-16 15:00:48, roy.qing.li@gmail.com wrote:
> From: Li RongQing <roy.qing.li@gmail.com>
> 
> when call uncharge_list, if a page is transparent huge, and not need to
> BUG_ON about non-transparent huge, since nobody should be be seeing the
> page at this stage and this page cannot be raced with a THP split up

Johannes do you remember why you have kept this bug on even after
0a31bc97c80c ("mm: memcontrol: rewrite uncharge API")?

> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
> ---
>  mm/memcontrol.c | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 4d9a215..d7a56f1 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -5457,7 +5457,6 @@ static void uncharge_list(struct list_head *page_list)
>  
>  		if (PageTransHuge(page)) {
>  			nr_pages <<= compound_order(page);
> -			VM_BUG_ON_PAGE(!PageTransHuge(page), page);
>  			nr_huge += nr_pages;
>  		}
>  
> -- 
> 2.1.4

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
