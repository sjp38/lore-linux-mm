Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 71C2B6B0660
	for <linux-mm@kvack.org>; Thu,  8 Nov 2018 15:36:35 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id l7-v6so41367234qkd.5
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 12:36:35 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g1si3734398qtq.235.2018.11.08.12.36.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Nov 2018 12:36:34 -0800 (PST)
From: Waiman Long <longman@redhat.com>
Subject: [RFC PATCH 12/12] mm/kasan: Make quarantine_lock a terminal lock
Date: Thu,  8 Nov 2018 15:34:28 -0500
Message-Id: <1541709268-3766-13-git-send-email-longman@redhat.com>
In-Reply-To: <1541709268-3766-1-git-send-email-longman@redhat.com>
References: <1541709268-3766-1-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>
Cc: linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Waiman Long <longman@redhat.com>

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
