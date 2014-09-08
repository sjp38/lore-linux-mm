Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 22A4E6B0036
	for <linux-mm@kvack.org>; Mon,  8 Sep 2014 14:59:51 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id kq14so676473pab.19
        for <linux-mm@kvack.org>; Mon, 08 Sep 2014 11:59:50 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id pb4si19220816pdb.225.2014.09.08.11.59.49
        for <linux-mm@kvack.org>;
        Mon, 08 Sep 2014 11:59:49 -0700 (PDT)
Date: Mon, 8 Sep 2014 14:59:36 -0400
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH v10 19/21] xip: Add xip_zero_page_range
Message-ID: <20140908185936.GE27730@localhost.localdomain>
References: <cover.1409110741.git.matthew.r.wilcox@intel.com>
 <80c8efc903971eb3a338f262fbd3ef135db63eb0.1409110741.git.matthew.r.wilcox@intel.com>
 <20140903092116.GF20473@dastard>
 <20140904210802.GA27730@localhost.localdomain>
 <20140904213641.GB4364@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140904213641.GB4364@thunk.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Matthew Wilcox <willy@linux.intel.com>, Dave Chinner <david@fromorbit.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>

On Thu, Sep 04, 2014 at 05:36:41PM -0400, Theodore Ts'o wrote:
> On Thu, Sep 04, 2014 at 05:08:02PM -0400, Matthew Wilcox wrote:
> > 
> > ext4 does (or did?) have this bug (expectation?).  I then take advantage
> > of the fact that we have to accommodate it, so there are now two places
> > that have to accommodate it.  I forget what the path was that has that
> > assumption, but xfstests used to display it.
> > 
> > I'm away this week (... bad timing), but I can certainly fix it elsewhere
> > in ext4 next week.
> 
> Huh?  Can you say more about what it is or was doing?  And where?
> 
> I tried to look for it, and I'm not seeing it, but I'm not entirely
> sure from your description whether I'm looking in the right place.

I wrote this patch:

diff --git a/fs/dax.c b/fs/dax.c
index 96c4fed..bdf6622 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -473,6 +473,7 @@ int dax_zero_page_range(struct inode *inode, loff_t from, unsigned length,
 	/* Block boundary? Nothing to do */
 	if (!length)
 		return 0;
+	BUG_ON((offset + length) > PAGE_CACHE_SIZE);
 
 	memset(&bh, 0, sizeof(bh));
 	bh.b_size = PAGE_CACHE_SIZE;
@@ -484,14 +485,31 @@ int dax_zero_page_range(struct inode *inode, loff_t from, unsigned length,
 		err = dax_get_addr(&bh, &addr, inode->i_blkbits);
 		if (err < 0)
 			return err;
-		/*
-		 * ext4 sometimes asks to zero past the end of a block.  It
-		 * really just wants to zero to the end of the block.
-		 */
-		length = min_t(unsigned, length, PAGE_CACHE_SIZE - offset);
 		memset(addr + offset, 0, length);
 	}
 
 	return 0;
 }
 EXPORT_SYMBOL_GPL(dax_zero_page_range);
+
+/**
+ * dax_truncate_page - handle a partial page being truncated in a DAX file
+ * @inode: The file being truncated
+ * @from: The file offset that is being truncated to
+ * @get_block: The filesystem method used to translate file offsets to blocks
+ *
+ * Similar to block_truncate_page(), this function can be called by a
+ * filesystem when it is truncating an DAX file to handle the partial page.
+ *
+ * We work in terms of PAGE_CACHE_SIZE here for commonality with
+ * block_truncate_page(), but we could go down to PAGE_SIZE if the filesystem
+ * took care of disposing of the unnecessary blocks.  Even if the filesystem
+ * block size is smaller than PAGE_SIZE, we have to zero the rest of the page
+ * since the file might be mmaped.
+ */
+int dax_truncate_page(struct inode *inode, loff_t from, get_block_t get_block)
+{
+	unsigned length = PAGE_CACHE_ALIGN(from) - from;
+	return dax_zero_page_range(inode, from, length, get_block);
+}
+EXPORT_SYMBOL_GPL(dax_truncate_page);
diff --git a/include/linux/fs.h b/include/linux/fs.h
index b0078df..d0182a5 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2502,6 +2502,12 @@ static inline int dax_clear_blocks(struct inode *i, sector_t blk, long sz)
 	return 0;
 }
 
