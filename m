Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 945756B025E
	for <linux-mm@kvack.org>; Mon,  4 Dec 2017 00:16:49 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id n6so12073522pfg.19
        for <linux-mm@kvack.org>; Sun, 03 Dec 2017 21:16:49 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id k23si9552484pff.141.2017.12.03.21.16.47
        for <linux-mm@kvack.org>;
        Sun, 03 Dec 2017 21:16:48 -0800 (PST)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [PATCH v2 2/4] lockdep: Apply lock_acquire(release) on __Set(__Clear)PageLocked
Date: Mon,  4 Dec 2017 14:16:21 +0900
Message-Id: <1512364583-26070-3-git-send-email-byungchul.park@lge.com>
In-Reply-To: <1512364583-26070-1-git-send-email-byungchul.park@lge.com>
References: <1512364583-26070-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org, akpm@linux-foundation.org
Cc: tglx@linutronix.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, kernel-team@lge.com, jack@suse.cz, jlayton@redhat.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, npiggin@gmail.com, rgoldwyn@suse.com, vbabka@suse.cz, mhocko@suse.com, pombredanne@nexb.com, vinmenon@codeaurora.org, gregkh@linuxfoundation.org

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
index 584b14c..108d2dd 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -262,7 +262,6 @@ static __always_inline int PageCompound(struct page *page)
 #define TESTSCFLAG_FALSE(uname)						\
 	TESTSETFLAG_FALSE(uname) TESTCLEARFLAG_FALSE(uname)
 
-__PAGEFLAG(Locked, locked, PF_NO_TAIL)
 PAGEFLAG(Waiters, waiters, PF_ONLY_HEAD) __CLEARPAGEFLAG(Waiters, waiters, PF_ONLY_HEAD)
 PAGEFLAG(Error, error, PF_NO_COMPOUND) TESTCLEARFLAG(Error, error, PF_NO_COMPOUND)
 PAGEFLAG(Referenced, referenced, PF_HEAD)
@@ -374,6 +373,35 @@ static __always_inline int PageSwapCache(struct page *page)
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
