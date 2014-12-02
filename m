Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id ADFA46B006C
	for <linux-mm@kvack.org>; Mon,  1 Dec 2014 21:50:12 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id bj1so12421448pad.37
        for <linux-mm@kvack.org>; Mon, 01 Dec 2014 18:50:12 -0800 (PST)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id ol9si31602237pdb.124.2014.12.01.18.50.08
        for <linux-mm@kvack.org>;
        Mon, 01 Dec 2014 18:50:10 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [RFC 0/6] zsmalloc support compaction
Date: Tue,  2 Dec 2014 11:49:41 +0900
Message-Id: <1417488587-28609-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nitin Gupta <ngupta@vflare.org>, Dan Streetman <ddstreet@ieee.org>, Seth Jennings <sjennings@variantweb.net>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Luigi Semenzato <semenzato@google.com>, Jerome Marchand <jmarchan@redhat.com>, juno.choi@lge.com, seungho1.park@lge.com, Minchan Kim <minchan@kernel.org>

Recently, there was issue about zsmalloc fragmentation and
I got a report from Juno that new fork failed although there
are plenty of free pages in the system.
His investigation revealed zram is one of the culprit to make
heavy fragmentation so there was no more contiguous 16K page
for pgd to fork in the ARM.

This patchset implement *basic* zsmalloc compaction support
and zram utilizes it so admin can do
	"echo 1 > /sys/block/zram0/compact"

Actually, ideal is that mm migrate code is aware of zram pages and
migrate them out automatically without admin's manual opeartion
when system is out of contiguous page. Howver, we need more thinking
before adding more hooks to migrate.c. Even though we implement it,
we need manual trigger mode, too so I hope we could enhance
zram migration stuff based on this primitive functions in future.

I just tested it on only x86 so need more testing on other arches.
Additionally, I should have a number for zsmalloc regression
caused by indirect layering. Unfortunately, I don't have any
ARM test machine on my desk. I will get it soon and test it.
Anyway, before further work, I'd like to hear opinion.

Pathset is based on v3.18-rc6-mmotm-2014-11-26-15-45.

Thanks.

Minchan Kim (6):
  zsmalloc: expand size class to support sizeof(unsigned long)
  zsmalloc: add indrection layer to decouple handle from object
  zsmalloc: implement reverse mapping
  zsmalloc: encode alloced mark in handle object
  zsmalloc: support compaction
  zram: support compaction

 drivers/block/zram/zram_drv.c |  24 ++
 drivers/block/zram/zram_drv.h |   1 +
 include/linux/zsmalloc.h      |   1 +
 mm/zsmalloc.c                 | 596 +++++++++++++++++++++++++++++++++++++-----
 4 files changed, 552 insertions(+), 70 deletions(-)

-- 
2.0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
