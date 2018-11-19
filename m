Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 955936B1BF3
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 13:57:43 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id c7so70780625qkg.16
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 10:57:43 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l49si2793755qvc.80.2018.11.19.10.57.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Nov 2018 10:57:42 -0800 (PST)
From: Waiman Long <longman@redhat.com>
Subject: [PATCH v2 13/17] mm/kasan: Make quarantine_lock a terminal lock
Date: Mon, 19 Nov 2018 13:55:22 -0500
Message-Id: <1542653726-5655-14-git-send-email-longman@redhat.com>
In-Reply-To: <1542653726-5655-1-git-send-email-longman@redhat.com>
References: <1542653726-5655-1-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>
Cc: linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Waiman Long <longman@redhat.com>

By making quarantine_lock a terminal spinlock, it reduces the lockdep
overhead when this lock is being used.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 mm/kasan/quarantine.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/kasan/quarantine.c b/mm/kasan/quarantine.c
index b209dba..c9d36ab 100644
--- a/mm/kasan/quarantine.c
+++ b/mm/kasan/quarantine.c
@@ -103,7 +103,7 @@ static void qlist_move_all(struct qlist_head *from, struct qlist_head *to)
 static int quarantine_tail;
 /* Total size of all objects in global_quarantine across all batches. */
 static unsigned long quarantine_size;
-static DEFINE_RAW_SPINLOCK(quarantine_lock);
+static DEFINE_RAW_TERMINAL_SPINLOCK(quarantine_lock);
 DEFINE_STATIC_SRCU(remove_cache_srcu);
 
 /* Maximum size of the global queue. */
-- 
1.8.3.1
