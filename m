Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 00E716B03BC
	for <linux-mm@kvack.org>; Mon, 10 Apr 2017 07:04:26 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id h188so2770965wma.4
        for <linux-mm@kvack.org>; Mon, 10 Apr 2017 04:04:25 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id f26si20867481wrc.172.2017.04.10.04.04.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Apr 2017 04:04:24 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id x75so8989023wma.1
        for <linux-mm@kvack.org>; Mon, 10 Apr 2017 04:04:24 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 7/9] mm, memory_hotplug: replace for_device by want_memblock in arch_add_memory
Date: Mon, 10 Apr 2017 13:03:49 +0200
Message-Id: <20170410110351.12215-8-mhocko@kernel.org>
In-Reply-To: <20170410110351.12215-1-mhocko@kernel.org>
References: <20170410110351.12215-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Dan Williams <dan.j.williams@gmail.com>

From: Michal Hocko <mhocko@suse.com>

arch_add_memory gets for_device argument which then controls whether we
want to create memblocks for created memory sections. Simplify the logic
by telling whether we want memblocks directly rather than going through
pointless negation. This also makes the api easier to understand because
it is clear what we want rather than nothing telling for_device which
can mean anything.

This shouldn't introduce any functional change.

Cc: Dan Williams <dan.j.williams@gmail.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 arch/ia64/mm/init.c            | 4 ++--
 arch/powerpc/mm/mem.c          | 4 ++--
 arch/s390/mm/init.c            | 4 ++--
 arch/sh/mm/init.c              | 4 ++--
 arch/x86/mm/init_32.c          | 4 ++--
 arch/x86/mm/init_64.c          | 4 ++--
 include/linux/memory_hotplug.h | 2 +-
 kernel/memremap.c              | 2 +-
 mm/memory_hotplug.c            | 2 +-
 9 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
index efe46742905a..b02c789e3c86 100644
--- a/arch/ia64/mm/init.c
+++ b/arch/ia64/mm/init.c
@@ -645,13 +645,13 @@ mem_init (void)
 }
 
 #ifdef CONFIG_MEMORY_HOTPLUG
-int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
+int arch_add_memory(int nid, u64 start, u64 size, bool want_memblock)
 {
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
 	int ret;
 
-	ret = __add_pages(nid, start_pfn, nr_pages, !for_device);
+	ret = __add_pages(nid, start_pfn, nr_pages, want_memblock);
 	if (ret)
 		printk("%s: Problem encountered in __add_pages() as ret=%d\n",
 		       __func__,  ret);
diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
index d3decea056a0..2f2e5eaa10e3 100644
--- a/arch/powerpc/mm/mem.c
+++ b/arch/powerpc/mm/mem.c
@@ -126,7 +126,7 @@ int __weak remove_section_mapping(unsigned long start, unsigned long end)
 	return -ENODEV;
 }
 
-int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
+int arch_add_memory(int nid, u64 start, u64 size, bool want_memblock)
 {
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
@@ -141,7 +141,7 @@ int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
 		return -EFAULT;
 	}
 
-	return __add_pages(nid, start_pfn, nr_pages, !for_device);
+	return __add_pages(nid, start_pfn, nr_pages, want_memblock);
 }
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
diff --git a/arch/s390/mm/init.c b/arch/s390/mm/init.c
index 2d9f3f91b08d..597aad4e05d4 100644
--- a/arch/s390/mm/init.c
+++ b/arch/s390/mm/init.c
@@ -153,7 +153,7 @@ void __init free_initrd_mem(unsigned long start, unsigned long end)
 #endif
 
 #ifdef CONFIG_MEMORY_HOTPLUG
