Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id A20C56B0010
	for <linux-mm@kvack.org>; Thu, 24 May 2018 05:57:58 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id y7-v6so766089qtn.3
        for <linux-mm@kvack.org>; Thu, 24 May 2018 02:57:58 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id x76-v6si8316258qkb.259.2018.05.24.02.57.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 May 2018 02:57:57 -0700 (PDT)
From: Li Wang <liwang@redhat.com>
Subject: [PATCH RFC] zswap: reject to compress/store page if zswap_max_pool_percent is 0
Date: Thu, 24 May 2018 17:57:51 +0800
Message-Id: <20180524095752.17770-1-liwang@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Seth Jennings <sjenning@redhat.com>, Dan Streetman <ddstreet@ieee.org>, Huang Ying <huang.ying.caritas@gmail.com>, Yu Zhao <yuzhao@google.com>

The '/sys/../zswap/stored_pages:' keep raising in zswap test with
"zswap.max_pool_percent=0" parameter. But theoretically, it should
not compress or store pages any more since there is no space for
compressed pool.

Reproduce steps:

  1. Boot kernel with "zswap.enabled=1 zswap.max_pool_percent=17"
  2. Set the max_pool_percent to 0
      # echo 0 > /sys/module/zswap/parameters/max_pool_percent
     Confirm this parameter works fine
      # cat /sys/kernel/debug/zswap/pool_total_size
      0
  3. Do memory stress test to see if some pages have been compressed
      # stress --vm 1 --vm-bytes $mem_available"M" --timeout 60s
     Watching the 'stored_pages' numbers increasing or not

The root cause is:

  When the zswap_max_pool_percent is set to 0 via kernel parameter, the zswap_is_full()
  will always return true to shrink the pool size by zswap_shrink(). If the pool size
  has been shrinked a little success, zswap will do compress/store pages again. Then we
  get fails on that as above.

Signed-off-by: Li Wang <liwang@redhat.com>
Cc: Seth Jennings <sjenning@redhat.com>
Cc: Dan Streetman <ddstreet@ieee.org>
Cc: Huang Ying <huang.ying.caritas@gmail.com>
Cc: Yu Zhao <yuzhao@google.com>
---
 mm/zswap.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/mm/zswap.c b/mm/zswap.c
index 61a5c41..2b537bb 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -1007,6 +1007,11 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
 	u8 *src, *dst;
 	struct zswap_header zhdr = { .swpentry = swp_entry(type, offset) };
 
+	if (!zswap_max_pool_percent) {
+		ret = -ENOMEM;
+		goto reject;
+	}
+
 	/* THP isn't supported */
 	if (PageTransHuge(page)) {
 		ret = -EINVAL;
-- 
2.9.5
