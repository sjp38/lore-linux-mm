Subject: PATCH: less dirty (Re: [dirtypatch] quickhack to make pre8/9 behave (fwd))
References: <Pine.LNX.4.21.0005161631320.32026-100000@duckman.distro.conectiva>
From: "Juan J. Quintela" <quintela@fi.udc.es>
In-Reply-To: Rik van Riel's message of "Tue, 16 May 2000 16:32:36 -0300 (BRST)"
Date: 17 May 2000 02:28:12 +0200
Message-ID: <yttvh0evx43.fsf@vexeta.dc.fi.udc.es>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@transmeta.com>, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

>>>>> "rik" == Rik van Riel <riel@conectiva.com.br> writes:

rik> [ARGHHH, this time -with- patch, thanks RogerL]
rik> Hi,

rik> with the quick&dirty patch below the system:
rik> - gracefully (more or less) survives mmap002
rik> - has good performance on mmap002

rik> To me this patch shows that we really want to wait
rik> for dirty page IO to finish before randomly evicting
rik> the (wrong) clean pages and dying horribly.

rik> This is a dirty hack which should be replaced by whichever
rik> solution people thing should be implemented to have the
rik> allocator waiting for dirty pages to be flushed out.

Hi,
        after discussing with rik several designs I have done that
        patch, it behaves better indeed that rik patch.  The patch is
        against pre9-2.  It also deletes the previos patch to lock
        try_to_free_pages by zones.

I have added one argument to try_to_free pages indicating if we want
to wait for the page.  Note also that we only wait if we are allowed
to do that by the gpf_mask.

Basically what I do is from shrink_mmap I count how many dirty buffers
I have found (magical value 10), and If I find 10 dirty buffers before
freeing a page, I will wait in the next dirty buffer, to obtain a free
page.  The value 10 needs tuning, but here performance is very good
for mmap002, could people test it with other workloads? It
looks rock solid and stable.  I need to refine a bit more the patch
but It begins to look promising.

Comments?

Later, Juan.

