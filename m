Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f169.google.com (mail-pf0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id AC75982F60
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 14:49:15 -0400 (EDT)
Received: by mail-pf0-f169.google.com with SMTP id u190so238342810pfb.3
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 11:49:15 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id fd9si7103985pad.134.2016.03.20.11.41.50
        for <linux-mm@kvack.org>;
        Sun, 20 Mar 2016 11:41:50 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 44/71] jffs2: get rid of PAGE_CACHE_* and page_cache_{get,release} macros
Date: Sun, 20 Mar 2016 21:40:51 +0300
Message-Id: <1458499278-1516-45-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Matthew Wilcox <willy@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, David Woodhouse <dwmw2@infradead.org>

PAGE_CACHE_{SIZE,SHIFT,MASK,ALIGN} macros were introduced *long* time ago
with promise that one day it will be possible to implement page cache with
bigger chunks than PAGE_SIZE.

This promise never materialized. And unlikely will.

We have many places where PAGE_CACHE_SIZE assumed to be equal to
PAGE_SIZE. And it's constant source of confusion on whether PAGE_CACHE_*
or PAGE_* constant should be used in a particular case, especially on the
border between fs and mm.

Global switching to PAGE_CACHE_SIZE != PAGE_SIZE would cause to much
breakage to be doable.

Let's stop pretending that pages in page cache are special. They are not.

The changes are pretty straight-forward:

 - <foo> << (PAGE_CACHE_SHIFT - PAGE_SHIFT) -> <foo>;

 - PAGE_CACHE_{SIZE,SHIFT,MASK,ALIGN} -> PAGE_{SIZE,SHIFT,MASK,ALIGN};

 - page_cache_get() -> get_page();

 - page_cache_release() -> put_page();

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: David Woodhouse <dwmw2@infradead.org>
---
 fs/jffs2/debug.c    |  8 ++++----
 fs/jffs2/file.c     | 23 ++++++++++++-----------
 fs/jffs2/fs.c       |  8 ++++----
 fs/jffs2/gc.c       |  8 ++++----
 fs/jffs2/nodelist.c |  8 ++++----
 fs/jffs2/write.c    |  7 ++++---
 6 files changed, 32 insertions(+), 30 deletions(-)

diff --git a/fs/jffs2/debug.c b/fs/jffs2/debug.c
index 1090eb64b90d..9d26b1b9fc01 100644
--- a/fs/jffs2/debug.c
+++ b/fs/jffs2/debug.c
@@ -95,15 +95,15 @@ __jffs2_dbg_fragtree_paranoia_check_nolock(struct jffs2_inode_info *f)
 			   rather than mucking around with actually reading the node
 			   and checking the compression type, which is the real way
 			   to tell a hole node. */
