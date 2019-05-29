Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0DFA5C04AB6
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 01:22:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B80972070D
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 01:22:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B80972070D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 588386B0282; Tue, 28 May 2019 21:22:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5114F6B0286; Tue, 28 May 2019 21:22:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 365A76B0287; Tue, 28 May 2019 21:22:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id F33BB6B0282
	for <linux-mm@kvack.org>; Tue, 28 May 2019 21:22:54 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id d7so567581pfq.15
        for <linux-mm@kvack.org>; Tue, 28 May 2019 18:22:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=i2PbIkKA4qN+dzYCxIErZGHuK3U2KLnXw23pqB12a7U=;
        b=RHQ4lLxmQ3/Ba70mWum1QCJ8+eMJ9OE8d7hbai+w/Pqzf26lWg5zsytQbiE1OI1xYi
         1HS7ZdHibru+M4aiXUUBbk423scAG14kPTs90SGHJpcrrqF4UmsUazfhbRy5A23Ahunl
         4ctYGkrPuQxjTSJlSWrrnYdEfy4kXj4MoU7ZpbwlyyGeUIT45Th/cYODTdf3yNQjL4NN
         CDQh9Uw0shkKmmaIWObdKEWaihI/6iMF5chk8N3LsHdgkjVzeaOfHVU9MMLCeye411tw
         RFMH7ZeDDH/28YjSHek13G6FKJP/LzrIsASPxYGNKJ3rlau1p0JNsHMyv7rRvCXz7V89
         jCaQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of teawaterz@linux.alibaba.com designates 115.124.30.130 as permitted sender) smtp.mailfrom=teawaterz@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAXBSRrgV7KSA1CDUBtLkpkD07P8/V39TKhe0XjpH89bWnrwQAyX
	GrnlYbyLpvaJZZugUaGIgh/ebyxPkBUwTat9/LelzaEkdAc1imkKLdasB6rWy3iZJ7wiVGFJeBZ
	FOhVyxOygrtcgdY+lUZ0X0EbrqI5bbetC3ax7T0X1ZzG570smy7ZkcXwtsaciBS+D8g==
X-Received: by 2002:a63:eb0d:: with SMTP id t13mr38755086pgh.37.1559092974607;
        Tue, 28 May 2019 18:22:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzZ6e02Twp5l6GcXIU+KxrtnoWCb9rS8lS3PtdAve49+h8mU6biZZ3bkMQ22Bn9cvtaE4Fe
X-Received: by 2002:a63:eb0d:: with SMTP id t13mr38754998pgh.37.1559092972659;
        Tue, 28 May 2019 18:22:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559092972; cv=none;
        d=google.com; s=arc-20160816;
        b=mA6OlCSOZJcEyMewAccvneVgkb2YKwEreNjKvcMiEZSPNWeY/01fnOneQ9qqUsLzCu
         feNV9gsydsvUcBQi2MumtpOYH1Su+rSTL1b9eHcoAioVC2CfY3hKeT/q4XuUCTso60np
         d+kVNIG8Mz0OxSCVUcS79crE7HtOX7hKC2nOLO7DE/P/oB+9eoitA8vPjxfKOIWu4xwE
         2CRyHUjxO55b+HFrvEwrGwZIY9q4UCl1UdLJQ52xylmu94WcEWYWxuVJFsE4kEABVin+
         Es/OSa/trYiWPRUuIY+he2PoaHEJx5hQNZXHNdib/giutC+tsrR4jBdisx+3dVdKLgLO
         68Tw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=i2PbIkKA4qN+dzYCxIErZGHuK3U2KLnXw23pqB12a7U=;
        b=jCIALc0nqt8JW9ePEgbw5vrA0sPf+2CAdTGkwv9/vnJaEjBXXb8tzB28hzqm5NcRTu
         R28tkj5OinwlVVlqaukhaGqRKsHXqJaDub6GMd2zIHXAXM7+V8X6hMvY5PpEIS7IXRnN
         Hzd5Ol6a4PuNtIwterzpBsdiSZKrxu1b/MTs+2DPvQLKw1kF081em3gsX6wISZBFJnov
         xP23thQV9lYWc2DNsCMvaU2fQZERnyeWbz0JipmiqHl/BYQuOGrtC77x37yKSLkTw/3Q
         b+YeRxAMJKpm3qRJ4JSmVusOgrp1faLTypeWuWtRAVCKfa75BymLA2tBK+SWgGbDzCtr
         65rA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of teawaterz@linux.alibaba.com designates 115.124.30.130 as permitted sender) smtp.mailfrom=teawaterz@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-130.freemail.mail.aliyun.com (out30-130.freemail.mail.aliyun.com. [115.124.30.130])
        by mx.google.com with ESMTPS id d185si25755484pfa.182.2019.05.28.18.22.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 May 2019 18:22:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of teawaterz@linux.alibaba.com designates 115.124.30.130 as permitted sender) client-ip=115.124.30.130;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of teawaterz@linux.alibaba.com designates 115.124.30.130 as permitted sender) smtp.mailfrom=teawaterz@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R181e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e01422;MF=teawaterz@linux.alibaba.com;NM=1;PH=DS;RN=6;SR=0;TI=SMTPD_---0TSv6CYB_1559092963;
