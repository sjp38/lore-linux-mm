Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4EDF76B0038
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 19:17:43 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id h64so6086176itb.13
        for <linux-mm@kvack.org>; Wed, 18 Oct 2017 16:17:43 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e10sor23426itf.81.2017.10.18.16.17.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 18 Oct 2017 16:17:42 -0700 (PDT)
From: Shakeel Butt <shakeelb@google.com>
Subject: [PATCH] mm: mlock: remove lru_add_drain_all()
Date: Wed, 18 Oct 2017 16:17:30 -0700
Message-Id: <20171018231730.42754-1-shakeelb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Yisheng Xie <xieyisheng1@huawei.com>, Ingo Molnar <mingo@kernel.org>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Shakeel Butt <shakeelb@google.com>

Recently we have observed high latency in mlock() in our generic
library and noticed that users have started using tmpfs files even
without swap and the latency was due to expensive remote LRU cache
draining.

Is lru_add_drain_all() required by mlock()? The answer is no and the
reason it is still in mlock() is to rapidly move mlocked pages to
unevictable LRU. Without lru_add_drain_all() the mlocked pages which
were on pagevec at mlock() time will be moved to evictable LRUs but
will eventually be moved back to unevictable LRU by reclaim. So, we
can safely remove lru_add_drain_all() from mlock(). Also there is no
need for local lru_add_drain() as it will be called deep inside
__mm_populate() (in follow_page_pte()).

Signed-off-by: Shakeel Butt <shakeelb@google.com>
---
 mm/mlock.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/mm/mlock.c b/mm/mlock.c
index dfc6f1912176..3ceb2935d1e0 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -669,8 +669,6 @@ static __must_check int do_mlock(unsigned long start, size_t len, vm_flags_t fla
 	if (!can_do_mlock())
 		return -EPERM;
 
-	lru_add_drain_all();	/* flush pagevec */
-
 	len = PAGE_ALIGN(len + (offset_in_page(start)));
 	start &= PAGE_MASK;
 
@@ -797,9 +795,6 @@ SYSCALL_DEFINE1(mlockall, int, flags)
 	if (!can_do_mlock())
 		return -EPERM;
 
-	if (flags & MCL_CURRENT)
-		lru_add_drain_all();	/* flush pagevec */
-
 	lock_limit = rlimit(RLIMIT_MEMLOCK);
 	lock_limit >>= PAGE_SHIFT;
 
-- 
2.15.0.rc1.287.g2b38de12cc-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
