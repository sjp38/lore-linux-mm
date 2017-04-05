Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id D1F8F6B03B2
	for <linux-mm@kvack.org>; Wed,  5 Apr 2017 16:40:45 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id l10so6412145qtl.13
        for <linux-mm@kvack.org>; Wed, 05 Apr 2017 13:40:45 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 88si9712976qkx.256.2017.04.05.13.40.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Apr 2017 13:40:45 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [HMM 04/16] mm/ZONE_DEVICE/x86: add support for un-addressable device memory
Date: Wed,  5 Apr 2017 16:40:14 -0400
Message-Id: <20170405204026.3940-5-jglisse@redhat.com>
In-Reply-To: <20170405204026.3940-1-jglisse@redhat.com>
References: <20170405204026.3940-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Nellans <dnellans@nvidia.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>

It does not need much, just skip populating kernel linear mapping
for range of un-addressable device memory (it is pick so that there
is no physical memory resource overlapping it). All the logic is in
share mm code.

Only support x86-64 as this feature doesn't make much sense with
constrained virtual address space of 32bits architecture.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
---
 arch/x86/mm/init_64.c | 18 ++++++++++++++++--
 1 file changed, 16 insertions(+), 2 deletions(-)

diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 6c0b24e..b635636 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -658,6 +658,7 @@ int arch_add_memory(int nid, u64 start, u64 size, enum memory_type type)
 	case MEMORY_NORMAL:
 		break;
 	case MEMORY_DEVICE_PERSISTENT:
+	case MEMORY_DEVICE_UNADDRESSABLE:
 		for_device = true;
 		break;
 	default:
@@ -668,7 +669,17 @@ int arch_add_memory(int nid, u64 start, u64 size, enum memory_type type)
 	zone = pgdat->node_zones +
 		zone_for_memory(nid, start, size, ZONE_NORMAL, for_device);
 
-	init_memory_mapping(start, start + size);
+	/*
+	 * We get un-addressable memory when some one is adding a ZONE_DEVICE
+	 * to have struct page for a device memory which is not accessible by
+	 * the CPU so it is pointless to have a linear kernel mapping of such
+	 * memory.
+	 *
+	 * Core mm should make sure it never set a pte pointing to such fake
+	 * physical range.
+	 */
+	if (type != MEMORY_DEVICE_UNADDRESSABLE)
+		init_memory_mapping(start, start + size);
 
 	ret = __add_pages(nid, zone, start_pfn, nr_pages);
 	WARN_ON_ONCE(ret);
@@ -980,6 +991,7 @@ int __ref arch_remove_memory(u64 start, u64 size, enum memory_type type)
 	switch (type) {
 	case MEMORY_NORMAL:
 	case MEMORY_DEVICE_PERSISTENT:
+	case MEMORY_DEVICE_UNADDRESSABLE:
 		break;
 	default:
 		pr_err("hotplug unsupported memory type %d\n", type);
@@ -993,7 +1005,9 @@ int __ref arch_remove_memory(u64 start, u64 size, enum memory_type type)
 	zone = page_zone(page);
 	ret = __remove_pages(zone, start_pfn, nr_pages);
 	WARN_ON_ONCE(ret);
-	kernel_physical_mapping_remove(start, start + size);
+
+	if (type != MEMORY_DEVICE_UNADDRESSABLE)
+		kernel_physical_mapping_remove(start, start + size);
 
 	return ret;
 }
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
