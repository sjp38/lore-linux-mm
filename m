Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 3A9E06B0035
	for <linux-mm@kvack.org>; Fri, 18 Jul 2014 02:45:45 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id eu11so4823390pac.17
        for <linux-mm@kvack.org>; Thu, 17 Jul 2014 23:45:44 -0700 (PDT)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id rb5si4782102pab.143.2014.07.17.23.45.42
        for <linux-mm@kvack.org>;
        Thu, 17 Jul 2014 23:45:44 -0700 (PDT)
Message-ID: <53C8C290.90503@lge.com>
Date: Fri, 18 Jul 2014 15:45:36 +0900
From: Gioh Kim <gioh.kim@lge.com>
MIME-Version: 1.0
Subject: [PATCH] CMA/HOTPLUG: clear buffer-head lru before page migration
Content-Type: text/plain; charset=EUC-KR
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, =?EUC-KR?B?J7Howdi89ic=?= <iamjoonsoo.kim@lge.com>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>
Cc: Michal Nazarewicz <mina86@mina86.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, =?EUC-KR?B?wMywx8ij?= <gunho.lee@lge.com>, 'Chanho Min' <chanho.min@lge.com>


Hi,

For page migration of CMA, buffer-heads of lru should be dropped.
Please refer to https://lkml.org/lkml/2014/7/4/101 for the history.

I have two solution to drop bhs.
One is invalidating entire lru.
Another is searching the lru and dropping only one bh that Laura proposed
at https://lkml.org/lkml/2012/8/31/313.

I'm not sure which has better performance.
So I did performance test on my cortex-a7 platform with Lmbench
that has "File & VM system latencies" test.
I am attaching the results.
The first line is of invalidating entire lru and the second is dropping selected bh.

File & VM system latencies in microseconds - smaller is better
-------------------------------------------------------------------------------
Host                 OS   0K File      10K File     Mmap    Prot   Page   100fd
                        Create Delete Create Delete Latency Fault  Fault  selct
--------- ------------- ------ ------ ------ ------ ------- ----- ------- -----
10.178.33 Linux 3.10.19   25.1   19.6   32.6   19.7  5098.0 0.666 3.45880 6.506
10.178.33 Linux 3.10.19   24.9   19.5   32.3   19.4  5059.0 0.563 3.46380 6.521


I tried several times but the result tells that they are the same under 1% gap
except Protection Fault.
But the latency of Protection Fault is very small and I think it has little effect.

Therefore we can choose anything but I choose invalidating entire lru.
The try_to_free_buffers() which is calling drop_buffers() is called by many filesystem code.
So I think inserting codes in drop_buffers() can affect the system.
And also we cannot distinguish migration type in drop_buffers().

In alloc_contig_range() we can distinguish migration type and invalidate lru if it needs.
I think alloc_contig_range() is proper to deal with bh like following patch.

Laura, can I have you name on Acked-by line?
Please let me represent my thanks.

Thanks for any feedback.

------------------------------- 8< ----------------------------------
