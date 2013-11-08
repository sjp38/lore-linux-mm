Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 846E36B025E
	for <linux-mm@kvack.org>; Fri,  8 Nov 2013 18:43:39 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id hz1so2868940pad.30
        for <linux-mm@kvack.org>; Fri, 08 Nov 2013 15:43:39 -0800 (PST)
Received: from psmtp.com ([74.125.245.185])
        by mx.google.com with SMTP id kg8si8460943pad.96.2013.11.08.15.43.33
        for <linux-mm@kvack.org>;
        Fri, 08 Nov 2013 15:43:34 -0800 (PST)
From: Santosh Shilimkar <santosh.shilimkar@ti.com>
Subject: [PATCH 24/24] mm/ARM: OMAP: Use memblock apis for early memory allocations
Date: Fri, 8 Nov 2013 18:42:00 -0500
Message-ID: <1383954120-24368-25-git-send-email-santosh.shilimkar@ti.com>
In-Reply-To: <1383954120-24368-1-git-send-email-santosh.shilimkar@ti.com>
References: <1383954120-24368-1-git-send-email-santosh.shilimkar@ti.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tj@kernel.org, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, Santosh Shilimkar <santosh.shilimkar@ti.com>, Yinghai Lu <yinghai@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Paul Walmsley <paul@pwsan.com>, Tony Lindgren <tony@atomide.com>

Switch to memblock interfaces for early memory allocator instead of
bootmem allocator. No functional change in beahvior than what it is
in current code from bootmem users points of view.

Archs already converted to NO_BOOTMEM now directly use memblock
interfaces instead of bootmem wrappers build on top of memblock. And the
archs which still uses bootmem, these new apis just fallback to exiting
bootmem APIs.

Cc: Yinghai Lu <yinghai@kernel.org>
Cc: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Paul Walmsley <paul@pwsan.com>
Cc: Tony Lindgren <tony@atomide.com>

Signed-off-by: Santosh Shilimkar <santosh.shilimkar@ti.com>
---
 arch/arm/mach-omap2/omap_hwmod.c |    8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/arch/arm/mach-omap2/omap_hwmod.c b/arch/arm/mach-omap2/omap_hwmod.c
index d9ee0ff..0a3a048 100644
--- a/arch/arm/mach-omap2/omap_hwmod.c
+++ b/arch/arm/mach-omap2/omap_hwmod.c
@@ -2676,9 +2676,7 @@ static int __init _alloc_links(struct omap_hwmod_link **ml,
 	sz = sizeof(struct omap_hwmod_link) * LINKS_PER_OCP_IF;
 
 	*sl = NULL;
-	*ml = alloc_bootmem(sz);
-
-	memset(*ml, 0, sz);
+	*ml = memblock_virt_alloc(sz);
 
 	*sl = (void *)(*ml) + sizeof(struct omap_hwmod_link);
 
@@ -2797,9 +2795,7 @@ static int __init _alloc_linkspace(struct omap_hwmod_ocp_if **ois)
 	pr_debug("omap_hwmod: %s: allocating %d byte linkspace (%d links)\n",
 		 __func__, sz, max_ls);
 
-	linkspace = alloc_bootmem(sz);
-
-	memset(linkspace, 0, sz);
+	linkspace = memblock_virt_alloc(sz);
 
 	return 0;
 }
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
