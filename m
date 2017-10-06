Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8B0DE6B0033
	for <linux-mm@kvack.org>; Fri,  6 Oct 2017 11:11:48 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id l188so25413346pfc.7
        for <linux-mm@kvack.org>; Fri, 06 Oct 2017 08:11:48 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n66sor329847pfa.135.2017.10.06.08.11.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 06 Oct 2017 08:11:47 -0700 (PDT)
From: Yafang Shao <laoar.shao@gmail.com>
Subject: [PATCH] mm/page-writeback.c: fix bug caused by disable periodic writeback
Date: Sat,  7 Oct 2017 06:58:04 +0800
Message-Id: <1507330684-2205-1-git-send-email-laoar.shao@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, jack@suse.cz, mhocko@suse.com, hannes@cmpxchg.org, vdavydov.dev@gmail.com, jlayton@redhat.com, nborisov@suse.com, tytso@mit.edu, mawilcox@microsoft.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, laoar.shao@gmail.com

After disable periodic writeback by writing 0 to
dirty_writeback_centisecs, the handler wb_workfn() will not be
entered again until the dirty background limit reaches or
sync syscall is executed or no enough free memory available or
vmscan is triggered.
So the periodic writeback can't be enabled by writing a non-zero
value to dirty_writeback_centisecs
As it can be disabled by sysctl, it should be able to enable by 
sysctl as well.

Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
---
 mm/page-writeback.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 0b9c5cb..e202f37 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -1972,7 +1972,13 @@ bool wb_over_bg_thresh(struct bdi_writeback *wb)
 int dirty_writeback_centisecs_handler(struct ctl_table *table, int write,
 	void __user *buffer, size_t *length, loff_t *ppos)
 {
-	proc_dointvec(table, write, buffer, length, ppos);
+	unsigned int old_interval = dirty_writeback_interval;
+	int ret;
+
+	ret = proc_dointvec(table, write, buffer, length, ppos);
+	if (!ret && !old_interval && dirty_writeback_interval)
+		wakeup_flusher_threads(0, WB_REASON_PERIODIC);
+
 	return 0;
 }
 
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