Received: from localhost(mailfrom:teawaterz@linux.alibaba.com fp:SMTPD_---0TSv6CYB_1559092963)
          by smtp.aliyun-inc.com(127.0.0.1);
          Wed, 29 May 2019 09:22:50 +0800
From: Hui Zhu <teawaterz@linux.alibaba.com>
To: minchan@kernel.org,
	ngupta@vflare.org,
	sergey.senozhatsky.work@gmail.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Cc: Hui Zhu <teawaterz@linux.alibaba.com>
Subject: [UPSTREAM KERNEL] mm/zsmalloc.c: Add module parameter malloc_force_movable
Date: Wed, 29 May 2019 09:22:30 +0800
Message-Id: <20190529012230.89042-1-teawaterz@linux.alibaba.com>
X-Mailer: git-send-email 2.20.1 (Apple Git-117)
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

zswap compresses swap pages into a dynamically allocated RAM-based
memory pool.  The memory pool should be zbud, z3fold or zsmalloc.
All of them will allocate unmovable pages.  It will increase the
number of unmovable page blocks that will bad for anti-fragment.

zsmalloc support page migration if request movable page:
        handle = zs_malloc(zram->mem_pool, comp_len,
                GFP_NOIO | __GFP_HIGHMEM |
                __GFP_MOVABLE);

This commit adds module parameter malloc_force_movable to enable
or disable zs_malloc force allocate block with gfp
__GFP_HIGHMEM | __GFP_MOVABLE (disabled by default).

Following part is test log in a pc that has 8G memory and 2G swap.

When it disabled:
~# echo lz4 > /sys/module/zswap/parameters/compressor
~# echo zsmalloc > /sys/module/zswap/parameters/zpool
~# echo 1 > /sys/module/zswap/parameters/enabled
~# swapon /swapfile
~# cd /home/teawater/kernel/vm-scalability/
/home/teawater/kernel/vm-scalability# export unit_size=$((9 * 1024 * 1024 * 1024))
/home/teawater/kernel/vm-scalability# ./case-anon-w-seq
2717908992 bytes / 4410183 usecs = 601836 KB/s
2717908992 bytes / 4524375 usecs = 586646 KB/s
2717908992 bytes / 4558583 usecs = 582244 KB/s
2717908992 bytes / 4824261 usecs = 550179 KB/s
348046 usecs to free memory
401680 usecs to free memory
369660 usecs to free memory
180867 usecs to free memory
/home/teawater/kernel/vm-scalability# cat /proc/pagetypeinfo
Page block order: 9
Pages per block:  512

Free pages count per migrate type at order       0      1      2      3      4      5      6      7      8      9     10
Node    0, zone      DMA, type    Unmovable      1      1      1      0      2      1      1      0      1      0      0
Node    0, zone      DMA, type      Movable      0      0      0      0      0      0      0      0      0      1      3
Node    0, zone      DMA, type  Reclaimable      0      0      0      0      0      0      0      0      0      0      0
Node    0, zone      DMA, type   HighAtomic      0      0      0      0      0      0      0      0      0      0      0
Node    0, zone      DMA, type          CMA      0      0      0      0      0      0      0      0      0      0      0
Node    0, zone      DMA, type      Isolate      0      0      0      0      0      0      0      0      0      0      0
Node    0, zone    DMA32, type    Unmovable     13     11     10     11     10      6      7      3      1      0      0
Node    0, zone    DMA32, type      Movable     36     26     39     40     37     36     24     29     14      6    767
Node    0, zone    DMA32, type  Reclaimable      0      0      0      0      0      0      0      0      0      0      1
Node    0, zone    DMA32, type   HighAtomic      0      0      0      0      0      0      0      0      0      0      0
Node    0, zone    DMA32, type          CMA      0      0      0      0      0      0      0      0      0      0      0
Node    0, zone    DMA32, type      Isolate      0      0      0      0      0      0      0      0      0      0      0
Node    0, zone   Normal, type    Unmovable   7744   7519   6900   5964   4583   2878   1346    448    146      1      0
Node    0, zone   Normal, type      Movable    645   1930   1685   1339   1020    670    363    210    106    310    399
Node    0, zone   Normal, type  Reclaimable     53     70    116     48     13      0      0      0      0      0      0
Node    0, zone   Normal, type   HighAtomic      0      0      0      0      0      0      0      0      0      0      0
Node    0, zone   Normal, type          CMA      0      0      0      0      0      0      0      0      0      0      0
Node    0, zone   Normal, type      Isolate      0      0      0      0      0      0      0      0      0      0      0

