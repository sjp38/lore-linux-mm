Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 43D436B1B92
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 13:57:00 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id k66so71416494qkf.1
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 10:57:00 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t22si474853qtq.46.2018.11.19.10.56.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Nov 2018 10:56:59 -0800 (PST)
From: Waiman Long <longman@redhat.com>
Subject: [PATCH v2 05/17] printk: Mark logbuf_lock & console_owner_lock as terminal locks
Date: Mon, 19 Nov 2018 13:55:14 -0500
Message-Id: <1542653726-5655-6-git-send-email-longman@redhat.com>
In-Reply-To: <1542653726-5655-1-git-send-email-longman@redhat.com>
References: <1542653726-5655-1-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>
Cc: linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Waiman Long <longman@redhat.com>

By marking logbuf_lock and console_owner_lock as terminal locks,
it reduces the performance overhead when those locks are used with
lockdep enabled.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 kernel/printk/printk.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/kernel/printk/printk.c b/kernel/printk/printk.c
index 1b2a029..bdbbe31 100644
--- a/kernel/printk/printk.c
+++ b/kernel/printk/printk.c
@@ -367,7 +367,7 @@ __packed __aligned(4)
  * within the scheduler's rq lock. It must be released before calling
  * console_unlock() or anything else that might wake up a process.
  */
-DEFINE_RAW_SPINLOCK(logbuf_lock);
+DEFINE_RAW_TERMINAL_SPINLOCK(logbuf_lock);
 
 /*
  * Helper macros to lock/unlock logbuf_lock and switch between
@@ -1568,7 +1568,7 @@ int do_syslog(int type, char __user *buf, int len, int source)
 };
 #endif
 
-static DEFINE_RAW_SPINLOCK(console_owner_lock);
+static DEFINE_RAW_TERMINAL_SPINLOCK(console_owner_lock);
 static struct task_struct *console_owner;
 static bool console_waiter;
 
-- 
1.8.3.1
