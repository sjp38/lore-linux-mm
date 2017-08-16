Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 518AC6B02B4
	for <linux-mm@kvack.org>; Wed, 16 Aug 2017 00:52:07 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id m133so15291689pga.2
        for <linux-mm@kvack.org>; Tue, 15 Aug 2017 21:52:07 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id p28si7184689pli.712.2017.08.15.21.52.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Aug 2017 21:52:06 -0700 (PDT)
From: Chen Yu <yu.c.chen@intel.com>
Subject: [PATCH][RFC v2] PM / Hibernate: Disable wathdog when creating snapshot
Date: Wed, 16 Aug 2017 12:53:38 +0800
Message-Id: <1502859218-13099-1-git-send-email-yu.c.chen@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Chen Yu <yu.c.chen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Dan Williams <dan.j.williams@intel.com>, linux-pm@vger.kernel.org, linux-kernel@vger.kernel.org

There is a problem that when counting the pages for creating
the hibernation snapshot will take significant amount of
time, especially on system with large memory. Since the counting
job is performed with irq disabled, this might lead to NMI lockup.
The following warning were found on a system with 1.5TB DRAM:

[ 1124.758184] Freezing user space processes ... (elapsed 0.002 seconds) done.
[ 1124.768721] OOM killer disabled.
[ 1124.847009] PM: Preallocating image memory...
[ 1139.392042] NMI watchdog: Watchdog detected hard LOCKUP on cpu 27
[ 1139.392076] CPU: 27 PID: 3128 Comm: systemd-sleep Not tainted 4.13.0-0.rc2.git0.1.fc27.x86_64 #1
[ 1139.392077] task: ffff9f01971ac000 task.stack: ffffb1a3f325c000
[ 1139.392083] RIP: 0010:memory_bm_find_bit+0xf4/0x100
[ 1139.392084] RSP: 0018:ffffb1a3f325fc20 EFLAGS: 00000006
[ 1139.392084] RAX: 0000000000000000 RBX: 0000000013b83000 RCX: ffff9fbe89caf000
[ 1139.392085] RDX: ffffb1a3f325fc30 RSI: 0000000000003200 RDI: ffff9fbeaffffe80
[ 1139.392085] RBP: ffffb1a3f325fc40 R08: 0000000013b80000 R09: ffff9fbe89c54878
[ 1139.392085] R10: ffffb1a3f325fc2c R11: 0000000013b83200 R12: 0000000000000400
[ 1139.392086] R13: fffffd552e0c0000 R14: ffff9fc1bffd31e0 R15: 0000000000000202
[ 1139.392086] FS:  00007f3189704180(0000) GS:ffff9fbec8ec0000(0000) knlGS:0000000000000000
[ 1139.392087] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 1139.392087] CR2: 00000085da0f7398 CR3: 000001771cf9a000 CR4: 00000000007406e0
[ 1139.392088] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 1139.392088] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[ 1139.392088] PKRU: 55555554
[ 1139.392089] Call Trace:
[ 1139.392092]  ? memory_bm_set_bit+0x29/0x60
[ 1139.392094]  swsusp_set_page_free+0x2b/0x30
[ 1139.392098]  mark_free_pages+0x147/0x1c0
[ 1139.392099]  count_data_pages+0x41/0xa0
[ 1139.392101]  hibernate_preallocate_memory+0x80/0x450
[ 1139.392102]  hibernation_snapshot+0x58/0x410
[ 1139.392103]  hibernate+0x17c/0x310
[ 1139.392104]  state_store+0xdf/0xf0
[ 1139.392107]  kobj_attr_store+0xf/0x20
[ 1139.392111]  sysfs_kf_write+0x37/0x40
[ 1139.392113]  kernfs_fop_write+0x11c/0x1a0
[ 1139.392117]  __vfs_write+0x37/0x170
[ 1139.392121]  ? handle_mm_fault+0xd8/0x230
[ 1139.392122]  vfs_write+0xb1/0x1a0
[ 1139.392123]  SyS_write+0x55/0xc0
[ 1139.392126]  entry_SYSCALL_64_fastpath+0x1a/0xa5

So avoid the NMI lockup by disabling the watchdog temporarily.

Reported-by: Jan Filipcewicz <jan.filipcewicz@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: Len Brown <lenb@kernel.org>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: linux-pm@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Signed-off-by: Chen Yu <yu.c.chen@intel.com>
---
 v2: Change the 'feed' action by touch_nmi_watchdog()
     to 'disable' the watchdog by lockup_detector_suspend().
---
 mm/page_alloc.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6d00f74..adff934 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -66,6 +66,7 @@
 #include <linux/kthread.h>
 #include <linux/memcontrol.h>
 #include <linux/ftrace.h>
+#include <linux/nmi.h>
 
 #include <asm/sections.h>
 #include <asm/tlbflush.h>
@@ -2537,10 +2538,15 @@ void mark_free_pages(struct zone *zone)
 	unsigned long flags;
 	unsigned int order, t;
 	struct page *page;
+	bool wd_suspended;
 
 	if (zone_is_empty(zone))
 		return;
 
+	wd_suspended = lockup_detector_suspend() ? false : true;
+	if (!wd_suspended)
+		pr_warn_once("Failed to disable lockup detector during hibernation.\n");
+
 	spin_lock_irqsave(&zone->lock, flags);
 
 	max_zone_pfn = zone_end_pfn(zone);
@@ -2566,6 +2572,9 @@ void mark_free_pages(struct zone *zone)
 		}
 	}
 	spin_unlock_irqrestore(&zone->lock, flags);
+
+	if (wd_suspended)
+		lockup_detector_resume();
 }
 #endif /* CONFIG_PM */
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
