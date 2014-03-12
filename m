Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 1C62D6B0082
	for <linux-mm@kvack.org>; Wed, 12 Mar 2014 03:06:05 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id kq14so690806pab.9
        for <linux-mm@kvack.org>; Wed, 12 Mar 2014 00:06:04 -0700 (PDT)
Received: from LGEAMRELO02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id u5si1374665pbi.118.2014.03.12.00.06.03
        for <linux-mm@kvack.org>;
        Wed, 12 Mar 2014 00:06:04 -0700 (PDT)
Date: Wed, 12 Mar 2014 16:06:21 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] page owners: correct page->order when to free page
Message-ID: <20140312070621.GI17828@bbox>
References: <1394607486-31493-1-git-send-email-jungsoo.son@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1394607486-31493-1-git-send-email-jungsoo.son@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jungsoo Son <jungsoo.son@lge.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Wed, Mar 12, 2014 at 03:58:06PM +0900, Jungsoo Son wrote:
> When I use PAGE_OWNER in mmotm tree, I found a problem that mismatches
> the number of allocated pages. When I investigate, the problem is that
> set_page_order is called for only a head page if freed page is merged to
> a higher order page in the buddy allocator so tail pages of the higher
> order page couldn't be reset to page->order = -1.
> 
> It means when we do 'cat /proc/page-owner', it could show wrong
> information.

We could make read_page_owner more smart so that it could check
PageBuddy at head page of high order page and skip tail pages but
it needs zone->lock which is already heavy contention lock.
Additionally, it could make wrong information on pcp pages, too.
So, I like this simple approach.

> 
> So page->order should be set to -1 for all the tail pages as well as the
> first page before buddy allocator merges them.
> 
> This patch is for clearing page->order of all the tail pages in
> free_pages_prepare() when to free page.
> 
> Signed-off-by: Jungsoo Son <jungsoo.son@lge.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Acked-by: Minchan Kim <minchan@kernel.org>

Thanks.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
