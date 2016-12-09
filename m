Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 110246B0273
	for <linux-mm@kvack.org>; Fri,  9 Dec 2016 00:16:38 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 3so17139620pgd.3
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 21:16:38 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id t124si31927743pgt.334.2016.12.08.21.16.36
        for <linux-mm@kvack.org>;
        Thu, 08 Dec 2016 21:16:37 -0800 (PST)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [PATCH v4 13/15] lockdep: Apply lock_acquire(release) on __Set(__Clear)PageLocked
Date: Fri,  9 Dec 2016 14:12:09 +0900
Message-Id: <1481260331-360-14-git-send-email-byungchul.park@lge.com>
In-Reply-To: <1481260331-360-1-git-send-email-byungchul.park@lge.com>
References: <1481260331-360-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org
Cc: tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com

Usually PG_locked bit is updated by lock_page() or unlock_page().
However, it can be also updated through __SetPageLocked() or
__ClearPageLockded(). They have to be considered, to get paired between
acquire and release.

Furthermore, e.g. __SetPageLocked() in add_to_page_cache_lru() is called
frequently. We might miss many chances to check deadlock if we ignore it.
Consider __Set(__Clear)PageLockded as well.

Signed-off-by: Byungchul Park <byungchul.park@lge.com>
---
 include/linux/page-flags.h | 30 +++++++++++++++++++++++++++++-
 1 file changed, 29 insertions(+), 1 deletion(-)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index e5a3244..e28f232 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -249,7 +249,6 @@ static inline int TestClearPage##uname(struct page *page) { return 0; }
 #define TESTSCFLAG_FALSE(uname)						\
 	TESTSETFLAG_FALSE(uname) TESTCLEARFLAG_FALSE(uname)
 
-__PAGEFLAG(Locked, locked, PF_NO_TAIL)
 PAGEFLAG(Error, error, PF_NO_COMPOUND) TESTCLEARFLAG(Error, error, PF_NO_COMPOUND)
 PAGEFLAG(Referenced, referenced, PF_HEAD)
 	TESTCLEARFLAG(Referenced, referenced, PF_HEAD)
@@ -351,6 +350,35 @@ TESTCLEARFLAG(Young, young, PF_ANY)
 PAGEFLAG(Idle, idle, PF_ANY)
 #endif
 
+#ifdef CONFIG_LOCKDEP_PAGELOCK
+#include <linux/lockdep.h>
+
+TESTPAGEFLAG(Locked, locked, PF_NO_TAIL)
+
+static __always_inline void __SetPageLocked(struct page *page)
+{
+	__set_bit(PG_locked, &PF_NO_TAIL(page, 1)->flags);
+
+	page = compound_head(page);
+	lock_acquire_exclusive(&page->map, 0, 1, NULL, _RET_IP_);
+}
+
+static __always_inline void __ClearPageLocked(struct page *page)
+{
+	__clear_bit(PG_locked, &PF_NO_TAIL(page, 1)->flags);
+
+	page = compound_head(page);
+	/*
+	 * lock_commit_crosslock() is necessary for crosslock
+	 * when the lock is released, before lock_release().
+	 */
+	lock_commit_crosslock(&page->map);
+	lock_release(&page->map, 0, _RET_IP_);
+}
+#else
+__PAGEFLAG(Locked, locked, PF_NO_TAIL)
+#endif
+
 /*
  * On an anonymous page mapped into a user virtual memory area,
  * page->mapping points to its anon_vma, not to a struct address_space;
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
