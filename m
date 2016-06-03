Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 935D76B007E
	for <linux-mm@kvack.org>; Thu,  2 Jun 2016 21:32:18 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id g64so83551086pfb.2
        for <linux-mm@kvack.org>; Thu, 02 Jun 2016 18:32:18 -0700 (PDT)
Received: from smtpproxy19.qq.com (smtpproxy19.qq.com. [184.105.206.84])
        by mx.google.com with ESMTPS id vl8si2079959pab.245.2016.06.02.18.32.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 02 Jun 2016 18:32:17 -0700 (PDT)
From: Wang Sheng-Hui <shhuiw@foxmail.com>
Subject: [PATCH v2] mm: Introduce dedicated WQ_MEM_RECLAIM workqueue to do lru_add_drain_all
Date: Fri,  3 Jun 2016 09:32:01 +0800
Message-Id: <1464917521-9775-1-git-send-email-shhuiw@foxmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tj@kernel.org, keith.busch@intel.com, peterz@infradead.org
Cc: treding@nvidia.com, mingo@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org

This patch is based on https://patchwork.ozlabs.org/patch/574623/.

Tejun submitted commit 23d11a58a9a6 ("workqueue: skip flush dependency
checks for legacy workqueues") for the legacy create*_workqueue()
interface. But some workq created by alloc_workqueue still reports
warning on memory reclaim, e.g nvme_workq with flag WQ_MEM_RECLAIM set:

[    0.153902] workqueue: WQ_MEM_RECLAIM nvme:nvme_reset_work is
flushing !WQ_MEM_RECLAIM events:lru_add_drain_per_cpu
[    0.153907] ------------[ cut here ]------------
[    0.153912] WARNING: CPU: 0 PID: 6 at
SoC/linux/kernel/workqueue.c:2448
check_flush_dependency+0xb4/0x10c
...
[    0.154083] [<fffffc00080d6de0>] check_flush_dependency+0xb4/0x10c
[    0.154088] [<fffffc00080d8e80>] flush_work+0x54/0x140
[    0.154092] [<fffffc0008166a0c>] lru_add_drain_all+0x138/0x188
[    0.154097] [<fffffc00081ab2dc>] migrate_prep+0xc/0x18
[    0.154101] [<fffffc0008160e88>] alloc_contig_range+0xf4/0x350
[    0.154105] [<fffffc00081bcef8>] cma_alloc+0xec/0x1e4
[    0.154110] [<fffffc0008446ad0>] dma_alloc_from_contiguous+0x38/0x40
[    0.154114] [<fffffc00080a093c>] __dma_alloc+0x74/0x25c
[    0.154119] [<fffffc00084828d8>] nvme_alloc_queue+0xcc/0x36c
[    0.154123] [<fffffc0008484b2c>] nvme_reset_work+0x5c4/0xda8
[    0.154128] [<fffffc00080d9528>] process_one_work+0x128/0x2ec
[    0.154132] [<fffffc00080d9744>] worker_thread+0x58/0x434
[    0.154136] [<fffffc00080df0ec>] kthread+0xd4/0xe8
[    0.154141] [<fffffc0008093ac0>] ret_from_fork+0x10/0x50

That's because lru_add_drain_all() will schedule the drain work on
system_wq, whose flag is set to 0, !WQ_MEM_RECLAIM.

Introduce a dedicated WQ_MEM_RECLAIM workqueue to do lru_add_drain_all(),
aiding in getting memory freed.

Compared with v1:
	* The key flag is WQ_MEM_RECLAIM. Drop the flag WQ_UNBOUND.
	* Reserve the warn in lru_init as init code during bootup ignore
	  return code from early_initcall functions.
	* Instead of falling back to system_wq, crash directly if the wq
	  is used in lru_add_drain_all but was not created in lru_init
	  at init stage.

Signed-off-by: Wang Sheng-Hui <shhuiw@foxmail.com>
---
 mm/swap.c | 20 +++++++++++++++++++-
 1 file changed, 19 insertions(+), 1 deletion(-)

diff --git a/mm/swap.c b/mm/swap.c
index 9591614..59f5faf 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -667,6 +667,24 @@ static void lru_add_drain_per_cpu(struct work_struct *dummy)
 
 static DEFINE_PER_CPU(struct work_struct, lru_add_drain_work);
 
+/*
+ * lru_add_drain_wq is used to do lru_add_drain_all() from a WQ_MEM_RECLAIM
+ * workqueue, aiding in getting memory freed.
+ */
+static struct workqueue_struct *lru_add_drain_wq;
+
+static int __init lru_init(void)
+{
+	lru_add_drain_wq = alloc_workqueue("lru-add-drain", WQ_MEM_RECLAIM, 0);
+
+	if (WARN(!lru_add_drain_wq,
+		"Failed to create workqueue lru_add_drain_wq"))
+		return -ENOMEM;
+
+	return 0;
+}
+early_initcall(lru_init);
+
 void lru_add_drain_all(void)
 {
 	static DEFINE_MUTEX(lock);
@@ -686,7 +704,7 @@ void lru_add_drain_all(void)
 		    pagevec_count(&per_cpu(lru_deactivate_pvecs, cpu)) ||
 		    need_activate_page_drain(cpu)) {
 			INIT_WORK(work, lru_add_drain_per_cpu);
-			schedule_work_on(cpu, work);
+			queue_work_on(cpu, lru_add_drain_wq, work);
 			cpumask_set_cpu(cpu, &has_work);
 		}
 	}
-- 
2.7.4



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
