Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 90AF96B0253
	for <linux-mm@kvack.org>; Fri, 25 Sep 2015 04:04:39 -0400 (EDT)
Received: by pablk4 with SMTP id lk4so2335028pab.3
        for <linux-mm@kvack.org>; Fri, 25 Sep 2015 01:04:39 -0700 (PDT)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id qx10si3801809pab.241.2015.09.25.01.04.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Sep 2015 01:04:38 -0700 (PDT)
Received: by pacex6 with SMTP id ex6so99083818pac.0
        for <linux-mm@kvack.org>; Fri, 25 Sep 2015 01:04:38 -0700 (PDT)
Date: Fri, 25 Sep 2015 17:05:25 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v2] zbud: allow up to PAGE_SIZE allocations
Message-ID: <20150925080525.GE865@swordfish>
References: <20150922141733.d7d97f59f207d0655c3b881d@gmail.com>
 <20150923031845.GA31207@cerebellum.local.variantweb.net>
 <CAMJBoFOEYv05FZqDER9hw79re4vrc3wKwGeuL=uoGbCnwodH8Q@mail.gmail.com>
 <20150923215726.GA17171@cerebellum.local.variantweb.net>
 <20150925021325.GA16431@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150925021325.GA16431@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Seth Jennings <sjennings@variantweb.net>, Vitaly Wool <vitalywool@gmail.com>, Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On (09/25/15 11:13), Minchan Kim wrote:
> > Ok, I can see that having the allocator backends for zpool 
> > have the same set of constraints is nice.
> 
> Sorry for delay. I'm on vacation until next week.
> It seems Seth was missed in previous discusstion which was not the end.
> 
> I already said questions, opinion and concerns but anything is not clear
> until now. Only clear thing I could hear is just "compaction stats are
> better" which is not enough for me. Sorry.

Agree.

There weren't lots of answers, really.

Vitaly,

Have you seen those symptoms before? How did you come up to a conclusion
that zram->zbud will do the trick?

If those symptoms are some sort of a recent addition, then does it help
when you disable zsmalloc compaction?

---

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index f59e8eb..b6c6a19 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -1944,8 +1944,8 @@ struct zs_pool *zs_create_pool(const char *name, gfp_t flags)
         * Not critical, we still can use the pool
         * and user can trigger compaction manually.
         */
-       if (zs_register_shrinker(pool) == 0)
-               pool->shrinker_enabled = true;
+/*     if (zs_register_shrinker(pool) == 0)
+               pool->shrinker_enabled = true;*/
        return pool;
 
 err:

---


p.s. I'll be on vacation next week, so most likely will be quite slow
to answer.

	-ss

> 
> 1) https://lkml.org/lkml/2015/9/15/33
> 2) https://lkml.org/lkml/2015/9/21/2
> 
> Vitally, Please say what's the root cause of your problem and if it
> is external fragmentation, what's the problem of my approach?
> 
> 1) make non-LRU page migrate
> 2) provide zsmalloc's migratpage
> 
> We should provide it for CMA as well as external fragmentation.
> I think we could solve your issue with above approach and
> it fundamentally makes zsmalloc/zbud happy in future.
> 
> Also, please keep it in mind that zram has been in linux kernel for
> memory efficiency for a long time and later zswap/zbud was born
> for *determinism* at the cost of memory efficiency.
> 
> Thanks.
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
