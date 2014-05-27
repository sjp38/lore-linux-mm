Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f182.google.com (mail-ob0-f182.google.com [209.85.214.182])
	by kanga.kvack.org (Postfix) with ESMTP id 3F1126B0036
	for <linux-mm@kvack.org>; Tue, 27 May 2014 18:44:15 -0400 (EDT)
Received: by mail-ob0-f182.google.com with SMTP id wn1so9954159obc.13
        for <linux-mm@kvack.org>; Tue, 27 May 2014 15:44:14 -0700 (PDT)
Received: from mail-ob0-x22e.google.com (mail-ob0-x22e.google.com [2607:f8b0:4003:c01::22e])
        by mx.google.com with ESMTPS id d8si27512393obq.49.2014.05.27.15.44.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 27 May 2014 15:44:14 -0700 (PDT)
Received: by mail-ob0-f174.google.com with SMTP id uz6so9963227obc.5
        for <linux-mm@kvack.org>; Tue, 27 May 2014 15:44:14 -0700 (PDT)
Date: Tue, 27 May 2014 17:44:10 -0500
From: Seth Jennings <sjennings@variantweb.net>
Subject: Re: [PATCHv3 0/6] mm/zpool: add common api for zswap to use
 zbud/zsmalloc
Message-ID: <20140527224410.GC25781@cerebellum.variantweb.net>
References: <1399499496-3216-1-git-send-email-ddstreet@ieee.org>
 <1400958369-3588-1-git-send-email-ddstreet@ieee.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1400958369-3588-1-git-send-email-ddstreet@ieee.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Minchan Kim <minchan@kernel.org>, Weijie Yang <weijie.yang@samsung.com>, Nitin Gupta <ngupta@vflare.org>, Andrew Morton <akpm@linux-foundation.org>, Bob Liu <bob.liu@oracle.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Sat, May 24, 2014 at 03:06:03PM -0400, Dan Streetman wrote:
> In order to allow zswap users to choose between zbud and zsmalloc for
> the compressed storage pool, this patch set adds a new api "zpool" that
> provides an interface to both zbud and zsmalloc.  Only minor changes
> to zbud's interface were needed.  This does not include implementing
> shrinking in zsmalloc, which will be sent separately.
> 
> I believe Seth originally was using zsmalloc for swap, but there were
> concerns about how significant the impact of shrinking zsmalloc would
> be when zswap had to start reclaiming pages.  That still may be an
> issue, but this at least allows users to choose themselves whether
> they want a lower-density or higher-density compressed storage medium.
> At least for situations where zswap reclaim is never or rarely reached,
> it probably makes sense to use the higher density of zsmalloc.
> 
> Note this patch set does not change zram to use zpool, although that
> change should be possible as well.

Much cleaner now, thanks Dan :)

A few more comments (see replies to 3/6 and 6/6)

Seth

> 
> ---
> 
> Changes since v2 : https://lkml.org/lkml/2014/5/7/927
>   -Change zpool to use driver registration instead of hardcoding
>    implementations
>   -Add module use counting in zbud/zsmalloc
> 
> Changes since v1 https://lkml.org/lkml/2014/4/19/97
>  -remove zsmalloc shrinking
>  -change zbud size param type from unsigned int to size_t
>  -remove zpool fallback creation
>  -zswap manually falls back to zbud if specified type fails
> 
> 
> Dan Streetman (6):
>   mm/zbud: zbud_alloc() minor param change
>   mm/zbud: change zbud_alloc size type to size_t
>   mm/zpool: implement common zpool api to zbud/zsmalloc
>   mm/zpool: zbud/zsmalloc implement zpool
>   mm/zpool: update zswap to use zpool
>   mm/zpool: prevent zbud/zsmalloc from unloading when used
> 
>  include/linux/zbud.h  |   2 +-
>  include/linux/zpool.h | 214 ++++++++++++++++++++++++++++++++++++++++++++++++++
>  mm/Kconfig            |  43 +++++-----
>  mm/Makefile           |   1 +
>  mm/zbud.c             | 113 ++++++++++++++++++++++----
>  mm/zpool.c            | 197 ++++++++++++++++++++++++++++++++++++++++++++++
>  mm/zsmalloc.c         |  86 ++++++++++++++++++++
>  mm/zswap.c            |  76 ++++++++++--------
>  8 files changed, 668 insertions(+), 64 deletions(-)
>  create mode 100644 include/linux/zpool.h
>  create mode 100644 mm/zpool.c
> 
> -- 
> 1.8.3.1
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
