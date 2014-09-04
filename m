Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 771C96B0038
	for <linux-mm@kvack.org>; Wed,  3 Sep 2014 21:38:29 -0400 (EDT)
Received: by mail-pd0-f175.google.com with SMTP id ft15so12308242pdb.20
        for <linux-mm@kvack.org>; Wed, 03 Sep 2014 18:38:29 -0700 (PDT)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id qt3si537289pbc.13.2014.09.03.18.38.26
        for <linux-mm@kvack.org>;
        Wed, 03 Sep 2014 18:38:27 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [RFC 0/3] make vm aware of zram-swap
Date: Thu,  4 Sep 2014 10:39:43 +0900
Message-Id: <1409794786-10951-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Jerome Marchand <jmarchan@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Dan Streetman <ddstreet@ieee.org>, Nitin Gupta <ngupta@vflare.org>, Luigi Semenzato <semenzato@google.com>, Minchan Kim <minchan@kernel.org>

VM uses nr_swap_pages as one of information when it reclaims
anonymous page because nr_swap_pages means how many freeable
space in swap so VM is able to throttle swap out if it found
there is no more space in swap.

But for zram-swap, there is size gap between virtual disksize
and physical memory to be able to store compressed memory so
nr_swap_pages is not correct parameter to throttle swap.

It causes endless anonymous reclaim(ie, swapout) even if there
is no free space in zram-swap so it makes system unresponsive.

This patch adds new hint SWAP_GET_FREE so zram can return how
many of freeable space to VM. With using that, VM can know whether
zram is full and substract remained freeable space from
nr_swap_pages to make it less than 0. IOW, from now on, VM sees
there is no more space of zram so that it will stop anonymous
reclaiming until swap_entry_free free a page which increases
nr_swap_pages again.

With this patch, user will see OOM when zram-swap is full
instead of hang with no response.

Minchan Kim (3):
  zram: generalize swap_slot_free_notify
  mm: add swap_get_free hint for zram
  zram: add swap_get_free hint

 Documentation/filesystems/Locking |  7 ++----
 drivers/block/zram/zram_drv.c     | 36 +++++++++++++++++++++++++--
 include/linux/blkdev.h            |  8 ++++--
 mm/page_io.c                      |  7 +++---
 mm/swapfile.c                     | 52 +++++++++++++++++++++++++++++++++++----
 5 files changed, 93 insertions(+), 17 deletions(-)

-- 
2.0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
