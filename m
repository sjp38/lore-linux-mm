Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id A66646B0055
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 14:44:27 -0400 (EDT)
From: "Eric W. Biederman" <ebiederm@xmission.com>
Date: Mon,  1 Jun 2009 14:50:42 -0700
Message-Id: <1243893048-17031-17-git-send-email-ebiederm@xmission.com>
In-Reply-To: <m1oct739xu.fsf@fess.ebiederm.org>
References: <m1oct739xu.fsf@fess.ebiederm.org>
Subject: [PATCH 17/23] proc: Teach /proc/<pid>/fd to use file_hotplug_lock
Sender: owner-linux-mm@kvack.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Tejun Heo <tj@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Greg Kroah-Hartman <gregkh@suse.de>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, "Eric W. Biederman" <ebiederm@maxwell.arastra.com>, "Eric W. Biederman" <ebiederm@aristanetworks.com>
List-ID: <linux-mm.kvack.org>

From: Eric W. Biederman <ebiederm@maxwell.arastra.com>

I have taken the opportunity to modify proc_fd_info to have
a single exit point.

Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>
---
 fs/proc/base.c |   29 ++++++++++++++++-------------
 1 files changed, 16 insertions(+), 13 deletions(-)

diff --git a/fs/proc/base.c b/fs/proc/base.c
index fb45615..ee4cdc2 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -1626,6 +1626,7 @@ static int proc_fd_info(struct inode *inode, struct path *path, char *info)
 	struct files_struct *files = NULL;
 	struct file *file;
 	int fd = proc_fd(inode);
+	int retval = -ENOENT;
 
 	if (task) {
 		files = get_files_struct(task);
@@ -1639,24 +1640,26 @@ static int proc_fd_info(struct inode *inode, struct path *path, char *info)
 		spin_lock(&files->file_lock);
 		file = fcheck_files(files, fd);
 		if (file) {
-			if (path) {
-				*path = file->f_path;
-				path_get(&file->f_path);
+			retval = -EIO;
+			if (file_hotplug_read_trylock(file)) {
+				retval = 0;
+				if (path) {
+					*path = file->f_path;
+					path_get(&file->f_path);
+				}
+				if (info)
+					snprintf(info, PROC_FDINFO_MAX,
+						"pos:\t%lli\n"
+						"flags:\t0%o\n",
+						(long long) file->f_pos,
+						file->f_flags);
+				file_hotplug_read_unlock(file);
 			}
-			if (info)
-				snprintf(info, PROC_FDINFO_MAX,
-					 "pos:\t%lli\n"
-					 "flags:\t0%o\n",
-					 (long long) file->f_pos,
-					 file->f_flags);
-			spin_unlock(&files->file_lock);
-			put_files_struct(files);
-			return 0;
 		}
 		spin_unlock(&files->file_lock);
 		put_files_struct(files);
 	}
-	return -ENOENT;
+	return retval;
 }
 
 static int proc_fd_link(struct inode *inode, struct path *path)
-- 
1.6.3.1.54.g99dd.dirty

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
