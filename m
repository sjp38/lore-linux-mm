Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id D72546B02A2
	for <linux-mm@kvack.org>; Wed, 30 May 2018 06:39:43 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id 5-v6so16458546qke.19
        for <linux-mm@kvack.org>; Wed, 30 May 2018 03:39:43 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id d10-v6si661849qvd.227.2018.05.30.03.39.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 May 2018 03:39:43 -0700 (PDT)
From: Li Wang <liwang@redhat.com>
Subject: [PATCH v2] zswap: re-check zswap_is_full after do zswap_shrink
Date: Wed, 30 May 2018 18:39:36 +0800
Message-Id: <20180530103936.17812-1-liwang@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ddstreet@ieee.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Seth Jennings <sjenning@redhat.com>, Huang Ying <huang.ying.caritas@gmail.com>, Yu Zhao <yuzhao@google.com>

The '/sys/../zswap/stored_pages:' keep raising in zswap test with
"zswap.max_pool_percent=0" parameter. But theoretically, it should
not compress or store pages any more since there is no space in
compressed pool.

Reproduce steps:
  1. Boot kernel with "zswap.enabled=1"
  2. Set the max_pool_percent to 0
      # echo 0 > /sys/module/zswap/parameters/max_pool_percent
  3. Do memory stress test to see if some pages have been compressed
      # stress --vm 1 --vm-bytes $mem_available"M" --timeout 60s
  4. Watching the 'stored_pages' number increasing or not

The root cause is:
  When zswap_max_pool_percent is setting to 0 via kernel parameter, the
  zswap_is_full() will always return true to do zswap_shrink(). But if
  the shinking is able to reclain a page successful, then proceeds to
  compress/store another page, so the value of stored_pages will keep
  changing.

To solve the issue, this patch adds zswap_is_full() check again after
zswap_shrink() to make sure it's now under the max_pool_percent, and
not to compress/store if reach its limitaion.

Signed-off-by: Li Wang <liwang@redhat.com>
Cc: Seth Jennings <sjenning@redhat.com>
Cc: Dan Streetman <ddstreet@ieee.org>
Cc: Huang Ying <huang.ying.caritas@gmail.com>
Cc: Yu Zhao <yuzhao@google.com>
---
 mm/zswap.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/mm/zswap.c b/mm/zswap.c
index 61a5c41..fd320c3 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -1026,6 +1026,15 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
 			ret = -ENOMEM;
 			goto reject;
 		}
+
+		/* A second zswap_is_full() check after
+		 * zswap_shrink() to make sure it's now
+		 * under the max_pool_percent
+		 */
+		if (zswap_is_full()) {
+			ret = -ENOMEM;
+			goto reject;
+		}
 	}
 
 	/* allocate entry */
-- 
2.9.5
