Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4B2186B007E
	for <linux-mm@kvack.org>; Thu, 12 May 2016 21:07:57 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id zy2so147677432pac.1
        for <linux-mm@kvack.org>; Thu, 12 May 2016 18:07:57 -0700 (PDT)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id az8si20945700pab.242.2016.05.12.18.07.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 May 2016 18:07:56 -0700 (PDT)
Received: by mail-pf0-x241.google.com with SMTP id 145so7924511pfz.1
        for <linux-mm@kvack.org>; Thu, 12 May 2016 18:07:56 -0700 (PDT)
Date: Fri, 13 May 2016 10:09:29 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] zram: introduce per-device debug_stat sysfs node
Message-ID: <20160513010929.GA615@swordfish>
References: <20160511134553.12655-1-sergey.senozhatsky@gmail.com>
 <20160512234143.GA27204@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160512234143.GA27204@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

Hello Minchan,

On (05/13/16 08:41), Minchan Kim wrote:
[..]

will fix and update, thanks!


> > @@ -719,6 +737,8 @@ compress_again:
> >  		zcomp_strm_release(zram->comp, zstrm);
> >  		zstrm = NULL;
> >  
> > +		atomic64_inc(&zram->stats.num_recompress);
> > +
> 
> It should be below "goto compress_again".

I moved it out of goto intentionally. this second zs_malloc()

		handle = zs_malloc(meta->mem_pool, clen,
				GFP_NOIO | __GFP_HIGHMEM |
				__GFP_MOVABLE);

can take some time to complete, which will slow down zram for a bit,
and _theoretically_ this second zs_malloc() still can fail. yes, we
would do the error print out pr_err("Error allocating memory ... ")
and inc the `failed_writes' in zram_bvec_rw(), but zram_bvec_write()
has several more error return paths that can inc the `failed_writes'.
so by just looking at the stats we won't be able to tell that we had
failed fast path allocation combined with failed slow path allocation
(IOW, `goto recompress' never happened).

so I'm thinking about changing its name to num_failed_fast_compress
or num_failed_fast_write, or something similar and thus count the number
of times we fell to "!handle" branch, not the number of goto-s.
what do you think? or do you want it to be num_recompress specifically?

> Other than that,
> 
> Acked-by: Minchan Kim <minchan@kernel.org>
> 

thanks.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
