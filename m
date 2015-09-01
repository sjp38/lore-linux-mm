Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f52.google.com (mail-la0-f52.google.com [209.85.215.52])
	by kanga.kvack.org (Postfix) with ESMTP id BDA2D6B0254
	for <linux-mm@kvack.org>; Tue,  1 Sep 2015 10:27:50 -0400 (EDT)
Received: by laeb10 with SMTP id b10so864259lae.1
        for <linux-mm@kvack.org>; Tue, 01 Sep 2015 07:27:50 -0700 (PDT)
Received: from mail-la0-x22d.google.com (mail-la0-x22d.google.com. [2a00:1450:4010:c03::22d])
        by mx.google.com with ESMTPS id do10si16553961lac.73.2015.09.01.07.27.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Sep 2015 07:27:49 -0700 (PDT)
Received: by lamp12 with SMTP id p12so923913lam.0
        for <linux-mm@kvack.org>; Tue, 01 Sep 2015 07:27:49 -0700 (PDT)
From: Alexander Kuleshov <kuleshovmail@gmail.com>
Subject: [PATCH 1/5 v2] mm/memblock: Introduce memblock_first_region_size() helper
Date: Tue,  1 Sep 2015 20:27:11 +0600
Message-Id: <1441117631-30589-1-git-send-email-kuleshovmail@gmail.com>
In-Reply-To: <1441117527-30466-1-git-send-email-kuleshovmail@gmail.com>
References: <1441117527-30466-1-git-send-email-kuleshovmail@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Xishi Qiu <qiuxishi@huawei.com>, Robin Holt <holt@sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexander Kuleshov <kuleshovmail@gmail.com>

Some architectures (like s390, microblaze and etc...) require size
of the first memory region. This patch provides new memblock_first_region_size()
helper for this case.

Signed-off-by: Alexander Kuleshov <kuleshovmail@gmail.com>
---
 include/linux/memblock.h | 1 +
 mm/memblock.c            | 5 +++++
 2 files changed, 6 insertions(+)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index cc4b019..8a481e5 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -319,6 +319,7 @@ phys_addr_t memblock_phys_mem_size(void);
 phys_addr_t memblock_mem_size(unsigned long limit_pfn);
 phys_addr_t memblock_start_of_DRAM(void);
 phys_addr_t memblock_end_of_DRAM(void);
+phys_addr_t memblock_first_region_size(void);
 void memblock_enforce_memory_limit(phys_addr_t memory_limit);
 int memblock_is_memory(phys_addr_t addr);
 int memblock_is_region_memory(phys_addr_t base, phys_addr_t size);
diff --git a/mm/memblock.c b/mm/memblock.c
index 87108e7..fb4b7ca 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -1463,6 +1463,11 @@ phys_addr_t __init_memblock memblock_end_of_DRAM(void)
 	return (memblock.memory.regions[idx].base + memblock.memory.regions[idx].size);
 }
 
+phys_addr_t __init_memblock memblock_first_region_size(void)
+{
+	return memblock.memory.regions[0].size;
+}
+
 void __init memblock_enforce_memory_limit(phys_addr_t limit)
 {
 	phys_addr_t max_addr = (phys_addr_t)ULLONG_MAX;
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
