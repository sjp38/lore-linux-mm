Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 2696E6B0005
	for <linux-mm@kvack.org>; Wed, 17 Feb 2016 22:01:31 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id fl4so22278098pad.0
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 19:01:31 -0800 (PST)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com. [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id h26si6081138pfh.169.2016.02.17.19.01.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Feb 2016 19:01:30 -0800 (PST)
Received: by mail-pa0-x231.google.com with SMTP id ho8so22797502pac.2
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 19:01:30 -0800 (PST)
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: [RFC PATCH 0/3] mm/zsmalloc: increase density and reduce memory wastage
Date: Thu, 18 Feb 2016 12:02:33 +0900
Message-Id: <1455764556-13979-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Hello,

 RFC

 ->huge classes are evil, and zsmalloc knows the watermark after which classes
are considered to be ->huge -- every object stored consumes the entire zspage
(which consist of a single order-0 page). zram, however, has its own statically
defined watermark for `bad' compression and stores every object larger than
this watermark as a PAGE_SIZE, object, IOW, to a ->huge class, this results
in increased memory consumption and memory wastage. And zram's 'bad' watermark
is much lower than zsmalloc. Apart from that, 'bad' compressions are not so rare,
on some of my tests 41% of writes result in 'bad' compressions.

This patch set inverts this 'huge class watermark' enforcement, it's zsmalloc
that knows better, not zram.

I did a number of tests (see 0003 commit message) and memory savings were around
36MB and 51MB (depending on zsmalloc configuration).

I also copied a linux-next directory (with object files, du -sh  2.5G)
and (ZS_MAX_PAGES_PER_ZSPAGE=5) memory saving were around 17-20MB.



Sergey Senozhatsky (3):
  mm/zsmalloc: introduce zs_get_huge_class_size_watermark()
  zram: use zs_get_huge_class_size_watermark()
  mm/zsmalloc: change ZS_MAX_PAGES_PER_ZSPAGE

 drivers/block/zram/zram_drv.c |  2 +-
 drivers/block/zram/zram_drv.h |  6 ------
 include/linux/zsmalloc.h      |  2 ++
 mm/zsmalloc.c                 | 21 +++++++++++++++++----
 4 files changed, 20 insertions(+), 11 deletions(-)

-- 
2.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
