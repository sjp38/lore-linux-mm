Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6E7646B065E
	for <linux-mm@kvack.org>; Thu,  8 Nov 2018 15:36:33 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id g22so6988740qke.15
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 12:36:33 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u35-v6si188952qth.262.2018.11.08.12.36.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Nov 2018 12:36:32 -0800 (PST)
From: Waiman Long <longman@redhat.com>
Subject: [RFC PATCH 11/12] cgroup: Mark the rstat percpu lock as terminal
Date: Thu,  8 Nov 2018 15:34:27 -0500
Message-Id: <1541709268-3766-12-git-send-email-longman@redhat.com>
In-Reply-To: <1541709268-3766-1-git-send-email-longman@redhat.com>
References: <1541709268-3766-1-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>
Cc: linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Waiman Long <longman@redhat.com>

By classifying the cgroup rstat percpu locks as terminal locks, it
reduces the lockdep overhead when these locks are being used.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 kernel/cgroup/rstat.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/kernel/cgroup/rstat.c b/kernel/cgroup/rstat.c
index d503d1a..47f7ffb 100644
--- a/kernel/cgroup/rstat.c
+++ b/kernel/cgroup/rstat.c
@@ -291,8 +291,13 @@ void __init cgroup_rstat_boot(void)
 {
 	int cpu;
 
-	for_each_possible_cpu(cpu)
-		raw_spin_lock_init(per_cpu_ptr(&cgroup_rstat_cpu_lock, cpu));
+	for_each_possible_cpu(cpu) {
+		raw_spinlock_t *cgroup_rstat_percpu_lock =
+				per_cpu_ptr(&cgroup_rstat_cpu_lock, cpu);
+
+		raw_spin_lock_init(cgroup_rstat_percpu_lock);
+		lockdep_set_terminal_class(cgroup_rstat_percpu_lock);
+	}
 
 	BUG_ON(cgroup_rstat_init(&cgrp_dfl_root.cgrp));
 }
-- 
1.8.3.1
