Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f175.google.com (mail-qk0-f175.google.com [209.85.220.175])
	by kanga.kvack.org (Postfix) with ESMTP id 21F486B02EC
	for <linux-mm@kvack.org>; Mon,  5 Oct 2015 22:07:54 -0400 (EDT)
Received: by qkbi190 with SMTP id i190so56903995qkb.1
        for <linux-mm@kvack.org>; Mon, 05 Oct 2015 19:07:53 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 8si26077402qhq.109.2015.10.05.19.07.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Oct 2015 19:07:53 -0700 (PDT)
Date: Mon, 5 Oct 2015 19:12:17 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: linux-next: kernel BUG at mm/slub.c:1447!
Message-Id: <20151005191217.48008dc7.akpm@linux-foundation.org>
In-Reply-To: <20151005122936.8a3b0fe21629390c9aa8bc2a@linux-foundation.org>
References: <560D59F7.4070002@roeck-us.net>
	<20151001134904.127ccc7bea14e969fbfba0d5@linux-foundation.org>
	<20151002072522.GC30354@dhcp22.suse.cz>
	<20151002134953.551e6379ee9f6b5a0aeb7af7@linux-foundation.org>
	<20151005134713.GC7023@dhcp22.suse.cz>
	<20151005122936.8a3b0fe21629390c9aa8bc2a@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Guenter Roeck <linux@roeck-us.net>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>

On Mon, 5 Oct 2015 12:29:36 -0700 Andrew Morton <akpm@linux-foundation.org> wrote:

> Maybe it would be better to add the gfp_t argument to the
> address_space_operations.  At a minimum, writepage(), readpage(),
> writepages(), readpages().  What a pickle.

I'm being dumb.  All we need to do is to add a new

	address_space_operations.readpage_gfp(..., gfp_t gfp)

etc.  That should be trivial.  Each fs type only has 2-4 instances of
address_space_operations so the overhead is miniscule.

As a background janitorial thing we can migrate filesystems over to the
new interface then remove address_space_operations.readpage() etc.  But
this *would* add overhead: more stack and more text for no gain.  So
perhaps we just leave things as they are.

That's so simple that I expect we can short-term fix this bug with that
approach.  umm, something like

--- a/fs/mpage.c~a
+++ a/fs/mpage.c
@@ -139,7 +139,8 @@ map_buffer_to_page(struct page *page, st
 static struct bio *
 do_mpage_readpage(struct bio *bio, struct page *page, unsigned nr_pages,
 		sector_t *last_block_in_bio, struct buffer_head *map_bh,
-		unsigned long *first_logical_block, get_block_t get_block)
+		unsigned long *first_logical_block, get_block_t get_block,
+		gfp_t gfp)
 {
 	struct inode *inode = page->mapping->host;
 	const unsigned blkbits = inode->i_blkbits;
@@ -278,7 +279,7 @@ alloc_new:
 		}
 		bio = mpage_alloc(bdev, blocks[0] << (blkbits - 9),
 				min_t(int, nr_pages, BIO_MAX_PAGES),
-				GFP_KERNEL);
+				gfp);
 		if (bio == NULL)
 			goto confused;
 	}
@@ -310,7 +311,7 @@ confused:
 }
 
 /**
- * mpage_readpages - populate an address space with some pages & start reads against them
+ * mpage_readpages_gfp - populate an address space with some pages & start reads against them
  * @mapping: the address_space
  * @pages: The address of a list_head which contains the target pages.  These
  *   pages have their ->index populated and are otherwise uninitialised.
@@ -318,6 +319,7 @@ confused:
  *   issued in @pages->prev to @pages->next order.
  * @nr_pages: The number of pages at *@pages
  * @get_block: The filesystem's block mapper function.
+ * @gfp: memory allocation constraints
  *
  * This function walks the pages and the blocks within each page, building and
  * emitting large BIOs.
@@ -352,9 +354,8 @@ confused:
  *
  * This all causes the disk requests to be issued in the correct order.
  */
