Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 9DDD35F001F
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 14:17:43 -0400 (EDT)
From: "Eric W. Biederman" <ebiederm@xmission.com>
Date: Mon,  1 Jun 2009 14:50:38 -0700
Message-Id: <1243893048-17031-13-git-send-email-ebiederm@xmission.com>
In-Reply-To: <m1oct739xu.fsf@fess.ebiederm.org>
References: <m1oct739xu.fsf@fess.ebiederm.org>
Subject: [PATCH 13/23] vfs: Teach ioctl to use file_hotplug_lock
Sender: owner-linux-mm@kvack.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Tejun Heo <tj@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Greg Kroah-Hartman <gregkh@suse.de>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, "Eric W. Biederman" <ebiederm@maxwell.arastra.com>, "Eric W. Biederman" <ebiederm@aristanetworks.com>
List-ID: <linux-mm.kvack.org>

From: Eric W. Biederman <ebiederm@maxwell.arastra.com>

Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>
---
 fs/compat_ioctl.c |   14 ++++++++++----
 fs/ioctl.c        |    8 +++++++-
 2 files changed, 17 insertions(+), 5 deletions(-)

diff --git a/fs/compat_ioctl.c b/fs/compat_ioctl.c
index b83f6bc..fa654c5 100644
--- a/fs/compat_ioctl.c
+++ b/fs/compat_ioctl.c
@@ -2796,10 +2796,14 @@ asmlinkage long compat_sys_ioctl(unsigned int fd, unsigned int cmd,
 	if (!filp)
 		goto out;
 
+	error = -EIO;
+	if (!file_hotplug_read_trylock(filp))
+		goto out_fput;
+
 	/* RED-PEN how should LSM module know it's handling 32bit? */
 	error = security_file_ioctl(filp, cmd, arg);
 	if (error)
-		goto out_fput;
+		goto out_unlock;
 
 	/*
 	 * To allow the compat_ioctl handlers to be self contained
@@ -2825,7 +2829,7 @@ asmlinkage long compat_sys_ioctl(unsigned int fd, unsigned int cmd,
 		if (filp->f_op && filp->f_op->compat_ioctl) {
 			error = filp->f_op->compat_ioctl(filp, cmd, arg);
 			if (error != -ENOIOCTLCMD)
-				goto out_fput;
+				goto out_unlock;
 		}
 
 		if (!filp->f_op ||
@@ -2853,18 +2857,20 @@ asmlinkage long compat_sys_ioctl(unsigned int fd, unsigned int cmd,
 		error = -EINVAL;
 	}
 
-	goto out_fput;
+	goto out_unlock;
 
  found_handler:
 	if (t->handler) {
 		lock_kernel();
 		error = t->handler(fd, cmd, arg, filp);
 		unlock_kernel();
-		goto out_fput;
+		goto out_unlock;
 	}
 
  do_ioctl:
 	error = do_vfs_ioctl(filp, fd, cmd, arg);
+ out_unlock:
+	file_hotplug_read_unlock(filp);
  out_fput:
 	fput_light(filp, fput_needed);
  out:
diff --git a/fs/ioctl.c b/fs/ioctl.c
index 82d9c42..2dad7ba 100644
--- a/fs/ioctl.c
+++ b/fs/ioctl.c
@@ -577,11 +577,17 @@ SYSCALL_DEFINE3(ioctl, unsigned int, fd, unsigned int, cmd, unsigned long, arg)
 	if (!filp)
 		goto out;
 
+	error = -EIO;
+	if (!file_hotplug_read_trylock(filp))
+		goto out_fput;
+
 	error = security_file_ioctl(filp, cmd, arg);
 	if (error)
-		goto out_fput;
+		goto out_unlock;
 
 	error = do_vfs_ioctl(filp, fd, cmd, arg);
+ out_unlock:
+	file_hotplug_read_unlock(filp);
  out_fput:
 	fput_light(filp, fput_needed);
  out:
-- 
1.6.3.1.54.g99dd.dirty

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
