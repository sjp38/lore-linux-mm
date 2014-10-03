Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f46.google.com (mail-qa0-f46.google.com [209.85.216.46])
	by kanga.kvack.org (Postfix) with ESMTP id 2CE636B0078
	for <linux-mm@kvack.org>; Fri,  3 Oct 2014 13:08:53 -0400 (EDT)
Received: by mail-qa0-f46.google.com with SMTP id w8so1118376qac.5
        for <linux-mm@kvack.org>; Fri, 03 Oct 2014 10:08:52 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k4si13249915qae.95.2014.10.03.10.08.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Oct 2014 10:08:47 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 13/17] waitqueue: add nr wake parameter to __wake_up_locked_key
Date: Fri,  3 Oct 2014 19:08:03 +0200
Message-Id: <1412356087-16115-14-git-send-email-aarcange@redhat.com>
In-Reply-To: <1412356087-16115-1-git-send-email-aarcange@redhat.com>
References: <1412356087-16115-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andres Lagar-Cavilla <andreslc@google.com>, Dave Hansen <dave@sr71.net>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "\\\"Dr. David Alan Gilbert\\\"" <dgilbert@redhat.com>, Christopher Covington <cov@codeaurora.org>, Johannes Weiner <hannes@cmpxchg.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, Keith Packard <keithp@keithp.com>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Isaku Yamahata <yamahata@valinux.co.jp>, Anthony Liguori <anthony@codemonkey.ws>, Stefan Hajnoczi <stefanha@gmail.com>, Wenchao Xia <wenchaoqemu@gmail.com>, Andrew Jones <drjones@redhat.com>, Juan Quintela <quintela@redhat.com>

Userfaultfd needs to wake all waitqueues (pass 0 as nr parameter),
instead of the current hardcoded 1 (that would wake just the first
waitqueue in the head list).

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 include/linux/wait.h | 5 +++--
 kernel/sched/wait.c  | 7 ++++---
 net/sunrpc/sched.c   | 2 +-
 3 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/include/linux/wait.h b/include/linux/wait.h
index 6fb1ba5..f8271cb 100644
--- a/include/linux/wait.h
+++ b/include/linux/wait.h
@@ -144,7 +144,8 @@ __remove_wait_queue(wait_queue_head_t *head, wait_queue_t *old)
 
 typedef int wait_bit_action_f(struct wait_bit_key *);
 void __wake_up(wait_queue_head_t *q, unsigned int mode, int nr, void *key);
-void __wake_up_locked_key(wait_queue_head_t *q, unsigned int mode, void *key);
+void __wake_up_locked_key(wait_queue_head_t *q, unsigned int mode, int nr,
+			  void *key);
 void __wake_up_sync_key(wait_queue_head_t *q, unsigned int mode, int nr, void *key);
 void __wake_up_locked(wait_queue_head_t *q, unsigned int mode, int nr);
 void __wake_up_sync(wait_queue_head_t *q, unsigned int mode, int nr);
@@ -175,7 +176,7 @@ wait_queue_head_t *bit_waitqueue(void *, int);
 #define wake_up_poll(x, m)						\
 	__wake_up(x, TASK_NORMAL, 1, (void *) (m))
 #define wake_up_locked_poll(x, m)					\
-	__wake_up_locked_key((x), TASK_NORMAL, (void *) (m))
+	__wake_up_locked_key((x), TASK_NORMAL, 1, (void *) (m))
 #define wake_up_interruptible_poll(x, m)				\
 	__wake_up(x, TASK_INTERRUPTIBLE, 1, (void *) (m))
 #define wake_up_interruptible_sync_poll(x, m)				\
diff --git a/kernel/sched/wait.c b/kernel/sched/wait.c
index 15cab1a..d848738 100644
--- a/kernel/sched/wait.c
+++ b/kernel/sched/wait.c
@@ -105,9 +105,10 @@ void __wake_up_locked(wait_queue_head_t *q, unsigned int mode, int nr)
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
 
@@ -282,7 +283,7 @@ void abort_exclusive_wait(wait_queue_head_t *q, wait_queue_t *wait,
 	if (!list_empty(&wait->task_list))
 		list_del_init(&wait->task_list);
 	else if (waitqueue_active(q))
-		__wake_up_locked_key(q, mode, key);
+		__wake_up_locked_key(q, mode, 1, key);
 	spin_unlock_irqrestore(&q->lock, flags);
 }
 EXPORT_SYMBOL(abort_exclusive_wait);
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 9358c79..39b7496 100644
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
