Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2FF3D6B027C
	for <linux-mm@kvack.org>; Tue, 22 May 2018 07:22:35 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id x23-v6so10972479pfm.7
        for <linux-mm@kvack.org>; Tue, 22 May 2018 04:22:35 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id f9-v6si3768015pgp.224.2018.05.22.04.22.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 22 May 2018 04:22:33 -0700 (PDT)
Date: Tue, 22 May 2018 04:22:30 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [RFC PATCH v2 10/12] mm/zsmalloc: update usage of address zone
 modifiers
Message-ID: <20180522112230.GA5412@bombadil.infradead.org>
References: <1526916033-4877-1-git-send-email-yehs2007@gmail.com>
 <1526916033-4877-11-git-send-email-yehs2007@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1526916033-4877-11-git-send-email-yehs2007@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Huaisheng Ye <yehs2007@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, mhocko@suse.com, vbabka@suse.cz, mgorman@techsingularity.net, kstewart@linuxfoundation.org, alexander.levin@verizon.com, gregkh@linuxfoundation.org, colyli@suse.de, chengnt@lenovo.com, hehy1@lenovo.com, linux-kernel@vger.kernel.org, iommu@lists.linux-foundation.org, xen-devel@lists.xenproject.org, linux-btrfs@vger.kernel.org, Huaisheng Ye <yehs1@lenovo.com>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On Mon, May 21, 2018 at 11:20:31PM +0800, Huaisheng Ye wrote:
> @@ -343,7 +343,7 @@ static void destroy_cache(struct zs_pool *pool)
>  static unsigned long cache_alloc_handle(struct zs_pool *pool, gfp_t gfp)
>  {
>  	return (unsigned long)kmem_cache_alloc(pool->handle_cachep,
> -			gfp & ~(__GFP_HIGHMEM|__GFP_MOVABLE));
> +			gfp & ~__GFP_ZONE_MOVABLE);
>  }

This should be & ~GFP_ZONEMASK

Actually, we should probably have a function to clear those bits rather
than have every driver manipulating the gfp mask like this.  Maybe

#define gfp_normal(gfp)		((gfp) & ~GFP_ZONEMASK)

	return (unsigned long)kmem_cache_alloc(pool->handle_cachep,
-			gfp & ~(__GFP_HIGHMEM|__GFP_MOVABLE));
+			gfp_normal(gfp));
