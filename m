Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6F0A86B4866
	for <linux-mm@kvack.org>; Tue, 28 Aug 2018 18:27:30 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id b93-v6so1236154plb.10
        for <linux-mm@kvack.org>; Tue, 28 Aug 2018 15:27:30 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id t18-v6si1954789plo.191.2018.08.28.15.27.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 28 Aug 2018 15:27:28 -0700 (PDT)
Date: Tue, 28 Aug 2018 15:27:27 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Tagged pointers in the XArray
Message-ID: <20180828222727.GD11400@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Cc: Gao Xiang <gaoxiang25@huawei.com>, zhong jiang <zhongjiang@huawei.com>, Chao Yu <yuchao0@huawei.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>


I find myself caught between two traditions.

On the one hand, the radix tree has been calling the page cache dirty &
writeback bits "tags" for over a decade.

On the other hand, using some of the bits _in a pointer_ as a tag has been
common practice since at least the 1960s.
https://en.wikipedia.org/wiki/Tagged_pointer and
https://en.wikipedia.org/wiki/31-bit

EROFS wants to use tagged pointers in the radix tree / xarray.  Right now,
they're building them by hand, which is predictably grotty-looking.
I think it's reasonable to provide this functionality as part of the
XArray API, _but_ it's confusing to have two different things called tags.

I've done my best to document my way around this, but if we want to rename
the things that the radix tree called tags to avoid the problem entirely,
now is the time to do it.  Anybody got a Good Idea?

commit e2f06dd921a072bcc021fc7224a216d2c1b88b54
Author: Matthew Wilcox <willy@infradead.org>
Date:   Tue Aug 28 14:37:22 2018 -0400

    xarray: Add support for tagged pointers
    
    EROFS wants to tag its pointers rather than use XArray tags.  This is
    a new usecase which seems reasonable to support.
    
    Signed-off-by: Matthew Wilcox <willy@infradead.org>

diff --git a/Documentation/core-api/xarray.rst b/Documentation/core-api/xarray.rst
index bc0c43f49efe..215bd468cae7 100644
--- a/Documentation/core-api/xarray.rst
+++ b/Documentation/core-api/xarray.rst
@@ -41,6 +41,12 @@ When you retrieve an entry from the XArray, you can check whether it is
 a value entry by calling :c:func:`xa_is_value`, and convert it back to
 an integer by calling :c:func:`xa_to_value`.
 
+Some users want to tag their pointers without using the tag bits described
+above.  They can call :c:func:`xa_tag_pointer` to create an entry with
+a tag, :c:func:`xa_untag_pointer` to turn a tagged entry back into an
+untagged pointer and :c:func:`xa_pointer_tag` to retrieve the tag of
+an entry.
+
 The XArray does not support storing :c:func:`IS_ERR` pointers as some
 conflict with value entries or internal entries.
 
diff --git a/drivers/staging/erofs/Kconfig b/drivers/staging/erofs/Kconfig
index 96f614934df1..663b755bf2fb 100644
--- a/drivers/staging/erofs/Kconfig
+++ b/drivers/staging/erofs/Kconfig
@@ -2,7 +2,7 @@
 
 config EROFS_FS
 	tristate "EROFS filesystem support"
