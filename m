Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1FD798E0001
	for <linux-mm@kvack.org>; Mon, 10 Dec 2018 08:07:23 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id e29so5359800ede.19
        for <linux-mm@kvack.org>; Mon, 10 Dec 2018 05:07:23 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id f48si4676572ede.180.2018.12.10.05.07.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Dec 2018 05:07:21 -0800 (PST)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wBAD4hM3015793
	for <linux-mm@kvack.org>; Mon, 10 Dec 2018 08:07:20 -0500
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2p9p370kd9-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 10 Dec 2018 08:07:19 -0500
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <zaslonko@linux.ibm.com>;
	Mon, 10 Dec 2018 13:07:18 -0000
From: Mikhail Zaslonko <zaslonko@linux.ibm.com>
Subject: [PATCH 1/1] mm, memory_hotplug: Initialize struct pages for the full memory section
Date: Mon, 10 Dec 2018 14:07:12 +0100
In-Reply-To: <20181210130712.30148-1-zaslonko@linux.ibm.com>
References: <20181210130712.30148-1-zaslonko@linux.ibm.com>
Message-Id: <20181210130712.30148-2-zaslonko@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, Pavel.Tatashin@microsoft.com, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, gerald.schaefer@de.ibm.com, zaslonko@linux.ibm.com

If memory end is not aligned with the sparse memory section boundary, the
mapping of such a section is only partly initialized. This may lead to
VM_BUG_ON due to uninitialized struct page access from
is_mem_section_removable() or test_pages_in_a_zone() function triggered by
memory_hotplug sysfs handlers:

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

Fix the problem by initializing the last memory section of the highest zone
in memmap_init_zone() till the very end, even if it goes beyond the zone
end.

Signed-off-by: Mikhail Zaslonko <zaslonko@linux.ibm.com>
Reviewed-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Cc: <stable@vger.kernel.org>
---
 mm/page_alloc.c | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 2ec9cc407216..41ef5508e5f1 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5542,6 +5542,21 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 			cond_resched();
 		}
 	}
+#ifdef CONFIG_SPARSEMEM
+	/*
+	 * If there is no zone spanning the rest of the section
+	 * then we should at least initialize those pages. Otherwise we
+	 * could blow up on a poisoned page in some paths which depend
+	 * on full sections being initialized (e.g. memory hotplug).
+	 */
+	if (end_pfn == max_pfn) {
+		while (end_pfn % PAGES_PER_SECTION) {
+			__init_single_page(pfn_to_page(end_pfn), end_pfn, zone,
+					   nid);
+			end_pfn++;
+		}
+	}
+#endif
 }
 
 #ifdef CONFIG_ZONE_DEVICE
-- 
2.16.4
