Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3ECA66B0253
	for <linux-mm@kvack.org>; Sun, 29 May 2016 21:33:01 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id di3so139937292pab.0
        for <linux-mm@kvack.org>; Sun, 29 May 2016 18:33:01 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id xw5si5683484pac.189.2016.05.29.18.32.58
        for <linux-mm@kvack.org>;
        Sun, 29 May 2016 18:32:59 -0700 (PDT)
Date: Mon, 30 May 2016 10:33:27 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v6 02/12] mm: migrate: support non-lru movable page
 migration
Message-ID: <20160530013327.GA8683@bbox>
References: <1463754225-31311-1-git-send-email-minchan@kernel.org>
 <1463754225-31311-3-git-send-email-minchan@kernel.org>
 <ebe3244c-4821-aad2-ed32-8e730a882438@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ebe3244c-4821-aad2-ed32-8e730a882438@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rafael Aquini <aquini@redhat.com>, virtualization@lists.linux-foundation.org, Jonathan Corbet <corbet@lwn.net>, John Einar Reitan <john.reitan@foss.arm.com>, dri-devel@lists.freedesktop.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Gioh Kim <gi-oh.kim@profitbricks.com>

On Fri, May 27, 2016 at 04:26:21PM +0200, Vlastimil Babka wrote:
> On 05/20/2016 04:23 PM, Minchan Kim wrote:
> >We have allowed migration for only LRU pages until now and it was
> >enough to make high-order pages. But recently, embedded system(e.g.,
> >webOS, android) uses lots of non-movable pages(e.g., zram, GPU memory)
> >so we have seen several reports about troubles of small high-order
> >allocation. For fixing the problem, there were several efforts
> >(e,g,. enhance compaction algorithm, SLUB fallback to 0-order page,
> >reserved memory, vmalloc and so on) but if there are lots of
> >non-movable pages in system, their solutions are void in the long run.
> >
> >So, this patch is to support facility to change non-movable pages
> >with movable. For the feature, this patch introduces functions related
> >to migration to address_space_operations as well as some page flags.
> >
> >If a driver want to make own pages movable, it should define three functions
> >which are function pointers of struct address_space_operations.
> >
> >1. bool (*isolate_page) (struct page *page, isolate_mode_t mode);
> >
> >What VM expects on isolate_page function of driver is to return *true*
> >if driver isolates page successfully. On returing true, VM marks the page
> >as PG_isolated so concurrent isolation in several CPUs skip the page
> >for isolation. If a driver cannot isolate the page, it should return *false*.
> >
> >Once page is successfully isolated, VM uses page.lru fields so driver
> >shouldn't expect to preserve values in that fields.
> >
> >2. int (*migratepage) (struct address_space *mapping,
> >		struct page *newpage, struct page *oldpage, enum migrate_mode);
> >
> >After isolation, VM calls migratepage of driver with isolated page.
> >The function of migratepage is to move content of the old page to new page
> >and set up fields of struct page newpage. Keep in mind that you should
> >clear PG_movable of oldpage via __ClearPageMovable under page_lock if you
> >migrated the oldpage successfully and returns 0.
> >If driver cannot migrate the page at the moment, driver can return -EAGAIN.
> >On -EAGAIN, VM will retry page migration in a short time because VM interprets
> >-EAGAIN as "temporal migration failure". On returning any error except -EAGAIN,
> >VM will give up the page migration without retrying in this time.
> >
> >Driver shouldn't touch page.lru field VM using in the functions.
> >
> >3. void (*putback_page)(struct page *);
> >
> >If migration fails on isolated page, VM should return the isolated page
> >to the driver so VM calls driver's putback_page with migration failed page.
> >In this function, driver should put the isolated page back to the own data
> >structure.
> >
> >4. non-lru movable page flags
> >
> >There are two page flags for supporting non-lru movable page.
> >
> >* PG_movable
> >
> >Driver should use the below function to make page movable under page_lock.
> >
> >	void __SetPageMovable(struct page *page, struct address_space *mapping)
> >
> >It needs argument of address_space for registering migration family functions
> >which will be called by VM. Exactly speaking, PG_movable is not a real flag of
> >struct page. Rather than, VM reuses page->mapping's lower bits to represent it.
> >
> >	#define PAGE_MAPPING_MOVABLE 0x2
> >	page->mapping = page->mapping | PAGE_MAPPING_MOVABLE;
> 
> Interesting, let's see how that works out...
> 
> Overal this looks much better than the last version I checked!

