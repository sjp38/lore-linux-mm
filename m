Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 5DCAF6B00E7
	for <linux-mm@kvack.org>; Thu, 16 Feb 2012 08:46:49 -0500 (EST)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 03/11] fs: Push file_update_time() into __block_page_mkwrite()
Date: Thu, 16 Feb 2012 14:46:11 +0100
Message-Id: <1329399979-3647-4-git-send-email-jack@suse.cz>
In-Reply-To: <1329399979-3647-1-git-send-email-jack@suse.cz>
References: <1329399979-3647-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Eric Sandeen <sandeen@redhat.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>

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
