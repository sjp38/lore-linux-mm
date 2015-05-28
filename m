Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f182.google.com (mail-qk0-f182.google.com [209.85.220.182])
	by kanga.kvack.org (Postfix) with ESMTP id 69AA06B0075
	for <linux-mm@kvack.org>; Thu, 28 May 2015 14:51:17 -0400 (EDT)
Received: by qkhg32 with SMTP id g32so31837626qkh.0
        for <linux-mm@kvack.org>; Thu, 28 May 2015 11:51:17 -0700 (PDT)
Received: from mail-qg0-x229.google.com (mail-qg0-x229.google.com. [2607:f8b0:400d:c04::229])
        by mx.google.com with ESMTPS id e76si1347853qka.106.2015.05.28.11.51.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 May 2015 11:51:16 -0700 (PDT)
Received: by qgf2 with SMTP id 2so20488487qgf.3
        for <linux-mm@kvack.org>; Thu, 28 May 2015 11:51:16 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 9/9] writeback: disassociate inodes from dying bdi_writebacks
Date: Thu, 28 May 2015 14:50:57 -0400
Message-Id: <1432839057-17609-10-git-send-email-tj@kernel.org>
In-Reply-To: <1432839057-17609-1-git-send-email-tj@kernel.org>
References: <1432839057-17609-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru, Tejun Heo <tj@kernel.org>

For the purpose of foreign inode detection, wb's (bdi_writeback's) are
identified by the associated memcg ID.  As we create a separate wb for
each memcg, this is enough to identify the active wb's; however, when
blkcg is enabled or disabled higher up in the hierarchy, the mapping
between memcg and blkcg changes which in turn creates a new wb to
service the new mapping.  The old wb is unlinked from index and
released after all references are drained.  The foreign inode
detection logic can't detect this condition because both the old and
new wb's point to the same memcg and thus never decides to move inodes
attached to the old wb to the new one.

This patch adds logic to initiate switching immediately in
wbc_attach_and_unlock_inode() if the associated wb is dying.  We can
make the usual foreign detection logic to distinguish the different
wb's mapped to the memcg but the dying wb is never gonna be in active
service again and there's no point in tracking the usage history and
reaching the switch verdict after enough data points are collected.
It's already known that the wb has to be switched.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Jan Kara <jack@suse.cz>
Cc: Wu Fengguang <fengguang.wu@intel.com>
Cc: Greg Thelen <gthelen@google.com>
---
 fs/fs-writeback.c                |  7 +++++++
 include/linux/backing-dev-defs.h | 16 ++++++++++++++++
 2 files changed, 23 insertions(+)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 5eeb24a..f60de54 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -525,6 +525,13 @@ void wbc_attach_and_unlock_inode(struct writeback_control *wbc,
 
 	wb_get(wbc->wb);
 	spin_unlock(&inode->i_lock);
+
+	/*
+	 * A dying wb indicates that the memcg-blkcg mapping has changed
+	 * and a new wb is already serving the memcg.  Switch immediately.
+	 */
+	if (unlikely(wb_dying(wbc->wb)))
+		inode_switch_wbs(inode, wbc->wb_id);
 }
 
 /**
diff --git a/include/linux/backing-dev-defs.h b/include/linux/backing-dev-defs.h
index e047b49..a48d90e 100644
--- a/include/linux/backing-dev-defs.h
+++ b/include/linux/backing-dev-defs.h
@@ -219,6 +219,17 @@ static inline void wb_put(struct bdi_writeback *wb)
 		percpu_ref_put(&wb->refcnt);
 }
 
+/**
+ * wb_dying - is a wb dying?
+ * @wb: bdi_writeback of interest
+ *
+ * Returns whether @wb is unlinked and being drained.
+ */
+static inline bool wb_dying(struct bdi_writeback *wb)
+{
+	return percpu_ref_is_dying(&wb->refcnt);
+}
+
 #else	/* CONFIG_CGROUP_WRITEBACK */
 
 static inline bool wb_tryget(struct bdi_writeback *wb)
@@ -234,6 +245,11 @@ static inline void wb_put(struct bdi_writeback *wb)
 {
 }
 
+static inline bool wb_dying(struct bdi_writeback *wb)
+{
+	return false;
+}
+
 #endif	/* CONFIG_CGROUP_WRITEBACK */
 
 #endif	/* __LINUX_BACKING_DEV_DEFS_H */
-- 
2.4.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
