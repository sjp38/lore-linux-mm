Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f49.google.com (mail-la0-f49.google.com [209.85.215.49])
	by kanga.kvack.org (Postfix) with ESMTP id EB0FC6B0038
	for <linux-mm@kvack.org>; Thu, 17 Sep 2015 02:21:55 -0400 (EDT)
Received: by lamp12 with SMTP id p12so4821698lam.0
        for <linux-mm@kvack.org>; Wed, 16 Sep 2015 23:21:55 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z5si1898884wiy.117.2015.09.16.23.21.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 16 Sep 2015 23:21:54 -0700 (PDT)
Subject: Re: [PATCH 0/3] allow zram to use zbud as underlying allocator
References: <20150914154901.92c5b7b24e15f04d8204de18@gmail.com>
 <55F6D356.5000106@suse.cz>
 <CAMJBoFMD8jj372sXfb5NkT2MBzBUQp232U7XxO9QHKco+mHUYQ@mail.gmail.com>
 <55F6D641.6010209@suse.cz>
 <CALZtONCKCTRP5r0u5iXYHsQ=uxA-B+1M=4=RPGtFiwo4EOpzeg@mail.gmail.com>
 <20150915042216.GE1860@swordfish>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55FA5BFE.6010605@suse.cz>
Date: Thu, 17 Sep 2015 08:21:50 +0200
MIME-Version: 1.0
In-Reply-To: <20150915042216.GE1860@swordfish>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Dan Streetman <ddstreet@ieee.org>
Cc: Vitaly Wool <vitalywool@gmail.com>, Minchan Kim <minchan@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On 09/15/2015 06:22 AM, Sergey Senozhatsky wrote:
> On (09/15/15 00:08), Dan Streetman wrote:
> [..]
>
> correct. a bit of internals: we don't scan all the zspages every
> time. each class has stats for allocated used objects, allocated
> used objects, etc. so we 'compact' only classes that can be
> compacted:
>
>   static unsigned long zs_can_compact(struct size_class *class)
>   {
>           unsigned long obj_wasted;
>
>           obj_wasted = zs_stat_get(class, OBJ_ALLOCATED) -
>                   zs_stat_get(class, OBJ_USED);
>
>           obj_wasted /= get_maxobj_per_zspage(class->size,
>                           class->pages_per_zspage);
>
>           return obj_wasted * class->pages_per_zspage;
>   }
>
> if we can free any zspages (which is at least one page), then we
> attempt to do so.
>
> is compaction the root cause of the symptoms Vitaly observe?

He mentioned the "compact_stalls" counter which in /proc/vmstat is for 
the traditional physical memory compaction, not the zsmalloc-specific 
one. Which would imply high-order allocations. Does zsmalloc try them 
first before falling back to the order-0 zspages linked together manually?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
