Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 35D8A6B007E
	for <linux-mm@kvack.org>; Mon, 28 Mar 2016 01:07:06 -0400 (EDT)
Received: by mail-pf0-f175.google.com with SMTP id 4so128730890pfd.0
        for <linux-mm@kvack.org>; Sun, 27 Mar 2016 22:07:06 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id m21si17779220pfi.12.2016.03.27.22.07.04
        for <linux-mm@kvack.org>;
        Sun, 27 Mar 2016 22:07:05 -0700 (PDT)
Date: Mon, 28 Mar 2016 14:08:41 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2 00/18] Support non-lru page migration
Message-ID: <20160328050841.GC31023@bbox>
References: <1458541867-27380-1-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1458541867-27380-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jlayton@poochiereds.net, bfields@fieldses.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, koct9i@gmail.com, aquini@redhat.com, virtualization@lists.linux-foundation.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Rik van Riel <riel@redhat.com>, rknize@motorola.com, Gioh Kim <gi-oh.kim@profitbricks.com>, Sangseok Lee <sangseok.lee@lge.com>, Chan Gyun Jeong <chan.jeong@lge.com>, Al Viro <viro@ZenIV.linux.org.uk>, YiPing Xu <xuyiping@hisilicon.com>

Hello Andrew,

On Mon, Mar 21, 2016 at 03:30:49PM +0900, Minchan Kim wrote:
> Recently, I got many reports about perfermance degradation
> in embedded system(Android mobile phone, webOS TV and so on)
> and failed to fork easily.
> 
> The problem was fragmentation caused by zram and GPU driver
> pages. Their pages cannot be migrated so compaction cannot
> work well, either so reclaimer ends up shrinking all of working
> set pages. It made system very slow and even to fail to fork
> easily.
> 
> Other pain point is that they cannot work with CMA.
> Most of CMA memory space could be idle(ie, it could be used
> for movable pages unless driver is using) but if driver(i.e.,
> zram) cannot migrate his page, that memory space could be
> wasted. In our product which has big CMA memory, it reclaims
> zones too exccessively although there are lots of free space
> in CMA so system was very slow easily.
> 
> To solve these problem, this patch try to add facility to
> migrate non-lru pages via introducing new friend functions
> of migratepage in address_space_operation and new page flags.
> 
> 	(isolate_page, putback_page)
> 	(PG_movable, PG_isolated)
> 
> For details, please read description in
> "mm/compaction: support non-lru movable page migration".
> 
> Originally, Gioh Kim tried to support this feature but he moved
> so I took over the work. But I took many code from his work and
> changed a little bit.
> Thanks, Gioh!
> 
> And I should mention Konstantin Khlebnikov. He really heped Gioh
> at that time so he should deserve to have many credit, too.
> Thanks, Konstantin!
> 
> This patchset consists of five parts
> 
> 1. clean up migration
>   mm: use put_page to free page instead of putback_lru_page
> 
> 2. zsmalloc clean-up for preparing page migration
>   zsmalloc: use first_page rather than page
>   zsmalloc: clean up many BUG_ON
>   zsmalloc: reordering function parameter
>   zsmalloc: remove unused pool param in obj_free
>   zsmalloc: keep max_object in size_class
>   zsmalloc: squeeze inuse into page->mapping
>   zsmalloc: squeeze freelist into page->mapping
>   zsmalloc: move struct zs_meta from mapping to freelist
>   zsmalloc: factor page chain functionality out
>   zsmalloc: separate free_zspage from putback_zspage
>   zsmalloc: zs_compact refactoring

In this series, [2-5] are clean up regardless of goal of the patchset
so it could be merged independently.
I want to reduce patchset size in next post.
If anyone are not against, could you merge cleanup patchset?

   zsmalloc: use first_page rather than page
   zsmalloc: clean up many BUG_ON
   zsmalloc: reordering function parameter
   zsmalloc: remove unused pool param in obj_free

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
