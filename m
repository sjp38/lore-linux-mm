Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 406E46B0008
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 05:25:27 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id c7so20291245qkg.16
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 02:25:27 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a7-v6si8070655qtm.171.2018.11.05.02.25.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Nov 2018 02:25:25 -0800 (PST)
Date: Mon, 5 Nov 2018 18:25:20 +0800
From: Baoquan He <bhe@redhat.com>
Subject: Re: [PATCH] mm, memory_hotplug: teach has_unmovable_pages about of
 LRU migrateable pages
Message-ID: <20181105102520.GB22011@MiWiFi-R3L-srv>
References: <20181101091055.GA15166@MiWiFi-R3L-srv>
 <20181102155528.20358-1-mhocko@kernel.org>
 <20181105002009.GF27491@MiWiFi-R3L-srv>
 <20181105091407.GB4361@dhcp22.suse.cz>
 <20181105092851.GD4361@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181105092851.GD4361@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Stable tree <stable@vger.kernel.org>

Hi Michal,

On 11/05/18 at 10:28am, Michal Hocko wrote:
> 
> Or something like this. Ugly as hell, no question about that. I also
> have to think about this some more to convince myself this will not
> result in an endless loop under some situations.

It failed. Paste the log and patch diff here, please help check if I made
any mistake on manual code change. The log is at bottom.

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a919ba5cb3c8..cdcd923ec337 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -7779,14 +7779,22 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
 	pfn = page_to_pfn(page);
 	for (found = 0, iter = 0; iter < pageblock_nr_pages; iter++) {
 		unsigned long check = pfn + iter;
+		unsigned long saved_flags;
 
 		if (!pfn_valid_within(check))
 			continue;
 
 		page = pfn_to_page(check);
 
-		if (PageReserved(page))
+retry:
+		saved_flags = READ_ONCE(page->flags);
+
+
+		if (PageReserved(page)) {
+			pr_info("has_unmovable_pages 000: pfn:0x%x\n", pfn+iter);
+			__dump_page(page, "hotplug");
 			goto unmovable;
+		}
 
 		/*
 		 * Hugepages are not in LRU lists, but they're movable.
@@ -7795,8 +7803,11 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
 		 */
 		if (PageHuge(page)) {
 
-			if (!hugepage_migration_supported(page_hstate(page)))
+			if (!hugepage_migration_supported(page_hstate(page))) {
+				pr_info("has_unmovable_pages 111: pfn:0x%x\n", pfn+iter);
+				__dump_page(page, "hotplug");
 				goto unmovable;
+			}
 
 			iter = round_up(iter + 1, 1<<compound_order(page)) - 1;
 			continue;
@@ -7824,8 +7835,29 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
 		if (__PageMovable(page))
 			continue;
 
-		if (!PageLRU(page))
+#if 0
+		if (!PageLRU(page) && (get_pageblock_migratetype(page)!=MIGRATE_MOVABLE) )
 			found++;
+#endif
+               if (PageLRU(page))
+                       continue;
+
+               if (PageSwapBacked(page))
+                       continue;
+
+
+               if (page->mapping && !page->mapping->a_ops)
+		       pr_info("page->mapping:%ps \n", page->mapping);
+
+               if (page->mapping && page->mapping->a_ops && page->mapping->a_ops->migratepage)
+                       continue;
+
+		/*
+		 * We might race with the allocation of the page so retry
+		 * if flags have changed.
+		 */
+		if (saved_flags != READ_ONCE(page->flags))
+			goto retry;
 		/*
 		 * If there are RECLAIMABLE pages, we need to check
 		 * it.  But now, memory offline itself doesn't call
@@ -7839,8 +7871,11 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
 		 * is set to both of a memory hole page and a _used_ kernel
 		 * page at boot.
 		 */
-		if (found > count)
+		if (++found > count) {
+			pr_info("has_unmovable_pages: pfn:0x%x, found:0x%x, count:0x%x \n", pfn+iter, found, count);
+			__dump_page(page, "hotplug");
 			goto unmovable;
+		}
 	}
 	return false;
 unmovable:


***********console log*******************
[  458.584711] Offlined Pages 524288
[  458.943655] Offlined Pages 524288
[  459.390757] Offlined Pages 524288
[  460.086409] Offlined Pages 524288
[  460.931868] Offlined Pages 524288
[  461.741327] Offlined Pages 524288
[  462.576653] Offlined Pages 524288
[  463.291947] Offlined Pages 524288
[  464.121980] Offlined Pages 524288
[  464.869983] Offlined Pages 524288
[  465.550254] Offlined Pages 524288
[  466.337934] Offlined Pages 524288
[  467.143416] Offlined Pages 524288
[  467.925108] Offlined Pages 524288
[  468.665318] Offlined Pages 524288
[  469.473999] Offlined Pages 524288
[  470.390116] Offlined Pages 524288
[  471.069104] Offlined Pages 524288
[  471.704154] Offlined Pages 524288
[  472.322466] Offlined Pages 524288
[  472.964513] Offlined Pages 524288
[  473.629328] Offlined Pages 524288
[  474.265908] Offlined Pages 524288
[  474.883829] Offlined Pages 524288
[  475.538700] Offlined Pages 524288
[  476.247451] Offlined Pages 524288
[  476.575516] has_unmovable_pages: pfn:0x10dfec00, found:0x1, count:0x0 
[  476.582103] page:ffffea0437fb0000 count:1 mapcount:1 mapping:ffff880e05239841 index:0x7f26e5000 compound_mapcount: 1
[  476.592645] flags: 0x5fffffc0090034(uptodate|lru|active|head|swapbacked)
[  476.599386] raw: 005fffffc0090034 ffffea043bd58008 ffffea0437fb8008 ffff880e05239841
[  476.607154] raw: 00000007f26e5000 0000000000000000 00000001ffffffff ffff880e74f5c000
[  476.616725] page dumped because: hotplug
[  476.620682] page->mem_cgroup:ffff880e74f5c000
[  476.625190] WARNING: CPU: 245 PID: 8 at mm/page_alloc.c:7882 has_unmovable_pages.cold.123+0x44/0xb6
[  476.634230] Modules linked in: vfat fat intel_rapl sb_edac x86_pkg_temp_thermal coretemp kvm_intel kvm irqbypass crct10dif_pclmul iTCO_wdt crc32_pclmul iTCO_vendor_support ghash_clmulni_intel intel_cstate joydev ses ipmi_si enclosure ipmi_devintf scsi_transport_sas intel_uncore ipmi_msghandler pcspkr intel_rapl_perf sg mei_me i2c_i801 mei lpc_ich wmi xfs libcrc32c sd_mod ahci igb crc32c_intel libahci i2c_algo_bit dca libata megaraid_sas dm_mirror dm_region_hash dm_log dm_mod
[  476.678239] CPU: 245 PID: 8 Comm: kworker/u576:0 Not tainted 4.19.0+ #9
[  476.684871] Hardware name:  9008/IT91SMUB, BIOS BLXSV512 03/22/2018
[  476.691199] Workqueue: kacpi_hotplug acpi_hotplug_work_fn
[  476.696678] RIP: 0010:has_unmovable_pages.cold.123+0x44/0xb6
[  476.702369] Code: fe 0f 0e 82 4c 89 ff e8 0f a0 02 00 48 8b 44 24 10 48 2b 40 50 48 89 c2 b8 01 00 00 00 48 81 fa 40 11 00 00 0f 85 ec eb ff ff <0f> 0b e9 e5 eb ff ff 48 89 de 48 c7 c7 08 4d 0a 82 e8 79 1e f0 ff
[  476.721100] RSP: 0018:ffffc900000e3c70 EFLAGS: 00010046
[  476.726361] RAX: 0000000000000001 RBX: 0000000010dfec00 RCX: 0000000000000006
[  476.733543] RDX: 0000000000001140 RSI: 0000000000000096 RDI: ffff880e7cb55ad0
[  476.742768] RBP: 005fffffc0010000 R08: 0000000000000bbf R09: 0000000000000007
[  476.749926] R10: 0000000000000000 R11: ffffffff829f162d R12: 0000000010dfec00
[  476.757082] R13: 0000000000000001 R14: 0000000000000000 R15: ffffea0437fb0000
[  476.764241] FS:  0000000000000000(0000) GS:ffff880e7cb40000(0000) knlGS:0000000000000000
[  476.772338] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  476.778102] CR2: 00007fc3670f3000 CR3: 0000000e716c8003 CR4: 00000000003606e0
[  476.785249] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  476.792405] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[  476.799562] Call Trace:
[  476.804039]  start_isolate_page_range+0x258/0x2f0
[  476.808823]  __offline_pages+0xcc/0x8e0
[  476.812753]  ? klist_next+0xf2/0x100
[  476.816402]  ? device_is_dependent+0x90/0x90
[  476.820759]  memory_subsys_offline+0x40/0x60
[  476.825127]  device_offline+0x81/0xb0
[  476.828920]  acpi_bus_offline+0xdb/0x140
[  476.832937]  acpi_device_hotplug+0x21c/0x460
[  476.837281]  acpi_hotplug_work_fn+0x1a/0x30
[  476.841562]  process_one_work+0x1a1/0x3a0
[  476.845647]  worker_thread+0x30/0x380
[  476.849381]  ? drain_workqueue+0x120/0x120
[  476.853549]  kthread+0x112/0x130
[  476.856866]  ? kthread_park+0x80/0x80
[  476.860588]  ret_from_fork+0x35/0x40
[  476.864204] ---[ end trace 08fb4fe25cf760b3 ]---
[  476.955547] has_unmovable_pages: pfn:0x10e07a00, found:0x1, count:0x0 
[  476.962126] page:ffffea04381e8000 count:1 mapcount:1 mapping:ffff880e0913d899 index:0x7f26ec600 compound_mapcount: 1
[  476.972673] flags: 0x5fffffc0090034(uptodate|lru|active|head|swapbacked)
[  476.979413] raw: 005fffffc0090034 ffffea043c338008 ffffea043f5b0008 ffff880e0913d899
[  476.987192] raw: 00000007f26ec600 0000000000000000 00000001ffffffff ffff880e74f5c000
[  476.996921] page dumped because: hotplug
[  477.000880] page->mem_cgroup:ffff880e74f5c000
[  477.110154] has_unmovable_pages: pfn:0x10e9ee00, found:0x1, count:0x0 
[  477.118626] page:ffffea043a7b8000 count:1 mapcount:1 mapping:ffff880e0c89c2c1 index:0x7f26e5000 compound_mapcount: 1
[  477.129176] flags: 0x5fffffc0090034(uptodate|lru|active|head|swapbacked)
[  477.135911] raw: 005fffffc0090034 ffffea043b0e0008 ffffea04383e8008 ffff880e0c89c2c1
[  477.143690] raw: 00000007f26e5000 0000000000000000 00000001ffffffff ffff880e74f5c000
[  477.151448] page dumped because: hotplug
[  477.155404] page->mem_cgroup:ffff880e74f5c000
[  477.224784] has_unmovable_pages: pfn:0x10f13600, found:0x1, count:0x0 
[  477.231368] page:ffffea043c4d8000 count:1 mapcount:1 mapping:ffff880e57b7adc1 index:0x7f26e8600 compound_mapcount: 1
[  477.241922] flags: 0x5fffffc0090034(uptodate|lru|active|head|swapbacked)
[  477.250324] raw: 005fffffc0090034 ffffea043af88008 ffffea043cf20508 ffff880e57b7adc1
[  477.258089] raw: 00000007f26e8600 0000000000000000 00000001ffffffff ffff880e74f5c000
[  477.265857] page dumped because: hotplug
[  477.269811] page->mem_cgroup:ffff880e74f5c000
[  477.307236] has_unmovable_pages: pfn:0x10f8da00, found:0x1, count:0x0 
[  477.313807] page:ffffea043e368000 count:1 mapcount:1 mapping:ffff880e75132529 index:0x7f26e1600 compound_mapcount: 1
[  477.324361] flags: 0x5fffffc0090034(uptodate|lru|active|head|swapbacked)
[  477.331096] raw: 005fffffc0090034 ffffea043d2c0008 ffffea043ba40008 ffff880e75132529
[  477.338875] raw: 00000007f26e1600 0000000000000000 00000001ffffffff ffff880e74f5c000
[  477.346635] page dumped because: hotplug
[  477.350590] page->mem_cgroup:ffff880e74f5c000
[  477.380478] has_unmovable_pages: pfn:0x10d87200, found:0x1, count:0x0 
[  477.387060] page:ffffea04361c8000 count:1 mapcount:1 mapping:ffff880e0913d899 index:0x7f26e2400 compound_mapcount: 1
[  477.397610] flags: 0x5fffffc0090034(uptodate|lru|active|head|swapbacked)
[  477.404340] raw: 005fffffc0090034 ffffea0437fb8008 ffffea043cd20008 ffff880e0913d899
[  477.412113] raw: 00000007f26e2400 0000000000000000 00000001ffffffff ffff880e74f5c000
[  477.419870] page dumped because: hotplug
[  477.423842] page->mem_cgroup:ffff880e74f5c000
[  477.435557] memory memory539: Offline failed.
[  489.171077] perf: interrupt took too long (2745 > 2500), lowering kernel.perf_event_max_sample_rate to 72000
[  501.332276] INFO: NMI handler (ghes_notify_nmi) took too long to run: 2.179 msecs
[  511.073564] perf: interrupt took too long (3593 > 3431), lowering kernel.perf_event_max_sample_rate to 55000
[  521.050208] INFO: NMI handler (perf_event_nmi_handler) took too long to run: 1.836 msecs
[  521.058339] perf: interrupt took too long (16324 > 4491), lowering kernel.perf_event_max_sample_rate to 12000
