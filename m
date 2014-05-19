Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 03AE06B0036
	for <linux-mm@kvack.org>; Mon, 19 May 2014 01:52:59 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id ey11so5289740pad.32
        for <linux-mm@kvack.org>; Sun, 18 May 2014 22:52:59 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id wp2si18116305pab.65.2014.05.18.22.52.57
        for <linux-mm@kvack.org>;
        Sun, 18 May 2014 22:52:59 -0700 (PDT)
Date: Mon, 19 May 2014 14:55:27 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC][PATCH] CMA: drivers/base/Kconfig: restrict CMA size to
 non-zero value
Message-ID: <20140519055527.GA24099@js1304-P5Q-DELUXE>
References: <1399509144-8898-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1399509144-8898-3-git-send-email-iamjoonsoo.kim@lge.com>
 <20140513030057.GC32092@bbox>
 <20140515015301.GA10116@js1304-P5Q-DELUXE>
 <5375C619.8010501@lge.com>
 <xa1tppjdfwif.fsf@mina86.com>
 <537962A0.4090600@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <537962A0.4090600@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gioh Kim <gioh.kim@lge.com>
Cc: Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Laura Abbott <lauraa@codeaurora.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Heesub Shin <heesub.shin@samsung.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Marek Szyprowski <m.szyprowski@samsung.com>, =?utf-8?B?7J206rG07Zi4?= <gunho.lee@lge.com>, gurugio@gmail.com

On Mon, May 19, 2014 at 10:47:12AM +0900, Gioh Kim wrote:
> Thank you for your advice. I didn't notice it.
> 
> I'm adding followings according to your advice:
> 
> - range restrict for CMA_SIZE_MBYTES and *CMA_SIZE_PERCENTAGE*
> I think this can prevent the wrong kernel option.
> 
> - change size_cmdline into default value SZ_16M
> I am not sure this can prevent if cma=0 cmdline option is also with base and limit options.

Hello,

I think that this problem is originated from atomic_pool_init().
If configured coherent_pool size is larger than default cma size,
it can be failed even if this patch is applied.

How about below patch?
It uses fallback allocation if CMA is failed.

Thanks.

-----------------8<---------------------
diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
index 6b00be1..2909ab9 100644
--- a/arch/arm/mm/dma-mapping.c
+++ b/arch/arm/mm/dma-mapping.c
@@ -379,7 +379,7 @@ static int __init atomic_pool_init(void)
        unsigned long *bitmap;
        struct page *page;
        struct page **pages;
-       void *ptr;
+       void *ptr = NULL;
        int bitmap_size = BITS_TO_LONGS(nr_pages) * sizeof(long);
 
        bitmap = kzalloc(bitmap_size, GFP_KERNEL);
@@ -393,7 +393,7 @@ static int __init atomic_pool_init(void)
        if (IS_ENABLED(CONFIG_DMA_CMA))
                ptr = __alloc_from_contiguous(NULL, pool->size, prot, &page,
                                              atomic_pool_init);
-       else
+       if (!ptr)
                ptr = __alloc_remap_buffer(NULL, pool->size, gfp, prot, &page,
                                           atomic_pool_init);
        if (ptr) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
