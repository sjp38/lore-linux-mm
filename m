Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1F9986B02F3
	for <linux-mm@kvack.org>; Mon, 24 Jul 2017 13:06:26 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id k72so31788008pfj.1
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 10:06:26 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id r2si5515156pgo.574.2017.07.24.10.06.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jul 2017 10:06:25 -0700 (PDT)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH v5 4/5] dax: remove DAX code from page_cache_tree_insert()
Date: Mon, 24 Jul 2017 11:06:15 -0600
Message-Id: <20170724170616.25810-5-ross.zwisler@linux.intel.com>
In-Reply-To: <20170724170616.25810-1-ross.zwisler@linux.intel.com>
References: <20170724170616.25810-1-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.cz>, Jonathan Corbet <corbet@lwn.net>, Matthew Wilcox <mawilcox@microsoft.com>, Steven Rostedt <rostedt@goodmis.org>, linux-doc@vger.kernel.org, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

Now that we no longer insert struct page pointers in DAX radix trees we can
remove the special casing for DAX in page_cache_tree_insert().  This also
allows us to make dax_wake_mapping_entry_waiter() local to fs/dax.c,
removing it from dax.h.

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Suggested-by: Jan Kara <jack@suse.cz>
Reviewed-by: Jan Kara <jack@suse.cz>
---
 fs/dax.c            |  2 +-
 include/linux/dax.h |  2 --
 mm/filemap.c        | 13 ++-----------
 3 files changed, 3 insertions(+), 14 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index 8f8bcb8..a0484a1 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -127,7 +127,7 @@ static int wake_exceptional_entry_func(wait_queue_entry_t *wait, unsigned int mo
  * correct waitqueue where tasks might be waiting for that old 'entry' and
  * wake them.
  */
-void dax_wake_mapping_entry_waiter(struct address_space *mapping,
+static void dax_wake_mapping_entry_waiter(struct address_space *mapping,
 		pgoff_t index, void *entry, bool wake_all)
 {
 	struct exceptional_entry_key key;
diff --git a/include/linux/dax.h b/include/linux/dax.h
index 29cced8..afa99bb 100644
--- a/include/linux/dax.h
+++ b/include/linux/dax.h
@@ -122,8 +122,6 @@ int dax_iomap_fault(struct vm_fault *vmf, enum page_entry_size pe_size,
 int dax_delete_mapping_entry(struct address_space *mapping, pgoff_t index);
 int dax_invalidate_mapping_entry_sync(struct address_space *mapping,
 				      pgoff_t index);
-void dax_wake_mapping_entry_waiter(struct address_space *mapping,
-		pgoff_t index, void *entry, bool wake_all);
 
 #ifdef CONFIG_FS_DAX
 int __dax_zero_page_range(struct block_device *bdev,
diff --git a/mm/filemap.c b/mm/filemap.c
index a497024..1bf1265 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -130,17 +130,8 @@ static int page_cache_tree_insert(struct address_space *mapping,
 			return -EEXIST;
 
 		mapping->nrexceptional--;
-		if (!dax_mapping(mapping)) {
-			if (shadowp)
-				*shadowp = p;
-		} else {
-			/* DAX can replace empty locked entry with a hole */
-			WARN_ON_ONCE(p !=
-				dax_radix_locked_entry(0, RADIX_DAX_EMPTY));
-			/* Wakeup waiters for exceptional entry lock */
-			dax_wake_mapping_entry_waiter(mapping, page->index, p,
-						      true);
-		}
+		if (shadowp)
+			*shadowp = p;
 	}
 	__radix_tree_replace(&mapping->page_tree, node, slot, page,
 			     workingset_update_node, mapping);
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
