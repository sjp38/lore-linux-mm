Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id A04B66B007E
	for <linux-mm@kvack.org>; Thu, 31 Mar 2016 09:20:44 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id zm5so66639103pac.0
        for <linux-mm@kvack.org>; Thu, 31 Mar 2016 06:20:44 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id d3si14131615pas.116.2016.03.31.06.20.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 31 Mar 2016 06:20:43 -0700 (PDT)
From: Kaixu Xia <xiakaixu@huawei.com>
Subject: [PATCH] writeback: fix the wrong congested state variable definition
Date: Thu, 31 Mar 2016 13:19:41 +0000
Message-ID: <1459430381-13947-1-git-send-email-xiakaixu@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tj@kernel.org, axboe@kernel.dk
Cc: lizefan@huawei.com, jack@suse.cz, linux-mm@kvack.org, akpm@linux-foundation.org, mhocko@suse.com, neilb@suse.de, linux-kernel@vger.kernel.org, xiakaixu@huawei.com

The right variable definition should be wb_congested_state that
include WB_async_congested and WB_sync_congested. So fix it.

Signed-off-by: Kaixu Xia <xiakaixu@huawei.com>
---
 mm/backing-dev.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index bfbd709..0c6317b 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -898,7 +898,7 @@ static atomic_t nr_wb_congested[2];
 void clear_wb_congested(struct bdi_writeback_congested *congested, int sync)
 {
 	wait_queue_head_t *wqh = &congestion_wqh[sync];
-	enum wb_state bit;
+	enum wb_congested_state bit;
 
 	bit = sync ? WB_sync_congested : WB_async_congested;
 	if (test_and_clear_bit(bit, &congested->state))
@@ -911,7 +911,7 @@ EXPORT_SYMBOL(clear_wb_congested);
 
 void set_wb_congested(struct bdi_writeback_congested *congested, int sync)
 {
-	enum wb_state bit;
+	enum wb_congested_state bit;
 
 	bit = sync ? WB_sync_congested : WB_async_congested;
 	if (!test_and_set_bit(bit, &congested->state))
-- 
1.8.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
