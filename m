Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 0F67C6B00F6
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 14:17:41 -0400 (EDT)
From: "Eric W. Biederman" <ebiederm@xmission.com>
Date: Mon,  1 Jun 2009 14:50:34 -0700
Message-Id: <1243893048-17031-9-git-send-email-ebiederm@xmission.com>
In-Reply-To: <m1oct739xu.fsf@fess.ebiederm.org>
References: <m1oct739xu.fsf@fess.ebiederm.org>
Subject: [PATCH 09/23] vfs: Teach poll and select to use file_hotplug_lock
Sender: owner-linux-mm@kvack.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Tejun Heo <tj@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Greg Kroah-Hartman <gregkh@suse.de>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, "Eric W. Biederman" <ebiederm@maxwell.arastra.com>, "Eric W. Biederman" <ebiederm@aristanetworks.com>
List-ID: <linux-mm.kvack.org>

From: Eric W. Biederman <ebiederm@maxwell.arastra.com>

Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>
---
 fs/select.c          |   24 +++++++++++++++++-------
 include/linux/poll.h |    1 +
 2 files changed, 18 insertions(+), 7 deletions(-)

diff --git a/fs/select.c b/fs/select.c
index 99e4145..fd68da0 100644
--- a/fs/select.c
+++ b/fs/select.c
@@ -416,10 +416,15 @@ int do_select(int n, fd_set_bits *fds, struct timespec *end_time)
 					continue;
 				file = fget_light(i, &fput_needed);
 				if (file) {
-					f_op = file->f_op;
-					mask = DEFAULT_POLLMASK;
-					if (f_op && f_op->poll)
-						mask = (*f_op->poll)(file, retval ? NULL : wait);
+					mask = DEAD_POLLMASK;
+					if (file_hotplug_read_trylock(file)) {
+						f_op = file->f_op;
+						mask = DEFAULT_POLLMASK;
+						if (f_op && f_op->poll)
+							mask = (*f_op->poll)(file, retval ? NULL : wait);
+
+						file_hotplug_read_unlock(file);
+					}
 					fput_light(file, fput_needed);
 					if ((mask & POLLIN_SET) && (in & bit)) {
 						res_in |= bit;
@@ -684,9 +689,14 @@ static inline unsigned int do_pollfd(struct pollfd *pollfd, poll_table *pwait)
 		file = fget_light(fd, &fput_needed);
 		mask = POLLNVAL;
 		if (file != NULL) {
-			mask = DEFAULT_POLLMASK;
-			if (file->f_op && file->f_op->poll)
-				mask = file->f_op->poll(file, pwait);
+			mask = DEAD_POLLMASK;
+			if (file_hotplug_read_trylock(file)) {
+				mask = DEFAULT_POLLMASK;
+				if (file->f_op && file->f_op->poll)
+					mask = file->f_op->poll(file, pwait);
+
+				file_hotplug_read_unlock(file);
+			}
 			/* Mask out unneeded events. */
 			mask &= pollfd->events | POLLERR | POLLHUP;
 			fput_light(file, fput_needed);
diff --git a/include/linux/poll.h b/include/linux/poll.h
index d388620..f0512f4 100644
--- a/include/linux/poll.h
+++ b/include/linux/poll.h
@@ -22,6 +22,7 @@
 #define N_INLINE_POLL_ENTRIES	(WQUEUES_STACK_ALLOC / sizeof(struct poll_table_entry))
 
 #define DEFAULT_POLLMASK (POLLIN | POLLOUT | POLLRDNORM | POLLWRNORM)
+#define DEAD_POLLMASK (DEFAULT_POLLMASK | POLLERR)
 
 struct poll_table_struct;
 
-- 
1.6.3.1.54.g99dd.dirty

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
