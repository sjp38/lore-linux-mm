Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id CA4EC6B0028
	for <linux-mm@kvack.org>; Mon, 12 Mar 2018 15:23:25 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id c41-v6so8224688plj.10
        for <linux-mm@kvack.org>; Mon, 12 Mar 2018 12:23:25 -0700 (PDT)
Received: from NAM03-BY2-obe.outbound.protection.outlook.com (mail-by2nam03on0047.outbound.protection.outlook.com. [104.47.42.47])
        by mx.google.com with ESMTPS id v17si6161946pfe.186.2018.03.12.12.23.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 12 Mar 2018 12:23:24 -0700 (PDT)
From: "Steven J. Hill" <steven.hill@cavium.com>
Subject: [PATCH] mm/vmstat.c: Fix vmstat_update() preemption BUG.
Date: Mon, 12 Mar 2018 14:05:52 -0500
Message-Id: <1520881552-25659-1-git-send-email-steven.hill@cavium.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

Attempting to hotplug CPUs with CONFIG_VM_EVENT_COUNTERS enabled
can cause vmstat_update() to report a BUG due to preemption not
being disabled around smp_processor_id(). Discovered on Ubiquiti
EdgeRouter Pro with Cavium Octeon II processor.

BUG: using smp_processor_id() in preemptible [00000000] code:
kworker/1:1/269
caller is vmstat_update+0x50/0xa0
CPU: 0 PID: 269 Comm: kworker/1:1 Not tainted
4.16.0-rc4-Cavium-Octeon-00009-gf83bbd5-dirty #1
Workqueue: mm_percpu_wq vmstat_update
Stack : 0000002600000026 0000000010009ce0 0000000000000000 0000000000000001
        0000000000000000 0000000000000000 0000000000000005 8001180000000800
        00000000000000bf 0000000000000000 00000000000000bf 766d737461745f75
        ffffffff83ad0000 0000000000000007 0000000000000000 0000000008000000
        0000000000000000 ffffffff818d0000 0000000000000001 ffffffff81818a70
        0000000000000000 0000000000000000 ffffffff8115bbb0 ffffffff818a0000
        0000000000000005 ffffffff8144dc50 0000000000000000 0000000000000000
        8000000088980000 8000000088983b30 0000000000000088 ffffffff813d3054
        0000000000000000 ffffffff83ace622 00000000000000be 0000000000000000
        00000000000000be ffffffff81121fb4 0000000000000000 0000000000000000
        ...
Call Trace:
[<ffffffff81121fb4>] show_stack+0x94/0x128
[<ffffffff813d3054>] dump_stack+0xa4/0xe0
[<ffffffff813fcfb8>] check_preemption_disabled+0x118/0x120
[<ffffffff811eafd8>] vmstat_update+0x50/0xa0
[<ffffffff8115b954>] process_one_work+0x144/0x348
[<ffffffff8115bd00>] worker_thread+0x150/0x4b8
[<ffffffff811622a0>] kthread+0x110/0x140
[<ffffffff8111c304>] ret_from_kernel_thread+0x14/0x1c

Signed-off-by: Steven J. Hill <steven.hill@cavium.com>
---
 mm/vmstat.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/vmstat.c b/mm/vmstat.c
index 40b2db6..33581be 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1839,9 +1839,11 @@ static void vmstat_update(struct work_struct *w)
 		 * to occur in the future. Keep on running the
 		 * update worker thread.
 		 */
+		preempt_disable();
 		queue_delayed_work_on(smp_processor_id(), mm_percpu_wq,
 				this_cpu_ptr(&vmstat_work),
 				round_jiffies_relative(sysctl_stat_interval));
+		preempt_enable();
 	}
 }
 
-- 
2.1.4
