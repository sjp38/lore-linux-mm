Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id B9D726B0055
	for <linux-mm@kvack.org>; Wed, 14 Oct 2009 20:57:31 -0400 (EDT)
Date: Thu, 15 Oct 2009 01:57:28 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: [PATCH 8/9] swap_info: note SWAP_MAP_SHMEM
In-Reply-To: <Pine.LNX.4.64.0910150130001.2250@sister.anvils>
Message-ID: <Pine.LNX.4.64.0910150156060.3291@sister.anvils>
References: <Pine.LNX.4.64.0910150130001.2250@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

While we're fiddling with the swap_map values, let's assign a particular
value to shmem/tmpfs swap pages: their swap counts are never incremented,
and it helps swapoff's try_to_unuse() a little if it can immediately
distinguish those pages from process pages.

Since we've no use for SWAP_MAP_BAD | COUNT_CONTINUED,
we might as well use that 0xbf value for SWAP_MAP_SHMEM.

Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
---

 include/linux/swap.h |    6 +++++
 mm/shmem.c           |   11 +++++++--
 mm/swapfile.c        |   47 +++++++++++++++++++++++------------------
 3 files changed, 42 insertions(+), 22 deletions(-)

--- si7/include/linux/swap.h	2009-10-14 21:26:57.000000000 +0100
+++ si8/include/linux/swap.h	2009-10-14 21:27:07.000000000 +0100
@@ -157,6 +157,7 @@ enum {
 #define SWAP_HAS_CACHE	0x40	/* Flag page is cached, in first swap_map */
 #define SWAP_CONT_MAX	0x7f	/* Max count, in each swap_map continuation */
 #define COUNT_CONTINUED	0x80	/* See swap_map continuation for full count */
+#define SWAP_MAP_SHMEM	0xbf	/* Owned by shmem/tmpfs, in first swap_map */
 
 /*
  * The in-memory structure used to track swap areas.
@@ -315,6 +316,7 @@ extern swp_entry_t get_swap_page(void);
 extern swp_entry_t get_swap_page_of_type(int);
 extern int valid_swaphandles(swp_entry_t, unsigned long *);
 extern int add_swap_count_continuation(swp_entry_t, gfp_t);
+extern void swap_shmem_alloc(swp_entry_t);
 extern int swap_duplicate(swp_entry_t);
 extern int swapcache_prepare(swp_entry_t);
 extern void swap_free(swp_entry_t);
@@ -393,6 +395,10 @@ static inline int add_swap_count_continu
 	return 0;
 }
 
+static inline void swap_shmem_alloc(swp_entry_t swp)
+{
+}
+
 static inline int swap_duplicate(swp_entry_t swp)
 {
 	return 0;
--- si7/mm/shmem.c	2009-09-28 00:28:41.000000000 +0100
+++ si8/mm/shmem.c	2009-10-14 21:27:07.000000000 +0100
@@ -1017,7 +1017,14 @@ int shmem_unuse(swp_entry_t entry, struc
 			goto out;
 	}
 	mutex_unlock(&shmem_swaplist_mutex);
-out:	return found;	/* 0 or 1 or -ENOMEM */
+	/*
+	 * Can some race bring us here?  We've been holding page lock,
+	 * so I think not; but would rather try again later than BUG()
+	 */
+	unlock_page(page);
+	page_cache_release(page);
+out:
+	return (found < 0) ? found : 0;
 }
 
 /*
@@ -1080,7 +1087,7 @@ static int shmem_writepage(struct page *
 		else
 			inode = NULL;
 		spin_unlock(&info->lock);
-		swap_duplicate(swap);
+		swap_shmem_alloc(swap);
 		BUG_ON(page_mapped(page));
 		page_cache_release(page);	/* pagecache ref */
 		swap_writepage(page, wbc);
