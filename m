Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f46.google.com (mail-lf0-f46.google.com [209.85.215.46])
	by kanga.kvack.org (Postfix) with ESMTP id 6B2316B0297
	for <linux-mm@kvack.org>; Thu,  4 Feb 2016 13:05:55 -0500 (EST)
Received: by mail-lf0-f46.google.com with SMTP id j78so41734760lfb.1
        for <linux-mm@kvack.org>; Thu, 04 Feb 2016 10:05:55 -0800 (PST)
Received: from mail-lb0-x22d.google.com (mail-lb0-x22d.google.com. [2a00:1450:4010:c04::22d])
        by mx.google.com with ESMTPS id rj5si7676922lbb.161.2016.02.04.10.05.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Feb 2016 10:05:54 -0800 (PST)
Received: by mail-lb0-x22d.google.com with SMTP id dx2so36042618lbd.3
        for <linux-mm@kvack.org>; Thu, 04 Feb 2016 10:05:53 -0800 (PST)
From: Alexander Kuleshov <kuleshovmail@gmail.com>
Subject: [PATCH] mm/memblock: remove unnecessary memblock_type variable
Date: Fri,  5 Feb 2016 00:01:50 +0600
Message-Id: <1454608910-7595-1-git-send-email-kuleshovmail@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tony Luck <tony.luck@intel.com>, Wei Yang <weiyang@linux.vnet.ibm.com>, Tang Chen <tangchen@cn.fujitsu.com>, Baoquan He <bhe@redhat.com>, Robin Holt <holt@sgi.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexander Kuleshov <kuleshovmail@gmail.com>

We define struct memblock_type *type in the memblock_add_region()
and memblock_reserve_region() functions only for passing it to the
memlock_add_range() and memblock_reserve_range() functions. Let's
remove these variables and will pass a type directly.

Signed-off-by: Alexander Kuleshov <kuleshovmail@gmail.com>
---
 mm/memblock.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index d2ed81e..edfae98 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -612,14 +612,12 @@ static int __init_memblock memblock_add_region(phys_addr_t base,
 						int nid,
 						unsigned long flags)
 {
-	struct memblock_type *type = &memblock.memory;
-
 	memblock_dbg("memblock_add: [%#016llx-%#016llx] flags %#02lx %pF\n",
 		     (unsigned long long)base,
 		     (unsigned long long)base + size - 1,
 		     flags, (void *)_RET_IP_);
 
-	return memblock_add_range(type, base, size, nid, flags);
+	return memblock_add_range(&memblock.memory, base, size, nid, flags);
 }
 
 int __init_memblock memblock_add(phys_addr_t base, phys_addr_t size)
@@ -740,14 +738,12 @@ static int __init_memblock memblock_reserve_region(phys_addr_t base,
 						   int nid,
 						   unsigned long flags)
 {
-	struct memblock_type *type = &memblock.reserved;
-
 	memblock_dbg("memblock_reserve: [%#016llx-%#016llx] flags %#02lx %pF\n",
 		     (unsigned long long)base,
 		     (unsigned long long)base + size - 1,
 		     flags, (void *)_RET_IP_);
 
-	return memblock_add_range(type, base, size, nid, flags);
+	return memblock_add_range(&memblock.reserved, base, size, nid, flags);
 }
 
 int __init_memblock memblock_reserve(phys_addr_t base, phys_addr_t size)
-- 
2.7.0.25.gfc10eb5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
