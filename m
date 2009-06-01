Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 8DFF46B00C2
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 14:17:42 -0400 (EDT)
From: "Eric W. Biederman" <ebiederm@xmission.com>
Date: Mon,  1 Jun 2009 14:50:30 -0700
Message-Id: <1243893048-17031-5-git-send-email-ebiederm@xmission.com>
In-Reply-To: <m1oct739xu.fsf@fess.ebiederm.org>
References: <m1oct739xu.fsf@fess.ebiederm.org>
Subject: [PATCH 05/23] vfs: Teach lseek to use file_hotplug_lock
Sender: owner-linux-mm@kvack.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Tejun Heo <tj@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Greg Kroah-Hartman <gregkh@suse.de>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, "Eric W. Biederman" <ebiederm@maxwell.arastra.com>, "Eric W. Biederman" <ebiederm@aristanetworks.com>
List-ID: <linux-mm.kvack.org>

From: Eric W. Biederman <ebiederm@maxwell.arastra.com>

Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>
---
 fs/read_write.c |   24 +++++++++++++++++-------
 1 files changed, 17 insertions(+), 7 deletions(-)

diff --git a/fs/read_write.c b/fs/read_write.c
index 9d1e76b..c9511ce 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -136,14 +136,24 @@ EXPORT_SYMBOL(default_llseek);
 loff_t vfs_llseek(struct file *file, loff_t offset, int origin)
 {
 	loff_t (*fn)(struct file *, loff_t, int);
+	loff_t retval = -ESPIPE;
 
-	fn = no_llseek;
-	if (file->f_mode & FMODE_LSEEK) {
-		fn = default_llseek;
-		if (file->f_op && file->f_op->llseek)
-			fn = file->f_op->llseek;
-	}
-	return fn(file, offset, origin);
+	if (!(file->f_mode & FMODE_LSEEK))
+		goto out;
+
+	retval = -EIO;
+	if (!file_hotplug_read_trylock(file))
+		goto out;
+
+	fn = default_llseek;
+	if (file->f_op && file->f_op->llseek)
+		fn = file->f_op->llseek;
+
+	retval = fn(file, offset, origin);
+
+	file_hotplug_read_unlock(file);
+out:
+	return retval;
 }
 EXPORT_SYMBOL(vfs_llseek);
 
-- 
1.6.3.1.54.g99dd.dirty

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
