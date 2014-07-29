Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f46.google.com (mail-oi0-f46.google.com [209.85.218.46])
	by kanga.kvack.org (Postfix) with ESMTP id 917276B0036
	for <linux-mm@kvack.org>; Tue, 29 Jul 2014 03:37:47 -0400 (EDT)
Received: by mail-oi0-f46.google.com with SMTP id i138so7082230oig.33
        for <linux-mm@kvack.org>; Tue, 29 Jul 2014 00:37:47 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id x1si48763452obg.89.2014.07.29.00.37.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 29 Jul 2014 00:37:46 -0700 (PDT)
Message-ID: <53D74EE5.1070308@huawei.com>
Date: Tue, 29 Jul 2014 15:36:05 +0800
From: Zhang Zhen <zhenzhang.zhang@huawei.com>
MIME-Version: 1.0
Subject: [PATCH v2] memory hotplug: update the variables after memory removed
References: <1406619310-20555-1-git-send-email-zhenzhang.zhang@huawei.com>
In-Reply-To: <1406619310-20555-1-git-send-email-zhenzhang.zhang@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Dave Hansen <dave.hansen@intel.com>, mgorman@suse.de, mingo@redhat.com, akpm@linux-foundation.org
Cc: wangnan0@huawei.com, Linux MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

Commit ea0854170c95245a258b386c7a9314399c949fe0 added a fuction
update_end_of_memory_vars() to update high_memory, max_pfn and
max_low_pfn.

I modified the function according to Dave Hansen and David Rientjes's
suggestions.
And call it in arch_remove_memory() to update these variables too.

Change v1->v2:
- according to Dave Hansen and David Rientjes's suggestions modified
  update_end_of_memory_vars().
Signed-off-by: Zhang Zhen <zhenzhang.zhang@huawei.com>
---
 arch/x86/mm/init_64.c | 23 ++++++++++++++---------
 1 file changed, 14 insertions(+), 9 deletions(-)

diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index df1a992..fd7bd6b 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -673,15 +673,11 @@ void __init paging_init(void)
  * After memory hotplug the variables max_pfn, max_low_pfn and high_memory need
  * updating.
  */
-static void  update_end_of_memory_vars(u64 start, u64 size)
+static void  update_end_of_memory_vars(u64 end_pfn)
 {
-	unsigned long end_pfn = PFN_UP(start + size);
-
-	if (end_pfn > max_pfn) {
-		max_pfn = end_pfn;
-		max_low_pfn = end_pfn;
-		high_memory = (void *)__va(max_pfn * PAGE_SIZE - 1) + 1;
-	}
+	max_pfn = end_pfn;
+	max_low_pfn = end_pfn;
+	high_memory = (void *)__va(max_pfn * PAGE_SIZE - 1) + 1;
 }

 /*
@@ -694,6 +690,7 @@ int arch_add_memory(int nid, u64 start, u64 size)
 	struct zone *zone = pgdat->node_zones + ZONE_NORMAL;
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
+	unsigned long end_pfn;
 	int ret;

 	init_memory_mapping(start, start + size);
@@ -702,7 +699,9 @@ int arch_add_memory(int nid, u64 start, u64 size)
 	WARN_ON_ONCE(ret);

 	/* update max_pfn, max_low_pfn and high_memory */
-	update_end_of_memory_vars(start, size);
+	end_pfn = start_pfn + nr_pages;
+	if (end_pfn > max_pfn)
+		update_end_of_memory_vars(end_pfn);

 	return ret;
 }
@@ -1018,6 +1017,7 @@ int __ref arch_remove_memory(u64 start, u64 size)
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
 	struct zone *zone;
+	unsigned long end_pfn;
 	int ret;

 	zone = page_zone(pfn_to_page(start_pfn));
@@ -1025,6 +1025,11 @@ int __ref arch_remove_memory(u64 start, u64 size)
 	ret = __remove_pages(zone, start_pfn, nr_pages);
 	WARN_ON_ONCE(ret);

+	/* update max_pfn, max_low_pfn and high_memory */
+	end_pfn = start_pfn + nr_pages;
+	if ((max_pfn >= start_pfn) && (max_pfn < end_pfn))
+		update_end_of_memory_vars(start_pfn);
+
 	return ret;
 }
 #endif
-- 
1.8.1.2


.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