Thanks.

> 
> [...]
> 
> >@@ -357,29 +360,37 @@ PAGEFLAG(Idle, idle, PF_ANY)
> >  * with the PAGE_MAPPING_ANON bit set to distinguish it.  See rmap.h.
> >  *
> >  * On an anonymous page in a VM_MERGEABLE area, if CONFIG_KSM is enabled,
> >- * the PAGE_MAPPING_KSM bit may be set along with the PAGE_MAPPING_ANON bit;
> >- * and then page->mapping points, not to an anon_vma, but to a private
> >+ * the PAGE_MAPPING_MOVABLE bit may be set along with the PAGE_MAPPING_ANON
> >+ * bit; and then page->mapping points, not to an anon_vma, but to a private
> >  * structure which KSM associates with that merged page.  See ksm.h.
> >  *
> >- * PAGE_MAPPING_KSM without PAGE_MAPPING_ANON is currently never used.
> >+ * PAGE_MAPPING_KSM without PAGE_MAPPING_ANON is used for non-lru movable
> >+ * page and then page->mapping points a struct address_space.
> >  *
> >  * Please note that, confusingly, "page_mapping" refers to the inode
> >  * address_space which maps the page from disk; whereas "page_mapped"
> >  * refers to user virtual address space into which the page is mapped.
> >  */
> >-#define PAGE_MAPPING_ANON	1
> >-#define PAGE_MAPPING_KSM	2
> >-#define PAGE_MAPPING_FLAGS	(PAGE_MAPPING_ANON | PAGE_MAPPING_KSM)
> >+#define PAGE_MAPPING_ANON	0x1
> >+#define PAGE_MAPPING_MOVABLE	0x2
> >+#define PAGE_MAPPING_KSM	(PAGE_MAPPING_ANON | PAGE_MAPPING_MOVABLE)
> >+#define PAGE_MAPPING_FLAGS	(PAGE_MAPPING_ANON | PAGE_MAPPING_MOVABLE)
> >
> >-static __always_inline int PageAnonHead(struct page *page)
> >+static __always_inline int PageMappingFlag(struct page *page)
> 
> PageMappingFlags()?

Yeb.

