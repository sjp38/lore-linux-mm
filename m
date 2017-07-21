Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 93CCC6B02FD
	for <linux-mm@kvack.org>; Fri, 21 Jul 2017 18:40:11 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id w72so27531290pfa.7
        for <linux-mm@kvack.org>; Fri, 21 Jul 2017 15:40:11 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id s27si3462068pfi.496.2017.07.21.15.40.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jul 2017 15:40:10 -0700 (PDT)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH v4 4/5] dax: remove DAX code from page_cache_tree_insert()
Date: Fri, 21 Jul 2017 16:39:54 -0600
Message-Id: <20170721223956.29485-5-ross.zwisler@linux.intel.com>
In-Reply-To: <20170721223956.29485-1-ross.zwisler@linux.intel.com>
References: <20170721223956.29485-1-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, David Airlie <airlied@linux.ie>, Ingo Molnar <mingo@redhat.com>, Inki Dae <inki.dae@samsung.com>, Jan Kara <jack@suse.cz>, Jonathan Corbet <corbet@lwn.net>, Joonyoung Shim <jy0922.shim@samsung.com>, Krzysztof Kozlowski <krzk@kernel.org>, Kukjin Kim <kgene@kernel.org>, Kyungmin Park <kyungmin.park@samsung.com>, Matthew Wilcox <mawilcox@microsoft.com>, Patrik Jakobsson <patrik.r.jakobsson@gmail.com>, Rob Clark <robdclark@gmail.com>, Seung-Woo Kim <sw0312.kim@samsung.com>, Steven Rostedt <rostedt@goodmis.org>, Tomi Valkeinen <tomi.valkeinen@ti.com>, dri-devel@lists.freedesktop.org, freedreno@lists.freedesktop.org, linux-arm-kernel@lists.infradead.org, linux-arm-msm@vger.kernel.org, linux-doc@vger.kernel.org, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-samsung-soc@vger.kernel.org, linux-xfs@vger.kernel.org

Now that we no longer insert struct page pointers in DAX radix trees we can
remove the special casing for DAX in page_cache_tree_insert().  This also
allows us to make dax_wake_mapping_entry_waiter() local to fs/dax.c,
removing it from dax.h.

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Suggested-by: Jan Kara <jack@suse.cz>
---
 fs/dax.c            |  2 +-
 include/linux/dax.h |  2 --
 mm/filemap.c        | 13 ++-----------
 3 files changed, 3 insertions(+), 14 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index fb0e4c1..0e27d90 100644
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
