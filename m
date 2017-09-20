Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 08DED6B0260
	for <linux-mm@kvack.org>; Wed, 20 Sep 2017 11:33:21 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id v140so4538756ita.3
        for <linux-mm@kvack.org>; Wed, 20 Sep 2017 08:33:21 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id c3sor884298iob.47.2017.09.20.08.33.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Sep 2017 08:33:20 -0700 (PDT)
From: Jens Axboe <axboe@kernel.dk>
Subject: [PATCH 1/7] buffer: cleanup free_more_memory() flusher wakeup
Date: Wed, 20 Sep 2017 09:32:56 -0600
Message-Id: <1505921582-26709-2-git-send-email-axboe@kernel.dk>
In-Reply-To: <1505921582-26709-1-git-send-email-axboe@kernel.dk>
References: <1505921582-26709-1-git-send-email-axboe@kernel.dk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Cc: hannes@cmpxchg.org, clm@fb.com, jack@suse.cz, Jens Axboe <axboe@kernel.dk>

This whole function is... interesting. Change the wakeup call
to the flusher threads to pass in nr_pages == 0, instead of
some random number of pages. This matches more closely what
similar cases do for memory shortage/reclaim.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Tested-by: Chris Mason <clm@fb.com>
Reviewed-by: Jan Kara <jack@suse.cz>
Signed-off-by: Jens Axboe <axboe@kernel.dk>
---
 fs/buffer.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/buffer.c b/fs/buffer.c
index 170df856bdb9..9471a445e370 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -260,7 +260,7 @@ static void free_more_memory(void)
 	struct zoneref *z;
 	int nid;
 
-	wakeup_flusher_threads(1024, WB_REASON_FREE_MORE_MEM);
+	wakeup_flusher_threads(0, WB_REASON_FREE_MORE_MEM);
 	yield();
 
 	for_each_online_node(nid) {
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
