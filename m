From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 4/5] HWPOISON: report sticky EIO for poisoned file
Date: Thu, 11 Jun 2009 22:22:43 +0800
Message-ID: <20090611144430.813191526@intel.com>
References: <20090611142239.192891591@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 7C5D76B0055
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 10:52:18 -0400 (EDT)
Content-Disposition: inline; filename=hwpoison-more-sticky-eio.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Wu Fengguang <fengguang.wu@intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Andi Kleen <andi@firstfloor.org>, "riel@redhat.com" <riel@redhat.com>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-Id: linux-mm.kvack.org

This makes the EIO reports on write(), fsync(), or the NFS close()
sticky enough. The only way to get rid of it may be

	echo 3 > /proc/sys/vm/drop_caches

Note that the impacted process will only be killed if it mapped the page.
XXX
via read()/write()/fsync() instead of memory mapped reads/writes, simply
because it's very hard to find them.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/linux/pagemap.h |   13 +++++++++++++
 mm/filemap.c            |   11 +++++++++++
 mm/memory-failure.c     |    2 +-
 3 files changed, 25 insertions(+), 1 deletion(-)

--- sound-2.6.orig/include/linux/pagemap.h
+++ sound-2.6/include/linux/pagemap.h
@@ -23,6 +23,7 @@ enum mapping_flags {
 	AS_ENOSPC	= __GFP_BITS_SHIFT + 1,	/* ENOSPC on async write */
 	AS_MM_ALL_LOCKS	= __GFP_BITS_SHIFT + 2,	/* under mm_take_all_locks() */
 	AS_UNEVICTABLE	= __GFP_BITS_SHIFT + 3,	/* e.g., ramdisk, SHM_LOCK */
+	AS_HWPOISON	= __GFP_BITS_SHIFT + 4,	/* hardware memory corruption */
 };
 
 static inline void mapping_set_error(struct address_space *mapping, int error)
@@ -52,6 +53,18 @@ static inline int mapping_unevictable(st
 	return !!mapping;
 }
 
+#ifdef CONFIG_MEMORY_FAILURE
+static inline int mapping_hwpoison(struct address_space *mapping)
+{
+	return test_bit(AS_HWPOISON, &mapping->flags);
+}
+#else
+static inline int mapping_hwpoison(struct address_space *mapping)
+{
+	return 0;
+}
+#endif
+
 static inline gfp_t mapping_gfp_mask(struct address_space * mapping)
 {
 	return (__force gfp_t)mapping->flags & __GFP_BITS_MASK;
--- sound-2.6.orig/mm/filemap.c
+++ sound-2.6/mm/filemap.c
@@ -302,6 +302,8 @@ int wait_on_page_writeback_range(struct 
 		ret = -ENOSPC;
 	if (test_and_clear_bit(AS_EIO, &mapping->flags))
 		ret = -EIO;
+	if (mapping_hwpoison(mapping))
+		ret = -EIO;
 
 	return ret;
 }
@@ -460,6 +462,15 @@ int add_to_page_cache_locked(struct page
 
 	VM_BUG_ON(!PageLocked(page));
 
+	/*
+	 * Hardware corrupted page will be removed from mapping,
+	 * so we want to deny (possibly) reloading the old data.
+	 */
+	if (unlikely(mapping_hwpoison(mapping))) {
+		error = -EIO;
+		goto out;
+	}
+
 	error = mem_cgroup_cache_charge(page, current->mm,
 					gfp_mask & GFP_RECLAIM_MASK);
 	if (error)
--- sound-2.6.orig/mm/memory-failure.c
+++ sound-2.6/mm/memory-failure.c
@@ -184,7 +184,7 @@ static int me_pagecache_dirty(struct pag
 		 * the first EIO, but we're not worse than other parts
 		 * of the kernel.
 		 */
-		mapping_set_error(mapping, EIO);
+		set_bit(AS_HWPOISON, &mapping->flags);
 	}
 
 	return me_pagecache_clean(p, pfn);

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
