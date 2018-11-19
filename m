Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 811286B1BF7
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 13:57:48 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id f22so69981425qkm.11
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 10:57:48 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o127si7092133qkd.13.2018.11.19.10.57.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Nov 2018 10:57:47 -0800 (PST)
From: Waiman Long <longman@redhat.com>
Subject: [PATCH v2 16/17] delay_acct: Mark task's delays->lock as terminal spinlock
Date: Mon, 19 Nov 2018 13:55:25 -0500
Message-Id: <1542653726-5655-17-git-send-email-longman@redhat.com>
In-Reply-To: <1542653726-5655-1-git-send-email-longman@redhat.com>
References: <1542653726-5655-1-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>
Cc: linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Waiman Long <longman@redhat.com>

By making task's delays->lock a terminal spinlock, it reduces the
lockdep overhead when this lock is used.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 kernel/delayacct.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/kernel/delayacct.c b/kernel/delayacct.c
index 2a12b98..49dd8d3 100644
--- a/kernel/delayacct.c
+++ b/kernel/delayacct.c
@@ -43,8 +43,10 @@ void delayacct_init(void)
 void __delayacct_tsk_init(struct task_struct *tsk)
 {
 	tsk->delays = kmem_cache_zalloc(delayacct_cache, GFP_KERNEL);
-	if (tsk->delays)
+	if (tsk->delays) {
 		raw_spin_lock_init(&tsk->delays->lock);
+		lockdep_set_terminal_class(&tsk->delays->lock);
+	}
 }
 
 /*
-- 
1.8.3.1
