Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 9E7476B0092
	for <linux-mm@kvack.org>; Wed,  3 Oct 2012 18:44:05 -0400 (EDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: [RFC/PATCH 2/3] swap: add read_frontswap_async to move a page from frontswap to swapcache
Date: Wed,  3 Oct 2012 15:43:53 -0700
Message-Id: <1349304234-19273-3-git-send-email-dan.magenheimer@oracle.com>
In-Reply-To: <1349304234-19273-1-git-send-email-dan.magenheimer@oracle.com>
References: <1349304234-19273-1-git-send-email-dan.magenheimer@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, ngupta@vflare.org, konrad.wilk@oracle.com, sjenning@linux.vnet.ibm.com, minchan@kernel.org, hughd@google.com, akpm@linux-foundation.org, riel@redhat.com, hannes@cmpxchg.org, dan.magenheimer@oracle.com, aarcange@redhat.com, mgorman@suse.de, gregkh@linuxfoundation.org

We would like to move a "swap page" identified by swaptype/offset
out of frontswap and into swap cache.  Add read_frontswap_async
that, given an unused new page and a gfp_mask (for necessary radix
tree work), attempts to do that and communicates success, failure,
or the fact that a (possibly dirty) copy already exists in swap cache.
This new routine will be called from zcache (via frontswap) to
allow pages to be swapped to a true swap device when zcache gets "full".

Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>
---
 include/linux/swap.h |    1 +
 mm/swap_state.c      |   80 ++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 81 insertions(+), 0 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index d3c7281..8a59ddb 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -352,6 +352,7 @@ extern void free_pages_and_swap_cache(struct page **, int);
 extern struct page *lookup_swap_cache(swp_entry_t);
 extern struct page *read_swap_cache_async(swp_entry_t, gfp_t,
 			struct vm_area_struct *vma, unsigned long addr);
+extern int read_frontswap_async(int, pgoff_t, struct page *, gfp_t);
 extern struct page *swapin_readahead(swp_entry_t, gfp_t,
 			struct vm_area_struct *vma, unsigned long addr);
 
diff --git a/mm/swap_state.c b/mm/swap_state.c
index 0cb36fb..ad790bf 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -18,6 +18,7 @@
 #include <linux/pagevec.h>
 #include <linux/migrate.h>
 #include <linux/page_cgroup.h>
+#include <linux/frontswap.h>
 
 #include <asm/pgtable.h>
 
@@ -351,6 +352,85 @@ struct page *read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
 	return found_page;
 }
 
+/*
+ * Similar to read_swap_cache_async except we know the page is in frontswap
+ * and we are trying to place it in swapcache so we can remove it from
+ * frontswap. Success means the data in frontswap can be thrown away,
+ * ENOMEM means it cannot, and -EEXIST means a (possibly dirty) copy
+ * already exists in the swapcache.
+ */
+int read_frontswap_async(int type, pgoff_t offset, struct page *new_page,
+				gfp_t gfp_mask)
+{
+	struct page *found_page;
+	swp_entry_t entry;
+	int ret = 0;
+
+	entry = swp_entry(type, offset);
+	do {
+		/*
+		 * First check the swap cache.  Since this is normally
+		 * called after lookup_swap_cache() failed, re-calling
+		 * that would confuse statistics.
+		 */
+		found_page = find_get_page(&swapper_space, entry.val);
+		if (found_page) {
+			/* its already in the swap cache */
+			ret = -EEXIST;
+			break;
+		}
+
+
+		/*
+		 * call radix_tree_preload() while we can wait.
+		 */
+		ret = radix_tree_preload(gfp_mask);
+		if (ret)
+			break;
+
+		/*
+		 * Swap entry may have been freed since our caller observed it.
+		 */
+		ret = swapcache_prepare(entry);
+		if (ret == -EEXIST) {	/* seems racy */
+			radix_tree_preload_end();
+			continue;
+		}
+		if (ret) {		/* swp entry is obsolete ? */
+			radix_tree_preload_end();
+			break;
+		}
+
+		/* May fail (-ENOMEM) if radix-tree node allocation failed. */
+		__set_page_locked(new_page);
+		SetPageSwapBacked(new_page);
+		ret = __add_to_swap_cache(new_page, entry);
+		if (likely(!ret)) {
+			radix_tree_preload_end();
+			/* FIXME: how do I add this at tail of lru? */
+			SetPageDirty(new_page);
+			lru_cache_add_anon_tail(new_page);
+			/* Get page (from frontswap) and return */
+			if (frontswap_load(new_page) == 0)
+				SetPageUptodate(new_page);
+			unlock_page(new_page);
+			ret = 0;
+			goto out;
+		}
+		radix_tree_preload_end();
+		ClearPageSwapBacked(new_page);
+		__clear_page_locked(new_page);
+		/*
+		 * add_to_swap_cache() doesn't return -EEXIST, so we can safely
+		 * clear SWAP_HAS_CACHE flag.
+		 */
+		swapcache_free(entry, NULL);
+	} while (ret != -ENOMEM);
+
+out:
+	return ret;
+}
+
 /**
  * swapin_readahead - swap in pages in hope we need them soon
  * @entry: swap entry of this memory
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
