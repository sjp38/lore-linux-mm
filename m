Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 46E6D6B0253
	for <linux-mm@kvack.org>; Sat, 11 Jul 2015 05:46:27 -0400 (EDT)
Received: by pachj5 with SMTP id hj5so5329482pac.3
        for <linux-mm@kvack.org>; Sat, 11 Jul 2015 02:46:27 -0700 (PDT)
Received: from mail-pd0-x22f.google.com (mail-pd0-x22f.google.com. [2607:f8b0:400e:c02::22f])
        by mx.google.com with ESMTPS id sk5si18624082pac.9.2015.07.11.02.46.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 11 Jul 2015 02:46:26 -0700 (PDT)
Received: by pdbqm3 with SMTP id qm3so53196941pdb.0
        for <linux-mm@kvack.org>; Sat, 11 Jul 2015 02:46:26 -0700 (PDT)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [PATCH 0/3] zsmalloc: small compaction improvements
Date: Sat, 11 Jul 2015 18:45:29 +0900
Message-Id: <1436607932-7116-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Hello,

First two patches introduce new zsmalloc zs_pages_to_compact()
symbol and change zram's `compact' sysfs attribute to be
read-write:
-- write triggers compaction, no changes
-- read returns the number of pages that compaction can
   potentially free

This lets user space to make a bit better decisions and to
avoid unneeded (which will not result in any significant
memory savings) compaction calls:

Example:

      if [ `cat /sys/block/zram<id>/compact` -gt 10 ]; then
          echo 1 > /sys/block/zram<id>/compact;
      fi

Up until now user space could not tell whether compaction
will result in any gain.

The third patch removes class locking around zs_can_compact()
in zs_pages_to_compact(), the motivation and details are
provided in the commit message.

Sergey Senozhatsky (3):
  zsmalloc: factor out zs_pages_to_compact()
  zram: make compact a read-write sysfs node
  zsmalloc: do not take class lock in zs_pages_to_compact()

 Documentation/ABI/testing/sysfs-block-zram |  7 +++---
 Documentation/blockdev/zram.txt            |  4 +++-
 drivers/block/zram/zram_drv.c              | 16 ++++++++++++-
 include/linux/zsmalloc.h                   |  1 +
 mm/zsmalloc.c                              | 37 +++++++++++++++++-------------
 5 files changed, 44 insertions(+), 21 deletions(-)

-- 
2.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
