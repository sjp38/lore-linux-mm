Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f180.google.com (mail-pf0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 5899182F60
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 14:47:30 -0400 (EDT)
Received: by mail-pf0-f180.google.com with SMTP id u190so238313121pfb.3
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 11:47:30 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id tr4si13932449pac.222.2016.03.20.11.41.46
        for <linux-mm@kvack.org>;
        Sun, 20 Mar 2016 11:41:46 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 29/71] ecryptfs: get rid of PAGE_CACHE_* and page_cache_{get,release} macros
Date: Sun, 20 Mar 2016 21:40:36 +0300
Message-Id: <1458499278-1516-30-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Matthew Wilcox <willy@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Tyler Hicks <tyhicks@canonical.com>

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
Cc: Tyler Hicks <tyhicks@canonical.com>
---
 fs/ecryptfs/crypto.c     | 22 +++++++++++-----------
 fs/ecryptfs/inode.c      |  8 ++++----
 fs/ecryptfs/keystore.c   |  2 +-
 fs/ecryptfs/main.c       |  8 ++++----
 fs/ecryptfs/mmap.c       | 44 ++++++++++++++++++++++----------------------
 fs/ecryptfs/read_write.c | 14 +++++++-------
 6 files changed, 49 insertions(+), 49 deletions(-)

