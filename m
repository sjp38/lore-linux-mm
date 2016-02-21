Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id ACA546B0005
	for <linux-mm@kvack.org>; Sun, 21 Feb 2016 08:29:57 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id fl4so76276853pad.0
        for <linux-mm@kvack.org>; Sun, 21 Feb 2016 05:29:57 -0800 (PST)
Received: from mail-pf0-x232.google.com (mail-pf0-x232.google.com. [2607:f8b0:400e:c00::232])
        by mx.google.com with ESMTPS id w12si32205186pfa.177.2016.02.21.05.29.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 Feb 2016 05:29:56 -0800 (PST)
Received: by mail-pf0-x232.google.com with SMTP id c10so80073339pfc.2
        for <linux-mm@kvack.org>; Sun, 21 Feb 2016 05:29:56 -0800 (PST)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [RFC][PATCH v2 0/3] mm/zsmalloc: increase objects density and reduce memory wastage
Date: Sun, 21 Feb 2016 22:27:51 +0900
Message-Id: <1456061274-20059-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Hello,

	RFC

huge classes are evil. zsmalloc knows the watermark after which classes
are considered to be ->huge - every object stored consumes the entire zspage
(which consist of a single order-0 page). zram, however, has its own statically
defined watermark for `bad' compression and stores every object larger than
this watermark as a PAGE_SIZE, object, IOW, to a ->huge class, this results
in increased memory consumption and memory wastage. And zram's 'bad' watermark
is much lower than zsmalloc's one. Apart from that, 'bad' compressions are not
so rare, on some of my tests 41% of writes are 'bad' compressions.

This patch set inverts this 'huge class watermark' enforcement, it's zsmalloc
that knows better, not zram. It also reduces the number of huge classes, this
saves some memory. Since we request less pages for object larger than 3072
bytes, zmalloc in some cases should behave nicer when the system is getting
low on free pages.


Object's location is encoded as
	<PFN, OBJ_INDEX_BITS | OBJ_ALLOCATED_TAG | HANDLE_PIN_BIT>

so mostly we have enough bits in OBJ_INDEX_BITS to increase ZS_MAX_ZSPAGE_ORDER
and keep all of the classes. This is not true, however, on PAE/LPAE and PAGE_SHIFT
16 systems, so we need to preserve the exiting ZS_MAX_ZSPAGE_ORDER 2 limit
there.

Please commit 0003 for some numbers.

Thanks to Joonsoo Kim for valuable questions and opinions.

v2:
-- keep ZS_MAX_PAGES_PER_ZSPAGE order of two (Joonsoo)
-- suffice ZS_MIN_ALLOC_SIZE alignment requirement
-- do not change ZS_MAX_PAGES_PER_ZSPAGE on PAE/LPAE and
   on PAGE_SHIFT 16 systems (Joonsoo)

Sergey Senozhatsky (3):
  mm/zsmalloc: introduce zs_get_huge_class_size_watermark()
  zram: use zs_get_huge_class_size_watermark()
  mm/zsmalloc: increase ZS_MAX_PAGES_PER_ZSPAGE

 drivers/block/zram/zram_drv.c |  2 +-
 drivers/block/zram/zram_drv.h |  6 ------
 include/linux/zsmalloc.h      |  2 ++
 mm/zsmalloc.c                 | 43 ++++++++++++++++++++++++++++++++++++-------
 4 files changed, 39 insertions(+), 14 deletions(-)

-- 
2.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