--- si7/mm/swapfile.c	2009-10-14 21:26:57.000000000 +0100
+++ si8/mm/swapfile.c	2009-10-14 21:27:07.000000000 +0100
@@ -548,6 +548,12 @@ static unsigned char swap_entry_free(str
 	if (usage == SWAP_HAS_CACHE) {
 		VM_BUG_ON(!has_cache);
 		has_cache = 0;
+	} else if (count == SWAP_MAP_SHMEM) {
+		/*
+		 * Or we could insist on shmem.c using a special
+		 * swap_shmem_free() and free_shmem_swap_and_cache()...
+		 */
+		count = 0;
 	} else if ((count & ~COUNT_CONTINUED) <= SWAP_MAP_MAX) {
 		if (count == COUNT_CONTINUED) {
 			if (swap_count_continued(p, offset, count))
@@ -1031,7 +1037,6 @@ static int try_to_unuse(unsigned int typ
 	swp_entry_t entry;
 	unsigned int i = 0;
 	int retval = 0;
-	int shmem;
 
 	/*
 	 * When searching mms for an entry, a good strategy is to
@@ -1107,17 +1112,18 @@ static int try_to_unuse(unsigned int typ
 
 		/*
 		 * Remove all references to entry.
-		 * Whenever we reach init_mm, there's no address space
-		 * to search, but use it as a reminder to search shmem.
 		 */
-		shmem = 0;
 		swcount = *swap_map;
-		if (swap_count(swcount)) {
-			if (start_mm == &init_mm)
-				shmem = shmem_unuse(entry, page);
-			else
-				retval = unuse_mm(start_mm, entry, page);
+		if (swap_count(swcount) == SWAP_MAP_SHMEM) {
+			retval = shmem_unuse(entry, page);
+			/* page has already been unlocked and released */
+			if (retval < 0)
+				break;
+			continue;
 		}
+		if (swap_count(swcount) && start_mm != &init_mm)
+			retval = unuse_mm(start_mm, entry, page);
+
 		if (swap_count(*swap_map)) {
 			int set_start_mm = (*swap_map >= swcount);
 			struct list_head *p = &start_mm->mmlist;
@@ -1128,7 +1134,7 @@ static int try_to_unuse(unsigned int typ
 			atomic_inc(&new_start_mm->mm_users);
 			atomic_inc(&prev_mm->mm_users);
 			spin_lock(&mmlist_lock);
-			while (swap_count(*swap_map) && !retval && !shmem &&
+			while (swap_count(*swap_map) && !retval &&
 					(p = p->next) != &start_mm->mmlist) {
 				mm = list_entry(p, struct mm_struct, mmlist);
 				if (!atomic_inc_not_zero(&mm->mm_users))
@@ -1142,10 +1148,9 @@ static int try_to_unuse(unsigned int typ
 				swcount = *swap_map;
 				if (!swap_count(swcount)) /* any usage ? */
 					;
-				else if (mm == &init_mm) {
+				else if (mm == &init_mm)
 					set_start_mm = 1;
-					shmem = shmem_unuse(entry, page);
-				} else
+				else
 					retval = unuse_mm(mm, entry, page);
 
 				if (set_start_mm &&
@@ -1162,13 +1167,6 @@ static int try_to_unuse(unsigned int typ
 			mmput(start_mm);
 			start_mm = new_start_mm;
 		}
-		if (shmem) {
-			/* page has already been unlocked and released */
-			if (shmem > 0)
-				continue;
-			retval = shmem;
-			break;
-		}
 		if (retval) {
 			unlock_page(page);
 			page_cache_release(page);
@@ -2128,6 +2126,15 @@ bad_file:
 }
 
 /*
+ * Help swapoff by noting that swap entry belongs to shmem/tmpfs
+ * (in which case its reference count is never incremented).
+ */
+void swap_shmem_alloc(swp_entry_t entry)
+{
+	__swap_duplicate(entry, SWAP_MAP_SHMEM);
+}
+
+/*
  * increase reference count of swap entry by 1.
  */
 int swap_duplicate(swp_entry_t entry)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
