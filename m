Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 2ACD86B00EB
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 16:10:43 -0500 (EST)
Date: Mon, 20 Feb 2012 16:10:40 -0500
From: Dean Nelson <dnelson@redhat.com>
Message-Id: <20120220211040.8887.22420.email-sent-by-dnelson@aqua>
Subject: [PATCH] thp: allow a hwpoisoned head page to be put back to LRU
Content-Type: text/x-diff; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Jin Dongming <jin.dongming@np.css.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org

Andrea Arcangeli pointed out to me that a check in __memory_failure() which
was intended to prevent THP tail pages from being checked for the absence
of the PG_lru flag (something that is always the case), was also preventing
THP head pages from being checked.

A THP head page could actually benefit from the call to shake_page() by
ending up being put back to a LRU, provided it had been waiting in a
pagevec array.

Andrea suggested that the "!PageTransCompound(p)" in the if-statement
should be replaced by a "!PageTransTail(p)", thus allowing THP head pages
to be checked and possibly shaken.

Signed-off-by: Dean Nelson <dnelson@redhat.com>

---
 include/linux/page-flags.h |   20 ++++++++++++++++++++
 mm/memory-failure.c        |    2 +-
 2 files changed, 21 insertions(+), 1 deletions(-)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index e90a673..ca8b626 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -414,11 +414,26 @@ static inline int PageTransHuge(struct page *page)
 	return PageHead(page);
 }
 
+/*
+ * PageTransCompound returns true for both transparent huge pages
+ * and hugetlbfs pages, so it should only be called when it's known
+ * that hugetlbfs pages aren't involved.
+ */
 static inline int PageTransCompound(struct page *page)
 {
 	return PageCompound(page);
 }
 
+/*
+ * PageTransTail returns true for both transparent huge pages
+ * and hugetlbfs pages, so it should only be called when it's known
+ * that hugetlbfs pages aren't involved.
+ */
+static inline int PageTransTail(struct page *page)
+{
+	return PageTail(page);
+}
+
 #else
 
 static inline int PageTransHuge(struct page *page)
@@ -430,6 +445,11 @@ static inline int PageTransCompound(struct page *page)
 {
 	return 0;
 }
+
+static inline int PageTransTail(struct page *page)
+{
+	return 0;
+}
 #endif
 
 #ifdef CONFIG_MMU
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 56080ea..c22076f 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1063,7 +1063,7 @@ int __memory_failure(unsigned long pfn, int trapno, int flags)
 	 * The check (unnecessarily) ignores LRU pages being isolated and
 	 * walked by the page reclaim code, however that's not a big loss.
 	 */
-	if (!PageHuge(p) && !PageTransCompound(p)) {
+	if (!PageHuge(p) && !PageTransTail(p)) {
 		if (!PageLRU(p))
 			shake_page(p, 0);
 		if (!PageLRU(p)) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
