Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id EC6938E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 09:45:18 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id e29so6777052ede.19
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 06:45:18 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a37sor29758587edd.23.2019.01.28.06.45.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 28 Jan 2019 06:45:17 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 2/2] mm, memory_hotplug: test_pages_in_a_zone do not pass the end of zone
Date: Mon, 28 Jan 2019 15:45:06 +0100
Message-Id: <20190128144506.15603-3-mhocko@kernel.org>
In-Reply-To: <20190128144506.15603-1-mhocko@kernel.org>
References: <20190128144506.15603-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikhail Zaslonko <zaslonko@linux.ibm.com>, Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pavel Tatashin <pasha.tatashin@soleen.com>, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, gerald.schaefer@de.ibm.com, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Mikhail Zaslonko <zaslonko@linux.ibm.com>

If memory end is not aligned with the sparse memory section boundary, the
mapping of such a section is only partly initialized. This may lead to
VM_BUG_ON due to uninitialized struct pages access from test_pages_in_a_zone()
function triggered by memory_hotplug sysfs handlers.

Here are the the panic examples:
 CONFIG_DEBUG_VM_PGFLAGS=y
 kernel parameter mem=2050M
 --------------------------
 page:000003d082008000 is uninitialized and poisoned
 page dumped because: VM_BUG_ON_PAGE(PagePoisoned(p))
 Call Trace:
 ([<0000000000385b26>] test_pages_in_a_zone+0xde/0x160)
  [<00000000008f15c4>] show_valid_zones+0x5c/0x190
  [<00000000008cf9c4>] dev_attr_show+0x34/0x70
  [<0000000000463ad0>] sysfs_kf_seq_show+0xc8/0x148
  [<00000000003e4194>] seq_read+0x204/0x480
  [<00000000003b53ea>] __vfs_read+0x32/0x178
  [<00000000003b55b2>] vfs_read+0x82/0x138
  [<00000000003b5be2>] ksys_read+0x5a/0xb0
  [<0000000000b86ba0>] system_call+0xdc/0x2d8
 Last Breaking-Event-Address:
  [<0000000000385b26>] test_pages_in_a_zone+0xde/0x160
 Kernel panic - not syncing: Fatal exception: panic_on_oops

Fix this by checking whether the pfn to check is within the zone.

[mhocko@suse.com: separated this change from
http://lkml.kernel.org/r/20181105150401.97287-2-zaslonko@linux.ibm.com]
Signed-off-by: Mikhail Zaslonko <zaslonko@linux.ibm.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/memory_hotplug.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 07872789d778..7711d0e327b6 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1274,6 +1274,9 @@ int test_pages_in_a_zone(unsigned long start_pfn, unsigned long end_pfn,
 				i++;
 			if (i == MAX_ORDER_NR_PAGES || pfn + i >= end_pfn)
 				continue;
+			/* Check if we got outside of the zone */
+			if (zone && !zone_spans_pfn(zone, pfn + i))
+				return 0;
 			page = pfn_to_page(pfn + i);
 			if (zone && page_zone(page) != zone)
 				return 0;
-- 
2.20.1
