Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id 526AA6B0260
	for <linux-mm@kvack.org>; Wed, 30 Dec 2015 01:33:56 -0500 (EST)
Received: by mail-ig0-f182.google.com with SMTP id to18so163053092igc.0
        for <linux-mm@kvack.org>; Tue, 29 Dec 2015 22:33:56 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id o81si17293330ioe.92.2015.12.29.22.33.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 29 Dec 2015 22:33:55 -0800 (PST)
Subject: [RFC][PATCH] sysrq: ensure manual invocation of the OOM killer under OOM livelock
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-Id: <201512301533.JDJ18237.QOFOMVSFtHOJLF@I-love.SAKURA.ne.jp>
Date: Wed, 30 Dec 2015 15:33:47 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, akpm@linux-foundation.org
Cc: mgorman@suse.de, rientjes@google.com, torvalds@linux-foundation.org, oleg@redhat.com, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

>From 7fcac2054b33dc3df6c5915a58f232b9b80bb1e6 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Wed, 30 Dec 2015 15:24:40 +0900
Subject: [RFC][PATCH] sysrq: ensure manual invocation of the OOM killer under OOM livelock

This patch is similar to what commit 373ccbe5927034b5 ("mm, vmstat:
allow WQ concurrency to discover memory reclaim doesn't make any
progress") does, but this patch is for SysRq-f.

SysRq-f is a method for reclaiming memory by manually invoking the OOM
killer. Therefore, it needs to be invokable even when the system is
looping under OOM livelock condition.

While making sure that we give workqueue items a chance to run is
done by "mm,oom: Always sleep before retrying." patch, allocating
a dedicated workqueue only for SysRq-f might be too wasteful when
there is the OOM reaper kernel thread which will be idle when
we need to use SysRq-f due to OOM livelock condition.

I wish for a kernel thread that does OOM-kill operation.
Maybe we can change the OOM reaper kernel thread to do it.
What do you think?

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 drivers/tty/sysrq.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/tty/sysrq.c b/drivers/tty/sysrq.c
index e513940..55407c9 100644
--- a/drivers/tty/sysrq.c
+++ b/drivers/tty/sysrq.c
@@ -373,11 +373,12 @@ static void moom_callback(struct work_struct *ignored)
 	mutex_unlock(&oom_lock);
 }
 
+static struct workqueue_struct *sysrq_moom_wq;
 static DECLARE_WORK(moom_work, moom_callback);
 
 static void sysrq_handle_moom(int key)
 {
-	schedule_work(&moom_work);
+	queue_work(sysrq_moom_wq, &moom_work);
 }
 static struct sysrq_key_op sysrq_moom_op = {
 	.handler	= sysrq_handle_moom,
@@ -1123,6 +1124,7 @@ static inline void sysrq_init_procfs(void)
 static int __init sysrq_init(void)
 {
 	sysrq_init_procfs();
+	sysrq_moom_wq = alloc_workqueue("sysrq", WQ_FREEZABLE|WQ_MEM_RECLAIM, 0);
 
 	if (sysrq_on())
 		sysrq_register_handler();
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
