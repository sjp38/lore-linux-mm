Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f51.google.com (mail-bk0-f51.google.com [209.85.214.51])
	by kanga.kvack.org (Postfix) with ESMTP id C94086B0035
	for <linux-mm@kvack.org>; Tue, 11 Mar 2014 21:16:46 -0400 (EDT)
Received: by mail-bk0-f51.google.com with SMTP id 6so1317281bkj.24
        for <linux-mm@kvack.org>; Tue, 11 Mar 2014 18:16:46 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id uh6si7812099bkb.333.2014.03.11.18.16.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 11 Mar 2014 18:16:45 -0700 (PDT)
Date: Tue, 11 Mar 2014 21:15:58 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 5/9] mm + fs: prepare for non-page entries in page cache
 radix trees
Message-ID: <20140312011558.GA14688@cmpxchg.org>
References: <1389377443-11755-1-git-send-email-hannes@cmpxchg.org>
 <1389377443-11755-6-git-send-email-hannes@cmpxchg.org>
 <20140212140052.GT6732@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140212140052.GT6732@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Bob Liu <bob.liu@oracle.com>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Luigi Semenzato <semenzato@google.com>, Metin Doslu <metin@citusdata.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan.kim@gmail.com>, Ozgun Erdogan <ozgun@citusdata.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Roman Gushchin <klamm@yandex-team.ru>, Ryan Mallon <rmallon@gmail.com>, Tejun Heo <tj@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Hello Mel,

