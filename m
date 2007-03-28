Date: Wed, 28 Mar 2007 15:51:25 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH 2/4] holepunch: fix shmem_truncate_range punch locking
In-Reply-To: <Pine.LNX.4.64.0703281543230.11119@blonde.wat.veritas.com>
Message-ID: <Pine.LNX.4.64.0703281550300.11726@blonde.wat.veritas.com>
References: <Pine.LNX.4.64.0703281543230.11119@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Miklos Szeredi <mszeredi@suse.cz>, Badari Pulavarty <pbadari@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Miklos Szeredi observes that during truncation of shmem page directories,
info->lock is released to improve latency (after lowering i_size and
next_index to exclude races); but this is quite wrong for holepunching,
which receives no such protection from i_size or next_index, and is left
vulnerable to races with shmem_unuse, shmem_getpage and shmem_writepage.

Hold info->lock throughout when holepunching?  No, any user could prevent
rescheduling for far too long.  Instead take info->lock just when needed:
in shmem_free_swp when removing the swap entries, and whenever removing
a directory page from the level above.  But so long as we remove before
scanning, we can safely skip taking the lock at the lower levels, except
at misaligned start and end of the hole.

Signed-off-by: Hugh Dickins <hugh@veritas.com>
Cc: Miklos Szeredi <mszeredi@suse.cz>
Cc: Badari Pulavarty <pbadari@us.ibm.com>
---
Patch against 1/4: intended for 2.6.21.

 mm/shmem.c |   96 ++++++++++++++++++++++++++++++++++++++-------------
 1 file changed, 73 insertions(+), 23 deletions(-)