> 
> [...]
> 
> >diff --git a/mm/compaction.c b/mm/compaction.c
> >index 1427366ad673..2d6862d0df60 100644
> >--- a/mm/compaction.c
> >+++ b/mm/compaction.c
> >@@ -81,6 +81,41 @@ static inline bool migrate_async_suitable(int migratetype)
> >
> > #ifdef CONFIG_COMPACTION
> >
> >+int PageMovable(struct page *page)
> >+{
> >+	struct address_space *mapping;
> >+
> >+	WARN_ON(!PageLocked(page));
> 
> Why not VM_BUG_ON_PAGE as elsewhere?

I have backported this patchset to huge old kernel which doesn't have
VM_BUG_ON_PAGE and forgot to correct it beforre sending mainline.

Thanks.

> 
> >+	if (!__PageMovable(page))
> >+		goto out;
> 
> Just return 0.

Maybe I love goto. You realized me. I will split up will her.

> 
> >+
> >+	mapping = page_mapping(page);
> >+	if (mapping && mapping->a_ops && mapping->a_ops->isolate_page)
> >+		return 1;
> >+out:
> >+	return 0;
> >+}
> >+EXPORT_SYMBOL(PageMovable);
> >+
> >+void __SetPageMovable(struct page *page, struct address_space *mapping)
> >+{
> >+	VM_BUG_ON_PAGE(!PageLocked(page), page);
> >+	VM_BUG_ON_PAGE((unsigned long)mapping & PAGE_MAPPING_MOVABLE, page);
> >+	page->mapping = (void *)((unsigned long)mapping | PAGE_MAPPING_MOVABLE);
> >+}
> >+EXPORT_SYMBOL(__SetPageMovable);
> >+
> >+void __ClearPageMovable(struct page *page)
> >+{
> >+	VM_BUG_ON_PAGE(!PageLocked(page), page);
> >+	VM_BUG_ON_PAGE(!PageMovable(page), page);
> >+	VM_BUG_ON_PAGE(!((unsigned long)page->mapping & PAGE_MAPPING_MOVABLE),
> >+				page);
> 
> The last line sounds redundant, PageMovable() already checked this
> via __PageMovable()

Yeb.

> 
> 
> >+	page->mapping = (void *)((unsigned long)page->mapping &
> >+				PAGE_MAPPING_MOVABLE);
> 
> This should be negated to clear... use ~PAGE_MAPPING_MOVABLE ?

No.

The intention is to clear only mapping value but PAGE_MAPPING_MOVABLE
flag. So, any new migration trial will be failed because PageMovable
checks page's mapping value but ongoing migraion handling can catch
whether it's movable page or not with the type bit.

For example, we need to keep the type bit to handle putback the page.
With parallel freeing(e.g., __ClearPageMovable) from the owner after
isolating the page, migration will be failed and put it back. Then,
we need to identify movable to clear PG_isolate and shouldn't call
mapping->a_ops->putback_page. For that, we need to keep the type bit
until the page is return to buddy.

> 
> >+}
> >+EXPORT_SYMBOL(__ClearPageMovable);
> >+
> > /* Do not skip compaction more than 64 times */
> > #define COMPACT_MAX_DEFER_SHIFT 6
> >
> >@@ -735,21 +770,6 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
> > 		}
> >
> > 		/*
> >-		 * Check may be lockless but that's ok as we recheck later.
> >-		 * It's possible to migrate LRU pages and balloon pages
> >-		 * Skip any other type of page
> >-		 */
> >-		is_lru = PageLRU(page);
> >-		if (!is_lru) {
> >-			if (unlikely(balloon_page_movable(page))) {
> >-				if (balloon_page_isolate(page)) {
> >-					/* Successfully isolated */
> >-					goto isolate_success;
> >-				}
> >-			}
> >-		}
> 
> So this effectively prevents movable compound pages from being
> migrated. Are you sure no users of this functionality are going to
> have compound pages? I assumed that they could, and so made the code
> like this, with the is_lru variable (which is redundant after your
> change).

This implementation at the moment disables effectively non-lru compound
page migration but I'm not a god so I can't make sure no one doesn't want
it in future. If someone want it, we can support it then because this work
doesn't prevent it by design.

