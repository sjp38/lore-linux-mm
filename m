Date: Thu, 1 May 2003 02:45:00 -0700
From: Andrew Morton <akpm@digeo.com>
Subject: Re: [BUG 2.4] Buffers Span Zones
Message-Id: <20030501024500.68646c03.akpm@digeo.com>
In-Reply-To: <3EB0071B.2020308@google.com>
References: <3EB0071B.2020308@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ross Biro <rossb@google.com>
Cc: Linux-MM@kvack.org
List-ID: <linux-mm.kvack.org>

Ross Biro <rossb@google.com> wrote:
>
> It appears that in the 2.4 kernels, kswapd is 
> not aware that buffer heads can be in one zone while the buffers 
> themselves are in another zone.

What Martin said...

This problem has a fix in Andrea's kernel.  I broke out his VM changes a
while back but seem to have lost that one.  hmm.  I have an old version,
below.

Fixes exist in 2.5.

> It also appears that in buffer.c balance_dirty_state really needs to be 
> zone aware as well.

Not really - the arithmetic in there only takes into account the size of
ZONE_NORMAL+ZONE_DMA anyway.  nr_free_buffer_pages().

> It might also be nice to replace many of the 
> current->policy |= YIELD; schedule(); pairs with real waits for memory 
> to free up a bit.  If dirty pages or associated structures are filling 
> up most of the memory, then the problem will go away if we just wait a bit.

2.5 does this.  It's a bit crude, but works sufficiently well to have not
made a nuisance of itself in six months or so.







Addresses the problem where all of ZONE_NORMAL is full of buffer_heads.
 Normal page reclaim will view all this memory as non-freeable.

So what the patch does is, while scanning the LRU pages, also check
whether a page in the wrong zone has buffers in the *right* zone.  If
it does, then strip the page's buffers but leave the page alone.

hmm.  Are we sure that we subsequently call the right slabcache shrink
function to actually free the page which backed those buffer_heads?

We discussed making this code conditional on CONFIG_HIGHMEM64G only, as
it's not been an observed problem on any other configs.  Theoretically,
the same problem could occur with ZONE_DMA.  The code is left in.

Testing with 50/50 highmem/normal shows that memclass_related_bhs() is
almost never called - presumably it will be called more often when the
highmem/normal ratio is higher.  But it'll only be called for
allocations which are specifically asking for ZONE_NORMAL - mainly fs
metadata.

Bottom line: the code works and the CPU cost is negligible.



=====================================

--- 2.4.19-pre6/mm/vmscan.c~aa-230-free_zone_bhs	Fri Apr  5 01:08:04 2002
+++ 2.4.19-pre6-akpm/mm/vmscan.c	Fri Apr  5 01:08:04 2002
@@ -358,10 +358,30 @@ static int swap_out(zone_t * classzone)
 			return 1;
 	} while (--counter >= 0);
 
+ out:
+	if (unlikely(vm_gfp_debug)) {
+		printk(KERN_NOTICE "swap_out: failed\n");
+		dump_stack();
+	}
 	return 0;
 
 empty:
 	spin_unlock(&mmlist_lock);
+	goto out;
+}
+
+static int FASTCALL(memclass_related_bhs(struct page * page, zone_t * classzone));
+static int memclass_related_bhs(struct page * page, zone_t * classzone)
+{
+	struct buffer_head * tmp, * bh = page->buffers;
+
+	tmp = bh;
+	do {
+		if (memclass(page_zone(virt_to_page(tmp)), classzone))
+			return 1;
+		tmp = tmp->b_this_page;
+	} while (tmp != bh);
+
 	return 0;
 }
 
@@ -375,6 +395,7 @@ static int shrink_cache(int nr_pages, zo
 
 	while (max_scan && classzone->nr_inactive_pages && (entry = inactive_list.prev) != &inactive_list) {
 		struct page * page;
+		int only_metadata;
 
 		if (unlikely(current->need_resched)) {
 			spin_unlock(&pagemap_lru_lock);
@@ -399,8 +420,30 @@ static int shrink_cache(int nr_pages, zo
 		if (unlikely(!page_count(page)))
 			continue;
 
-		if (!memclass(page_zone(page), classzone))
+		only_metadata = 0;
+		if (!memclass(page_zone(page), classzone)) {
+			/*
+			 * Hack to address an issue found by Rik. The problem is that
+			 * highmem pages can hold buffer headers allocated
+			 * from the slab on lowmem, and so if we are working
+			 * on the NORMAL classzone here, it is correct not to
+			 * try to free the highmem pages themself (that would be useless)
+			 * but we must make sure to drop any lowmem metadata related to those
+			 * highmem pages.
+			 */
+			if (page->buffers && page->mapping) { /* fast path racy check */
+				if (unlikely(TryLockPage(page)))
+					continue;
+				if (page->buffers && page->mapping && memclass_related_bhs(page, classzone)) { /* non racy check */
+					only_metadata = 1;
+					goto free_bhs;
+				}
+				UnlockPage(page);
+			}
 			continue;
+		}
+
+		max_scan--;
 
 		/* Racy check to avoid trylocking when not worthwhile */
 		if (!page->buffers && (page_count(page) != 1 || !page->mapping))
@@ -453,6 +496,7 @@ static int shrink_cache(int nr_pages, zo
 		 * the page as well.
 		 */
 		if (page->buffers) {
+		free_bhs:
 			spin_unlock(&pagemap_lru_lock);
 
 			/* avoid to free a locked page */
@@ -485,6 +529,10 @@ static int shrink_cache(int nr_pages, zo
 					page_cache_release(page);
 
 					spin_lock(&pagemap_lru_lock);
+					if (only_metadata) {
+						UnlockPage(page);
+						continue;
+					}
 				}
 			} else {
 				/* failed to drop the buffers so stop here */
@@ -586,16 +634,40 @@ static void refill_inactive(int nr_pages
 	entry = active_list.prev;
 	while (ratio && entry != &active_list) {
 		struct page * page;
+		int related_metadata = 0;
 
 		page = list_entry(entry, struct page, lru);
 		entry = entry->prev;
+
+		if (!memclass(page_zone(page), classzone)) {
+			/*
+			 * Hack to address an issue found by Rik. The problem is that
+			 * highmem pages can hold buffer headers allocated
+			 * from the slab on lowmem, and so if we are working
+			 * on the NORMAL classzone here, it is correct not to
+			 * try to free the highmem pages themself (that would be useless)
+			 * but we must make sure to drop any lowmem metadata related to those
+			 * highmem pages.
+			 */
+			if (page->buffers && page->mapping) { /* fast path racy check */
+				if (unlikely(TryLockPage(page)))
+					continue;
+				if (page->buffers && page->mapping && memclass_related_bhs(page, classzone)) /* non racy check */
+					related_metadata = 1;
+				UnlockPage(page);
+			}
+			if (!related_metadata)
+				continue;
+		}
+
 		if (PageTestandClearReferenced(page)) {
 			list_del(&page->lru);
 			list_add(&page->lru, &active_list);
 			continue;
 		}
 
-		nr_pages--;
+		if (!related_metadata)
+			ratio--;
 
 		del_page_from_active_list(page);
 		add_page_to_inactive_list(page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
