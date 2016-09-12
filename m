Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7E2EE6B025E
	for <linux-mm@kvack.org>; Mon, 12 Sep 2016 07:16:29 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id u14so93682252lfd.0
        for <linux-mm@kvack.org>; Mon, 12 Sep 2016 04:16:29 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id u200si1416492wmu.0.2016.09.12.04.16.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Sep 2016 04:16:26 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id g141so2101423wmd.1
        for <linux-mm@kvack.org>; Mon, 12 Sep 2016 04:16:26 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 2/2] mm: split gfp_mask and mapping flags into separate fields
Date: Mon, 12 Sep 2016 13:16:08 +0200
Message-Id: <20160912111608.2588-3-mhocko@kernel.org>
In-Reply-To: <20160912111608.2588-1-mhocko@kernel.org>
References: <20160901091347.GC12147@dhcp22.suse.cz>
 <20160912111608.2588-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

mapping->flags currently encodes two different things into a single
flag. It contains sticky gfp_mask for page cache allocations and AS_
codes used to report errors/enospace and other states which are mapping
specific. Condensing the two semantically unrelated things saves few
bytes but it also complicates other things. For one thing the gfp flags
space is reduced and in fact we are already running out of available
bits. It can be assumed that more gfp flags will be necessary later on.

To not introduce the address_space grow (at least on x86_64) we can
stick it right after private_lock because we have a hole there.

struct address_space {
        struct inode *             host;                 /*     0     8 */
        struct radix_tree_root     page_tree;            /*     8    16 */
        spinlock_t                 tree_lock;            /*    24     4 */
        atomic_t                   i_mmap_writable;      /*    28     4 */
        struct rb_root             i_mmap;               /*    32     8 */
        struct rw_semaphore        i_mmap_rwsem;         /*    40    40 */
        /* --- cacheline 1 boundary (64 bytes) was 16 bytes ago --- */
        long unsigned int          nrpages;              /*    80     8 */
        long unsigned int          nrexceptional;        /*    88     8 */
        long unsigned int          writeback_index;      /*    96     8 */
        const struct address_space_operations  * a_ops;  /*   104     8 */
        long unsigned int          flags;                /*   112     8 */
        spinlock_t                 private_lock;         /*   120     4 */

        /* XXX 4 bytes hole, try to pack */

        /* --- cacheline 2 boundary (128 bytes) --- */
        struct list_head           private_list;         /*   128    16 */
        void *                     private_data;         /*   144     8 */

        /* size: 152, cachelines: 3, members: 14 */
        /* sum members: 148, holes: 1, sum holes: 4 */
        /* last cacheline: 24 bytes */
};

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/fs.h      |  3 ++-
 include/linux/pagemap.h | 20 +++++++++-----------
 2 files changed, 11 insertions(+), 12 deletions(-)

diff --git a/include/linux/fs.h b/include/linux/fs.h
index cd8a5e1d5580..41d7213946af 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -443,7 +443,8 @@ struct address_space {
 	unsigned long		nrexceptional;
 	pgoff_t			writeback_index;/* writeback starts here */
 	const struct address_space_operations *a_ops;	/* methods */
-	unsigned long		flags;		/* error bits/gfp mask */
+	unsigned long		flags;		/* error bits */
+	gfp_t			gfp_mask;	/* implicit gfp mask for allocations */
 	spinlock_t		private_lock;	/* for use by the address_space */
 	struct list_head	private_list;	/* ditto */
 	void			*private_data;	/* ditto */
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 76f151ab4f62..0385a954465c 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -16,17 +16,16 @@
 #include <linux/hugetlb_inline.h>
 
 /*
- * Bits in mapping->flags.  The lower __GFP_BITS_SHIFT bits are the page
- * allocation mode flags.
+ * Bits in mapping->flags.
  */
 enum mapping_flags {
-	AS_EIO		= __GFP_BITS_SHIFT + 0,	/* IO error on async write */
-	AS_ENOSPC	= __GFP_BITS_SHIFT + 1,	/* ENOSPC on async write */
-	AS_MM_ALL_LOCKS	= __GFP_BITS_SHIFT + 2,	/* under mm_take_all_locks() */
-	AS_UNEVICTABLE	= __GFP_BITS_SHIFT + 3,	/* e.g., ramdisk, SHM_LOCK */
-	AS_EXITING	= __GFP_BITS_SHIFT + 4, /* final truncate in progress */
+	AS_EIO		= 0,	/* IO error on async write */
+	AS_ENOSPC	= 1,	/* ENOSPC on async write */
+	AS_MM_ALL_LOCKS	= 2,	/* under mm_take_all_locks() */
+	AS_UNEVICTABLE	= 3,	/* e.g., ramdisk, SHM_LOCK */
+	AS_EXITING	= 4, 	/* final truncate in progress */
 	/* writeback related tags are not used */
-	AS_NO_WRITEBACK_TAGS = __GFP_BITS_SHIFT + 5,
+	AS_NO_WRITEBACK_TAGS = 5,
 
 	AS_LAST_FLAG,
 };
@@ -80,7 +79,7 @@ static inline int mapping_use_writeback_tags(struct address_space *mapping)
 
 static inline gfp_t mapping_gfp_mask(struct address_space * mapping)
 {
-	return (__force gfp_t)mapping->flags & __GFP_BITS_MASK;
+	return mapping->gfp_mask;
 }
 
 /* Restricts the given gfp_mask to what the mapping allows. */
@@ -96,8 +95,7 @@ static inline gfp_t mapping_gfp_constraint(struct address_space *mapping,
  */
 static inline void mapping_set_gfp_mask(struct address_space *m, gfp_t mask)
 {
-	m->flags = (m->flags & ~(__force unsigned long)__GFP_BITS_MASK) |
-				(__force unsigned long)mask;
+	m->gfp_mask = mask;
 }
 
 void release_pages(struct page **pages, int nr, bool cold);
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
