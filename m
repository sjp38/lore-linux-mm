Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id D772D6B0035
	for <linux-mm@kvack.org>; Tue,  5 Aug 2014 04:01:38 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id z10so902970pdj.2
        for <linux-mm@kvack.org>; Tue, 05 Aug 2014 01:01:38 -0700 (PDT)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id id5si1061170pbc.69.2014.08.05.01.01.36
        for <linux-mm@kvack.org>;
        Tue, 05 Aug 2014 01:01:37 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [RFC 0/3] zram memory control enhance
Date: Tue,  5 Aug 2014 17:02:00 +0900
Message-Id: <1407225723-23754-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Jerome Marchand <jmarchan@redhat.com>, juno.choi@lge.com, seungho1.park@lge.com, Luigi Semenzato <semenzato@google.com>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>

Notice! It's RFC. I didn't test at all but wanted to hear opinion
during merge window when it's really busy time for Andrew so we could
use the slack time to discuss without hurting him. ;-)

Patch 1 is to move pages_allocated in zsmalloc from size_class to zs_pool
so zs_get_total_size_bytes of zsmalloc would be faster than old.
zs_get_total_size_bytes could be used next patches frequently.

Patch 2 adds new feature which exports how many of bytes zsmalloc consumes
during testing workload. Normally, before fixing the zram's disksize
we have tested various workload and wanted to how many of bytes zram
consumed.
For it, we could poll mem_used_total of zram in userspace but the problem is
when memory pressure is severe and heavy swap out happens suddenly then
heavy swapin or exist while polling interval of user space is a few second,
it could miss max memory size zram had consumed easily.
With lack of information, user can set wrong disksize of zram so the result
is OOM. So this patch adds max_mem_used for zram and zsmalloc supports it

Patch 3 is to limit zram memory consumption. Now, zram has no bound for
memory usage so it could consume up all of system memory. It makes system
memory control for platform hard so I have heard the feature several time.

Feedback is welcome!

Minchan Kim (3):
  zsmalloc: move pages_allocated to zs_pool
  zsmalloc/zram: add zs_get_max_size_bytes and use it in zram
  zram: limit memory size for zram

 Documentation/blockdev/zram.txt |  2 ++
 drivers/block/zram/zram_drv.c   | 58 +++++++++++++++++++++++++++++++++++++++++
 drivers/block/zram/zram_drv.h   |  1 +
 include/linux/zsmalloc.h        |  1 +
 mm/zsmalloc.c                   | 50 +++++++++++++++++++++++++----------
 5 files changed, 98 insertions(+), 14 deletions(-)

-- 
2.0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
