Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id CF1C06B005D
	for <linux-mm@kvack.org>; Thu, 31 May 2012 18:31:55 -0400 (EDT)
Received: by dakp5 with SMTP id p5so2385347dak.14
        for <linux-mm@kvack.org>; Thu, 31 May 2012 15:31:55 -0700 (PDT)
Date: Thu, 31 May 2012 15:31:27 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH] shmem: replace_page must flush_dcache and others
Message-ID: <alpine.LSU.2.00.1205311524160.4512@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Stephane Marchesin <marcheu@chromium.org>, Andi Kleen <andi@firstfloor.org>, Dave Airlie <airlied@gmail.com>, Daniel Vetter <daniel@ffwll.ch>, Rob Clark <rob.clark@linaro.org>, Cong Wang <xiyou.wangcong@gmail.com>, linux-mm@kvack.org, linux-fsdevel@kernel.org, linux-kernel@vger.kernel.org

Commit bde05d1ccd51 ("shmem: replace page if mapping excludes its zone")
is not at all likely to break for anyone, but it was an earlier version
from before review feedback was incorporated.  Fix that up now.

* shmem_replace_page must flush_dcache_page after copy_highpage [akpm]
* Expand comment on why shmem_unuse_inode needs page_swapcount [akpm]
* Remove excess of VM_BUG_ONs from shmem_replace_page [wangcong]
* Check page_private matches swap before calling shmem_replace_page [hughd]
* shmem_replace_page allow for unexpected race in radix_tree lookup [hughd]

Signed-off-by: Hugh Dickins <hughd@google.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>
Cc: Christoph Hellwig <hch@infradead.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Stephane Marchesin <marcheu@chromium.org>
Cc: Andi Kleen <andi@firstfloor.org>
Cc: Dave Airlie <airlied@gmail.com>
Cc: Daniel Vetter <daniel@ffwll.ch>
Cc: Rob Clark <rob.clark@linaro.org>
---

Andrew, many thanks for sending those patches in for v3.5.  You'll find
a [PATCH v2 1/10] languishing in your mailbox from 18 May.  Since that
didn't make it to Linus, please delete it, and send this incremental
instead.  I don't see much point in renaming shmem_replace_page now,
but if you still feel that shmem_substitute_page is preferable, we
can send another patch to make that change.  Thanks - Hugh

 mm/shmem.c |   57 +++++++++++++++++++++++++++++++++------------------
 1 file changed, 37 insertions(+), 20 deletions(-)

--- 3.4.0+/mm/shmem.c	2012-05-30 08:17:19.404008281 -0700
+++ linux/mm/shmem.c	2012-05-31 12:26:28.920160948 -0700
@@ -683,10 +683,21 @@ static int shmem_unuse_inode(struct shme
 		mutex_lock(&shmem_swaplist_mutex);
 		/*
 		 * We needed to drop mutex to make that restrictive page
-		 * allocation; but the inode might already be freed by now,
-		 * and we cannot refer to inode or mapping or info to check.
-		 * However, we do hold page lock on the PageSwapCache page,
-		 * so can check if that still has our reference remaining.
+		 * allocation, but the inode might have been freed while we
+		 * dropped it: although a racing shmem_evict_inode() cannot
+		 * complete without emptying the radix_tree, our page lock
+		 * on this swapcache page is not enough to prevent that -
+		 * free_swap_and_cache() of our swap entry will only
+		 * trylock_page(), removing swap from radix_tree whatever.
+		 *
+		 * We must not proceed to shmem_add_to_page_cache() if the
+		 * inode has been freed, but of course we cannot rely on
+		 * inode or mapping or info to check that.  However, we can
+		 * safely check if our swap entry is still in use (and here
+		 * it can't have got reused for another page): if it's still
+		 * in use, then the inode cannot have been freed yet, and we
+		 * can safely proceed (if it's no longer in use, that tells
+		 * nothing about the inode, but we don't need to unuse swap).
 		 */
 		if (!page_swapcount(*pagep))
 			error = -ENOENT;
@@ -730,9 +741,9 @@ int shmem_unuse(swp_entry_t swap, struct
 
 	/*
 	 * There's a faint possibility that swap page was replaced before
-	 * caller locked it: it will come back later with the right page.
+	 * caller locked it: caller will come back later with the right page.
 	 */
-	if (unlikely(!PageSwapCache(page)))
+	if (unlikely(!PageSwapCache(page) || page_private(page) != swap.val))
 		goto out;
 
 	/*
@@ -995,21 +1006,15 @@ static int shmem_replace_page(struct pag
 	newpage = shmem_alloc_page(gfp, info, index);
 	if (!newpage)
 		return -ENOMEM;
-	VM_BUG_ON(shmem_should_replace_page(newpage, gfp));
 
-	*pagep = newpage;
 	page_cache_get(newpage);
 	copy_highpage(newpage, oldpage);
+	flush_dcache_page(newpage);
 
-	VM_BUG_ON(!PageLocked(oldpage));
 	__set_page_locked(newpage);
-	VM_BUG_ON(!PageUptodate(oldpage));
 	SetPageUptodate(newpage);
-	VM_BUG_ON(!PageSwapBacked(oldpage));
 	SetPageSwapBacked(newpage);
-	VM_BUG_ON(!swap_index);
 	set_page_private(newpage, swap_index);
-	VM_BUG_ON(!PageSwapCache(oldpage));
 	SetPageSwapCache(newpage);
 
 	/*
@@ -1019,13 +1024,24 @@ static int shmem_replace_page(struct pag
 	spin_lock_irq(&swap_mapping->tree_lock);
 	error = shmem_radix_tree_replace(swap_mapping, swap_index, oldpage,
 								   newpage);
-	__inc_zone_page_state(newpage, NR_FILE_PAGES);
-	__dec_zone_page_state(oldpage, NR_FILE_PAGES);
+	if (!error) {
+		__inc_zone_page_state(newpage, NR_FILE_PAGES);
+		__dec_zone_page_state(oldpage, NR_FILE_PAGES);
+	}
 	spin_unlock_irq(&swap_mapping->tree_lock);
-	BUG_ON(error);
 
-	mem_cgroup_replace_page_cache(oldpage, newpage);
-	lru_cache_add_anon(newpage);
+	if (unlikely(error)) {
+		/*
+		 * Is this possible?  I think not, now that our callers check
+		 * both PageSwapCache and page_private after getting page lock;
+		 * but be defensive.  Reverse old to newpage for clear and free.
+		 */
+		oldpage = newpage;
+	} else {
+		mem_cgroup_replace_page_cache(oldpage, newpage);
+		lru_cache_add_anon(newpage);
+		*pagep = newpage;
+	}
 
 	ClearPageSwapCache(oldpage);
 	set_page_private(oldpage, 0);
@@ -1033,7 +1049,7 @@ static int shmem_replace_page(struct pag
 	unlock_page(oldpage);
 	page_cache_release(oldpage);
 	page_cache_release(oldpage);
-	return 0;
+	return error;
 }
 
 /*
@@ -1107,7 +1123,8 @@ repeat:
 
 		/* We have to do this with page locked to prevent races */
 		lock_page(page);
-		if (!PageSwapCache(page) || page->mapping) {
+		if (!PageSwapCache(page) || page_private(page) != swap.val ||
+		    page->mapping) {
 			error = -EEXIST;	/* try again */
 			goto failed;
 		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
