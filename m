Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 1041A6B0083
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 06:45:19 -0400 (EDT)
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id p5EAjE7v001064
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 03:45:14 -0700
Received: from pzk9 (pzk9.prod.google.com [10.243.19.137])
	by wpaz1.hot.corp.google.com with ESMTP id p5EAj0dg023656
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 03:45:12 -0700
Received: by pzk9 with SMTP id 9so3423388pzk.33
        for <linux-mm@kvack.org>; Tue, 14 Jun 2011 03:45:12 -0700 (PDT)
Date: Tue, 14 Jun 2011 03:45:01 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 3/12] tmpfs: demolish old swap vector support
In-Reply-To: <alpine.LSU.2.00.1106140327550.29206@sister.anvils>
Message-ID: <alpine.LSU.2.00.1106140343520.29206@sister.anvils>
References: <alpine.LSU.2.00.1106140327550.29206@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

The maximum size of a shmem/tmpfs file has been limited by the maximum
size of its triple-indirect swap vector.  With 4kB page size, maximum
filesize was just over 2TB on a 32-bit kernel, but sadly one eighth of
that on a 64-bit kernel.  (With 8kB page size, maximum filesize was
just over 4TB on a 64-bit kernel, but 16TB on a 32-bit kernel,
MAX_LFS_FILESIZE being then more restrictive than swap vector layout.)

It's a shame that tmpfs should be more restrictive than ramfs, and this
limitation has now been noticed.  Add another level to the swap vector?
No, it became obscure and hard to maintain, once I complicated it to
make use of highmem pages nine years ago: better choose another way.

Surely, if 2.4 had had the radix tree pagecache introduced in 2.5,
then tmpfs would never have invented its own peculiar radix tree:
we would have fitted swap entries into the common radix tree instead,
in much the same way as we fit swap entries into page tables.

And why should each file have a separate radix tree for its pages
and for its swap entries?  The swap entries are required precisely
where and when the pages are not.  We want to put them together in
a single radix tree: which can then avoid much of the locking which
was needed to prevent them from being exchanged underneath us.

This also avoids the waste of memory devoted to swap vectors, first
in the shmem_inode itself, then at least two more pages once a file
grew beyond 16 data pages (pages accounted by df and du, but not by
memcg).  Allocated upfront, to avoid allocation when under swapping
pressure, but pure waste when CONFIG_SWAP is not set - I have never
spattered around the ifdefs to prevent that, preferring this move
to sharing the common radix tree instead.

There are three downsides to sharing the radix tree.  One, that it
binds tmpfs more tightly to the rest of mm, either requiring knowledge
of swap entries in radix tree there, or duplication of its code here
in shmem.c.  I believe that the simplications and memory savings
(and probable higher performance, not yet measured) justify that.

Two, that on HIGHMEM systems with SWAP enabled, it's the lowmem radix
nodes that cannot be freed under memory pressure - whereas before it
was the less precious highmem swap vector pages that could not be freed.
I'm hoping that 64-bit has now been accessible for long enough, that
the highmem argument has grown much less persuasive.

Three, that swapoff is slower than it used to be on tmpfs files, since
it's using a simple generic mechanism not tailored to it: I find this
noticeable, and shall want to improve, but maybe nobody else will notice.

So... now remove most of the old swap vector code from shmem.c.  But,
for the moment, keep the simple i_direct vector of 16 pages, with simple
accessors shmem_put_swap() and shmem_get_swap(), as a toy implementation
to help mark where swap needs to be handled in subsequent patches.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 include/linux/shmem_fs.h |    2 
 mm/shmem.c               |  782 +++----------------------------------
 2 files changed, 84 insertions(+), 700 deletions(-)