--- punch1/mm/shmem.c	2007-03-28 11:50:57.000000000 +0100
+++ punch2/mm/shmem.c	2007-03-28 11:50:58.000000000 +0100
@@ -402,26 +402,38 @@ static swp_entry_t *shmem_swp_alloc(stru
 /*
  * shmem_free_swp - free some swap entries in a directory
  *
- * @dir:   pointer to the directory
- * @edir:  pointer after last entry of the directory
+ * @dir:        pointer to the directory
+ * @edir:       pointer after last entry of the directory
+ * @punch_lock: pointer to spinlock when needed for the holepunch case
  */
-static int shmem_free_swp(swp_entry_t *dir, swp_entry_t *edir)
+static int shmem_free_swp(swp_entry_t *dir, swp_entry_t *edir,
+						spinlock_t *punch_lock)
 {
+	spinlock_t *punch_unlock = NULL;
 	swp_entry_t *ptr;
 	int freed = 0;
 
 	for (ptr = dir; ptr < edir; ptr++) {
 		if (ptr->val) {
+			if (unlikely(punch_lock)) {
+				punch_unlock = punch_lock;
+				punch_lock = NULL;
+				spin_lock(punch_unlock);
+				if (!ptr->val)
+					continue;
+			}
 			free_swap_and_cache(*ptr);
 			*ptr = (swp_entry_t){0};
 			freed++;
 		}
 	}
+	if (punch_unlock)
+		spin_unlock(punch_unlock);
 	return freed;
 }
 
-static int shmem_map_and_free_swp(struct page *subdir,
-		int offset, int limit, struct page ***dir)
+static int shmem_map_and_free_swp(struct page *subdir, int offset,
+		int limit, struct page ***dir, spinlock_t *punch_lock)
 {
 	swp_entry_t *ptr;
 	int freed = 0;
@@ -431,7 +443,8 @@ static int shmem_map_and_free_swp(struct
 		int size = limit - offset;
 		if (size > LATENCY_LIMIT)
 			size = LATENCY_LIMIT;
-		freed += shmem_free_swp(ptr+offset, ptr+offset+size);
+		freed += shmem_free_swp(ptr+offset, ptr+offset+size,
+							punch_lock);
 		if (need_resched()) {
 			shmem_swp_unmap(ptr);
 			if (*dir) {
@@ -482,6 +495,8 @@ static void shmem_truncate_range(struct 
 	int offset;
 	int freed;
 	int punch_hole;
+	spinlock_t *needs_lock;
+	spinlock_t *punch_lock;
 	unsigned long upper_limit;
 
 	inode->i_ctime = inode->i_mtime = CURRENT_TIME;
@@ -495,6 +510,7 @@ static void shmem_truncate_range(struct 
 		limit = info->next_index;
 		upper_limit = SHMEM_MAX_INDEX;
 		info->next_index = idx;
+		needs_lock = NULL;
 		punch_hole = 0;
 	} else {
 		if (end + 1 >= inode->i_size) {	/* we may free a little more */
@@ -505,6 +521,7 @@ static void shmem_truncate_range(struct 
 			limit = (end + 1) >> PAGE_CACHE_SHIFT;
 			upper_limit = limit;
 		}
+		needs_lock = &info->lock;
 		punch_hole = 1;
 	}
 
@@ -521,7 +538,7 @@ static void shmem_truncate_range(struct 
 		size = limit;
 		if (size > SHMEM_NR_DIRECT)
 			size = SHMEM_NR_DIRECT;
-		nr_swaps_freed = shmem_free_swp(ptr+idx, ptr+size);
+		nr_swaps_freed = shmem_free_swp(ptr+idx, ptr+size, needs_lock);
 	}
 
 	/*
@@ -531,6 +548,19 @@ static void shmem_truncate_range(struct 
 	if (!topdir || limit <= SHMEM_NR_DIRECT)
 		goto done2;
 
+	/*
+	 * The truncation case has already dropped info->lock, and we're safe
+	 * because i_size and next_index have already been lowered, preventing
+	 * access beyond.  But in the punch_hole case, we still need to take
+	 * the lock when updating the swap directory, because there might be
+	 * racing accesses by shmem_getpage(SGP_CACHE), shmem_unuse_inode or
+	 * shmem_writepage.  However, whenever we find we can remove a whole
+	 * directory page (not at the misaligned start or end of the range),
+	 * we first NULLify its pointer in the level above, and then have no
+	 * need to take the lock when updating its contents: needs_lock and
+	 * punch_lock (either pointing to info->lock or NULL) manage this.
+	 */
+
 	upper_limit -= SHMEM_NR_DIRECT;
 	limit -= SHMEM_NR_DIRECT;
 	idx = (idx > SHMEM_NR_DIRECT)? (idx - SHMEM_NR_DIRECT): 0;
@@ -552,7 +582,13 @@ static void shmem_truncate_range(struct 
 			diroff = ((idx - ENTRIES_PER_PAGEPAGE/2) %
 				ENTRIES_PER_PAGEPAGE) / ENTRIES_PER_PAGE;
 			if (!diroff && !offset && upper_limit >= stage) {
-				*dir = NULL;
+				if (needs_lock) {
+					spin_lock(needs_lock);
+					*dir = NULL;
+					spin_unlock(needs_lock);
+					needs_lock = NULL;
+				} else
+					*dir = NULL;
 				nr_pages_to_free++;
 				list_add(&middir->lru, &pages_to_free);
 			}
@@ -578,8 +614,16 @@ static void shmem_truncate_range(struct 
 			}
 			stage = idx + ENTRIES_PER_PAGEPAGE;
 			middir = *dir;
+			if (punch_hole)
+				needs_lock = &info->lock;
 			if (upper_limit >= stage) {
-				*dir = NULL;
+				if (needs_lock) {
+					spin_lock(needs_lock);
+					*dir = NULL;
+					spin_unlock(needs_lock);
+					needs_lock = NULL;
+				} else
+					*dir = NULL;
 				nr_pages_to_free++;
 				list_add(&middir->lru, &pages_to_free);
 			}
@@ -588,31 +632,37 @@ static void shmem_truncate_range(struct 
 			dir = shmem_dir_map(middir);
 			diroff = 0;
 		}
+		punch_lock = needs_lock;
 		subdir = dir[diroff];
-		if (subdir && page_private(subdir)) {
+		if (subdir && !offset && upper_limit-idx >= ENTRIES_PER_PAGE) {
+			if (needs_lock) {
+				spin_lock(needs_lock);
+				dir[diroff] = NULL;
+				spin_unlock(needs_lock);
+				punch_lock = NULL;
+			} else
+				dir[diroff] = NULL;
+			nr_pages_to_free++;
+			list_add(&subdir->lru, &pages_to_free);
+		}
+		if (subdir && page_private(subdir) /* has swap entries */) {
 			size = limit - idx;
 			if (size > ENTRIES_PER_PAGE)
 				size = ENTRIES_PER_PAGE;
 			freed = shmem_map_and_free_swp(subdir,
-						offset, size, &dir);
+					offset, size, &dir, punch_lock);
 			if (!dir)
 				dir = shmem_dir_map(middir);
 			nr_swaps_freed += freed;
-			if (offset)
+			if (offset || punch_lock) {
 				spin_lock(&info->lock);
-			set_page_private(subdir, page_private(subdir) - freed);
-			if (offset)
+				set_page_private(subdir,
+					page_private(subdir) - freed);
 				spin_unlock(&info->lock);
-			if (!punch_hole)
-				BUG_ON(page_private(subdir) > offset);
-		}
-		if (offset)
-			offset = 0;
-		else if (subdir && upper_limit - idx >= ENTRIES_PER_PAGE) {
-			dir[diroff] = NULL;
-			nr_pages_to_free++;
-			list_add(&subdir->lru, &pages_to_free);
+			} else
+				BUG_ON(page_private(subdir) != freed);
 		}
+		offset = 0;
 	}
 done1:
 	shmem_dir_unmap(dir);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