diff --git a/fs/ecryptfs/crypto.c b/fs/ecryptfs/crypto.c
index 64026e53722a..d09cb4cdd09f 100644
--- a/fs/ecryptfs/crypto.c
+++ b/fs/ecryptfs/crypto.c
@@ -286,7 +286,7 @@ int virt_to_scatterlist(const void *addr, int size, struct scatterlist *sg,
 		pg = virt_to_page(addr);
 		offset = offset_in_page(addr);
 		sg_set_page(&sg[i], pg, 0, offset);
-		remainder_of_page = PAGE_CACHE_SIZE - offset;
+		remainder_of_page = PAGE_SIZE - offset;
 		if (size >= remainder_of_page) {
 			sg[i].length = remainder_of_page;
 			addr += remainder_of_page;
@@ -400,7 +400,7 @@ static loff_t lower_offset_for_page(struct ecryptfs_crypt_stat *crypt_stat,
 				    struct page *page)
 {
 	return ecryptfs_lower_header_size(crypt_stat) +
-	       ((loff_t)page->index << PAGE_CACHE_SHIFT);
+	       ((loff_t)page->index << PAGE_SHIFT);
 }
 
 /**
@@ -428,7 +428,7 @@ static int crypt_extent(struct ecryptfs_crypt_stat *crypt_stat,
 	size_t extent_size = crypt_stat->extent_size;
 	int rc;
 
-	extent_base = (((loff_t)page_index) * (PAGE_CACHE_SIZE / extent_size));
+	extent_base = (((loff_t)page_index) * (PAGE_SIZE / extent_size));
 	rc = ecryptfs_derive_iv(extent_iv, crypt_stat,
 				(extent_base + extent_offset));
 	if (rc) {
@@ -498,7 +498,7 @@ int ecryptfs_encrypt_page(struct page *page)
 	}
 
 	for (extent_offset = 0;
-	     extent_offset < (PAGE_CACHE_SIZE / crypt_stat->extent_size);
+	     extent_offset < (PAGE_SIZE / crypt_stat->extent_size);
 	     extent_offset++) {
 		rc = crypt_extent(crypt_stat, enc_extent_page, page,
 				  extent_offset, ENCRYPT);
@@ -512,7 +512,7 @@ int ecryptfs_encrypt_page(struct page *page)
 	lower_offset = lower_offset_for_page(crypt_stat, page);
 	enc_extent_virt = kmap(enc_extent_page);
 	rc = ecryptfs_write_lower(ecryptfs_inode, enc_extent_virt, lower_offset,
-				  PAGE_CACHE_SIZE);
+				  PAGE_SIZE);
 	kunmap(enc_extent_page);
 	if (rc < 0) {
 		ecryptfs_printk(KERN_ERR,
@@ -560,7 +560,7 @@ int ecryptfs_decrypt_page(struct page *page)
 
 	lower_offset = lower_offset_for_page(crypt_stat, page);
 	page_virt = kmap(page);
-	rc = ecryptfs_read_lower(page_virt, lower_offset, PAGE_CACHE_SIZE,
+	rc = ecryptfs_read_lower(page_virt, lower_offset, PAGE_SIZE,
 				 ecryptfs_inode);
 	kunmap(page);
 	if (rc < 0) {
@@ -571,7 +571,7 @@ int ecryptfs_decrypt_page(struct page *page)
 	}
 
 	for (extent_offset = 0;
-	     extent_offset < (PAGE_CACHE_SIZE / crypt_stat->extent_size);
+	     extent_offset < (PAGE_SIZE / crypt_stat->extent_size);
 	     extent_offset++) {
 		rc = crypt_extent(crypt_stat, page, page,
 				  extent_offset, DECRYPT);
@@ -659,11 +659,11 @@ void ecryptfs_set_default_sizes(struct ecryptfs_crypt_stat *crypt_stat)
 	if (crypt_stat->flags & ECRYPTFS_METADATA_IN_XATTR)
 		crypt_stat->metadata_size = ECRYPTFS_MINIMUM_HEADER_EXTENT_SIZE;
 	else {
-		if (PAGE_CACHE_SIZE <= ECRYPTFS_MINIMUM_HEADER_EXTENT_SIZE)
+		if (PAGE_SIZE <= ECRYPTFS_MINIMUM_HEADER_EXTENT_SIZE)
 			crypt_stat->metadata_size =
 				ECRYPTFS_MINIMUM_HEADER_EXTENT_SIZE;
 		else
-			crypt_stat->metadata_size = PAGE_CACHE_SIZE;
+			crypt_stat->metadata_size = PAGE_SIZE;
 	}
 }
 
@@ -1442,7 +1442,7 @@ int ecryptfs_read_metadata(struct dentry *ecryptfs_dentry)
 						ECRYPTFS_VALIDATE_HEADER_SIZE);
 	if (rc) {
 		/* metadata is not in the file header, so try xattrs */
-		memset(page_virt, 0, PAGE_CACHE_SIZE);
+		memset(page_virt, 0, PAGE_SIZE);
 		rc = ecryptfs_read_xattr_region(page_virt, ecryptfs_inode);
 		if (rc) {
 			printk(KERN_DEBUG "Valid eCryptfs headers not found in "
@@ -1475,7 +1475,7 @@ int ecryptfs_read_metadata(struct dentry *ecryptfs_dentry)
 	}
 out:
 	if (page_virt) {
-		memset(page_virt, 0, PAGE_CACHE_SIZE);
+		memset(page_virt, 0, PAGE_SIZE);
 		kmem_cache_free(ecryptfs_header_cache, page_virt);
 	}
 	return rc;
diff --git a/fs/ecryptfs/inode.c b/fs/ecryptfs/inode.c
index 121114e9a464..224b49e71aa4 100644
--- a/fs/ecryptfs/inode.c
+++ b/fs/ecryptfs/inode.c
@@ -763,10 +763,10 @@ static int truncate_upper(struct dentry *dentry, struct iattr *ia,
 	} else { /* ia->ia_size < i_size_read(inode) */
 		/* We're chopping off all the pages down to the page
 		 * in which ia->ia_size is located. Fill in the end of
-		 * that page from (ia->ia_size & ~PAGE_CACHE_MASK) to
-		 * PAGE_CACHE_SIZE with zeros. */
-		size_t num_zeros = (PAGE_CACHE_SIZE
-				    - (ia->ia_size & ~PAGE_CACHE_MASK));
+		 * that page from (ia->ia_size & ~PAGE_MASK) to
+		 * PAGE_SIZE with zeros. */
+		size_t num_zeros = (PAGE_SIZE
+				    - (ia->ia_size & ~PAGE_MASK));
 
 		if (!(crypt_stat->flags & ECRYPTFS_ENCRYPTED)) {
 			truncate_setsize(inode, ia->ia_size);
diff --git a/fs/ecryptfs/keystore.c b/fs/ecryptfs/keystore.c
index c5c84dfb5b3e..3274c469b42f 100644
--- a/fs/ecryptfs/keystore.c
+++ b/fs/ecryptfs/keystore.c
@@ -1800,7 +1800,7 @@ int ecryptfs_parse_packet_set(struct ecryptfs_crypt_stat *crypt_stat,
 	 * added the our &auth_tok_list */
 	next_packet_is_auth_tok_packet = 1;
 	while (next_packet_is_auth_tok_packet) {
-		size_t max_packet_size = ((PAGE_CACHE_SIZE - 8) - i);
+		size_t max_packet_size = ((PAGE_SIZE - 8) - i);
 
 		switch (src[i]) {
 		case ECRYPTFS_TAG_3_PACKET_TYPE:
diff --git a/fs/ecryptfs/main.c b/fs/ecryptfs/main.c
index 8b0b4a73116d..1698132d0e57 100644
--- a/fs/ecryptfs/main.c
+++ b/fs/ecryptfs/main.c
@@ -695,12 +695,12 @@ static struct ecryptfs_cache_info {
 	{
 		.cache = &ecryptfs_header_cache,
 		.name = "ecryptfs_headers",
-		.size = PAGE_CACHE_SIZE,
+		.size = PAGE_SIZE,
 	},
 	{
 		.cache = &ecryptfs_xattr_cache,
 		.name = "ecryptfs_xattr_cache",
-		.size = PAGE_CACHE_SIZE,
+		.size = PAGE_SIZE,
 	},
 	{
 		.cache = &ecryptfs_key_record_cache,
@@ -818,7 +818,7 @@ static int __init ecryptfs_init(void)
 {
 	int rc;
 
-	if (ECRYPTFS_DEFAULT_EXTENT_SIZE > PAGE_CACHE_SIZE) {
+	if (ECRYPTFS_DEFAULT_EXTENT_SIZE > PAGE_SIZE) {
 		rc = -EINVAL;
 		ecryptfs_printk(KERN_ERR, "The eCryptfs extent size is "
 				"larger than the host's page size, and so "
@@ -826,7 +826,7 @@ static int __init ecryptfs_init(void)
 				"default eCryptfs extent size is [%u] bytes; "
 				"the page size is [%lu] bytes.\n",
 				ECRYPTFS_DEFAULT_EXTENT_SIZE,
-				(unsigned long)PAGE_CACHE_SIZE);
+				(unsigned long)PAGE_SIZE);
 		goto out;
 	}
 	rc = ecryptfs_init_kmem_caches();
diff --git a/fs/ecryptfs/mmap.c b/fs/ecryptfs/mmap.c
index 1f5865263b3e..e6b1d80952b9 100644
--- a/fs/ecryptfs/mmap.c
+++ b/fs/ecryptfs/mmap.c
@@ -122,7 +122,7 @@ ecryptfs_copy_up_encrypted_with_header(struct page *page,
 				       struct ecryptfs_crypt_stat *crypt_stat)
 {
 	loff_t extent_num_in_page = 0;
-	loff_t num_extents_per_page = (PAGE_CACHE_SIZE
+	loff_t num_extents_per_page = (PAGE_SIZE
 				       / crypt_stat->extent_size);
 	int rc = 0;
 
@@ -138,7 +138,7 @@ ecryptfs_copy_up_encrypted_with_header(struct page *page,
 			char *page_virt;
 
 			page_virt = kmap_atomic(page);
-			memset(page_virt, 0, PAGE_CACHE_SIZE);
+			memset(page_virt, 0, PAGE_SIZE);
 			/* TODO: Support more than one header extent */
 			if (view_extent_num == 0) {
 				size_t written;
@@ -164,8 +164,8 @@ ecryptfs_copy_up_encrypted_with_header(struct page *page,
 				 - crypt_stat->metadata_size);
 
 			rc = ecryptfs_read_lower_page_segment(
-				page, (lower_offset >> PAGE_CACHE_SHIFT),
-				(lower_offset & ~PAGE_CACHE_MASK),
+				page, (lower_offset >> PAGE_SHIFT),
+				(lower_offset & ~PAGE_MASK),
 				crypt_stat->extent_size, page->mapping->host);
 			if (rc) {
 				printk(KERN_ERR "%s: Error attempting to read "
@@ -198,7 +198,7 @@ static int ecryptfs_readpage(struct file *file, struct page *page)
 
 	if (!crypt_stat || !(crypt_stat->flags & ECRYPTFS_ENCRYPTED)) {
 		rc = ecryptfs_read_lower_page_segment(page, page->index, 0,
-						      PAGE_CACHE_SIZE,
+						      PAGE_SIZE,
 						      page->mapping->host);
 	} else if (crypt_stat->flags & ECRYPTFS_VIEW_AS_ENCRYPTED) {
 		if (crypt_stat->flags & ECRYPTFS_METADATA_IN_XATTR) {
@@ -215,7 +215,7 @@ static int ecryptfs_readpage(struct file *file, struct page *page)
 
 		} else {
 			rc = ecryptfs_read_lower_page_segment(
-				page, page->index, 0, PAGE_CACHE_SIZE,
+				page, page->index, 0, PAGE_SIZE,
 				page->mapping->host);
 			if (rc) {
 				printk(KERN_ERR "Error reading page; rc = "
@@ -250,12 +250,12 @@ static int fill_zeros_to_end_of_page(struct page *page, unsigned int to)
 	struct inode *inode = page->mapping->host;
 	int end_byte_in_page;
 
-	if ((i_size_read(inode) / PAGE_CACHE_SIZE) != page->index)
+	if ((i_size_read(inode) / PAGE_SIZE) != page->index)
 		goto out;
-	end_byte_in_page = i_size_read(inode) % PAGE_CACHE_SIZE;
+	end_byte_in_page = i_size_read(inode) % PAGE_SIZE;
 	if (to > end_byte_in_page)
 		end_byte_in_page = to;
-	zero_user_segment(page, end_byte_in_page, PAGE_CACHE_SIZE);
+	zero_user_segment(page, end_byte_in_page, PAGE_SIZE);
 out:
 	return 0;
 }
@@ -279,7 +279,7 @@ static int ecryptfs_write_begin(struct file *file,
 			loff_t pos, unsigned len, unsigned flags,
 			struct page **pagep, void **fsdata)
 {
-	pgoff_t index = pos >> PAGE_CACHE_SHIFT;
+	pgoff_t index = pos >> PAGE_SHIFT;
 	struct page *page;
 	loff_t prev_page_end_size;
 	int rc = 0;
@@ -289,14 +289,14 @@ static int ecryptfs_write_begin(struct file *file,
 		return -ENOMEM;
 	*pagep = page;
 
-	prev_page_end_size = ((loff_t)index << PAGE_CACHE_SHIFT);
+	prev_page_end_size = ((loff_t)index << PAGE_SHIFT);
 	if (!PageUptodate(page)) {
 		struct ecryptfs_crypt_stat *crypt_stat =
 			&ecryptfs_inode_to_private(mapping->host)->crypt_stat;
 
 		if (!(crypt_stat->flags & ECRYPTFS_ENCRYPTED)) {
 			rc = ecryptfs_read_lower_page_segment(
-				page, index, 0, PAGE_CACHE_SIZE, mapping->host);
+				page, index, 0, PAGE_SIZE, mapping->host);
 			if (rc) {
 				printk(KERN_ERR "%s: Error attempting to read "
 				       "lower page segment; rc = [%d]\n",
@@ -322,7 +322,7 @@ static int ecryptfs_write_begin(struct file *file,
 				SetPageUptodate(page);
 			} else {
 				rc = ecryptfs_read_lower_page_segment(
-					page, index, 0, PAGE_CACHE_SIZE,
+					page, index, 0, PAGE_SIZE,
 					mapping->host);
 				if (rc) {
 					printk(KERN_ERR "%s: Error reading "
@@ -336,9 +336,9 @@ static int ecryptfs_write_begin(struct file *file,
 		} else {
 			if (prev_page_end_size
 			    >= i_size_read(page->mapping->host)) {
-				zero_user(page, 0, PAGE_CACHE_SIZE);
+				zero_user(page, 0, PAGE_SIZE);
 				SetPageUptodate(page);
-			} else if (len < PAGE_CACHE_SIZE) {
+			} else if (len < PAGE_SIZE) {
 				rc = ecryptfs_decrypt_page(page);
 				if (rc) {
 					printk(KERN_ERR "%s: Error decrypting "
@@ -371,11 +371,11 @@ static int ecryptfs_write_begin(struct file *file,
 	 * of page?  Zero it out. */
 	if ((i_size_read(mapping->host) == prev_page_end_size)
 	    && (pos != 0))
-		zero_user(page, 0, PAGE_CACHE_SIZE);
+		zero_user(page, 0, PAGE_SIZE);
 out:
 	if (unlikely(rc)) {
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 		*pagep = NULL;
 	}
 	return rc;
@@ -437,7 +437,7 @@ static int ecryptfs_write_inode_size_to_xattr(struct inode *ecryptfs_inode)
 	}
 	inode_lock(lower_inode);
 	size = lower_inode->i_op->getxattr(lower_dentry, ECRYPTFS_XATTR_NAME,
-					   xattr_virt, PAGE_CACHE_SIZE);
+					   xattr_virt, PAGE_SIZE);
 	if (size < 0)
 		size = 8;
 	put_unaligned_be64(i_size_read(ecryptfs_inode), xattr_virt);
@@ -479,8 +479,8 @@ static int ecryptfs_write_end(struct file *file,
 			loff_t pos, unsigned len, unsigned copied,
 			struct page *page, void *fsdata)
 {
-	pgoff_t index = pos >> PAGE_CACHE_SHIFT;
-	unsigned from = pos & (PAGE_CACHE_SIZE - 1);
+	pgoff_t index = pos >> PAGE_SHIFT;
+	unsigned from = pos & (PAGE_SIZE - 1);
 	unsigned to = from + copied;
 	struct inode *ecryptfs_inode = mapping->host;
 	struct ecryptfs_crypt_stat *crypt_stat =
@@ -500,7 +500,7 @@ static int ecryptfs_write_end(struct file *file,
 		goto out;
 	}
 	if (!PageUptodate(page)) {
-		if (copied < PAGE_CACHE_SIZE) {
+		if (copied < PAGE_SIZE) {
 			rc = 0;
 			goto out;
 		}
@@ -533,7 +533,7 @@ static int ecryptfs_write_end(struct file *file,
 		rc = copied;
 out:
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 	return rc;
 }
 
diff --git a/fs/ecryptfs/read_write.c b/fs/ecryptfs/read_write.c
index 09fe622274e4..158a3a39f82d 100644
--- a/fs/ecryptfs/read_write.c
+++ b/fs/ecryptfs/read_write.c
@@ -74,7 +74,7 @@ int ecryptfs_write_lower_page_segment(struct inode *ecryptfs_inode,
 	loff_t offset;
 	int rc;
 
-	offset = ((((loff_t)page_for_lower->index) << PAGE_CACHE_SHIFT)
+	offset = ((((loff_t)page_for_lower->index) << PAGE_SHIFT)
 		  + offset_in_page);
 	virt = kmap(page_for_lower);
 	rc = ecryptfs_write_lower(ecryptfs_inode, virt, offset, size);
@@ -123,9 +123,9 @@ int ecryptfs_write(struct inode *ecryptfs_inode, char *data, loff_t offset,
 	else
 		pos = offset;
 	while (pos < (offset + size)) {
-		pgoff_t ecryptfs_page_idx = (pos >> PAGE_CACHE_SHIFT);
-		size_t start_offset_in_page = (pos & ~PAGE_CACHE_MASK);
-		size_t num_bytes = (PAGE_CACHE_SIZE - start_offset_in_page);
+		pgoff_t ecryptfs_page_idx = (pos >> PAGE_SHIFT);
+		size_t start_offset_in_page = (pos & ~PAGE_MASK);
+		size_t num_bytes = (PAGE_SIZE - start_offset_in_page);
 		loff_t total_remaining_bytes = ((offset + size) - pos);
 
 		if (fatal_signal_pending(current)) {
@@ -165,7 +165,7 @@ int ecryptfs_write(struct inode *ecryptfs_inode, char *data, loff_t offset,
 			 * Fill in zero values to the end of the page */
 			memset(((char *)ecryptfs_page_virt
 				+ start_offset_in_page), 0,
-				PAGE_CACHE_SIZE - start_offset_in_page);
+				PAGE_SIZE - start_offset_in_page);
 		}
 
 		/* pos >= offset, we are now writing the data request */
@@ -186,7 +186,7 @@ int ecryptfs_write(struct inode *ecryptfs_inode, char *data, loff_t offset,
 						ecryptfs_page,
 						start_offset_in_page,
 						data_offset);
-		page_cache_release(ecryptfs_page);
+		put_page(ecryptfs_page);
 		if (rc) {
 			printk(KERN_ERR "%s: Error encrypting "
 			       "page; rc = [%d]\n", __func__, rc);
@@ -262,7 +262,7 @@ int ecryptfs_read_lower_page_segment(struct page *page_for_ecryptfs,
 	loff_t offset;
 	int rc;
 
-	offset = ((((loff_t)page_index) << PAGE_CACHE_SHIFT) + offset_in_page);
+	offset = ((((loff_t)page_index) << PAGE_SHIFT) + offset_in_page);
 	virt = kmap(page_for_ecryptfs);
 	rc = ecryptfs_read_lower(virt, offset, size, ecryptfs_inode);
 	if (rc > 0)
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
