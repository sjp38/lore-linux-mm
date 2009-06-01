Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 7E8616B00FD
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 14:17:44 -0400 (EDT)
From: "Eric W. Biederman" <ebiederm@xmission.com>
Date: Mon,  1 Jun 2009 14:50:43 -0700
Message-Id: <1243893048-17031-18-git-send-email-ebiederm@xmission.com>
In-Reply-To: <m1oct739xu.fsf@fess.ebiederm.org>
References: <m1oct739xu.fsf@fess.ebiederm.org>
Subject: [PATCH 18/23] vfs: Teach epoll to use file_hotplug_lock
Sender: owner-linux-mm@kvack.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Tejun Heo <tj@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Greg Kroah-Hartman <gregkh@suse.de>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, "Eric W. Biederman" <ebiederm@maxwell.aristanetworks.com>, "Eric W. Biederman" <ebiederm@aristanetworks.com>
List-ID: <linux-mm.kvack.org>

From: Eric W. Biederman <ebiederm@maxwell.aristanetworks.com>

Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>
---
 fs/eventpoll.c |   39 ++++++++++++++++++++++++++++++++-------
 1 files changed, 32 insertions(+), 7 deletions(-)

diff --git a/fs/eventpoll.c b/fs/eventpoll.c
index a89f370..eabb167 100644
--- a/fs/eventpoll.c
+++ b/fs/eventpoll.c
@@ -627,8 +627,13 @@ static int ep_read_events_proc(struct eventpoll *ep, struct list_head *head,
 	struct epitem *epi, *tmp;
 
 	list_for_each_entry_safe(epi, tmp, head, rdllink) {
-		if (epi->ffd.file->f_op->poll(epi->ffd.file, NULL) &
-		    epi->event.events)
+		int events = DEAD_POLLMASK;
+		
+		if (file_hotplug_read_trylock(epi->ffd.file)) {
+			events = epi->ffd.file->f_op->poll(epi->ffd.file, NULL);
+			file_hotplug_read_unlock(epi->ffd.file);
+		}
+		if (events & epi->event.events)
 			return POLLIN | POLLRDNORM;
 		else {
 			/*
@@ -1060,8 +1065,12 @@ static int ep_send_events_proc(struct eventpoll *ep, struct list_head *head,
 
 		list_del_init(&epi->rdllink);
 
-		revents = epi->ffd.file->f_op->poll(epi->ffd.file, NULL) &
-			epi->event.events;
+		revents = DEAD_POLLMASK;
+		if (file_hotplug_read_trylock(epi->ffd.file)) {
+			revents = epi->ffd.file->f_op->poll(epi->ffd.file, NULL);
+			file_hotplug_read_unlock(epi->ffd.file);
+		}
+		revents &= epi->event.events;
 
 		/*
 		 * If the event mask intersect the caller-requested one,
@@ -1248,10 +1257,17 @@ SYSCALL_DEFINE4(epoll_ctl, int, epfd, int, op, int, fd,
 	if (!tfile)
 		goto error_fput;
 
+	error = -EIO;
+	if (!file_hotplug_read_trylock(file))
+		goto error_tgt_fput;
+
+	if (!file_hotplug_read_trylock(tfile))
+		goto error_file_unlock;
+
 	/* The target file descriptor must support poll */
 	error = -EPERM;
 	if (!tfile->f_op || !tfile->f_op->poll)
-		goto error_tgt_fput;
+		goto error_tgt_unlock;
 
 	/*
 	 * We have to check that the file structure underneath the file descriptor
@@ -1260,7 +1276,7 @@ SYSCALL_DEFINE4(epoll_ctl, int, epfd, int, op, int, fd,
 	 */
 	error = -EINVAL;
 	if (file == tfile || !is_file_epoll(file))
-		goto error_tgt_fput;
+		goto error_tgt_unlock;
 
 	/*
 	 * At this point it is safe to assume that the "private_data" contains
@@ -1302,6 +1318,10 @@ SYSCALL_DEFINE4(epoll_ctl, int, epfd, int, op, int, fd,
 	}
 	mutex_unlock(&ep->mtx);
 
+error_tgt_unlock:
+	file_hotplug_read_unlock(tfile);
+error_file_unlock:
+	file_hotplug_read_unlock(file);
 error_tgt_fput:
 	fput(tfile);
 error_fput:
@@ -1338,13 +1358,16 @@ SYSCALL_DEFINE4(epoll_wait, int, epfd, struct epoll_event __user *, events,
 	if (!file)
 		goto error_return;
 
+	error = -EIO;
+	if (!file_hotplug_read_trylock(file))
+		goto error_fput;
 	/*
 	 * We have to check that the file structure underneath the fd
 	 * the user passed to us _is_ an eventpoll file.
 	 */
 	error = -EINVAL;
 	if (!is_file_epoll(file))
-		goto error_fput;
+		goto error_unlock;
 
 	/*
 	 * At this point it is safe to assume that the "private_data" contains
@@ -1355,6 +1378,8 @@ SYSCALL_DEFINE4(epoll_wait, int, epfd, struct epoll_event __user *, events,
 	/* Time to fish for events ... */
 	error = ep_poll(ep, events, maxevents, timeout);
 
+error_unlock:
+	file_hotplug_read_unlock(file);
 error_fput:
 	fput(file);
 error_return:
-- 
1.6.3.1.54.g99dd.dirty

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
