Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 47FE46B0277
	for <linux-mm@kvack.org>; Fri, 13 Oct 2017 20:52:27 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id n89so3943153pfk.17
        for <linux-mm@kvack.org>; Fri, 13 Oct 2017 17:52:27 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a91sor148134pla.112.2017.10.13.17.52.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 13 Oct 2017 17:52:26 -0700 (PDT)
From: Yafang Shao <laoar.shao@gmail.com>
Subject: [PATCH for linux-next] mm/page-writeback.c: make changes of dirty_writeback_centisecs take effect immediately
Date: Sat, 14 Oct 2017 16:38:27 +0800
Message-Id: <1507970307-16431-1-git-send-email-laoar.shao@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk, akpm@linux-foundation.org
Cc: jack@suse.cz, hannes@cmpxchg.org, vdavydov.dev@gmail.com, jlayton@redhat.com, nborisov@suse.com, tytso@mit.edu, yamada.masahiro@socionext.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, laoar.shao@gmail.com

This patch is the followup of the prvious patch:
[writeback: schedule periodic writeback with sysctl].

There's another issue to fix.
For example,
- When the tunable was set to one hour and is reset to one second, the
  new setting will not take effect for up to one hour.

Kicking the flusher threads immediately fixes it.

Cc: Jens Axboe <axboe@kernel.dk>
Cc: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
---
 mm/page-writeback.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 3969e69..768fe4e 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -1978,7 +1978,16 @@ int dirty_writeback_centisecs_handler(struct ctl_table *table, int write,
 	int ret;
 
 	ret = proc_dointvec(table, write, buffer, length, ppos);
-	if (!ret && !old_interval && dirty_writeback_interval)
+
+	/*
+	 * Writing 0 to dirty_writeback_interval will disable periodic writeback
+	 * and a different non-zero value will wakeup the writeback threads.
+	 * wb_wakeup_delayed() would be more appropriate, but it's a pain to
+	 * iterate over all bdis and wbs.
+	 * The reason we do this is to make the change take effect immediately.
+	 */
+	if (!ret && write && dirty_writeback_interval &&
+		dirty_writeback_interval != old_interval)
 		wakeup_flusher_threads(WB_REASON_PERIODIC);
 
 	return ret;
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
