Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 57138900016
	for <linux-mm@kvack.org>; Wed,  3 Jun 2015 01:08:49 -0400 (EDT)
Received: by pdjm12 with SMTP id m12so65622450pdj.3
        for <linux-mm@kvack.org>; Tue, 02 Jun 2015 22:08:49 -0700 (PDT)
Received: from mail-pd0-x22f.google.com (mail-pd0-x22f.google.com. [2607:f8b0:400e:c02::22f])
        by mx.google.com with ESMTPS id b12si29748871pdl.238.2015.06.02.22.08.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Jun 2015 22:08:48 -0700 (PDT)
Received: by pdbqa5 with SMTP id qa5so148575152pdb.0
        for <linux-mm@kvack.org>; Tue, 02 Jun 2015 22:08:48 -0700 (PDT)
Date: Wed, 3 Jun 2015 14:09:10 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [RFC][PATCH 00/10] zsmalloc auto-compaction
Message-ID: <20150603050910.GA534@swordfish>
References: <1432911928-14654-1-git-send-email-sergey.senozhatsky@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1432911928-14654-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On (05/30/15 00:05), Sergey Senozhatsky wrote:
> RFC
> 
> this is 4.3 material, but I wanted to publish it sooner to gain
> responses and to settle it down before 4.3 merge window opens.
> 
> in short, this series tweaks zsmalloc's compaction and adds
> auto-compaction support. auto-compaction is not aimed to replace
> manual compaction, intead it's supposed to be good enough. yet
> it surely slows down zsmalloc in some scenarious. whilst simple
> un-tar test didn't show any significant performance difference
> 
> 
> quote from commit 0007:
> 
> this test copies a 1.3G linux kernel tar to mounted zram disk,
> and extracts it.
> 

[..]


Hello,

I've a v2:
-- squashed and re-order some of the patches;
-- run iozone with lockdep disabled.

=== quote ===

    auto-compaction should not affect read-only tests, so we are interested
    in write-only and read-write (mixed) tests, but I'll post complete test
    stats:
    
    iozone -t 3 -R -r 16K -s 60M -I +Z
    ext4, 2g zram0 device, lzo, 4 compression streams max
    
           test           base       auto-compact (compacted 67904 objs)
       Initial write   2474943.62          2490551.69
             Rewrite   3656121.38          3002796.31
                Read   12068187.50         12044105.25
             Re-read   12009777.25         11930537.50
        Reverse Read   10858884.25         10388252.50
         Stride read   10715304.75         10429308.00
         Random read   10597970.50         10502978.75
      Mixed workload   8517269.00          8701298.12
        Random write   3595597.00          3465174.38
              Pwrite   2507361.25          2553224.50
               Pread   5380608.28          5340646.03
              Fwrite   6123863.62          6130514.25
               Fread   12006438.50         11936981.25
    
    mm_stat after the test
    
    base:
    cat /sys/block/zram0/mm_stat
    378834944  5748695  7446528        0  7450624    16318        0
    
    auto-compaction:
    cat /sys/block/zram0/mm_stat
    378892288  5754987  7397376        0  7397376    16304    67904

===

	-ss

> 
> 
> Sergey Senozhatsky (10):
>   zsmalloc: drop unused variable `nr_to_migrate'
>   zsmalloc: always keep per-class stats
>   zsmalloc: introduce zs_can_compact() function
>   zsmalloc: cosmetic compaction code adjustments
>   zsmalloc: add `num_migrated' to zs_pool
>   zsmalloc: move compaction functions
>   zsmalloc: introduce auto-compact support
>   zsmalloc: export zs_pool `num_migrated'
>   zram: remove `num_migrated' from zram_stats
>   zsmalloc: lower ZS_ALMOST_FULL waterline
> 
>  drivers/block/zram/zram_drv.c |  12 +-
>  drivers/block/zram/zram_drv.h |   1 -
>  include/linux/zsmalloc.h      |   1 +
>  mm/zsmalloc.c                 | 578 +++++++++++++++++++++---------------------
>  4 files changed, 296 insertions(+), 296 deletions(-)
> 
> -- 
> 2.4.2.337.gfae46aa
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
