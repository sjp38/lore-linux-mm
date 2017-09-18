Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id E19256B025E
	for <linux-mm@kvack.org>; Mon, 18 Sep 2017 08:14:27 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id v109so285781wrc.5
        for <linux-mm@kvack.org>; Mon, 18 Sep 2017 05:14:27 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 184sor1826337wmk.75.2017.09.18.05.14.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Sep 2017 05:14:26 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 3/3] memremap: add scheduling point to devm_memremap_pages
Date: Mon, 18 Sep 2017 14:14:10 +0200
Message-Id: <20170918121410.24466-4-mhocko@kernel.org>
In-Reply-To: <20170918121410.24466-1-mhocko@kernel.org>
References: <20170918121410.24466-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dan Williams <dan.j.williams@gmail.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>, Johannes Thumshirn <jthumshirn@suse.de>

From: Michal Hocko <mhocko@suse.com>

devm_memremap_pages is initializing struct pages in for_each_device_pfn
and that can take quite some time. We have even seen a soft lockup
trigerring on a non preemptive kernel
[  125.583233] NMI watchdog: BUG: soft lockup - CPU#61 stuck for 22s! [kworker/u641:11:1808]
[...]
[  125.583467] RIP: 0010:[<ffffffff8118b6b7>]  [<ffffffff8118b6b7>] devm_memremap_pages+0x327/0x430
[...]
[  125.583488] Call Trace:
[  125.583496]  [<ffffffffa016550d>] pmem_attach_disk+0x2fd/0x3f0 [nd_pmem]
[  125.583528]  [<ffffffffa14ae984>] nvdimm_bus_probe+0x64/0x110 [libnvdimm]
[  125.583536]  [<ffffffff8146b257>] driver_probe_device+0x1f7/0x420
[  125.583540]  [<ffffffff81469212>] bus_for_each_drv+0x52/0x80
[  125.583543]  [<ffffffff8146af40>] __device_attach+0xb0/0x130
[  125.583546]  [<ffffffff8146a367>] bus_probe_device+0x87/0xa0
[  125.583548]  [<ffffffff814682fc>] device_add+0x3fc/0x5f0
[  125.583553]  [<ffffffffa14adffe>] nd_async_device_register+0xe/0x40 [libnvdimm]
[  125.583556]  [<ffffffff8109e413>] async_run_entry_fn+0x43/0x150
[  125.583561]  [<ffffffff81095b8e>] process_one_work+0x14e/0x410
[  125.583563]  [<ffffffff810963f6>] worker_thread+0x116/0x490
[  125.583565]  [<ffffffff8109b8c7>] kthread+0xc7/0xe0
[  125.583569]  [<ffffffff8160a57f>] ret_from_fork+0x3f/0x70

fix this by adding cond_resched every 1024 pages.

Reported-by: Johannes Thumshirn <jthumshirn@suse.de>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 kernel/memremap.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/kernel/memremap.c b/kernel/memremap.c
index 6bcbfbf1a8fd..403ab9cdb949 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -350,7 +350,7 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
 	pgprot_t pgprot = PAGE_KERNEL;
 	struct dev_pagemap *pgmap;
 	struct page_map *page_map;
-	int error, nid, is_ram;
+	int error, nid, is_ram, i = 0;
 
 	align_start = res->start & ~(SECTION_SIZE - 1);
 	align_size = ALIGN(res->start + resource_size(res), SECTION_SIZE)
@@ -448,6 +448,8 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
 		list_del(&page->lru);
 		page->pgmap = pgmap;
 		percpu_ref_get(ref);
+		if (!(++i % 1024))
+			cond_resched();
 	}
 	devres_add(dev, page_map);
 	return __va(res->start);
-- 
2.14.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
