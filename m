Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f179.google.com (mail-ob0-f179.google.com [209.85.214.179])
	by kanga.kvack.org (Postfix) with ESMTP id 3DEED280309
	for <linux-mm@kvack.org>; Thu, 16 Jul 2015 19:24:24 -0400 (EDT)
Received: by obbgp5 with SMTP id gp5so56528699obb.0
        for <linux-mm@kvack.org>; Thu, 16 Jul 2015 16:24:24 -0700 (PDT)
Received: from g9t5008.houston.hp.com (g9t5008.houston.hp.com. [15.240.92.66])
        by mx.google.com with ESMTPS id ro6si7662369oeb.104.2015.07.16.16.24.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Jul 2015 16:24:23 -0700 (PDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH RESEND 2/3] mm, x86: Remove region_is_ram() call from ioremap
Date: Thu, 16 Jul 2015 17:23:15 -0600
Message-Id: <1437088996-28511-3-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1437088996-28511-1-git-send-email-toshi.kani@hp.com>
References: <1437088996-28511-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, akpm@linux-foundation.org
Cc: travis@sgi.com, roland@purestorage.com, dan.j.williams@intel.com, mcgrof@suse.com, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Toshi Kani <toshi.kani@hp.com>, Borislav Petkov <bp@alien8.de>

__ioremap_caller() calls region_is_ram() to walk through the
iomem_resource table to check if a target range is in RAM, which
was added to improve the lookup performance over page_is_ram()
(commit 906e36c5c717 "x86: use optimized ioresource lookup in
ioremap function").  page_is_ram() was no longer used when this
change was added, though.

__ioremap_caller() then calls walk_system_ram_range(), which had
replaced page_is_ram() to improve the lookup performance (commit
c81c8a1eeede "x86, ioremap: Speed up check for RAM pages").

Since both checks walk through the same iomem_resource table for
the same purpose, there is no need to call the two functions.
Furthermore, region_is_ram() always returns with -1, which makes
walk_system_ram_range() as the only check being used at this point.

Therefore, this patch changes __ioremap_caller() to call
walk_system_ram_range() only.

Note, removing the call to region_is_ram() is also necessary to
fix bugs in region_is_ram().  walk_system_ram_range() requires
RAM ranges be page-aligned in the iomem_resource table to work
properly.  This restriction has allowed multiple ioremaps to RAM
(setup_data) which are page-unaligned.  Using fixed region_is_ram()
will cause these callers to start failing.  After all ioremap
callers to setup_data are converted, __ioremap_caller() may call
region_is_ram() instead to remove this restriction.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
Cc: Roland Dreier <roland@purestorage.com>
Cc: Mike Travis <travis@sgi.com>
Cc: Luis R. Rodriguez <mcgrof@suse.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Borislav Petkov <bp@alien8.de>
---
 arch/x86/mm/ioremap.c |   24 ++++++------------------
 1 file changed, 6 insertions(+), 18 deletions(-)

diff --git a/arch/x86/mm/ioremap.c b/arch/x86/mm/ioremap.c
index fd3df0d..b9d4a33 100644
--- a/arch/x86/mm/ioremap.c
+++ b/arch/x86/mm/ioremap.c
@@ -92,7 +92,6 @@ static void __iomem *__ioremap_caller(resource_size_t phys_addr,
 	pgprot_t prot;
 	int retval;
 	void __iomem *ret_addr;
-	int ram_region;
 
 	/* Don't allow wraparound or zero size */
 	last_addr = phys_addr + size - 1;
@@ -115,26 +114,15 @@ static void __iomem *__ioremap_caller(resource_size_t phys_addr,
 	/*
 	 * Don't allow anybody to remap normal RAM that we're using..
 	 */
-	/* First check if whole region can be identified as RAM or not */
-	ram_region = region_is_ram(phys_addr, size);
-	if (ram_region > 0) {
-		WARN_ONCE(1, "ioremap on RAM at 0x%lx - 0x%lx\n",
-				(unsigned long int)phys_addr,
-				(unsigned long int)last_addr);
-		return NULL;
-	}
-
-	/* If could not be identified(-1), check page by page */
-	if (ram_region < 0) {
-		pfn      = phys_addr >> PAGE_SHIFT;
-		last_pfn = last_addr >> PAGE_SHIFT;
-		if (walk_system_ram_range(pfn, last_pfn - pfn + 1, NULL,
+	pfn      = phys_addr >> PAGE_SHIFT;
+	last_pfn = last_addr >> PAGE_SHIFT;
+	if (walk_system_ram_range(pfn, last_pfn - pfn + 1, NULL,
 					  __ioremap_check_ram) == 1) {
-			WARN_ONCE(1, "ioremap on RAM at 0x%llx - 0x%llx\n",
+		WARN_ONCE(1, "ioremap on RAM at 0x%llx - 0x%llx\n",
 					phys_addr, last_addr);
-			return NULL;
-		}
+		return NULL;
 	}
+
 	/*
 	 * Mappings have to be page-aligned
 	 */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
