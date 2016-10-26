Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8E3C56B0276
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 09:42:31 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id q6so14622464wmg.15
        for <linux-mm@kvack.org>; Wed, 26 Oct 2016 06:42:31 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a10si2563856wjd.63.2016.10.26.06.42.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 26 Oct 2016 06:42:30 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH] mm, frontswap: make sure allocated frontswap map is assigned
Date: Wed, 26 Oct 2016 15:42:20 +0200
Message-Id: <20161026134220.2566-1-vbabka@suse.cz>
In-Reply-To: <633c9485-d150-03ac-d0d3-827ad24c514d@de.ibm.com>
References: <633c9485-d150-03ac-d0d3-827ad24c514d@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Christian Borntraeger <borntraeger@de.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, stable@vger.kernel.org, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, David Vrabel <david.vrabel@citrix.com>, Juergen Gross <jgross@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Christian Borntraeger reports:

with commit 8ea1d2a1985a7ae096e ("mm, frontswap: convert frontswap_enabled to
static key") kmemleak complains about a memory leak in swapon

unreferenced object 0x3e09ba56000 (size 32112640):
  comm "swapon", pid 7852, jiffies 4294968787 (age 1490.770s)
  hex dump (first 32 bytes):
    00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
    00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
  backtrace:
    [<00000000003a2504>] __vmalloc_node_range+0x194/0x2d8
    [<00000000003a2918>] vzalloc+0x58/0x68
    [<00000000003b0af0>] SyS_swapon+0xd60/0x12f8
    [<0000000000a3dc2e>] system_call+0xd6/0x270
    [<ffffffffffffffff>] 0xffffffffffffffff

Turns out kmemleak is right. We now allocate the frontswap map depending on the
kernel config (and no longer on the enablement)

swapfile.c:
[...]
      if (IS_ENABLED(CONFIG_FRONTSWAP))
                frontswap_map = vzalloc(BITS_TO_LONGS(maxpages) * sizeof(long));

but later on this is passed along
--> enable_swap_info(p, prio, swap_map, cluster_info, frontswap_map);

and ignored if frontswap is disabled
--> frontswap_init(p->type, frontswap_map);
static inline void frontswap_init(unsigned type, unsigned long *map)
{
        if (frontswap_enabled())
                __frontswap_init(type, map);
}

Thing is, that frontswap map is never freed.

===

The leakage is relatively not that bad, because swapon is an infrequent and
privileged operation. However, if the first frontswap backend is registered
after a swap type has been already enabled, it will WARN_ON in
frontswap_register_ops() and frontswap will not be available for the swap type.

Fix this by making sure the map is assigned by frontswap_init() as long as
CONFIG_FRONTSWAP is enabled.

Reported-by: Christian Borntraeger <borntraeger@de.ibm.com>
Fixes: 8ea1d2a1985a ("mm, frontswap: convert frontswap_enabled to static key")
Cc: stable@vger.kernel.org
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Cc: David Vrabel <david.vrabel@citrix.com>
Cc: Juergen Gross <jgross@suse.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 include/linux/frontswap.h | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/include/linux/frontswap.h b/include/linux/frontswap.h
index c46d2aa16d81..1d18af034554 100644
--- a/include/linux/frontswap.h
+++ b/include/linux/frontswap.h
@@ -106,8 +106,9 @@ static inline void frontswap_invalidate_area(unsigned type)
 
 static inline void frontswap_init(unsigned type, unsigned long *map)
 {
-	if (frontswap_enabled())
-		__frontswap_init(type, map);
+#ifdef CONFIG_FRONTSWAP
+	__frontswap_init(type, map);
+#endif
 }
 
 #endif /* _LINUX_FRONTSWAP_H */
-- 
2.10.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
