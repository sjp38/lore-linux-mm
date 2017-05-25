Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id C9E266B02B4
	for <linux-mm@kvack.org>; Thu, 25 May 2017 04:13:32 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id i77so1640337wmh.10
        for <linux-mm@kvack.org>; Thu, 25 May 2017 01:13:32 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e38si25777455edb.56.2017.05.25.01.13.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 25 May 2017 01:13:31 -0700 (PDT)
Date: Thu, 25 May 2017 10:13:30 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [RFC PATCH] mm: fix mlock incorrent event account
Message-ID: <20170525081330.GG12721@dhcp22.suse.cz>
References: <1495699179-7566-1-git-send-email-zhongjiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1495699179-7566-1-git-send-email-zhongjiang@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhongjiang <zhongjiang@huawei.com>
Cc: akpm@linux-foundation.org, vbabka@suse.cz, qiuxishi@huawei.com, linux-mm@kvack.org

On Thu 25-05-17 15:59:39, zhongjiang wrote:
> From: zhong jiang <zhongjiang@huawei.com>
> 
> when clear_page_mlock call, we had finish the page isolate successfully,
> but it fails to increase the UNEVICTABLE_PGMUNLOCKED account.
> 
> The patch add the event account when successful page isolation.

Could you describe _what_ is the problem, how it can be _triggered_
and _how_ serious it is. Is it something that can be triggered from
userspace? The mlock code is really tricky and it is far from trivial
to see whether this is obviously right or a wrong assumption on your
side. Before people go and spend time reviewing it is fair to introduce
them to the problem.

I believe this is not the first time I am giving you this feedback
so I would _really_ appreciated if you tried harder with the changelog.
It is much simpler to write a patch than review it in many cases.

> Signed-off-by: zhong jiang <zhongjiang@huawei.com>
> ---
>  mm/mlock.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/mm/mlock.c b/mm/mlock.c
> index c483c5c..941930b 100644
> --- a/mm/mlock.c
> +++ b/mm/mlock.c
> @@ -64,6 +64,7 @@ void clear_page_mlock(struct page *page)
>  			    -hpage_nr_pages(page));
>  	count_vm_event(UNEVICTABLE_PGCLEARED);
>  	if (!isolate_lru_page(page)) {
> +		count_vm_event(UNEVICTABLE_PGMUNLOCKED);
>  		putback_lru_page(page);
>  	} else {
>  		/*
> -- 
> 1.8.3.1

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
