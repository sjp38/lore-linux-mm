Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8AD696B005C
	for <linux-mm@kvack.org>; Wed, 14 Jan 2009 15:24:04 -0500 (EST)
Subject: [PATCH RFC] Lost wakeups from lock_page_killable()
From: Chris Mason <chris.mason@oracle.com>
Content-Type: text/plain
Date: Wed, 14 Jan 2009 15:23:52 -0500
Message-Id: <1231964632.8269.47.camel@think.oraclecorp.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Matthew Wilcox <matthew@wil.cx>, "chuck.lever" <chuck.lever@oracle.com>
List-ID: <linux-mm.kvack.org>

Chuck has been debugging a problem with NFS mounts where procs are
getting stuck waiting on the page lock.  He did a bunch of work around
tracking the last person to lock the page and then printing out the page
state when it found stuck procs.

The end result showed that procs were waiting to lock pages that were
not actually locked.  The workload involved a well known commercial
database that was being shutdown via sql shutdown abort

After trying to blame NFS for a really long time I think
lock_page_killable may be the cause.

lock_page and lock_page_killable both call __wait_on_bit_lock, and so
both end up using prepare_to_wait_exclusive().  This means that when
someone does finally unlock the page, only one process is going to get
woken up.

So, procA holding the page lock, procB and procC are waiting on the
lock.

procA: lock_page() // success
procB: lock_page_killable(), sync_page_killable(), io_schedule()
procC: lock_page_killable(), sync_page_killable(), io_schedule()

procA: unlock, wake_up_page(page, PG_locked)
procA: wake up procB

happy admin: kill procB

procB: wakes into sync_page_killable(), notices the signal and returns
-EINTR

procB: __wait_on_bit_lock sees the action() func returns < 0 and does
not take the page lock

procB: lock_page_killable() returns < 0 and exits happily.

procC: sleeping in io_schedule() forever unless someone else locks the
page.

The patch below is entirely untested but may do a better job of
explaining what I think the bug is.  I'm hoping I can trigger it locally
with a few dd commands mixed with a lot of kill commands.

-chris

diff --git a/mm/filemap.c b/mm/filemap.c
index ceba0bd..e1184fa 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -623,9 +623,20 @@ EXPORT_SYMBOL(__lock_page);
 int __lock_page_killable(struct page *page)
 {
 	DEFINE_WAIT_BIT(wait, &page->flags, PG_locked);
+	int ret;
 
-	return __wait_on_bit_lock(page_waitqueue(page), &wait,
+	ret = __wait_on_bit_lock(page_waitqueue(page), &wait,
 					sync_page_killable, TASK_KILLABLE);
+	/*
+	 * wait_on_bit_lock uses prepare_to_wait_exclusive, so if multiple
+	 * procs were waiting on this page, we were the only proc woken up.
+	 *
+	 * if ret != 0, we didn't actually get the lock.  We need to
+	 * make sure any other waiters don't sleep forever.
+	 */
+	if (ret)
+		wake_up_page(page, PG_locked);
+	return ret;
 }
 
 /**


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
