Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f178.google.com (mail-ob0-f178.google.com [209.85.214.178])
	by kanga.kvack.org (Postfix) with ESMTP id A3B926B0254
	for <linux-mm@kvack.org>; Thu, 18 Feb 2016 03:28:58 -0500 (EST)
Received: by mail-ob0-f178.google.com with SMTP id wb13so56127789obb.1
        for <linux-mm@kvack.org>; Thu, 18 Feb 2016 00:28:58 -0800 (PST)
Received: from mail-ob0-x231.google.com (mail-ob0-x231.google.com. [2607:f8b0:4003:c01::231])
        by mx.google.com with ESMTPS id t83si7716086oig.81.2016.02.18.00.28.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Feb 2016 00:28:57 -0800 (PST)
Received: by mail-ob0-x231.google.com with SMTP id wb13so56127503obb.1
        for <linux-mm@kvack.org>; Thu, 18 Feb 2016 00:28:57 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1455764556-13979-4-git-send-email-sergey.senozhatsky@gmail.com>
References: <1455764556-13979-1-git-send-email-sergey.senozhatsky@gmail.com>
	<1455764556-13979-4-git-send-email-sergey.senozhatsky@gmail.com>
Date: Thu, 18 Feb 2016 17:28:57 +0900
Message-ID: <CAAmzW4O-yQ5GBTE-6WvCL-hZeqyW=k3Fzn4_9G2qkMmp=ceuJg@mail.gmail.com>
Subject: Re: [RFC PATCH 3/3] mm/zsmalloc: change ZS_MAX_PAGES_PER_ZSPAGE
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Hello,

2016-02-18 12:02 GMT+09:00 Sergey Senozhatsky
<sergey.senozhatsky.work@gmail.com>:
> ZS_MAX_PAGES_PER_ZSPAGE does not have to be order or 2. The existing
> limit of 4 pages per zspage sets a tight limit on ->huge classes, which
> results in increased memory wastage and consumption.

There is a reason that it is order of 2. Increasing ZS_MAX_PAGES_PER_ZSPAGE
is related to ZS_MIN_ALLOC_SIZE. If we don't have enough OBJ_INDEX_BITS,
ZS_MIN_ALLOC_SIZE would be increase and it causes regression on some
system. Using one more bit on OBJ_INDEX_BITS means that we can increase
ZS_MAX_PAGES_PER_ZSPAGE to double times. AFAIK, there is no bit left
so you need to steal one from somewhere to increase
ZS_MAX_PAGES_PER_ZSPAGE.

> For example, on x86_64, PAGE_SHIFT 12, ->huge class_size range is
>
> ZS_MAX_PAGES_PER_ZSPAGE         ->huge classes size range
> 4                                       3280-4096
> 5                                       3424-4096
> 6                                       3520-4096
>
> With bigger ZS_MAX_PAGES_PER_ZSPAGE we have less ->huge classes, because
> some of the previously known as ->huge classes now have better chances to
> form zspages that will waste less memory. This increases the density and
> improves memory efficiency.
>
> Example,
>
> class_size 3328 with ZS_MAX_PAGES_PER_ZSPAGE=5 has pages_per_zspage 5
> and max_objects 6, while with ZS_MAX_PAGES_PER_ZSPAGE=1 it had
> pages_per_zspage 1 and max_objects 1. So now every 6th 3328-bytes object
> stored by zram will not consume a new zspage (and order-0 page), but will
> share an already allocated one.
>
> TEST
> ====
>
> Create a text file and do rounds of dd (one process). The amount of
> copied data, its content and order are stable.
>
> test script:
>
> rm /tmp/test-file
> for i in {1..200}; do
>         cat /media/dev/linux-mmots/mm/zsmalloc.c >> /tmp/test-file;
> done
>
> for i in {1..5}; do
>         umount /zram
>         rmmod zram
>
>         # create a 4G zram device, LZ0, multi stream, ext4 fs
>         ./create-zram 4g
>
>         for k in {1..3}; do
>                 j=1;
>                 while [ $j -lt $((1024*1024)) ]; do
>                         dd if=/tmp/test-file of=/zram/file-$k-$j bs=$j count=1 \
>                                 oflag=sync > /dev/null 2>&1
>                         let j=$j+512
>                 done
>         done
>
>         sync
>         cat /sys/block/zram0/mm_stat >> /tmp/zram-stat
>         umount /zram
>         rmmod zram
> done
>
> RESULTS
> =======
> cat /sys/block/zram0/mm_stat column 3 is zs_get_total_pages() << PAGE_SHIFT
>
> BASE
> 3371106304 1714719722 1842778112        0 1842778112       16        0        1
> 3371098112 1714667024 1842831360        0 1842831360       16        0        1
> 3371110400 1714767329 1842716672        0 1842716672       16        0        1
> 3371110400 1714717615 1842601984        0 1842601984       16        0        1
> 3371106304 1714744207 1842135040        0 1842135040       16        0        1
>
> ZS_MAX_PAGES_PER_ZSPAGE=5
> 3371094016 1714584459 1804095488        0 1804095488       16        0        1
> 3371102208 1714619140 1804660736        0 1804660736       16        0        1
> 3371114496 1714755452 1804316672        0 1804316672       16        0        1
> 3371081728 1714606179 1804800000        0 1804800000       16        0        1
> 3371122688 1714871507 1804361728        0 1804361728       16        0        1
>
> ZS_MAX_PAGES_PER_ZSPAGE=6
> 3371114496 1714704275 1789206528        0 1789206528       16        0        1
> 3371102208 1714740225 1789259776        0 1789259776       16        0        1
> 3371102208 1714717465 1789071360        0 1789071360       16        0        1
> 3371110400 1714704079 1789194240        0 1789194240       16        0        1
> 3371085824 1714792954 1789308928        0 1789308928       16        0        1
>
> So that's
>  around 36MB of saved space between BASE and ZS_MAX_PAGES_PER_ZSPAGE=5
> and
>  around 51MB of saved space between BASE and ZS_MAX_PAGES_PER_ZSPAGE=6.

Looks nice.

> Set ZS_MAX_PAGES_PER_ZSPAGE to 6 for now.

Why not just set it to 8? It could save more because some classes can fit
better to 8 pages zspage.

I have a concern that increasing ZS_MAX_PAGES_PER_ZSPAGE would
cause more pressure on memory at some moment because it requires
more pages to compress and store just 1 pages. What do you think
about it?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
