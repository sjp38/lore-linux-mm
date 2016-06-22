Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id B326A6B0005
	for <linux-mm@kvack.org>; Wed, 22 Jun 2016 07:23:16 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id c127so119205345vkb.1
        for <linux-mm@kvack.org>; Wed, 22 Jun 2016 04:23:16 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v5si5688189qki.15.2016.06.22.04.23.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Jun 2016 04:23:15 -0700 (PDT)
From: Brian Foster <bfoster@redhat.com>
Subject: [PATCH v8 2/2] wb: inode writeback list tracking tracepoints
Date: Wed, 22 Jun 2016 07:23:13 -0400
Message-Id: <1466594593-6757-3-git-send-email-bfoster@redhat.com>
In-Reply-To: <1466594593-6757-1-git-send-email-bfoster@redhat.com>
References: <1466594593-6757-1-git-send-email-bfoster@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Cc: Al Viro <viro@ZenIV.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <dchinner@redhat.com>, Josef Bacik <jbacik@fb.com>, Jan Kara <jack@suse.cz>, Holger Hoffstatte <holger.hoffstaette@applied-asynchrony.com>

The per-sb inode writeback list tracks inodes currently under writeback
to facilitate efficient sync processing. In particular, it ensures that
sync only needs to walk through a list of inodes that were cleaned by
the sync.

Add a couple tracepoints to help identify when inodes are added/removed
to and from the writeback lists. Piggyback off of the writeback lazytime
tracepoint template as it already tracks the relevant inode information.

Signed-off-by: Brian Foster <bfoster@redhat.com>
Reviewed-by: Jan Kara <jack@suse.cz>
---
 fs/fs-writeback.c                |  9 +++++++--
 include/trace/events/writeback.h | 22 ++++++++++++++++++----
 2 files changed, 25 insertions(+), 6 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 9dbf4d1..e21d20b 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -990,8 +990,10 @@ void sb_mark_inode_writeback(struct inode *inode)
 
 	if (list_empty(&inode->i_wb_list)) {
 		spin_lock_irqsave(&sb->s_inode_wblist_lock, flags);
-		if (list_empty(&inode->i_wb_list))
+		if (list_empty(&inode->i_wb_list)) {
 			list_add_tail(&inode->i_wb_list, &sb->s_inodes_wb);
+			trace_sb_mark_inode_writeback(inode);
+		}
 		spin_unlock_irqrestore(&sb->s_inode_wblist_lock, flags);
 	}
 }
@@ -1006,7 +1008,10 @@ void sb_clear_inode_writeback(struct inode *inode)
 
 	if (!list_empty(&inode->i_wb_list)) {
 		spin_lock_irqsave(&sb->s_inode_wblist_lock, flags);
-		list_del_init(&inode->i_wb_list);
+		if (!list_empty(&inode->i_wb_list)) {
+			list_del_init(&inode->i_wb_list);
+			trace_sb_clear_inode_writeback(inode);
+		}
 		spin_unlock_irqrestore(&sb->s_inode_wblist_lock, flags);
 	}
 }
diff --git a/include/trace/events/writeback.h b/include/trace/events/writeback.h
index 73614ce..531f581 100644
--- a/include/trace/events/writeback.h
+++ b/include/trace/events/writeback.h
@@ -696,7 +696,7 @@ DEFINE_EVENT(writeback_single_inode_template, writeback_single_inode,
 	TP_ARGS(inode, wbc, nr_to_write)
 );
 
-DECLARE_EVENT_CLASS(writeback_lazytime_template,
+DECLARE_EVENT_CLASS(writeback_inode_template,
 	TP_PROTO(struct inode *inode),
 
 	TP_ARGS(inode),
@@ -723,25 +723,39 @@ DECLARE_EVENT_CLASS(writeback_lazytime_template,
 		  show_inode_state(__entry->state), __entry->mode)
 );
 
-DEFINE_EVENT(writeback_lazytime_template, writeback_lazytime,
+DEFINE_EVENT(writeback_inode_template, writeback_lazytime,
 	TP_PROTO(struct inode *inode),
 
 	TP_ARGS(inode)
 );
 
-DEFINE_EVENT(writeback_lazytime_template, writeback_lazytime_iput,
+DEFINE_EVENT(writeback_inode_template, writeback_lazytime_iput,
 	TP_PROTO(struct inode *inode),
 
 	TP_ARGS(inode)
 );
 
-DEFINE_EVENT(writeback_lazytime_template, writeback_dirty_inode_enqueue,
+DEFINE_EVENT(writeback_inode_template, writeback_dirty_inode_enqueue,
 
 	TP_PROTO(struct inode *inode),
 
 	TP_ARGS(inode)
 );
 
+/*
+ * Inode writeback list tracking.
+ */
+
+DEFINE_EVENT(writeback_inode_template, sb_mark_inode_writeback,
+	TP_PROTO(struct inode *inode),
+	TP_ARGS(inode)
+);
+
+DEFINE_EVENT(writeback_inode_template, sb_clear_inode_writeback,
+	TP_PROTO(struct inode *inode),
+	TP_ARGS(inode)
+);
+
 #endif /* _TRACE_WRITEBACK_H */
 
 /* This part must be outside protection */
-- 
2.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
