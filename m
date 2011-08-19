Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9B86D6B016F
	for <linux-mm@kvack.org>; Fri, 19 Aug 2011 03:49:00 -0400 (EDT)
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id p7J7mw1I006282
	for <linux-mm@kvack.org>; Fri, 19 Aug 2011 00:48:58 -0700
Received: from gyd8 (gyd8.prod.google.com [10.243.49.200])
	by wpaz5.hot.corp.google.com with ESMTP id p7J7mlE1005352
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 19 Aug 2011 00:48:57 -0700
Received: by gyd8 with SMTP id 8so2504709gyd.24
        for <linux-mm@kvack.org>; Fri, 19 Aug 2011 00:48:57 -0700 (PDT)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH 6/9] mm: assert that get_page_unless_zero() callers hold the rcu lock
Date: Fri, 19 Aug 2011 00:48:28 -0700
Message-Id: <1313740111-27446-7-git-send-email-walken@google.com>
In-Reply-To: <1313740111-27446-1-git-send-email-walken@google.com>
References: <1313740111-27446-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>

In order to guarantee that page counts are stable one rcu grace period
after page allocation, it is important that get_page_unless_zero
call sites follow the proper protocol and hold the rcu read lock from
the time they locate the desired page until they get a reference on it.

__isolate_lru_page() is exempted - it knows the page it's trying to get
a reference on can't get fully freed, as it is on LRU list and it holds
the zone LRU lock.

Other call sites in memory_hotplug.c, memory_failure.c and hwpoison-inject.c
are also exempted. It would be preferable if someone more familiar with
these features could determine if that's safe.

Signed-off-by: Michel Lespinasse <walken@google.com>
---
 include/linux/mm.h      |   16 +++++++++++++++-
 include/linux/pagemap.h |    1 +
 mm/hwpoison-inject.c    |    2 +-
 mm/memory-failure.c     |    6 +++---
 mm/memory_hotplug.c     |    2 +-
 mm/vmscan.c             |    7 ++++++-
 6 files changed, 27 insertions(+), 7 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 9670f71..9ff5f2d 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -275,13 +275,27 @@ static inline int put_page_testzero(struct page *page)
 	return atomic_dec_and_test(&page->_count);
 }
 
+static inline int __get_page_unless_zero(struct page *page)
+{
+	return atomic_inc_not_zero(&page->_count);
+}
+
 /*
  * Try to grab a ref unless the page has a refcount of zero, return false if
  * that is the case.
  */
 static inline int get_page_unless_zero(struct page *page)
 {
-	return atomic_inc_not_zero(&page->_count);
+	/*
+	 * See page_cache_get_speculative() comment in pagemap.h
+	 * Note that for page counts to be guaranteed stable one
+	 * RCU grace period after they've been allocated,
+	 * all get_page_unless_zero call sites have to participate
+	 * by taking an rcu read lock before locating the desired page
+	 * and until getting a reference on it.
+	 */
+	VM_BUG_ON(!rcu_read_lock_held());
+	return __get_page_unless_zero(page);
 }
 
 extern int page_is_ram(unsigned long pfn);
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 716875e..736f47d 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -131,6 +131,7 @@ void release_pages(struct page **pages, int nr, int cold);
  */
 static inline int page_cache_get_speculative(struct page *page)
 {
+	VM_BUG_ON(!rcu_read_lock_held());
 	VM_BUG_ON(in_interrupt());
 
 #if !defined(CONFIG_SMP) && defined(CONFIG_TREE_RCU)
diff --git a/mm/hwpoison-inject.c b/mm/hwpoison-inject.c
index c7fc7fd..87e027b 100644
--- a/mm/hwpoison-inject.c
+++ b/mm/hwpoison-inject.c
@@ -30,7 +30,7 @@ static int hwpoison_inject(void *data, u64 val)
 	/*
 	 * This implies unable to support free buddy pages.
 	 */
-	if (!get_page_unless_zero(hpage))
+	if (!__get_page_unless_zero(hpage))
 		return 0;
 
 	if (!PageLRU(p) && !PageHuge(p))
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 740c4f5..6fc0409 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1025,7 +1025,7 @@ int __memory_failure(unsigned long pfn, int trapno, int flags)
 	 * that may make page_freeze_refs()/page_unfreeze_refs() mismatch.
 	 */
 	if (!(flags & MF_COUNT_INCREASED) &&
-		!get_page_unless_zero(hpage)) {
+		!__get_page_unless_zero(hpage)) {
 		if (is_free_buddy_page(p)) {
 			action_result(pfn, "free buddy", DELAYED);
 			return 0;
@@ -1210,7 +1210,7 @@ int unpoison_memory(unsigned long pfn)
 
 	nr_pages = 1 << compound_trans_order(page);
 
-	if (!get_page_unless_zero(page)) {
+	if (!__get_page_unless_zero(page)) {
 		/*
 		 * Since HWPoisoned hugepage should have non-zero refcount,
 		 * race between memory failure and unpoison seems to happen.
@@ -1289,7 +1289,7 @@ static int get_any_page(struct page *p, unsigned long pfn, int flags)
 	 * When the target page is a free hugepage, just remove it
 	 * from free hugepage list.
 	 */
-	if (!get_page_unless_zero(compound_head(p))) {
+	if (!__get_page_unless_zero(compound_head(p))) {
 		if (PageHuge(p)) {
 			pr_info("get_any_page: %#lx free huge page\n", pfn);
 			ret = dequeue_hwpoisoned_huge_page(compound_head(p));
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index c46887b..cf57dfc 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -710,7 +710,7 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
 		if (!pfn_valid(pfn))
 			continue;
 		page = pfn_to_page(pfn);
-		if (!get_page_unless_zero(page))
+		if (!__get_page_unless_zero(page))
 			continue;
 		/*
 		 * We can skip free pages. And we can only deal with pages on
diff --git a/mm/vmscan.c b/mm/vmscan.c
index d036e59..4c167da 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1001,11 +1001,16 @@ int __isolate_lru_page(struct page *page, int mode, int file)
 
 	ret = -EBUSY;
 
-	if (likely(get_page_unless_zero(page))) {
+	if (likely(__get_page_unless_zero(page))) {
 		/*
 		 * Be careful not to clear PageLRU until after we're
 		 * sure the page is not being freed elsewhere -- the
 		 * page release code relies on it.
+		 *
+		 * We are able to use the __get_page_unless_zero() variant
+		 * because we know the page can't get fully freed before we
+		 * get the reference on it - as it is on LRU list and we
+		 * hold the zone LRU lock.
 		 */
 		ClearPageLRU(page);
 		ret = 0;
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
