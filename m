Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 9AFDB6B016A
	for <linux-mm@kvack.org>; Mon, 25 Jul 2011 16:35:43 -0400 (EDT)
From: Johannes Weiner <jweiner@redhat.com>
Subject: [patch 2/2] fuse: mark pages accessed when written to
Date: Mon, 25 Jul 2011 22:35:35 +0200
Message-Id: <1311626135-14279-2-git-send-email-jweiner@redhat.com>
In-Reply-To: <1311626135-14279-1-git-send-email-jweiner@redhat.com>
References: <1311626135-14279-1-git-send-email-jweiner@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: fuse-devel@lists.sourceforge.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org

As fuse does not use the page cache library functions when userspace
writes to a file, it did not benefit from 'c8236db mm: mark page
accessed before we write_end()' that made sure pages are properly
marked accessed when written to.

Signed-off-by: Johannes Weiner <jweiner@redhat.com>
---
 fs/fuse/file.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/fs/fuse/file.c b/fs/fuse/file.c
index 5c48126..471067e 100644
--- a/fs/fuse/file.c
+++ b/fs/fuse/file.c
@@ -14,6 +14,7 @@
 #include <linux/sched.h>
 #include <linux/module.h>
 #include <linux/compat.h>
+#include <linux/swap.h>
 
 static const struct file_operations fuse_direct_io_file_operations;
 
@@ -828,6 +829,8 @@ static ssize_t fuse_fill_write_pages(struct fuse_req *req,
 		pagefault_enable();
 		flush_dcache_page(page);
 
+		mark_page_accessed(page);
+
 		if (!tmp) {
 			unlock_page(page);
 			page_cache_release(page);
-- 
1.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
