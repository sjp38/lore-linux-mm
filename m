Return-Path: <SRS0=2YS/=UB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 41EB7C282DC
	for <linux-mm@archiver.kernel.org>; Sun,  2 Jun 2019 09:46:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E9DB2278AB
	for <linux-mm@archiver.kernel.org>; Sun,  2 Jun 2019 09:46:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E9DB2278AB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 751CD6B0010; Sun,  2 Jun 2019 05:46:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6DB206B0266; Sun,  2 Jun 2019 05:46:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 57EAE6B0269; Sun,  2 Jun 2019 05:46:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1C3F26B0010
	for <linux-mm@kvack.org>; Sun,  2 Jun 2019 05:46:44 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id 93so9494487plf.14
        for <linux-mm@kvack.org>; Sun, 02 Jun 2019 02:46:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=+RgFaPwzCNwNxIUjGFSq56qKQgfzgYNSGLTN36JyM2o=;
        b=XRNNYUR/2xLOqU8kMVCIwN3+iFH6c9Gq1reDMUwTd9B85tNKTSqSgOS2rYyzKNnbrj
         Ft8Vo8TteDBUx9ha62hpAI1oK6xXIBA1xZsaqVPEolob0HrzE0xNq81HDESYXcwEMBoL
         RPEP33jpG7l2StruVgk14xON5VH9uKiWLGVhsItcasEUuHTUbxk9NtUMx58vrDMWIgmb
         PV99tE0YtDfwqdTL0VpYS98HP4PLu4A36oh04Kv7uR8UXpXIPPBWNWj2iPn8jcdMYKeq
         bKlANJ9F6FFEozSBy81N2XR761pp6lFCSr7bsFd3Q5K5Dyn8SI/FkMmPj0epe+zmb83/
         jg/w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of teawaterz@linux.alibaba.com designates 115.124.30.57 as permitted sender) smtp.mailfrom=teawaterz@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAXhUjhic5ikY5EEmt9CkkBz+opeoNh4/G064nR+E/TnJYefJq8C
	sq7tPLz0anexq6LfvXojny/IO8zxGWfFPS2FPMZ/Vm9ODFF+fKopOX5DqharDWYsJnySGALZcHg
	7w+n6HyIlq/S6xP+JHbpSVZ+z0t0Bm0yPIcZLEkAxXNI90o+rTxhlKQTlk2EsRbt85g==
X-Received: by 2002:a17:902:2e81:: with SMTP id r1mr22207175plb.0.1559468803531;
        Sun, 02 Jun 2019 02:46:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwWn4L2cGRqmu8d/CDMToLp1km0waNhsU3xLWLHZlA9NQZw0A0tbObBoqyY38YgAjgjs+au
X-Received: by 2002:a17:902:2e81:: with SMTP id r1mr22207105plb.0.1559468801824;
        Sun, 02 Jun 2019 02:46:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559468801; cv=none;
        d=google.com; s=arc-20160816;
        b=WYi+oLSmZIJUiP8iOODE/jFj8hySyv/BzKQvlhBIIZzJmbbqfFzVhj05DKRzBhq6ZT
         wrqLEKu+n4vdnSWq0doZwai1zu8Lr21JQSBR1w4VhqGnPbNNIXEQGaXgWbuQZ/h91pWD
         304mhyZMJs/WUacbatXENeSqIvkgzu6PFmOppCQts3GfmSNjWJHwZTZK7SScviRH0mQA
         /AAuYJOyP+FIw2Qn68lZ0LCYDJVpMCiq33/BfnJnnhH+9NFs9F8YJFaFIbDSeeWFOp4J
         2OioLNVk2/jWAkg15MEmJsHgTLOCaauy3PUuYiZ+wHkEvy8ZbB6geuFVlWjK+f8+8Frt
         ZPLw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=+RgFaPwzCNwNxIUjGFSq56qKQgfzgYNSGLTN36JyM2o=;
        b=euRLu0U1CchBp0F/9JPZFqAZY2dYxvavrFVmzie0ujF/BPWTY24GrqIAzLXRVhBOGk
         TC9X+3Awe3TOfjK0FVVbo10xClzICvhkPcvk6YbhzwoOMpHGybL5an3GDGP39IKIMcOc
         8rWlyYCCTnjZQgyws86LJUxHMBICi944GqOJtoe/p7XXgSnlTjyNN3p098jhmh1MZZB+
         IELQQh9ewBF38Or3mWImeAHj6Tw4RHd1aAJGxsAC0fACUOuW+SJnttPyHwOWacjqSEjq
         A55YxxIXsNNZR7aOV69rjhq9/oV6efTRny07vuiCZ7QZYYyR37OEzneyp0fKllc6vNlf
         lMZA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of teawaterz@linux.alibaba.com designates 115.124.30.57 as permitted sender) smtp.mailfrom=teawaterz@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-57.freemail.mail.aliyun.com (out30-57.freemail.mail.aliyun.com. [115.124.30.57])
        by mx.google.com with ESMTPS id m5si12951928pgj.451.2019.06.02.02.46.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 02 Jun 2019 02:46:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of teawaterz@linux.alibaba.com designates 115.124.30.57 as permitted sender) client-ip=115.124.30.57;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of teawaterz@linux.alibaba.com designates 115.124.30.57 as permitted sender) smtp.mailfrom=teawaterz@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R121e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e07487;MF=teawaterz@linux.alibaba.com;NM=1;PH=DS;RN=8;SR=0;TI=SMTPD_---0TTD1lP8_1559468787;
