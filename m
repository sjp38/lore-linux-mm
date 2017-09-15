Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 35F1C6B0038
	for <linux-mm@kvack.org>; Fri, 15 Sep 2017 14:27:20 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id d8so5924439pgt.1
        for <linux-mm@kvack.org>; Fri, 15 Sep 2017 11:27:20 -0700 (PDT)
Received: from BJEXCAS008.didichuxing.com (mx1.didichuxing.com. [111.202.154.82])
        by mx.google.com with ESMTPS id w22si966846pge.598.2017.09.15.11.27.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 15 Sep 2017 11:27:18 -0700 (PDT)
Date: Sat, 16 Sep 2017 02:27:05 +0800
From: weiping zhang <zhangweiping@didichuxing.com>
Subject: [PATCH] bdi: fix cleanup when fail to percpu_counter_init
Message-ID: <20170915182700.GA2489@localhost.didichuxing.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@fb.com, jack@suse.cz, tj@kernel.org
Cc: linux-mm@kvack.org

when percpu_counter_init fail at i, 0 ~ (i-1) should be destoried, not
1 ~ i.

Signed-off-by: weiping zhang <zhangweiping@didichuxing.com>
---
 mm/backing-dev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index e19606b..d399d3c 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -334,7 +334,7 @@ static int wb_init(struct bdi_writeback *wb, struct backing_dev_info *bdi,
 	return 0;
 
 out_destroy_stat:
-	while (i--)
+	while (--i >= 0)
 		percpu_counter_destroy(&wb->stat[i]);
 	fprop_local_destroy_percpu(&wb->completions);
 out_put_cong:
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
