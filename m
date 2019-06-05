Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A544BC282DE
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 10:07:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 67143206B8
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 10:07:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 67143206B8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E72646B0010; Wed,  5 Jun 2019 06:07:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E23B16B0266; Wed,  5 Jun 2019 06:07:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D37C06B0269; Wed,  5 Jun 2019 06:07:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id B26F26B0010
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 06:07:05 -0400 (EDT)
Received: by mail-it1-f199.google.com with SMTP id o83so1429353itc.9
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 03:07:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=3fn1Cj3qS1vM8x05CuUXuctfbV0i+6VVjPYt+7uhgbs=;
        b=k/nvFHu42XPp44A0VmYXE23KgSmSY23wtq/5sM7/xr+OFuwPxdfmfL9gZlhLzGDxni
         t1SjzJBb7FIUbsYri21YNC13g2GXKHHshNNng2ffYTZ854HyiUPJRMkyCJtvBFKP1CpV
         zgP5oRjPlriEusARlccvfr0ggteUV661NpBDAr3aSYOya/ChLn+HX4gAgQZrI7UeXNKH
         /Mkz5qUdcaob8FcwcfZ5/lEbroqSiP8CnDIMNcP5m/pM+jI9YUID5QgXARRiTNQPQlHZ
         pOJrwG6qhG/IOBd6I/olx+E2rqjvOIWiDwjNJ+2v2MBN2MuwOD8iKVZ1AKkYGoN8Tz1C
         Z4iQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of teawaterz@linux.alibaba.com designates 115.124.30.54 as permitted sender) smtp.mailfrom=teawaterz@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAXnAteFLvqSE8JsGZRevBuH/LvH+aYBsk3stlctqkUpA/wTNrAq
	9R2fxLO39XrisA1PbptvY43IglbBq68eeWshak3PAgwj5qxgbinLHqFd2zyqjQCxjolwTypDnVC
	+tRitxTiyzvZxsnq0mjtlMVWzY757KMFvudicQw+mm0puwWsIxPKSG0VKyzFz+e9GHQ==
X-Received: by 2002:a24:3a50:: with SMTP id m77mr26029441itm.110.1559729225432;
        Wed, 05 Jun 2019 03:07:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwL6A/9ulwG/THo8QAmWFOz0RIycngrLVOcsHubQmcMuey/GJlpuZUoovcwBJukPKAAw3wJ
X-Received: by 2002:a24:3a50:: with SMTP id m77mr26029322itm.110.1559729223814;
        Wed, 05 Jun 2019 03:07:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559729223; cv=none;
        d=google.com; s=arc-20160816;
        b=POla4ywBSsQJWazuLUUqpuM2DbVXgDdu+z6SaMbtLl3tjTwYfj3yK1ihq0j1Ch7CQe
         NlGFlvODmScFO3CvpCC2A1hcmSFcOUlRhM8sYvNOBE5cHTQlmvdYkZAHgY2RlOUI1Dhx
         n2WrA4cjqDDreOLRoGbKn/gGAXmF0PTQi8z5m5S3H0ZOsGa1FbxWaGDIWj7Ko4mf0K6V
         7+LGl94EDmmLW2PL/cvTBLS5LCDI2q+b3i63ao8tvHQX92G7vI9EY1zxnwP5kh3xUgQW
         cOcM67w7hQjgZSe74sfp+r8E5lAvhhi9ZtN0rlnMTgYvH77cpj+b8SD+JnGui/1EIExy
         k8Gw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=3fn1Cj3qS1vM8x05CuUXuctfbV0i+6VVjPYt+7uhgbs=;
        b=ksjcZHf2GTDdGIPlxBxDkja33afu2bJrWdwjfppuNrzmIcYxqqs7yKfnkqu1oss2lX
         OFSdAbEKO8/QK8njE/DPxBxzPJiISZmNPnFtg+WEIVJ/Di1rz2Xh/nkt0wMyCKQ+lGzo
         JDhxsWriT+QLU41kwYvA/JAvJrR62tLtbAgfC/giPlV8RVmr7CM6yF7JIg6KQgvnT5Jl
         DkkUXrU8CwyWePY/wxY97tnEM3Dx2RJktu10REthiVYs2ocU6+vGA4JRKfAUbFN3SDb5
         i7fDYsye+TgyPWm/spzo94U+C5hbjZCNsO/xjPr0blOHCZ3zBxNIiWOitlLogGyTTxnQ
         xpkA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of teawaterz@linux.alibaba.com designates 115.124.30.54 as permitted sender) smtp.mailfrom=teawaterz@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-54.freemail.mail.aliyun.com (out30-54.freemail.mail.aliyun.com. [115.124.30.54])
        by mx.google.com with ESMTPS id p16si5814744itc.32.2019.06.05.03.07.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jun 2019 03:07:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of teawaterz@linux.alibaba.com designates 115.124.30.54 as permitted sender) client-ip=115.124.30.54;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of teawaterz@linux.alibaba.com designates 115.124.30.54 as permitted sender) smtp.mailfrom=teawaterz@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R391e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04394;MF=teawaterz@linux.alibaba.com;NM=1;PH=DS;RN=9;SR=0;TI=SMTPD_---0TTUHvuX_1559729202;