--- linux.orig/include/linux/shmem_fs.h	2011-06-13 13:26:07.446100738 -0700
+++ linux/include/linux/shmem_fs.h	2011-06-13 13:27:59.634657055 -0700
@@ -17,9 +17,7 @@ struct shmem_inode_info {
 	unsigned long		flags;
 	unsigned long		alloced;	/* data pages alloced to file */
 	unsigned long		swapped;	/* subtotal assigned to swap */
-	unsigned long		next_index;	/* highest alloced index + 1 */
 	struct shared_policy	policy;		/* NUMA memory alloc policy */
-	struct page		*i_indirect;	/* top indirect blocks page */
 	union {
 		swp_entry_t	i_direct[SHMEM_NR_DIRECT]; /* first blocks */
 		char		inline_symlink[SHMEM_SYMLINK_INLINE_LEN];
--- linux.orig/mm/shmem.c	2011-06-13 13:26:07.446100738 -0700
+++ linux/mm/shmem.c	2011-06-13 13:27:59.634657055 -0700
@@ -66,37 +66,9 @@ static struct vfsmount *shm_mnt;
 #include <asm/div64.h>
 #include <asm/pgtable.h>
 
-/*
- * The maximum size of a shmem/tmpfs file is limited by the maximum size of
- * its triple-indirect swap vector - see illustration at shmem_swp_entry().
- *
- * With 4kB page size, maximum file size is just over 2TB on a 32-bit kernel,
- * but one eighth of that on a 64-bit kernel.  With 8kB page size, maximum
- * file size is just over 4TB on a 64-bit kernel, but 16TB on a 32-bit kernel,
- * MAX_LFS_FILESIZE being then more restrictive than swap vector layout.
- *
- * We use / and * instead of shifts in the definitions below, so that the swap
- * vector can be tested with small even values (e.g. 20) for ENTRIES_PER_PAGE.
- */
-#define ENTRIES_PER_PAGE (PAGE_CACHE_SIZE/sizeof(unsigned long))
-#define ENTRIES_PER_PAGEPAGE ((unsigned long long)ENTRIES_PER_PAGE*ENTRIES_PER_PAGE)
-
-#define SHMSWP_MAX_INDEX (SHMEM_NR_DIRECT + (ENTRIES_PER_PAGEPAGE/2) * (ENTRIES_PER_PAGE+1))
-#define SHMSWP_MAX_BYTES (SHMSWP_MAX_INDEX << PAGE_CACHE_SHIFT)
-
-#define SHMEM_MAX_BYTES  min_t(unsigned long long, SHMSWP_MAX_BYTES, MAX_LFS_FILESIZE)
-#define SHMEM_MAX_INDEX  ((unsigned long)((SHMEM_MAX_BYTES+1) >> PAGE_CACHE_SHIFT))
-
 #define BLOCKS_PER_PAGE  (PAGE_CACHE_SIZE/512)
 #define VM_ACCT(size)    (PAGE_CACHE_ALIGN(size) >> PAGE_SHIFT)
 
-/* info->flags needs VM_flags to handle pagein/truncate races efficiently */
-#define SHMEM_PAGEIN	 VM_READ
-#define SHMEM_TRUNCATE	 VM_WRITE
-
-/* Definition to limit shmem_truncate's steps between cond_rescheds */
-#define LATENCY_LIMIT	 64
-
 /* Pretend that each entry is of this size in directory's i_size */
 #define BOGO_DIRENT_SIZE 20
 
@@ -107,7 +79,7 @@ struct shmem_xattr {
 	char value[0];
 };
 
-/* Flag allocation requirements to shmem_getpage and shmem_swp_alloc */
+/* Flag allocation requirements to shmem_getpage */
 enum sgp_type {
 	SGP_READ,	/* don't exceed i_size, don't allocate page */
 	SGP_CACHE,	/* don't exceed i_size, may allocate page */
@@ -137,56 +109,6 @@ static inline int shmem_getpage(struct i
 			mapping_gfp_mask(inode->i_mapping), fault_type);
 }
 
-static inline struct page *shmem_dir_alloc(gfp_t gfp_mask)
-{
-	/*
-	 * The above definition of ENTRIES_PER_PAGE, and the use of
-	 * BLOCKS_PER_PAGE on indirect pages, assume PAGE_CACHE_SIZE:
-	 * might be reconsidered if it ever diverges from PAGE_SIZE.
-	 *
-	 * Mobility flags are masked out as swap vectors cannot move
-	 */
-	return alloc_pages((gfp_mask & ~GFP_MOVABLE_MASK) | __GFP_ZERO,
-				PAGE_CACHE_SHIFT-PAGE_SHIFT);
-}
-
-static inline void shmem_dir_free(struct page *page)
-{
-	__free_pages(page, PAGE_CACHE_SHIFT-PAGE_SHIFT);
-}
-
-static struct page **shmem_dir_map(struct page *page)
-{
-	return (struct page **)kmap_atomic(page, KM_USER0);
-}
-
-static inline void shmem_dir_unmap(struct page **dir)
-{
-	kunmap_atomic(dir, KM_USER0);
-}
-
-static swp_entry_t *shmem_swp_map(struct page *page)
-{
-	return (swp_entry_t *)kmap_atomic(page, KM_USER1);
-}
-
-static inline void shmem_swp_balance_unmap(void)
-{
-	/*
-	 * When passing a pointer to an i_direct entry, to code which
-	 * also handles indirect entries and so will shmem_swp_unmap,
-	 * we must arrange for the preempt count to remain in balance.
-	 * What kmap_atomic of a lowmem page does depends on config
-	 * and architecture, so pretend to kmap_atomic some lowmem page.
-	 */
-	(void) kmap_atomic(ZERO_PAGE(0), KM_USER1);
-}
-
-static inline void shmem_swp_unmap(swp_entry_t *entry)
-{
-	kunmap_atomic(entry, KM_USER1);
-}
-
 static inline struct shmem_sb_info *SHMEM_SB(struct super_block *sb)
 {
 	return sb->s_fs_info;
@@ -303,468 +225,56 @@ static void shmem_recalc_inode(struct in
 	}
 }
 
-/**
- * shmem_swp_entry - find the swap vector position in the info structure
- * @info:  info structure for the inode
- * @index: index of the page to find
- * @page:  optional page to add to the structure. Has to be preset to
- *         all zeros
- *
- * If there is no space allocated yet it will return NULL when
- * page is NULL, else it will use the page for the needed block,
- * setting it to NULL on return to indicate that it has been used.
- *
- * The swap vector is organized the following way:
- *
- * There are SHMEM_NR_DIRECT entries directly stored in the
- * shmem_inode_info structure. So small files do not need an addional
- * allocation.
- *
- * For pages with index > SHMEM_NR_DIRECT there is the pointer
- * i_indirect which points to a page which holds in the first half
- * doubly indirect blocks, in the second half triple indirect blocks:
- *
- * For an artificial ENTRIES_PER_PAGE = 4 this would lead to the
- * following layout (for SHMEM_NR_DIRECT == 16):
- *
- * i_indirect -> dir --> 16-19
- * 	      |	     +-> 20-23
- * 	      |
- * 	      +-->dir2 --> 24-27
- * 	      |	       +-> 28-31
- * 	      |	       +-> 32-35
- * 	      |	       +-> 36-39
- * 	      |
- * 	      +-->dir3 --> 40-43
- * 	       	       +-> 44-47
- * 	      	       +-> 48-51
- * 	      	       +-> 52-55
- */
-static swp_entry_t *shmem_swp_entry(struct shmem_inode_info *info, unsigned long index, struct page **page)
-{
-	unsigned long offset;
-	struct page **dir;
-	struct page *subdir;
-
-	if (index < SHMEM_NR_DIRECT) {
-		shmem_swp_balance_unmap();
-		return info->i_direct+index;
-	}
-	if (!info->i_indirect) {
-		if (page) {
-			info->i_indirect = *page;
-			*page = NULL;
-		}
-		return NULL;			/* need another page */
-	}
-
-	index -= SHMEM_NR_DIRECT;
-	offset = index % ENTRIES_PER_PAGE;
-	index /= ENTRIES_PER_PAGE;
-	dir = shmem_dir_map(info->i_indirect);
-
-	if (index >= ENTRIES_PER_PAGE/2) {
-		index -= ENTRIES_PER_PAGE/2;
-		dir += ENTRIES_PER_PAGE/2 + index/ENTRIES_PER_PAGE;
-		index %= ENTRIES_PER_PAGE;
-		subdir = *dir;
-		if (!subdir) {
-			if (page) {
-				*dir = *page;
-				*page = NULL;
-			}
-			shmem_dir_unmap(dir);
-			return NULL;		/* need another page */
-		}
-		shmem_dir_unmap(dir);
-		dir = shmem_dir_map(subdir);
-	}
-
-	dir += index;
-	subdir = *dir;
-	if (!subdir) {
-		if (!page || !(subdir = *page)) {
-			shmem_dir_unmap(dir);
-			return NULL;		/* need a page */
-		}
-		*dir = subdir;
-		*page = NULL;
-	}
-	shmem_dir_unmap(dir);
-	return shmem_swp_map(subdir) + offset;
-}
-
-static void shmem_swp_set(struct shmem_inode_info *info, swp_entry_t *entry, unsigned long value)
+static void shmem_put_swap(struct shmem_inode_info *info, pgoff_t index,
+			   swp_entry_t swap)
 {
-	long incdec = value? 1: -1;
-
-	entry->val = value;
-	info->swapped += incdec;
-	if ((unsigned long)(entry - info->i_direct) >= SHMEM_NR_DIRECT) {
-		struct page *page = kmap_atomic_to_page(entry);
-		set_page_private(page, page_private(page) + incdec);
-	}
+	if (index < SHMEM_NR_DIRECT)
+		info->i_direct[index] = swap;
 }
 
-/**
- * shmem_swp_alloc - get the position of the swap entry for the page.
- * @info:	info structure for the inode
- * @index:	index of the page to find
- * @sgp:	check and recheck i_size? skip allocation?
- * @gfp:	gfp mask to use for any page allocation
- *
- * If the entry does not exist, allocate it.
- */
-static swp_entry_t *shmem_swp_alloc(struct shmem_inode_info *info,
-			unsigned long index, enum sgp_type sgp, gfp_t gfp)
+static swp_entry_t shmem_get_swap(struct shmem_inode_info *info, pgoff_t index)
 {
-	struct inode *inode = &info->vfs_inode;
-	struct shmem_sb_info *sbinfo = SHMEM_SB(inode->i_sb);
-	struct page *page = NULL;
-	swp_entry_t *entry;
-
-	if (sgp != SGP_WRITE &&
-	    ((loff_t) index << PAGE_CACHE_SHIFT) >= i_size_read(inode))
-		return ERR_PTR(-EINVAL);
-
-	while (!(entry = shmem_swp_entry(info, index, &page))) {
-		if (sgp == SGP_READ)
-			return shmem_swp_map(ZERO_PAGE(0));
-		/*
-		 * Test used_blocks against 1 less max_blocks, since we have 1 data
-		 * page (and perhaps indirect index pages) yet to allocate:
-		 * a waste to allocate index if we cannot allocate data.
-		 */
-		if (sbinfo->max_blocks) {
-			if (percpu_counter_compare(&sbinfo->used_blocks,
-						sbinfo->max_blocks - 1) >= 0)
-				return ERR_PTR(-ENOSPC);
-			percpu_counter_inc(&sbinfo->used_blocks);
-			inode->i_blocks += BLOCKS_PER_PAGE;
-		}
-
-		spin_unlock(&info->lock);
-		page = shmem_dir_alloc(gfp);
-		spin_lock(&info->lock);
-
-		if (!page) {
-			shmem_free_blocks(inode, 1);
-			return ERR_PTR(-ENOMEM);
-		}
-		if (sgp != SGP_WRITE &&
-		    ((loff_t) index << PAGE_CACHE_SHIFT) >= i_size_read(inode)) {
-			entry = ERR_PTR(-EINVAL);
-			break;
-		}
-		if (info->next_index <= index)
-			info->next_index = index + 1;
-	}
-	if (page) {
-		/* another task gave its page, or truncated the file */
-		shmem_free_blocks(inode, 1);
-		shmem_dir_free(page);
-	}
-	if (info->next_index <= index && !IS_ERR(entry))
-		info->next_index = index + 1;
-	return entry;
+	return (index < SHMEM_NR_DIRECT) ?
+		info->i_direct[index] : (swp_entry_t){0};
 }
 
-/**
- * shmem_free_swp - free some swap entries in a directory
- * @dir:        pointer to the directory
- * @edir:       pointer after last entry of the directory
- * @punch_lock: pointer to spinlock when needed for the holepunch case
- */
-static int shmem_free_swp(swp_entry_t *dir, swp_entry_t *edir,
-						spinlock_t *punch_lock)
-{
-	spinlock_t *punch_unlock = NULL;
-	swp_entry_t *ptr;
-	int freed = 0;
-
-	for (ptr = dir; ptr < edir; ptr++) {
-		if (ptr->val) {
-			if (unlikely(punch_lock)) {
-				punch_unlock = punch_lock;
-				punch_lock = NULL;
-				spin_lock(punch_unlock);
-				if (!ptr->val)
-					continue;
-			}
-			free_swap_and_cache(*ptr);
-			*ptr = (swp_entry_t){0};
-			freed++;
-		}
-	}
-	if (punch_unlock)
-		spin_unlock(punch_unlock);
-	return freed;
-}
-
-static int shmem_map_and_free_swp(struct page *subdir, int offset,
-		int limit, struct page ***dir, spinlock_t *punch_lock)
-{
-	swp_entry_t *ptr;
-	int freed = 0;
-
-	ptr = shmem_swp_map(subdir);
-	for (; offset < limit; offset += LATENCY_LIMIT) {
-		int size = limit - offset;
-		if (size > LATENCY_LIMIT)
-			size = LATENCY_LIMIT;
-		freed += shmem_free_swp(ptr+offset, ptr+offset+size,
-							punch_lock);
-		if (need_resched()) {
-			shmem_swp_unmap(ptr);
-			if (*dir) {
-				shmem_dir_unmap(*dir);
-				*dir = NULL;
-			}
-			cond_resched();
-			ptr = shmem_swp_map(subdir);
-		}
-	}
-	shmem_swp_unmap(ptr);
-	return freed;
-}
-
-static void shmem_free_pages(struct list_head *next)
-{
-	struct page *page;
-	int freed = 0;
-
-	do {
-		page = container_of(next, struct page, lru);
-		next = next->next;
-		shmem_dir_free(page);
-		freed++;
-		if (freed >= LATENCY_LIMIT) {
-			cond_resched();
-			freed = 0;
-		}
-	} while (next);
-}
-
-void shmem_truncate_range(struct inode *inode, loff_t start, loff_t end)
+void shmem_truncate_range(struct inode *inode, loff_t lstart, loff_t lend)
 {
+	struct address_space *mapping = inode->i_mapping;
 	struct shmem_inode_info *info = SHMEM_I(inode);
-	unsigned long idx;
-	unsigned long size;
-	unsigned long limit;
-	unsigned long stage;
-	unsigned long diroff;
-	struct page **dir;
-	struct page *topdir;
-	struct page *middir;
-	struct page *subdir;
-	swp_entry_t *ptr;
-	LIST_HEAD(pages_to_free);
-	long nr_pages_to_free = 0;
-	long nr_swaps_freed = 0;
-	int offset;
-	int freed;
-	int punch_hole;
-	spinlock_t *needs_lock;
-	spinlock_t *punch_lock;
-	unsigned long upper_limit;
+	pgoff_t start = (lstart + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
+	pgoff_t end = (lend >> PAGE_CACHE_SHIFT);
+	pgoff_t index;
+	swp_entry_t swap;
 
-	truncate_inode_pages_range(inode->i_mapping, start, end);
+	truncate_inode_pages_range(mapping, lstart, lend);
 
-	inode->i_ctime = inode->i_mtime = CURRENT_TIME;
-	idx = (start + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
-	if (idx >= info->next_index)
-		return;
+	if (end > SHMEM_NR_DIRECT)
+		end = SHMEM_NR_DIRECT;
 
 	spin_lock(&info->lock);
-	info->flags |= SHMEM_TRUNCATE;
-	if (likely(end == (loff_t) -1)) {
-		limit = info->next_index;
-		upper_limit = SHMEM_MAX_INDEX;
-		info->next_index = idx;
-		needs_lock = NULL;
-		punch_hole = 0;
-	} else {
-		if (end + 1 >= inode->i_size) {	/* we may free a little more */
-			limit = (inode->i_size + PAGE_CACHE_SIZE - 1) >>
-							PAGE_CACHE_SHIFT;
-			upper_limit = SHMEM_MAX_INDEX;
-		} else {
-			limit = (end + 1) >> PAGE_CACHE_SHIFT;
-			upper_limit = limit;
-		}
-		needs_lock = &info->lock;
-		punch_hole = 1;
-	}
-
-	topdir = info->i_indirect;
-	if (topdir && idx <= SHMEM_NR_DIRECT && !punch_hole) {
-		info->i_indirect = NULL;
-		nr_pages_to_free++;
-		list_add(&topdir->lru, &pages_to_free);
-	}
-	spin_unlock(&info->lock);
-
-	if (info->swapped && idx < SHMEM_NR_DIRECT) {
-		ptr = info->i_direct;
-		size = limit;
-		if (size > SHMEM_NR_DIRECT)
-			size = SHMEM_NR_DIRECT;
-		nr_swaps_freed = shmem_free_swp(ptr+idx, ptr+size, needs_lock);
-	}
-
-	/*
-	 * If there are no indirect blocks or we are punching a hole
-	 * below indirect blocks, nothing to be done.
-	 */
-	if (!topdir || limit <= SHMEM_NR_DIRECT)
-		goto done2;
-
-	/*
-	 * The truncation case has already dropped info->lock, and we're safe
-	 * because i_size and next_index have already been lowered, preventing
-	 * access beyond.  But in the punch_hole case, we still need to take
-	 * the lock when updating the swap directory, because there might be
-	 * racing accesses by shmem_getpage(SGP_CACHE), shmem_unuse_inode or
-	 * shmem_writepage.  However, whenever we find we can remove a whole
-	 * directory page (not at the misaligned start or end of the range),
-	 * we first NULLify its pointer in the level above, and then have no
-	 * need to take the lock when updating its contents: needs_lock and
-	 * punch_lock (either pointing to info->lock or NULL) manage this.
-	 */
-
-	upper_limit -= SHMEM_NR_DIRECT;
-	limit -= SHMEM_NR_DIRECT;
-	idx = (idx > SHMEM_NR_DIRECT)? (idx - SHMEM_NR_DIRECT): 0;
-	offset = idx % ENTRIES_PER_PAGE;
-	idx -= offset;
-
-	dir = shmem_dir_map(topdir);
-	stage = ENTRIES_PER_PAGEPAGE/2;
-	if (idx < ENTRIES_PER_PAGEPAGE/2) {
-		middir = topdir;
-		diroff = idx/ENTRIES_PER_PAGE;
-	} else {
-		dir += ENTRIES_PER_PAGE/2;
-		dir += (idx - ENTRIES_PER_PAGEPAGE/2)/ENTRIES_PER_PAGEPAGE;
-		while (stage <= idx)
-			stage += ENTRIES_PER_PAGEPAGE;
-		middir = *dir;
-		if (*dir) {
-			diroff = ((idx - ENTRIES_PER_PAGEPAGE/2) %
-				ENTRIES_PER_PAGEPAGE) / ENTRIES_PER_PAGE;
-			if (!diroff && !offset && upper_limit >= stage) {
-				if (needs_lock) {
-					spin_lock(needs_lock);
-					*dir = NULL;
-					spin_unlock(needs_lock);
-					needs_lock = NULL;
-				} else
-					*dir = NULL;
-				nr_pages_to_free++;
-				list_add(&middir->lru, &pages_to_free);
-			}
-			shmem_dir_unmap(dir);
-			dir = shmem_dir_map(middir);
-		} else {
-			diroff = 0;
-			offset = 0;
-			idx = stage;
+	for (index = start; index < end; index++) {
+		swap = shmem_get_swap(info, index);
+		if (swap.val) {
+			free_swap_and_cache(swap);
+			shmem_put_swap(info, index, (swp_entry_t){0});
+			info->swapped--;
 		}
 	}
 
-	for (; idx < limit; idx += ENTRIES_PER_PAGE, diroff++) {
-		if (unlikely(idx == stage)) {
-			shmem_dir_unmap(dir);
-			dir = shmem_dir_map(topdir) +
-			    ENTRIES_PER_PAGE/2 + idx/ENTRIES_PER_PAGEPAGE;
-			while (!*dir) {
-				dir++;
-				idx += ENTRIES_PER_PAGEPAGE;
-				if (idx >= limit)
-					goto done1;
-			}
-			stage = idx + ENTRIES_PER_PAGEPAGE;
-			middir = *dir;
-			if (punch_hole)
-				needs_lock = &info->lock;
-			if (upper_limit >= stage) {
-				if (needs_lock) {
-					spin_lock(needs_lock);
-					*dir = NULL;
-					spin_unlock(needs_lock);
-					needs_lock = NULL;
-				} else
-					*dir = NULL;
-				nr_pages_to_free++;
-				list_add(&middir->lru, &pages_to_free);
-			}
-			shmem_dir_unmap(dir);
-			cond_resched();
-			dir = shmem_dir_map(middir);
-			diroff = 0;
-		}
-		punch_lock = needs_lock;
-		subdir = dir[diroff];
-		if (subdir && !offset && upper_limit-idx >= ENTRIES_PER_PAGE) {
-			if (needs_lock) {
-				spin_lock(needs_lock);
-				dir[diroff] = NULL;
-				spin_unlock(needs_lock);
-				punch_lock = NULL;
-			} else
-				dir[diroff] = NULL;
-			nr_pages_to_free++;
-			list_add(&subdir->lru, &pages_to_free);
-		}
-		if (subdir && page_private(subdir) /* has swap entries */) {
-			size = limit - idx;
-			if (size > ENTRIES_PER_PAGE)
-				size = ENTRIES_PER_PAGE;
-			freed = shmem_map_and_free_swp(subdir,
-					offset, size, &dir, punch_lock);
-			if (!dir)
-				dir = shmem_dir_map(middir);
-			nr_swaps_freed += freed;
-			if (offset || punch_lock) {
-				spin_lock(&info->lock);
-				set_page_private(subdir,
-					page_private(subdir) - freed);
-				spin_unlock(&info->lock);
-			} else
-				BUG_ON(page_private(subdir) != freed);
-		}
-		offset = 0;
-	}
-done1:
-	shmem_dir_unmap(dir);
-done2:
-	if (inode->i_mapping->nrpages && (info->flags & SHMEM_PAGEIN)) {
+	if (mapping->nrpages) {
+		spin_unlock(&info->lock);
 		/*
-		 * Call truncate_inode_pages again: racing shmem_unuse_inode
-		 * may have swizzled a page in from swap since
-		 * truncate_pagecache or generic_delete_inode did it, before we
-		 * lowered next_index.  Also, though shmem_getpage checks
-		 * i_size before adding to cache, no recheck after: so fix the
-		 * narrow window there too.
+		 * A page may have meanwhile sneaked in from swap.
 		 */
-		truncate_inode_pages_range(inode->i_mapping, start, end);
+		truncate_inode_pages_range(mapping, lstart, lend);
+		spin_lock(&info->lock);
 	}
 
-	spin_lock(&info->lock);
-	info->flags &= ~SHMEM_TRUNCATE;
-	info->swapped -= nr_swaps_freed;
-	if (nr_pages_to_free)
-		shmem_free_blocks(inode, nr_pages_to_free);
 	shmem_recalc_inode(inode);
 	spin_unlock(&info->lock);
 
-	/*
-	 * Empty swap vector directory pages to be freed?
-	 */
-	if (!list_empty(&pages_to_free)) {
-		pages_to_free.prev->next = NULL;
-		shmem_free_pages(pages_to_free.next);
-	}
+	inode->i_ctime = inode->i_mtime = CURRENT_TIME;
 }
 EXPORT_SYMBOL_GPL(shmem_truncate_range);
 
@@ -797,19 +307,6 @@ static int shmem_setattr(struct dentry *
 				if (page)
 					unlock_page(page);
 			}
-			/*
-			 * Reset SHMEM_PAGEIN flag so that shmem_truncate can
-			 * detect if any pages might have been added to cache
-			 * after truncate_inode_pages.  But we needn't bother
-			 * if it's being fully truncated to zero-length: the
-			 * nrpages check is efficient enough in that case.
-			 */
-			if (newsize) {
-				struct shmem_inode_info *info = SHMEM_I(inode);
-				spin_lock(&info->lock);
-				info->flags &= ~SHMEM_PAGEIN;
-				spin_unlock(&info->lock);
-			}
 		}
 		if (newsize != oldsize) {
 			i_size_write(inode, newsize);
@@ -859,106 +356,28 @@ static void shmem_evict_inode(struct ino
 	end_writeback(inode);
 }
 
-static inline int shmem_find_swp(swp_entry_t entry, swp_entry_t *dir, swp_entry_t *edir)
-{
-	swp_entry_t *ptr;
-
-	for (ptr = dir; ptr < edir; ptr++) {
-		if (ptr->val == entry.val)
-			return ptr - dir;
-	}
-	return -1;
-}
-
 static int shmem_unuse_inode(struct shmem_inode_info *info, swp_entry_t entry, struct page *page)
 {
-	struct address_space *mapping;
+	struct address_space *mapping = info->vfs_inode.i_mapping;
 	unsigned long idx;
-	unsigned long size;
-	unsigned long limit;
-	unsigned long stage;
-	struct page **dir;
-	struct page *subdir;
-	swp_entry_t *ptr;
-	int offset;
 	int error;
 
-	idx = 0;
-	ptr = info->i_direct;
-	spin_lock(&info->lock);
-	if (!info->swapped) {
-		list_del_init(&info->swaplist);
-		goto lost2;
-	}
-	limit = info->next_index;
-	size = limit;
-	if (size > SHMEM_NR_DIRECT)
-		size = SHMEM_NR_DIRECT;
-	offset = shmem_find_swp(entry, ptr, ptr+size);
-	if (offset >= 0) {
-		shmem_swp_balance_unmap();
-		goto found;
-	}
-	if (!info->i_indirect)
-		goto lost2;
-
-	dir = shmem_dir_map(info->i_indirect);
-	stage = SHMEM_NR_DIRECT + ENTRIES_PER_PAGEPAGE/2;
-
-	for (idx = SHMEM_NR_DIRECT; idx < limit; idx += ENTRIES_PER_PAGE, dir++) {
-		if (unlikely(idx == stage)) {
-			shmem_dir_unmap(dir-1);
-			if (cond_resched_lock(&info->lock)) {
-				/* check it has not been truncated */
-				if (limit > info->next_index) {
-					limit = info->next_index;
-					if (idx >= limit)
-						goto lost2;
-				}
-			}
-			dir = shmem_dir_map(info->i_indirect) +
-			    ENTRIES_PER_PAGE/2 + idx/ENTRIES_PER_PAGEPAGE;
-			while (!*dir) {
-				dir++;
-				idx += ENTRIES_PER_PAGEPAGE;
-				if (idx >= limit)
-					goto lost1;
-			}
-			stage = idx + ENTRIES_PER_PAGEPAGE;
-			subdir = *dir;
-			shmem_dir_unmap(dir);
-			dir = shmem_dir_map(subdir);
-		}
-		subdir = *dir;
-		if (subdir && page_private(subdir)) {
-			ptr = shmem_swp_map(subdir);
-			size = limit - idx;
-			if (size > ENTRIES_PER_PAGE)
-				size = ENTRIES_PER_PAGE;
-			offset = shmem_find_swp(entry, ptr, ptr+size);
-			shmem_swp_unmap(ptr);
-			if (offset >= 0) {
-				shmem_dir_unmap(dir);
-				ptr = shmem_swp_map(subdir);
-				goto found;
-			}
-		}
-	}
-lost1:
-	shmem_dir_unmap(dir-1);
-lost2:
-	spin_unlock(&info->lock);
+	for (idx = 0; idx < SHMEM_NR_DIRECT; idx++)
+		if (shmem_get_swap(info, idx).val == entry.val)
+			goto found;
 	return 0;
 found:
-	idx += offset;
-	ptr += offset;
+	spin_lock(&info->lock);
+	if (shmem_get_swap(info, idx).val != entry.val) {
+		spin_unlock(&info->lock);
+		return 0;
+	}
 
 	/*
 	 * Move _head_ to start search for next from here.
 	 * But be careful: shmem_evict_inode checks list_empty without taking
 	 * mutex, and there's an instant in list_move_tail when info->swaplist
-	 * would appear empty, if it were the only one on shmem_swaplist.  We
-	 * could avoid doing it if inode NULL; or use this minor optimization.
+	 * would appear empty, if it were the only one on shmem_swaplist.
 	 */
 	if (shmem_swaplist.next != &info->swaplist)
 		list_move_tail(&shmem_swaplist, &info->swaplist);
@@ -968,19 +387,17 @@ found:
 	 * but also to hold up shmem_evict_inode(): so inode cannot be freed
 	 * beneath us (pagelock doesn't help until the page is in pagecache).
 	 */
-	mapping = info->vfs_inode.i_mapping;
 	error = add_to_page_cache_locked(page, mapping, idx, GFP_NOWAIT);
 	/* which does mem_cgroup_uncharge_cache_page on error */
 
 	if (error != -ENOMEM) {
 		delete_from_swap_cache(page);
 		set_page_dirty(page);
-		info->flags |= SHMEM_PAGEIN;
-		shmem_swp_set(info, ptr, 0);
+		shmem_put_swap(info, idx, (swp_entry_t){0});
+		info->swapped--;
 		swap_free(entry);
 		error = 1;	/* not an error, but entry was found */
 	}
-	shmem_swp_unmap(ptr);
 	spin_unlock(&info->lock);
 	return error;
 }
@@ -1017,7 +434,14 @@ int shmem_unuse(swp_entry_t entry, struc
 	mutex_lock(&shmem_swaplist_mutex);
 	list_for_each_safe(p, next, &shmem_swaplist) {
 		info = list_entry(p, struct shmem_inode_info, swaplist);
-		found = shmem_unuse_inode(info, entry, page);
+		if (!info->swapped) {
+			spin_lock(&info->lock);
+			if (!info->swapped)
+				list_del_init(&info->swaplist);
+			spin_unlock(&info->lock);
+		}
+		if (info->swapped)
+			found = shmem_unuse_inode(info, entry, page);
 		cond_resched();
 		if (found)
 			break;
@@ -1041,7 +465,7 @@ out:
 static int shmem_writepage(struct page *page, struct writeback_control *wbc)
 {
 	struct shmem_inode_info *info;
-	swp_entry_t *entry, swap;
+	swp_entry_t swap, oswap;
 	struct address_space *mapping;
 	unsigned long index;
 	struct inode *inode;
@@ -1067,6 +491,15 @@ static int shmem_writepage(struct page *
 		WARN_ON_ONCE(1);	/* Still happens? Tell us about it! */
 		goto redirty;
 	}
+
+	/*
+	 * Just for this patch, we have a toy implementation,
+	 * which can swap out only the first SHMEM_NR_DIRECT pages:
+	 * for simple demonstration of where we need to think about swap.
+	 */
+	if (index >= SHMEM_NR_DIRECT)
+		goto redirty;
+
 	swap = get_swap_page();
 	if (!swap.val)
 		goto redirty;
@@ -1087,22 +520,19 @@ static int shmem_writepage(struct page *
 	spin_lock(&info->lock);
 	mutex_unlock(&shmem_swaplist_mutex);
 
-	if (index >= info->next_index) {
-		BUG_ON(!(info->flags & SHMEM_TRUNCATE));
-		goto unlock;
-	}
-	entry = shmem_swp_entry(info, index, NULL);
-	if (entry->val) {
+	oswap = shmem_get_swap(info, index);
+	if (oswap.val) {
 		WARN_ON_ONCE(1);	/* Still happens? Tell us about it! */
-		free_swap_and_cache(*entry);
-		shmem_swp_set(info, entry, 0);
+		free_swap_and_cache(oswap);
+		shmem_put_swap(info, index, (swp_entry_t){0});
+		info->swapped--;
 	}
 	shmem_recalc_inode(inode);
 
 	if (add_to_swap_cache(page, swap, GFP_ATOMIC) == 0) {
 		delete_from_page_cache(page);
-		shmem_swp_set(info, entry, swap.val);
-		shmem_swp_unmap(entry);
+		shmem_put_swap(info, index, swap);
+		info->swapped++;
 		swap_shmem_alloc(swap);
 		spin_unlock(&info->lock);
 		BUG_ON(page_mapped(page));
@@ -1110,13 +540,7 @@ static int shmem_writepage(struct page *
 		return 0;
 	}
 
-	shmem_swp_unmap(entry);
-unlock:
 	spin_unlock(&info->lock);
-	/*
-	 * add_to_swap_cache() doesn't return -EEXIST, so we can safely
-	 * clear SWAP_HAS_CACHE flag.
-	 */
 	swapcache_free(swap, NULL);
 redirty:
 	set_page_dirty(page);
@@ -1230,12 +654,10 @@ static int shmem_getpage_gfp(struct inod
 	struct shmem_sb_info *sbinfo;
 	struct page *page;
 	struct page *prealloc_page = NULL;
-	swp_entry_t *entry;
 	swp_entry_t swap;
 	int error;
-	int ret;
 
-	if (idx >= SHMEM_MAX_INDEX)
+	if (idx > (MAX_LFS_FILESIZE >> PAGE_CACHE_SHIFT))
 		return -EFBIG;
 repeat:
 	page = find_lock_page(mapping, idx);
@@ -1272,37 +694,22 @@ repeat:
 
 	spin_lock(&info->lock);
 	shmem_recalc_inode(inode);
-	entry = shmem_swp_alloc(info, idx, sgp, gfp);
-	if (IS_ERR(entry)) {
-		spin_unlock(&info->lock);
-		error = PTR_ERR(entry);
-		goto out;
-	}
-	swap = *entry;
-
+	swap = shmem_get_swap(info, idx);
 	if (swap.val) {
 		/* Look it up and read it in.. */
 		page = lookup_swap_cache(swap);
 		if (!page) {
-			shmem_swp_unmap(entry);
 			spin_unlock(&info->lock);
 			/* here we actually do the io */
 			if (fault_type)
 				*fault_type |= VM_FAULT_MAJOR;
 			page = shmem_swapin(swap, gfp, info, idx);
 			if (!page) {
-				spin_lock(&info->lock);
-				entry = shmem_swp_alloc(info, idx, sgp, gfp);
-				if (IS_ERR(entry))
-					error = PTR_ERR(entry);
-				else {
-					if (entry->val == swap.val)
-						error = -ENOMEM;
-					shmem_swp_unmap(entry);
-				}
-				spin_unlock(&info->lock);
-				if (error)
+				swp_entry_t nswap = shmem_get_swap(info, idx);
+				if (nswap.val == swap.val) {
+					error = -ENOMEM;
 					goto out;
+				}
 				goto repeat;
 			}
 			wait_on_page_locked(page);
@@ -1312,14 +719,12 @@ repeat:
 
 		/* We have to do this with page locked to prevent races */
 		if (!trylock_page(page)) {
-			shmem_swp_unmap(entry);
 			spin_unlock(&info->lock);
 			wait_on_page_locked(page);
 			page_cache_release(page);
 			goto repeat;
 		}
 		if (PageWriteback(page)) {
-			shmem_swp_unmap(entry);
 			spin_unlock(&info->lock);
 			wait_on_page_writeback(page);
 			unlock_page(page);
@@ -1327,7 +732,6 @@ repeat:
 			goto repeat;
 		}
 		if (!PageUptodate(page)) {
-			shmem_swp_unmap(entry);
 			spin_unlock(&info->lock);
 			unlock_page(page);
 			page_cache_release(page);
@@ -1338,7 +742,6 @@ repeat:
 		error = add_to_page_cache_locked(page, mapping,
 						 idx, GFP_NOWAIT);
 		if (error) {
-			shmem_swp_unmap(entry);
 			spin_unlock(&info->lock);
 			if (error == -ENOMEM) {
 				/*
@@ -1358,16 +761,14 @@ repeat:
 			goto repeat;
 		}
 
-		info->flags |= SHMEM_PAGEIN;
-		shmem_swp_set(info, entry, 0);
-		shmem_swp_unmap(entry);
 		delete_from_swap_cache(page);
+		shmem_put_swap(info, idx, (swp_entry_t){0});
+		info->swapped--;
 		spin_unlock(&info->lock);
 		set_page_dirty(page);
 		swap_free(swap);
 
 	} else if (sgp == SGP_READ) {
-		shmem_swp_unmap(entry);
 		page = find_get_page(mapping, idx);
 		if (page && !trylock_page(page)) {
 			spin_unlock(&info->lock);
@@ -1378,7 +779,6 @@ repeat:
 		spin_unlock(&info->lock);
 
 	} else if (prealloc_page) {
-		shmem_swp_unmap(entry);
 		sbinfo = SHMEM_SB(inode->i_sb);
 		if (sbinfo->max_blocks) {
 			if (percpu_counter_compare(&sbinfo->used_blocks,
@@ -1393,34 +793,24 @@ repeat:
 		page = prealloc_page;
 		prealloc_page = NULL;
 
-		entry = shmem_swp_alloc(info, idx, sgp, gfp);
-		if (IS_ERR(entry))
-			error = PTR_ERR(entry);
-		else {
-			swap = *entry;
-			shmem_swp_unmap(entry);
-		}
-		ret = error || swap.val;
-		if (ret)
+		swap = shmem_get_swap(info, idx);
+		if (swap.val)
 			mem_cgroup_uncharge_cache_page(page);
 		else
-			ret = add_to_page_cache_lru(page, mapping,
+			error = add_to_page_cache_lru(page, mapping,
 						idx, GFP_NOWAIT);
 		/*
 		 * At add_to_page_cache_lru() failure,
 		 * uncharge will be done automatically.
 		 */
-		if (ret) {
+		if (swap.val || error) {
 			shmem_unacct_blocks(info->flags, 1);
 			shmem_free_blocks(inode, 1);
 			spin_unlock(&info->lock);
 			page_cache_release(page);
-			if (error)
-				goto out;
 			goto repeat;
 		}
 
-		info->flags |= SHMEM_PAGEIN;
 		info->alloced++;
 		spin_unlock(&info->lock);
 		clear_highpage(page);
@@ -2627,7 +2017,7 @@ int shmem_fill_super(struct super_block
 		goto failed;
 	sbinfo->free_inodes = sbinfo->max_inodes;
 
-	sb->s_maxbytes = SHMEM_MAX_BYTES;
+	sb->s_maxbytes = MAX_LFS_FILESIZE;
 	sb->s_blocksize = PAGE_CACHE_SIZE;
 	sb->s_blocksize_bits = PAGE_CACHE_SHIFT;
 	sb->s_magic = TMPFS_MAGIC;
@@ -2869,7 +2259,7 @@ out4:
 void mem_cgroup_get_shmem_target(struct inode *inode, pgoff_t pgoff,
 					struct page **pagep, swp_entry_t *ent)
 {
-	swp_entry_t entry = { .val = 0 }, *ptr;
+	swp_entry_t entry = { .val = 0 };
 	struct page *page = NULL;
 	struct shmem_inode_info *info = SHMEM_I(inode);
 
@@ -2877,16 +2267,13 @@ void mem_cgroup_get_shmem_target(struct
 		goto out;
 
 	spin_lock(&info->lock);
-	ptr = shmem_swp_entry(info, pgoff, NULL);
 #ifdef CONFIG_SWAP
-	if (ptr && ptr->val) {
-		entry.val = ptr->val;
+	entry = shmem_get_swap(info, pgoff);
+	if (entry.val)
 		page = find_get_page(&swapper_space, entry.val);
-	} else
+	else
 #endif
 		page = find_get_page(inode->i_mapping, pgoff);
-	if (ptr)
-		shmem_swp_unmap(ptr);
 	spin_unlock(&info->lock);
 out:
 	*pagep = page;
@@ -2969,7 +2356,6 @@ out:
 #define shmem_get_inode(sb, dir, mode, dev, flags)	ramfs_get_inode(sb, dir, mode, dev)
 #define shmem_acct_size(flags, size)		0
 #define shmem_unacct_size(flags, size)		do {} while (0)
-#define SHMEM_MAX_BYTES				MAX_LFS_FILESIZE
 
 #endif /* CONFIG_SHMEM */
 
@@ -2993,7 +2379,7 @@ struct file *shmem_file_setup(const char
 	if (IS_ERR(shm_mnt))
 		return (void *)shm_mnt;
 
-	if (size < 0 || size > SHMEM_MAX_BYTES)
+	if (size < 0 || size > MAX_LFS_FILESIZE)
 		return ERR_PTR(-EINVAL);
 
 	if (shmem_acct_size(flags, size))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