Number of blocks type     Unmovable      Movable  Reclaimable   HighAtomic          CMA      Isolate
Node 0, zone      DMA            1            7            0            0            0            0
Node 0, zone    DMA32            4         1650            2            0            0            0
Node 0, zone   Normal          947         1469           15            0            0            0

When it enabled:
~# echo 1 > /sys/module/zsmalloc/parameters/malloc_force_movable
~# echo lz4 > /sys/module/zswap/parameters/compressor
~# echo zsmalloc > /sys/module/zswap/parameters/zpool
~# echo 1 > /sys/module/zswap/parameters/enabled
~# swapon /swapfile
~# cd /home/teawater/kernel/vm-scalability/
/home/teawater/kernel/vm-scalability# export unit_size=$((9 * 1024 * 1024 * 1024))
/home/teawater/kernel/vm-scalability# ./case-anon-w-seq
2717908992 bytes / 4779235 usecs = 555362 KB/s
2717908992 bytes / 4856673 usecs = 546507 KB/s
2717908992 bytes / 4920079 usecs = 539464 KB/s
2717908992 bytes / 4935505 usecs = 537778 KB/s
354839 usecs to free memory
368167 usecs to free memory
355460 usecs to free memory
385452 usecs to free memory
/home/teawater/kernel/vm-scalability# cat /proc/pagetypeinfo
Page block order: 9
Pages per block:  512

Free pages count per migrate type at order       0      1      2      3      4      5      6      7      8      9     10
Node    0, zone      DMA, type    Unmovable      1      1      1      0      2      1      1      0      1      0      0
Node    0, zone      DMA, type      Movable      0      0      0      0      0      0      0      0      0      1      3
Node    0, zone      DMA, type  Reclaimable      0      0      0      0      0      0      0      0      0      0      0
Node    0, zone      DMA, type   HighAtomic      0      0      0      0      0      0      0      0      0      0      0
Node    0, zone      DMA, type          CMA      0      0      0      0      0      0      0      0      0      0      0
Node    0, zone      DMA, type      Isolate      0      0      0      0      0      0      0      0      0      0      0
Node    0, zone    DMA32, type    Unmovable      9     15     13     10     13      9      3      2      2      0      0
Node    0, zone    DMA32, type      Movable     16     19     10     14     17     17     16      8      5      6    775
Node    0, zone    DMA32, type  Reclaimable      0      0      0      0      0      0      0      0      0      0      0
Node    0, zone    DMA32, type   HighAtomic      0      0      0      0      0      0      0      0      0      0      0
Node    0, zone    DMA32, type          CMA      0      0      0      0      0      0      0      0      0      0      0
Node    0, zone    DMA32, type      Isolate      0      0      0      0      0      0      0      0      0      0      0
Node    0, zone   Normal, type    Unmovable   2525   1347    603    181     55     14      4      1      6      0      0
Node    0, zone   Normal, type      Movable   5255   6069   5007   3978   2885   1940   1164    732    485    276    511
Node    0, zone   Normal, type  Reclaimable    103    104    140     87     31     21      7      3      2      1      1
Node    0, zone   Normal, type   HighAtomic      0      0      0      0      0      0      0      0      0      0      0
Node    0, zone   Normal, type          CMA      0      0      0      0      0      0      0      0      0      0      0
Node    0, zone   Normal, type      Isolate      0      0      0      0      0      0      0      0      0      0      0

Number of blocks type     Unmovable      Movable  Reclaimable   HighAtomic          CMA      Isolate
Node 0, zone      DMA            1            7            0            0            0            0
Node 0, zone    DMA32            4         1652            0            0            0            0
Node 0, zone   Normal           78         2330           23            0            0            0

You can see that the number of unmovable page blocks is decreased
when malloc_force_movable is enabled.

Signed-off-by: Hui Zhu <teawaterz@linux.alibaba.com>
---
 mm/zsmalloc.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 0787d33b80d8..7d44c7ccd882 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -178,6 +178,13 @@ static struct dentry *zs_stat_root;
 static struct vfsmount *zsmalloc_mnt;
 #endif
 
+/* Enable/disable zs_malloc force allocate block with
+ *  gfp __GFP_HIGHMEM | __GFP_MOVABLE (disabled by default).
+ */
+static bool __read_mostly zs_malloc_force_movable;
+module_param_cb(malloc_force_movable, &param_ops_bool,
+		&zs_malloc_force_movable, 0644);
+
 /*
  * We assign a page to ZS_ALMOST_EMPTY fullness group when:
  *	n <= N / f, where
@@ -1479,6 +1486,9 @@ unsigned long zs_malloc(struct zs_pool *pool, size_t size, gfp_t gfp)
 	if (unlikely(!size || size > ZS_MAX_ALLOC_SIZE))
 		return 0;
 
+	if (zs_malloc_force_movable)
+		gfp |= __GFP_HIGHMEM | __GFP_MOVABLE;
+
 	handle = cache_alloc_handle(pool, gfp);
 	if (!handle)
 		return 0;
-- 
2.20.1 (Apple Git-117)

