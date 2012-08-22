Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 6F1806B00BD
	for <linux-mm@kvack.org>; Wed, 22 Aug 2012 11:17:58 -0400 (EDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 2/3] HWPOISON: report sticky EIO for poisoned file
Date: Wed, 22 Aug 2012 11:17:34 -0400
Message-Id: <1345648655-4497-3-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1345648655-4497-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1345648655-4497-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi.kleen@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Tony Luck <tony.luck@intel.com>, Rik van Riel <riel@redhat.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: Wu Fengguang <fengguang.wu@intel.com>

This makes the EIO reports on write(), fsync(), or the NFS close()
sticky enough. The only way to get rid of it may be

	echo 3 > /proc/sys/vm/drop_caches

Note that the impacted process will only be killed if it mapped the page.
XXX
via read()/write()/fsync() instead of memory mapped reads/writes, simply
because it's very hard to find them.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/linux/pagemap.h | 13 +++++++++++++
 mm/filemap.c            | 11 +++++++++++
 mm/memory-failure.c     |  2 +-
 3 files changed, 25 insertions(+), 1 deletion(-)

diff --git v3.6-rc1.orig/include/linux/pagemap.h v3.6-rc1/include/linux/pagemap.h
index e42c762..4d8d821 100644
--- v3.6-rc1.orig/include/linux/pagemap.h
+++ v3.6-rc1/include/linux/pagemap.h
@@ -24,6 +24,7 @@ enum mapping_flags {
 	AS_ENOSPC	= __GFP_BITS_SHIFT + 1,	/* ENOSPC on async write */
 	AS_MM_ALL_LOCKS	= __GFP_BITS_SHIFT + 2,	/* under mm_take_all_locks() */
 	AS_UNEVICTABLE	= __GFP_BITS_SHIFT + 3,	/* e.g., ramdisk, SHM_LOCK */
+	AS_HWPOISON	= __GFP_BITS_SHIFT + 4,	/* hardware memory corruption */
 };
 
 static inline void mapping_set_error(struct address_space *mapping, int error)
@@ -53,6 +54,18 @@ static inline int mapping_unevictable(struct address_space *mapping)
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
diff --git v3.6-rc1.orig/mm/filemap.c v3.6-rc1/mm/filemap.c
index fa5ca30..8bdaf57 100644
--- v3.6-rc1.orig/mm/filemap.c
+++ v3.6-rc1/mm/filemap.c
@@ -297,6 +297,8 @@ int filemap_fdatawait_range(struct address_space *mapping, loff_t start_byte,
 		ret = -ENOSPC;
 	if (test_and_clear_bit(AS_EIO, &mapping->flags))
 		ret = -EIO;
+	if (mapping_hwpoison(mapping))
+		ret = -EIO;
 
 	return ret;
 }
@@ -447,6 +449,15 @@ int add_to_page_cache_locked(struct page *page, struct address_space *mapping,
 	VM_BUG_ON(!PageLocked(page));
 	VM_BUG_ON(PageSwapBacked(page));
 
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
diff --git v3.6-rc1.orig/mm/memory-failure.c v3.6-rc1/mm/memory-failure.c
index 79dfb2f..a1e7e00 100644
--- v3.6-rc1.orig/mm/memory-failure.c
+++ v3.6-rc1/mm/memory-failure.c
@@ -652,7 +652,7 @@ static int me_pagecache_dirty(struct page *p, unsigned long pfn)
 		 * the first EIO, but we're not worse than other parts
 		 * of the kernel.
 		 */
-		mapping_set_error(mapping, EIO);
+		set_bit(AS_HWPOISON, &mapping->flags);
 	}
 
 	return me_pagecache_clean(p, pfn);
-- 
1.7.11.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
