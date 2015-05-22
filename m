Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f173.google.com (mail-qk0-f173.google.com [209.85.220.173])
	by kanga.kvack.org (Postfix) with ESMTP id B8E9E829CE
	for <linux-mm@kvack.org>; Fri, 22 May 2015 17:15:38 -0400 (EDT)
Received: by qkdn188 with SMTP id n188so22254603qkd.2
        for <linux-mm@kvack.org>; Fri, 22 May 2015 14:15:38 -0700 (PDT)
Received: from mail-qg0-x22b.google.com (mail-qg0-x22b.google.com. [2607:f8b0:400d:c04::22b])
        by mx.google.com with ESMTPS id h10si3722592qgf.29.2015.05.22.14.15.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 May 2015 14:15:38 -0700 (PDT)
Received: by qget53 with SMTP id t53so16193141qge.3
        for <linux-mm@kvack.org>; Fri, 22 May 2015 14:15:38 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 42/51] writeback: make wakeup_dirtytime_writeback() handle multiple bdi_writeback's
Date: Fri, 22 May 2015 17:13:56 -0400
Message-Id: <1432329245-5844-43-git-send-email-tj@kernel.org>
In-Reply-To: <1432329245-5844-1-git-send-email-tj@kernel.org>
References: <1432329245-5844-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru, Tejun Heo <tj@kernel.org>, Theodore Ts'o <tytso@mit.edu>

wakeup_dirtytime_writeback() currently only starts writeback on the
root wb (bdi_writeback).  For cgroup writeback support, update the
function to check all wbs.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Jan Kara <jack@suse.cz>
Cc: Theodore Ts'o <tytso@mit.edu>
---
 fs/fs-writeback.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 508e10c..8ae212e 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -1260,9 +1260,12 @@ static void wakeup_dirtytime_writeback(struct work_struct *w)
 
 	rcu_read_lock();
 	list_for_each_entry_rcu(bdi, &bdi_list, bdi_list) {
-		if (list_empty(&bdi->wb.b_dirty_time))
-			continue;
-		wb_wakeup(&bdi->wb);
+		struct bdi_writeback *wb;
+		struct wb_iter iter;
+
+		bdi_for_each_wb(wb, bdi, &iter, 0)
+			if (!list_empty(&bdi->wb.b_dirty_time))
+				wb_wakeup(&bdi->wb);
 	}
 	rcu_read_unlock();
 	schedule_delayed_work(&dirtytime_work, dirtytime_expire_interval * HZ);
-- 
2.4.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
