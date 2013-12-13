Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
	by kanga.kvack.org (Postfix) with ESMTP id 06B146B0031
	for <linux-mm@kvack.org>; Fri, 13 Dec 2013 18:59:09 -0500 (EST)
Received: by mail-pb0-f50.google.com with SMTP id rr13so3211443pbb.37
        for <linux-mm@kvack.org>; Fri, 13 Dec 2013 15:59:09 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id sw1si2628304pab.199.2013.12.13.15.59.05
        for <linux-mm@kvack.org>;
        Fri, 13 Dec 2013 15:59:06 -0800 (PST)
Subject: [RFC][PATCH 1/7] mm: print more details for bad_page()
From: Dave Hansen <dave@sr71.net>
Date: Fri, 13 Dec 2013 15:59:04 -0800
References: <20131213235903.8236C539@viggo.jf.intel.com>
In-Reply-To: <20131213235903.8236C539@viggo.jf.intel.com>
Message-Id: <20131213235904.D69C09F7@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Pravin B Shelar <pshelar@nicira.com>, Christoph Lameter <cl@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave@sr71.net>


bad_page() is cool in that it prints out a bunch of data about
the page.  But, I can never remember which page flags are good
and which are bad, or whether ->index or ->mapping is required to
be NULL.

This patch allows bad/dump_page() callers to specify a string about
why they are dumping the page and adds explanation strings to a
number of places.  It also adds a 'bad_flags'
argument to bad_page(), which it then dumps out separately from
the flags which are actually set.

This way, the messages will show specifically why the page was
bad, *specifically* which flags it is complaining about, if it
was a page flag combination which was the problem.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
---

 linux.git-davehans/include/linux/mm.h      |    4 +
 linux.git-davehans/mm/balloon_compaction.c |    4 -
 linux.git-davehans/mm/memory.c             |    2 
 linux.git-davehans/mm/memory_hotplug.c     |    2 
 linux.git-davehans/mm/page_alloc.c         |   73 +++++++++++++++++++++--------
 5 files changed, 62 insertions(+), 23 deletions(-)

