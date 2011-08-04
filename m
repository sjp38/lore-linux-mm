Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id B8A67900138
	for <linux-mm@kvack.org>; Thu,  4 Aug 2011 17:07:48 -0400 (EDT)
Received: from kpbe16.cbf.corp.google.com (kpbe16.cbf.corp.google.com [172.25.105.80])
	by smtp-out.google.com with ESMTP id p74L7iBF032606
	for <linux-mm@kvack.org>; Thu, 4 Aug 2011 14:07:45 -0700
Received: from gwb17 (gwb17.prod.google.com [10.200.2.17])
	by kpbe16.cbf.corp.google.com with ESMTP id p74L7gsw014060
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 4 Aug 2011 14:07:43 -0700
Received: by gwb17 with SMTP id 17so1413680gwb.15
        for <linux-mm@kvack.org>; Thu, 04 Aug 2011 14:07:42 -0700 (PDT)
From: Michel Lespinasse <walken@google.com>
Subject: [RFC PATCH 3/3] mm: get_first_page_unless_zero()
Date: Thu,  4 Aug 2011 14:07:22 -0700
Message-Id: <1312492042-13184-4-git-send-email-walken@google.com>
In-Reply-To: <1312492042-13184-1-git-send-email-walken@google.com>
References: <1312492042-13184-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>

This change introduces a new get_page_unless_zero() function, to be
used for idle page tracking in a a future patch series. It also
illustrates why I care about introducing the page count lock discussed
in the previous commit.

To explain the context: for idle page tracking, I am scanning pages
at a known rate based on their physical address. I want to find out
if pages have been referenced since the last scan using page_referenced(),
but before that I must acquire a reference on the page and to basic
checks about the page type. Before THP, it was safe to acquire references
using get_page_unless_zero(), but this won't work with in THP enabled kernel
due to the possible race with __split_huge_page_refcount(). Thus, the new
proposed get_first_page_unless_zero() function:

- must act like get_page_unless_zero() if the page is not a tail page;
- returns 0 for tail pages.

Without the page count lock I'm proposing, other approaches don't work
as well to provide mutual exclusion with __split_huge_page_refcount():

- using the zone LRU lock would work, but has a low granularity and
  exhibits contention under some of our workloads
- using the page compound lock on some head page wouldn't work well:
  suppose the page we want to get() is currently a single page, but we
  don't hold a reference on it. It can disappear at any time and get
  replaced with a tail page, so it's unsafe to just get a reference
  count on it. OTOH if it does NOT get replaced with a tail page, there
  is no head page to take a compound lock on.
- tricks involving page table locks, disabling interrupts to prevent
  TLB shootdown, or PMD splitting flag, don't work because we don't know
  of an existing mapping for the page.

Signed-off-by: Michel Lespinasse <walken@google.com>
---
 mm/internal.h |   25 +++++++++++++++++++++++++
 mm/swap.c     |   26 ++++++++++++++++++++++++++
 2 files changed, 51 insertions(+), 0 deletions(-)

diff --git a/mm/internal.h b/mm/internal.h
index 8dde36d..7894a33 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -48,6 +48,31 @@ static inline int __put_page_return(struct page *page)
 				 &page->_count) >> _PAGE_COUNT_SHIFT;
 }
 
+static inline int lock_page_count_get_unless_zero(struct page *page)
+{
+	int count, prev, next;
+
+retry_spin:
+	count = atomic_read(&page->_count);
+retry:
+	if (count < _PAGE_COUNT_ONE)
+		return 0;
+	else if (count & _PAGE_COUNT_LOCK) {
+		cpu_relax();
+		goto retry_spin;
+	}
+	prev = count;
+	next = count + _PAGE_COUNT_ONE + _PAGE_COUNT_LOCK;
+	preempt_disable();
+	count = atomic_cmpxchg(&page->_count, prev, next);
+	if (count != prev) {
+		preempt_enable();
+		goto retry;
+	}
+	__acquire(page_count_lock);
+	return 1;
+}
+
 static inline int lock_add_page_count(int nr, struct page *page)
 {
 	int count, prev, next;
diff --git a/mm/swap.c b/mm/swap.c
index 1e91a1b..27cbb14 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -112,6 +112,32 @@ void put_page(struct page *page)
 }
 EXPORT_SYMBOL(put_page);
 
+int get_first_page_unless_zero(struct page *page)
+{
+	if (unlikely(PageTail(page)))
+		return 0;
+
+	/*
+	 * As we do not have a reference count on the page, it could get
+	 * freed anytime and reallocated as a tail page. And if it does, it
+	 * would be unsafe to just increase that tail page's reference count,
+	 * as __split_huge_page_refcount() could then race against us and drop
+	 * an extra reference on the corresponding head page.
+	 *
+	 * Taking the page count lock here protects us against this scenario.
+	 */
+	if (!lock_page_count_get_unless_zero(page))
+		return 0;
+
+	if (unlikely(PageTail(page))) {
+		unlock_sub_page_count(1, page);
+		return 0;
+	}
+	unlock_page_count(page);
+	return 1;
+}
+EXPORT_SYMBOL(get_first_page_unless_zero);
+
 /**
  * put_pages_list() - release a list of pages
  * @pages: list of pages threaded on page->lru
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
