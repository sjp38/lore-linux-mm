Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f172.google.com (mail-ob0-f172.google.com [209.85.214.172])
	by kanga.kvack.org (Postfix) with ESMTP id E02176B0035
	for <linux-mm@kvack.org>; Mon, 11 Aug 2014 09:34:08 -0400 (EDT)
Received: by mail-ob0-f172.google.com with SMTP id wn1so6061020obc.31
        for <linux-mm@kvack.org>; Mon, 11 Aug 2014 06:34:08 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [119.145.14.64])
        by mx.google.com with ESMTPS id h1si25062206obf.69.2014.08.11.06.34.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 11 Aug 2014 06:34:08 -0700 (PDT)
Message-ID: <53E8C5AA.5040506@huawei.com>
Date: Mon, 11 Aug 2014 21:31:22 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [PATCH] mem-hotplug: let memblock skip the hotpluggable memory regions
 in __next_mem_range()
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Tang Chen <tangchen@cn.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, tj@kernel.org, Wen Congyang <wency@cn.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Xishi Qiu <qiuxishi@huawei.com>

Let memblock skip the hotpluggable memory regions in __next_mem_range(),
it is used to to prevent memblock from allocating hotpluggable memory 
for the kernel at early time. The code is the same as __next_mem_range_rev().

Clear hotpluggable flag before releasing free pages to the buddy allocator.

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
 
-- 
1.7.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