Received: from localhost(mailfrom:teawaterz@linux.alibaba.com fp:SMTPD_---0TTD1lP8_1559468787)
          by smtp.aliyun-inc.com(127.0.0.1);
          Sun, 02 Jun 2019 17:46:39 +0800
From: Hui Zhu <teawaterz@linux.alibaba.com>
To: ddstreet@ieee.org,
	minchan@kernel.org,
	ngupta@vflare.org,
	sergey.senozhatsky.work@gmail.com,
	sjenning@redhat.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Cc: Hui Zhu <teawaterz@linux.alibaba.com>
Subject: [PATCH V2 2/2] zswap: Add module parameter malloc_movable_if_support
Date: Sun,  2 Jun 2019 17:46:07 +0800
Message-Id: <20190602094607.41840-2-teawaterz@linux.alibaba.com>
X-Mailer: git-send-email 2.20.1 (Apple Git-117)
In-Reply-To: <20190602094607.41840-1-teawaterz@linux.alibaba.com>
References: <20190602094607.41840-1-teawaterz@linux.alibaba.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is the second version that was updated according to the comments
from Sergey Senozhatsky in https://lkml.org/lkml/2019/5/29/73

zswap compresses swap pages into a dynamically allocated RAM-based
memory pool.  The memory pool should be zbud, z3fold or zsmalloc.
All of them will allocate unmovable pages.  It will increase the
number of unmovable page blocks that will bad for anti-fragment.

zsmalloc support page migration if request movable page:
        handle = zs_malloc(zram->mem_pool, comp_len,
                GFP_NOIO | __GFP_HIGHMEM |
                __GFP_MOVABLE);

And commit "zpool: Add malloc_support_movable to zpool_driver" add
zpool_malloc_support_movable check malloc_support_movable to make
sure if a zpool support allocate movable memory.

This commit adds module parameter malloc_movable_if_support to enable
or disable zpool allocate block with gfp __GFP_HIGHMEM | __GFP_MOVABLE
if it support allocate movable memory (disabled by default).

Following part is test log in a pc that has 8G memory and 2G swap.

When it disabled:
 echo lz4 > /sys/module/zswap/parameters/compressor
 echo zsmalloc > /sys/module/zswap/parameters/zpool
 echo 1 > /sys/module/zswap/parameters/enabled
 swapon /swapfile
 cd /home/teawater/kernel/vm-scalability/
/home/teawater/kernel/vm-scalability# export unit_size=$((9 * 1024 * 1024 * 1024))
/home/teawater/kernel/vm-scalability# ./case-anon-w-seq
2717908992 bytes / 3977932 usecs = 667233 KB/s
2717908992 bytes / 4160702 usecs = 637923 KB/s
2717908992 bytes / 4354611 usecs = 609516 KB/s
293359 usecs to free memory
340304 usecs to free memory
205781 usecs to free memory
2717908992 bytes / 5588016 usecs = 474982 KB/s
166124 usecs to free memory
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
Node    0, zone    DMA32, type    Unmovable      5     10      9      8      8      5      1      2      3      0      0
Node    0, zone    DMA32, type      Movable     15     16     14     12     14     10      9      6      6      5    776
Node    0, zone    DMA32, type  Reclaimable      0      0      0      0      0      0      0      0      0      0      0
Node    0, zone    DMA32, type   HighAtomic      0      0      0      0      0      0      0      0      0      0      0
Node    0, zone    DMA32, type          CMA      0      0      0      0      0      0      0      0      0      0      0
Node    0, zone    DMA32, type      Isolate      0      0      0      0      0      0      0      0      0      0      0
Node    0, zone   Normal, type    Unmovable   7097   6914   6473   5642   4373   2664   1220    319     78      4      0
Node    0, zone   Normal, type      Movable   2092   3216   2820   2266   1585    946    559    359    237    258    378
Node    0, zone   Normal, type  Reclaimable     47     88    122     80     34      9      5      4      2      1      2
Node    0, zone   Normal, type   HighAtomic      0      0      0      0      0      0      0      0      0      0      0
Node    0, zone   Normal, type          CMA      0      0      0      0      0      0      0      0      0      0      0
Node    0, zone   Normal, type      Isolate      0      0      0      0      0      0      0      0      0      0      0

Number of blocks type     Unmovable      Movable  Reclaimable   HighAtomic          CMA      Isolate
Node 0, zone      DMA            1            7            0            0            0            0
Node 0, zone    DMA32            4         1652            0            0            0            0
Node 0, zone   Normal          834         1572           25            0            0            0

