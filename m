Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 5D8356B002C
	for <linux-mm@kvack.org>; Thu,  1 Mar 2012 06:41:55 -0500 (EST)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 2/9] fs: Push file_update_time() into __block_page_mkwrite()
Date: Thu,  1 Mar 2012 12:41:36 +0100
Message-Id: <1330602103-8851-3-git-send-email-jack@suse.cz>
In-Reply-To: <1330602103-8851-1-git-send-email-jack@suse.cz>
References: <1330602103-8851-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Al Viro <viro@ZenIV.linux.org.uk>, linux-fsdevel@vger.kernel.org, dchinner@redhat.com, Jan Kara <jack@suse.cz>

Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/buffer.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/fs/buffer.c b/fs/buffer.c
index 1a30db7..5294a33 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -2300,6 +2300,12 @@ int __block_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf,
 	loff_t size;
 	int ret;
 
+	/*
+	 * Update file times before taking page lock. We may end up failing the
+	 * fault so this update may be superfluous but who really cares...
+	 */
+	file_update_time(vma->vm_file);
+
 	lock_page(page);
 	size = i_size_read(inode);
 	if ((page->mapping != inode->i_mapping) ||
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