Received: from localhost(mailfrom:teawaterz@linux.alibaba.com fp:SMTPD_---0TTUHvuX_1559729202)
          by smtp.aliyun-inc.com(127.0.0.1);
          Wed, 05 Jun 2019 18:06:46 +0800
From: Hui Zhu <teawaterz@linux.alibaba.com>
To: ddstreet@ieee.org,
	minchan@kernel.org,
	ngupta@vflare.org,
	sergey.senozhatsky.work@gmail.com,
	sjenning@redhat.com,
	shakeelb@google.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Cc: Hui Zhu <teawaterz@linux.alibaba.com>
Subject: [PATCH V3 2/2] zswap: Use movable memory if zpool support allocate movable memory
Date: Wed,  5 Jun 2019 18:06:30 +0800
Message-Id: <20190605100630.13293-2-teawaterz@linux.alibaba.com>
X-Mailer: git-send-email 2.21.0 (Apple Git-120)
In-Reply-To: <20190605100630.13293-1-teawaterz@linux.alibaba.com>
References: <20190605100630.13293-1-teawaterz@linux.alibaba.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is the third version that was updated according to the comments
from Sergey Senozhatsky https://lkml.org/lkml/2019/5/29/73 and
Shakeel Butt https://lkml.org/lkml/2019/6/4/973

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

This commit let zswap allocate block with gfp
__GFP_HIGHMEM | __GFP_MOVABLE if zpool support allocate movable memory.

Following part is test log in a pc that has 8G memory and 2G swap.

Without this commit:
~# echo lz4 > /sys/module/zswap/parameters/compressor
~# echo zsmalloc > /sys/module/zswap/parameters/zpool
~# echo 1 > /sys/module/zswap/parameters/enabled
~# swapon /swapfile
~# cd /home/teawater/kernel/vm-scalability/
/home/teawater/kernel/vm-scalability# export unit_size=$((9 * 1024 * 1024 * 1024))
/home/teawater/kernel/vm-scalability# ./case-anon-w-seq
2717908992 bytes / 4826062 usecs = 549973 KB/s
2717908992 bytes / 4864201 usecs = 545661 KB/s
2717908992 bytes / 4867015 usecs = 545346 KB/s
2717908992 bytes / 4915485 usecs = 539968 KB/s
397853 usecs to free memory
357820 usecs to free memory
421333 usecs to free memory
420454 usecs to free memory
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
Node    0, zone    DMA32, type    Unmovable      6      5      8      6      6      5      4      1      1      1      0
Node    0, zone    DMA32, type      Movable     25     20     20     19     22     15     14     11     11      5    767
Node    0, zone    DMA32, type  Reclaimable      0      0      0      0      0      0      0      0      0      0      0
Node    0, zone    DMA32, type   HighAtomic      0      0      0      0      0      0      0      0      0      0      0
Node    0, zone    DMA32, type          CMA      0      0      0      0      0      0      0      0      0      0      0
Node    0, zone    DMA32, type      Isolate      0      0      0      0      0      0      0      0      0      0      0
Node    0, zone   Normal, type    Unmovable   4753   5588   5159   4613   3712   2520   1448    594    188     11      0
Node    0, zone   Normal, type      Movable     16      3    457   2648   2143   1435    860    459    223    224    296
Node    0, zone   Normal, type  Reclaimable      0      0     44     38     11      2      0      0      0      0      0
Node    0, zone   Normal, type   HighAtomic      0      0      0      0      0      0      0      0      0      0      0
Node    0, zone   Normal, type          CMA      0      0      0      0      0      0      0      0      0      0      0
Node    0, zone   Normal, type      Isolate      0      0      0      0      0      0      0      0      0      0      0

