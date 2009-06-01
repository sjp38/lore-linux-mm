Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id C17A75F002C
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 14:17:43 -0400 (EDT)
From: "Eric W. Biederman" <ebiederm@xmission.com>
Date: Mon,  1 Jun 2009 14:50:35 -0700
Message-Id: <1243893048-17031-10-git-send-email-ebiederm@xmission.com>
In-Reply-To: <m1oct739xu.fsf@fess.ebiederm.org>
References: <m1oct739xu.fsf@fess.ebiederm.org>
Subject: [PATCH 10/23] vfs: Teach do_path_lookup to use file_hotplug_lock
Sender: owner-linux-mm@kvack.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Tejun Heo <tj@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Greg Kroah-Hartman <gregkh@suse.de>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, "Eric W. Biederman" <ebiederm@maxwell.aristanetworks.com>, "Eric W. Biederman" <ebiederm@aristanetworks.com>
List-ID: <linux-mm.kvack.org>

From: Eric W. Biederman <ebiederm@maxwell.aristanetworks.com>

Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>
---
 fs/namei.c |   11 +++++++++--
 1 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index 5472ed0..c4c6575 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -1049,23 +1049,30 @@ static int path_init(int dfd, const char *name, unsigned int flags, struct namei
 		if (!file)
 			goto out_fail;
 
+		retval = -EIO;
+		if (!file_hotplug_read_trylock(file))
+			goto fput_fail;
+
 		dentry = file->f_path.dentry;
 
 		retval = -ENOTDIR;
 		if (!S_ISDIR(dentry->d_inode->i_mode))
-			goto fput_fail;
+			goto unlock_fail;
 
 		retval = file_permission(file, MAY_EXEC);
 		if (retval)
-			goto fput_fail;
+			goto unlock_fail;
 
 		nd->path = file->f_path;
 		path_get(&file->f_path);
 
+		file_hotplug_read_unlock(file);
 		fput_light(file, fput_needed);
 	}
 	return 0;
 
+unlock_fail:
+	file_hotplug_read_unlock(file);
 fput_fail:
 	fput_light(file, fput_needed);
 out_fail:
-- 
1.6.3.1.54.g99dd.dirty

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
