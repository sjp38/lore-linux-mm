Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id CEF7B6B00BC
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 14:17:40 -0400 (EDT)
From: "Eric W. Biederman" <ebiederm@xmission.com>
Date: Mon,  1 Jun 2009 14:50:27 -0700
Message-Id: <1243893048-17031-2-git-send-email-ebiederm@xmission.com>
In-Reply-To: <m1oct739xu.fsf@fess.ebiederm.org>
References: <m1oct739xu.fsf@fess.ebiederm.org>
Subject: [PATCH 02/23] vfs: Implement unpoll_file.
Sender: owner-linux-mm@kvack.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Tejun Heo <tj@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Greg Kroah-Hartman <gregkh@suse.de>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, "Eric W. Biederman" <ebiederm@maxwell.aristanetworks.com>, "Eric W. Biederman" <ebiederm@aristanetworks.com>
List-ID: <linux-mm.kvack.org>

From: Eric W. Biederman <ebiederm@maxwell.aristanetworks.com>

During a revoke operation it is necessary to stop using all state that is managed
by the underlying file operations implementation.  The poll wait queue is one part
of that state.

unpoll_file achieves that by walking through a specified waitqueue.  Finding
any entries that were added by select or poll of that file descriptor and
awakening them.  If action was taken unpoll sleeps and repeats until
the waitqueue has no entries for the spcified file.

Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>
---
 fs/select.c          |   31 +++++++++++++++++++++++++++++++
 include/linux/poll.h |    2 ++
 2 files changed, 33 insertions(+), 0 deletions(-)

diff --git a/fs/select.c b/fs/select.c
index 0fe0e14..bd30fe8 100644
--- a/fs/select.c
+++ b/fs/select.c
@@ -941,3 +941,34 @@ SYSCALL_DEFINE5(ppoll, struct pollfd __user *, ufds, unsigned int, nfds,
 	return ret;
 }
 #endif /* HAVE_SET_RESTORE_SIGMASK */
+
+#ifdef CONFIG_FILE_HOTPLUG
+static int unpoll_file_once(wait_queue_head_t *q, struct file *file)
+{
+	unsigned long flags;
+	wait_queue_t *curr, *next;
+	int found = 0;
+
+	spin_lock_irqsave(&q->lock, flags);
+	list_for_each_entry_safe(curr, next, &q->task_list, task_list) {
+		struct poll_table_entry *entry;
+		if (curr->func != pollwake)
+			continue;
+		entry = container_of(curr, struct poll_table_entry, wait);
+		if (entry->filp != file)
+			continue;
+		curr->func(curr, TASK_NORMAL, 0, NULL);
+		found = 1;
+	}
+	spin_unlock_irqrestore(&q->lock, flags);
+
+	return found;
+}
+
+void unpoll_file(wait_queue_head_t *q, struct file *file)
+{
+	while (unpoll_file_once(q, file))
+		schedule_timeout_uninterruptible(1);
+}
+EXPORT_SYMBOL(unpoll_file);
+#endif
diff --git a/include/linux/poll.h b/include/linux/poll.h
index 8c24ef8..d388620 100644
--- a/include/linux/poll.h
+++ b/include/linux/poll.h
@@ -131,6 +131,8 @@ extern int core_sys_select(int n, fd_set __user *inp, fd_set __user *outp,
 
 extern int poll_select_set_timeout(struct timespec *to, long sec, long nsec);
 
+extern void unpoll_file(wait_queue_head_t *q, struct file *file);
+
 #endif /* KERNEL */
 
 #endif /* _LINUX_POLL_H */
-- 
1.6.3.1.54.g99dd.dirty

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
