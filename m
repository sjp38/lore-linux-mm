Message-ID: <46ABF184.40803@redhat.com>
Date: Sat, 28 Jul 2007 21:46:44 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: How can we make page replacement smarter
References: <200707272243.02336.a1426z@gawab.com> <46AAA25E.7040301@redhat.com> <200707280717.41250.a1426z@gawab.com>
In-Reply-To: <200707280717.41250.a1426z@gawab.com>
Content-Type: multipart/mixed;
 boundary="------------070802020901020402010801"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Al Boldi <a1426z@gawab.com>
Cc: Chris Snook <csnook@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------070802020901020402010801
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Al Boldi wrote:

> Good idea, but unless we understand the problems involved, we are bound to 
> repeat it.  So my first question would be:  Why is swap-in so slow?
> 
> As I have posted in other threads, swap-in of consecutive pages suffers a 2x 
> slowdown wrt swap-out, whereas swap-in of random pages suffers over 6x 
> slowdown.
> 
> Because it is hard to quantify the expected swap-in speed for random pages, 
> let's first tackle the swap-in of consecutive pages, which should be at 
> least as fast as swap-out.  So again, why is swap-in so slow?

I suspect that this is a locality of reference issue.

Anonymous memory can get jumbled up by repeated free and
malloc cycles of many smaller objects.  The amount of
anonymous memory is often smaller than or roughly the same
size as system memory.

Locality of refenence to anonymous memory tends to be
temporal in nature, with the same sets of pages being
accessed over and over again.

Files are different.  File content tends to be grouped
in large related chunks, both logically in the file and
on disk.  Generally there is a lot more file data on a
system than what fits in memory.

Locality of reference to file data tends to be spatial
in nature, with one file access leading up to the system
accessing "nearby" data.  The data is not necessarily
touched again any time soon.

> Once we understand this problem, we may be able to suggest a smart 
> improvement.

Like the one on http://linux-mm.org/PageoutFailureModes ?

I have the LRU lists split and am working on getting SEQ
replacement implemented for the anonymous pages.

The most recent (untested) patches are attached.

-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.

--------------070802020901020402010801
Content-Type: text/x-patch;
 name="linux-2.6.22-vmsplit.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux-2.6.22-vmsplit.patch"