When it enabled:
 echo lz4 > /sys/module/zswap/parameters/compressor
 echo zsmalloc > /sys/module/zswap/parameters/zpool
 echo 1 > /sys/module/zswap/parameters/enabled
 echo 1 > /sys/module/zswap/parameters/malloc_movable_if_support
 swapon /swapfile
 cd /home/teawater/kernel/vm-scalability/
/home/teawater/kernel/vm-scalability# export unit_size=$((9 * 1024 * 1024 * 1024))
/home/teawater/kernel/vm-scalability# ./case-anon-w-seq
2717908992 bytes / 4721401 usecs = 562165 KB/s
2717908992 bytes / 4783167 usecs = 554905 KB/s
2717908992 bytes / 4802125 usecs = 552715 KB/s
2717908992 bytes / 4866579 usecs = 545395 KB/s
323605 usecs to free memory
414817 usecs to free memory
458576 usecs to free memory
355827 usecs to free memory
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
Node    0, zone    DMA32, type    Unmovable      8     10      8      7      7      6      5      3      2      0      0
Node    0, zone    DMA32, type      Movable     23     21     18     15     13     14     14     10     11      6    766
Node    0, zone    DMA32, type  Reclaimable      0      0      0      0      0      0      0      0      0      0      1
Node    0, zone    DMA32, type   HighAtomic      0      0      0      0      0      0      0      0      0      0      0
Node    0, zone    DMA32, type          CMA      0      0      0      0      0      0      0      0      0      0      0
Node    0, zone    DMA32, type      Isolate      0      0      0      0      0      0      0      0      0      0      0
Node    0, zone   Normal, type    Unmovable   2660   1295    460    102     11      5      3     11      2      4      0
Node    0, zone   Normal, type      Movable   4178   5760   5045   4137   3324   2306   1482    930    497    254    460
Node    0, zone   Normal, type  Reclaimable     50     83    114     93     28     12     10      6      3      3      0
Node    0, zone   Normal, type   HighAtomic      0      0      0      0      0      0      0      0      0      0      0
Node    0, zone   Normal, type          CMA      0      0      0      0      0      0      0      0      0      0      0
Node    0, zone   Normal, type      Isolate      0      0      0      0      0      0      0      0      0      0      0

Number of blocks type     Unmovable      Movable  Reclaimable   HighAtomic          CMA      Isolate
Node 0, zone      DMA            1            7            0            0            0            0
Node 0, zone    DMA32            4         1650            2            0            0            0
Node 0, zone   Normal           81         2325           25            0            0            0

You can see that the number of unmovable page blocks is decreased
when malloc_movable_if_support is enabled.

Signed-off-by: Hui Zhu <teawaterz@linux.alibaba.com>
---
 mm/zswap.c | 16 +++++++++++++---
 1 file changed, 13 insertions(+), 3 deletions(-)

diff --git a/mm/zswap.c b/mm/zswap.c
index a4e4d36ec085..2fc45de92383 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -123,6 +123,13 @@ static bool zswap_same_filled_pages_enabled = true;
 module_param_named(same_filled_pages_enabled, zswap_same_filled_pages_enabled,
 		   bool, 0644);
 
+/* Enable/disable zpool allocate block with gfp __GFP_HIGHMEM | __GFP_MOVABLE
+ * if it support allocate movable memory (disabled by default).
+ */
+static bool __read_mostly zswap_malloc_movable_if_support;
+module_param_cb(malloc_movable_if_support, &param_ops_bool,
+		&zswap_malloc_movable_if_support, 0644);
+
 /*********************************
 * data structures
 **********************************/
@@ -1006,6 +1013,7 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
 	char *buf;
 	u8 *src, *dst;
 	struct zswap_header zhdr = { .swpentry = swp_entry(type, offset) };
+	gfp_t gfp = __GFP_NORETRY | __GFP_NOWARN | __GFP_KSWAPD_RECLAIM;
 
 	/* THP isn't supported */
 	if (PageTransHuge(page)) {
@@ -1079,9 +1087,11 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
 
 	/* store */
 	hlen = zpool_evictable(entry->pool->zpool) ? sizeof(zhdr) : 0;
-	ret = zpool_malloc(entry->pool->zpool, hlen + dlen,
-			   __GFP_NORETRY | __GFP_NOWARN | __GFP_KSWAPD_RECLAIM,
-			   &handle);
+	if (zswap_malloc_movable_if_support &&
+		zpool_malloc_support_movable(entry->pool->zpool)) {
+		gfp |= __GFP_HIGHMEM | __GFP_MOVABLE;
+	}
+	ret = zpool_malloc(entry->pool->zpool, hlen + dlen, gfp, &handle);
 	if (ret == -ENOSPC) {
 		zswap_reject_compress_poor++;
 		goto put_dstmem;
-- 
2.20.1 (Apple Git-117)

