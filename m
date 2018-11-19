Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6592A6B1BF0
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 13:57:37 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id j125so4417281qke.12
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 10:57:37 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y36si130100qtd.218.2018.11.19.10.57.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Nov 2018 10:57:36 -0800 (PST)
From: Waiman Long <longman@redhat.com>
Subject: [PATCH v2 09/17] debugobjects: Make object hash locks nestable terminal locks
Date: Mon, 19 Nov 2018 13:55:18 -0500
Message-Id: <1542653726-5655-10-git-send-email-longman@redhat.com>
In-Reply-To: <1542653726-5655-1-git-send-email-longman@redhat.com>
References: <1542653726-5655-1-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>
Cc: linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Waiman Long <longman@redhat.com>

By making the object hash locks nestable terminal locks, we can avoid
a bunch of unnecessary lockdep validations as well as saving space
in the lockdep tables.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 lib/debugobjects.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/lib/debugobjects.c b/lib/debugobjects.c
index 4216d3d..c6f3967 100644
--- a/lib/debugobjects.c
+++ b/lib/debugobjects.c
@@ -1129,8 +1129,13 @@ void __init debug_objects_early_init(void)
 {
 	int i;
 
-	for (i = 0; i < ODEBUG_HASH_SIZE; i++)
+	/*
+	 * Make the obj_hash locks nestable terminal locks.
+	 */
+	for (i = 0; i < ODEBUG_HASH_SIZE; i++) {
 		raw_spin_lock_init(&obj_hash[i].lock);
+		lockdep_set_terminal_nestable_class(&obj_hash[i].lock);
+	}
 
 	for (i = 0; i < ODEBUG_POOL_SIZE; i++)
 		hlist_add_head(&obj_static_pool[i].node, &obj_pool);
-- 
1.8.3.1