--- linux-2.6.21.noarch/drivers/base/node.c.vmsplit	2007-04-25 23:08:32.000000000 -0400
+++ linux-2.6.21.noarch/drivers/base/node.c	2007-07-23 11:42:52.000000000 -0400
@@ -44,33 +44,37 @@ static ssize_t node_read_meminfo(struct 
 	si_meminfo_node(&i, nid);
 
 	n = sprintf(buf, "\n"
-		       "Node %d MemTotal:     %8lu kB\n"
-		       "Node %d MemFree:      %8lu kB\n"
-		       "Node %d MemUsed:      %8lu kB\n"
-		       "Node %d Active:       %8lu kB\n"
-		       "Node %d Inactive:     %8lu kB\n"
+		       "Node %d MemTotal:       %8lu kB\n"
+		       "Node %d MemFree:        %8lu kB\n"
+		       "Node %d MemUsed:        %8lu kB\n"
+		       "Node %d Active(anon):   %8lu kB\n"
+		       "Node %d Inactive(anon): %8lu kB\n"
+		       "Node %d Active(file):   %8lu kB\n"
+		       "Node %d Inactive(file): %8lu kB\n"
 #ifdef CONFIG_HIGHMEM
-		       "Node %d HighTotal:    %8lu kB\n"
-		       "Node %d HighFree:     %8lu kB\n"
-		       "Node %d LowTotal:     %8lu kB\n"
-		       "Node %d LowFree:      %8lu kB\n"
+		       "Node %d HighTotal:      %8lu kB\n"
+		       "Node %d HighFree:       %8lu kB\n"
+		       "Node %d LowTotal:       %8lu kB\n"
+		       "Node %d LowFree:        %8lu kB\n"
 #endif
-		       "Node %d Dirty:        %8lu kB\n"
-		       "Node %d Writeback:    %8lu kB\n"
-		       "Node %d FilePages:    %8lu kB\n"
-		       "Node %d Mapped:       %8lu kB\n"
-		       "Node %d AnonPages:    %8lu kB\n"
-		       "Node %d PageTables:   %8lu kB\n"
-		       "Node %d NFS_Unstable: %8lu kB\n"
-		       "Node %d Bounce:       %8lu kB\n"
-		       "Node %d Slab:         %8lu kB\n"
-		       "Node %d SReclaimable: %8lu kB\n"
-		       "Node %d SUnreclaim:   %8lu kB\n",
+		       "Node %d Dirty:          %8lu kB\n"
+		       "Node %d Writeback:      %8lu kB\n"
+		       "Node %d FilePages:      %8lu kB\n"
+		       "Node %d Mapped:         %8lu kB\n"
+		       "Node %d AnonPages:      %8lu kB\n"
+		       "Node %d PageTables:     %8lu kB\n"
+		       "Node %d NFS_Unstable:   %8lu kB\n"
+		       "Node %d Bounce:         %8lu kB\n"
+		       "Node %d Slab:           %8lu kB\n"
+		       "Node %d SReclaimable:   %8lu kB\n"
+		       "Node %d SUnreclaim:     %8lu kB\n",
 		       nid, K(i.totalram),
 		       nid, K(i.freeram),
 		       nid, K(i.totalram - i.freeram),
-		       nid, node_page_state(nid, NR_ACTIVE),
-		       nid, node_page_state(nid, NR_INACTIVE),
+		       nid, node_page_state(nid, NR_ACTIVE_ANON),
+		       nid, node_page_state(nid, NR_INACTIVE_ANON),
+		       nid, node_page_state(nid, NR_ACTIVE_FILE),
+		       nid, node_page_state(nid, NR_INACTIVE_FILE),
 #ifdef CONFIG_HIGHMEM
 		       nid, K(i.totalhigh),
 		       nid, K(i.freehigh),
--- linux-2.6.21.noarch/fs/proc/proc_misc.c.vmsplit	2007-07-05 12:06:14.000000000 -0400
+++ linux-2.6.21.noarch/fs/proc/proc_misc.c	2007-07-23 11:42:52.000000000 -0400
@@ -146,43 +146,47 @@ static int meminfo_read_proc(char *page,
 	 * Tagged format, for easy grepping and expansion.
 	 */
 	len = sprintf(page,
-		"MemTotal:     %8lu kB\n"
-		"MemFree:      %8lu kB\n"
-		"Buffers:      %8lu kB\n"
-		"Cached:       %8lu kB\n"
-		"SwapCached:   %8lu kB\n"
-		"Active:       %8lu kB\n"
-		"Inactive:     %8lu kB\n"
+		"MemTotal:       %8lu kB\n"
+		"MemFree:        %8lu kB\n"
+		"Buffers:        %8lu kB\n"
+		"Cached:         %8lu kB\n"
+		"SwapCached:     %8lu kB\n"
+		"Active(anon):   %8lu kB\n"
+		"Inactive(anon): %8lu kB\n"
+		"Active(file):   %8lu kB\n"
+		"Inactive(file): %8lu kB\n"
 #ifdef CONFIG_HIGHMEM
-		"HighTotal:    %8lu kB\n"
-		"HighFree:     %8lu kB\n"
-		"LowTotal:     %8lu kB\n"
-		"LowFree:      %8lu kB\n"
-#endif
-		"SwapTotal:    %8lu kB\n"
-		"SwapFree:     %8lu kB\n"
-		"Dirty:        %8lu kB\n"
-		"Writeback:    %8lu kB\n"
-		"AnonPages:    %8lu kB\n"
-		"Mapped:       %8lu kB\n"
-		"Slab:         %8lu kB\n"
-		"SReclaimable: %8lu kB\n"
-		"SUnreclaim:   %8lu kB\n"
-		"PageTables:   %8lu kB\n"
-		"NFS_Unstable: %8lu kB\n"
-		"Bounce:       %8lu kB\n"
-		"CommitLimit:  %8lu kB\n"
-		"Committed_AS: %8lu kB\n"
-		"VmallocTotal: %8lu kB\n"
-		"VmallocUsed:  %8lu kB\n"
-		"VmallocChunk: %8lu kB\n",
+		"HighTotal:      %8lu kB\n"
+		"HighFree:       %8lu kB\n"
+		"LowTotal:       %8lu kB\n"
+		"LowFree:        %8lu kB\n"
+#endif
+		"SwapTotal:      %8lu kB\n"
+		"SwapFree:       %8lu kB\n"
+		"Dirty:          %8lu kB\n"
+		"Writeback:      %8lu kB\n"
+		"AnonPages:      %8lu kB\n"
+		"Mapped:         %8lu kB\n"
+		"Slab:           %8lu kB\n"
+		"SReclaimable:   %8lu kB\n"
+		"SUnreclaim:     %8lu kB\n"
+		"PageTables:     %8lu kB\n"
+		"NFS_Unstable:   %8lu kB\n"
+		"Bounce:         %8lu kB\n"
+		"CommitLimit:    %8lu kB\n"
+		"Committed_AS:   %8lu kB\n"
+		"VmallocTotal:   %8lu kB\n"
+		"VmallocUsed:    %8lu kB\n"
+		"VmallocChunk:   %8lu kB\n",
 		K(i.totalram),
 		K(i.freeram),
 		K(i.bufferram),
 		K(cached),
 		K(total_swapcache_pages),
-		K(global_page_state(NR_ACTIVE)),
-		K(global_page_state(NR_INACTIVE)),
+		K(global_page_state(NR_ACTIVE_ANON)),
+		K(global_page_state(NR_INACTIVE_ANON)),
+		K(global_page_state(NR_ACTIVE_FILE)),
+		K(global_page_state(NR_INACTIVE_FILE)),
 #ifdef CONFIG_HIGHMEM
 		K(i.totalhigh),
 		K(i.freehigh),
--- linux-2.6.21.noarch/fs/exec.c.vmsplit	2007-07-05 12:06:22.000000000 -0400
+++ linux-2.6.21.noarch/fs/exec.c	2007-07-23 11:42:52.000000000 -0400
@@ -327,7 +327,7 @@ void install_arg_page(struct vm_area_str
 		goto out;
 	}
 	inc_mm_counter(mm, anon_rss);
-	lru_cache_add_active(page);
+	lru_cache_add_active_anon(page);
 	set_pte_at(mm, address, pte, pte_mkdirty(pte_mkwrite(mk_pte(
 					page, vma->vm_page_prot))));
 	page_add_new_anon_rmap(page, vma, address);
--- linux-2.6.21.noarch/fs/mpage.c.vmsplit	2007-07-05 12:06:14.000000000 -0400
+++ linux-2.6.21.noarch/fs/mpage.c	2007-07-23 11:42:52.000000000 -0400
@@ -406,12 +406,12 @@ mpage_readpages(struct address_space *ma
 					&first_logical_block,
 					get_block);
 			if (!pagevec_add(&lru_pvec, page))
-				__pagevec_lru_add(&lru_pvec);
+				__pagevec_lru_add_file(&lru_pvec);
 		} else {
 			page_cache_release(page);
 		}
 	}
-	pagevec_lru_add(&lru_pvec);
+	pagevec_lru_add_file(&lru_pvec);
 	BUG_ON(!list_empty(pages));
 	if (bio)
 		mpage_bio_submit(READ, bio);
--- linux-2.6.21.noarch/include/linux/mm.h.vmsplit	2007-07-05 12:06:24.000000000 -0400
+++ linux-2.6.21.noarch/include/linux/mm.h	2007-07-23 11:42:52.000000000 -0400
@@ -617,6 +617,24 @@ static inline int PageAnon(struct page *
 	return ((unsigned long)page->mapping & PAGE_MAPPING_ANON) != 0;
 }
 
+/* Returns true if this page is anonymous, tmpfs or otherwise swap backed. */
+extern const struct address_space_operations shmem_aops;
+static inline int page_anon(struct page *page)
+{
+	struct address_space *mapping = page_mapping(page);
+
+	if (PageAnon(page) || PageSwapCache(page))
+		return 1;
+	if (mapping->a_ops == &shmem_aops)
+		return 1;
+	/* Should ramfs pages go onto an mlocked list instead? */
+	if ((unlikely(mapping->a_ops->writepage == NULL)))
+		return 1;
+
+	/* The page is page cache backed by a normal filesystem. */
+	return 0;
+}
+
 /*
  * Return the pagecache index of the passed page.  Regular pagecache pages
  * use ->index whereas swapcache pages use ->private
--- linux-2.6.21.noarch/include/linux/mm_inline.h.vmsplit	2007-04-25 23:08:32.000000000 -0400
+++ linux-2.6.21.noarch/include/linux/mm_inline.h	2007-07-23 11:42:52.000000000 -0400
@@ -1,29 +1,57 @@
 static inline void
-add_page_to_active_list(struct zone *zone, struct page *page)
+add_page_to_active_anon_list(struct zone *zone, struct page *page)
 {
-	list_add(&page->lru, &zone->active_list);
-	__inc_zone_state(zone, NR_ACTIVE);
+	list_add(&page->lru, &zone->active_anon_list);
+	__inc_zone_state(zone, NR_ACTIVE_ANON);
 }
 
 static inline void
-add_page_to_inactive_list(struct zone *zone, struct page *page)
+add_page_to_inactive_anon_list(struct zone *zone, struct page *page)
 {
-	list_add(&page->lru, &zone->inactive_list);
-	__inc_zone_state(zone, NR_INACTIVE);
+	list_add(&page->lru, &zone->inactive_anon_list);
+	__inc_zone_state(zone, NR_INACTIVE_ANON);
 }
 
 static inline void
-del_page_from_active_list(struct zone *zone, struct page *page)
+del_page_from_active_anon_list(struct zone *zone, struct page *page)
 {
 	list_del(&page->lru);
-	__dec_zone_state(zone, NR_ACTIVE);
+	__dec_zone_state(zone, NR_ACTIVE_ANON);
 }
 
 static inline void
-del_page_from_inactive_list(struct zone *zone, struct page *page)
+del_page_from_inactive_anon_list(struct zone *zone, struct page *page)
 {
 	list_del(&page->lru);
-	__dec_zone_state(zone, NR_INACTIVE);
+	__dec_zone_state(zone, NR_INACTIVE_ANON);
+}
+
+static inline void
+add_page_to_active_file_list(struct zone *zone, struct page *page)
+{
+	list_add(&page->lru, &zone->active_file_list);
+	__inc_zone_state(zone, NR_ACTIVE_FILE);
+}
+
+static inline void
+add_page_to_inactive_file_list(struct zone *zone, struct page *page)
+{
+	list_add(&page->lru, &zone->inactive_file_list);
+	__inc_zone_state(zone, NR_INACTIVE_FILE);
+}
+
+static inline void
+del_page_from_active_file_list(struct zone *zone, struct page *page)
+{
+	list_del(&page->lru);
+	__dec_zone_state(zone, NR_ACTIVE_FILE);
+}
+
+static inline void
+del_page_from_inactive_file_list(struct zone *zone, struct page *page)
+{
+	list_del(&page->lru);
+	__dec_zone_state(zone, NR_INACTIVE_FILE);
 }
 
 static inline void
@@ -32,9 +60,15 @@ del_page_from_lru(struct zone *zone, str
 	list_del(&page->lru);
 	if (PageActive(page)) {
 		__ClearPageActive(page);
-		__dec_zone_state(zone, NR_ACTIVE);
+		if (page_anon(page))
+			__dec_zone_state(zone, NR_ACTIVE_ANON);
+		else
+			__dec_zone_state(zone, NR_ACTIVE_FILE);
 	} else {
-		__dec_zone_state(zone, NR_INACTIVE);
+		if (page_anon(page))
+			__dec_zone_state(zone, NR_INACTIVE_ANON);
+		else
+			__dec_zone_state(zone, NR_INACTIVE_FILE);
 	}
 }
 
--- linux-2.6.21.noarch/include/linux/mmzone.h.vmsplit	2007-07-05 12:06:18.000000000 -0400
+++ linux-2.6.21.noarch/include/linux/mmzone.h	2007-07-23 11:43:35.000000000 -0400
@@ -49,15 +49,17 @@ struct zone_padding {
 enum zone_stat_item {
 	/* First 128 byte cacheline (assuming 64 bit words) */
 	NR_FREE_PAGES,
-	NR_INACTIVE,
-	NR_ACTIVE,
+	NR_ACTIVE_ANON,
+	NR_INACTIVE_ANON,
+	NR_ACTIVE_FILE,
+	NR_INACTIVE_FILE,
 	NR_ANON_PAGES,	/* Mapped anonymous pages */
 	NR_FILE_MAPPED,	/* pagecache pages mapped into pagetables.
 			   only modified from process context */
 	NR_FILE_PAGES,
+	/* Second 128 byte cacheline */
 	NR_FILE_DIRTY,
 	NR_WRITEBACK,
-	/* Second 128 byte cacheline */
 	NR_SLAB_RECLAIMABLE,
 	NR_SLAB_UNRECLAIMABLE,
 	NR_PAGETABLE,		/* used for pagetables */
@@ -218,10 +220,18 @@ struct zone {
 
 	/* Fields commonly accessed by the page reclaim scanner */
 	spinlock_t		lru_lock;	
-	struct list_head	active_list;
-	struct list_head	inactive_list;
-	unsigned long		nr_scan_active;
-	unsigned long		nr_scan_inactive;
+	struct list_head	active_anon_list;
+	struct list_head	inactive_anon_list;
+	struct list_head	active_file_list;
+	struct list_head	inactive_file_list;
+	unsigned long		nr_scan_active_anon;
+	unsigned long		nr_scan_inactive_anon;
+	unsigned long		nr_scan_active_file;
+	unsigned long		nr_scan_inactive_file;
+	unsigned long		recent_rotated_anon;
+	unsigned long		recent_rotated_file;
+	unsigned long		recent_scanned_anon;
+	unsigned long		recent_scanned_file;
 	unsigned long		pages_scanned;	   /* since last reclaim */
 	int			all_unreclaimable; /* All pages pinned */
 
--- linux-2.6.21.noarch/include/linux/pagevec.h.vmsplit	2007-04-25 23:08:32.000000000 -0400
+++ linux-2.6.21.noarch/include/linux/pagevec.h	2007-07-23 11:42:52.000000000 -0400
@@ -23,8 +23,10 @@ struct pagevec {
 void __pagevec_release(struct pagevec *pvec);
 void __pagevec_release_nonlru(struct pagevec *pvec);
 void __pagevec_free(struct pagevec *pvec);
-void __pagevec_lru_add(struct pagevec *pvec);
-void __pagevec_lru_add_active(struct pagevec *pvec);
+void __pagevec_lru_add_file(struct pagevec *pvec);
+void __pagevec_lru_add_active_file(struct pagevec *pvec);
+void __pagevec_lru_add_anon(struct pagevec *pvec);
+void __pagevec_lru_add_active_anon(struct pagevec *pvec);
 void pagevec_strip(struct pagevec *pvec);
 unsigned pagevec_lookup(struct pagevec *pvec, struct address_space *mapping,
 		pgoff_t start, unsigned nr_pages);
@@ -81,10 +83,16 @@ static inline void pagevec_free(struct p
 		__pagevec_free(pvec);
 }
 
-static inline void pagevec_lru_add(struct pagevec *pvec)
+static inline void pagevec_lru_add_file(struct pagevec *pvec)
 {
 	if (pagevec_count(pvec))
-		__pagevec_lru_add(pvec);
+		__pagevec_lru_add_file(pvec);
+}
+
+static inline void pagevec_lru_add_anon(struct pagevec *pvec)
+{
+	if (pagevec_count(pvec))
+		__pagevec_lru_add_anon(pvec);
 }
 
 #endif /* _LINUX_PAGEVEC_H */
--- linux-2.6.21.noarch/include/linux/swap.h.vmsplit	2007-04-25 23:08:32.000000000 -0400
+++ linux-2.6.21.noarch/include/linux/swap.h	2007-07-23 12:21:11.000000000 -0400
@@ -178,9 +178,12 @@ extern unsigned int nr_free_pagecache_pa
 
 
 /* linux/mm/swap.c */
-extern void FASTCALL(lru_cache_add(struct page *));
-extern void FASTCALL(lru_cache_add_active(struct page *));
-extern void FASTCALL(activate_page(struct page *));
+extern void FASTCALL(lru_cache_add_file(struct page *));
+extern void FASTCALL(lru_cache_add_anon(struct page *));
+extern void FASTCALL(lru_cache_add_active_file(struct page *));
+extern void FASTCALL(lru_cache_add_active_anon(struct page *));
+extern void FASTCALL(activate_page_anon(struct page *));
+extern void FASTCALL(activate_page_file(struct page *));
 extern void FASTCALL(mark_page_accessed(struct page *));
 extern void lru_add_drain(void);
 extern int lru_add_drain_all(void);
--- linux-2.6.21.noarch/mm/filemap.c.vmsplit	2007-07-05 12:06:19.000000000 -0400
+++ linux-2.6.21.noarch/mm/filemap.c	2007-07-23 11:42:52.000000000 -0400
@@ -462,7 +462,7 @@ int add_to_page_cache_lru(struct page *p
 {
 	int ret = add_to_page_cache(page, mapping, offset, gfp_mask);
 	if (ret == 0)
-		lru_cache_add(page);
+		lru_cache_add_file(page);
 	return ret;
 }
 
@@ -1870,7 +1870,7 @@ repeat:
 			page = *cached_page;
 			page_cache_get(page);
 			if (!pagevec_add(lru_pvec, page))
-				__pagevec_lru_add(lru_pvec);
+				__pagevec_lru_add_file(lru_pvec);
 			*cached_page = NULL;
 		}
 	}
@@ -2231,7 +2231,7 @@ zero_length_segment:
 	if (unlikely(file->f_flags & O_DIRECT) && written)
 		status = filemap_write_and_wait(mapping);
 
-	pagevec_lru_add(&lru_pvec);
+	pagevec_lru_add_file(&lru_pvec);
 	return written ? written : status;
 }
 EXPORT_SYMBOL(generic_file_buffered_write);
--- linux-2.6.21.noarch/mm/memory.c.vmsplit	2007-07-05 12:06:19.000000000 -0400
+++ linux-2.6.21.noarch/mm/memory.c	2007-07-23 11:42:52.000000000 -0400
@@ -1745,7 +1745,7 @@ gotten:
 		ptep_clear_flush(vma, address, page_table);
 		set_pte_at(mm, address, page_table, entry);
 		update_mmu_cache(vma, address, entry);
-		lru_cache_add_active(new_page);
+		lru_cache_add_active_anon(new_page);
 		page_add_new_anon_rmap(new_page, vma, address);
 
 		/* Free the old page.. */
@@ -2242,7 +2242,7 @@ static int do_anonymous_page(struct mm_s
 		if (!pte_none(*page_table))
 			goto release;
 		inc_mm_counter(mm, anon_rss);
-		lru_cache_add_active(page);
+		lru_cache_add_active_anon(page);
 		page_add_new_anon_rmap(page, vma, address);
 	} else {
 		/* Map the ZERO_PAGE - vm_page_prot is readonly */
@@ -2389,7 +2389,7 @@ retry:
 		set_pte_at(mm, address, page_table, entry);
 		if (anon) {
 			inc_mm_counter(mm, anon_rss);
-			lru_cache_add_active(new_page);
+			lru_cache_add_active_anon(new_page);
 			page_add_new_anon_rmap(new_page, vma, address);
 		} else {
 			inc_mm_counter(mm, file_rss);
--- linux-2.6.21.noarch/mm/migrate.c.vmsplit	2007-04-25 23:08:32.000000000 -0400
+++ linux-2.6.21.noarch/mm/migrate.c	2007-07-23 11:42:52.000000000 -0400
@@ -53,10 +53,17 @@ int isolate_lru_page(struct page *page, 
 			ret = 0;
 			get_page(page);
 			ClearPageLRU(page);
-			if (PageActive(page))
-				del_page_from_active_list(zone, page);
-			else
-				del_page_from_inactive_list(zone, page);
+			if (PageActive(page)) {
+			    if (page_anon(page)) 
+				del_page_from_active_anon_list(zone, page);
+			    else
+				del_page_from_active_file_list(zone, page);
+			} else {
+			    if (page_anon(page)) 
+				del_page_from_inactive_anon_list(zone, page);
+			    else
+				del_page_from_inactive_file_list(zone, page);
+			}
 			list_add_tail(&page->lru, pagelist);
 		}
 		spin_unlock_irq(&zone->lru_lock);
@@ -89,9 +96,15 @@ static inline void move_to_lru(struct pa
 		 * the PG_active bit is off.
 		 */
 		ClearPageActive(page);
-		lru_cache_add_active(page);
+		if (page_anon(page))
+			lru_cache_add_active_anon(page);
+		else
+			lru_cache_add_active_file(page);
 	} else {
-		lru_cache_add(page);
+		if (page_anon(page))
+			lru_cache_add_anon(page);
+		else
+			lru_cache_add_file(page);
 	}
 	put_page(page);
 }
--- linux-2.6.21.noarch/mm/page_alloc.c.vmsplit	2007-07-05 12:06:25.000000000 -0400
+++ linux-2.6.21.noarch/mm/page_alloc.c	2007-07-23 11:42:52.000000000 -0400
@@ -1544,10 +1544,13 @@ void show_free_areas(void)
 		}
 	}
 
-	printk("Active:%lu inactive:%lu dirty:%lu writeback:%lu unstable:%lu\n"
+	printk("Active_anon:%lu active_file:%lu inactive_anon%lu\n"
+		" inactive_file:%lu dirty:%lu writeback:%lu unstable:%lu\n"
 		" free:%lu slab:%lu mapped:%lu pagetables:%lu bounce:%lu\n",
-		global_page_state(NR_ACTIVE),
-		global_page_state(NR_INACTIVE),
+		global_page_state(NR_ACTIVE_ANON),
+		global_page_state(NR_ACTIVE_FILE),
+		global_page_state(NR_INACTIVE_ANON),
+		global_page_state(NR_INACTIVE_FILE),
 		global_page_state(NR_FILE_DIRTY),
 		global_page_state(NR_WRITEBACK),
 		global_page_state(NR_UNSTABLE_NFS),
@@ -1570,8 +1573,10 @@ void show_free_areas(void)
 			" min:%lukB"
 			" low:%lukB"
 			" high:%lukB"
-			" active:%lukB"
-			" inactive:%lukB"
+			" active_anon:%lukB"
+			" inactive_anon:%lukB"
+			" active_file:%lukB"
+			" inactive_file:%lukB"
 			" present:%lukB"
 			" pages_scanned:%lu"
 			" all_unreclaimable? %s"
@@ -1581,8 +1586,10 @@ void show_free_areas(void)
 			K(zone->pages_min),
 			K(zone->pages_low),
 			K(zone->pages_high),
-			K(zone_page_state(zone, NR_ACTIVE)),
-			K(zone_page_state(zone, NR_INACTIVE)),
+			K(zone_page_state(zone, NR_ACTIVE_ANON)),
+			K(zone_page_state(zone, NR_INACTIVE_ANON)),
+			K(zone_page_state(zone, NR_ACTIVE_FILE)),
+			K(zone_page_state(zone, NR_INACTIVE_FILE)),
 			K(zone->present_pages),
 			zone->pages_scanned,
 			(zone->all_unreclaimable ? "yes" : "no")
@@ -2647,10 +2654,16 @@ static void __meminit free_area_init_cor
 		zone->prev_priority = DEF_PRIORITY;
 
 		zone_pcp_init(zone);
-		INIT_LIST_HEAD(&zone->active_list);
-		INIT_LIST_HEAD(&zone->inactive_list);
-		zone->nr_scan_active = 0;
-		zone->nr_scan_inactive = 0;
+		INIT_LIST_HEAD(&zone->active_anon_list);
+		INIT_LIST_HEAD(&zone->inactive_anon_list);
+		INIT_LIST_HEAD(&zone->active_file_list);
+		INIT_LIST_HEAD(&zone->inactive_file_list);
+		zone->nr_scan_active_anon = 0;
+		zone->nr_scan_inactive_anon = 0;
+		zone->nr_scan_active_file = 0;
+		zone->nr_scan_inactive_file = 0;
+		zone->recent_rotated_anon = 0;
+		zone->recent_rotated_file = 0;
 		zap_zone_vm_stats(zone);
 		atomic_set(&zone->reclaim_in_progress, 0);
 		if (!size)
--- linux-2.6.21.noarch/mm/readahead.c.vmsplit	2007-07-05 12:06:19.000000000 -0400
+++ linux-2.6.21.noarch/mm/readahead.c	2007-07-23 11:42:52.000000000 -0400
@@ -147,14 +147,14 @@ int read_cache_pages(struct address_spac
 		}
 		ret = filler(data, page);
 		if (!pagevec_add(&lru_pvec, page))
-			__pagevec_lru_add(&lru_pvec);
+			__pagevec_lru_add_file(&lru_pvec);
 		if (ret) {
 			put_pages_list(pages);
 			break;
 		}
 		task_io_account_read(PAGE_CACHE_SIZE);
 	}
-	pagevec_lru_add(&lru_pvec);
+	pagevec_lru_add_file(&lru_pvec);
 	return ret;
 }
 
@@ -182,11 +182,11 @@ static int read_pages(struct address_spa
 					page->index, GFP_KERNEL)) {
 			mapping->a_ops->readpage(filp, page);
 			if (!pagevec_add(&lru_pvec, page))
-				__pagevec_lru_add(&lru_pvec);
+				__pagevec_lru_add_file(&lru_pvec);
 		} else
 			page_cache_release(page);
 	}
