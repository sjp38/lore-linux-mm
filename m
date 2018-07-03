Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 97A986B026A
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 13:05:54 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id c2-v6so1169969edi.20
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 10:05:54 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id n12-v6si1432217edr.216.2018.07.03.10.05.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jul 2018 10:05:52 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w63H5hk2000669
	for <linux-mm@kvack.org>; Tue, 3 Jul 2018 13:05:50 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2k0bhq4mn4-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 03 Jul 2018 13:05:49 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Tue, 3 Jul 2018 18:05:14 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH] mm/memblock: replace u64 with phys_addr_t where appropriate
Date: Tue,  3 Jul 2018 20:05:06 +0300
Message-Id: <1530637506-1256-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Michal Hocko <mhocko@kernel.org>, Matthew Wilcox <willy@infradead.org>

Most functions in memblock already use phys_addr_t to represent a physical
address with __memblock_free_late() being an exception.

This patch replaces u64 with phys_addr_t in __memblock_free_late() and
switches several format strings from %llx to %pa to avoid casting from
phys_addr_t to u64.

CC: Michal Hocko <mhocko@kernel.org>
CC: Matthew Wilcox <willy@infradead.org>
Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 mm/memblock.c | 46 +++++++++++++++++++++++-----------------------
 1 file changed, 23 insertions(+), 23 deletions(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index 03d48d8..20ad8e9 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -330,7 +330,7 @@ static int __init_memblock memblock_double_array(struct memblock_type *type,
 {
 	struct memblock_region *new_array, *old_array;
 	phys_addr_t old_alloc_size, new_alloc_size;
-	phys_addr_t old_size, new_size, addr;
+	phys_addr_t old_size, new_size, addr, new_end;
 	int use_slab = slab_is_available();
 	int *in_slab;
 
@@ -391,9 +391,9 @@ static int __init_memblock memblock_double_array(struct memblock_type *type,
 		return -1;
 	}
 
-	memblock_dbg("memblock: %s is doubled to %ld at [%#010llx-%#010llx]",
-			type->name, type->max * 2, (u64)addr,
-			(u64)addr + new_size - 1);
+	new_end = addr + new_size - 1;
+	memblock_dbg("memblock: %s is doubled to %ld at [%pa-%pa]",
+			type->name, type->max * 2, &addr, &new_end);
 
 	/*
 	 * Found space, we now need to move the array over before we add the
@@ -1343,9 +1343,9 @@ void * __init memblock_virt_alloc_try_nid_raw(
 {
 	void *ptr;
 
-	memblock_dbg("%s: %llu bytes align=0x%llx nid=%d from=0x%llx max_addr=0x%llx %pF\n",
-		     __func__, (u64)size, (u64)align, nid, (u64)min_addr,
-		     (u64)max_addr, (void *)_RET_IP_);
+	memblock_dbg("%s: %llu bytes align=0x%llx nid=%d from=%pa max_addr=%pa %pF\n",
+		     __func__, (u64)size, (u64)align, nid, &min_addr,
+		     &max_addr, (void *)_RET_IP_);
 
 	ptr = memblock_virt_alloc_internal(size, align,
 					   min_addr, max_addr, nid);
@@ -1380,9 +1380,9 @@ void * __init memblock_virt_alloc_try_nid_nopanic(
 {
 	void *ptr;
 
-	memblock_dbg("%s: %llu bytes align=0x%llx nid=%d from=0x%llx max_addr=0x%llx %pF\n",
-		     __func__, (u64)size, (u64)align, nid, (u64)min_addr,
-		     (u64)max_addr, (void *)_RET_IP_);
+	memblock_dbg("%s: %llu bytes align=0x%llx nid=%d from=%pa max_addr=%pa %pF\n",
+		     __func__, (u64)size, (u64)align, nid, &min_addr,
+		     &max_addr, (void *)_RET_IP_);
 
 	ptr = memblock_virt_alloc_internal(size, align,
 					   min_addr, max_addr, nid);
@@ -1416,9 +1416,9 @@ void * __init memblock_virt_alloc_try_nid(
 {
 	void *ptr;
 
-	memblock_dbg("%s: %llu bytes align=0x%llx nid=%d from=0x%llx max_addr=0x%llx %pF\n",
-		     __func__, (u64)size, (u64)align, nid, (u64)min_addr,
-		     (u64)max_addr, (void *)_RET_IP_);
+	memblock_dbg("%s: %llu bytes align=0x%llx nid=%d from=%pa max_addr=%pa %pF\n",
+		     __func__, (u64)size, (u64)align, nid, &min_addr,
+		     &max_addr, (void *)_RET_IP_);
 	ptr = memblock_virt_alloc_internal(size, align,
 					   min_addr, max_addr, nid);
 	if (ptr) {
@@ -1426,9 +1426,8 @@ void * __init memblock_virt_alloc_try_nid(
 		return ptr;
 	}
 
-	panic("%s: Failed to allocate %llu bytes align=0x%llx nid=%d from=0x%llx max_addr=0x%llx\n",
-	      __func__, (u64)size, (u64)align, nid, (u64)min_addr,
-	      (u64)max_addr);
+	panic("%s: Failed to allocate %llu bytes align=0x%llx nid=%d from=%pa max_addr=%pa\n",
+	      __func__, (u64)size, (u64)align, nid, &min_addr, &max_addr);
 	return NULL;
 }
 
@@ -1442,9 +1441,10 @@ void * __init memblock_virt_alloc_try_nid(
  */
 void __init __memblock_free_early(phys_addr_t base, phys_addr_t size)
 {
-	memblock_dbg("%s: [%#016llx-%#016llx] %pF\n",
-		     __func__, (u64)base, (u64)base + size - 1,
-		     (void *)_RET_IP_);
+	phys_addr_t end = base + size - 1;
+
+	memblock_dbg("%s: [%pa-%pa] %pF\n",
+		     __func__, &base, &end, (void *)_RET_IP_);
 	kmemleak_free_part_phys(base, size);
 	memblock_remove_range(&memblock.reserved, base, size);
 }
@@ -1460,11 +1460,11 @@ void __init __memblock_free_early(phys_addr_t base, phys_addr_t size)
  */
 void __init __memblock_free_late(phys_addr_t base, phys_addr_t size)
 {
-	u64 cursor, end;
+	phys_addr_t cursor, end;
 
-	memblock_dbg("%s: [%#016llx-%#016llx] %pF\n",
-		     __func__, (u64)base, (u64)base + size - 1,
-		     (void *)_RET_IP_);
+	end = base + size - 1;
+	memblock_dbg("%s: [%pa-%pa] %pF\n",
+		     __func__, &base, &end, (void *)_RET_IP_);
 	kmemleak_free_part_phys(base, size);
 	cursor = PFN_UP(base);
 	end = PFN_DOWN(base + size);
-- 
2.7.4
