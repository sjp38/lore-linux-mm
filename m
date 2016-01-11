Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f178.google.com (mail-yk0-f178.google.com [209.85.160.178])
	by kanga.kvack.org (Postfix) with ESMTP id B062F828F3
	for <linux-mm@kvack.org>; Sun, 10 Jan 2016 19:44:09 -0500 (EST)
Received: by mail-yk0-f178.google.com with SMTP id a85so338311234ykb.1
        for <linux-mm@kvack.org>; Sun, 10 Jan 2016 16:44:09 -0800 (PST)
Received: from mail-yk0-x230.google.com (mail-yk0-x230.google.com. [2607:f8b0:4002:c07::230])
        by mx.google.com with ESMTPS id v66si21224508ywf.74.2016.01.10.16.44.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 10 Jan 2016 16:44:09 -0800 (PST)
Received: by mail-yk0-x230.google.com with SMTP id k129so393510674yke.0
        for <linux-mm@kvack.org>; Sun, 10 Jan 2016 16:44:08 -0800 (PST)
From: l@dorileo.org
Subject: [RFC][4.1.15-rt17 PATCH] mm: swap: lru drain don't use workqueue with PREEMPT_RT_FULL
Date: Sun, 10 Jan 2016 22:43:21 -0200
Message-Id: <1452473001-10518-1-git-send-email-l@dorileo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Cc: LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, rostedt@goodmis.org, John Kacur <jkacur@redhat.com>, linux-mm@kvack.org, Leandro Dorileo <leandro.maciel.dorileo@intel.com>

From: Leandro Dorileo <leandro.maciel.dorileo@intel.com>

Running a smp system with an -rt kernel, with CONFIG_PREEMPT_RT_FULL,
in a heavy cpu load scenario and an arbitrary process tries to mlockall
with MCL_CURRENT flag that process will block indefinitely - until the
process resulting in the heavy cpu load finishes(the process's set the
sched priority > 0).

Since MCL_CURRENT flag is passed to mlockall it will try to drain the
lru in all cpus. The lru_add_drain_all() will start an workqueue to
drain lru on each online cpu and then try to flush the work(will wait
until the work's finished).

The drain for the heavy loaded core will never finished - like
mentioned before - until the process resulting in the heavy cpu load
finishes. The work will never be scheduled, even if the calling process
has been so.

This patch adds an lru_add_drain_all() implementation for such
situation, and synchronously do the lru drain on behalf of the calling
process.

Signed-off-by: Leandro Dorileo <leandro.maciel.dorileo@intel.com>
---
 mm/swap.c | 18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff --git a/mm/swap.c b/mm/swap.c
index 1785ac6..df807b4 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -864,6 +864,23 @@ void lru_add_drain(void)
 	local_unlock_cpu(swapvec_lock);
 }
 
+#ifdef CONFIG_PREEMPT_RT_FULL
+void lru_add_drain_all(void)
+{
+	static DEFINE_MUTEX(lock);
+	int cpu;
+
+	mutex_lock(&lock);
+	get_online_cpus();
+
+	for_each_online_cpu(cpu) {
+		smp_call_function_single(cpu, lru_add_drain, NULL, 1);
+	}
+
+	put_online_cpus();
+	mutex_unlock(&lock);
+}
+#else
 static void lru_add_drain_per_cpu(struct work_struct *dummy)
 {
 	lru_add_drain();
@@ -900,6 +917,7 @@ void lru_add_drain_all(void)
 	put_online_cpus();
 	mutex_unlock(&lock);
 }
+#endif
 
 /**
  * release_pages - batched page_cache_release()
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
