Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id CEFF86B0255
	for <linux-mm@kvack.org>; Tue,  1 Mar 2016 14:55:29 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id bj10so48812147pad.2
        for <linux-mm@kvack.org>; Tue, 01 Mar 2016 11:55:29 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id qc8si13206658pac.39.2016.03.01.11.55.28
        for <linux-mm@kvack.org>;
        Tue, 01 Mar 2016 11:55:28 -0800 (PST)
Subject: [RFC PATCH] semaphore: fix uninitialized list_head vs
 list_force_poison
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 01 Mar 2016 11:55:04 -0800
Message-ID: <20160301195504.40400.79558.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Eryu Guan <eguan@redhat.com>, Peter Zijlstra <peterz@infradead.org>, xfs@oss.sgi.com, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, akpm@linux-foundation.org

list_force_poison is a debug mechanism to make sure that ZONE_DEVICE
pages never appear on an lru.  Those pages only exist for enabling DMA
to device discovered memory ranges and are not suitable for general
purpose allocations.  list_force_poison() explicitly initializes a
list_head with a poison value that list_add() can use to detect mistaken
use of page->lru.

Unfortunately, it seems calling list_add() leads to the poison value
leaking on to the stack and occasionally cause stack-allocated
list_heads to be inadvertently "force poisoned".

 list_add attempted on force-poisoned entry
 WARNING: at lib/list_debug.c:34
 [..]
 NIP [c00000000043c390] __list_add+0xb0/0x150
 LR [c00000000043c38c] __list_add+0xac/0x150
 Call Trace:
 [c000000fb5fc3320] [c00000000043c38c] __list_add+0xac/0x150 (unreliable)
 [c000000fb5fc33a0] [c00000000081b454] __down+0x4c/0xf8
 [c000000fb5fc3410] [c00000000010b6f8] down+0x68/0x70
 [c000000fb5fc3450] [d0000000201ebf4c] xfs_buf_lock+0x4c/0x150 [xfs]

 list_add attempted on force-poisoned entry(0000000000000500),
  new->next == d0000000059ecdb0, new->prev == 0000000000000500
 WARNING: at lib/list_debug.c:33
 [..]
 NIP [c00000000042db78] __list_add+0xa8/0x140
 LR [c00000000042db74] __list_add+0xa4/0x140
 Call Trace:
 [c0000004c749f620] [c00000000042db74] __list_add+0xa4/0x140 (unreliable)
 [c0000004c749f6b0] [c0000000008010ec] rwsem_down_read_failed+0x6c/0x1a0
 [c0000004c749f760] [c000000000800828] down_read+0x58/0x60
 [c0000004c749f7e0] [d000000005a1a6bc] xfs_log_commit_cil+0x7c/0x600 [xfs]

We can squash these uninitialized list_heads as they pop-up as this
patch does, or maybe need to rethink how to implement the
list_force_poison() safety mechanism.

Reported-by: Eryu Guan <eguan@redhat.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: <xfs@oss.sgi.com>
Fixes: commit 5c2c2587b132 ("mm, dax, pmem: introduce {get|put}_dev_pagemap() for dax-gup")
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 kernel/locking/rwsem-xadd.c |    4 +++-
 kernel/locking/semaphore.c  |    4 +++-
 2 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/kernel/locking/rwsem-xadd.c b/kernel/locking/rwsem-xadd.c
index a4d4de05b2d1..68678a20da52 100644
--- a/kernel/locking/rwsem-xadd.c
+++ b/kernel/locking/rwsem-xadd.c
@@ -214,8 +214,10 @@ __visible
 struct rw_semaphore __sched *rwsem_down_read_failed(struct rw_semaphore *sem)
 {
 	long count, adjustment = -RWSEM_ACTIVE_READ_BIAS;
-	struct rwsem_waiter waiter;
 	struct task_struct *tsk = current;
+	struct rwsem_waiter waiter = {
+		.list = LIST_HEAD_INIT(waiter.list),
+	};
 
 	/* set up my own style of waitqueue */
 	waiter.task = tsk;
diff --git a/kernel/locking/semaphore.c b/kernel/locking/semaphore.c
index b8120abe594b..39929b4e6fbb 100644
--- a/kernel/locking/semaphore.c
+++ b/kernel/locking/semaphore.c
@@ -205,7 +205,9 @@ static inline int __sched __down_common(struct semaphore *sem, long state,
 								long timeout)
 {
 	struct task_struct *task = current;
-	struct semaphore_waiter waiter;
+	struct semaphore_waiter waiter = {
+		.list = LIST_HEAD_INIT(waiter.list),
+	};
 
 	list_add_tail(&waiter.list, &sem->wait_list);
 	waiter.task = task;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
