In-reply-to: <20080220150308.142619000@chello.nl> (message from Peter Zijlstra
	on Wed, 20 Feb 2008 15:46:32 +0100)
Subject: Re: [PATCH 22/28] mm: add support for non block device backed swap files
References: <20080220144610.548202000@chello.nl> <20080220150308.142619000@chello.nl>
Message-Id: <E1JTzBV-0001aO-R3@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Tue, 26 Feb 2008 13:45:25 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: a.p.zijlstra@chello.nl
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Starting review in the middle, because this is the part I'm most
familiar with.

> New addres_space_operations methods are added:
>   int swapfile(struct address_space *, int);

Separate ->swapon() and ->swapoff() methods would be so much cleaner IMO.

Also is there a reason why 'struct file *' cannot be supplied to these
functions?

[snip]

> +int swap_set_page_dirty(struct page *page)
> +{
> +	struct swap_info_struct *sis = page_swap_info(page);
> +
> +	if (sis->flags & SWP_FILE) {
> +		const struct address_space_operations *a_ops =
> +			sis->swap_file->f_mapping->a_ops;
> +		int (*spd)(struct page *) = a_ops->set_page_dirty;
> +#ifdef CONFIG_BLOCK
> +		if (!spd)
> +			spd = __set_page_dirty_buffers;
> +#endif

This ifdef is not really needed.  Just require ->set_page_dirty() be
filled in by filesystems which want swapfiles (and others too, in the
longer term, the fallback is just historical crud).

Here's an incremental patch addressing these issues and beautifying
the new code.

Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>

Index: linux/mm/page_io.c
===================================================================
--- linux.orig/mm/page_io.c	2008-02-26 11:15:58.000000000 +0100
+++ linux/mm/page_io.c	2008-02-26 13:40:55.000000000 +0100
@@ -106,8 +106,10 @@ int swap_writepage(struct page *page, st
 	}
 
 	if (sis->flags & SWP_FILE) {
-		ret = sis->swap_file->f_mapping->
-			a_ops->swap_out(sis->swap_file, page, wbc);
+		struct file *swap_file = sis->swap_file;
+		struct address_space *mapping = swap_file->f_mapping;
+
+		ret = mapping->a_ops->swap_out(swap_file, page, wbc);
 		if (!ret)
 			count_vm_event(PSWPOUT);
 		return ret;
@@ -136,12 +138,13 @@ void swap_sync_page(struct page *page)
 	struct swap_info_struct *sis = page_swap_info(page);
 
 	if (sis->flags & SWP_FILE) {
-		const struct address_space_operations *a_ops =
-			sis->swap_file->f_mapping->a_ops;
-		if (a_ops->sync_page)
-			a_ops->sync_page(page);
-	} else
+		struct address_space *mapping = sis->swap_file->f_mapping;
+
+		if (mapping->a_ops->sync_page)
+			mapping->a_ops->sync_page(page);
+	} else {
 		block_sync_page(page);
+	}
 }
 
 int swap_set_page_dirty(struct page *page)
@@ -149,17 +152,12 @@ int swap_set_page_dirty(struct page *pag
 	struct swap_info_struct *sis = page_swap_info(page);
 
 	if (sis->flags & SWP_FILE) {
-		const struct address_space_operations *a_ops =
-			sis->swap_file->f_mapping->a_ops;
-		int (*spd)(struct page *) = a_ops->set_page_dirty;
-#ifdef CONFIG_BLOCK
-		if (!spd)
-			spd = __set_page_dirty_buffers;
-#endif
-		return (*spd)(page);
-	}
+		struct address_space *mapping = sis->swap_file->f_mapping;
 
-	return __set_page_dirty_nobuffers(page);
+		return mapping->a_ops->set_page_dirty(page);
+	} else {
+		return __set_page_dirty_nobuffers(page);
+	}
 }
 
 int swap_readpage(struct file *file, struct page *page)
@@ -172,8 +170,10 @@ int swap_readpage(struct file *file, str
 	BUG_ON(PageUptodate(page));
 
 	if (sis->flags & SWP_FILE) {
-		ret = sis->swap_file->f_mapping->
-			a_ops->swap_in(sis->swap_file, page);
+		struct file *swap_file = sis->swap_file;
+		struct address_space *mapping = swap_file->f_mapping;
+
+		ret = mapping->a_ops->swap_in(swap_file, page);
 		if (!ret)
 			count_vm_event(PSWPIN);
 		return ret;
Index: linux/include/linux/fs.h
===================================================================
--- linux.orig/include/linux/fs.h	2008-02-26 11:15:58.000000000 +0100
+++ linux/include/linux/fs.h	2008-02-26 13:29:40.000000000 +0100
@@ -485,7 +485,8 @@ struct address_space_operations {
 	/*
 	 * swapfile support
 	 */
-	int (*swapfile)(struct address_space *, int);
+	int (*swapon)(struct file *file);
+	int (*swapoff)(struct file *file);
 	int (*swap_out)(struct file *file, struct page *page,
 			struct writeback_control *wbc);
 	int (*swap_in)(struct file *file, struct page *page);
Index: linux/mm/swapfile.c
===================================================================
--- linux.orig/mm/swapfile.c	2008-02-26 12:43:57.000000000 +0100
+++ linux/mm/swapfile.c	2008-02-26 13:34:57.000000000 +0100
@@ -1014,9 +1014,11 @@ static void destroy_swap_extents(struct 
 	}
 
 	if (sis->flags & SWP_FILE) {
+		struct file *swap_file = sis->swap_file;
+		struct address_space *mapping = swap_file->f_mapping;
+
 		sis->flags &= ~SWP_FILE;
-		sis->swap_file->f_mapping->a_ops->
-			swapfile(sis->swap_file->f_mapping, 0);
+		mapping->a_ops->swapoff(swap_file);
 	}
 }
 
@@ -1092,7 +1094,9 @@ add_swap_extent(struct swap_info_struct 
  */
 static int setup_swap_extents(struct swap_info_struct *sis, sector_t *span)
 {
-	struct inode *inode;
+	struct file *swap_file = sis->swap_file;
+	struct address_space *mapping = swap_file->f_mapping;
+	struct inode *inode = mapping->host;
 	unsigned blocks_per_page;
 	unsigned long page_no;
 	unsigned blkbits;
@@ -1103,16 +1107,14 @@ static int setup_swap_extents(struct swa
 	int nr_extents = 0;
 	int ret;
 
-	inode = sis->swap_file->f_mapping->host;
 	if (S_ISBLK(inode->i_mode)) {
 		ret = add_swap_extent(sis, 0, sis->max, 0);
 		*span = sis->pages;
 		goto done;
 	}
 
-	if (sis->swap_file->f_mapping->a_ops->swapfile) {
-		ret = sis->swap_file->f_mapping->a_ops->
-			swapfile(sis->swap_file->f_mapping, 1);
+	if (mapping->a_ops->swapon) {
+		ret = mapping->a_ops->swapon(swap_file);
 		if (!ret) {
 			sis->flags |= SWP_FILE;
 			ret = add_swap_extent(sis, 0, sis->max, 0);



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
