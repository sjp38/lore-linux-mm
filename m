Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f169.google.com (mail-yk0-f169.google.com [209.85.160.169])
	by kanga.kvack.org (Postfix) with ESMTP id DFF766B0038
	for <linux-mm@kvack.org>; Tue,  4 Aug 2015 18:09:40 -0400 (EDT)
Received: by ykeo23 with SMTP id o23so20446424yke.3
        for <linux-mm@kvack.org>; Tue, 04 Aug 2015 15:09:40 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id m135si725496ywd.5.2015.08.04.15.09.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Aug 2015 15:09:39 -0700 (PDT)
Date: Tue, 4 Aug 2015 15:09:37 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] vmscan: fix increasing nr_isolated incurred by
 putback unevictable pages
Message-Id: <20150804150937.ee3b62257e77911a2f41a48e@linux-foundation.org>
In-Reply-To: <1438684808-12707-1-git-send-email-jaewon31.kim@samsung.com>
References: <1438684808-12707-1-git-send-email-jaewon31.kim@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jaewon Kim <jaewon31.kim@samsung.com>
Cc: mgorman@suse.de, minchan@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jaewon31.kim@gmail.com

On Tue, 04 Aug 2015 19:40:08 +0900 Jaewon Kim <jaewon31.kim@samsung.com> wrote:

> reclaim_clean_pages_from_list() assumes that shrink_page_list() returns
> number of pages removed from the candidate list. But shrink_page_list()
> puts back mlocked pages without passing it to caller and without
> counting as nr_reclaimed. This incurrs increasing nr_isolated.
> To fix this, this patch changes shrink_page_list() to pass unevictable
> pages back to caller. Caller will take care those pages.
> 
> ..
>
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1157,7 +1157,7 @@ cull_mlocked:
>  		if (PageSwapCache(page))
>  			try_to_free_swap(page);
>  		unlock_page(page);
> -		putback_lru_page(page);
> +		list_add(&page->lru, &ret_pages);
>  		continue;
>  
>  activate_locked:

Is this going to cause a whole bunch of mlocked pages to be migrated
whereas in current kernels they stay where they are?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
