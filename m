Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9E16F6B025F
	for <linux-mm@kvack.org>; Fri, 13 Oct 2017 05:10:05 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id k80so7606022pfj.18
        for <linux-mm@kvack.org>; Fri, 13 Oct 2017 02:10:05 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b34sor263258pld.12.2017.10.13.02.10.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 13 Oct 2017 02:10:04 -0700 (PDT)
From: Yafang Shao <laoar.shao@gmail.com>
Subject: [PATCH resend] mm/page-writeback.c: make changes of dirty_writeback_centisecs take effect immediately
Date: Sat, 14 Oct 2017 00:56:17 +0800
Message-Id: <1507913777-14799-1-git-send-email-laoar.shao@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: jack@suse.cz, hannes@cmpxchg.org, vdavydov.dev@gmail.com, jlayton@redhat.com, nborisov@suse.com, tytso@mit.edu, yamada.masahiro@socionext.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, laoar.shao@gmail.com

Two problems with /proc/sys/vm/dirty_writeback_centisecs:

- When the tunable is set to 0 (disable), writing a non-zero value
  doesn't restart the flushing operations until the dirty background limit
  is reached or sys_sync is executed or not enough free memory is
  available or vmscan is triggered.

- When the tunable was set to one hour and is reset to one second, the
  new setting will not take effect for up to one hour.

Kicking the flusher threads immediately fixes these issues.

Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
---
 mm/page-writeback.c | 19 +++++++++++++++++--
 1 file changed, 17 insertions(+), 2 deletions(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 0b9c5cb..4e7e739 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -1972,8 +1972,23 @@ bool wb_over_bg_thresh(struct bdi_writeback *wb)
 int dirty_writeback_centisecs_handler(struct ctl_table *table, int write,
 	void __user *buffer, size_t *length, loff_t *ppos)
 {
-	proc_dointvec(table, write, buffer, length, ppos);
-	return 0;
+	unsigned int old_interval = dirty_writeback_interval;
+	int ret;
+
+	ret = proc_dointvec(table, write, buffer, length, ppos);
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
+		wakeup_flusher_threads(0, WB_REASON_PERIODIC);
+
+	return ret;
 }
 
 #ifdef CONFIG_BLOCK
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