-int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
+int arch_add_memory(int nid, u64 start, u64 size, bool want_memblock)
 {
 	unsigned long start_pfn = PFN_DOWN(start);
 	unsigned long size_pages = PFN_DOWN(size);
@@ -163,7 +163,7 @@ int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
 	if (rc)
 		return rc;
 
-	rc = __add_pages(nid, start_pfn, size_pages, !for_device);
+	rc = __add_pages(nid, start_pfn, size_pages, want_memblock);
 	if (rc)
 		vmem_remove_mapping(start, size);
 	return rc;
diff --git a/arch/sh/mm/init.c b/arch/sh/mm/init.c
index 3813a610a2bb..bf726af5f1a5 100644
--- a/arch/sh/mm/init.c
+++ b/arch/sh/mm/init.c
@@ -485,14 +485,14 @@ void free_initrd_mem(unsigned long start, unsigned long end)
 #endif
 
 #ifdef CONFIG_MEMORY_HOTPLUG
-int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
+int arch_add_memory(int nid, u64 start, u64 size, bool want_memblock)
 {
 	unsigned long start_pfn = PFN_DOWN(start);
 	unsigned long nr_pages = size >> PAGE_SHIFT;
 	int ret;
 
 	/* We only have ZONE_NORMAL, so this is easy.. */
-	ret = __add_pages(nid, start_pfn, nr_pages, !for_device);
+	ret = __add_pages(nid, start_pfn, nr_pages, want_memblock);
 	if (unlikely(ret))
 		printk("%s: Failed, __add_pages() == %d\n", __func__, ret);
 
diff --git a/arch/x86/mm/init_32.c b/arch/x86/mm/init_32.c
index 3c66da076053..3423bb4156e5 100644
--- a/arch/x86/mm/init_32.c
+++ b/arch/x86/mm/init_32.c
@@ -826,12 +826,12 @@ void __init mem_init(void)
 }
 
 #ifdef CONFIG_MEMORY_HOTPLUG
-int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
+int arch_add_memory(int nid, u64 start, u64 size, bool want_memblock)
 {
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
 
-	return __add_pages(nid, start_pfn, nr_pages, !for_device);
+	return __add_pages(nid, start_pfn, nr_pages, want_memblock);
 }
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 07dbd32f6583..754d47cb2847 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -637,7 +637,7 @@ static void  update_end_of_memory_vars(u64 start, u64 size)
 	}
 }
 
-int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
+int arch_add_memory(int nid, u64 start, u64 size, bool want_memblock)
 {
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
@@ -645,7 +645,7 @@ int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
 
 	init_memory_mapping(start, start + size);
 
-	ret = __add_pages(nid, start_pfn, nr_pages, !for_device);
+	ret = __add_pages(nid, start_pfn, nr_pages, want_memblock);
 	WARN_ON_ONCE(ret);
 
 	/* update max_pfn, max_low_pfn and high_memory */
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 98470ea5536b..c28d0aba7525 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -276,7 +276,7 @@ extern int add_memory(int nid, u64 start, u64 size);
 extern int add_memory_resource(int nid, struct resource *resource, bool online);
 extern int zone_for_memory(int nid, u64 start, u64 size, int zone_default,
 		bool for_device);
-extern int arch_add_memory(int nid, u64 start, u64 size, bool for_device);
+extern int arch_add_memory(int nid, u64 start, u64 size, bool want_memblock);
 extern void move_pfn_range_to_zone(struct zone *zone, unsigned long start_pfn,
 		unsigned long nr_pages);
 extern int offline_pages(unsigned long start_pfn, unsigned long nr_pages);
diff --git a/kernel/memremap.c b/kernel/memremap.c
index 61aaa41f4e18..ea714eee029c 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -363,7 +363,7 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
 		goto err_pfn_remap;
 
 	mem_hotplug_begin();
-	error = arch_add_memory(nid, align_start, align_size, true);
+	error = arch_add_memory(nid, align_start, align_size, false);
 	if (!error)
 		move_pfn_range_to_zone(&NODE_DATA(nid)->node_zones[ZONE_DEVICE],
 					align_start >> PAGE_SHIFT,
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index b7351de3978c..43e84758057b 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1427,7 +1427,7 @@ int __ref add_memory_resource(int nid, struct resource *res, bool online)
 	}
 
 	/* call arch's memory hotadd */
-	ret = arch_add_memory(nid, start, size, false);
+	ret = arch_add_memory(nid, start, size, true);
 
 	if (ret < 0)
 		goto error;
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
