Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2B7406B0009
	for <linux-mm@kvack.org>; Fri, 13 Apr 2018 08:47:40 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id e82so1240890wmc.3
        for <linux-mm@kvack.org>; Fri, 13 Apr 2018 05:47:40 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 35si5184135edp.28.2018.04.13.05.47.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 13 Apr 2018 05:47:38 -0700 (PDT)
From: Petr Mladek <pmladek@suse.com>
Subject: [PATCH] printk: Ratelimit messages printed by console drivers
Date: Fri, 13 Apr 2018 14:47:04 +0200
Message-Id: <20180413124704.19335-1-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Tejun Heo <tj@kernel.org>, linux-kernel@vger.kernel.org, Petr Mladek <pmladek@suse.com>

Error messages printed by console drivers might cause an infinite loop.
In particular, writing a message might produce another message that
need to be written, etc.

The obvious solution is to remove these messages. But there many
non-trivial console drivers. Also showing printk() messages is not
the only task of these drivers. Finally, the messages might come
from the timer, allocator, locking, or any other generic code.
As a result it is hard to catch all the problems. Not to say
that it is hard to be aware of problems and debug them without
the messages.

This patch rate-limits messages printed by console drivers from
console_unlock(). The decision is done in vprintk_func() that already
modifies printk() behavior according to the context. It uses the existing
console_owner variable to detect the context where console drivers are
called.

The burst limit is set to 100 lines so that it allows to see WARN(),
lockdep or other similar messages. The exact number is inspired by
printk_limits used by btrfs_printk().

The interval is set to one hour. It is rather arbitrary selected time.
It is supposed to be a compromise between never print these messages,
do not lockup the machine, do not fill the entire buffer too quickly,
and get information if something changes over time.

The important thing is to break a potential infinite loop. Both printk
and consoles need to get calm. This is not that easy because the messages
printed by console drivers are stored into a printk_safe buffers. They
are flushed later from IRQ context using printk_deferred(). It means
that they are flushed to the console even later by another IRQ.
Therefore there might be ping-pong scenario where flushing printk_safe
buffers wakes consoles that would fill the buffer again, etc.

Signed-off-by: Petr Mladek <pmladek@suse.com>
---
 kernel/printk/internal.h    | 1 +
 kernel/printk/printk.c      | 2 +-
 kernel/printk/printk_safe.c | 7 +++++++
 3 files changed, 9 insertions(+), 1 deletion(-)

diff --git a/kernel/printk/internal.h b/kernel/printk/internal.h
index 2a7d04049af4..1633ccbd774c 100644
--- a/kernel/printk/internal.h
+++ b/kernel/printk/internal.h
@@ -23,6 +23,7 @@
 #define PRINTK_NMI_CONTEXT_MASK		 0x80000000
 
 extern raw_spinlock_t logbuf_lock;
+extern struct task_struct *console_owner;
 
 __printf(1, 0) int vprintk_default(const char *fmt, va_list args);
 __printf(1, 0) int vprintk_deferred(const char *fmt, va_list args);
diff --git a/kernel/printk/printk.c b/kernel/printk/printk.c
index 2f4af216bd6e..26f45c03d245 100644
--- a/kernel/printk/printk.c
+++ b/kernel/printk/printk.c
@@ -1559,7 +1559,7 @@ static struct lockdep_map console_owner_dep_map = {
 #endif
 
 static DEFINE_RAW_SPINLOCK(console_owner_lock);
-static struct task_struct *console_owner;
+struct task_struct *console_owner;
 static bool console_waiter;
 
 /**
diff --git a/kernel/printk/printk_safe.c b/kernel/printk/printk_safe.c
index 3e3c2004bb23..201913ae9c40 100644
--- a/kernel/printk/printk_safe.c
+++ b/kernel/printk/printk_safe.c
@@ -21,6 +21,7 @@
 #include <linux/smp.h>
 #include <linux/cpumask.h>
 #include <linux/irq_work.h>
+#include <linux/ratelimit.h>
 #include <linux/printk.h>
 
 #include "internal.h"
@@ -360,10 +361,16 @@ void __printk_safe_exit(void)
 
 __printf(1, 0) int vprintk_func(const char *fmt, va_list args)
 {
+	static DEFINE_RATELIMIT_STATE(ratelimit_console, 60 * 60 * HZ, 100);
+
 	/* Use extra buffer in NMI when logbuf_lock is taken or in safe mode. */
 	if (this_cpu_read(printk_context) & PRINTK_NMI_CONTEXT_MASK)
 		return vprintk_nmi(fmt, args);
 
+	/* Prevent infinite loop caused by messages from console drivers. */
+	if (console_owner == current && !__ratelimit(&ratelimit_console))
+		return 0;
+
 	/* Use extra buffer to prevent a recursion deadlock in safe mode. */
 	if (this_cpu_read(printk_context) & PRINTK_SAFE_CONTEXT_MASK)
 		return vprintk_safe(fmt, args);
-- 
2.13.6