> 
> >-		/*
> > 		 * Regardless of being on LRU, compound pages such as THP and
> > 		 * hugetlbfs are not to be compacted. We can potentially save
> > 		 * a lot of iterations if we skip them at once. The check is
> >@@ -765,8 +785,38 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
> > 			goto isolate_fail;
> > 		}
> >
> >-		if (!is_lru)
> >+		/*
> >+		 * Check may be lockless but that's ok as we recheck later.
> >+		 * It's possible to migrate LRU and non-lru movable pages.
> >+		 * Skip any other type of page
> >+		 */
> >+		is_lru = PageLRU(page);
> >+		if (!is_lru) {
> >+			if (unlikely(balloon_page_movable(page))) {
> >+				if (balloon_page_isolate(page)) {
> >+					/* Successfully isolated */
> >+					goto isolate_success;
> >+				}
> >+			}
> 
> [...]
> 
> >+bool isolate_movable_page(struct page *page, isolate_mode_t mode)
> >+{
> >+	struct address_space *mapping;
> >+
> >+	/*
> >+	 * Avoid burning cycles with pages that are yet under __free_pages(),
> >+	 * or just got freed under us.
> >+	 *
> >+	 * In case we 'win' a race for a movable page being freed under us and
> >+	 * raise its refcount preventing __free_pages() from doing its job
> >+	 * the put_page() at the end of this block will take care of
> >+	 * release this page, thus avoiding a nasty leakage.
> >+	 */
> >+	if (unlikely(!get_page_unless_zero(page)))
> >+		goto out;
> >+
> >+	/*
> >+	 * Check PageMovable before holding a PG_lock because page's owner
> >+	 * assumes anybody doesn't touch PG_lock of newly allocated page
> >+	 * so unconditionally grapping the lock ruins page's owner side.
> >+	 */
> >+	if (unlikely(!__PageMovable(page)))
> >+		goto out_putpage;
> >+	/*
> >+	 * As movable pages are not isolated from LRU lists, concurrent
> >+	 * compaction threads can race against page migration functions
> >+	 * as well as race against the releasing a page.
> >+	 *
> >+	 * In order to avoid having an already isolated movable page
> >+	 * being (wrongly) re-isolated while it is under migration,
> >+	 * or to avoid attempting to isolate pages being released,
> >+	 * lets be sure we have the page lock
> >+	 * before proceeding with the movable page isolation steps.
> >+	 */
> >+	if (unlikely(!trylock_page(page)))
> >+		goto out_putpage;
> >+
> >+	if (!PageMovable(page) || PageIsolated(page))
> >+		goto out_no_isolated;
> >+
> >+	mapping = page_mapping(page);
> 
> Hmm so on first tail page of a THP compound page, page->mapping will
> alias with compound_mapcount. That can easily have a value matching
> PageMovable flags and we'll proceed and start inspecting the
> compound head in page_mapping()... maybe it's not a big deal, or we
> better check and skip PageTail first, must think about it more...

I thouht PageCompound check right before isolate_movable_page in
isolate_migratepages_block will filter it out mostly but yeah
it is racy without zone->lru_lock so it could reach to isolate_movable_page.
However, PageMovable check in there investigates mapping, mapping->a_ops,
and a_ops->isolate_page to verify whether it's movable page or not.

I thought it's sufficient to filter THP page.

> 
> [...]
> 
> >@@ -755,33 +844,69 @@ static int move_to_new_page(struct page *newpage, struct page *page,
> > 				enum migrate_mode mode)
> > {
> > 	struct address_space *mapping;
> >-	int rc;
> >+	int rc = -EAGAIN;
> >+	bool is_lru = !__PageMovable(page);
> >
> > 	VM_BUG_ON_PAGE(!PageLocked(page), page);
> > 	VM_BUG_ON_PAGE(!PageLocked(newpage), newpage);
> >
> > 	mapping = page_mapping(page);
> >-	if (!mapping)
> >-		rc = migrate_page(mapping, newpage, page, mode);
> >-	else if (mapping->a_ops->migratepage)
> >-		/*
> >-		 * Most pages have a mapping and most filesystems provide a
> >-		 * migratepage callback. Anonymous pages are part of swap
> >-		 * space which also has its own migratepage callback. This
> >-		 * is the most common path for page migration.
> >-		 */
> >-		rc = mapping->a_ops->migratepage(mapping, newpage, page, mode);
> >-	else
> >-		rc = fallback_migrate_page(mapping, newpage, page, mode);
> >+	/*
> >+	 * In case of non-lru page, it could be released after
> >+	 * isolation step. In that case, we shouldn't try
> >+	 * fallback migration which is designed for LRU pages.
> >+	 */
> 
> Hmm but is_lru was determined from !__PageMovable() above, also well
> after the isolation step. So if the driver already released it, we
> wouldn't detect it? And this function is all under same page lock,
> so if __PageMovable was true above, so will be PageMovable below?

You are missing what I mentioned above.
We should keep the type bit to catch what you are saying(i.e., driver
already released).

__PageMovable just checks PAGE_MAPPING_MOVABLE flag and PageMovable
checks page->mapping valid while __ClearPageMovable reset only
valid vaule of mapping, not PAGE_MAPPING_MOVABLE flag.

I wrote it down in Documentation/vm/page_migration.

"For testing of non-lru movable page, VM supports __PageMovable function.
However, it doesn't guarantee to identify non-lru movable page because
page->mapping field is unified with other variables in struct page.
As well, if driver releases the page after isolation by VM, page->mapping
doesn't have stable value although it has PAGE_MAPPING_MOVABLE
(Look at __ClearPageMovable). But __PageMovable is cheap to catch whether
page is LRU or non-lru movable once the page has been isolated. Because
LRU pages never can have PAGE_MAPPING_MOVABLE in page->mapping. It is also
good for just peeking to test non-lru movable pages before more expensive
checking with lock_page in pfn scanning to select victim.

For guaranteeing non-lru movable page, VM provides PageMovable function.
Unlike __PageMovable, PageMovable functions validates page->mapping and 
mapping->a_ops->isolate_page under lock_page. The lock_page prevents sudden
destroying of page->mapping.

Driver using __SetPageMovable should clear the flag via __ClearMovablePage
under page_lock before the releasing the page."

> 
> >+	if (unlikely(!is_lru)) {
> >+		VM_BUG_ON_PAGE(!PageIsolated(page), page);
> >+		if (!PageMovable(page)) {
> >+			rc = MIGRATEPAGE_SUCCESS;
> >+			__ClearPageIsolated(page);
> >+			goto out;
> >+		}
> >+	}
> >+
> >+	if (likely(is_lru)) {
> >+		if (!mapping)
> >+			rc = migrate_page(mapping, newpage, page, mode);
> >+		else if (mapping->a_ops->migratepage)
> >+			/*
> >+			 * Most pages have a mapping and most filesystems
> >+			 * provide a migratepage callback. Anonymous pages
> >+			 * are part of swap space which also has its own
> >+			 * migratepage callback. This is the most common path
> >+			 * for page migration.
> >+			 */
> >+			rc = mapping->a_ops->migratepage(mapping, newpage,
> >+							page, mode);
> >+		else
> >+			rc = fallback_migrate_page(mapping, newpage,
> >+							page, mode);
> >+	} else {
> >+		rc = mapping->a_ops->migratepage(mapping, newpage,
> >+						page, mode);
> >+		WARN_ON_ONCE(rc == MIGRATEPAGE_SUCCESS &&
> >+			!PageIsolated(page));
> >+	}
> 
> Why split the !is_lru handling in two places?

Fixed.

> 
> >
> > 	/*
> > 	 * When successful, old pagecache page->mapping must be cleared before
> > 	 * page is freed; but stats require that PageAnon be left as PageAnon.
> > 	 */
> > 	if (rc == MIGRATEPAGE_SUCCESS) {
> >-		if (!PageAnon(page))
> >+		if (__PageMovable(page)) {
> >+			VM_BUG_ON_PAGE(!PageIsolated(page), page);
> >+
> >+			/*
> >+			 * We clear PG_movable under page_lock so any compactor
> >+			 * cannot try to migrate this page.
> >+			 */
> >+			__ClearPageIsolated(page);
> >+		}
> >+
> >+		if (!((unsigned long)page->mapping & PAGE_MAPPING_FLAGS))
> > 			page->mapping = NULL;
> 
> The two lines above make little sense to me without a comment.

I folded this.

@@ -901,7 +901,12 @@ static int move_to_new_page(struct page *newpage, struct page *page,
                        __ClearPageIsolated(page);
                }
 
-               if (!((unsigned long)page->mapping & PAGE_MAPPING_FLAGS))
+               /*
+                * Anonymous and movable page->mapping will be cleard by
+                * free_pages_prepare so don't reset it here for keeping
+                * the type to work PageAnon, for example.
+                */
+               if (!PageMappingFlags(page))
                        page->mapping = NULL;
        }
 out:


> Should the condition be negated, even?

No.

> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
