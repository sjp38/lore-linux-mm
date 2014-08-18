Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 46B666B0037
	for <linux-mm@kvack.org>; Sun, 17 Aug 2014 22:04:23 -0400 (EDT)
Received: by mail-wg0-f49.google.com with SMTP id k14so4302694wgh.8
        for <linux-mm@kvack.org>; Sun, 17 Aug 2014 19:04:22 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id wf7si23042159wjb.74.2014.08.17.19.04.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 17 Aug 2014 19:04:22 -0700 (PDT)
Message-ID: <53F15E37.9080602@huawei.com>
Date: Mon, 18 Aug 2014 10:00:23 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [PATCH V2] mem-hotplug: let memblock skip the hotpluggable memory
 regions in __next_mem_range()
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Tang Chen <tangchen@cn.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>, "Rafael
 J. Wysocki" <rjw@sisk.pl>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Let memblock skip the hotpluggable memory regions in __next_mem_range(),
it is used to to prevent memblock from allocating hotpluggable memory 
for the kernel at early time. The code is the same as __next_mem_range_rev().

Clear hotpluggable flag before releasing free pages to the buddy allocator.
If we don't clear hotpluggable flag in free_low_memory_core_early(), the 
memory which marked hotpluggable flag will not free to buddy allocator.
Because __next_mem_range() will skip them.

free_low_memory_core_early
	for_each_free_mem_range
		for_each_mem_range
			__next_mem_range

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
---
 mm/memblock.c  |    4 ++++
 mm/nobootmem.c |    2 ++
 2 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index 6d2f219..5090050 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -817,6 +817,10 @@ void __init_memblock __next_mem_range(u64 *idx, int nid,
 		if (nid != NUMA_NO_NODE && nid != m_nid)
 			continue;
 
+		/* skip hotpluggable memory regions if needed */
+		if (movable_node_is_enabled() && memblock_is_hotpluggable(m))
+			continue;
+
 		if (!type_b) {
 			if (out_start)
 				*out_start = m_start;
diff --git a/mm/nobootmem.c b/mm/nobootmem.c
index 7ed5860..03de286 100644
--- a/mm/nobootmem.c
+++ b/mm/nobootmem.c
@@ -119,6 +119,8 @@ static unsigned long __init free_low_memory_core_early(void)
 	phys_addr_t start, end;
 	u64 i;
 
+	memblock_clear_hotplug(0, ULLONG_MAX);
+
 	for_each_free_mem_range(i, NUMA_NO_NODE, &start, &end, NULL)
 		count += __free_memory_core(start, end);
 
-- 1.7.1 



. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
