Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3232D6B0022
	for <linux-mm@kvack.org>; Sat, 14 Apr 2018 10:13:29 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id 91-v6so7585374plf.6
        for <linux-mm@kvack.org>; Sat, 14 Apr 2018 07:13:29 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id o1-v6si7685752pld.255.2018.04.14.07.13.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 14 Apr 2018 07:13:27 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v11 16/63] page cache: Rearrange address_space
Date: Sat, 14 Apr 2018 07:12:29 -0700
Message-Id: <20180414141316.7167-17-willy@infradead.org>
In-Reply-To: <20180414141316.7167-1-willy@infradead.org>
References: <20180414141316.7167-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, Goldwyn Rodrigues <rgoldwyn@suse.com>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

Change i_pages from a radix_tree_root to an xarray, convert the
documentation into kernel-doc format and change the order of the elements
to pack them better on 64-bit systems.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/fs.h | 46 +++++++++++++++++++++++++++++++---------------
 1 file changed, 31 insertions(+), 15 deletions(-)

diff --git a/include/linux/fs.h b/include/linux/fs.h
index bf3d5039c708..0a4e213f1069 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -389,24 +389,40 @@ int pagecache_write_end(struct file *, struct address_space *mapping,
 				loff_t pos, unsigned len, unsigned copied,
 				struct page *page, void *fsdata);
 
+/**
+ * struct address_space - Contents of a cacheable, mappable object.
+ * @host: Owner, either the inode or the block_device.
+ * @i_pages: Cached pages.
+ * @gfp_mask: Memory allocation flags to use for allocating pages.
+ * @i_mmap_writable: Number of VM_SHARED mappings.
+ * @i_mmap: Tree of private and shared mappings.
+ * @i_mmap_rwsem: Protects @i_mmap and @i_mmap_writable.
+ * @nrpages: Number of page entries, protected by the i_pages lock.
+ * @nrexceptional: Shadow or DAX entries, protected by the i_pages lock.
+ * @writeback_index: Writeback starts here.
+ * @a_ops: Methods.
+ * @flags: Error bits and flags (AS_*).
+ * @wb_err: The most recent error which has occurred.
+ * @private_lock: For use by the owner of the address_space.
+ * @private_list: For use by the owner of the address_space.
+ * @private_data: For use by the owner of the address_space.
+ */
 struct address_space {
-	struct inode		*host;		/* owner: inode, block_device */
-	struct radix_tree_root	i_pages;	/* cached pages */
-	atomic_t		i_mmap_writable;/* count VM_SHARED mappings */
-	struct rb_root_cached	i_mmap;		/* tree of private and shared mappings */
-	struct rw_semaphore	i_mmap_rwsem;	/* protect tree, count, list */
-	/* Protected by the i_pages lock */
-	unsigned long		nrpages;	/* number of total pages */
-	/* number of shadow or DAX exceptional entries */
+	struct inode		*host;
+	struct xarray		i_pages;
+	gfp_t			gfp_mask;
+	atomic_t		i_mmap_writable;
+	struct rb_root_cached	i_mmap;
+	struct rw_semaphore	i_mmap_rwsem;
+	unsigned long		nrpages;
 	unsigned long		nrexceptional;
-	pgoff_t			writeback_index;/* writeback starts here */
-	const struct address_space_operations *a_ops;	/* methods */
-	unsigned long		flags;		/* error bits */
-	spinlock_t		private_lock;	/* for use by the address_space */
-	gfp_t			gfp_mask;	/* implicit gfp mask for allocations */
-	struct list_head	private_list;	/* for use by the address_space */
-	void			*private_data;	/* ditto */
+	pgoff_t			writeback_index;
+	const struct address_space_operations *a_ops;
+	unsigned long		flags;
 	errseq_t		wb_err;
+	spinlock_t		private_lock;
+	struct list_head	private_list;
+	void			*private_data;
 } __attribute__((aligned(sizeof(long)))) __randomize_layout;
 	/*
 	 * On most architectures that alignment is already the case; but
-- 
2.17.0
