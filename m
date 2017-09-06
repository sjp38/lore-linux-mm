Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 44AEC2802FE
	for <linux-mm@kvack.org>; Wed,  6 Sep 2017 16:34:06 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id v109so7947349wrc.5
        for <linux-mm@kvack.org>; Wed, 06 Sep 2017 13:34:06 -0700 (PDT)
Received: from mout.gmx.net (mout.gmx.net. [212.227.15.15])
        by mx.google.com with ESMTPS id v9si1950902wmg.166.2017.09.06.13.34.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Sep 2017 13:34:05 -0700 (PDT)
From: Helge Deller <deller@gmx.de>
Subject: [PATCH 12/14] mm/memblock: Use %pS printk format for direct addresses
Date: Wed,  6 Sep 2017 22:27:59 +0200
Message-Id: <1504729681-3504-13-git-send-email-deller@gmx.de>
In-Reply-To: <1504729681-3504-1-git-send-email-deller@gmx.de>
References: <1504729681-3504-1-git-send-email-deller@gmx.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Petr Mladek <pmladek@suse.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

The debug code in memblock uses wrongly the %pF instead of the %pS printk
format specifier for printing symbols for the address returned by
_builtin_return_address(0)/_RET_IP_. Fix it for the ia64, ppc64 and parisc64
architectures.

Signed-off-by: Helge Deller <deller@gmx.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
---
 mm/memblock.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index 9120578..7f1590d 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -597,7 +597,7 @@ int __init_memblock memblock_add(phys_addr_t base, phys_addr_t size)
 {
 	phys_addr_t end = base + size - 1;
 
-	memblock_dbg("memblock_add: [%pa-%pa] %pF\n",
+	memblock_dbg("memblock_add: [%pa-%pa] %pS\n",
 		     &base, &end, (void *)_RET_IP_);
 
 	return memblock_add_range(&memblock.memory, base, size, MAX_NUMNODES, 0);
@@ -704,7 +704,7 @@ int __init_memblock memblock_free(phys_addr_t base, phys_addr_t size)
 {
 	phys_addr_t end = base + size - 1;
 
-	memblock_dbg("   memblock_free: [%pa-%pa] %pF\n",
+	memblock_dbg("   memblock_free: [%pa-%pa] %pS\n",
 		     &base, &end, (void *)_RET_IP_);
 
 	kmemleak_free_part_phys(base, size);
@@ -715,7 +715,7 @@ int __init_memblock memblock_reserve(phys_addr_t base, phys_addr_t size)
 {
 	phys_addr_t end = base + size - 1;
 
-	memblock_dbg("memblock_reserve: [%pa-%pa] %pF\n",
+	memblock_dbg("memblock_reserve: [%pa-%pa] %pS\n",
 		     &base, &end, (void *)_RET_IP_);
 
 	return memblock_add_range(&memblock.reserved, base, size, MAX_NUMNODES, 0);
@@ -1362,7 +1362,7 @@ void * __init memblock_virt_alloc_try_nid_nopanic(
 				phys_addr_t min_addr, phys_addr_t max_addr,
 				int nid)
 {
-	memblock_dbg("%s: %llu bytes align=0x%llx nid=%d from=0x%llx max_addr=0x%llx %pF\n",
+	memblock_dbg("%s: %llu bytes align=0x%llx nid=%d from=0x%llx max_addr=0x%llx %pS\n",
 		     __func__, (u64)size, (u64)align, nid, (u64)min_addr,
 		     (u64)max_addr, (void *)_RET_IP_);
 	return memblock_virt_alloc_internal(size, align, min_addr,
@@ -1394,7 +1394,7 @@ void * __init memblock_virt_alloc_try_nid(
 {
 	void *ptr;
 
-	memblock_dbg("%s: %llu bytes align=0x%llx nid=%d from=0x%llx max_addr=0x%llx %pF\n",
+	memblock_dbg("%s: %llu bytes align=0x%llx nid=%d from=0x%llx max_addr=0x%llx %pS\n",
 		     __func__, (u64)size, (u64)align, nid, (u64)min_addr,
 		     (u64)max_addr, (void *)_RET_IP_);
 	ptr = memblock_virt_alloc_internal(size, align,
@@ -1418,7 +1418,7 @@ void * __init memblock_virt_alloc_try_nid(
  */
 void __init __memblock_free_early(phys_addr_t base, phys_addr_t size)
 {
-	memblock_dbg("%s: [%#016llx-%#016llx] %pF\n",
+	memblock_dbg("%s: [%#016llx-%#016llx] %pS\n",
 		     __func__, (u64)base, (u64)base + size - 1,
 		     (void *)_RET_IP_);
 	kmemleak_free_part_phys(base, size);
@@ -1438,7 +1438,7 @@ void __init __memblock_free_late(phys_addr_t base, phys_addr_t size)
 {
 	u64 cursor, end;
 
-	memblock_dbg("%s: [%#016llx-%#016llx] %pF\n",
+	memblock_dbg("%s: [%#016llx-%#016llx] %pS\n",
 		     __func__, (u64)base, (u64)base + size - 1,
 		     (void *)_RET_IP_);
 	kmemleak_free_part_phys(base, size);
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
