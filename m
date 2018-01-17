Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 366C5280286
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 15:23:08 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id e12so6364779pgu.11
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 12:23:08 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id a9si4425879pgv.684.2018.01.17.12.23.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 17 Jan 2018 12:23:07 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v6 92/99] f2fs: Convert pids radix tree to XArray
Date: Wed, 17 Jan 2018 12:21:56 -0800
Message-Id: <20180117202203.19756-93-willy@infradead.org>
In-Reply-To: <20180117202203.19756-1-willy@infradead.org>
References: <20180117202203.19756-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, Bjorn Andersson <bjorn.andersson@linaro.org>, Stefano Stabellini <sstabellini@kernel.org>, iommu@lists.linux-foundation.org, linux-remoteproc@vger.kernel.org, linux-s390@vger.kernel.org, intel-gfx@lists.freedesktop.org, cgroups@vger.kernel.org, linux-sh@vger.kernel.org, David Howells <dhowells@redhat.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

The XArray API works out rather well for this user.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 fs/f2fs/super.c |  2 --
 fs/f2fs/trace.c | 60 ++++-----------------------------------------------------
 fs/f2fs/trace.h |  2 --
 3 files changed, 4 insertions(+), 60 deletions(-)

diff --git a/fs/f2fs/super.c b/fs/f2fs/super.c
index 708155d9c2e4..d608edffe69e 100644
--- a/fs/f2fs/super.c
+++ b/fs/f2fs/super.c
@@ -2831,8 +2831,6 @@ static int __init init_f2fs_fs(void)
 {
 	int err;
 
-	f2fs_build_trace_ios();
-
 	err = init_inodecache();
 	if (err)
 		goto fail;
diff --git a/fs/f2fs/trace.c b/fs/f2fs/trace.c
index bccbbf2616d2..f316a42c547f 100644
--- a/fs/f2fs/trace.c
+++ b/fs/f2fs/trace.c
@@ -16,8 +16,7 @@
 #include "f2fs.h"
 #include "trace.h"
 
-static RADIX_TREE(pids, GFP_ATOMIC);
-static spinlock_t pids_lock;
+static DEFINE_XARRAY(pids);
 static struct last_io_info last_io;
 
 static inline void __print_last_io(void)
@@ -57,28 +56,13 @@ void f2fs_trace_pid(struct page *page)
 {
 	struct inode *inode = page->mapping->host;
 	pid_t pid = task_pid_nr(current);
-	void *p;
 
 	set_page_private(page, (unsigned long)pid);
 
-	if (radix_tree_preload(GFP_NOFS))
-		return;
-
-	spin_lock(&pids_lock);
-	p = radix_tree_lookup(&pids, pid);
-	if (p == current)
-		goto out;
-	if (p)
-		radix_tree_delete(&pids, pid);
-
-	f2fs_radix_tree_insert(&pids, pid, current);
-
-	trace_printk("%3x:%3x %4x %-16s\n",
+	if (xa_store(&pids, pid, current, GFP_NOFS) != current)
+		trace_printk("%3x:%3x %4x %-16s\n",
 			MAJOR(inode->i_sb->s_dev), MINOR(inode->i_sb->s_dev),
 			pid, current->comm);
-out:
-	spin_unlock(&pids_lock);
-	radix_tree_preload_end();
 }
 
 void f2fs_trace_ios(struct f2fs_io_info *fio, int flush)
@@ -120,43 +104,7 @@ void f2fs_trace_ios(struct f2fs_io_info *fio, int flush)
 	return;
 }
 
-void f2fs_build_trace_ios(void)
-{
-	spin_lock_init(&pids_lock);
-}
-
-#define PIDVEC_SIZE	128
-static unsigned int gang_lookup_pids(pid_t *results, unsigned long first_index,
-							unsigned int max_items)
-{
-	struct radix_tree_iter iter;
-	void **slot;
-	unsigned int ret = 0;
-
-	if (unlikely(!max_items))
-		return 0;
-
-	radix_tree_for_each_slot(slot, &pids, &iter, first_index) {
-		results[ret] = iter.index;
-		if (++ret == max_items)
-			break;
-	}
-	return ret;
-}
-
 void f2fs_destroy_trace_ios(void)
 {
-	pid_t pid[PIDVEC_SIZE];
-	pid_t next_pid = 0;
-	unsigned int found;
-
-	spin_lock(&pids_lock);
-	while ((found = gang_lookup_pids(pid, next_pid, PIDVEC_SIZE))) {
-		unsigned idx;
-
-		next_pid = pid[found - 1] + 1;
-		for (idx = 0; idx < found; idx++)
-			radix_tree_delete(&pids, pid[idx]);
-	}
-	spin_unlock(&pids_lock);
+	xa_destroy(&pids);
 }
diff --git a/fs/f2fs/trace.h b/fs/f2fs/trace.h
index 67db24ac1e85..157e4564e48b 100644
--- a/fs/f2fs/trace.h
+++ b/fs/f2fs/trace.h
@@ -34,12 +34,10 @@ struct last_io_info {
 
 extern void f2fs_trace_pid(struct page *);
 extern void f2fs_trace_ios(struct f2fs_io_info *, int);
-extern void f2fs_build_trace_ios(void);
 extern void f2fs_destroy_trace_ios(void);
 #else
 #define f2fs_trace_pid(p)
 #define f2fs_trace_ios(i, n)
-#define f2fs_build_trace_ios()
 #define f2fs_destroy_trace_ios()
 
 #endif
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
