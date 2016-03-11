Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 24E9B6B025C
	for <linux-mm@kvack.org>; Fri, 11 Mar 2016 03:19:55 -0500 (EST)
Received: by mail-wm0-f42.google.com with SMTP id l68so7616545wml.0
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 00:19:55 -0800 (PST)
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com. [74.125.82.49])
        by mx.google.com with ESMTPS id kt2si9603386wjb.42.2016.03.11.00.19.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Mar 2016 00:19:54 -0800 (PST)
Received: by mail-wm0-f49.google.com with SMTP id p65so7751184wmp.1
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 00:19:53 -0800 (PST)
Date: Fri, 11 Mar 2016 09:19:52 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: memcontrol: clarify the uncharge_list() loop
Message-ID: <20160311081951.GD27701@dhcp22.suse.cz>
References: <1457643015-8828-3-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1457643015-8828-3-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Thu 10-03-16 15:50:15, Johannes Weiner wrote:
> uncharge_list() does an unusual list walk because the function can
> take regular lists with dedicated list_heads as well as singleton
> lists where a single page is passed via the page->lru list node.
> 
> This can sometimes lead to confusion as well as suggestions to replace
> the loop with a list_for_each_entry(), which wouldn't work.

Yes this confused at least me 2 times AFAIR.

> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!

> ---
>  mm/memcontrol.c | 4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 8614e0d750e5..fa7bf354ae32 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -5420,6 +5420,10 @@ static void uncharge_list(struct list_head *page_list)
>  	struct list_head *next;
>  	struct page *page;
>  
> +	/*
> +	 * Note that the list can be a single page->lru; hence the
> +	 * do-while loop instead of a simple list_for_each_entry().
> +	 */
>  	next = page_list->next;
>  	do {
>  		unsigned int nr_pages = 1;
> -- 
> 2.7.2

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
