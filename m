Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id BC1476B0008
	for <linux-mm@kvack.org>; Wed, 23 Jan 2013 10:23:50 -0500 (EST)
Date: Wed, 23 Jan 2013 15:23:31 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH] mm: uninline page_xchg_last_nid()
Message-ID: <20130123152330.GJ13304@suse.de>
References: <1358874762-19717-1-git-send-email-mgorman@suse.de>
 <1358874762-19717-6-git-send-email-mgorman@suse.de>
 <20130122144659.d512e05c.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130122144659.d512e05c.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>, Simon Jeons <simon.jeons@gmail.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Hugh Dickins <hughd@google.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Andrew Morton pointed out that page_xchg_last_nid() and reset_page_last_nid()
were "getting nuttily large" and asked that it be investigated.

reset_page_last_nid() is on the page free path and it would be unfortunate
to make that path more expensive than it needs to be. Due to the internal
use of page_xchg_last_nid() it is already too expensive but fortunately,
it should also be impossible for the page->flags to be updated in parallel
when we call reset_page_last_nid(). Instead of unlining the function,
it uses a simplier implementation that assumes no parallel updates and
should now be sufficiently short for inlining.

page_xchg_last_nid() is called in paths that are already quite expensive
(splitting huge page, fault handling, migration) and it is reasonable to
uninline. There was not really a good place to place the function but
mm/mmzone.c was the closest fit IMO.

This patch saved 128 bytes of text in the vmlinux file for the kernel
configuration I used for testing automatic NUMA balancing.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/mm.h |   21 +++++----------------
 mm/mmzone.c        |   20 +++++++++++++++++++-
 2 files changed, 24 insertions(+), 17 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index e25d47f..6e4468f 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -676,25 +676,14 @@ static inline int page_last_nid(struct page *page)
 	return (page->flags >> LAST_NID_PGSHIFT) & LAST_NID_MASK;
 }
 
-static inline int page_xchg_last_nid(struct page *page, int nid)
-{
-	unsigned long old_flags, flags;
-	int last_nid;
-
-	do {
-		old_flags = flags = page->flags;
-		last_nid = page_last_nid(page);
-
-		flags &= ~(LAST_NID_MASK << LAST_NID_PGSHIFT);
-		flags |= (nid & LAST_NID_MASK) << LAST_NID_PGSHIFT;
-	} while (unlikely(cmpxchg(&page->flags, old_flags, flags) != old_flags));
-
-	return last_nid;
-}
+extern int page_xchg_last_nid(struct page *page, int nid);
 
 static inline void reset_page_last_nid(struct page *page)
 {
-	page_xchg_last_nid(page, (1 << LAST_NID_SHIFT) - 1);
+	int nid = (1 << LAST_NID_SHIFT) - 1;
+
+	page->flags &= ~(LAST_NID_MASK << LAST_NID_PGSHIFT);
+	page->flags |= (nid & LAST_NID_MASK) << LAST_NID_PGSHIFT;
 }
 #endif /* LAST_NID_NOT_IN_PAGE_FLAGS */
 #else
diff --git a/mm/mmzone.c b/mm/mmzone.c
index 4596d81..bce796e 100644
--- a/mm/mmzone.c
+++ b/mm/mmzone.c
@@ -1,7 +1,7 @@
 /*
  * linux/mm/mmzone.c
  *
- * management codes for pgdats and zones.
+ * management codes for pgdats, zones and page flags
  */
 
 
@@ -96,3 +96,21 @@ void lruvec_init(struct lruvec *lruvec)
 	for_each_lru(lru)
 		INIT_LIST_HEAD(&lruvec->lists[lru]);
 }
+
+#if defined(CONFIG_NUMA_BALANCING) && !defined(LAST_NID_NOT_IN_PAGE_FLAGS)
+int page_xchg_last_nid(struct page *page, int nid)
+{
+	unsigned long old_flags, flags;
+	int last_nid;
+
+	do {
+		old_flags = flags = page->flags;
+		last_nid = page_last_nid(page);
+
+		flags &= ~(LAST_NID_MASK << LAST_NID_PGSHIFT);
+		flags |= (nid & LAST_NID_MASK) << LAST_NID_PGSHIFT;
+	} while (unlikely(cmpxchg(&page->flags, old_flags, flags) != old_flags));
+
+	return last_nid;
+}
+#endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
