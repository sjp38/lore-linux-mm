Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 3351A6B00FB
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 14:17:44 -0400 (EDT)
From: "Eric W. Biederman" <ebiederm@xmission.com>
Date: Mon,  1 Jun 2009 14:50:46 -0700
Message-Id: <1243893048-17031-21-git-send-email-ebiederm@xmission.com>
In-Reply-To: <m1oct739xu.fsf@fess.ebiederm.org>
References: <m1oct739xu.fsf@fess.ebiederm.org>
Subject: [PATCH 21/23] vfs: Teach fsync to use file_hotplug_lock
Sender: owner-linux-mm@kvack.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Tejun Heo <tj@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Greg Kroah-Hartman <gregkh@suse.de>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, "Eric W. Biederman" <ebiederm@maxwell.aristanetworks.com>, "Eric W. Biederman" <ebiederm@aristanetworks.com>
List-ID: <linux-mm.kvack.org>

From: Eric W. Biederman <ebiederm@maxwell.aristanetworks.com>

Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>
---
 fs/sync.c |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/fs/sync.c b/fs/sync.c
index e9d56f6..ac6da60 100644
--- a/fs/sync.c
+++ b/fs/sync.c
@@ -197,6 +197,9 @@ int vfs_fsync(struct file *file, struct dentry *dentry, int datasync)
 	 * don't have a struct file available.  Damn nfsd..
 	 */
 	if (file) {
+		ret = -EIO;
+		if (!file_hotplug_read_trylock(file))
+			goto out;
 		mapping = file->f_mapping;
 		fop = file->f_op;
 	} else {
@@ -206,7 +209,7 @@ int vfs_fsync(struct file *file, struct dentry *dentry, int datasync)
 
 	if (!fop || !fop->fsync) {
 		ret = -EINVAL;
-		goto out;
+		goto out_unlock;
 	}
 
 	ret = filemap_fdatawrite(mapping);
@@ -223,6 +226,10 @@ int vfs_fsync(struct file *file, struct dentry *dentry, int datasync)
 	err = filemap_fdatawait(mapping);
 	if (!ret)
 		ret = err;
+
+out_unlock:
+	if (file)
+		file_hotplug_read_unlock(file);
 out:
 	return ret;
 }
-- 
1.6.3.1.54.g99dd.dirty

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
