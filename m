Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0B3256B0003
	for <linux-mm@kvack.org>; Tue, 27 Mar 2018 06:42:14 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id z5-v6so6867160plo.21
        for <linux-mm@kvack.org>; Tue, 27 Mar 2018 03:42:14 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id 3-v6si1018365plo.475.2018.03.27.03.42.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Mar 2018 03:42:12 -0700 (PDT)
Subject: [PATCH v2] lockdep: Show address of "struct lockdep_map" at print_lock().
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1522059513-5461-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20180326160549.GL4043@hirez.programming.kicks-ass.net>
	<201803270558.HCA41032.tVFJOFOMOFLHSQ@I-love.SAKURA.ne.jp>
In-Reply-To: <201803270558.HCA41032.tVFJOFOMOFLHSQ@I-love.SAKURA.ne.jp>
Message-Id: <201803271941.GBE57310.tVSOJLQOFFOHFM@I-love.SAKURA.ne.jp>
Date: Tue, 27 Mar 2018 19:41:41 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mhocko@suse.com
Cc: mingo@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, bp@suse.de, rientjes@google.com, tglx@linutronix.de

>From 91c081c4c5f6a99402542951e7de661c38f928ab Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Tue, 27 Mar 2018 19:38:33 +0900
Subject: [PATCH v2] lockdep: Show address of "struct lockdep_map" at print_lock().

Since "struct lockdep_map" is embedded into lock objects, we can know
which instance of a lock object is acquired using hlock->instance field.
This will help finding which threads are causing a lock contention.

Currently, print_lock() is printing hlock->acquire_ip field in both
"[<%px>]" and "%pS" format. But "[<%px>]" is little useful nowadays, for
we use scripts/faddr2line which receives "%pS" for finding the location
in the source code. And I want to reduce amount of output, for
debug_show_all_locks() might print a lot.

Therefore, this patch replaces "[<%px>]" for printing hlock->acquire_ip
field with "%p" for printing hlock->instance field.

[  251.305475] 3 locks held by a.out/31106:
[  251.308949]  #0: 00000000b0f753ba (&mm->mmap_sem){++++}, at: copy_process.part.41+0x10d5/0x1fe0
[  251.314283]  #1: 00000000ef64d539 (&mm->mmap_sem/1){+.+.}, at: copy_process.part.41+0x10fe/0x1fe0
[  251.319618]  #2: 00000000b41a282e (&mapping->i_mmap_rwsem){++++}, at: copy_process.part.41+0x12f2/0x1fe0

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Borislav Petkov <bp@suse.de>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: David Rientjes <rientjes@google.com>
Cc: Michal Hocko <mhocko@suse.com>
---
 kernel/locking/lockdep.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/kernel/locking/lockdep.c b/kernel/locking/lockdep.c
index 12a2805..0233863 100644
--- a/kernel/locking/lockdep.c
+++ b/kernel/locking/lockdep.c
@@ -556,9 +556,9 @@ static void print_lock(struct held_lock *hlock)
 		return;
 	}
 
+	printk(KERN_CONT "%p", hlock->instance);
 	print_lock_name(lock_classes + class_idx - 1);
-	printk(KERN_CONT ", at: [<%px>] %pS\n",
-		(void *)hlock->acquire_ip, (void *)hlock->acquire_ip);
+	printk(KERN_CONT ", at: %pS\n", (void *)hlock->acquire_ip);
 }
 
 static void lockdep_print_held_locks(struct task_struct *curr)
-- 
1.8.3.1
