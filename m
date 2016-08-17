Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4D6BC6B0260
	for <linux-mm@kvack.org>; Wed, 17 Aug 2016 01:17:41 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id le9so184320506pab.0
        for <linux-mm@kvack.org>; Tue, 16 Aug 2016 22:17:41 -0700 (PDT)
Received: from mailout3.samsung.com (mailout3.samsung.com. [203.254.224.33])
        by mx.google.com with ESMTPS id p11si35815356pao.78.2016.08.16.22.17.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 16 Aug 2016 22:17:40 -0700 (PDT)
Received: from epcpsbgr1.samsung.com
 (u141.gpu120.samsung.co.kr [203.254.230.141])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7.0.5.31.0
 64bit (built May  5 2014))
 with ESMTP id <0OC100FOTG1ATXB0@mailout3.samsung.com> for linux-mm@kvack.org;
 Wed, 17 Aug 2016 14:17:34 +0900 (KST)
From: Daeho Jeong <daeho.jeong@samsung.com>
Subject: [RFC 0/3] Add the feature of boosting urgent asynchronous writeback I/O
Date: Wed, 17 Aug 2016 14:20:42 +0900
Message-id: <1471411245-5186-1-git-send-email-daeho.jeong@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk, tytso@mit.edu, adilger.kernel@dilger.ca, jack@suse.com, linux-block@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org
Cc: Daeho Jeong <daeho.jeong@samsung.com>

This is the draft version of the feature to boost urgent async
writeback I/O and this is developed based on kernel 4.7.

We can experience an unexpected dalay when we execute fsync() in the
situation of that tons of async I/O are being flushed out in the system
and, by this kind of fsync() delay, mobile users can see the
application's hiccups frequently.

To finish the fsync() operation, fsync() normally flushes out the
previous buffered data of the file as sync I/O, however, if there are
too many dirty pages in the page cache, the buffered data can be
flushed out as async I/O with other dirty pages by kworker before
fsync() directly flushes out that, and fysnc() might wait until all the
asynchronously issued I/Os are done.

To minimize this kind of delay, we convert async I/Os whose completion
are waited by other processes into sync I/Os for better responsiveness.

We made two micro benchmarks using fsync() and evaluated the effect of
this feature on the mobile device having four 2.3GHz Exynos M1 ARM
cores and four 1.6GHz Cortex-A53 ARM cores, 4GB RAM and 32GB UFS
storage.

The first benchmark is iterating that 4KB data write() and holding on
for 100ms for giving more chances for kworker to flush the buffered
data and executing fsync(), 100 times with the intensive background I/O.
(Its total execution time is 1.06s without the background I/O.)

                        <before opt.>   =>      <after opt.>
fsync exec. time(sec.)  0.289489                0.031048
                        0.282681                0.031255
                        0.290374                0.034004
                        0.235380                0.026512
                        (...)                   (...)
                        0.230488                0.044029
                        0.337035                0.054402
                        0.377575                0.025746
Total exec. time(sec.)  21.78                   3.24 (85.1% decreased)

The second one is iterating that 8MB data write() and fsync(), 50 times
with the intensive background I/O.
(Its total execution time is 5.23s without the background I/O.)

                        <before opt.>   =>      <after opt.>
fsync exec. time(sec.)  0.258374                0.125503
                        0.311217                0.127392
                        0.255543                0.117327
                        0.237811                0.154037
                        (...)                   (...)
                        0.205052                0.131991
                        0.206469                0.107791
                        0.263619                0.155979
Total exec. time(sec.)  14.61                   11.28 (22.8% decreased)

Daeho Jeong (3):
  block, mm: add support for boosting urgent asynchronous writeback io
  cfq: add cfq_find_async_wb_req
  ext4: tag asynchronous writeback io

 block/Kconfig.iosched          |    9 +++
 block/blk-core.c               |   28 ++++++++
 block/cfq-iosched.c            |   29 +++++++++
 block/elevator.c               |  141 ++++++++++++++++++++++++++++++++++++++++
 fs/ext4/page-io.c              |   11 ++++
 include/linux/blk_types.h      |    3 +
 include/linux/elevator.h       |   13 ++++
 include/linux/page-flags.h     |   12 ++++
 include/linux/pagemap.h        |   12 ++++
 include/trace/events/mmflags.h |   10 ++-
 mm/filemap.c                   |   39 +++++++++++
 11 files changed, 306 insertions(+), 1 deletion(-)

-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
