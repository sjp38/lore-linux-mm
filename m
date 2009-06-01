Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id C77B36B00D4
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 11:40:06 -0400 (EDT)
From: "Eric W. Biederman" <ebiederm@xmission.com>
Date: Mon,  1 Jun 2009 14:50:37 -0700
Message-Id: <1243893048-17031-12-git-send-email-ebiederm@xmission.com>
In-Reply-To: <m1oct739xu.fsf@fess.ebiederm.org>
References: <m1oct739xu.fsf@fess.ebiederm.org>
Subject: [PATCH 12/23] vfs: Teach fcntl to use file_hotplug_lock
Sender: owner-linux-mm@kvack.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Tejun Heo <tj@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Greg Kroah-Hartman <gregkh@suse.de>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, "Eric W. Biederman" <ebiederm@maxwell.arastra.com>, "Eric W. Biederman" <ebiederm@aristanetworks.com>
List-ID: <linux-mm.kvack.org>

From: Eric W. Biederman <ebiederm@maxwell.arastra.com>

Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>
---
 fs/fcntl.c |   28 +++++++++++++++++++---------
 1 files changed, 19 insertions(+), 9 deletions(-)

diff --git a/fs/fcntl.c b/fs/fcntl.c
index cc8e4de..05d8961 100644
--- a/fs/fcntl.c
+++ b/fs/fcntl.c
@@ -344,14 +344,19 @@ SYSCALL_DEFINE3(fcntl, unsigned int, fd, unsigned int, cmd, unsigned long, arg)
 	if (!filp)
 		goto out;
 
+	err = -EIO;
+	if (!file_hotplug_read_trylock(filp))
+		goto out_fput;
+
 	err = security_file_fcntl(filp, cmd, arg);
-	if (err) {
-		fput(filp);
-		return err;
-	}
+	if (err)
+		goto out_unlock;
 
 	err = do_fcntl(fd, cmd, arg, filp);
 
+out_unlock:
+	file_hotplug_read_unlock(filp);
+out_fput:
  	fput(filp);
 out:
 	return err;
@@ -369,13 +374,15 @@ SYSCALL_DEFINE3(fcntl64, unsigned int, fd, unsigned int, cmd,
 	if (!filp)
 		goto out;
 
+	err = -EIO;
+	if (!file_hotplug_read_trylock(filp))
+		goto out_fput;
+
 	err = security_file_fcntl(filp, cmd, arg);
-	if (err) {
-		fput(filp);
-		return err;
-	}
+	if (err)
+		goto out_unlock;
+
 	err = -EBADF;
-	
 	switch (cmd) {
 		case F_GETLK64:
 			err = fcntl_getlk64(filp, (struct flock64 __user *) arg);
@@ -389,6 +396,9 @@ SYSCALL_DEFINE3(fcntl64, unsigned int, fd, unsigned int, cmd,
 			err = do_fcntl(fd, cmd, arg, filp);
 			break;
 	}
+out_unlock:
+	file_hotplug_read_unlock(filp);
+out_fput:
 	fput(filp);
 out:
 	return err;
-- 
1.6.3.1.54.g99dd.dirty

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
