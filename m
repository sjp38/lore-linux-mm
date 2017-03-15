Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 658916B038B
	for <linux-mm@kvack.org>; Wed, 15 Mar 2017 12:40:33 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id d66so5904033wmi.2
        for <linux-mm@kvack.org>; Wed, 15 Mar 2017 09:40:33 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id i23si3234330wrc.50.2017.03.15.09.40.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Mar 2017 09:40:32 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id z63so5581468wmg.2
        for <linux-mm@kvack.org>; Wed, 15 Mar 2017 09:40:31 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH] mm: move mm_percpu_wq initialization earlier
Date: Wed, 15 Mar 2017 17:40:21 +0100
Message-Id: <20170315164021.28532-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Li Yang <pku.leo@gmail.com>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-arm-kernel@lists.infradead.org, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

Yang Li has reported that drain_all_pages triggers a WARN_ON which means
that this function is called earlier than the mm_percpu_wq is
initialized on arm64 with CMA configured:

[    0.276449] WARNING: CPU: 2 PID: 1 at mm/page_alloc.c:2423 drain_all_pages+0x244/0x25c
[    0.276537] Modules linked in:
[    0.276594] CPU: 2 PID: 1 Comm: swapper/0 Not tainted 4.11.0-rc1-next-20170310-00027-g64dfbc5 #127
[    0.276693] Hardware name: Freescale Layerscape 2088A RDB Board (DT)
[    0.276764] task: ffffffc07c4a6d00 task.stack: ffffffc07c4a8000
[    0.276831] PC is at drain_all_pages+0x244/0x25c
[    0.276886] LR is at start_isolate_page_range+0x14c/0x1f0
[...]
[    0.279000] [<ffffff80081636bc>] drain_all_pages+0x244/0x25c
[    0.279065] [<ffffff80081c675c>] start_isolate_page_range+0x14c/0x1f0
[    0.279137] [<ffffff8008166a48>] alloc_contig_range+0xec/0x354
[    0.279203] [<ffffff80081c6c5c>] cma_alloc+0x100/0x1fc
[    0.279263] [<ffffff8008481714>] dma_alloc_from_contiguous+0x3c/0x44
[    0.279336] [<ffffff8008b25720>] atomic_pool_init+0x7c/0x208
[    0.279399] [<ffffff8008b258f0>] arm64_dma_init+0x44/0x4c
[    0.279461] [<ffffff8008083144>] do_one_initcall+0x38/0x128
[    0.279525] [<ffffff8008b20d30>] kernel_init_freeable+0x1a0/0x240
[    0.279596] [<ffffff8008807778>] kernel_init+0x10/0xfc
[    0.279654] [<ffffff8008082b70>] ret_from_fork+0x10/0x20

Fix this by moving the whole setup_vmstat which is an initcall right now
to init_mm_internals which will be called right after the WQ subsystem
is initialized.

Reported-and-tested-by: Yang Li <pku.leo@gmail.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/mm.h | 2 ++
 init/main.c        | 2 ++
 mm/vmstat.c        | 4 +---
 3 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 21ee5503c702..8362dca071cb 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -32,6 +32,8 @@ struct user_struct;
 struct writeback_control;
 struct bdi_writeback;
 
+void init_mm_internals(void);
+
 #ifndef CONFIG_NEED_MULTIPLE_NODES	/* Don't use mapnrs, do it properly */
 extern unsigned long max_mapnr;
 
diff --git a/init/main.c b/init/main.c
index 51aa8f336819..c72d35250e84 100644
--- a/init/main.c
+++ b/init/main.c
@@ -1023,6 +1023,8 @@ static noinline void __init kernel_init_freeable(void)
 
 	workqueue_init();
 
+	init_mm_internals();
+
 	do_pre_smp_initcalls();
 	lockup_detector_init();
 
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 4bbc775f9d08..d0871fc1aeca 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1762,7 +1762,7 @@ static int vmstat_cpu_dead(unsigned int cpu)
 
 struct workqueue_struct *mm_percpu_wq;
 
-static int __init setup_vmstat(void)
+void __init init_mm_internals(void)
 {
 	int ret __maybe_unused;
 
@@ -1792,9 +1792,7 @@ static int __init setup_vmstat(void)
 	proc_create("vmstat", S_IRUGO, NULL, &proc_vmstat_file_operations);
 	proc_create("zoneinfo", S_IRUGO, NULL, &proc_zoneinfo_file_operations);
 #endif
-	return 0;
 }
-module_init(setup_vmstat)
 
 #if defined(CONFIG_DEBUG_FS) && defined(CONFIG_COMPACTION)
 
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
