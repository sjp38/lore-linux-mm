Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id B11396B038D
	for <linux-mm@kvack.org>; Tue, 14 Mar 2017 04:26:25 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id b2so361332416pgc.6
        for <linux-mm@kvack.org>; Tue, 14 Mar 2017 01:26:25 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id r185si14091111pfr.34.2017.03.14.01.26.23
        for <linux-mm@kvack.org>;
        Tue, 14 Mar 2017 01:26:23 -0700 (PDT)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [PATCH v6 13/15] lockdep: Apply lock_acquire(release) on __Set(__Clear)PageLocked
Date: Tue, 14 Mar 2017 17:19:00 +0900
Message-ID: <1489479542-27030-14-git-send-email-byungchul.park@lge.com>
In-Reply-To: <1489479542-27030-1-git-send-email-byungchul.park@lge.com>
References: <1489479542-27030-1-git-send-email-byungchul.park@lge.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org
Cc: tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com

Usually PG_locked bit is updated by lock_page() or unlock_page().
However, it can be also updated through __SetPageLocked() or
__ClearPageLockded(). They have to be considered, to get paired between
acquire and release.

Furthermore, e.g. __SetPageLocked() in add_to_page_cache_lru() is called
frequently. We might miss many chances to check deadlock if we ignore it.
Make __Set(__Clear)PageLockded considered as well.

Signed-off-by: Byungchul Park <byungchul.park@lge.com>
---
 include/linux/page-flags.h | 30 +++++++++++++++++++++++++++++-
 1 file changed, 29 insertions(+), 1 deletion(-)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 74e4dda..9d5f79d 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -252,7 +252,6 @@ static __always_inline int PageCompound(struct page *page)
 #define TESTSCFLAG_FALSE(uname)						\
 	TESTSETFLAG_FALSE(uname) TESTCLEARFLAG_FALSE(uname)
 
-__PAGEFLAG(Locked, locked, PF_NO_TAIL)
 PAGEFLAG(Error, error, PF_NO_COMPOUND) TESTCLEARFLAG(Error, error, PF_NO_COMPOUND)
 PAGEFLAG(Referenced, referenced, PF_HEAD)
 	TESTCLEARFLAG(Referenced, referenced, PF_HEAD)
@@ -354,6 +353,35 @@ static __always_inline int PageCompound(struct page *page)
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
+	lock_acquire_exclusive((struct lockdep_map *)&page->map, 0, 1, NULL, _RET_IP_);
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
+	lock_commit_crosslock((struct lockdep_map *)&page->map);
+	lock_release((struct lockdep_map *)&page->map, 0, _RET_IP_);
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
