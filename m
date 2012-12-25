Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id E88CC6B0068
	for <linux-mm@kvack.org>; Tue, 25 Dec 2012 12:24:53 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id hz11so4565328pad.17
        for <linux-mm@kvack.org>; Tue, 25 Dec 2012 09:24:53 -0800 (PST)
From: Sha Zhengju <handai.szj@gmail.com>
Subject: [PATCH V3 3/8] use vfs __set_page_dirty interface instead of doing it inside filesystem
Date: Wed, 26 Dec 2012 01:24:21 +0800
Message-Id: <1356456261-14579-1-git-send-email-handai.szj@taobao.com>
In-Reply-To: <1356455919-14445-1-git-send-email-handai.szj@taobao.com>
References: <1356455919-14445-1-git-send-email-handai.szj@taobao.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, ceph-devel@vger.kernel.org
Cc: sage@newdream.net, dchinner@redhat.com, mhocko@suse.cz, akpm@linux-foundation.org, kamezawa.hiroyu@jp.fujitsu.com, gthelen@google.com, fengguang.wu@intel.com, glommer@parallels.com, Sha Zhengju <handai.szj@taobao.com>

From: Sha Zhengju <handai.szj@taobao.com>

Following we will treat SetPageDirty and dirty page accounting as an integrated
operation. Filesystems had better use vfs interface directly to avoid those details.

Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
Acked-by: Sage Weil <sage@inktank.com>
---
 fs/buffer.c                 |    3 ++-
 fs/ceph/addr.c              |   20 ++------------------
 include/linux/buffer_head.h |    2 ++
 3 files changed, 6 insertions(+), 19 deletions(-)

diff --git a/fs/buffer.c b/fs/buffer.c
index 3b032b9..762168a 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -609,7 +609,7 @@ EXPORT_SYMBOL(mark_buffer_dirty_inode);
  * If warn is true, then emit a warning if the page is not uptodate and has
  * not been truncated.
  */
-static int __set_page_dirty(struct page *page,
+int __set_page_dirty(struct page *page,
 		struct address_space *mapping, int warn)
 {
 	if (unlikely(!mapping))
@@ -630,6 +630,7 @@ static int __set_page_dirty(struct page *page,
 
 	return 1;
 }
+EXPORT_SYMBOL(__set_page_dirty);
 
 /*
  * Add a page to the dirty page list.
diff --git a/fs/ceph/addr.c b/fs/ceph/addr.c
index 6690269..f2779b8 100644
--- a/fs/ceph/addr.c
+++ b/fs/ceph/addr.c
@@ -5,6 +5,7 @@
 #include <linux/mm.h>
 #include <linux/pagemap.h>
 #include <linux/writeback.h>	/* generic_writepages */
+#include <linux/buffer_head.h>
 #include <linux/slab.h>
 #include <linux/pagevec.h>
 #include <linux/task_io_accounting_ops.h>
@@ -73,14 +74,8 @@ static int ceph_set_page_dirty(struct page *page)
 	int undo = 0;
 	struct ceph_snap_context *snapc;
 
-	if (unlikely(!mapping))
-		return !TestSetPageDirty(page);
-
-	if (TestSetPageDirty(page)) {
-		dout("%p set_page_dirty %p idx %lu -- already dirty\n",
-		     mapping->host, page, page->index);
+	if (!__set_page_dirty(page, mapping, 1))
 		return 0;
-	}
 
 	inode = mapping->host;
 	ci = ceph_inode(inode);
@@ -107,14 +102,7 @@ static int ceph_set_page_dirty(struct page *page)
 	     snapc, snapc->seq, snapc->num_snaps);
 	spin_unlock(&ci->i_ceph_lock);
 
-	/* now adjust page */
-	spin_lock_irq(&mapping->tree_lock);
 	if (page->mapping) {	/* Race with truncate? */
-		WARN_ON_ONCE(!PageUptodate(page));
-		account_page_dirtied(page, page->mapping);
-		radix_tree_tag_set(&mapping->page_tree,
-				page_index(page), PAGECACHE_TAG_DIRTY);
-
 		/*
 		 * Reference snap context in page->private.  Also set
 		 * PagePrivate so that we get invalidatepage callback.
@@ -126,14 +114,10 @@ static int ceph_set_page_dirty(struct page *page)
 		undo = 1;
 	}
 
-	spin_unlock_irq(&mapping->tree_lock);
-
 	if (undo)
 		/* whoops, we failed to dirty the page */
 		ceph_put_wrbuffer_cap_refs(ci, 1, snapc);
 
-	__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
-
 	BUG_ON(!PageDirty(page));
 	return 1;
 }
diff --git a/include/linux/buffer_head.h b/include/linux/buffer_head.h
index 458f497..0a331a8 100644
--- a/include/linux/buffer_head.h
+++ b/include/linux/buffer_head.h
@@ -336,6 +336,8 @@ static inline void lock_buffer(struct buffer_head *bh)
 }
 
 extern int __set_page_dirty_buffers(struct page *page);
+extern int __set_page_dirty(struct page *page,
+		struct address_space *mapping, int warn);
 
 #else /* CONFIG_BLOCK */
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
