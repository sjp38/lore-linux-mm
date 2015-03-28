Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f50.google.com (mail-la0-f50.google.com [209.85.215.50])
	by kanga.kvack.org (Postfix) with ESMTP id F2E586B0038
	for <linux-mm@kvack.org>; Sat, 28 Mar 2015 13:08:19 -0400 (EDT)
Received: by labto5 with SMTP id to5so91318778lab.0
        for <linux-mm@kvack.org>; Sat, 28 Mar 2015 10:08:19 -0700 (PDT)
Received: from mail-lb0-x231.google.com (mail-lb0-x231.google.com. [2a00:1450:4010:c04::231])
        by mx.google.com with ESMTPS id o12si2070043lal.67.2015.03.28.10.08.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 28 Mar 2015 10:08:18 -0700 (PDT)
Received: by lbcmq2 with SMTP id mq2so82657999lbc.0
        for <linux-mm@kvack.org>; Sat, 28 Mar 2015 10:08:17 -0700 (PDT)
From: Alexander Kuleshov <kuleshovmail@gmail.com>
Subject: [PATCH] mm/memblock: add debug output for the memblock_add
Date: Sat, 28 Mar 2015 23:08:03 +0600
Message-Id: <1427562483-29839-1-git-send-email-kuleshovmail@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Philipp Hachtmann <phacht@linux.vnet.ibm.com>, Fabian Frederick <fabf@skynet.be>, Catalin Marinas <catalin.marinas@arm.com>, Emil Medve <Emilian.Medve@freescale.com>, Akinobu Mita <akinobu.mita@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, Tony Luck <tony.luck@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexander Kuleshov <kuleshovmail@gmail.com>

memblock_reserve function calls memblock_reserve_region which
prints debugging information if 'memblock=debug' passed to the
command line. This patch adds the same behaviour, but for the 
memblock_add function.

Signed-off-by: Alexander Kuleshov <kuleshovmail@gmail.com>
---
 mm/memblock.c | 18 ++++++++++++++++--
 1 file changed, 16 insertions(+), 2 deletions(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index 252b77b..c7b8306 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -580,10 +580,24 @@ int __init_memblock memblock_add_node(phys_addr_t base, phys_addr_t size,
 	return memblock_add_range(&memblock.memory, base, size, nid, 0);
 }
 
+static int __init_memblock memblock_add_region(phys_addr_t base,
+						phys_addr_t size,
+						int nid,
+						unsigned long flags)
+{
+	struct memblock_type *_rgn = &memblock.memory;
+
+	memblock_dbg("memblock_memory: [%#016llx-%#016llx] flags %#02lx %pF\n",
+		     (unsigned long long)base,
+		     (unsigned long long)base + size - 1,
+		     flags, (void *)_RET_IP_);
+
+	return memblock_add_range(_rgn, base, size, nid, flags);
+}
+
 int __init_memblock memblock_add(phys_addr_t base, phys_addr_t size)
 {
-	return memblock_add_range(&memblock.memory, base, size,
-				   MAX_NUMNODES, 0);
+	return memblock_add_region(base, size, MAX_NUMNODES, 0);
 }
 
 /**
-- 
2.3.3.611.g09038fc.dirty

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
