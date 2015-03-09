Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f177.google.com (mail-ig0-f177.google.com [209.85.213.177])
	by kanga.kvack.org (Postfix) with ESMTP id AD2DB6B0032
	for <linux-mm@kvack.org>; Mon,  9 Mar 2015 15:57:57 -0400 (EDT)
Received: by igal13 with SMTP id l13so24720532iga.0
        for <linux-mm@kvack.org>; Mon, 09 Mar 2015 12:57:57 -0700 (PDT)
Received: from mail-ig0-x233.google.com (mail-ig0-x233.google.com. [2607:f8b0:4001:c05::233])
        by mx.google.com with ESMTPS id e6si521707icr.34.2015.03.09.12.57.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Mar 2015 12:57:57 -0700 (PDT)
Received: by igbhn18 with SMTP id hn18so24692210igb.2
        for <linux-mm@kvack.org>; Mon, 09 Mar 2015 12:57:56 -0700 (PDT)
Date: Mon, 9 Mar 2015 12:57:54 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH V2] Allow compaction of unevictable pages
In-Reply-To: <1425921156-16923-1-git-send-email-emunson@akamai.com>
Message-ID: <alpine.DEB.2.10.1503091254380.26686@chino.kir.corp.google.com>
References: <1425921156-16923-1-git-send-email-emunson@akamai.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@akamai.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Thomas Gleixner <tglx@linutronix.de>, Christoph Lameter <cl@linux.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 9 Mar 2015, Eric B Munson wrote:

> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index f279d9c..599fb01 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -232,8 +232,6 @@ struct lruvec {
>  #define ISOLATE_UNMAPPED	((__force isolate_mode_t)0x2)
>  /* Isolate for asynchronous migration */
>  #define ISOLATE_ASYNC_MIGRATE	((__force isolate_mode_t)0x4)
> -/* Isolate unevictable pages */
> -#define ISOLATE_UNEVICTABLE	((__force isolate_mode_t)0x8)
>  
>  /* LRU Isolation modes. */
>  typedef unsigned __bitwise__ isolate_mode_t;
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 8c0d945..4a8ea87 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -872,8 +872,7 @@ isolate_migratepages_range(struct compact_control *cc, unsigned long start_pfn,
>  		if (!pageblock_pfn_to_page(pfn, block_end_pfn, cc->zone))
>  			continue;
>  
> -		pfn = isolate_migratepages_block(cc, pfn, block_end_pfn,
> -							ISOLATE_UNEVICTABLE);
> +		pfn = isolate_migratepages_block(cc, pfn, block_end_pfn, 0);
>  
>  		/*
>  		 * In case of fatal failure, release everything that might
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 5e8eadd..3b2a444 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1234,10 +1234,6 @@ int __isolate_lru_page(struct page *page, isolate_mode_t mode)
>  	if (!PageLRU(page))
>  		return ret;
>  
> -	/* Compaction should not handle unevictable pages but CMA can do so */
> -	if (PageUnevictable(page) && !(mode & ISOLATE_UNEVICTABLE))
> -		return ret;
> -
>  	ret = -EBUSY;
>  
>  	/*

Looks better!

I think there's one more cleanup we can do now thanks to your patch: 
dropping the isolate_mode_t formal from isolate_migratepages_block() 
entirely since that function can now just do

	const isolate_mode_t isolate_mode =
		(cc->mode == MIGRATE_ASYNC ? ISOLATE_ASYNC_MIGRATE : 0);

since we already pass in the struct compact_control and isolate_mode only 
depends on MIGRATE_ASYNC or not.

If you'd like to fold that change into this patch because it's logically 
allowed by it, feel free to add my enthusiastic

	Acked-by: David Rientjes <rientjes@google.com>

Otherwise, I'll just send a change on top of it if you don't have time.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
