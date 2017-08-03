Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5360D6B066B
	for <linux-mm@kvack.org>; Thu,  3 Aug 2017 03:47:57 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id j83so6048946pfe.10
        for <linux-mm@kvack.org>; Thu, 03 Aug 2017 00:47:57 -0700 (PDT)
Received: from zte.com.cn (mxhk.zte.com.cn. [63.217.80.70])
        by mx.google.com with ESMTP id i1si9904409plk.597.2017.08.03.00.47.55
        for <linux-mm@kvack.org>;
        Thu, 03 Aug 2017 00:47:56 -0700 (PDT)
From: Wen Yang <wen.yang99@zte.com.cn>
Subject: [PATCH] mm/vmstat: fix divide error at __fragmentation_index
Date: Thu, 3 Aug 2017 15:59:41 +0800
Message-Id: <1501747181-30322-1-git-send-email-wen.yang99@zte.com.cn>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, mhocko@suse.com, vbabka@suse.cz, kirill.shutemov@linux.intel.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, wen.yang99@zte.com.cn, jiang.biao2@zte.com.cn

From: Jiang Biao <jiang.biao2@zte.com.cn>

When order is -1 or too big, *1UL << order* will be 0, which will
cause divide error like this,

    divide error: 0000 [#1] SMP
    Call Trace:
     [<ffffffff81168423>] compaction_suitable+0x63/0xc0
     [<ffffffff81168a75>] compact_zone+0x35/0x950
     [<ffffffff811745b5>] ? free_percpu+0xb5/0x140
     [<ffffffff81092b23>] ? schedule_on_each_cpu+0x133/0x160
     [<ffffffff8116949c>] compact_node+0x10c/0x120
     [<ffffffff8116953c>] sysctl_compaction_handler+0x5c/0x90
     [<ffffffff811fa517>] proc_sys_call_handler+0x97/0xd0
     [<ffffffff811fa564>] proc_sys_write+0x14/0x20
     [<ffffffff81187368>] vfs_write+0xb8/0x1a0
     [<ffffffff81187c61>] sys_write+0x51/0x90
     [<ffffffff8100b052>] system_call_fastpath+0x16/0x1b

Signed-off-by: Wen Yang <wen.yang99@zte.com.cn>
Reviewed-by: Jiang Biao <jiang.biao2@zte.com.cn>
---
 mm/vmstat.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/vmstat.c b/mm/vmstat.c
index 76f7367..2f9d012 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -870,6 +870,9 @@ static int __fragmentation_index(unsigned int order, struct contig_page_info *in
 {
 	unsigned long requested = 1UL << order;
 
+        if (!requested)
+                return 0;
+
 	if (!info->free_blocks_total)
 		return 0;
 
-- 
2.7.4


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
