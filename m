Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7B4816B0037
	for <linux-mm@kvack.org>; Tue, 24 Sep 2013 18:22:56 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id kp14so4286545pab.24
        for <linux-mm@kvack.org>; Tue, 24 Sep 2013 15:22:56 -0700 (PDT)
Subject: [PATCH v5 1/6] rwsem: check the lock before cpmxchg in
 down_write_trylock
From: Tim Chen <tim.c.chen@linux.intel.com>
In-Reply-To: <cover.1380057198.git.tim.c.chen@linux.intel.com>
References: <cover.1380057198.git.tim.c.chen@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 24 Sep 2013 15:22:26 -0700
Message-ID: <1380061346.3467.50.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Tim Chen <tim.c.chen@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>

Cmpxchg will cause the cacheline bouning when do the value checking,
that cause scalability issue in a large machine (like a 80 core box).

So a lock pre-read can relief this contention.

Signed-off-by: Alex Shi <alex.shi@intel.com>
---
 include/asm-generic/rwsem.h |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/asm-generic/rwsem.h b/include/asm-generic/rwsem.h
index bb1e2cd..5ba80e7 100644
--- a/include/asm-generic/rwsem.h
+++ b/include/asm-generic/rwsem.h
@@ -70,11 +70,11 @@ static inline void __down_write(struct rw_semaphore *sem)
 
 static inline int __down_write_trylock(struct rw_semaphore *sem)
 {
-	long tmp;
+	if (unlikely(sem->count != RWSEM_UNLOCKED_VALUE))
+		return 0;
 
-	tmp = cmpxchg(&sem->count, RWSEM_UNLOCKED_VALUE,
-		      RWSEM_ACTIVE_WRITE_BIAS);
-	return tmp == RWSEM_UNLOCKED_VALUE;
+	return cmpxchg(&sem->count, RWSEM_UNLOCKED_VALUE,
+		      RWSEM_ACTIVE_WRITE_BIAS) == RWSEM_UNLOCKED_VALUE;
 }
 
 /*
-- 
1.7.4.4



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
