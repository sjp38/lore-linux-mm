Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5270C6B038D
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 11:03:57 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id n37so38759084qtb.7
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 08:03:57 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g188si4105849qkb.7.2017.03.16.08.03.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Mar 2017 08:03:56 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [HMM 05/16] mm/ZONE_DEVICE/x86: add support for un-addressable device memory
Date: Thu, 16 Mar 2017 12:05:24 -0400
Message-Id: <1489680335-6594-6-git-send-email-jglisse@redhat.com>
In-Reply-To: <1489680335-6594-1-git-send-email-jglisse@redhat.com>
References: <1489680335-6594-1-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Nellans <dnellans@nvidia.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>

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
 arch/x86/mm/init_64.c | 22 ++++++++++++++++++----
 1 file changed, 18 insertions(+), 4 deletions(-)

diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 0098dc9..7c8c91c 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -644,7 +644,8 @@ static void  update_end_of_memory_vars(u64 start, u64 size)
 int arch_add_memory(int nid, u64 start, u64 size, int flags)
 {
 	const int supported_flags = MEMORY_DEVICE |
-				    MEMORY_DEVICE_ALLOW_MIGRATE;
+				    MEMORY_DEVICE_ALLOW_MIGRATE |
+				    MEMORY_DEVICE_UNADDRESSABLE;
 	struct pglist_data *pgdat = NODE_DATA(nid);
 	struct zone *zone = pgdat->node_zones +
 		zone_for_memory(nid, start, size, ZONE_NORMAL,
@@ -659,7 +660,17 @@ int arch_add_memory(int nid, u64 start, u64 size, int flags)
 		return -EINVAL;
 	}
 
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
+	if (!(flags & MEMORY_DEVICE_UNADDRESSABLE))
+		init_memory_mapping(start, start + size);
 
 	ret = __add_pages(nid, zone, start_pfn, nr_pages);
 	WARN_ON_ONCE(ret);
@@ -958,7 +969,8 @@ kernel_physical_mapping_remove(unsigned long start, unsigned long end)
 int __ref arch_remove_memory(u64 start, u64 size, int flags)
 {
 	const int supported_flags = MEMORY_DEVICE |
-				    MEMORY_DEVICE_ALLOW_MIGRATE;
+				    MEMORY_DEVICE_ALLOW_MIGRATE |
+				    MEMORY_DEVICE_UNADDRESSABLE;
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
 	struct page *page = pfn_to_page(start_pfn);
@@ -979,7 +991,9 @@ int __ref arch_remove_memory(u64 start, u64 size, int flags)
 	zone = page_zone(page);
 	ret = __remove_pages(zone, start_pfn, nr_pages);
 	WARN_ON_ONCE(ret);
-	kernel_physical_mapping_remove(start, start + size);
+
+	if (!(flags & MEMORY_DEVICE_UNADDRESSABLE))
+		kernel_physical_mapping_remove(start, start + size);
 
 	return ret;
 }
-- 
2.4.11

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
