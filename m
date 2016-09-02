Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 68A136B0260
	for <linux-mm@kvack.org>; Fri,  2 Sep 2016 07:40:00 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id i4so114789164oih.1
        for <linux-mm@kvack.org>; Fri, 02 Sep 2016 04:40:00 -0700 (PDT)
Received: from g9t5009.houston.hpe.com (g9t5009.houston.hpe.com. [15.241.48.73])
        by mx.google.com with ESMTPS id y6si12534563ota.280.2016.09.02.04.39.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Sep 2016 04:39:59 -0700 (PDT)
From: Juerg Haefliger <juerg.haefliger@hpe.com>
Subject: [RFC PATCH v2 3/3] block: Always use a bounce buffer when XPFO is enabled
Date: Fri,  2 Sep 2016 13:39:09 +0200
Message-Id: <20160902113909.32631-4-juerg.haefliger@hpe.com>
In-Reply-To: <20160902113909.32631-1-juerg.haefliger@hpe.com>
References: <1456496467-14247-1-git-send-email-juerg.haefliger@hpe.com>
 <20160902113909.32631-1-juerg.haefliger@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, linux-x86_64@vger.kernel.org
Cc: juerg.haefliger@hpe.com, vpk@cs.columbia.edu

This is a temporary hack to prevent the use of bio_map_user_iov()
which causes XPFO page faults.

Signed-off-by: Juerg Haefliger <juerg.haefliger@hpe.com>
---
 block/blk-map.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/block/blk-map.c b/block/blk-map.c
index b8657fa8dc9a..e889dbfee6fb 100644
--- a/block/blk-map.c
+++ b/block/blk-map.c
@@ -52,7 +52,7 @@ static int __blk_rq_map_user_iov(struct request *rq,
 	struct bio *bio, *orig_bio;
 	int ret;
 
-	if (copy)
+	if (copy || IS_ENABLED(CONFIG_XPFO))
 		bio = bio_copy_user_iov(q, map_data, iter, gfp_mask);
 	else
 		bio = bio_map_user_iov(q, iter, gfp_mask);
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
