Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	by kanga.kvack.org (Postfix) with ESMTP id 137626B0037
	for <linux-mm@kvack.org>; Fri, 29 Aug 2014 15:53:33 -0400 (EDT)
Received: by mail-ig0-f175.google.com with SMTP id uq10so10186593igb.14
        for <linux-mm@kvack.org>; Fri, 29 Aug 2014 12:53:32 -0700 (PDT)
Received: from relay.sgi.com (relay3.sgi.com. [192.48.152.1])
        by mx.google.com with ESMTP id y8si978547icx.94.2014.08.29.12.53.32
        for <linux-mm@kvack.org>;
        Fri, 29 Aug 2014 12:53:32 -0700 (PDT)
Message-Id: <20140829195328.888414588@asylum.americas.sgi.com>
References: <20140829195328.511550688@asylum.americas.sgi.com>
Date: Fri, 29 Aug 2014 14:53:30 -0500
From: Mike Travis <travis@sgi.com>
Subject: [PATCH 2/2] x86: Use optimized ioresource lookup in ioremap function
Content-Disposition: inline; filename=use-get-resource-type
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mingo@redhat.com, tglx@linutronix.de, hpa@zytor.com
Cc: akpm@linux-foundation.org, msalter@redhat.com, dyoung@redhat.com, riel@redhat.com, peterz@infradead.org, mgorman@suse.de, linux-kernel@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org, Alex Thorlton <athorlton@sgi.com>, stable@vger.kernel.org

This patch uses the optimized ioresource lookup, "region_is_ram", for
the ioremap function.  If the region is not found, it falls back to the
"page_is_ram" function.  If it is found and it is RAM, then the usual
warning message is issued, and the ioremap operation is aborted.
Otherwise, the ioremap operation continues.

Signed-off-by: Mike Travis <travis@sgi.com>
Acked-by: Alex Thorlton <athorlton@sgi.com>
Reviewed-by: Cliff Wickman <cpw@sgi.com>
Cc: <stable@vger.kernel.org>
---
v2: slight rearrangement of code
v3: added Cc: stable
---
 arch/x86/mm/ioremap.c |   20 ++++++++++++++++----
 1 file changed, 16 insertions(+), 4 deletions(-)

--- linux.orig/arch/x86/mm/ioremap.c
+++ linux/arch/x86/mm/ioremap.c
@@ -86,6 +86,7 @@ static void __iomem *__ioremap_caller(re
 	pgprot_t prot;
 	int retval;
 	void __iomem *ret_addr;
+	int ram_region;
 
 	/* Don't allow wraparound or zero size */
 	last_addr = phys_addr + size - 1;
@@ -108,12 +109,23 @@ static void __iomem *__ioremap_caller(re
 	/*
 	 * Don't allow anybody to remap normal RAM that we're using..
 	 */
-	pfn      = phys_addr >> PAGE_SHIFT;
-	last_pfn = last_addr >> PAGE_SHIFT;
-	if (walk_system_ram_range(pfn, last_pfn - pfn + 1, NULL,
-				  __ioremap_check_ram) == 1)
+	/* First check if whole region can be identified as RAM or not */
+	ram_region = region_is_ram(phys_addr, size);
+	if (ram_region > 0) {
+		WARN_ONCE(1, "ioremap on RAM at 0x%lx - 0x%lx\n",
+				(unsigned long int)phys_addr,
+				(unsigned long int)last_addr);
 		return NULL;
+	}
 
+	/* If could not be identified(-1), check page by page */
+	if (ram_region < 0) {
+		pfn      = phys_addr >> PAGE_SHIFT;
+		last_pfn = last_addr >> PAGE_SHIFT;
+		if (walk_system_ram_range(pfn, last_pfn - pfn + 1, NULL,
+					  __ioremap_check_ram) == 1)
+			return NULL;
+	}
 	/*
 	 * Mappings have to be page-aligned
 	 */

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
