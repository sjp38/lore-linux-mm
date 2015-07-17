Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id C0A9C280314
	for <linux-mm@kvack.org>; Thu, 16 Jul 2015 21:22:52 -0400 (EDT)
Received: by pdbbh15 with SMTP id bh15so7530576pdb.1
        for <linux-mm@kvack.org>; Thu, 16 Jul 2015 18:22:52 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id g6si15715874pdn.197.2015.07.16.18.22.50
        for <linux-mm@kvack.org>;
        Thu, 16 Jul 2015 18:22:51 -0700 (PDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH 1/2] memblock: Make memblock_overlaps_region() return bool.
Date: Fri, 17 Jul 2015 09:23:30 +0800
Message-ID: <1437096211-28605-2-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1437096211-28605-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1437096211-28605-1-git-send-email-tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, dyoung@redhat.com, isimatu.yasuaki@jp.fujitsu.com, yasu.isimatu@gmail.com, lcapitulino@redhat.com, qiuxishi@huawei.com, will.deacon@arm.com, tony.luck@intel.com, vladimir.murzin@arm.com, fabf@skynet.be, kuleshovmail@gmail.com, bhe@redhat.com
Cc: x86@kernel.org, tangchen@cn.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

memblock_overlaps_region() checks if the given memblock region
intersects a region in memblock. If so, it returns the index of
the intersected region.

But its only caller is memblock_is_region_reserved(), and it
returns 0 if false, non-zero if true.

Both of these should return bool.

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
---
 include/linux/memblock.h |  2 +-
 mm/memblock.c            | 10 +++++-----
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index cc4b019..d312ae3 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -323,7 +323,7 @@ void memblock_enforce_memory_limit(phys_addr_t memory_limit);
 int memblock_is_memory(phys_addr_t addr);
 int memblock_is_region_memory(phys_addr_t base, phys_addr_t size);
 int memblock_is_reserved(phys_addr_t addr);
-int memblock_is_region_reserved(phys_addr_t base, phys_addr_t size);
+bool memblock_is_region_reserved(phys_addr_t base, phys_addr_t size);
 
 extern void __memblock_dump_all(void);
 
diff --git a/mm/memblock.c b/mm/memblock.c
index 87108e7..f1e7100 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -91,7 +91,7 @@ static unsigned long __init_memblock memblock_addrs_overlap(phys_addr_t base1, p
 	return ((base1 < (base2 + size2)) && (base2 < (base1 + size1)));
 }
 
-static long __init_memblock memblock_overlaps_region(struct memblock_type *type,
+static bool __init_memblock memblock_overlaps_region(struct memblock_type *type,
 					phys_addr_t base, phys_addr_t size)
 {
 	unsigned long i;
@@ -103,7 +103,7 @@ static long __init_memblock memblock_overlaps_region(struct memblock_type *type,
 			break;
 	}
 
-	return (i < type->cnt) ? i : -1;
+	return i < type->cnt;
 }
 
 /*
@@ -1562,12 +1562,12 @@ int __init_memblock memblock_is_region_memory(phys_addr_t base, phys_addr_t size
  * Check if the region [@base, @base+@size) intersects a reserved memory block.
  *
  * RETURNS:
- * 0 if false, non-zero if true
+ * True if they intersect, false if not.
  */
-int __init_memblock memblock_is_region_reserved(phys_addr_t base, phys_addr_t size)
+bool __init_memblock memblock_is_region_reserved(phys_addr_t base, phys_addr_t size)
 {
 	memblock_cap_size(base, &size);
-	return memblock_overlaps_region(&memblock.reserved, base, size) >= 0;
+	return memblock_overlaps_region(&memblock.reserved, base, size);
 }
 
 void __init_memblock memblock_trim_memory(phys_addr_t align)
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
