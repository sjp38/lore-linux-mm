Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8E0F46B0005
	for <linux-mm@kvack.org>; Mon, 29 Feb 2016 12:02:19 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id fl4so94996296pad.0
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 09:02:19 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id fl1si5330240pab.55.2016.02.29.09.02.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Feb 2016 09:02:18 -0800 (PST)
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH] exit: clear TIF_MEMDIE after exit_task_work
Date: Mon, 29 Feb 2016 20:02:09 +0300
Message-ID: <1456765329-14890-1-git-send-email-vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

An mm_struct may be pinned by a file. An example is vhost-net device
created by a qemu/kvm (see vhost_net_ioctl -> vhost_net_set_owner ->
vhost_dev_set_owner). If such process gets OOM-killed, the reference to
its mm_struct will only be released from exit_task_work -> ____fput ->
__fput -> vhost_net_release -> vhost_dev_cleanup, which is called after
exit_mmap, where TIF_MEMDIE is cleared. As a result, we can start
selecting the next victim before giving the last one a chance to free
its memory. In practice, this leads to killing several VMs along with
the fattest one.

Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
---
 kernel/exit.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/kernel/exit.c b/kernel/exit.c
index fd90195667e1..cc50e12165f7 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -434,8 +434,6 @@ static void exit_mm(struct task_struct *tsk)
 	task_unlock(tsk);
 	mm_update_next_owner(mm);
 	mmput(mm);
-	if (test_thread_flag(TIF_MEMDIE))
-		exit_oom_victim(tsk);
 }
 
 static struct task_struct *find_alive_thread(struct task_struct *p)
@@ -746,6 +744,8 @@ void do_exit(long code)
 		disassociate_ctty(1);
 	exit_task_namespaces(tsk);
 	exit_task_work(tsk);
+	if (test_thread_flag(TIF_MEMDIE))
+		exit_oom_victim(tsk);
 	exit_thread();
 
 	/*
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