-			if (frag->ofs & (PAGE_CACHE_SIZE-1) && frag_prev(frag)
-					&& frag_prev(frag)->size < PAGE_CACHE_SIZE && frag_prev(frag)->node) {
+			if (frag->ofs & (PAGE_SIZE-1) && frag_prev(frag)
+					&& frag_prev(frag)->size < PAGE_SIZE && frag_prev(frag)->node) {
 				JFFS2_ERROR("REF_PRISTINE node at 0x%08x had a previous non-hole frag in the same page. Tell dwmw2.\n",
 					ref_offset(fn->raw));
 				bitched = 1;
 			}
 
-			if ((frag->ofs+frag->size) & (PAGE_CACHE_SIZE-1) && frag_next(frag)
-					&& frag_next(frag)->size < PAGE_CACHE_SIZE && frag_next(frag)->node) {
+			if ((frag->ofs+frag->size) & (PAGE_SIZE-1) && frag_next(frag)
+					&& frag_next(frag)->size < PAGE_SIZE && frag_next(frag)->node) {
 				JFFS2_ERROR("REF_PRISTINE node at 0x%08x (%08x-%08x) had a following non-hole frag in the same page. Tell dwmw2.\n",
 				       ref_offset(fn->raw), frag->ofs, frag->ofs+frag->size);
 				bitched = 1;
diff --git a/fs/jffs2/file.c b/fs/jffs2/file.c
index cad86bac3453..0e62dec3effc 100644
--- a/fs/jffs2/file.c
+++ b/fs/jffs2/file.c
@@ -87,14 +87,15 @@ static int jffs2_do_readpage_nolock (struct inode *inode, struct page *pg)
 	int ret;
 
 	jffs2_dbg(2, "%s(): ino #%lu, page at offset 0x%lx\n",
-		  __func__, inode->i_ino, pg->index << PAGE_CACHE_SHIFT);
+		  __func__, inode->i_ino, pg->index << PAGE_SHIFT);
 
 	BUG_ON(!PageLocked(pg));
 
 	pg_buf = kmap(pg);
 	/* FIXME: Can kmap fail? */
 
-	ret = jffs2_read_inode_range(c, f, pg_buf, pg->index << PAGE_CACHE_SHIFT, PAGE_CACHE_SIZE);
+	ret = jffs2_read_inode_range(c, f, pg_buf, pg->index << PAGE_SHIFT,
+				     PAGE_SIZE);
 
 	if (ret) {
 		ClearPageUptodate(pg);
@@ -137,8 +138,8 @@ static int jffs2_write_begin(struct file *filp, struct address_space *mapping,
 	struct page *pg;
 	struct inode *inode = mapping->host;
 	struct jffs2_inode_info *f = JFFS2_INODE_INFO(inode);
-	pgoff_t index = pos >> PAGE_CACHE_SHIFT;
-	uint32_t pageofs = index << PAGE_CACHE_SHIFT;
+	pgoff_t index = pos >> PAGE_SHIFT;
+	uint32_t pageofs = index << PAGE_SHIFT;
 	int ret = 0;
 
 	pg = grab_cache_page_write_begin(mapping, index, flags);
@@ -230,7 +231,7 @@ static int jffs2_write_begin(struct file *filp, struct address_space *mapping,
 
 out_page:
 	unlock_page(pg);
-	page_cache_release(pg);
+	put_page(pg);
 	return ret;
 }
 
@@ -245,14 +246,14 @@ static int jffs2_write_end(struct file *filp, struct address_space *mapping,
 	struct jffs2_inode_info *f = JFFS2_INODE_INFO(inode);
 	struct jffs2_sb_info *c = JFFS2_SB_INFO(inode->i_sb);
 	struct jffs2_raw_inode *ri;
-	unsigned start = pos & (PAGE_CACHE_SIZE - 1);
+	unsigned start = pos & (PAGE_SIZE - 1);
 	unsigned end = start + copied;
 	unsigned aligned_start = start & ~3;
 	int ret = 0;
 	uint32_t writtenlen = 0;
 
 	jffs2_dbg(1, "%s(): ino #%lu, page at 0x%lx, range %d-%d, flags %lx\n",
-		  __func__, inode->i_ino, pg->index << PAGE_CACHE_SHIFT,
+		  __func__, inode->i_ino, pg->index << PAGE_SHIFT,
 		  start, end, pg->flags);
 
 	/* We need to avoid deadlock with page_cache_read() in
@@ -261,7 +262,7 @@ static int jffs2_write_end(struct file *filp, struct address_space *mapping,
 	   to re-lock it. */
 	BUG_ON(!PageUptodate(pg));
 
-	if (end == PAGE_CACHE_SIZE) {
+	if (end == PAGE_SIZE) {
 		/* When writing out the end of a page, write out the
 		   _whole_ page. This helps to reduce the number of
 		   nodes in files which have many short writes, like
@@ -275,7 +276,7 @@ static int jffs2_write_end(struct file *filp, struct address_space *mapping,
 		jffs2_dbg(1, "%s(): Allocation of raw inode failed\n",
 			  __func__);
 		unlock_page(pg);
-		page_cache_release(pg);
+		put_page(pg);
 		return -ENOMEM;
 	}
 
@@ -292,7 +293,7 @@ static int jffs2_write_end(struct file *filp, struct address_space *mapping,
 	kmap(pg);
 
 	ret = jffs2_write_inode_range(c, f, ri, page_address(pg) + aligned_start,
-				      (pg->index << PAGE_CACHE_SHIFT) + aligned_start,
+				      (pg->index << PAGE_SHIFT) + aligned_start,
 				      end - aligned_start, &writtenlen);
 
 	kunmap(pg);
@@ -329,6 +330,6 @@ static int jffs2_write_end(struct file *filp, struct address_space *mapping,
 	jffs2_dbg(1, "%s() returning %d\n",
 		  __func__, writtenlen > 0 ? writtenlen : ret);
 	unlock_page(pg);
-	page_cache_release(pg);
+	put_page(pg);
 	return writtenlen > 0 ? writtenlen : ret;
 }
diff --git a/fs/jffs2/fs.c b/fs/jffs2/fs.c
index bead25ae8fe4..ae2ebb26b446 100644
--- a/fs/jffs2/fs.c
+++ b/fs/jffs2/fs.c
@@ -586,8 +586,8 @@ int jffs2_do_fill_super(struct super_block *sb, void *data, int silent)
 		goto out_root;
 
 	sb->s_maxbytes = 0xFFFFFFFF;
-	sb->s_blocksize = PAGE_CACHE_SIZE;
-	sb->s_blocksize_bits = PAGE_CACHE_SHIFT;
+	sb->s_blocksize = PAGE_SIZE;
+	sb->s_blocksize_bits = PAGE_SHIFT;
 	sb->s_magic = JFFS2_SUPER_MAGIC;
 	if (!(sb->s_flags & MS_RDONLY))
 		jffs2_start_garbage_collect_thread(c);
@@ -685,7 +685,7 @@ unsigned char *jffs2_gc_fetch_page(struct jffs2_sb_info *c,
 	struct inode *inode = OFNI_EDONI_2SFFJ(f);
 	struct page *pg;
 
-	pg = read_cache_page(inode->i_mapping, offset >> PAGE_CACHE_SHIFT,
+	pg = read_cache_page(inode->i_mapping, offset >> PAGE_SHIFT,
 			     (void *)jffs2_do_readpage_unlock, inode);
 	if (IS_ERR(pg))
 		return (void *)pg;
@@ -701,7 +701,7 @@ void jffs2_gc_release_page(struct jffs2_sb_info *c,
 	struct page *pg = (void *)*priv;
 
 	kunmap(pg);
-	page_cache_release(pg);
+	put_page(pg);
 }
 
 static int jffs2_flash_setup(struct jffs2_sb_info *c) {
diff --git a/fs/jffs2/gc.c b/fs/jffs2/gc.c
index 95d5880a63ee..7c82e6159826 100644
--- a/fs/jffs2/gc.c
+++ b/fs/jffs2/gc.c
@@ -532,7 +532,7 @@ static int jffs2_garbage_collect_live(struct jffs2_sb_info *c,  struct jffs2_era
 				goto upnout;
 		}
 		/* We found a datanode. Do the GC */
-		if((start >> PAGE_CACHE_SHIFT) < ((end-1) >> PAGE_CACHE_SHIFT)) {
+		if((start >> PAGE_SHIFT) < ((end-1) >> PAGE_SHIFT)) {
 			/* It crosses a page boundary. Therefore, it must be a hole. */
 			ret = jffs2_garbage_collect_hole(c, jeb, f, fn, start, end);
 		} else {
@@ -1172,8 +1172,8 @@ static int jffs2_garbage_collect_dnode(struct jffs2_sb_info *c, struct jffs2_era
 		struct jffs2_node_frag *frag;
 		uint32_t min, max;
 
-		min = start & ~(PAGE_CACHE_SIZE-1);
-		max = min + PAGE_CACHE_SIZE;
+		min = start & ~(PAGE_SIZE-1);
+		max = min + PAGE_SIZE;
 
 		frag = jffs2_lookup_node_frag(&f->fragtree, start);
 
@@ -1331,7 +1331,7 @@ static int jffs2_garbage_collect_dnode(struct jffs2_sb_info *c, struct jffs2_era
 		cdatalen = min_t(uint32_t, alloclen - sizeof(ri), end - offset);
 		datalen = end - offset;
 
-		writebuf = pg_ptr + (offset & (PAGE_CACHE_SIZE -1));
+		writebuf = pg_ptr + (offset & (PAGE_SIZE -1));
 
 		comprtype = jffs2_compress(c, f, writebuf, &comprbuf, &datalen, &cdatalen);
 
diff --git a/fs/jffs2/nodelist.c b/fs/jffs2/nodelist.c
index 9a5449bc3afb..b86c78d178c6 100644
--- a/fs/jffs2/nodelist.c
+++ b/fs/jffs2/nodelist.c
@@ -90,7 +90,7 @@ uint32_t jffs2_truncate_fragtree(struct jffs2_sb_info *c, struct rb_root *list,
 
 	/* If the last fragment starts at the RAM page boundary, it is
 	 * REF_PRISTINE irrespective of its size. */
-	if (frag->node && (frag->ofs & (PAGE_CACHE_SIZE - 1)) == 0) {
+	if (frag->node && (frag->ofs & (PAGE_SIZE - 1)) == 0) {
 		dbg_fragtree2("marking the last fragment 0x%08x-0x%08x REF_PRISTINE.\n",
 			frag->ofs, frag->ofs + frag->size);
 		frag->node->raw->flash_offset = ref_offset(frag->node->raw) | REF_PRISTINE;
@@ -237,7 +237,7 @@ static int jffs2_add_frag_to_fragtree(struct jffs2_sb_info *c, struct rb_root *r
 		   If so, both 'this' and the new node get marked REF_NORMAL so
 		   the GC can take a look.
 		*/
-		if (lastend && (lastend-1) >> PAGE_CACHE_SHIFT == newfrag->ofs >> PAGE_CACHE_SHIFT) {
+		if (lastend && (lastend-1) >> PAGE_SHIFT == newfrag->ofs >> PAGE_SHIFT) {
 			if (this->node)
 				mark_ref_normal(this->node->raw);
 			mark_ref_normal(newfrag->node->raw);
@@ -382,7 +382,7 @@ int jffs2_add_full_dnode_to_inode(struct jffs2_sb_info *c, struct jffs2_inode_in
 
 	/* If we now share a page with other nodes, mark either previous
 	   or next node REF_NORMAL, as appropriate.  */
-	if (newfrag->ofs & (PAGE_CACHE_SIZE-1)) {
+	if (newfrag->ofs & (PAGE_SIZE-1)) {
 		struct jffs2_node_frag *prev = frag_prev(newfrag);
 
 		mark_ref_normal(fn->raw);
@@ -391,7 +391,7 @@ int jffs2_add_full_dnode_to_inode(struct jffs2_sb_info *c, struct jffs2_inode_in
 			mark_ref_normal(prev->node->raw);
 	}
 
-	if ((newfrag->ofs+newfrag->size) & (PAGE_CACHE_SIZE-1)) {
+	if ((newfrag->ofs+newfrag->size) & (PAGE_SIZE-1)) {
 		struct jffs2_node_frag *next = frag_next(newfrag);
 
 		if (next) {
diff --git a/fs/jffs2/write.c b/fs/jffs2/write.c
index b634de4c8101..7fb187ab2682 100644
--- a/fs/jffs2/write.c
+++ b/fs/jffs2/write.c
@@ -172,8 +172,8 @@ struct jffs2_full_dnode *jffs2_write_dnode(struct jffs2_sb_info *c, struct jffs2
 	   beginning of a page and runs to the end of the file, or if
 	   it's a hole node, mark it REF_PRISTINE, else REF_NORMAL.
 	*/
-	if ((je32_to_cpu(ri->dsize) >= PAGE_CACHE_SIZE) ||
-	    ( ((je32_to_cpu(ri->offset)&(PAGE_CACHE_SIZE-1))==0) &&
+	if ((je32_to_cpu(ri->dsize) >= PAGE_SIZE) ||
+	    ( ((je32_to_cpu(ri->offset)&(PAGE_SIZE-1))==0) &&
 	      (je32_to_cpu(ri->dsize)+je32_to_cpu(ri->offset) ==  je32_to_cpu(ri->isize)))) {
 		flash_ofs |= REF_PRISTINE;
 	} else {
@@ -366,7 +366,8 @@ int jffs2_write_inode_range(struct jffs2_sb_info *c, struct jffs2_inode_info *f,
 			break;
 		}
 		mutex_lock(&f->sem);
-		datalen = min_t(uint32_t, writelen, PAGE_CACHE_SIZE - (offset & (PAGE_CACHE_SIZE-1)));
+		datalen = min_t(uint32_t, writelen,
+				PAGE_SIZE - (offset & (PAGE_SIZE-1)));
 		cdatalen = min_t(uint32_t, alloclen - sizeof(*ri), datalen);
 
 		comprtype = jffs2_compress(c, f, buf, &comprbuf, &datalen, &cdatalen);
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
