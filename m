Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f200.google.com (mail-ig0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id 96E7C6B025E
	for <linux-mm@kvack.org>; Fri, 29 Apr 2016 01:37:42 -0400 (EDT)
Received: by mail-ig0-f200.google.com with SMTP id fn8so27741488igb.1
        for <linux-mm@kvack.org>; Thu, 28 Apr 2016 22:37:42 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id e7si2552559igg.93.2016.04.28.22.37.41
        for <linux-mm@kvack.org>;
        Thu, 28 Apr 2016 22:37:41 -0700 (PDT)
Date: Fri, 29 Apr 2016 14:37:40 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm/zsmalloc: don't fail if can't create debugfs info
Message-ID: <20160429053740.GA2431@bbox>
References: <1461857808-11030-1-git-send-email-ddstreet@ieee.org>
 <20160428150709.2eef0506d84cd37ac6b61d12@linux-foundation.org>
 <20160429003824.GC4920@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160429003824.GC4920@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dan Streetman <ddstreet@ieee.org>, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjenning@redhat.com>, Yu Zhao <yuzhao@google.com>, Linux-MM <linux-mm@kvack.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel <linux-kernel@vger.kernel.org>, Dan Streetman <dan.streetman@canonical.com>

On Fri, Apr 29, 2016 at 09:38:24AM +0900, Sergey Senozhatsky wrote:
> On (04/28/16 15:07), Andrew Morton wrote:
> > Needed a bit of tweaking due to
> > http://ozlabs.org/~akpm/mmotm/broken-out/zsmalloc-reordering-function-parameter.patch
> 
> Thanks.
> 
> > From: Dan Streetman <ddstreet@ieee.org>
> > Subject: mm/zsmalloc: don't fail if can't create debugfs info
> > 
> > Change the return type of zs_pool_stat_create() to void, and
> > remove the logic to abort pool creation if the stat debugfs
> > dir/file could not be created.
> > 
> > The debugfs stat file is for debugging/information only, and doesn't
> > affect operation of zsmalloc; there is no reason to abort creating
> > the pool if the stat file can't be created.  This was seen with
> > zswap, which used the same name for all pool creations, which caused
> > zsmalloc to fail to create a second pool for zswap if
> > CONFIG_ZSMALLOC_STAT was enabled.
> 
> no real objections from me. given that both zram and zswap now provide
> unique names for zsmalloc stats dir, this patch does not fix any "real"
> (observed) problem /* ENOMEM in debugfs_create_dir() is a different
> case */.  so it's more of a cosmetic patch.
> 

Logically, I agree with Dan that debugfs is just optional so it
shouldn't affect the module running *but* practically, debugfs_create_dir
failure with no memory would be rare. Rather than it, we would see
error from same entry naming like Dan's case.

If we removes such error propagation logic in case of same naming,
how do zsmalloc user can notice that debugfs entry was not created
although zs_creation was successful returns success?

Otherwise, future user of zsmalloc can miss it easily if they repeates
same mistakes. So, what's the gain with this patch in real practice?


> FWIW,
> Reviewed-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> 
> 	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
