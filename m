Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id B90C56B0253
	for <linux-mm@kvack.org>; Fri, 13 May 2016 02:58:39 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 4so189304713pfw.0
        for <linux-mm@kvack.org>; Thu, 12 May 2016 23:58:39 -0700 (PDT)
Received: from mail-pa0-x243.google.com (mail-pa0-x243.google.com. [2607:f8b0:400e:c03::243])
        by mx.google.com with ESMTPS id r193si22767334pfr.120.2016.05.12.23.58.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 May 2016 23:58:38 -0700 (PDT)
Received: by mail-pa0-x243.google.com with SMTP id i5so7914167pag.3
        for <linux-mm@kvack.org>; Thu, 12 May 2016 23:58:38 -0700 (PDT)
Date: Fri, 13 May 2016 15:58:05 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] zram: introduce per-device debug_stat sysfs node
Message-ID: <20160513065805.GB615@swordfish>
References: <20160511134553.12655-1-sergey.senozhatsky@gmail.com>
 <20160512234143.GA27204@bbox>
 <20160513010929.GA615@swordfish>
 <20160513062303.GA21204@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160513062303.GA21204@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On (05/13/16 15:23), Minchan Kim wrote:
[..]
> @@ -737,12 +737,12 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
>  		zcomp_strm_release(zram->comp, zstrm);
>  		zstrm = NULL;
>  
> -		atomic64_inc(&zram->stats.num_recompress);
> -
>  		handle = zs_malloc(meta->mem_pool, clen,
>  				GFP_NOIO | __GFP_HIGHMEM);
> -		if (handle)
> +		if (handle) {
> +			atomic64_inc(&zram->stats.num_recompress);
>  			goto compress_again;
> +		}

not like a real concern...

the main (and only) purpose of num_recompress is to match performance
slowdowns and failed fast write paths (when the first zs_malloc() fails).
this matching is depending on successful second zs_malloc(), but if it's
also unsuccessful we would only increase failed_writes; w/o increasing
the failed fast write counter, while we actually would have failed fast
write and extra zs_malloc() [unaccounted in this case]. yet it's probably
a bit unlikely to happen, but still. well, just saying.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