-int
-mpage_readpages(struct address_space *mapping, struct list_head *pages,
-				unsigned nr_pages, get_block_t get_block)
+int mpage_readpages_gfp(struct address_space *mapping, struct list_head *pages,
+			unsigned nr_pages, get_block_t get_block, gfp_t gfp)
 {
 	struct bio *bio = NULL;
 	unsigned page_idx;
@@ -370,12 +371,12 @@ mpage_readpages(struct address_space *ma
 		prefetchw(&page->flags);
 		list_del(&page->lru);
 		if (!add_to_page_cache_lru(page, mapping,
-					page->index, GFP_KERNEL)) {
+					page->index, gfp)) {
 			bio = do_mpage_readpage(bio, page,
 					nr_pages - page_idx,
 					&last_block_in_bio, &map_bh,
 					&first_logical_block,
-					get_block);
+					get_block, gfp);
 		}
 		page_cache_release(page);
 	}
@@ -384,6 +385,14 @@ mpage_readpages(struct address_space *ma
 		mpage_bio_submit(READ, bio);
 	return 0;
 }
+EXPORT_SYMBOL(mpage_readpages_gfp);
+
+int mpage_readpages(struct address_space *mapping, struct list_head *pages,
+			unsigned nr_pages, get_block_t get_block)
+{
+	return mpage_readpages_gfp(mapping, pages, nr_pages, get_block,
+				   GFP_KERNEL);
+}
 EXPORT_SYMBOL(mpage_readpages);
 
 /*
@@ -399,7 +408,7 @@ int mpage_readpage(struct page *page, ge
 	map_bh.b_state = 0;
 	map_bh.b_size = 0;
 	bio = do_mpage_readpage(bio, page, 1, &last_block_in_bio,
-			&map_bh, &first_logical_block, get_block);
+			&map_bh, &first_logical_block, get_block, GFP_KERNEL);
 	if (bio)
 		mpage_bio_submit(READ, bio);
 	return 0;
diff -puN include/linux/fs.h~a include/linux/fs.h
diff -puN include/linux/mpage.h~a include/linux/mpage.h
--- a/include/linux/mpage.h~a
+++ a/include/linux/mpage.h
@@ -15,6 +15,8 @@ struct writeback_control;
 
 int mpage_readpages(struct address_space *mapping, struct list_head *pages,
 				unsigned nr_pages, get_block_t get_block);
+int mpage_readpages_gfp(struct address_space *mapping, struct list_head *pages,
+			unsigned nr_pages, get_block_t get_block, gfp_t gfp);
 int mpage_readpage(struct page *page, get_block_t get_block);
 int mpage_writepages(struct address_space *mapping,
 		struct writeback_control *wbc, get_block_t get_block);
diff -puN fs/xfs/xfs_aops.c~a fs/xfs/xfs_aops.c
--- a/fs/xfs/xfs_aops.c~a
+++ a/fs/xfs/xfs_aops.c
@@ -1908,13 +1908,14 @@ xfs_vm_readpage(
 }
 
 STATIC int
-xfs_vm_readpages(
+xfs_vm_readpages_gfp(
 	struct file		*unused,
 	struct address_space	*mapping,
 	struct list_head	*pages,
 	unsigned		nr_pages)
 {
-	return mpage_readpages(mapping, pages, nr_pages, xfs_get_blocks);
+	return mpage_readpages_gfp(mapping, pages, nr_pages, xfs_get_blocks,
+				   GFP_NOFS);
 }
 
 /*
@@ -1987,7 +1988,7 @@ xfs_vm_set_page_dirty(
 
 const struct address_space_operations xfs_address_space_operations = {
 	.readpage		= xfs_vm_readpage,
-	.readpages		= xfs_vm_readpages,
+	.readpages		= xfs_vm_readpages_gfp,
 	.writepage		= xfs_vm_writepage,
 	.writepages		= xfs_vm_writepages,
 	.set_page_dirty		= xfs_vm_set_page_dirty,
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
