Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id EB9B26B0542
	for <linux-mm@kvack.org>; Wed,  7 Nov 2018 14:16:56 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id n22-v6so16217371pff.2
        for <linux-mm@kvack.org>; Wed, 07 Nov 2018 11:16:56 -0800 (PST)
Received: from out30-132.freemail.mail.aliyun.com (out30-132.freemail.mail.aliyun.com. [115.124.30.132])
        by mx.google.com with ESMTPS id p14-v6si1403611plo.363.2018.11.07.11.16.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Nov 2018 11:16:53 -0800 (PST)
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [PATCH 1/2] mm: vmscan: skip KSM page in direct reclaim if priority is low
Date: Thu,  8 Nov 2018 03:16:40 +0800
Message-Id: <1541618201-120667-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, vbabka@suse.cz, hannes@cmpxchg.org, hughd@google.com, akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

When running some stress test, we ran into the below hung issue
occasionally:

INFO: task ksmd:205 blocked for more than 360 seconds.
      Tainted: G            E 4.9.128-001.ali3000_nightly_20180925_264.alios7.x86_64 #1
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
ksmd            D    0   205      2 0x00000000
 ffff882fa00418c0 0000000000000000 ffff882fa4b10000 ffff882fbf059d00
 ffff882fa5bc1800 ffffc900190c7c28 ffffffff81725e58 ffffffff810777c0
 00ffc900190c7c88 ffff882fbf059d00 ffffffff8138cc09 ffff882fa4b10000
Call Trace:
 [<ffffffff81725e58>] ? __schedule+0x258/0x720
 [<ffffffff810777c0>] ? do_flush_tlb_all+0x30/0x30
 [<ffffffff8138cc09>] ? free_cpumask_var+0x9/0x10
 [<ffffffff81726356>] schedule+0x36/0x80
 [<ffffffff81729916>] schedule_timeout+0x206/0x4b0
 [<ffffffff81077d0f>] ? native_flush_tlb_others+0x11f/0x180
 [<ffffffff8110ca40>] ? ktime_get+0x40/0xb0
 [<ffffffff81725b6a>] io_schedule_timeout+0xda/0x170
 [<ffffffff81726c50>] ? bit_wait+0x60/0x60
 [<ffffffff81726c6b>] bit_wait_io+0x1b/0x60
 [<ffffffff81726759>] __wait_on_bit_lock+0x59/0xc0
 [<ffffffff811aff76>] __lock_page+0x86/0xa0
 [<ffffffff810d53e0>] ? wake_atomic_t_function+0x60/0x60
 [<ffffffff8121a269>] ksm_scan_thread+0xeb9/0x1430
 [<ffffffff810d5340>] ? prepare_to_wait_event+0x100/0x100
 [<ffffffff812193b0>] ? try_to_merge_with_ksm_page+0x850/0x850
 [<ffffffff810ac226>] kthread+0xe6/0x100
 [<ffffffff810ac140>] ? kthread_park+0x60/0x60
 [<ffffffff8172b196>] ret_from_fork+0x46/0x60

ksmd found the suitable KSM page on the stable tree, an is trying to
lock it. But, it is locked by direct reclaim path when walking its rmap
to get the number of referenced PTEs.

The KSM page rmap walk need iterate all rmap_item of the page and all
rmap anon_vma of each rmap_item. So, it may take (# rmap_item * #
children processes) loops. The number of loop might be very big in the
worst case, and may take long time.

Typically, direct reclaim will not intend to reclaim too many pages, and
it is latency sensitive. So, it sounds not worth doing the long ksm page
rmap walk to just reclaim one page.

Skip KSM page in direct reclaim if the reclaim priority is low, but
still try to reclaim KSM page with high priority.

Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 mm/vmscan.c | 23 +++++++++++++++++++++--
 1 file changed, 21 insertions(+), 2 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 62ac0c48..e821ad3 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1260,8 +1260,17 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			}
 		}
 
-		if (!force_reclaim)
-			references = page_check_references(page, sc);
+		if (!force_reclaim) {
+			/*
+			 * Don't try to reclaim KSM page in direct reclaim if
+			 * the priority is not high enough.
+			 */
+			if (PageKsm(page) && !current_is_kswapd() &&
+			    sc->priority > (DEF_PRIORITY - 2))
+				references = PAGEREF_KEEP;
+			else
+				references = page_check_references(page, sc);
+		}
 
 		switch (references) {
 		case PAGEREF_ACTIVATE:
@@ -2136,6 +2145,16 @@ static void shrink_active_list(unsigned long nr_to_scan,
 			}
 		}
 
+		/*
+		 * Skip KSM page in direct reclaim if priority is not
+		 * high enough.
+		 */
+		if (PageKsm(page) && !current_is_kswapd() &&
+		    sc->priority > (DEF_PRIORITY - 2)) {
+			putback_lru_page(page);
+			continue;
+		}
+
 		if (page_referenced(page, 0, sc->target_mem_cgroup,
 				    &vm_flags)) {
 			nr_rotated += hpage_nr_pages(page);
-- 
1.8.3.1
