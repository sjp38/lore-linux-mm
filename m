Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id C764E6B04FD
	for <linux-mm@kvack.org>; Wed,  7 Nov 2018 06:50:10 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id z72-v6so9358351ede.14
        for <linux-mm@kvack.org>; Wed, 07 Nov 2018 03:50:10 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y37-v6si529596edc.192.2018.11.07.03.50.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Nov 2018 03:50:09 -0800 (PST)
Subject: Re: [PATCH v1 4/4] mm: Remove managed_page_count spinlock
References: <1540551662-26458-1-git-send-email-arunks@codeaurora.org>
 <1540551662-26458-5-git-send-email-arunks@codeaurora.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <9a5351cd-f253-f4e1-804e-aa1dfcc99bbf@suse.cz>
Date: Wed, 7 Nov 2018 12:50:08 +0100
MIME-Version: 1.0
In-Reply-To: <1540551662-26458-5-git-send-email-arunks@codeaurora.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arun KS <arunks@codeaurora.org>
Cc: keescook@chromium.org, khlebnikov@yandex-team.ru, minchan@kernel.org, getarunks@gmail.com, gregkh@linuxfoundation.org, akpm@linux-foundation.org, mhocko@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 10/26/18 1:01 PM, Arun KS wrote:
> Now totalram_pages and managed_pages are atomic varibles. No need
> of managed_page_count spinlock.
> 
> Signed-off-by: Arun KS <arunks@codeaurora.org>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  include/linux/mmzone.h | 6 ------
>  mm/page_alloc.c        | 5 -----
>  2 files changed, 11 deletions(-)
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 597b0c7..aa960f6 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -428,12 +428,6 @@ struct zone {
>  	 * Write access to present_pages at runtime should be protected by
>  	 * mem_hotplug_begin/end(). Any reader who can't tolerant drift of
>  	 * present_pages should get_online_mems() to get a stable value.
> -	 *
> -	 * Read access to managed_pages should be safe because it's unsigned
> -	 * long. Write access to zone->managed_pages and totalram_pages are
> -	 * protected by managed_page_count_lock at runtime. Idealy only
> -	 * adjust_managed_page_count() should be used instead of directly
> -	 * touching zone->managed_pages and totalram_pages.
>  	 */
>  	atomic_long_t		managed_pages;
>  	unsigned long		spanned_pages;
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index af832de..e29e78f 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -122,9 +122,6 @@
>  };
>  EXPORT_SYMBOL(node_states);
>  
> -/* Protect totalram_pages and zone->managed_pages */
> -static DEFINE_SPINLOCK(managed_page_count_lock);
> -
>  atomic_long_t _totalram_pages __read_mostly;
>  unsigned long totalreserve_pages __read_mostly;
>  unsigned long totalcma_pages __read_mostly;
> @@ -7062,14 +7059,12 @@ static int __init cmdline_parse_movablecore(char *p)
>  
>  void adjust_managed_page_count(struct page *page, long count)
>  {
> -	spin_lock(&managed_page_count_lock);
>  	atomic_long_add(count, &page_zone(page)->managed_pages);
>  	totalram_pages_add(count);
>  #ifdef CONFIG_HIGHMEM
>  	if (PageHighMem(page))
>  		totalhigh_pages_add(count);
>  #endif
> -	spin_unlock(&managed_page_count_lock);
>  }
>  EXPORT_SYMBOL(adjust_managed_page_count);
>  
> 