diff -puN include/linux/mm.h~bad-page-details include/linux/mm.h
--- linux.git/include/linux/mm.h~bad-page-details	2013-12-13 15:51:47.177206143 -0800
+++ linux.git-davehans/include/linux/mm.h	2013-12-13 15:51:47.183206407 -0800
@@ -1977,7 +1977,9 @@ extern void shake_page(struct page *p, i
 extern atomic_long_t num_poisoned_pages;
 extern int soft_offline_page(struct page *page, int flags);
 
-extern void dump_page(struct page *page);
+extern void dump_page(struct page *page, char *reason);
+extern void dump_page_badflags(struct page *page, char *reason,
+			       unsigned long badflags);
 
 #if defined(CONFIG_TRANSPARENT_HUGEPAGE) || defined(CONFIG_HUGETLBFS)
 extern void clear_huge_page(struct page *page,
diff -puN mm/balloon_compaction.c~bad-page-details mm/balloon_compaction.c
--- linux.git/mm/balloon_compaction.c~bad-page-details	2013-12-13 15:51:47.178206187 -0800
+++ linux.git-davehans/mm/balloon_compaction.c	2013-12-13 15:51:47.183206407 -0800
@@ -267,7 +267,7 @@ void balloon_page_putback(struct page *p
 		put_page(page);
 	} else {
 		WARN_ON(1);
-		dump_page(page);
+		dump_page(page, "not movable balloon page");
 	}
 	unlock_page(page);
 }
@@ -287,7 +287,7 @@ int balloon_page_migrate(struct page *ne
 	BUG_ON(!trylock_page(newpage));
 
 	if (WARN_ON(!__is_movable_balloon_page(page))) {
-		dump_page(page);
+		dump_page(page, "not movable balloon page");
 		unlock_page(newpage);
 		return rc;
 	}
diff -puN mm/memory.c~bad-page-details mm/memory.c
--- linux.git/mm/memory.c~bad-page-details	2013-12-13 15:51:47.179206231 -0800
+++ linux.git-davehans/mm/memory.c	2013-12-13 15:51:47.184206451 -0800
@@ -670,7 +670,7 @@ static void print_bad_pte(struct vm_area
 		current->comm,
 		(long long)pte_val(pte), (long long)pmd_val(*pmd));
 	if (page)
-		dump_page(page);
+		dump_page(page, "bad pte");
 	printk(KERN_ALERT
 		"addr:%p vm_flags:%08lx anon_vma:%p mapping:%p index:%lx\n",
 		(void *)addr, vma->vm_flags, vma->anon_vma, mapping, index);
diff -puN mm/memory_hotplug.c~bad-page-details mm/memory_hotplug.c
--- linux.git/mm/memory_hotplug.c~bad-page-details	2013-12-13 15:51:47.180206275 -0800
+++ linux.git-davehans/mm/memory_hotplug.c	2013-12-13 15:51:47.185206495 -0800
@@ -1310,7 +1310,7 @@ do_migrate_range(unsigned long start_pfn
 #ifdef CONFIG_DEBUG_VM
 			printk(KERN_ALERT "removing pfn %lx from LRU failed\n",
 			       pfn);
-			dump_page(page);
+			dump_page(page, "failed to remove from LRU");
 #endif
 			put_page(page);
 			/* Because we don't have big zone->lock. we should
diff -puN mm/page_alloc.c~bad-page-details mm/page_alloc.c
--- linux.git/mm/page_alloc.c~bad-page-details	2013-12-13 15:51:47.181206319 -0800
+++ linux.git-davehans/mm/page_alloc.c	2013-12-13 15:51:47.186206539 -0800
@@ -295,7 +295,7 @@ static inline int bad_range(struct zone
 }
 #endif
 
-static void bad_page(struct page *page)
+static void bad_page(struct page *page, char *reason, unsigned long bad_flags)
 {
 	static unsigned long resume;
 	static unsigned long nr_shown;
@@ -329,7 +329,7 @@ static void bad_page(struct page *page)
 
 	printk(KERN_ALERT "BUG: Bad page state in process %s  pfn:%05lx\n",
 		current->comm, page_to_pfn(page));
-	dump_page(page);
+	dump_page_badflags(page, reason, bad_flags);
 
 	print_modules();
 	dump_stack();
@@ -383,7 +383,7 @@ static int destroy_compound_page(struct
 	int bad = 0;
 
 	if (unlikely(compound_order(page) != order)) {
-		bad_page(page);
+		bad_page(page, "wrong compound order", 0);
 		bad++;
 	}
 
@@ -392,8 +392,11 @@ static int destroy_compound_page(struct
 	for (i = 1; i < nr_pages; i++) {
 		struct page *p = page + i;
 
-		if (unlikely(!PageTail(p) || (p->first_page != page))) {
-			bad_page(page);
+		if (unlikely(!PageTail(p))) {
+			bad_page(page, "PageTail not set", 0);
+			bad++;
+		} else if (unlikely(p->first_page != page)) {
+			bad_page(page, "first_page not consistent", 0);
 			bad++;
 		}
 		__ClearPageTail(p);
@@ -618,12 +621,23 @@ out:
 
 static inline int free_pages_check(struct page *page)
 {
-	if (unlikely(page_mapcount(page) |
-		(page->mapping != NULL)  |
-		(atomic_read(&page->_count) != 0) |
-		(page->flags & PAGE_FLAGS_CHECK_AT_FREE) |
-		(mem_cgroup_bad_page_check(page)))) {
-		bad_page(page);
+	char *bad_reason = NULL;
+	unsigned long bad_flags = 0;
+
+	if (unlikely(page_mapcount(page)))
+		bad_reason = "nonzero mapcount";
+	if (unlikely(page->mapping != NULL))
+		bad_reason = "non-NULL mapping";
+	if (unlikely(atomic_read(&page->_count) != 0))
+		bad_reason = "nonzero _count";
+	if (unlikely(page->flags & PAGE_FLAGS_CHECK_AT_FREE)) {
+		bad_reason = "PAGE_FLAGS_CHECK_AT_FREE flag(s) set";
+		bad_flags = PAGE_FLAGS_CHECK_AT_FREE;
+	}
+	if (unlikely(mem_cgroup_bad_page_check(page)))
+		bad_reason = "cgroup check failed";
+	if (unlikely(bad_reason)) {
+		bad_page(page, bad_reason, bad_flags);
 		return 1;
 	}
 	page_cpupid_reset_last(page);
@@ -843,12 +857,23 @@ static inline void expand(struct zone *z
  */
 static inline int check_new_page(struct page *page)
 {
-	if (unlikely(page_mapcount(page) |
-		(page->mapping != NULL)  |
-		(atomic_read(&page->_count) != 0)  |
-		(page->flags & PAGE_FLAGS_CHECK_AT_PREP) |
-		(mem_cgroup_bad_page_check(page)))) {
-		bad_page(page);
+	char *bad_reason = NULL;
+	unsigned long bad_flags = 0;
+
+	if (unlikely(page_mapcount(page)))
+		bad_reason = "nonzero mapcount";
+	if (unlikely(page->mapping != NULL))
+		bad_reason = "non-NULL mapping";
+	if (unlikely(atomic_read(&page->_count) != 0))
+		bad_reason = "nonzero _count";
+	if (unlikely(page->flags & PAGE_FLAGS_CHECK_AT_PREP)) {
+		bad_reason = "PAGE_FLAGS_CHECK_AT_PREP flag set";
+		bad_flags = PAGE_FLAGS_CHECK_AT_PREP;
+	}
+	if (unlikely(mem_cgroup_bad_page_check(page)))
+		bad_reason = "cgroup check failed";
+	if (unlikely(bad_reason)) {
+		bad_page(page, bad_reason, bad_flags);
 		return 1;
 	}
 	return 0;
@@ -6458,12 +6483,24 @@ static void dump_page_flags(unsigned lon
 	printk(")\n");
 }
 
-void dump_page(struct page *page)
+void dump_page_badflags(struct page *page, char *reason, unsigned long badflags)
 {
 	printk(KERN_ALERT
 	       "page:%p count:%d mapcount:%d mapping:%p index:%#lx\n",
 		page, atomic_read(&page->_count), page_mapcount(page),
 		page->mapping, page->index);
 	dump_page_flags(page->flags);
+	if (reason)
+		printk(KERN_ALERT "page dumped because: %s\n", reason);
+	if (page->flags & badflags) {
+		printk(KERN_ALERT "bad because of flags:\n");
+		dump_page_flags(page->flags & badflags);
+	}
 	mem_cgroup_print_bad_page(page);
 }
+
+void dump_page(struct page *page, char *reason)
+{
+	dump_page_badflags(page, reason, 0);
+}
+
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
