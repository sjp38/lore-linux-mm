Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 1E0C76B0035
	for <linux-mm@kvack.org>; Sun, 20 Apr 2014 22:47:26 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id rd3so3240990pab.25
        for <linux-mm@kvack.org>; Sun, 20 Apr 2014 19:47:25 -0700 (PDT)
Received: from mailout2.samsung.com (mailout2.samsung.com. [203.254.224.25])
        by mx.google.com with ESMTPS id wh4si20020676pbc.133.2014.04.20.19.47.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Sun, 20 Apr 2014 19:47:23 -0700 (PDT)
Received: from epcpsbgm2.samsung.com (epcpsbgm2 [203.254.230.27])
 by mailout2.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0N4D005BN12WSP80@mailout2.samsung.com> for
 linux-mm@kvack.org; Mon, 21 Apr 2014 11:47:20 +0900 (KST)
From: Weijie Yang <weijie.yang@samsung.com>
References: <1397922764-1512-1-git-send-email-ddstreet@ieee.org>
In-reply-to: <1397922764-1512-1-git-send-email-ddstreet@ieee.org>
Subject: RE: [PATCH 0/4] mm: zpool: add common api for zswap to use
 zbud/zsmalloc
Date: Mon, 21 Apr 2014 10:47:16 +0800
Message-id: <000001cf5d0c$03f348e0$0bd9daa0$%yang@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=gb2312
Content-transfer-encoding: 7bit
Content-language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Dan Streetman' <ddstreet@ieee.org>, 'Seth Jennings' <sjennings@variantweb.net>, 'Minchan Kim' <minchan@kernel.org>, 'Nitin Gupta' <ngupta@vflare.org>
Cc: 'Andrew Morton' <akpm@linux-foundation.org>, 'Bob Liu' <bob.liu@oracle.com>, 'Hugh Dickins' <hughd@google.com>, 'Mel Gorman' <mgorman@suse.de>, 'Rik van Riel' <riel@redhat.com>, 'Johannes Weiner' <hannes@cmpxchg.org>, 'Sergey Senozhatsky' <sergey.senozhatsky@gmail.com>, 'Linux-MM' <linux-mm@kvack.org>, 'linux-kernel' <linux-kernel@vger.kernel.org>



On Sat, Apr 19, 2014 at 11:52 PM, Dan Streetman <ddstreet@ieee.org> wrote:
> In order to allow zswap users to choose between zbud and zsmalloc for
> the compressed storage pool, this patch set adds a new api "zpool" that
> provides an interface to both zbud and zsmalloc.  Only a minor change
> to zbud's interface was needed, as detailed in the first patch;
> zsmalloc required shrinking to be added and a minor interface change,
> as detailed in the second patch.
> 
> I believe Seth originally was using zsmalloc for swap, but there were
> concerns about how significant the impact of shrinking zsmalloc would
> be when zswap had to start reclaiming pages.  That still may be an
> issue, but this at least allows users to choose themselves whether
> they want a lower-density or higher-density compressed storage medium.
> At least for situations where zswap reclaim is never or rarely reached,
> it probably makes sense to use the higher density of zsmalloc.
> 
> Note this patch series does not change zram to use zpool, although that
> change should be possible as well.

I think this idea is acceptable, because for embedded devices reclaiming is
risky due to its write lifetime. By using zsmalloc, zswap user can not only take
the benefit of higher-density compressed storage but aslo supporting the
GFP_HIGHMEM in 32bit system.

I will pay attention to this patch set and give my opinion after my review.

Thanks for your work

> 
> Dan Streetman (4):
>   mm: zpool: zbud_alloc() minor param change
>   mm: zpool: implement zsmalloc shrinking
>   mm: zpool: implement common zpool api to zbud/zsmalloc
>   mm: zpool: update zswap to use zpool
> 
>  drivers/block/zram/zram_drv.c |   2 +-
>  include/linux/zbud.h          |   3 +-
>  include/linux/zpool.h         | 166 ++++++++++++++++++
>  include/linux/zsmalloc.h      |   7 +-
>  mm/Kconfig                    |  43 +++--
>  mm/Makefile                   |   1 +
>  mm/zbud.c                     |  28 ++--
>  mm/zpool.c                    | 380 ++++++++++++++++++++++++++++++++++++++++++
>  mm/zsmalloc.c                 | 168 +++++++++++++++++--
>  mm/zswap.c                    |  70 ++++----
>  10 files changed, 787 insertions(+), 81 deletions(-)
>  create mode 100644 include/linux/zpool.h
>  create mode 100644 mm/zpool.c
> 
> --
> 1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