diff -urN --exclude-from=/home/lfcia/quintela/work/kernel/exclude pre9-2/fs/buffer.c testing/fs/buffer.c
--- pre9-2/fs/buffer.c	Fri May 12 23:46:45 2000
+++ testing/fs/buffer.c	Wed May 17 01:26:55 2000
@@ -1324,7 +1324,7 @@
 	 * instead.
 	 */
 	if (!offset) {
-		if (!try_to_free_buffers(page)) {
+		if (!try_to_free_buffers(page, 0)) {
 			atomic_inc(&buffermem_pages);
 			return 0;
 		}
@@ -2121,14 +2121,14 @@
  * This all is required so that we can free up memory
  * later.
  */
-static void sync_page_buffers(struct buffer_head *bh)
+static void sync_page_buffers(struct buffer_head *bh, int wait)
 {
-	struct buffer_head * tmp;
-
-	tmp = bh;
+	struct buffer_head * tmp = bh;
 	do {
 		struct buffer_head *p = tmp;
 		tmp = tmp->b_this_page;
+		if (buffer_locked(p) && wait)
+			__wait_on_buffer(p);
 		if (buffer_dirty(p) && !buffer_locked(p))
 			ll_rw_block(WRITE, 1, &p);
 	} while (tmp != bh);
@@ -2151,7 +2151,7 @@
  *       obtain a reference to a buffer head within a page.  So we must
  *	 lock out all of these paths to cleanly toss the page.
  */
-int try_to_free_buffers(struct page * page)
+int try_to_free_buffers(struct page * page, int wait)
 {
 	struct buffer_head * tmp, * bh = page->buffers;
 	int index = BUFSIZE_INDEX(bh->b_size);
@@ -2201,7 +2201,7 @@
 	spin_unlock(&free_list[index].lock);
 	write_unlock(&hash_table_lock);
 	spin_unlock(&lru_list_lock);	
-	sync_page_buffers(bh);
+	sync_page_buffers(bh, wait);
 	return 0;
 }
 
diff -urN --exclude-from=/home/lfcia/quintela/work/kernel/exclude pre9-2/include/linux/fs.h testing/include/linux/fs.h
--- pre9-2/include/linux/fs.h	Tue May 16 01:01:20 2000
+++ testing/include/linux/fs.h	Wed May 17 02:22:34 2000
@@ -900,7 +900,7 @@
 
 extern int fs_may_remount_ro(struct super_block *);
 
-extern int try_to_free_buffers(struct page *);
+extern int try_to_free_buffers(struct page *, int);
 extern void refile_buffer(struct buffer_head * buf);
 
 #define BUF_CLEAN	0
diff -urN --exclude-from=/home/lfcia/quintela/work/kernel/exclude pre9-2/include/linux/mmzone.h testing/include/linux/mmzone.h
--- pre9-2/include/linux/mmzone.h	Tue May 16 01:01:20 2000
+++ testing/include/linux/mmzone.h	Tue May 16 15:36:20 2000
@@ -70,7 +70,6 @@
 typedef struct zonelist_struct {
 	zone_t * zones [MAX_NR_ZONES+1]; // NULL delimited
 	int gfp_mask;
-	atomic_t free_before_allocate;
 } zonelist_t;
 
 #define NR_GFPINDEX		0x100
diff -urN --exclude-from=/home/lfcia/quintela/work/kernel/exclude pre9-2/mm/filemap.c testing/mm/filemap.c
--- pre9-2/mm/filemap.c	Fri May 12 23:46:46 2000
+++ testing/mm/filemap.c	Wed May 17 02:23:42 2000
@@ -246,12 +246,13 @@
 
 int shrink_mmap(int priority, int gfp_mask)
 {
-	int ret = 0, count;
+	int ret = 0, count, nr_dirty;
 	LIST_HEAD(old);
 	struct list_head * page_lru, * dispose;
 	struct page * page = NULL;
 	
 	count = nr_lru_pages / (priority + 1);
+	nr_dirty = 10; /* magic number */
 
 	/* we need pagemap_lru_lock for list_del() ... subtle code below */
 	spin_lock(&pagemap_lru_lock);
@@ -303,8 +304,11 @@
 		 * of zone - it's old.
 		 */
 		if (page->buffers) {
-			if (!try_to_free_buffers(page))
-				goto unlock_continue;
+			int wait = ((gfp_mask & __GFP_IO) && (nr_dirty > 0));
+			nr_dirty--;
+
+			if (!try_to_free_buffers(page, wait))
+					goto unlock_continue;
 			/* page was locked, inode can't go away under us */
 			if (!page->mapping) {
 				atomic_dec(&buffermem_pages);
diff -urN --exclude-from=/home/lfcia/quintela/work/kernel/exclude pre9-2/mm/page_alloc.c testing/mm/page_alloc.c
--- pre9-2/mm/page_alloc.c	Tue May 16 00:36:11 2000
+++ testing/mm/page_alloc.c	Tue May 16 15:36:20 2000
@@ -243,9 +243,6 @@
 			if (page)
 				return page;
 		}
-		/* Somebody else is freeing pages? */
-		if (atomic_read(&zonelist->free_before_allocate))
-			try_to_free_pages(zonelist->gfp_mask);
 	}
 
 	/*
@@ -273,11 +270,7 @@
 	 */
 	if (!(current->flags & PF_MEMALLOC)) {
 		int gfp_mask = zonelist->gfp_mask;
-		int result;
-		atomic_inc(&zonelist->free_before_allocate);
-		result = try_to_free_pages(gfp_mask);
-		atomic_dec(&zonelist->free_before_allocate);
-		if (!result) {
+		if (!try_to_free_pages(gfp_mask)) {
 			if (!(gfp_mask & __GFP_HIGH))
 				goto fail;
 		}
@@ -421,7 +414,6 @@
 		zonelist = pgdat->node_zonelists + i;
 		memset(zonelist, 0, sizeof(*zonelist));
 
-		atomic_set(&zonelist->free_before_allocate, 0);
 		zonelist->gfp_mask = i;
 		j = 0;
 		k = ZONE_NORMAL;
diff -urN --exclude-from=/home/lfcia/quintela/work/kernel/exclude pre9-2/mm/vmscan.c testing/mm/vmscan.c
--- pre9-2/mm/vmscan.c	Tue May 16 00:36:11 2000
+++ testing/mm/vmscan.c	Wed May 17 02:01:20 2000
@@ -439,7 +439,7 @@
 	/* Always trim SLAB caches when memory gets low. */
 	kmem_cache_reap(gfp_mask);
 
-	priority = 6;
+	priority = 64;
 	do {
 		while (shrink_mmap(priority, gfp_mask)) {
 			if (!--count)

-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
