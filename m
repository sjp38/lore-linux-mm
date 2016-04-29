Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id B2A846B0005
	for <linux-mm@kvack.org>; Thu, 28 Apr 2016 20:23:33 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id zy2so145171770pac.1
        for <linux-mm@kvack.org>; Thu, 28 Apr 2016 17:23:33 -0700 (PDT)
Received: from mail-pa0-x234.google.com (mail-pa0-x234.google.com. [2607:f8b0:400e:c03::234])
        by mx.google.com with ESMTPS id o86si12870602pfi.217.2016.04.28.17.23.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Apr 2016 17:23:32 -0700 (PDT)
Received: by mail-pa0-x234.google.com with SMTP id r5so39046660pag.1
        for <linux-mm@kvack.org>; Thu, 28 Apr 2016 17:23:32 -0700 (PDT)
Date: Fri, 29 Apr 2016 09:25:06 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] mm/zswap: use workqueue to destroy pool
Message-ID: <20160429002506.GA4920@swordfish>
References: <1461619210-10057-1-git-send-email-ddstreet@ieee.org>
 <1461704891-15272-1-git-send-email-ddstreet@ieee.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1461704891-15272-1-git-send-email-ddstreet@ieee.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Yu Zhao <yuzhao@google.com>, Andrew Morton <akpm@linux-foundation.org>, Seth Jennings <sjenning@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Linux-MM <linux-mm@kvack.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel <linux-kernel@vger.kernel.org>, Dan Streetman <dan.streetman@canonical.com>

On (04/26/16 17:08), Dan Streetman wrote:
> Add a work_struct to struct zswap_pool, and change __zswap_pool_empty
> to use the workqueue instead of using call_rcu().
> 
> When zswap destroys a pool no longer in use, it uses call_rcu() to
> perform the destruction/freeing.  Since that executes in softirq
> context, it must not sleep.  However, actually destroying the pool
> involves freeing the per-cpu compressors (which requires locking the
> cpu_add_remove_lock mutex) and freeing the zpool, for which the
> implementation may sleep (e.g. zsmalloc calls kmem_cache_destroy,
> which locks the slab_mutex).  So if either mutex is currently taken,
> or any other part of the compressor or zpool implementation sleeps, it
> will result in a BUG().
> 
> It's not easy to reproduce this when changing zswap's params normally.
> In testing with a loaded system, this does not fail:
> 
> $ cd /sys/module/zswap/parameters
> $ echo lz4 > compressor ; echo zsmalloc > zpool
> 
> nor does this:
> 
> $ while true ; do
> > echo lzo > compressor ; echo zbud > zpool
> > sleep 1
> > echo lz4 > compressor ; echo zsmalloc > zpool
> > sleep 1
> > done
> 
> although it's still possible either of those might fail, depending on
> whether anything else besides zswap has locked the mutexes.
> 
> However, changing a parameter with no delay immediately causes the
> schedule while atomic BUG:
> 
> $ while true ; do
> > echo lzo > compressor ; echo lz4 > compressor
> > done
> 
> This is essentially the same as Yu Zhao's proposed patch to zsmalloc,
> but moved to zswap, to cover compressor and zpool freeing.
> 
> Fixes: f1c54846ee45 ("zswap: dynamic pool creation")
> Reported-by: Yu Zhao <yuzhao@google.com>
> Signed-off-by: Dan Streetman <ddstreet@ieee.org>
> Cc: Dan Streetman <dan.streetman@canonical.com>

Reviewed-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
