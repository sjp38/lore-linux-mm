Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 9683C6B0085
	for <linux-mm@kvack.org>; Fri, 27 Jul 2012 06:27:19 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so5512884pbb.14
        for <linux-mm@kvack.org>; Fri, 27 Jul 2012 03:27:18 -0700 (PDT)
From: Sha Zhengju <handai.szj@gmail.com>
Subject: [PATCH V2 3/6] Use vfs __set_page_dirty interface instead of doing it inside filesystem
Date: Fri, 27 Jul 2012 18:27:05 +0800
Message-Id: <1343384825-20127-1-git-send-email-handai.szj@taobao.com>
In-Reply-To: <1343384432-19903-1-git-send-email-handai.szj@taobao.com>
References: <1343384432-19903-1-git-send-email-handai.szj@taobao.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, cgroups@vger.kernel.org
Cc: fengguang.wu@intel.com, gthelen@google.com, akpm@linux-foundation.org, yinghan@google.com, mhocko@suse.cz, linux-kernel@vger.kernel.org, hannes@cmpxchg.org, torvalds@linux-foundation.org, viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org, sage@newdream.net, ceph-devel@vger.kernel.org, Sha Zhengju <handai.szj@taobao.com>

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
index 5e0b0d2..ffcfb87 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -610,7 +610,7 @@ EXPORT_SYMBOL(mark_buffer_dirty_inode);
  * If warn is true, then emit a warning if the page is not uptodate and has
  * not been truncated.
  */
-static int __set_page_dirty(struct page *page,
+int __set_page_dirty(struct page *page,
 		struct address_space *mapping, int warn)
 {
 	if (unlikely(!mapping))
@@ -631,6 +631,7 @@ static int __set_page_dirty(struct page *page,
 
 	return 1;
 }
+EXPORT_SYMBOL(__set_page_dirty);
 
 /*
  * Add a page to the dirty page list.
diff --git a/fs/ceph/addr.c b/fs/ceph/addr.c
index 8b67304..d028fbe 100644
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
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
