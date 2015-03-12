Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id DBE0382905
	for <linux-mm@kvack.org>; Wed, 11 Mar 2015 23:14:08 -0400 (EDT)
Received: by pdev10 with SMTP id v10so16273882pde.13
        for <linux-mm@kvack.org>; Wed, 11 Mar 2015 20:14:08 -0700 (PDT)
Received: from na01-by2-obe.outbound.protection.outlook.com (mail-by2on0107.outbound.protection.outlook.com. [207.46.100.107])
        by mx.google.com with ESMTPS id i3si10534328pdg.111.2015.03.11.20.14.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 11 Mar 2015 20:14:08 -0700 (PDT)
From: Scott Wood <scottwood@freescale.com>
Subject: [PATCH 01/22] mm/memblock.c: %pF is only for function pointers
Date: Wed, 11 Mar 2015 22:13:36 -0500
Message-ID: <1426130037-17956-1-git-send-email-scottwood@freescale.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: trivial@kernel.org, linux-kernel@vger.kernel.org
Cc: Scott Wood <scottwood@freescale.com>, linux-mm@kvack.org

Use %pS for actual addresses, otherwise you'll get bad output
on arches like ppc64 where %pF expects a function descriptor.

Signed-off-by: Scott Wood <scottwood@freescale.com>
Cc: linux-mm@kvack.org
---
 mm/memblock.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index 252b77b..a7d4ff3 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -685,7 +685,7 @@ int __init_memblock memblock_remove(phys_addr_t base, phys_addr_t size)
 
 int __init_memblock memblock_free(phys_addr_t base, phys_addr_t size)
 {
-	memblock_dbg("   memblock_free: [%#016llx-%#016llx] %pF\n",
+	memblock_dbg("   memblock_free: [%#016llx-%#016llx] %pS\n",
 		     (unsigned long long)base,
 		     (unsigned long long)base + size - 1,
 		     (void *)_RET_IP_);
@@ -701,7 +701,7 @@ static int __init_memblock memblock_reserve_region(phys_addr_t base,
 {
 	struct memblock_type *_rgn = &memblock.reserved;
 
-	memblock_dbg("memblock_reserve: [%#016llx-%#016llx] flags %#02lx %pF\n",
+	memblock_dbg("memblock_reserve: [%#016llx-%#016llx] flags %#02lx %pS\n",
 		     (unsigned long long)base,
 		     (unsigned long long)base + size - 1,
 		     flags, (void *)_RET_IP_);
@@ -1218,7 +1218,7 @@ void * __init memblock_virt_alloc_try_nid_nopanic(
 				phys_addr_t min_addr, phys_addr_t max_addr,
 				int nid)
 {
-	memblock_dbg("%s: %llu bytes align=0x%llx nid=%d from=0x%llx max_addr=0x%llx %pF\n",
+	memblock_dbg("%s: %llu bytes align=0x%llx nid=%d from=0x%llx max_addr=0x%llx %pS\n",
 		     __func__, (u64)size, (u64)align, nid, (u64)min_addr,
 		     (u64)max_addr, (void *)_RET_IP_);
 	return memblock_virt_alloc_internal(size, align, min_addr,
@@ -1250,7 +1250,7 @@ void * __init memblock_virt_alloc_try_nid(
 {
 	void *ptr;
 
-	memblock_dbg("%s: %llu bytes align=0x%llx nid=%d from=0x%llx max_addr=0x%llx %pF\n",
+	memblock_dbg("%s: %llu bytes align=0x%llx nid=%d from=0x%llx max_addr=0x%llx %pS\n",
 		     __func__, (u64)size, (u64)align, nid, (u64)min_addr,
 		     (u64)max_addr, (void *)_RET_IP_);
 	ptr = memblock_virt_alloc_internal(size, align,
@@ -1274,7 +1274,7 @@ void * __init memblock_virt_alloc_try_nid(
  */
 void __init __memblock_free_early(phys_addr_t base, phys_addr_t size)
 {
-	memblock_dbg("%s: [%#016llx-%#016llx] %pF\n",
+	memblock_dbg("%s: [%#016llx-%#016llx] %pS\n",
 		     __func__, (u64)base, (u64)base + size - 1,
 		     (void *)_RET_IP_);
 	kmemleak_free_part(__va(base), size);
@@ -1294,7 +1294,7 @@ void __init __memblock_free_late(phys_addr_t base, phys_addr_t size)
 {
 	u64 cursor, end;
 
-	memblock_dbg("%s: [%#016llx-%#016llx] %pF\n",
+	memblock_dbg("%s: [%#016llx-%#016llx] %pS\n",
 		     __func__, (u64)base, (u64)base + size - 1,
 		     (void *)_RET_IP_);
 	kmemleak_free_part(__va(base), size);
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
