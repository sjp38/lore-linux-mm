Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id A31658E0014
	for <linux-mm@kvack.org>; Thu, 13 Dec 2018 14:38:30 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id z126so2594648qka.10
        for <linux-mm@kvack.org>; Thu, 13 Dec 2018 11:38:30 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w64si1637439qte.374.2018.12.13.11.38.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Dec 2018 11:38:29 -0800 (PST)
From: Waiman Long <longman@redhat.com>
Subject: [PATCH] mm: Replace verify_mm_writelocked() by lockdep_assert_held_exclusive()
Date: Thu, 13 Dec 2018 14:38:05 -0500
Message-Id: <1544729885-30702-1-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Yang Shi <yang.shi@linux.alibaba.com>, Waiman Long <longman@redhat.com>

Using down_read_trylock() to check if a task holds a write lock on
a rwsem is not reliable. A task can hold a read lock on a rwsem and
down_read_trylock() can fail if a writer is waiting in the wait queue.
So use lockdep_assert_held_exclusive() instead which can do the right
check when CONFIG_LOCKDEP is on.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 mm/mmap.c | 12 +-----------
 1 file changed, 1 insertion(+), 11 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index 6c04292..62a5593 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2962,16 +2962,6 @@ int vm_munmap(unsigned long start, size_t len)
 	return ret;
 }
 
-static inline void verify_mm_writelocked(struct mm_struct *mm)
-{
-#ifdef CONFIG_DEBUG_VM
-	if (unlikely(down_read_trylock(&mm->mmap_sem))) {
-		WARN_ON(1);
-		up_read(&mm->mmap_sem);
-	}
-#endif
-}
-
 /*
  *  this is really a simplified "do_mmap".  it only handles
  *  anonymous maps.  eventually we may be able to do some
@@ -3002,7 +2992,7 @@ static int do_brk_flags(unsigned long addr, unsigned long len, unsigned long fla
 	 * mm->mmap_sem is required to protect against another thread
 	 * changing the mappings in case we sleep.
 	 */
-	verify_mm_writelocked(mm);
+	lockdep_assert_held_exclusive(&mm->mmap_sem);
 
 	/*
 	 * Clear old maps.  this also does some error checking for us
-- 
1.8.3.1
