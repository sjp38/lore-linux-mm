Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 7D8A06B00FC
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 14:17:44 -0400 (EDT)
From: "Eric W. Biederman" <ebiederm@xmission.com>
Date: Mon,  1 Jun 2009 14:50:48 -0700
Message-Id: <1243893048-17031-23-git-send-email-ebiederm@xmission.com>
In-Reply-To: <m1oct739xu.fsf@fess.ebiederm.org>
References: <m1oct739xu.fsf@fess.ebiederm.org>
Subject: [PATCH 23/23] vfs: Teach readahead to use the file_hotplug_lock
Sender: owner-linux-mm@kvack.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Tejun Heo <tj@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Greg Kroah-Hartman <gregkh@suse.de>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, "Eric W. Biederman" <ebiederm@maxwell.aristanetworks.com>, "Eric W. Biederman" <ebiederm@aristanetworks.com>
List-ID: <linux-mm.kvack.org>

From: Eric W. Biederman <ebiederm@maxwell.aristanetworks.com>

Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>
---
 mm/filemap.c |   25 ++++++++++++++++---------
 1 files changed, 16 insertions(+), 9 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index 379ff0b..5016aa5 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1402,16 +1402,23 @@ SYSCALL_DEFINE(readahead)(int fd, loff_t offset, size_t count)
 
 	ret = -EBADF;
 	file = fget(fd);
-	if (file) {
-		if (file->f_mode & FMODE_READ) {
-			struct address_space *mapping = file->f_mapping;
-			pgoff_t start = offset >> PAGE_CACHE_SHIFT;
-			pgoff_t end = (offset + count - 1) >> PAGE_CACHE_SHIFT;
-			unsigned long len = end - start + 1;
-			ret = do_readahead(mapping, file, start, len);
-		}
-		fput(file);
+	if (!file)
+		goto out;
+
+	if (!(file->f_mode & FMODE_READ))
+		goto out_fput;
+
+	if (file_hotplug_read_trylock(file)) {
+		struct address_space *mapping = file->f_mapping;
+		pgoff_t start = offset >> PAGE_CACHE_SHIFT;
+		pgoff_t end = (offset + count - 1) >> PAGE_CACHE_SHIFT;
+		unsigned long len = end - start + 1;
+		ret = do_readahead(mapping, file, start, len);
+		file_hotplug_read_unlock(file);
 	}
+out_fput:
+	fput(file);
+out:
 	return ret;
 }
 #ifdef CONFIG_HAVE_SYSCALL_WRAPPERS
-- 
1.6.3.1.54.g99dd.dirty

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
