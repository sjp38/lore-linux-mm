Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id CF5FC8299A
	for <linux-mm@kvack.org>; Tue,  6 May 2014 10:38:11 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id lf10so11206466pab.13
        for <linux-mm@kvack.org>; Tue, 06 May 2014 07:38:11 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id vw5si12102222pab.333.2014.05.06.07.38.10
        for <linux-mm@kvack.org>;
        Tue, 06 May 2014 07:38:10 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 6/8] mm, rmap: kill mapping->i_mmap_nonlinear
Date: Tue,  6 May 2014 17:37:30 +0300
Message-Id: <1399387052-31660-7-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1399387052-31660-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1399387052-31660-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, peterz@infradead.org, mingo@kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Nobody creates nonlinear VMAs. No need to support them.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 Documentation/cachetlb.txt | 4 ++--
 fs/inode.c                 | 1 -
 include/linux/fs.h         | 4 +---
 mm/swap.c                  | 1 -
 4 files changed, 3 insertions(+), 7 deletions(-)

diff --git a/Documentation/cachetlb.txt b/Documentation/cachetlb.txt
index d79b008e4a32..72405093f707 100644
--- a/Documentation/cachetlb.txt
+++ b/Documentation/cachetlb.txt
@@ -317,8 +317,8 @@ maps this page at its virtual address.
 	about doing this.
 
 	The idea is, first at flush_dcache_page() time, if
-	page->mapping->i_mmap is an empty tree and ->i_mmap_nonlinear
-	an empty list, just mark the architecture private page flag bit.
+	page->mapping->i_mmap is an empty tree just mark the architecture
+	private page flag bit.
 	Later, in update_mmu_cache(), a check is made of this flag bit,
 	and if set the flush is done and the flag bit is cleared.
 
diff --git a/fs/inode.c b/fs/inode.c
index f96d2a6f88cc..0cb8652b3719 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -352,7 +352,6 @@ void address_space_init_once(struct address_space *mapping)
 	INIT_LIST_HEAD(&mapping->private_list);
 	spin_lock_init(&mapping->private_lock);
 	mapping->i_mmap = RB_ROOT;
-	INIT_LIST_HEAD(&mapping->i_mmap_nonlinear);
 }
 EXPORT_SYMBOL(address_space_init_once);
 
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 14abfc355726..f95bd31ff424 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -386,7 +386,6 @@ struct address_space {
 	spinlock_t		tree_lock;	/* and lock protecting it */
 	unsigned int		i_mmap_writable;/* count VM_SHARED mappings */
 	struct rb_root		i_mmap;		/* tree of private and shared mappings */
-	struct list_head	i_mmap_nonlinear;/*list VM_NONLINEAR mappings */
 	struct mutex		i_mmap_mutex;	/* protect tree, count, list */
 	/* Protected by tree_lock together with the radix tree */
 	unsigned long		nrpages;	/* number of total pages */
@@ -458,8 +457,7 @@ int mapping_tagged(struct address_space *mapping, int tag);
  */
 static inline int mapping_mapped(struct address_space *mapping)
 {
-	return	!RB_EMPTY_ROOT(&mapping->i_mmap) ||
-		!list_empty(&mapping->i_mmap_nonlinear);
+	return	!RB_EMPTY_ROOT(&mapping->i_mmap);
 }
 
 /*
diff --git a/mm/swap.c b/mm/swap.c
index 9ce43ba4498b..6adef8e3ccf7 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -1046,7 +1046,6 @@ void __init swap_setup(void)
 		panic("Failed to init swap bdi");
 	for (i = 0; i < MAX_SWAPFILES; i++) {
 		spin_lock_init(&swapper_spaces[i].tree_lock);
-		INIT_LIST_HEAD(&swapper_spaces[i].i_mmap_nonlinear);
 	}
 #endif
 
-- 
2.0.0.rc0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
