Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id ED45A6B0253
	for <linux-mm@kvack.org>; Mon, 13 Jul 2015 19:36:12 -0400 (EDT)
Received: by padck2 with SMTP id ck2so50234817pad.0
        for <linux-mm@kvack.org>; Mon, 13 Jul 2015 16:36:12 -0700 (PDT)
Received: from mail-pa0-x230.google.com (mail-pa0-x230.google.com. [2607:f8b0:400e:c03::230])
        by mx.google.com with ESMTPS id hy8si30687945pab.227.2015.07.13.16.36.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Jul 2015 16:36:12 -0700 (PDT)
Received: by pacan13 with SMTP id an13so23452207pac.1
        for <linux-mm@kvack.org>; Mon, 13 Jul 2015 16:36:11 -0700 (PDT)
Date: Tue, 14 Jul 2015 08:36:02 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 0/3] zsmalloc: small compaction improvements
Message-ID: <20150713233602.GA31822@blaptop.AC68U>
References: <1436607932-7116-1-git-send-email-sergey.senozhatsky@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1436607932-7116-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

Hello Sergey,

On Sat, Jul 11, 2015 at 06:45:29PM +0900, Sergey Senozhatsky wrote:
> Hello,
> 
> First two patches introduce new zsmalloc zs_pages_to_compact()
> symbol and change zram's `compact' sysfs attribute to be
> read-write:
> -- write triggers compaction, no changes
> -- read returns the number of pages that compaction can
>    potentially free
> 
> This lets user space to make a bit better decisions and to
> avoid unneeded (which will not result in any significant
> memory savings) compaction calls:
> 
> Example:
> 
>       if [ `cat /sys/block/zram<id>/compact` -gt 10 ]; then
>           echo 1 > /sys/block/zram<id>/compact;
>       fi
> 
> Up until now user space could not tell whether compaction
> will result in any gain.

First of all, thanks for the looking this.

Question:

What is motivation?
IOW, did you see big overhead by user-triggered compaction? so,
do you want to throttle it by userspace?

> 
> The third patch removes class locking around zs_can_compact()
> in zs_pages_to_compact(), the motivation and details are
> provided in the commit message.
> 
> Sergey Senozhatsky (3):
>   zsmalloc: factor out zs_pages_to_compact()
>   zram: make compact a read-write sysfs node
>   zsmalloc: do not take class lock in zs_pages_to_compact()
> 
>  Documentation/ABI/testing/sysfs-block-zram |  7 +++---
>  Documentation/blockdev/zram.txt            |  4 +++-
>  drivers/block/zram/zram_drv.c              | 16 ++++++++++++-
>  include/linux/zsmalloc.h                   |  1 +
>  mm/zsmalloc.c                              | 37 +++++++++++++++++-------------
>  5 files changed, 44 insertions(+), 21 deletions(-)
> 
> -- 
> 2.4.5
> 

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