+static inline int dax_truncate_page(struct inode *inode, loff_t from,
+								get_block_t gb)
+{
+	return 0;
+}
+
 static inline int dax_zero_page_range(struct inode *inode, loff_t from,
 						unsigned len, get_block_t gb)
 {
@@ -2516,11 +2522,6 @@ static inline ssize_t dax_do_io(int rw, struct kiocb *iocb,
 }
 #endif
 
-/* Can't be a function because PAGE_CACHE_SIZE is defined in pagemap.h */
-#define dax_truncate_page(inode, from, get_block)	\
-	dax_zero_page_range(inode, from, PAGE_CACHE_SIZE, get_block)
-
-
 #ifdef CONFIG_BLOCK
 typedef void (dio_submit_t)(int rw, struct bio *bio, struct inode *inode,
 			    loff_t file_offset);

When running generic/008, it hit the BUG_ON in dax_zero_page_range():

[  506.752872] Call Trace:
[  506.752891]  [<ffffffffa02303cb>] ? __ext4_handle_dirty_metadata+0x9b/0x210 [ext4]
[  506.752910]  [<ffffffffa0200ffa>] ext4_block_zero_page_range+0x1ba/0x400 [ext4]
[  506.752930]  [<ffffffffa022f708>] ? ext4_fallocate+0x818/0xb70 [ext4]
[  506.752947]  [<ffffffffa020188e>] ext4_zero_partial_blocks+0xae/0xf0 [ext4]
[  506.752966]  [<ffffffffa022f719>] ext4_fallocate+0x829/0xb70 [ext4]
[  506.752980]  [<ffffffff811fee96>] do_fallocate+0x126/0x1b0
[  506.752992]  [<ffffffff811fef63>] SyS_fallocate+0x43/0x70

Someone appears to already know about this, since this code exists
in the current ext4_block_zero_page_range() [which I renamed to
__ext4_block_zero_page_range() in my patchset]:

        /*
         * correct length if it does not fall between
         * 'from' and the end of the block
         */
        if (length > max || length < 0)
                length = max;

Applying the following patch on top of the DAX patchset and the above
patch fixes everything nicely, but does result in a small amount of
code duplication.

diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index e71adf6..5edd903 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -3231,7 +3231,7 @@ static int __ext4_block_zero_page_range(handle_t *handle,
 {
 	ext4_fsblk_t index = from >> PAGE_CACHE_SHIFT;
 	unsigned offset = from & (PAGE_CACHE_SIZE-1);
-	unsigned blocksize, max, pos;
+	unsigned blocksize, pos;
 	ext4_lblk_t iblock;
 	struct inode *inode = mapping->host;
 	struct buffer_head *bh;
@@ -3244,14 +3244,6 @@ static int __ext4_block_zero_page_range(handle_t *handle,
 		return -ENOMEM;
 
 	blocksize = inode->i_sb->s_blocksize;
-	max = blocksize - (offset & (blocksize - 1));
-
-	/*
-	 * correct length if it does not fall between
-	 * 'from' and the end of the block
-	 */
-	if (length > max || length < 0)
-		length = max;
 
 	iblock = index << (PAGE_CACHE_SHIFT - inode->i_sb->s_blocksize_bits);
 
@@ -3327,6 +3319,17 @@ static int ext4_block_zero_page_range(handle_t *handle,
 		struct address_space *mapping, loff_t from, loff_t length)
 {
 	struct inode *inode = mapping->host;
+	unsigned offset = from & (PAGE_CACHE_SIZE-1);
+	unsigned blocksize = inode->i_sb->s_blocksize;
+	unsigned max = blocksize - (offset & (blocksize - 1));
+
+	/*
+	 * correct length if it does not fall between
+	 * 'from' and the end of the block
+	 */
+	if (length > max || length < 0)
+		length = max;
+
 	if (IS_DAX(inode))
 		return dax_zero_page_range(inode, from, length, ext4_get_block);
 	return __ext4_block_zero_page_range(handle, mapping, from, length);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