-	depends on BROKEN
+	depends on BLOCK
 	help
 	  EROFS(Enhanced Read-Only File System) is a lightweight
 	  read-only file system with modern designs (eg. page-sized
diff --git a/drivers/staging/erofs/utils.c b/drivers/staging/erofs/utils.c
index 595cf90af9bb..bdee9bd09f11 100644
--- a/drivers/staging/erofs/utils.c
+++ b/drivers/staging/erofs/utils.c
@@ -35,7 +35,6 @@ static atomic_long_t erofs_global_shrink_cnt;
 
 #ifdef CONFIG_EROFS_FS_ZIP
 
-/* radix_tree and the future XArray both don't use tagptr_t yet */
 struct erofs_workgroup *erofs_find_workgroup(
 	struct super_block *sb, pgoff_t index, bool *tag)
 {
@@ -47,9 +46,8 @@ struct erofs_workgroup *erofs_find_workgroup(
 	rcu_read_lock();
 	grp = radix_tree_lookup(&sbi->workstn_tree, index);
 	if (grp != NULL) {
-		*tag = radix_tree_exceptional_entry(grp);
-		grp = (void *)((unsigned long)grp &
-			~RADIX_TREE_EXCEPTIONAL_ENTRY);
+		*tag = xa_pointer_tag(grp);
+		grp = xa_untag_pointer(grp);
 
 		if (erofs_workgroup_get(grp, &oldcount)) {
 			/* prefer to relax rcu read side */
@@ -83,9 +81,7 @@ int erofs_register_workgroup(struct super_block *sb,
 	sbi = EROFS_SB(sb);
 	erofs_workstn_lock(sbi);
 
-	if (tag)
-		grp = (void *)((unsigned long)grp |
-			1UL << RADIX_TREE_EXCEPTIONAL_SHIFT);
+	grp = xa_tag_pointer(grp, tag);
 
 	err = radix_tree_insert(&sbi->workstn_tree,
 		grp->index, grp);
@@ -131,9 +127,7 @@ unsigned long erofs_shrink_workstation(struct erofs_sb_info *sbi,
 
 	for (i = 0; i < found; ++i) {
 		int cnt;
-		struct erofs_workgroup *grp = (void *)
-			((unsigned long)batch[i] &
-				~RADIX_TREE_EXCEPTIONAL_ENTRY);
+		struct erofs_workgroup *grp = xa_untag_pointer(batch[i]);
 
 		first_index = grp->index + 1;
 
@@ -150,8 +144,8 @@ unsigned long erofs_shrink_workstation(struct erofs_sb_info *sbi,
 #endif
 			continue;
 
-		if (radix_tree_delete(&sbi->workstn_tree,
-			grp->index) != grp) {
+		if (xa_untag_pointer(radix_tree_delete(&sbi->workstn_tree,
+			grp->index)) != grp) {
 #ifdef EROFS_FS_HAS_MANAGED_CACHE
 skip:
 			erofs_workgroup_unfreeze(grp, 1);
diff --git a/include/linux/xarray.h b/include/linux/xarray.h
index c74556ea4258..d1b383f3063f 100644
--- a/include/linux/xarray.h
+++ b/include/linux/xarray.h
@@ -24,7 +24,7 @@
  *
  * 00: Pointer entry
  * 10: Internal entry
- * x1: Value entry
+ * x1: Value entry or tagged pointer
  *
  * Attempting to store internal entries in the XArray is a bug.
  *
@@ -150,6 +150,54 @@ static inline int xa_err(void *entry)
 	return 0;
 }
 
+/**
+ * xa_tag_pointer() - Create an XArray entry for a tagged pointer.
+ * @p: Plain pointer.
+ * @tag: Tag value (0, 1 or 3).
+ *
+ * If the user of the XArray prefers, they can tag their pointers instead
+ * of storing value entries.  Three tags are available (0, 1 and 3).
+ * These are distinct from the xa_tag_t as they are not replicated up
+ * through the array and cannot be searched for.
+ *
+ * Context: Any context.
+ * Return: An XArray entry.
+ */
+static inline void *xa_tag_pointer(void *p, unsigned long tag)
+{
+	return (void *)((unsigned long)p | tag);
+}
+
+/**
+ * xa_untag_pointer() - Turn an XArray entry into a plain pointer.
+ * @entry: XArray entry.
+ *
+ * If you have stored a tagged pointer in the XArray, call this function
+ * to get the untagged version of the pointer.
+ *
+ * Context: Any context.
+ * Return: A pointer.
+ */
+static inline void *xa_untag_pointer(void *entry)
+{
+	return (void *)((unsigned long)entry & ~3UL);
+}
+
+/**
+ * xa_pointer_tag() - Get the tag stored in an XArray entry.
+ * @entry: XArray entry.
+ *
+ * If you have stored a tagged pointer in the XArray, call this function
+ * to get the tag of that pointer.
+ *
+ * Context: Any context.
+ * Return: A tag.
+ */
+static inline unsigned int xa_pointer_tag(void *entry)
+{
+	return (unsigned long)entry & 3UL;
+}
+
 typedef unsigned __bitwise xa_tag_t;
 #define XA_TAG_0		((__force xa_tag_t)0U)
 #define XA_TAG_1		((__force xa_tag_t)1U)
