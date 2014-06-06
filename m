Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f173.google.com (mail-ob0-f173.google.com [209.85.214.173])
	by kanga.kvack.org (Postfix) with ESMTP id 7784A6B00A4
	for <linux-mm@kvack.org>; Fri,  6 Jun 2014 17:01:23 -0400 (EDT)
Received: by mail-ob0-f173.google.com with SMTP id wm4so3376548obc.4
        for <linux-mm@kvack.org>; Fri, 06 Jun 2014 14:01:23 -0700 (PDT)
Received: from mail-ob0-x22f.google.com (mail-ob0-x22f.google.com [2607:f8b0:4003:c01::22f])
        by mx.google.com with ESMTPS id ea3si17355866obb.81.2014.06.06.14.01.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 06 Jun 2014 14:01:22 -0700 (PDT)
Received: by mail-ob0-f175.google.com with SMTP id wo20so3401173obc.6
        for <linux-mm@kvack.org>; Fri, 06 Jun 2014 14:01:22 -0700 (PDT)
Date: Fri, 6 Jun 2014 16:01:17 -0500
From: Seth Jennings <sjennings@variantweb.net>
Subject: Re: [PATCHv4 0/6] mm/zpool: add common api for zswap to use
 zbud/zsmalloc
Message-ID: <20140606210117.GA7983@cerebellum.variantweb.net>
References: <1400958369-3588-1-git-send-email-ddstreet@ieee.org>
 <1401747586-11861-1-git-send-email-ddstreet@ieee.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1401747586-11861-1-git-send-email-ddstreet@ieee.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Minchan Kim <minchan@kernel.org>, Weijie Yang <weijie.yang@samsung.com>, Nitin Gupta <ngupta@vflare.org>, Andrew Morton <akpm@linux-foundation.org>, Bob Liu <bob.liu@oracle.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Mon, Jun 02, 2014 at 06:19:40PM -0400, Dan Streetman wrote:
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

This looks good!  Much better than when we first started :) Thanks Dan.
I haven't had a chance to test it out yet so I'm going to wait to Ack it
until then, which might be as late as 6/16 due to a vacation and a
conference.

Thanks,
Seth

> 
> ---
> 
> Changes since v3 : https://lkml.org/lkml/2014/5/24/130
>   -In zpool_shrink() use # pages instead of # bytes
>   -Add reclaimed param to zpool_shrink() to indicate to caller
>    # pages actually reclaimed
>   -move module usage counting to zpool, from zbud/zsmalloc
>   -update zbud_zpool_shrink() to call zbud_reclaim_page() in a
>    loop until requested # pages have been reclaimed (or error)
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
>  include/linux/zpool.h | 224 ++++++++++++++++++++++++++++++++++++++++++++++++++
>  mm/Kconfig            |  43 ++++++----
>  mm/Makefile           |   1 +
>  mm/zbud.c             | 123 +++++++++++++++++++++++----
>  mm/zpool.c            | 206 ++++++++++++++++++++++++++++++++++++++++++++++
>  mm/zsmalloc.c         |  83 +++++++++++++++++++
>  mm/zswap.c            |  76 ++++++++++-------
>  8 files changed, 694 insertions(+), 64 deletions(-)
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
