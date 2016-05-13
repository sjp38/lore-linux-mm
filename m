Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2D3836B007E
	for <linux-mm@kvack.org>; Fri, 13 May 2016 02:22:33 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id yl2so136285456pac.2
        for <linux-mm@kvack.org>; Thu, 12 May 2016 23:22:33 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id e11si22572846pfb.36.2016.05.12.23.22.31
        for <linux-mm@kvack.org>;
        Thu, 12 May 2016 23:22:32 -0700 (PDT)
Date: Fri, 13 May 2016 15:23:03 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] zram: introduce per-device debug_stat sysfs node
Message-ID: <20160513062303.GA21204@bbox>
References: <20160511134553.12655-1-sergey.senozhatsky@gmail.com>
 <20160512234143.GA27204@bbox>
 <20160513010929.GA615@swordfish>
MIME-Version: 1.0
In-Reply-To: <20160513010929.GA615@swordfish>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, May 13, 2016 at 10:09:29AM +0900, Sergey Senozhatsky wrote:
> Hello Minchan,
> 
> On (05/13/16 08:41), Minchan Kim wrote:
> [..]
> 
> will fix and update, thanks!
> 
> 
> > > @@ -719,6 +737,8 @@ compress_again:
> > >  		zcomp_strm_release(zram->comp, zstrm);
> > >  		zstrm = NULL;
> > >  
> > > +		atomic64_inc(&zram->stats.num_recompress);
> > > +
> > 
> > It should be below "goto compress_again".
> 
> I moved it out of goto intentionally. this second zs_malloc()
> 
> 		handle = zs_malloc(meta->mem_pool, clen,
> 				GFP_NOIO | __GFP_HIGHMEM |
> 				__GFP_MOVABLE);
> 
> can take some time to complete, which will slow down zram for a bit,
> and _theoretically_ this second zs_malloc() still can fail. yes, we
> would do the error print out pr_err("Error allocating memory ... ")
> and inc the `failed_writes' in zram_bvec_rw(), but zram_bvec_write()
> has several more error return paths that can inc the `failed_writes'.
> so by just looking at the stats we won't be able to tell that we had
> failed fast path allocation combined with failed slow path allocation
> (IOW, `goto recompress' never happened).
> 
> so I'm thinking about changing its name to num_failed_fast_compress
> or num_failed_fast_write, or something similar and thus count the number
> of times we fell to "!handle" branch, not the number of goto-s.
> what do you think? or do you want it to be num_recompress specifically?

Sorry, I don't get your point.
What's the problem with below?

        goto compress_again
        so
        atomic_inc(num_recompress)

My concern isn't a performance or something but just want to be more
readable and not error-prone which can increase num_compress although
second zs_malloc could be failed. When I tested with heavy workload,
I saw second zs_malloc can be fail but not frequently so it's not
theoretical issue.

What's the your concern with below?
Sorry if I don't get your point. Please elaborate it more.

diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
index a629bd8d452b..8bdcc4b2b9b8 100644
--- a/drivers/block/zram/zram_drv.c
+++ b/drivers/block/zram/zram_drv.c
@@ -737,12 +737,12 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
 		zcomp_strm_release(zram->comp, zstrm);
 		zstrm = NULL;
 
-		atomic64_inc(&zram->stats.num_recompress);
-
 		handle = zs_malloc(meta->mem_pool, clen,
 				GFP_NOIO | __GFP_HIGHMEM);
-		if (handle)
+		if (handle) {
+			atomic64_inc(&zram->stats.num_recompress);
 			goto compress_again;
+		}
 
 		pr_err("Error allocating memory for compressed page: %u, size=%zu\n",
 			index, clen);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