Number of blocks type     Unmovable      Movable  Reclaimable   HighAtomic          CMA      Isolate
Node 0, zone      DMA            1            7            0            0            0            0
Node 0, zone    DMA32            4         1652            0            0            0            0
Node 0, zone   Normal          931         1485           15            0            0            0

With this commit:
~# echo lz4 > /sys/module/zswap/parameters/compressor
~# echo zsmalloc > /sys/module/zswap/parameters/zpool
~# echo 1 > /sys/module/zswap/parameters/enabled
~# swapon /swapfile
~# cd /home/teawater/kernel/vm-scalability/
/home/teawater/kernel/vm-scalability# export unit_size=$((9 * 1024 * 1024 * 1024))
/home/teawater/kernel/vm-scalability# ./case-anon-w-seq
2717908992 bytes / 4689240 usecs = 566020 KB/s
2717908992 bytes / 4760605 usecs = 557535 KB/s
2717908992 bytes / 4803621 usecs = 552543 KB/s
2717908992 bytes / 5069828 usecs = 523530 KB/s
431546 usecs to free memory
383397 usecs to free memory
456454 usecs to free memory
224487 usecs to free memory
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
Node    0, zone    DMA32, type    Unmovable     10      8     10      9     10      4      3      2      3      0      0
Node    0, zone    DMA32, type      Movable     18     12     14     16     16     11      9      5      5      6    775
Node    0, zone    DMA32, type  Reclaimable      0      0      0      0      0      0      0      0      0      0      1
Node    0, zone    DMA32, type   HighAtomic      0      0      0      0      0      0      0      0      0      0      0
Node    0, zone    DMA32, type          CMA      0      0      0      0      0      0      0      0      0      0      0
Node    0, zone    DMA32, type      Isolate      0      0      0      0      0      0      0      0      0      0      0
Node    0, zone   Normal, type    Unmovable   2669   1236    452    118     37     14      4      1      2      3      0
Node    0, zone   Normal, type      Movable   3850   6086   5274   4327   3510   2494   1520    934    438    220    470
Node    0, zone   Normal, type  Reclaimable     56     93    155    124     47     31     17      7      3      0      0
Node    0, zone   Normal, type   HighAtomic      0      0      0      0      0      0      0      0      0      0      0
Node    0, zone   Normal, type          CMA      0      0      0      0      0      0      0      0      0      0      0
Node    0, zone   Normal, type      Isolate      0      0      0      0      0      0      0      0      0      0      0

Number of blocks type     Unmovable      Movable  Reclaimable   HighAtomic          CMA      Isolate
Node 0, zone      DMA            1            7            0            0            0            0
Node 0, zone    DMA32            4         1650            2            0            0            0
Node 0, zone   Normal           79         2326           26            0            0            0

You can see that the number of unmovable page blocks is decreased
when the kernel has this commit.

Signed-off-by: Hui Zhu <teawaterz@linux.alibaba.com>
---
 mm/zswap.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/mm/zswap.c b/mm/zswap.c
index a4e4d36ec085..c6bf92bf5890 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -1006,6 +1006,7 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
 	char *buf;
 	u8 *src, *dst;
 	struct zswap_header zhdr = { .swpentry = swp_entry(type, offset) };
+	gfp_t gfp;
 
 	/* THP isn't supported */
 	if (PageTransHuge(page)) {
@@ -1079,9 +1080,10 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
 
 	/* store */
 	hlen = zpool_evictable(entry->pool->zpool) ? sizeof(zhdr) : 0;
-	ret = zpool_malloc(entry->pool->zpool, hlen + dlen,
-			   __GFP_NORETRY | __GFP_NOWARN | __GFP_KSWAPD_RECLAIM,
-			   &handle);
+	gfp = __GFP_NORETRY | __GFP_NOWARN | __GFP_KSWAPD_RECLAIM;
+	if (zpool_malloc_support_movable(entry->pool->zpool))
+		gfp |= __GFP_HIGHMEM | __GFP_MOVABLE;
+	ret = zpool_malloc(entry->pool->zpool, hlen + dlen, gfp, &handle);
 	if (ret == -ENOSPC) {
 		zswap_reject_compress_poor++;
 		goto put_dstmem;
-- 
2.21.0 (Apple Git-120)

