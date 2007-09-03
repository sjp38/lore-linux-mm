Date: Mon, 3 Sep 2007 18:09:43 -0300
From: "Luiz Fernando N. Capitulino" <lcapitulino@mandriva.com.br>
Subject: Re: [RFC:PATCH 00/07] VM File Tails
Message-ID: <20070903180943.1f9a0eb3@localhost>
In-Reply-To: <1188596826.20134.6.camel@norville.austin.ibm.com>
References: <20070829205325.28328.67953.sendpatchset@norville.austin.ibm.com>
	<20070831180006.2033828d@localhost>
	<1188596826.20134.6.camel@norville.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>, lcapitulino@gmail.com
List-ID: <linux-mm.kvack.org>

Em Fri, 31 Aug 2007 16:47:06 -0500
Dave Kleikamp <shaggy@linux.vnet.ibm.com> escreveu:

| I'm not sure exactly what's going on.  mapping->host can't be NULL, can
| it?  This patch is an improvement, but I'm not sure if it will fix the
| problem.  I won't have much time to look at this until next week, but
| feel free to give this a try.
| 
| Signed-off-by: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
| 
| diff -Nurp linux.orig/include/linux/vm_file_tail.h linux/include/linux/vm_file_tail.h
| --- linux.orig/include/linux/vm_file_tail.h	2007-08-29 13:27:46.000000000 -0500
| +++ linux/include/linux/vm_file_tail.h	2007-08-31 16:25:49.000000000 -0500
| @@ -54,7 +54,7 @@ void vm_file_tail_unpack(struct address_
|  static inline void vm_file_tail_unpack_index(struct address_space *mapping,
|  					     unsigned long index)
|  {
| -	if (index == vm_file_tail_index(mapping) && mapping->tail)
| +	if (mapping->tail && index == vm_file_tail_index(mapping))
|  		vm_file_tail_unpack(mapping);
|  }

 Ok, looks like it's fixed. I've ran the kernel with this patch
applied for a few hours and didn't get any problem (w/o this
patch I was getting the OOPS in a matter of minutes).

 Btw, in vm_file_tail_pack() when checking the size with the
spinlock held you have to free tail if things doesn't match
right?

 What about the following patch (only compile tested):

[PATCH]: vm_file_tail_pack() cleanup

  1. Fix a possible memory leak
  2. Add page_not_eligible()
  3. Do not duplicate exit code

---
 mm/file_tail.c |   65 +++++++++++++++++++++++++++++----------------------------
 1 file changed, 34 insertions(+), 31 deletions(-)

--- linux-2.6-vm.orig/mm/file_tail.c
+++ linux-2.6-vm/mm/file_tail.c
@@ -72,55 +72,56 @@ void vm_file_tail_unpack(struct address_
 		vm_file_tail_free(mapping);
 }
 
+static int page_not_eligible(struct page *page)
+{
+	if (!page->mapping || page->mapping->tail)
+		return 1;
+
+	if (PageDirty(page) || !PageUptodate(page) || PageWriteback(page))
+		return 1;
+
+	if ((page_count(page) > 2) || mapping_mapped(page->mapping) ||
+	    PageSwapCache(page))
+		return 1;
+
+	return 0;
+}
+
 /* * Determine if the page is eligible to be packed, and if so, pack it
  *
- * Non-fatal if this fails.  The page will remain in the page cache.
+ * Non-fatal if this fails. The page will remain in the page cache.
+ * 
+ * Returns 1 if the page was packed, 0 otherwise
  */
 int vm_file_tail_pack(struct page *page)
 {
 	unsigned long flags;
 	pgoff_t index;
 	void *kaddr;
-	int length;
+	int length, ret = 0;
 	struct address_space *mapping;
 	void *tail;
 
 	if (TestSetPageLocked(page))
 		return 0;
 
-	mapping = page->mapping;
-
-	if (!mapping ||
-	    mapping->tail ||
-	    PageDirty(page) ||
-	    !PageUptodate(page) ||
-	    PageWriteback(page) ||
-	    (page_count(page) > 2) ||
-	    mapping_mapped(mapping) ||
-	    PageSwapCache(page)) {
-		unlock_page(page);
-		return 0;
-	}
+	if (page_not_eligible(page))
+		goto out;
 
+	mapping = page->mapping;
 	index = vm_file_tail_index(mapping);
 	length = vm_file_tail_length(mapping);
 
 	if ((index != page->index) ||
-	    (length > PAGE_CACHE_SIZE / 2)) {
-		unlock_page(page);
-		return 0;
-	}
+	    (length > PAGE_CACHE_SIZE / 2))
+		goto out;
 
-	if (PagePrivate(page) && !try_to_release_page(page, 0)) {
-		unlock_page(page);
-		return 0;
-	}
+	if (PagePrivate(page) && !try_to_release_page(page, 0))
+		goto out;
 
 	tail = kmalloc(length, GFP_NOWAIT);
-	if (!tail) {
-		unlock_page(page);
-		return 0;
-	}
+	if (!tail)
+		goto out;
 
 	kaddr = kmap_atomic(page, KM_USER0);
 	memcpy(tail, kaddr, length);
@@ -133,8 +134,8 @@ int vm_file_tail_pack(struct page *page)
 	   (length != vm_file_tail_length(mapping))) {
 		/* File size must have changed */
 		spin_unlock_irqrestore(&mapping->tail_lock, flags);
-		unlock_page(page);
-		return 0;
+		kfree(tail);
+		goto out;
 	}
 
 	mapping->tail = tail;
@@ -143,9 +144,11 @@ int vm_file_tail_pack(struct page *page)
 
 	remove_from_page_cache(page);
 	page_cache_release(page);	/* pagecache ref */
-	unlock_page(page);
+	ret = 1;
 
-	return 1;
+out:	
+	unlock_page(page);
+	return ret;
 }
 
 void __vm_file_tail_unpack_on_resize(struct inode *inode, loff_t new_size)


-- 
Luiz Fernando N. Capitulino

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
