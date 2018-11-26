Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 13C706B3F51
	for <linux-mm@kvack.org>; Sun, 25 Nov 2018 21:01:29 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id m13so20593061pls.15
        for <linux-mm@kvack.org>; Sun, 25 Nov 2018 18:01:29 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id u9si38147784plk.61.2018.11.25.18.01.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 25 Nov 2018 18:01:27 -0800 (PST)
Date: Sun, 25 Nov 2018 18:01:15 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm: do not consider SWAP to calculate available when not
 necessary
Message-ID: <20181126020115.GF3065@bombadil.infradead.org>
References: <1543190303-8121-1-git-send-email-yang.yang29@zte.com.cn>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1543190303-8121-1-git-send-email-yang.yang29@zte.com.cn>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Yang <yang.yang29@zte.com.cn>
Cc: akpm@linux-foundation.org, mhocko@suse.com, pavel.tatashin@microsoft.com, vbabka@suse.cz, osalvador@suse.de, rppt@linux.vnet.ibm.com, iamjoonsoo.kim@lge.com, alexander.h.duyck@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, zhong.weidong@zte.com.cn, wang.yi59@zte.com.cn

On Mon, Nov 26, 2018 at 07:58:23AM +0800, Yang Yang wrote:
> When si_mem_available() calculates 'available', it takes SWAP
> into account. But if CONFIG_SWAP is N or SWAP is off(some embedded system
> would like to do that), there is no need to consider it.

I don't understand this patch.  The pagecache can be written back to
storage if it is dirty, regardless of whether there is swap space.

> @@ -4724,9 +4726,13 @@ long si_mem_available(void)
>  	 * Not all the page cache can be freed, otherwise the system will
>  	 * start swapping. Assume at least half of the page cache, or the
>  	 * low watermark worth of cache, needs to stay.
> +	 * But if CONFIG_SWAP is N or SWAP is off, do not consider it.
>  	 */
>  	pagecache = pages[LRU_ACTIVE_FILE] + pages[LRU_INACTIVE_FILE];
> -	pagecache -= min(pagecache / 2, wmark_low);
> +#ifdef CONFIG_SWAP
> +	if (i.totalswap > 0)
> +		pagecache -= min(pagecache / 2, wmark_low);
> +#endif
>  	available += pagecache;
>  
>  	/*
> -- 
> 2.15.2
> 
