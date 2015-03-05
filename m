Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f43.google.com (mail-qg0-f43.google.com [209.85.192.43])
	by kanga.kvack.org (Postfix) with ESMTP id 71B976B0070
	for <linux-mm@kvack.org>; Thu,  5 Mar 2015 12:19:10 -0500 (EST)
Received: by qgfh3 with SMTP id h3so6301572qgf.2
        for <linux-mm@kvack.org>; Thu, 05 Mar 2015 09:19:10 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x77si4769802qkx.90.2015.03.05.09.19.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Mar 2015 09:19:05 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 01/21] userfaultfd: waitqueue: add nr wake parameter to __wake_up_locked_key
Date: Thu,  5 Mar 2015 18:17:44 +0100
Message-Id: <1425575884-2574-2-git-send-email-aarcange@redhat.com>
In-Reply-To: <1425575884-2574-1-git-send-email-aarcange@redhat.com>
References: <1425575884-2574-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Android Kernel Team <kernel-team@android.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Pavel Emelyanov <xemul@parallels.com>, Sanidhya Kashyap <sanidhya.gatech@gmail.com>, zhang.zhanghailiang@huawei.com, Linus Torvalds <torvalds@linux-foundation.org>, Andres Lagar-Cavilla <andreslc@google.com>, Dave Hansen <dave@sr71.net>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Christopher Covington <cov@codeaurora.org>, Johannes Weiner <hannes@cmpxchg.org>, Robert Love <rlove@google.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, Keith Packard <keithp@keithp.com>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Anthony Liguori <anthony@codemonkey.ws>, Stefan Hajnoczi <stefanha@gmail.com>, Wenchao Xia <wenchaoqemu@gmail.com>, Andrew Jones <drjones@redhat.com>, Juan Quintela <quintela@redhat.com>

userfaultfd needs to wake all waitqueues (pass 0 as nr parameter),
instead of the current hardcoded 1 (that would wake just the first
waitqueue in the head list).

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 include/linux/wait.h | 5 +++--
 kernel/sched/wait.c  | 7 ++++---
 net/sunrpc/sched.c   | 2 +-
 3 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/include/linux/wait.h b/include/linux/wait.h
index 2db8334..cf884cf 100644
--- a/include/linux/wait.h
+++ b/include/linux/wait.h
@@ -147,7 +147,8 @@ __remove_wait_queue(wait_queue_head_t *head, wait_queue_t *old)
 
 typedef int wait_bit_action_f(struct wait_bit_key *);
 void __wake_up(wait_queue_head_t *q, unsigned int mode, int nr, void *key);
-void __wake_up_locked_key(wait_queue_head_t *q, unsigned int mode, void *key);
+void __wake_up_locked_key(wait_queue_head_t *q, unsigned int mode, int nr,
+			  void *key);
 void __wake_up_sync_key(wait_queue_head_t *q, unsigned int mode, int nr, void *key);
 void __wake_up_locked(wait_queue_head_t *q, unsigned int mode, int nr);
 void __wake_up_sync(wait_queue_head_t *q, unsigned int mode, int nr);
@@ -179,7 +180,7 @@ wait_queue_head_t *bit_waitqueue(void *, int);
 #define wake_up_poll(x, m)						\
 	__wake_up(x, TASK_NORMAL, 1, (void *) (m))
 #define wake_up_locked_poll(x, m)					\
-	__wake_up_locked_key((x), TASK_NORMAL, (void *) (m))
+	__wake_up_locked_key((x), TASK_NORMAL, 1, (void *) (m))
 #define wake_up_interruptible_poll(x, m)				\
 	__wake_up(x, TASK_INTERRUPTIBLE, 1, (void *) (m))
 #define wake_up_interruptible_sync_poll(x, m)				\
diff --git a/kernel/sched/wait.c b/kernel/sched/wait.c
index 852143a..6da208dd2 100644
--- a/kernel/sched/wait.c
+++ b/kernel/sched/wait.c
@@ -106,9 +106,10 @@ void __wake_up_locked(wait_queue_head_t *q, unsigned int mode, int nr)
 }
 EXPORT_SYMBOL_GPL(__wake_up_locked);
 
-void __wake_up_locked_key(wait_queue_head_t *q, unsigned int mode, void *key)
+void __wake_up_locked_key(wait_queue_head_t *q, unsigned int mode, int nr,
+			  void *key)
 {
-	__wake_up_common(q, mode, 1, 0, key);
+	__wake_up_common(q, mode, nr, 0, key);
 }
 EXPORT_SYMBOL_GPL(__wake_up_locked_key);
 
@@ -283,7 +284,7 @@ void abort_exclusive_wait(wait_queue_head_t *q, wait_queue_t *wait,
 	if (!list_empty(&wait->task_list))
 		list_del_init(&wait->task_list);
 	else if (waitqueue_active(q))
-		__wake_up_locked_key(q, mode, key);
+		__wake_up_locked_key(q, mode, 1, key);
 	spin_unlock_irqrestore(&q->lock, flags);
 }
 EXPORT_SYMBOL(abort_exclusive_wait);
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index b91fd9c..dead9e0 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -297,7 +297,7 @@ static int rpc_complete_task(struct rpc_task *task)
 	clear_bit(RPC_TASK_ACTIVE, &task->tk_runstate);
 	ret = atomic_dec_and_test(&task->tk_count);
 	if (waitqueue_active(wq))
-		__wake_up_locked_key(wq, TASK_NORMAL, &k);
+		__wake_up_locked_key(wq, TASK_NORMAL, 1, &k);
 	spin_unlock_irqrestore(&wq->lock, flags);
 	return ret;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
