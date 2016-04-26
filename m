Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id C1D7B6B0005
	for <linux-mm@kvack.org>; Mon, 25 Apr 2016 20:57:48 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id dx6so296166208pad.0
        for <linux-mm@kvack.org>; Mon, 25 Apr 2016 17:57:48 -0700 (PDT)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com. [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id n3si1086027pfb.123.2016.04.25.17.57.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Apr 2016 17:57:48 -0700 (PDT)
Received: by mail-pa0-x22e.google.com with SMTP id iv1so21885285pac.2
        for <linux-mm@kvack.org>; Mon, 25 Apr 2016 17:57:48 -0700 (PDT)
Date: Tue, 26 Apr 2016 09:59:19 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] mm/zpool: use workqueue for zpool_destroy
Message-ID: <20160426005919.GA9699@swordfish>
References: <CALZtONCDqBjL9TFmUEwuHaNU3n55k0VwbYWqW-9dODuNWyzkLQ@mail.gmail.com>
 <1461619210-10057-1-git-send-email-ddstreet@ieee.org>
 <20160425221816.GA1254@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160425221816.GA1254@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu Zhao <yuzhao@google.com>
Cc: Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>, Seth Jennings <sjenning@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Linux-MM <linux-mm@kvack.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel <linux-kernel@vger.kernel.org>, Dan Streetman <dan.streetman@canonical.com>

On (04/25/16 15:18), Yu Zhao wrote:
> On Mon, Apr 25, 2016 at 05:20:10PM -0400, Dan Streetman wrote:
> > Add a work_struct to struct zpool, and change zpool_destroy_pool to
> > defer calling the pool implementation destroy.
> > 
> > The zsmalloc pool destroy function, which is one of the zpool
> > implementations, may sleep during destruction of the pool.  However
> > zswap, which uses zpool, may call zpool_destroy_pool from atomic
> > context.  So we need to defer the call to the zpool implementation
> > to destroy the pool.
> > 
> > This is essentially the same as Yu Zhao's proposed patch to zsmalloc,
> > but moved to zpool.
> 
> Thanks, Dan. Sergey also mentioned another call path that triggers the
> same problem (BUG: scheduling while atomic):
>   rcu_process_callbacks()
>           __zswap_pool_release()
>                   zswap_pool_destroy()
>                           zswap_cpu_comp_destroy()
>                                   cpu_notifier_register_begin()
>                                           mutex_lock(&cpu_add_remove_lock);
> So I was thinking zswap_pool_destroy() might be done in workqueue in zswap.c.
> This way we fix both call paths.

right, I'm not sure the patch addressed all of the issues.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