-	pagevec_lru_add(&lru_pvec);
+	pagevec_lru_add_file(&lru_pvec);
 	ret = 0;
 out:
 	return ret;
@@ -578,6 +578,6 @@ void handle_ra_miss(struct address_space
  */
 unsigned long max_sane_readahead(unsigned long nr)
 {
-	return min(nr, (node_page_state(numa_node_id(), NR_INACTIVE)
+	return min(nr, (node_page_state(numa_node_id(), NR_INACTIVE_FILE)
 		+ node_page_state(numa_node_id(), NR_FREE_PAGES)) / 2);
 }
--- linux-2.6.21.noarch/mm/shmem.c.vmsplit	2007-07-05 12:06:19.000000000 -0400
+++ linux-2.6.21.noarch/mm/shmem.c	2007-07-23 11:42:52.000000000 -0400
@@ -176,7 +176,7 @@ static inline void shmem_unacct_blocks(u
 }
 
 static const struct super_operations shmem_ops;
-static const struct address_space_operations shmem_aops;
+const struct address_space_operations shmem_aops;
 static const struct file_operations shmem_file_operations;
 static const struct inode_operations shmem_inode_operations;
 static const struct inode_operations shmem_dir_inode_operations;
@@ -2382,7 +2382,7 @@ static void destroy_inodecache(void)
 	kmem_cache_destroy(shmem_inode_cachep);
 }
 
-static const struct address_space_operations shmem_aops = {
+const struct address_space_operations shmem_aops = {
 	.writepage	= shmem_writepage,
 	.set_page_dirty	= __set_page_dirty_no_writeback,
 #ifdef CONFIG_TMPFS
--- linux-2.6.21.noarch/mm/swap_state.c.vmsplit	2007-04-25 23:08:32.000000000 -0400
+++ linux-2.6.21.noarch/mm/swap_state.c	2007-07-23 11:42:52.000000000 -0400
@@ -354,7 +354,7 @@ struct page *read_swap_cache_async(swp_e
 			/*
 			 * Initiate read into locked page and return.
 			 */
-			lru_cache_add_active(new_page);
+			lru_cache_add_anon(new_page);
 			swap_readpage(NULL, new_page);
 			return new_page;
 		}
--- linux-2.6.21.noarch/mm/vmscan.c.vmsplit	2007-07-05 12:06:19.000000000 -0400
+++ linux-2.6.21.noarch/mm/vmscan.c	2007-07-23 11:56:50.000000000 -0400
@@ -66,6 +66,9 @@ struct scan_control {
 	int swappiness;
 
 	int all_unreclaimable;
+
+	/* The number of pages moved to the active list this pass. */
+	int activated;
 };
 
 /*
@@ -231,27 +234,6 @@ unsigned long shrink_slab(unsigned long 
 	return ret;
 }
 
-/* Called without lock on whether page is mapped, so answer is unstable */
-static inline int page_mapping_inuse(struct page *page)
-{
-	struct address_space *mapping;
-
-	/* Page is in somebody's page tables. */
-	if (page_mapped(page))
-		return 1;
-
-	/* Be more reluctant to reclaim swapcache than pagecache */
-	if (PageSwapCache(page))
-		return 1;
-
-	mapping = page_mapping(page);
-	if (!mapping)
-		return 0;
-
-	/* File is mmap'd by somebody? */
-	return mapping_mapped(mapping);
-}
-
 static inline int is_page_cache_freeable(struct page *page)
 {
 	return page_count(page) - !!PagePrivate(page) == 2;
@@ -481,7 +463,7 @@ static unsigned long shrink_page_list(st
 
 		referenced = page_referenced(page, 1);
 		/* In active use or really unfreeable?  Activate it. */
-		if (referenced && page_mapping_inuse(page))
+		if (referenced)
 			goto activate_locked;
 
 #ifdef CONFIG_SWAP
@@ -514,8 +496,6 @@ static unsigned long shrink_page_list(st
 		}
 
 		if (PageDirty(page)) {
-			if (referenced)
-				goto keep_locked;
 			if (!may_enter_fs)
 				goto keep_locked;
 			if (!sc->may_writepage)
@@ -595,6 +575,7 @@ keep:
 	if (pagevec_count(&freed_pvec))
 		__pagevec_release_nonlru(&freed_pvec);
 	count_vm_events(PGACTIVATE, pgactivate);
+	sc->activated = pgactivate;
 	return nr_reclaimed;
 }
 
@@ -655,7 +636,7 @@ static unsigned long isolate_lru_pages(u
  * of reclaimed pages
  */
 static unsigned long shrink_inactive_list(unsigned long max_scan,
-				struct zone *zone, struct scan_control *sc)
+			struct zone *zone, struct scan_control *sc, int file)
 {
 	LIST_HEAD(page_list);
 	struct pagevec pvec;
@@ -672,10 +653,17 @@ static unsigned long shrink_inactive_lis
 		unsigned long nr_scan;
 		unsigned long nr_freed;
 
-		nr_taken = isolate_lru_pages(sc->swap_cluster_max,
-					     &zone->inactive_list,
-					     &page_list, &nr_scan);
-		__mod_zone_page_state(zone, NR_INACTIVE, -nr_taken);
+		if (file) {
+			nr_taken = isolate_lru_pages(sc->swap_cluster_max,
+						     &zone->inactive_file_list,
+						     &page_list, &nr_scan);
+			__mod_zone_page_state(zone, NR_INACTIVE_FILE, -nr_taken);
+		} else {
+			nr_taken = isolate_lru_pages(sc->swap_cluster_max,
+						     &zone->inactive_anon_list,
+						     &page_list, &nr_scan);
+			__mod_zone_page_state(zone, NR_INACTIVE_ANON, -nr_taken);
+		}
 		zone->pages_scanned += nr_scan;
 		spin_unlock_irq(&zone->lru_lock);
 
@@ -702,10 +690,21 @@ static unsigned long shrink_inactive_lis
 			VM_BUG_ON(PageLRU(page));
 			SetPageLRU(page);
 			list_del(&page->lru);
-			if (PageActive(page))
-				add_page_to_active_list(zone, page);
-			else
-				add_page_to_inactive_list(zone, page);
+			if (file) {
+			    zone->recent_rotated_file += sc->activated;
+			    zone->recent_scanned_file += nr_scanned;
+			    if (PageActive(page))
+				add_page_to_active_file_list(zone, page);
+			    else
+				add_page_to_inactive_file_list(zone, page);
+			} else {
+			    zone->recent_rotated_anon += sc->activated;
+			    zone->recent_scanned_anon += nr_scanned;
+			    if (PageActive(page))
+				add_page_to_active_anon_list(zone, page);
+			    else
+				add_page_to_inactive_anon_list(zone, page);
+			}
 			if (!pagevec_add(&pvec, page)) {
 				spin_unlock_irq(&zone->lru_lock);
 				__pagevec_release(&pvec);
@@ -736,8 +735,10 @@ static inline void note_zone_scanning_pr
 
 static inline int zone_is_near_oom(struct zone *zone)
 {
-	return zone->pages_scanned >= (zone_page_state(zone, NR_ACTIVE)
-				+ zone_page_state(zone, NR_INACTIVE))*3;
+	return zone->pages_scanned >= (zone_page_state(zone, NR_ACTIVE_ANON)
+				+ zone_page_state(zone, NR_ACTIVE_FILE)
+				+ zone_page_state(zone, NR_INACTIVE_ANON)
+				+ zone_page_state(zone, NR_INACTIVE_FILE))*3;
 }
 
 /*
@@ -758,7 +759,7 @@ static inline int zone_is_near_oom(struc
  * But we had to alter page->flags anyway.
  */
 static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
-				struct scan_control *sc, int priority)
+				struct scan_control *sc, int priority, int file)
 {
 	unsigned long pgmoved;
 	int pgdeactivate = 0;
@@ -768,74 +769,28 @@ static void shrink_active_list(unsigned 
 	LIST_HEAD(l_active);	/* Pages to go onto the active_list */
 	struct page *page;
 	struct pagevec pvec;
-	int reclaim_mapped = 0;
-
-	if (sc->may_swap) {
-		long mapped_ratio;
-		long distress;
-		long swap_tendency;
-
-		if (zone_is_near_oom(zone))
-			goto force_reclaim_mapped;
-
-		/*
-		 * `distress' is a measure of how much trouble we're having
-		 * reclaiming pages.  0 -> no problems.  100 -> great trouble.
-		 */
-		distress = 100 >> min(zone->prev_priority, priority);
-
-		/*
-		 * The point of this algorithm is to decide when to start
-		 * reclaiming mapped memory instead of just pagecache.  Work out
-		 * how much memory
-		 * is mapped.
-		 */
-		mapped_ratio = ((global_page_state(NR_FILE_MAPPED) +
-				global_page_state(NR_ANON_PAGES)) * 100) /
-					vm_total_pages;
-
-		/*
-		 * Now decide how much we really want to unmap some pages.  The
-		 * mapped ratio is downgraded - just because there's a lot of
-		 * mapped memory doesn't necessarily mean that page reclaim
-		 * isn't succeeding.
-		 *
-		 * The distress ratio is important - we don't want to start
-		 * going oom.
-		 *
-		 * A 100% value of vm_swappiness overrides this algorithm
-		 * altogether.
-		 */
-		swap_tendency = mapped_ratio / 2 + distress + sc->swappiness;
-
-		/*
-		 * Now use this metric to decide whether to start moving mapped
-		 * memory onto the inactive list.
-		 */
-		if (swap_tendency >= 100)
-force_reclaim_mapped:
-			reclaim_mapped = 1;
-	}
 
 	lru_add_drain();
 	spin_lock_irq(&zone->lru_lock);
-	pgmoved = isolate_lru_pages(nr_pages, &zone->active_list,
-				    &l_hold, &pgscanned);
+	if (file) {
+		pgmoved = isolate_lru_pages(nr_pages, &zone->active_file_list,
+					    &l_hold, &pgscanned);
+		__mod_zone_page_state(zone, NR_ACTIVE_FILE, -pgmoved);
+	} else {
+		pgmoved = isolate_lru_pages(nr_pages, &zone->active_anon_list,
+					    &l_hold, &pgscanned);
+		__mod_zone_page_state(zone, NR_ACTIVE_ANON, -pgmoved);
+	}
 	zone->pages_scanned += pgscanned;
-	__mod_zone_page_state(zone, NR_ACTIVE, -pgmoved);
 	spin_unlock_irq(&zone->lru_lock);
 
 	while (!list_empty(&l_hold)) {
 		cond_resched();
 		page = lru_to_page(&l_hold);
 		list_del(&page->lru);
-		if (page_mapped(page)) {
-			if (!reclaim_mapped ||
-			    (total_swap_pages == 0 && PageAnon(page)) ||
-			    page_referenced(page, 0)) {
-				list_add(&page->lru, &l_active);
-				continue;
-			}
+		if (page_referenced(page, 0)) {
+			list_add(&page->lru, &l_active);
+			continue;
 		}
 		list_add(&page->lru, &l_inactive);
 	}
@@ -851,10 +806,16 @@ force_reclaim_mapped:
 		VM_BUG_ON(!PageActive(page));
 		ClearPageActive(page);
 
-		list_move(&page->lru, &zone->inactive_list);
+		if (file)
+			list_move(&page->lru, &zone->inactive_file_list);
+		else
+			list_move(&page->lru, &zone->inactive_anon_list);
 		pgmoved++;
 		if (!pagevec_add(&pvec, page)) {
-			__mod_zone_page_state(zone, NR_INACTIVE, pgmoved);
+			if (file)
+				__mod_zone_page_state(zone, NR_INACTIVE_FILE, pgmoved);
+			else
+				__mod_zone_page_state(zone, NR_INACTIVE_ANON, pgmoved);
 			spin_unlock_irq(&zone->lru_lock);
 			pgdeactivate += pgmoved;
 			pgmoved = 0;
@@ -864,7 +825,10 @@ force_reclaim_mapped:
 			spin_lock_irq(&zone->lru_lock);
 		}
 	}
-	__mod_zone_page_state(zone, NR_INACTIVE, pgmoved);
+	if (file)
+		__mod_zone_page_state(zone, NR_INACTIVE_FILE, pgmoved);
+	else
+		__mod_zone_page_state(zone, NR_INACTIVE_ANON, pgmoved);
 	pgdeactivate += pgmoved;
 	if (buffer_heads_over_limit) {
 		spin_unlock_irq(&zone->lru_lock);
@@ -879,17 +843,34 @@ force_reclaim_mapped:
 		VM_BUG_ON(PageLRU(page));
 		SetPageLRU(page);
 		VM_BUG_ON(!PageActive(page));
-		list_move(&page->lru, &zone->active_list);
+		if (file)
+			list_move(&page->lru, &zone->active_file_list);
+		else
+			list_move(&page->lru, &zone->active_anon_list);
 		pgmoved++;
 		if (!pagevec_add(&pvec, page)) {
-			__mod_zone_page_state(zone, NR_ACTIVE, pgmoved);
+			if (file) {
+				__mod_zone_page_state(zone, NR_ACTIVE_FILE, pgmoved);
+				zone->recent_rotated_file += pgmoved;
+			} else {
+				__mod_zone_page_state(zone, NR_ACTIVE_ANON, pgmoved);
+				zone->recent_rotated_anon += pgmoved;
+			}
 			pgmoved = 0;
 			spin_unlock_irq(&zone->lru_lock);
 			__pagevec_release(&pvec);
 			spin_lock_irq(&zone->lru_lock);
 		}
 	}
-	__mod_zone_page_state(zone, NR_ACTIVE, pgmoved);
+	if (file) {
+		__mod_zone_page_state(zone, NR_ACTIVE_FILE, pgmoved);
+		zone->recent_rotated_file += pgmoved;
+		zone->recent_scanned_file += pgscanned;
+	} else {
+		__mod_zone_page_state(zone, NR_ACTIVE_ANON, pgmoved);
+		zone->recent_rotated_anon += pgmoved;
+		zone->recent_scanned_anon += pgscanned;
+	}
 
 	__count_zone_vm_events(PGREFILL, zone, pgscanned);
 	__count_vm_events(PGDEACTIVATE, pgdeactivate);
@@ -899,52 +880,152 @@ force_reclaim_mapped:
 }
 
 /*
+ * The utility of the anon and file memory corresponds to the fraction
+ * of pages that were recently referenced in each category.  Pageout
+ * pressure is distributed according to the size of each set, the fraction
+ * of recently referenced pages (except used-once file pages) and the
+ * swappiness parameter. Note that shrink_zone takes care of size scaling.
+ *
+ * We return the relative pressures as percentages so shrink_zone can
+ * easily use them.
+ */
+static void get_scan_ratio(struct zone *zone, struct scan_control * sc,
+		unsigned long *anon_percent, unsigned long *file_percent)
+{
+	unsigned long anon, file;
+	unsigned long anon_prio, file_prio;
+	unsigned long anon_l, file_l;
+
+	anon  = zone_page_state(zone, NR_ACTIVE_ANON) +
+		zone_page_state(zone, NR_INACTIVE_ANON);
+	file  = zone_page_state(zone, NR_ACTIVE_FILE) +
+		zone_page_state(zone, NR_INACTIVE_FILE);
+
+	/* Keep a floating average of RECENT references. */
+	if (unlikely(zone->recent_rotated_anon > anon / 4)) {
+		spin_lock_irq(&zone->lru_lock);
+		zone->recent_rotated_anon /= 2;
+		zone->recent_scanned_anon /= 2;
+		spin_unlock_irq(&zone->lru_lock);
+	}
+
+	if (unlikely(zone->recent_rotated_file > file / 4)) {
+		spin_lock_irq(&zone->lru_lock);
+		zone->recent_rotated_file /= 2;
+		zone->recent_scanned_file /= 2;
+		spin_unlock_irq(&zone->lru_lock);
+	}
+
+	/*
+	 * With swappiness at 100, anonymous and file have the same priority.
+	 * This scanning priority is essentially the inverse of IO cost.
+	 */
+	anon_prio = sc->swappiness;
+	file_prio = 200 - sc->swappiness;
+
+	/*
+ 	 *                  anon       recent_rotated_anon 
+	 * %anon = 100 * ----------- / ------------------- * IO cost
+	 *               anon + file       rotate_sum
+	 */
+	anon_l = (anon_prio + 1) * (zone->recent_scanned_anon + 1);
+	anon_l /= zone->recent_rotated_anon + 1;
+
+	file_l = (file_prio + 1) * (zone->recent_scanned_file + 1);
+	file_l /= zone->recent_rotated_file + 1;
+
+	/* Normalize to percentages. */
+	*anon_percent = 100 * anon_l / (anon_l + file_l);
+	*file_percent = 100 - *anon_percent;
+}
+
+/*
  * This is a basic per-zone page freer.  Used by both kswapd and direct reclaim.
+ *
+ * Filesystem backed pages live on a separate set of pageout queues from
+ * anonymous, swap and tmpfs pages.  This is done because page cache pages
+ * can usually be evicted and faulted back in more cheaply because of
+ * readahead and better IO clustering.  Also, on many systems swap is
+ * undesirable so we do not want to scan through the anonymous pages.
  */
 static unsigned long shrink_zone(int priority, struct zone *zone,
 				struct scan_control *sc)
 {
-	unsigned long nr_active;
-	unsigned long nr_inactive;
+	unsigned long nr_active_file, nr_inactive_file;
+	unsigned long nr_active_anon, nr_inactive_anon;
+	unsigned long anon_percent, file_percent;
 	unsigned long nr_to_scan;
 	unsigned long nr_reclaimed = 0;
 
 	atomic_inc(&zone->reclaim_in_progress);
 
+	get_scan_ratio(zone, sc, &anon_percent, &file_percent);
 	/*
 	 * Add one to `nr_to_scan' just to make sure that the kernel will
-	 * slowly sift through the active list.
+	 * slowly sift through small lists, too.
 	 */
-	zone->nr_scan_active +=
-		(zone_page_state(zone, NR_ACTIVE) >> priority) + 1;
-	nr_active = zone->nr_scan_active;
-	if (nr_active >= sc->swap_cluster_max)
-		zone->nr_scan_active = 0;
+	zone->nr_scan_active_file +=
+		(zone_page_state(zone, NR_ACTIVE_FILE) >> priority) + 1;
+	nr_active_file = zone->nr_scan_active_file * file_percent / 100;
+	if (nr_active_file >= sc->swap_cluster_max)
+		zone->nr_scan_active_file = 0;
+	else
+		nr_active_file = 0;
+
+	zone->nr_scan_inactive_file +=
+		(zone_page_state(zone, NR_INACTIVE_FILE) >> priority) + 1;
+	nr_inactive_file = zone->nr_scan_inactive_file * file_percent / 100;
+	if (nr_inactive_file >= sc->swap_cluster_max)
+		zone->nr_scan_inactive_file = 0;
+	else
+		nr_inactive_file = 0;
+
+	zone->nr_scan_active_anon +=
+		(zone_page_state(zone, NR_ACTIVE_ANON) >> priority) + 1;
+	nr_active_anon = zone->nr_scan_active_anon * anon_percent / 100;
+	if (nr_active_anon >= sc->swap_cluster_max)
+		zone->nr_scan_active_anon = 0;
 	else
-		nr_active = 0;
+		nr_active_anon = 0;
 
-	zone->nr_scan_inactive +=
-		(zone_page_state(zone, NR_INACTIVE) >> priority) + 1;
-	nr_inactive = zone->nr_scan_inactive;
-	if (nr_inactive >= sc->swap_cluster_max)
-		zone->nr_scan_inactive = 0;
+	zone->nr_scan_inactive_anon +=
+		(zone_page_state(zone, NR_INACTIVE_ANON) >> priority) + 1;
+	nr_inactive_anon = zone->nr_scan_inactive_anon * anon_percent / 100;
+	if (nr_inactive_anon >= sc->swap_cluster_max)
+		zone->nr_scan_inactive_anon = 0;
 	else
-		nr_inactive = 0;
+		nr_inactive_anon = 0;
+
+	while (nr_active_file || nr_inactive_file ||
+				nr_active_anon || nr_inactive_anon) {
+		if (nr_active_file) {
+			nr_to_scan = min(nr_active_file,
+					(unsigned long)sc->swap_cluster_max);
+			nr_active_file -= nr_to_scan;
+			shrink_active_list(nr_to_scan, zone, sc, priority, 1);
+		}
+
+		if (nr_inactive_file) {
+			nr_to_scan = min(nr_inactive_file,
+					(unsigned long)sc->swap_cluster_max);
+			nr_inactive_file -= nr_to_scan;
+			nr_reclaimed += shrink_inactive_list(nr_to_scan, zone,
+								sc, 1);
+		}
 
-	while (nr_active || nr_inactive) {
-		if (nr_active) {
-			nr_to_scan = min(nr_active,
+		if (nr_active_anon) {
+			nr_to_scan = min(nr_active_anon,
 					(unsigned long)sc->swap_cluster_max);
-			nr_active -= nr_to_scan;
-			shrink_active_list(nr_to_scan, zone, sc, priority);
+			nr_active_anon -= nr_to_scan;
+			shrink_active_list(nr_to_scan, zone, sc, priority, 0);
 		}
 
-		if (nr_inactive) {
-			nr_to_scan = min(nr_inactive,
+		if (nr_inactive_anon) {
+			nr_to_scan = min(nr_inactive_anon,
 					(unsigned long)sc->swap_cluster_max);
-			nr_inactive -= nr_to_scan;
+			nr_inactive_anon -= nr_to_scan;
 			nr_reclaimed += shrink_inactive_list(nr_to_scan, zone,
-								sc);
+								sc, 0);
 		}
 	}
 
@@ -1036,8 +1117,10 @@ unsigned long try_to_free_pages(struct z
 		if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
 			continue;
 
-		lru_pages += zone_page_state(zone, NR_ACTIVE)
-				+ zone_page_state(zone, NR_INACTIVE);
+		lru_pages += zone_page_state(zone, NR_ACTIVE_ANON)
+				+ zone_page_state(zone, NR_ACTIVE_FILE)
+				+ zone_page_state(zone, NR_INACTIVE_ANON)
+				+ zone_page_state(zone, NR_INACTIVE_FILE);
 	}
 
 	for (priority = DEF_PRIORITY; priority >= 0; priority--) {
@@ -1182,8 +1265,10 @@ loop_again:
 		for (i = 0; i <= end_zone; i++) {
 			struct zone *zone = pgdat->node_zones + i;
 
-			lru_pages += zone_page_state(zone, NR_ACTIVE)
-					+ zone_page_state(zone, NR_INACTIVE);
+			lru_pages += zone_page_state(zone, NR_ACTIVE_ANON)
+				   + zone_page_state(zone, NR_ACTIVE_FILE) 
+				   + zone_page_state(zone, NR_INACTIVE_ANON) 
+				   + zone_page_state(zone, NR_INACTIVE_FILE);
 		}
 
 		/*
@@ -1220,8 +1305,10 @@ loop_again:
 			if (zone->all_unreclaimable)
 				continue;
 			if (nr_slab == 0 && zone->pages_scanned >=
-				(zone_page_state(zone, NR_ACTIVE)
-				+ zone_page_state(zone, NR_INACTIVE)) * 6)
+				(zone_page_state(zone, NR_ACTIVE_ANON)
+				+ zone_page_state(zone, NR_ACTIVE_FILE)
+				+ zone_page_state(zone, NR_INACTIVE_ANON)
+				+ zone_page_state(zone, NR_INACTIVE_FILE)) * 6)
 					zone->all_unreclaimable = 1;
 			/*
 			 * If we've done a decent amount of scanning and
@@ -1392,23 +1479,43 @@ static unsigned long shrink_all_zones(un
 
 		/* For pass = 0 we don't shrink the active list */
 		if (pass > 0) {
-			zone->nr_scan_active +=
-				(zone_page_state(zone, NR_ACTIVE) >> prio) + 1;
-			if (zone->nr_scan_active >= nr_pages || pass > 3) {
-				zone->nr_scan_active = 0;
+			zone->nr_scan_active_file +=
+				(zone_page_state(zone, NR_ACTIVE_FILE) >> prio) + 1;
+			if (zone->nr_scan_active_file >= nr_pages || pass > 3) {
+				zone->nr_scan_active_file = 0;
+				nr_to_scan = min(nr_pages,
+					zone_page_state(zone, NR_ACTIVE_FILE));
+				shrink_active_list(nr_to_scan, zone, sc, prio, 1);
+			}
+
+			zone->nr_scan_active_anon +=
+				(zone_page_state(zone, NR_ACTIVE_ANON) >> prio) + 1;
+			if (zone->nr_scan_active_anon >= nr_pages || pass > 3) {
+				zone->nr_scan_active_anon = 0;
 				nr_to_scan = min(nr_pages,
-					zone_page_state(zone, NR_ACTIVE));
-				shrink_active_list(nr_to_scan, zone, sc, prio);
+					zone_page_state(zone, NR_ACTIVE_ANON));
+				shrink_active_list(nr_to_scan, zone, sc, prio, 0);
 			}
 		}
 
-		zone->nr_scan_inactive +=
-			(zone_page_state(zone, NR_INACTIVE) >> prio) + 1;
-		if (zone->nr_scan_inactive >= nr_pages || pass > 3) {
-			zone->nr_scan_inactive = 0;
+		zone->nr_scan_inactive_file +=
+			(zone_page_state(zone, NR_INACTIVE_FILE) >> prio) + 1;
+		if (zone->nr_scan_inactive_file >= nr_pages || pass > 3) {
+			zone->nr_scan_inactive_file = 0;
+			nr_to_scan = min(nr_pages,
+				zone_page_state(zone, NR_INACTIVE_FILE));
+			ret += shrink_inactive_list(nr_to_scan, zone, sc, 1);
+			if (ret >= nr_pages)
+				return ret;
+		}
+
+		zone->nr_scan_inactive_anon +=
+			(zone_page_state(zone, NR_INACTIVE_ANON) >> prio) + 1;
+		if (zone->nr_scan_inactive_anon >= nr_pages || pass > 3) {
+			zone->nr_scan_inactive_anon = 0;
 			nr_to_scan = min(nr_pages,
-				zone_page_state(zone, NR_INACTIVE));
-			ret += shrink_inactive_list(nr_to_scan, zone, sc);
+				zone_page_state(zone, NR_INACTIVE_ANON));
+			ret += shrink_inactive_list(nr_to_scan, zone, sc, 0);
 			if (ret >= nr_pages)
 				return ret;
 		}
@@ -1419,7 +1526,10 @@ static unsigned long shrink_all_zones(un
 
 static unsigned long count_lru_pages(void)
 {
-	return global_page_state(NR_ACTIVE) + global_page_state(NR_INACTIVE);
+	return global_page_state(NR_ACTIVE_ANON)
+		+ global_page_state(NR_ACTIVE_FILE)
+		+ global_page_state(NR_INACTIVE_ANON)
+		+ global_page_state(NR_INACTIVE_FILE);
 }
 
 /*
--- linux-2.6.21.noarch/mm/vmstat.c.vmsplit	2007-07-05 12:06:19.000000000 -0400
+++ linux-2.6.21.noarch/mm/vmstat.c	2007-07-23 11:42:52.000000000 -0400
@@ -477,8 +477,10 @@ const struct seq_operations fragmentatio
 static const char * const vmstat_text[] = {
 	/* Zoned VM counters */
 	"nr_free_pages",
-	"nr_active",
-	"nr_inactive",
+	"nr_active_anon",
+	"nr_inactive_anon",
+	"nr_active_file",
+	"nr_inactive_file",
 	"nr_anon_pages",
 	"nr_mapped",
 	"nr_file_pages",
@@ -554,7 +556,7 @@ static int zoneinfo_show(struct seq_file
 			   "\n        min      %lu"
 			   "\n        low      %lu"
 			   "\n        high     %lu"
-			   "\n        scanned  %lu (a: %lu i: %lu)"
+			   "\n        scanned  %lu (ao: %lu io: %lu af: %lu if: %lu)"
 			   "\n        spanned  %lu"
 			   "\n        present  %lu",
 			   zone_page_state(zone, NR_FREE_PAGES),
@@ -562,7 +564,10 @@ static int zoneinfo_show(struct seq_file
 			   zone->pages_low,
 			   zone->pages_high,
 			   zone->pages_scanned,
-			   zone->nr_scan_active, zone->nr_scan_inactive,
+			   zone->nr_scan_active_anon,
+			   zone->nr_scan_inactive_anon,
+			   zone->nr_scan_active_file,
+			   zone->nr_scan_inactive_file,
 			   zone->spanned_pages,
 			   zone->present_pages);
 
--- linux-2.6.21.noarch/mm/page-writeback.c.vmsplit	2007-07-05 12:06:19.000000000 -0400
+++ linux-2.6.21.noarch/mm/page-writeback.c	2007-07-23 11:42:52.000000000 -0400
@@ -151,8 +151,8 @@ static unsigned long determine_dirtyable
 	unsigned long x;
 
 	x = global_page_state(NR_FREE_PAGES)
-		+ global_page_state(NR_INACTIVE)
-		+ global_page_state(NR_ACTIVE);
+		+ global_page_state(NR_INACTIVE_FILE)
+		+ global_page_state(NR_ACTIVE_FILE);
 	x -= highmem_dirtyable_memory(x);
 	return x + 1;	/* Ensure that we never return 0 */
 }
--- linux-2.6.21.noarch/mm/swap.c.vmsplit	2007-07-05 12:06:19.000000000 -0400
+++ linux-2.6.21.noarch/mm/swap.c	2007-07-23 11:42:52.000000000 -0400
@@ -125,7 +125,10 @@ int rotate_reclaimable_page(struct page 
 	zone = page_zone(page);
 	spin_lock_irqsave(&zone->lru_lock, flags);
 	if (PageLRU(page) && !PageActive(page)) {
-		list_move_tail(&page->lru, &zone->inactive_list);
+		if (unlikely(PageSwapCache(page)))
+			list_move_tail(&page->lru, &zone->inactive_anon_list);
+		else
+			list_move_tail(&page->lru, &zone->inactive_file_list);
 		__count_vm_event(PGROTATED);
 	}
 	if (!test_clear_page_writeback(page))
@@ -137,16 +140,32 @@ int rotate_reclaimable_page(struct page 
 /*
  * FIXME: speed this up?
  */
-void fastcall activate_page(struct page *page)
+void fastcall activate_page_file(struct page *page)
 {
 	struct zone *zone = page_zone(page);
 
 	spin_lock_irq(&zone->lru_lock);
 	if (PageLRU(page) && !PageActive(page)) {
-		del_page_from_inactive_list(zone, page);
+		del_page_from_inactive_file_list(zone, page);
 		SetPageActive(page);
-		add_page_to_active_list(zone, page);
+		add_page_to_active_file_list(zone, page);
 		__count_vm_event(PGACTIVATE);
+		zone->recent_rotated_file++;
+	}
+	spin_unlock_irq(&zone->lru_lock);
+}
+
+void fastcall activate_page_anon(struct page *page)
+{
+	struct zone *zone = page_zone(page);
+
+	spin_lock_irq(&zone->lru_lock);
+	if (PageLRU(page) && !PageActive(page)) {
+		del_page_from_inactive_anon_list(zone, page);
+		SetPageActive(page);
+		add_page_to_active_anon_list(zone, page);
+		__count_vm_event(PGACTIVATE);
+		zone->recent_rotated_anon++;
 	}
 	spin_unlock_irq(&zone->lru_lock);
 }
@@ -161,7 +180,10 @@ void fastcall activate_page(struct page 
 void fastcall mark_page_accessed(struct page *page)
 {
 	if (!PageActive(page) && PageReferenced(page) && PageLRU(page)) {
-		activate_page(page);
+		if (page_anon(page))
+			activate_page_anon(page);
+		else
+			activate_page_file(page);
 		ClearPageReferenced(page);
 	} else if (!PageReferenced(page)) {
 		SetPageReferenced(page);
@@ -174,39 +196,67 @@ EXPORT_SYMBOL(mark_page_accessed);
  * lru_cache_add: add a page to the page lists
  * @page: the page to add
  */
-static DEFINE_PER_CPU(struct pagevec, lru_add_pvecs) = { 0, };
-static DEFINE_PER_CPU(struct pagevec, lru_add_active_pvecs) = { 0, };
+static DEFINE_PER_CPU(struct pagevec, lru_add_file_pvecs) = { 0, };
+static DEFINE_PER_CPU(struct pagevec, lru_add_active_file_pvecs) = { 0, };
+static DEFINE_PER_CPU(struct pagevec, lru_add_anon_pvecs) = { 0, };
+static DEFINE_PER_CPU(struct pagevec, lru_add_active_anon_pvecs) = { 0, };
+
+void fastcall lru_cache_add_anon(struct page *page)
+{
+	struct pagevec *pvec = &get_cpu_var(lru_add_anon_pvecs);
+
+	page_cache_get(page);
+	if (!pagevec_add(pvec, page))
+		__pagevec_lru_add_anon(pvec);
+	put_cpu_var(lru_add_anon_pvecs);
+}
+
+void fastcall lru_cache_add_file(struct page *page)
+{
+	struct pagevec *pvec = &get_cpu_var(lru_add_file_pvecs);
+
+	page_cache_get(page);
+	if (!pagevec_add(pvec, page))
+		__pagevec_lru_add_file(pvec);
+	put_cpu_var(lru_add_file_pvecs);
+}
 
-void fastcall lru_cache_add(struct page *page)
+void fastcall lru_cache_add_active_anon(struct page *page)
 {
-	struct pagevec *pvec = &get_cpu_var(lru_add_pvecs);
+	struct pagevec *pvec = &get_cpu_var(lru_add_active_anon_pvecs);
 
 	page_cache_get(page);
 	if (!pagevec_add(pvec, page))
-		__pagevec_lru_add(pvec);
-	put_cpu_var(lru_add_pvecs);
+		__pagevec_lru_add_active_anon(pvec);
+	put_cpu_var(lru_add_active_anon_pvecs);
 }
 
-void fastcall lru_cache_add_active(struct page *page)
+void fastcall lru_cache_add_active_file(struct page *page)
 {
-	struct pagevec *pvec = &get_cpu_var(lru_add_active_pvecs);
+	struct pagevec *pvec = &get_cpu_var(lru_add_active_file_pvecs);
 
 	page_cache_get(page);
 	if (!pagevec_add(pvec, page))
-		__pagevec_lru_add_active(pvec);
-	put_cpu_var(lru_add_active_pvecs);
+		__pagevec_lru_add_active_file(pvec);
+	put_cpu_var(lru_add_active_file_pvecs);
 }
 
 static void __lru_add_drain(int cpu)
 {
-	struct pagevec *pvec = &per_cpu(lru_add_pvecs, cpu);
+	struct pagevec *pvec = &per_cpu(lru_add_file_pvecs, cpu);
 
 	/* CPU is dead, so no locking needed. */
 	if (pagevec_count(pvec))
-		__pagevec_lru_add(pvec);
-	pvec = &per_cpu(lru_add_active_pvecs, cpu);
+		__pagevec_lru_add_file(pvec);
+	pvec = &per_cpu(lru_add_active_file_pvecs, cpu);
 	if (pagevec_count(pvec))
-		__pagevec_lru_add_active(pvec);
+		__pagevec_lru_add_active_file(pvec);
+	pvec = &per_cpu(lru_add_anon_pvecs, cpu);
+	if (pagevec_count(pvec))
+		__pagevec_lru_add_anon(pvec);
+	pvec = &per_cpu(lru_add_active_anon_pvecs, cpu);
+	if (pagevec_count(pvec))
+		__pagevec_lru_add_active_anon(pvec);
 }
 
 void lru_add_drain(void)
@@ -348,7 +398,32 @@ void __pagevec_release_nonlru(struct pag
  * Add the passed pages to the LRU, then drop the caller's refcount
  * on them.  Reinitialises the caller's pagevec.
  */
-void __pagevec_lru_add(struct pagevec *pvec)
+void __pagevec_lru_add_file(struct pagevec *pvec)
+{
+	int i;
+	struct zone *zone = NULL;
+
+	for (i = 0; i < pagevec_count(pvec); i++) {
+		struct page *page = pvec->pages[i];
+		struct zone *pagezone = page_zone(page);
+
+		if (pagezone != zone) {
+			if (zone)
+				spin_unlock_irq(&zone->lru_lock);
+			zone = pagezone;
+			spin_lock_irq(&zone->lru_lock);
+		}
+		VM_BUG_ON(PageLRU(page));
+		SetPageLRU(page);
+		add_page_to_inactive_file_list(zone, page);
+	}
+	if (zone)
+		spin_unlock_irq(&zone->lru_lock);
+	release_pages(pvec->pages, pvec->nr, pvec->cold);
+	pagevec_reinit(pvec);
+}
+
+void __pagevec_lru_add_active_file(struct pagevec *pvec)
 {
 	int i;
 	struct zone *zone = NULL;
@@ -365,7 +440,9 @@ void __pagevec_lru_add(struct pagevec *p
 		}
 		VM_BUG_ON(PageLRU(page));
 		SetPageLRU(page);
-		add_page_to_inactive_list(zone, page);
+		VM_BUG_ON(PageActive(page));
+		SetPageActive(page);
+		add_page_to_active_file_list(zone, page);
 	}
 	if (zone)
 		spin_unlock_irq(&zone->lru_lock);
@@ -373,9 +450,32 @@ void __pagevec_lru_add(struct pagevec *p
 	pagevec_reinit(pvec);
 }
 
-EXPORT_SYMBOL(__pagevec_lru_add);
+void __pagevec_lru_add_anon(struct pagevec *pvec)
+{
+	int i;
+	struct zone *zone = NULL;
+
+	for (i = 0; i < pagevec_count(pvec); i++) {
+		struct page *page = pvec->pages[i];
+		struct zone *pagezone = page_zone(page);
+
+		if (pagezone != zone) {
+			if (zone)
+				spin_unlock_irq(&zone->lru_lock);
+			zone = pagezone;
+			spin_lock_irq(&zone->lru_lock);
+		}
+		VM_BUG_ON(PageLRU(page));
+		SetPageLRU(page);
+		add_page_to_inactive_anon_list(zone, page);
+	}
+	if (zone)
+		spin_unlock_irq(&zone->lru_lock);
+	release_pages(pvec->pages, pvec->nr, pvec->cold);
+	pagevec_reinit(pvec);
+}
 
-void __pagevec_lru_add_active(struct pagevec *pvec)
+void __pagevec_lru_add_active_anon(struct pagevec *pvec)
 {
 	int i;
 	struct zone *zone = NULL;
@@ -394,7 +494,7 @@ void __pagevec_lru_add_active(struct pag
 		SetPageLRU(page);
 		VM_BUG_ON(PageActive(page));
 		SetPageActive(page);
-		add_page_to_active_list(zone, page);
+		add_page_to_active_anon_list(zone, page);
 	}
 	if (zone)
 		spin_unlock_irq(&zone->lru_lock);
--- linux-2.6.21.noarch/mm/swapfile.c.vmsplit	2007-07-23 12:13:21.000000000 -0400
+++ linux-2.6.21.noarch/mm/swapfile.c	2007-07-23 12:15:20.000000000 -0400
@@ -519,7 +519,7 @@ static void unuse_pte(struct vm_area_str
 	 * Move the page to the active list so it is not
 	 * immediately swapped out again after swapon.
 	 */
-	activate_page(page);
+	activate_page_anon(page);
 }
 
 static int unuse_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
@@ -621,7 +621,7 @@ static int unuse_mm(struct mm_struct *mm
 		 * Activate page so shrink_cache is unlikely to unmap its
 		 * ptes while lock is dropped, so swapoff can make progress.
 		 */
-		activate_page(page);
+		activate_page_anon(page);
 		unlock_page(page);
 		down_read(&mm->mmap_sem);
 		lock_page(page);

--------------070802020901020402010801
Content-Type: text/x-patch;
 name="linux-2.6.22-vmsplit-swapfree.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux-2.6.22-vmsplit-swapfree.patch"

--- linux-2.6.22.noarch/mm/vmscan.c.swapfree	2007-07-14 00:36:26.000000000 -0400
+++ linux-2.6.22.noarch/mm/vmscan.c	2007-07-14 00:35:58.000000000 -0400
@@ -892,6 +892,13 @@ static void get_scan_ratio(struct zone *
 	unsigned long anon_prio, file_prio;
 	unsigned long rotate_sum;
 
+	/* If there is no free swap space, do not scan anonymous pages. */
+	if (nr_swap_pages <= 0) {
+		*anon_percent = 0;
+		*file_percent = 100;
+		return;
+	}
+
 	anon  = zone_page_state(zone, NR_ACTIVE_ANON) +
 		zone_page_state(zone, NR_INACTIVE_ANON);
 	file  = zone_page_state(zone, NR_ACTIVE_FILE) +

--------------070802020901020402010801--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