On Wed, Feb 12, 2014 at 02:00:52PM +0000, Mel Gorman wrote:
> On Fri, Jan 10, 2014 at 01:10:39PM -0500, Johannes Weiner wrote:
> > @@ -248,12 +248,15 @@ pgoff_t page_cache_next_hole(struct address_space *mapping,
> >  pgoff_t page_cache_prev_hole(struct address_space *mapping,
> >  			     pgoff_t index, unsigned long max_scan);
> >  
> > -extern struct page * find_get_page(struct address_space *mapping,
> > -				pgoff_t index);
> > -extern struct page * find_lock_page(struct address_space *mapping,
> > -				pgoff_t index);
> > -extern struct page * find_or_create_page(struct address_space *mapping,
> > -				pgoff_t index, gfp_t gfp_mask);
> > +struct page *__find_get_page(struct address_space *mapping, pgoff_t offset);
> > +struct page *find_get_page(struct address_space *mapping, pgoff_t offset);
> > +struct page *__find_lock_page(struct address_space *mapping, pgoff_t offset);
> > +struct page *find_lock_page(struct address_space *mapping, pgoff_t offset);
> > +struct page *find_or_create_page(struct address_space *mapping, pgoff_t index,
> > +				 gfp_t gfp_mask);
> > +unsigned __find_get_pages(struct address_space *mapping, pgoff_t start,
> > +			  unsigned int nr_pages, struct page **pages,
> > +			  pgoff_t *indices);
> 
> When I see foo() and __foo() in a header, my first assumption is that
> __foo() is a version of foo() that assumes the necesssary locks are
> already held. If I see it within a C file, my second assumption will be
> that it's an internal helper. Here __find_get_page is not returning just
> a page. It's returning a page or a shadow entry if they exist and that may
> cause some confusion. Consider renaming __find_get_page to find_get_entry()
> to give a hint to the reader they should be looking out for either pages
> or shadow entries. It still makes sense for find_lock_entry -- if it's a
> page, then it'll return locked etc

Oh, this is so much better.  I renamed the whole thing to
find_get_entry, find_get_entries, find_lock_entry,
pagevec_lookup_entries() and so forth.

Thanks for the suggestion.

> > @@ -446,6 +446,29 @@ int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask)
> >  }
> >  EXPORT_SYMBOL_GPL(replace_page_cache_page);
> >  
> > +static int page_cache_tree_insert(struct address_space *mapping,
> > +				  struct page *page)
> > +{
> 
> Nothing here on the locking rules for the function although the existing
> docs here are poor. Everyone knows you need the mapping lock and page lock
> here, right?

Yes, I would think so.  The function was only split out for
readability and not really as an interface...

> > @@ -762,14 +790,19 @@ pgoff_t page_cache_prev_hole(struct address_space *mapping,
> >  EXPORT_SYMBOL(page_cache_prev_hole);
> >  
> >  /**
> > - * find_get_page - find and get a page reference
> > + * __find_get_page - find and get a page reference
> 
> This comment will be out of date when it could be returning shadow
> entries

Oops, fixed.  And renamed to find_get_entry().  Thanks.

> >   * @mapping: the address_space to search
> >   * @offset: the page index
> >   *
> > - * Is there a pagecache struct page at the given (mapping, offset) tuple?
> > - * If yes, increment its refcount and return it; if no, return NULL.
> > + * Looks up the page cache slot at @mapping & @offset.  If there is a
> > + * page cache page, it is returned with an increased refcount.
> > + *
> > + * If the slot holds a shadow entry of a previously evicted page, it
> > + * is returned.
> > + *
> 
> That's not true yet but who cares. Anyone doing a git blame of the history
> will need to search around the area anyway.

Technically the documentation is true, just nobody stores shadow
entries yet :)

> > @@ -810,24 +843,49 @@ out:
> >  
> >  	return page;
> >  }
> > +EXPORT_SYMBOL(__find_get_page);
> > +
> > +/**
> > + * find_get_page - find and get a page reference
> > + * @mapping: the address_space to search
> > + * @offset: the page index
> > + *
> > + * Looks up the page cache slot at @mapping & @offset.  If there is a
> > + * page cache page, it is returned with an increased refcount.
> > + *
> > + * Otherwise, %NULL is returned.
> > + */
> > +struct page *find_get_page(struct address_space *mapping, pgoff_t offset)
> > +{
> > +	struct page *page = __find_get_page(mapping, offset);
> > +
> > +	if (radix_tree_exceptional_entry(page))
> > +		page = NULL;
> > +	return page;
> > +}
> >  EXPORT_SYMBOL(find_get_page);
> >  
> >  /**
> > - * find_lock_page - locate, pin and lock a pagecache page
> > + * __find_lock_page - locate, pin and lock a pagecache page
> >   * @mapping: the address_space to search
> >   * @offset: the page index
> >   *
> > - * Locates the desired pagecache page, locks it, increments its reference
> > - * count and returns its address.
> > + * Looks up the page cache slot at @mapping & @offset.  If there is a
> > + * page cache page, it is returned locked and with an increased
> > + * refcount.
> > + *
> > + * If the slot holds a shadow entry of a previously evicted page, it
> > + * is returned.
> > + *
> > + * Otherwise, %NULL is returned.
> >   *
> > - * Returns zero if the page was not present. find_lock_page() may sleep.
> > + * __find_lock_page() may sleep.
> >   */
> > -struct page *find_lock_page(struct address_space *mapping, pgoff_t offset)
> > +struct page *__find_lock_page(struct address_space *mapping, pgoff_t offset)
> >  {
> >  	struct page *page;
> > -
> >  repeat:
> 
> Unnecessary whitespace change.

I reverted that.

> > -	page = find_get_page(mapping, offset);
> > +	page = __find_get_page(mapping, offset);
> >  	if (page && !radix_tree_exception(page)) {
> >  		lock_page(page);
> >  		/* Has the page been truncated? */
> 
> Just as an example, if this was find_get_entry() it would be a lot
> clearer that the return value may or may not be a page.

Fully agreed, this site has been updated.

> > @@ -890,6 +973,73 @@ repeat:
> >  EXPORT_SYMBOL(find_or_create_page);
> >  
> >  /**
> > + * __find_get_pages - gang pagecache lookup
> > + * @mapping:	The address_space to search
> > + * @start:	The starting page index
> > + * @nr_pages:	The maximum number of pages
> > + * @pages:	Where the resulting pages are placed
> > + *
> > + * __find_get_pages() will search for and return a group of up to
> > + * @nr_pages pages in the mapping.  The pages are placed at @pages.
> > + * __find_get_pages() takes a reference against the returned pages.
> > + *
> > + * The search returns a group of mapping-contiguous pages with ascending
> > + * indexes.  There may be holes in the indices due to not-present pages.
> > + *
> > + * Any shadow entries of evicted pages are included in the returned
> > + * array.
> > + *
> > + * __find_get_pages() returns the number of pages and shadow entries
> > + * which were found.
> > + */
> > +unsigned __find_get_pages(struct address_space *mapping,
> > +			  pgoff_t start, unsigned int nr_pages,
> > +			  struct page **pages, pgoff_t *indices)
> > +{
> > +	void **slot;
> > +	unsigned int ret = 0;
> > +	struct radix_tree_iter iter;
> > +
> > +	if (!nr_pages)
> > +		return 0;
> > +
> > +	rcu_read_lock();
> > +restart:
> > +	radix_tree_for_each_slot(slot, &mapping->page_tree, &iter, start) {
> > +		struct page *page;
> > +repeat:
> > +		page = radix_tree_deref_slot(slot);
> > +		if (unlikely(!page))
> > +			continue;
> > +		if (radix_tree_exception(page)) {
> > +			if (radix_tree_deref_retry(page))
> > +				goto restart;
> > +			/*
> > +			 * Otherwise, we must be storing a swap entry
> > +			 * here as an exceptional entry: so return it
> > +			 * without attempting to raise page count.
> > +			 */
> > +			goto export;
> > +		}
> 
> There is a non-obvious API hazard here that should be called out in
> the function description. shmem was the previous gang lookup user and
> it knew that there would be swap entries and removed them if necessary
> with shmem_deswap_pagevec. It was internal to shmem.c so it could deal
> with the complexity. Now that you are making it a generic function it
> should clearly explain that exceptional entries can be returned and
> pagevec_remove_exceptionals should be used to remove them if necessary
> or else split the helper in two to return just pages or both pages and
> exceptional entries.

I'm confused.  That is not the pagevec API, so
pagevec_remove_exceptionals() does not apply.

Also, this API does in fact provide two functions, one of which
returns all entries, and one which returns only pages.  They are
called __find_get_pages() (now find_get_entries()) and
find_get_pages().

> > @@ -179,7 +179,7 @@ __do_page_cache_readahead(struct address_space *mapping, struct file *filp,
> >  		rcu_read_lock();
> >  		page = radix_tree_lookup(&mapping->page_tree, page_offset);
> >  		rcu_read_unlock();
> > -		if (page)
> > +		if (page && !radix_tree_exceptional_entry(page))
> >  			continue;
> >  
> >  		page = page_cache_alloc_readahead(mapping);
> 
> Maybe just think hunk can be split out and shared with btrfs to avoid it
> dealing with exceptional entries although I've no good suggestions on what
> you'd call it.

I'd rather btrfs wouldn't poke around in page cache internals like
that, so I'm reluctant to provide an interface to facilitate it.  Or
put lipstick on the pig... :)

Here is a delta patch based on your feedback.  Thanks for the review!

Andrew, short of any objections, could you please include the
following patch as
mm-fs-prepare-for-non-page-entries-in-page-cache-radix-trees-fix-fix.patch?

Thanks!

---
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch] mm: __find_get_page() -> find_get_entry()

__find_get_page() -> find_get_entry()
__find_lock_page() -> find_lock_entry()
__find_get_pages() -> find_get_entries()
__pagevec_lookup() -> pagevec_lookup_entries()

Also update and fix stale kerneldocs and revert gratuitous whitespace
changes.

Based on feedback from Mel Gorman.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/pagemap.h |  8 +++----
 include/linux/pagevec.h |  6 +++--
 mm/filemap.c            | 61 ++++++++++++++++++++++++++-----------------------
 mm/mincore.c            |  2 +-
 mm/shmem.c              | 12 +++++-----
 mm/swap.c               | 31 +++++++++++++------------
 mm/truncate.c           |  8 +++----
 7 files changed, 68 insertions(+), 60 deletions(-)

diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 2eeca3c83b0f..493bfd85214e 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -248,14 +248,14 @@ pgoff_t page_cache_next_hole(struct address_space *mapping,
 pgoff_t page_cache_prev_hole(struct address_space *mapping,
 			     pgoff_t index, unsigned long max_scan);
 
-struct page *__find_get_page(struct address_space *mapping, pgoff_t offset);
+struct page *find_get_entry(struct address_space *mapping, pgoff_t offset);
 struct page *find_get_page(struct address_space *mapping, pgoff_t offset);
-struct page *__find_lock_page(struct address_space *mapping, pgoff_t offset);
+struct page *find_lock_entry(struct address_space *mapping, pgoff_t offset);
 struct page *find_lock_page(struct address_space *mapping, pgoff_t offset);
 struct page *find_or_create_page(struct address_space *mapping, pgoff_t index,
 				 gfp_t gfp_mask);
-unsigned __find_get_pages(struct address_space *mapping, pgoff_t start,
-			  unsigned int nr_pages, struct page **pages,
+unsigned find_get_entries(struct address_space *mapping, pgoff_t start,
+			  unsigned int nr_entries, struct page **entries,
 			  pgoff_t *indices);
 unsigned find_get_pages(struct address_space *mapping, pgoff_t start,
 			unsigned int nr_pages, struct page **pages);
diff --git a/include/linux/pagevec.h b/include/linux/pagevec.h
index 3c6b8b1e945b..b45d391b4540 100644
--- a/include/linux/pagevec.h
+++ b/include/linux/pagevec.h
@@ -22,8 +22,10 @@ struct pagevec {
 
 void __pagevec_release(struct pagevec *pvec);
 void __pagevec_lru_add(struct pagevec *pvec);
-unsigned __pagevec_lookup(struct pagevec *pvec, struct address_space *mapping,
-			  pgoff_t start, unsigned nr_pages, pgoff_t *indices);
+unsigned pagevec_lookup_entries(struct pagevec *pvec,
+				struct address_space *mapping,
+				pgoff_t start, unsigned nr_entries,
+				pgoff_t *indices);
 void pagevec_remove_exceptionals(struct pagevec *pvec);
 unsigned pagevec_lookup(struct pagevec *pvec, struct address_space *mapping,
 		pgoff_t start, unsigned nr_pages);
diff --git a/mm/filemap.c b/mm/filemap.c
index a194179303e5..8ed29b71c972 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -790,9 +790,9 @@ pgoff_t page_cache_prev_hole(struct address_space *mapping,
 EXPORT_SYMBOL(page_cache_prev_hole);
 
 /**
- * __find_get_page - find and get a page reference
+ * find_get_entry - find and get a page cache entry
  * @mapping: the address_space to search
- * @offset: the page index
+ * @offset: the page cache index
  *
  * Looks up the page cache slot at @mapping & @offset.  If there is a
  * page cache page, it is returned with an increased refcount.
@@ -802,7 +802,7 @@ EXPORT_SYMBOL(page_cache_prev_hole);
  *
  * Otherwise, %NULL is returned.
  */
-struct page *__find_get_page(struct address_space *mapping, pgoff_t offset)
+struct page *find_get_entry(struct address_space *mapping, pgoff_t offset)
 {
 	void **pagep;
 	struct page *page;
@@ -843,7 +843,7 @@ out:
 
 	return page;
 }
-EXPORT_SYMBOL(__find_get_page);
+EXPORT_SYMBOL(find_get_entry);
 
 /**
  * find_get_page - find and get a page reference
@@ -857,7 +857,7 @@ EXPORT_SYMBOL(__find_get_page);
  */
 struct page *find_get_page(struct address_space *mapping, pgoff_t offset)
 {
-	struct page *page = __find_get_page(mapping, offset);
+	struct page *page = find_get_entry(mapping, offset);
 
 	if (radix_tree_exceptional_entry(page))
 		page = NULL;
@@ -866,9 +866,9 @@ struct page *find_get_page(struct address_space *mapping, pgoff_t offset)
 EXPORT_SYMBOL(find_get_page);
 
 /**
- * __find_lock_page - locate, pin and lock a pagecache page
+ * find_lock_entry - locate, pin and lock a page cache entry
  * @mapping: the address_space to search
- * @offset: the page index
+ * @offset: the page cache index
  *
  * Looks up the page cache slot at @mapping & @offset.  If there is a
  * page cache page, it is returned locked and with an increased
@@ -879,13 +879,14 @@ EXPORT_SYMBOL(find_get_page);
  *
  * Otherwise, %NULL is returned.
  *
- * __find_lock_page() may sleep.
+ * find_lock_entry() may sleep.
  */
-struct page *__find_lock_page(struct address_space *mapping, pgoff_t offset)
+struct page *find_lock_entry(struct address_space *mapping, pgoff_t offset)
 {
 	struct page *page;
+
 repeat:
-	page = __find_get_page(mapping, offset);
+	page = find_get_entry(mapping, offset);
 	if (page && !radix_tree_exception(page)) {
 		lock_page(page);
 		/* Has the page been truncated? */
@@ -898,7 +899,7 @@ repeat:
 	}
 	return page;
 }
-EXPORT_SYMBOL(__find_lock_page);
+EXPORT_SYMBOL(find_lock_entry);
 
 /**
  * find_lock_page - locate, pin and lock a pagecache page
@@ -915,7 +916,7 @@ EXPORT_SYMBOL(__find_lock_page);
  */
 struct page *find_lock_page(struct address_space *mapping, pgoff_t offset)
 {
-	struct page *page = __find_lock_page(mapping, offset);
+	struct page *page = find_lock_entry(mapping, offset);
 
 	if (radix_tree_exceptional_entry(page))
 		page = NULL;
@@ -973,35 +974,37 @@ repeat:
 EXPORT_SYMBOL(find_or_create_page);
 
 /**
- * __find_get_pages - gang pagecache lookup
+ * find_get_entries - gang pagecache lookup
  * @mapping:	The address_space to search
- * @start:	The starting page index
- * @nr_pages:	The maximum number of pages
- * @pages:	Where the resulting entries are placed
- * @indices:	The cache indices corresponding to the entries in @pages
+ * @start:	The starting page cache index
+ * @nr_entries:	The maximum number of entries
+ * @entries:	Where the resulting entries are placed
+ * @indices:	The cache indices corresponding to the entries in @entries
  *
- * __find_get_pages() will search for and return a group of up to
- * @nr_pages pages in the mapping.  The pages are placed at @pages.
- * __find_get_pages() takes a reference against the returned pages.
+ * find_get_entries() will search for and return a group of up to
+ * @nr_entries entries in the mapping.  The entries are placed at
+ * @entries.  find_get_entries() takes a reference against any actual
+ * pages it returns.
  *
- * The search returns a group of mapping-contiguous pages with ascending
- * indexes.  There may be holes in the indices due to not-present pages.
+ * The search returns a group of mapping-contiguous page cache entries
+ * with ascending indexes.  There may be holes in the indices due to
+ * not-present pages.
  *
  * Any shadow entries of evicted pages are included in the returned
  * array.
  *
- * __find_get_pages() returns the number of pages and shadow entries
+ * find_get_entries() returns the number of pages and shadow entries
  * which were found.
  */
-unsigned __find_get_pages(struct address_space *mapping,
-			  pgoff_t start, unsigned int nr_pages,
-			  struct page **pages, pgoff_t *indices)
+unsigned find_get_entries(struct address_space *mapping,
+			  pgoff_t start, unsigned int nr_entries,
+			  struct page **entries, pgoff_t *indices)
 {
 	void **slot;
 	unsigned int ret = 0;
 	struct radix_tree_iter iter;
 
-	if (!nr_pages)
+	if (!nr_entries)
 		return 0;
 
 	rcu_read_lock();
@@ -1032,8 +1035,8 @@ repeat:
 		}
 export:
 		indices[ret] = iter.index;
-		pages[ret] = page;
-		if (++ret == nr_pages)
+		entries[ret] = page;
+		if (++ret == nr_entries)
 			break;
 	}
 	rcu_read_unlock();
diff --git a/mm/mincore.c b/mm/mincore.c
index df52b572e8b4..725c80961048 100644
--- a/mm/mincore.c
+++ b/mm/mincore.c
@@ -72,7 +72,7 @@ static unsigned char mincore_page(struct address_space *mapping, pgoff_t pgoff)
 	 */
 #ifdef CONFIG_SWAP
 	if (shmem_mapping(mapping)) {
-		page = __find_get_page(mapping, pgoff);
+		page = find_get_entry(mapping, pgoff);
 		/*
 		 * shmem/tmpfs may return swap: account for swapcache
 		 * page too.
diff --git a/mm/shmem.c b/mm/shmem.c
index e5fe262bb834..a3ba988ec946 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -363,8 +363,8 @@ void shmem_unlock_mapping(struct address_space *mapping)
 		 * Avoid pagevec_lookup(): find_get_pages() returns 0 as if it
 		 * has finished, if it hits a row of PAGEVEC_SIZE swap entries.
 		 */
-		pvec.nr = __find_get_pages(mapping, index,
-					PAGEVEC_SIZE, pvec.pages, indices);
+		pvec.nr = find_get_entries(mapping, index,
+					   PAGEVEC_SIZE, pvec.pages, indices);
 		if (!pvec.nr)
 			break;
 		index = indices[pvec.nr - 1] + 1;
@@ -400,7 +400,7 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
 	pagevec_init(&pvec, 0);
 	index = start;
 	while (index < end) {
-		pvec.nr = __find_get_pages(mapping, index,
+		pvec.nr = find_get_entries(mapping, index,
 			min(end - index, (pgoff_t)PAGEVEC_SIZE),
 			pvec.pages, indices);
 		if (!pvec.nr)
@@ -470,7 +470,7 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
 	for ( ; ; ) {
 		cond_resched();
 
-		pvec.nr = __find_get_pages(mapping, index,
+		pvec.nr = find_get_entries(mapping, index,
 				min(end - index, (pgoff_t)PAGEVEC_SIZE),
 				pvec.pages, indices);
 		if (!pvec.nr) {
@@ -1015,7 +1015,7 @@ static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
 		return -EFBIG;
 repeat:
 	swap.val = 0;
-	page = __find_lock_page(mapping, index);
+	page = find_lock_entry(mapping, index);
 	if (radix_tree_exceptional_entry(page)) {
 		swap = radix_to_swp_entry(page);
 		page = NULL;
@@ -1669,7 +1669,7 @@ static pgoff_t shmem_seek_hole_data(struct address_space *mapping,
 	pagevec_init(&pvec, 0);
 	pvec.nr = 1;		/* start small: we may be there already */
 	while (!done) {
-		pvec.nr = __find_get_pages(mapping, index,
+		pvec.nr = find_get_entries(mapping, index,
 					pvec.nr, pvec.pages, indices);
 		if (!pvec.nr) {
 			if (whence == SEEK_DATA)
diff --git a/mm/swap.c b/mm/swap.c
index 20c267b52914..0c1715036a1f 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -948,28 +948,31 @@ void __pagevec_lru_add(struct pagevec *pvec)
 EXPORT_SYMBOL(__pagevec_lru_add);
 
 /**
- * __pagevec_lookup - gang pagecache lookup
+ * pagevec_lookup_entries - gang pagecache lookup
  * @pvec:	Where the resulting entries are placed
  * @mapping:	The address_space to search
  * @start:	The starting entry index
- * @nr_pages:	The maximum number of entries
+ * @nr_entries:	The maximum number of entries
  * @indices:	The cache indices corresponding to the entries in @pvec
  *
- * __pagevec_lookup() will search for and return a group of up to
- * @nr_pages pages and shadow entries in the mapping.  All entries are
- * placed in @pvec.  __pagevec_lookup() takes a reference against
- * actual pages in @pvec.
+ * pagevec_lookup_entries() will search for and return a group of up
+ * to @nr_entries pages and shadow entries in the mapping.  All
+ * entries are placed in @pvec.  pagevec_lookup_entries() takes a
+ * reference against actual pages in @pvec.
  *
  * The search returns a group of mapping-contiguous entries with
  * ascending indexes.  There may be holes in the indices due to
  * not-present entries.
  *
- * __pagevec_lookup() returns the number of entries which were found.
+ * pagevec_lookup_entries() returns the number of entries which were
+ * found.
  */
-unsigned __pagevec_lookup(struct pagevec *pvec, struct address_space *mapping,
-			  pgoff_t start, unsigned nr_pages, pgoff_t *indices)
+unsigned pagevec_lookup_entries(struct pagevec *pvec,
+				struct address_space *mapping,
+				pgoff_t start, unsigned nr_pages,
+				pgoff_t *indices)
 {
-	pvec->nr = __find_get_pages(mapping, start, nr_pages,
+	pvec->nr = find_get_entries(mapping, start, nr_pages,
 				    pvec->pages, indices);
 	return pagevec_count(pvec);
 }
@@ -978,10 +981,10 @@ unsigned __pagevec_lookup(struct pagevec *pvec, struct address_space *mapping,
  * pagevec_remove_exceptionals - pagevec exceptionals pruning
  * @pvec:	The pagevec to prune
  *
- * __pagevec_lookup() fills both pages and exceptional radix tree
- * entries into the pagevec.  This function prunes all exceptionals
- * from @pvec without leaving holes, so that it can be passed on to
- * page-only pagevec operations.
+ * pagevec_lookup_entries() fills both pages and exceptional radix
+ * tree entries into the pagevec.  This function prunes all
+ * exceptionals from @pvec without leaving holes, so that it can be
+ * passed on to page-only pagevec operations.
  */
 void pagevec_remove_exceptionals(struct pagevec *pvec)
 {
diff --git a/mm/truncate.c b/mm/truncate.c
index b0f4d4bee8ab..60c9817c5365 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -255,7 +255,7 @@ void truncate_inode_pages_range(struct address_space *mapping,
 
 	pagevec_init(&pvec, 0);
 	index = start;
-	while (index < end && __pagevec_lookup(&pvec, mapping, index,
+	while (index < end && pagevec_lookup_entries(&pvec, mapping, index,
 			min(end - index, (pgoff_t)PAGEVEC_SIZE),
 			indices)) {
 		mem_cgroup_uncharge_start();
@@ -331,7 +331,7 @@ void truncate_inode_pages_range(struct address_space *mapping,
 	index = start;
 	for ( ; ; ) {
 		cond_resched();
-		if (!__pagevec_lookup(&pvec, mapping, index,
+		if (!pagevec_lookup_entries(&pvec, mapping, index,
 			min(end - index, (pgoff_t)PAGEVEC_SIZE),
 			indices)) {
 			if (index == start)
@@ -422,7 +422,7 @@ unsigned long invalidate_mapping_pages(struct address_space *mapping,
 	 */
 
 	pagevec_init(&pvec, 0);
-	while (index <= end && __pagevec_lookup(&pvec, mapping, index,
+	while (index <= end && pagevec_lookup_entries(&pvec, mapping, index,
 			min(end - index, (pgoff_t)PAGEVEC_SIZE - 1) + 1,
 			indices)) {
 		mem_cgroup_uncharge_start();
@@ -531,7 +531,7 @@ int invalidate_inode_pages2_range(struct address_space *mapping,
 	cleancache_invalidate_inode(mapping);
 	pagevec_init(&pvec, 0);
 	index = start;
-	while (index <= end && __pagevec_lookup(&pvec, mapping, index,
+	while (index <= end && pagevec_lookup_entries(&pvec, mapping, index,
 			min(end - index, (pgoff_t)PAGEVEC_SIZE - 1) + 1,
 			indices)) {
 		mem_cgroup_uncharge_start();
-- 
1.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
