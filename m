Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id E24D0600337
	for <linux-mm@kvack.org>; Mon,  5 Apr 2010 03:13:59 -0400 (EDT)
Date: Mon, 5 Apr 2010 09:13:45 +0200
From: =?utf-8?B?SsO2cm4=?= Engel <joern@logfs.org>
Subject: Re: why are some low-level MM routines being exported?
Message-ID: <20100405071344.GC23515@logfs.org>
References: <alpine.LFD.2.00.1004041125350.5617@localhost> <1270396784.1814.92.camel@barrios-desktop> <20100404160328.GA30540@ioremap.net> <1270398112.1814.114.camel@barrios-desktop> <20100404195533.GA8836@logfs.org> <p2g28c262361004041759n52f5063dhb182663321d918bb@mail.gmail.com> <20100405053026.GA23515@logfs.org> <x2w28c262361004042320x52dda2d1l30789cac28fbef6@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <x2w28c262361004042320x52dda2d1l30789cac28fbef6@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Evgeniy Polyakov <zbr@ioremap.net>, "Robert P. J. Day" <rpjday@crashcourse.ca>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 5 April 2010 15:20:36 +0900, Minchan Kim wrote:
> 
> Previously I said, what I have a concern is that if file systems or
> some modules abuses
> add_to_page_cache_lru, it might system LRU list wrong so then system
> go to hell.
> Of course, if we use it carefully, it can be good but how do you make sure it?

Having access to the source code means you only have to read all
callers.  This is not java, we don't have to add layers of anti-abuse
wrappers.  We can simply flame the first offender to a crisp. :)

> I am not a file system expert but as I read comment of read_cache_pages
> "Hides the details of the LRU cache etc from the filesystem", I
> thought it is not good that
> file system handle LRU list directly. At least, we have been trying for years.

Only speaking for logfs, I need some variant of find_or_create_page
where I can replace lock_page() with a custom function.  Whether that
function lives in fs/logfs/ or mm/filemap.c doesn't matter much.

What we could do something roughly like the patch below, at least
semantically.  I know the patch is crap in its current form, but it
illustrates the general idea.

JA?rn

-- 
The key to performance is elegance, not battalions of special cases.
-- Jon Bentley and Doug McIlroy

diff --git a/mm/filemap.c b/mm/filemap.c
index 045b31c..6d452eb 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -646,27 +646,19 @@ repeat:
 }
 EXPORT_SYMBOL(find_get_page);
 
-/**
- * find_lock_page - locate, pin and lock a pagecache page
- * @mapping: the address_space to search
- * @offset: the page index
- *
- * Locates the desired pagecache page, locks it, increments its reference
- * count and returns its address.
- *
- * Returns zero if the page was not present. find_lock_page() may sleep.
- */
-struct page *find_lock_page(struct address_space *mapping, pgoff_t offset)
+static struct page *__find_lock_page(struct address_space *mapping,
+		pgoff_t offset, void(*lock)(struct page *),
+		void(*unlock)(struct page *))
 {
 	struct page *page;
 
 repeat:
 	page = find_get_page(mapping, offset);
 	if (page) {
-		lock_page(page);
+		lock(page);
 		/* Has the page been truncated? */
 		if (unlikely(page->mapping != mapping)) {
-			unlock_page(page);
+			unlock(page);
 			page_cache_release(page);
 			goto repeat;
 		}
@@ -674,32 +666,31 @@ repeat:
 	}
 	return page;
 }
-EXPORT_SYMBOL(find_lock_page);
 
 /**
- * find_or_create_page - locate or add a pagecache page
- * @mapping: the page's address_space
- * @index: the page's index into the mapping
- * @gfp_mask: page allocation mode
- *
- * Locates a page in the pagecache.  If the page is not present, a new page
- * is allocated using @gfp_mask and is added to the pagecache and to the VM's
- * LRU list.  The returned page is locked and has its reference count
- * incremented.
+ * find_lock_page - locate, pin and lock a pagecache page
+ * @mapping: the address_space to search
+ * @offset: the page index
  *
- * find_or_create_page() may sleep, even if @gfp_flags specifies an atomic
- * allocation!
+ * Locates the desired pagecache page, locks it, increments its reference
+ * count and returns its address.
  *
- * find_or_create_page() returns the desired page's address, or zero on
- * memory exhaustion.
+ * Returns zero if the page was not present. find_lock_page() may sleep.
  */
-struct page *find_or_create_page(struct address_space *mapping,
-		pgoff_t index, gfp_t gfp_mask)
+struct page *find_lock_page(struct address_space *mapping, pgoff_t offset)
+{
+	return __find_lock_page(mapping, offset, lock_page, unlock_page);
+}
+EXPORT_SYMBOL(find_lock_page);
+
+static struct page *__find_or_create_page(struct address_space *mapping,
+		pgoff_t index, gfp_t gfp_mask, void(*lock)(struct page *),
+		void(*unlock)(struct page *))
 {
 	struct page *page;
 	int err;
 repeat:
-	page = find_lock_page(mapping, index);
+	page = __find_lock_page(mapping, index, lock, unlock);
 	if (!page) {
 		page = __page_cache_alloc(gfp_mask);
 		if (!page)
@@ -721,6 +712,31 @@ repeat:
 	}
 	return page;
 }
+EXPORT_SYMBOL(__find_or_create_page);
+
+/**
+ * find_or_create_page - locate or add a pagecache page
+ * @mapping: the page's address_space
+ * @index: the page's index into the mapping
+ * @gfp_mask: page allocation mode
+ *
+ * Locates a page in the pagecache.  If the page is not present, a new page
+ * is allocated using @gfp_mask and is added to the pagecache and to the VM's
+ * LRU list.  The returned page is locked and has its reference count
+ * incremented.
+ *
+ * find_or_create_page() may sleep, even if @gfp_flags specifies an atomic
+ * allocation!
+ *
+ * find_or_create_page() returns the desired page's address, or zero on
+ * memory exhaustion.
+ */
+struct page *find_or_create_page(struct address_space *mapping,
+		pgoff_t index, gfp_t gfp_mask)
+{
+	return __find_or_create_page(mapping, index, gfp_mask, lock_page,
+			unlock_page);
+}
 EXPORT_SYMBOL(find_or_create_page);
 
 /**

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
