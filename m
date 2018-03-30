Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 155076B0022
	for <linux-mm@kvack.org>; Thu, 29 Mar 2018 23:42:57 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id n2so5718017pgs.2
        for <linux-mm@kvack.org>; Thu, 29 Mar 2018 20:42:57 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id s18si5081190pgd.631.2018.03.29.20.42.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 29 Mar 2018 20:42:54 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v10 01/62] page cache: Use xa_lock
Date: Thu, 29 Mar 2018 20:41:44 -0700
Message-Id: <20180330034245.10462-2-willy@infradead.org>
In-Reply-To: <20180330034245.10462-1-willy@infradead.org>
References: <20180330034245.10462-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, Goldwyn Rodrigues <rgoldwyn@suse.com>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

Remove the address_space ->tree_lock and use the xa_lock newly added to
the radix_tree_root.  Rename the address_space ->page_tree to ->i_pages,
since we don't really care that it's a tree.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
Acked-by: Jeff Layton <jlayton@redhat.com>
Reviewed-by: Josef Bacik <jbacik@fb.com>
---
 arch/nds32/include/asm/cacheflush.h | 4 ++--
 fs/dax.c                            | 6 +++---
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/arch/nds32/include/asm/cacheflush.h b/arch/nds32/include/asm/cacheflush.h
index 7b9b20a381cb..1240f148ec0f 100644
--- a/arch/nds32/include/asm/cacheflush.h
+++ b/arch/nds32/include/asm/cacheflush.h
@@ -34,8 +34,8 @@ void flush_anon_page(struct vm_area_struct *vma,
 void flush_kernel_dcache_page(struct page *page);
 void flush_icache_range(unsigned long start, unsigned long end);
 void flush_icache_page(struct vm_area_struct *vma, struct page *page);
-#define flush_dcache_mmap_lock(mapping)   spin_lock_irq(&(mapping)->tree_lock)
-#define flush_dcache_mmap_unlock(mapping) spin_unlock_irq(&(mapping)->tree_lock)
+#define flush_dcache_mmap_lock(mapping)   xa_lock_irq(&(mapping)->i_pages)
+#define flush_dcache_mmap_unlock(mapping) xa_unlock_irq(&(mapping)->i_pages)
 
 #else
 #include <asm-generic/cacheflush.h>
diff --git a/fs/dax.c b/fs/dax.c
index eeedecc8367b..9dc7337ef571 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -584,7 +584,7 @@ static int __dax_invalidate_mapping_entry(struct address_space *mapping,
 	void *entry;
 	struct radix_tree_root *pages = &mapping->i_pages;
 
-	xa_lock_irq(&mapping->i_pages);
+	xa_lock_irq(pages);
 	entry = get_unlocked_mapping_entry(mapping, index, NULL);
 	if (!entry || WARN_ON_ONCE(!radix_tree_exceptional_entry(entry)))
 		goto out;
@@ -598,7 +598,7 @@ static int __dax_invalidate_mapping_entry(struct address_space *mapping,
 	ret = 1;
 out:
 	put_unlocked_mapping_entry(mapping, index, entry);
-	xa_unlock_irq(&mapping->i_pages);
+	xa_unlock_irq(pages);
 	return ret;
 }
 /*
@@ -685,7 +685,7 @@ static void *dax_insert_mapping_entry(struct address_space *mapping,
 			unmap_mapping_pages(mapping, vmf->pgoff, 1, false);
 	}
 
-	xa_lock_irq(&mapping->i_pages);
+	xa_lock_irq(pages);
 	new_entry = dax_radix_locked_entry(pfn, flags);
 	if (dax_entry_size(entry) != dax_entry_size(new_entry)) {
 		dax_disassociate_entry(entry, mapping, false);
-- 
2.16.2
