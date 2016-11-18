Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3ECDB6B043C
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 12:17:50 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id b123so2023548itb.3
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 09:17:50 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a3si2721201itc.80.2016.11.18.09.17.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Nov 2016 09:17:49 -0800 (PST)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [HMM v13 07/18] mm/ZONE_DEVICE/x86: add support for un-addressable device memory
Date: Fri, 18 Nov 2016 13:18:16 -0500
Message-Id: <1479493107-982-8-git-send-email-jglisse@redhat.com>
In-Reply-To: <1479493107-982-1-git-send-email-jglisse@redhat.com>
References: <1479493107-982-1-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>

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
 arch/x86/mm/init_64.c | 28 ++++++++++++++--------------
 1 file changed, 14 insertions(+), 14 deletions(-)

diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 8c4abb0..556f7bb 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -661,13 +661,17 @@ int arch_add_memory(int nid, u64 start, u64 size, int flags)
 	unsigned long nr_pages = size >> PAGE_SHIFT;
 	int ret;
 
-	/* Need to add support for device and unaddressable memory if needed */
-	if (flags & MEMORY_UNADDRESSABLE) {
-		BUG();
-		return -EINVAL;
-	}
-
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
+	if (!(flags & MEMORY_UNADDRESSABLE))
+		init_memory_mapping(start, start + size);
 
 	ret = __add_pages(nid, zone, start_pfn, nr_pages);
 	WARN_ON_ONCE(ret);
@@ -972,12 +976,6 @@ int __ref arch_remove_memory(u64 start, u64 size, int flags)
 	struct zone *zone;
 	int ret;
 
-	/* Need to add support for device and unaddressable memory if needed */
-	if (flags & MEMORY_UNADDRESSABLE) {
-		BUG();
-		return -EINVAL;
-	}
-
 	/* With altmap the first mapped page is offset from @start */
 	altmap = to_vmem_altmap((unsigned long) page);
 	if (altmap)
@@ -985,7 +983,9 @@ int __ref arch_remove_memory(u64 start, u64 size, int flags)
 	zone = page_zone(page);
 	ret = __remove_pages(zone, start_pfn, nr_pages);
 	WARN_ON_ONCE(ret);
-	kernel_physical_mapping_remove(start, start + size);
+
+	if (!(flags & MEMORY_UNADDRESSABLE))
+		kernel_physical_mapping_remove(start, start + size);
 
 	return ret;
 }
-- 
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
