Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 748EA6B0069
	for <linux-mm@kvack.org>; Mon, 22 Aug 2016 04:27:50 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id j67so295727686oih.3
        for <linux-mm@kvack.org>; Mon, 22 Aug 2016 01:27:50 -0700 (PDT)
Received: from xiaomi.com (outboundhk.mxmail.xiaomi.com. [207.226.244.122])
        by mx.google.com with ESMTPS id k187si15188439ith.4.2016.08.22.01.27.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 22 Aug 2016 01:27:49 -0700 (PDT)
From: Hui Zhu <zhuhui@xiaomi.com>
Subject: [RFC 0/4] ZRAM: make it just store the high compression rate page
Date: Mon, 22 Aug 2016 16:25:05 +0800
Message-ID: <1471854309-30414-1-git-send-email-zhuhui@xiaomi.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, hughd@google.com, rostedt@goodmis.org, mingo@redhat.com, peterz@infradead.org, acme@kernel.org, alexander.shishkin@linux.intel.com, akpm@linux-foundation.org, mhocko@suse.com, hannes@cmpxchg.org, mgorman@techsingularity.net, vbabka@suse.cz, zhuhui@xiaomi.com, redkoi@virtuozzo.com, luto@kernel.org, kirill.shutemov@linux.intel.com, geliangtang@163.com, baiyaowei@cmss.chinamobile.com, dan.j.williams@intel.com, vdavydov@virtuozzo.com, aarcange@redhat.com, dvlasenk@redhat.com, jmarchan@redhat.com, koct9i@gmail.com, yang.shi@linaro.org, dave.hansen@linux.intel.com, vkuznets@redhat.com, vitalywool@gmail.com, ross.zwisler@linux.intel.com, tglx@linutronix.de, kwapulinski.piotr@gmail.com, axboe@fb.com, mchristi@redhat.com, joe@perches.com, namit@vmware.com, riel@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: teawater@gmail.com

Current ZRAM just can store all pages even if the compression rate
of a page is really low.  So the compression rate of ZRAM is out of
control when it is running.
In my part, I did some test and record with ZRAM.  The compression rate
is about 40%.

This series of patches make ZRAM can just store the page that the
compressed size is smaller than a value.
With these patches, I set the value to 2048 and did the same test with
before.  The compression rate is about 20%.  The times of lowmemorykiller
also decreased.

Hui Zhu (4):
vmscan.c: shrink_page_list: unmap anon pages after pageout
Add non-swap page flag to mark a page will not swap
ZRAM: do not swap the pages that compressed size bigger than non_swap
vmscan.c: zram: add non swap support for shmem file pages

 drivers/block/zram/Kconfig     |   11 +++
 drivers/block/zram/zram_drv.c  |   38 +++++++++++
 drivers/block/zram/zram_drv.h  |    4 +
 fs/proc/meminfo.c              |    6 +
 include/linux/mm_inline.h      |   20 +++++
 include/linux/mmzone.h         |    3 
 include/linux/page-flags.h     |    8 ++
 include/linux/rmap.h           |    5 +
 include/linux/shmem_fs.h       |    6 +
 include/trace/events/mmflags.h |    9 ++
 kernel/events/uprobes.c        |   16 ++++
 mm/Kconfig                     |    9 ++
 mm/memory.c                    |   34 ++++++++++
 mm/migrate.c                   |    4 +
 mm/mprotect.c                  |    8 ++
 mm/page_io.c                   |   11 ++-
 mm/rmap.c                      |   23 ++++++
 mm/shmem.c                     |   77 +++++++++++++++++-----
 mm/vmscan.c                    |  139 +++++++++++++++++++++++++++++++++++------
 19 files changed, 387 insertions(+), 44 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
