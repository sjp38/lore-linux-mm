Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f172.google.com (mail-ob0-f172.google.com [209.85.214.172])
	by kanga.kvack.org (Postfix) with ESMTP id 8C894280312
	for <linux-mm@kvack.org>; Thu, 16 Jul 2015 19:24:24 -0400 (EDT)
Received: by obbop1 with SMTP id op1so56508388obb.2
        for <linux-mm@kvack.org>; Thu, 16 Jul 2015 16:24:24 -0700 (PDT)
Received: from g4t3427.houston.hp.com (g4t3427.houston.hp.com. [15.201.208.55])
        by mx.google.com with ESMTPS id p8si7710610obk.41.2015.07.16.16.24.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Jul 2015 16:24:23 -0700 (PDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH RESEND 1/3] mm, x86: Fix warning in ioremap RAM check
Date: Thu, 16 Jul 2015 17:23:14 -0600
Message-Id: <1437088996-28511-2-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1437088996-28511-1-git-send-email-toshi.kani@hp.com>
References: <1437088996-28511-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, akpm@linux-foundation.org
Cc: travis@sgi.com, roland@purestorage.com, dan.j.williams@intel.com, mcgrof@suse.com, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Toshi Kani <toshi.kani@hp.com>, Borislav Petkov <bp@alien8.de>

__ioremap_caller() calls __ioremap_check_ram() through
walk_system_ram_range() to check if a target range is in RAM.
__ioremap_check_ram() has WARN_ONCE() in a wrong place where
it warns when the given range is not RAM.  This misplaced
warning is not exposed since walk_system_ram_range() only
calls __ioremap_check_ram() for RAM ranges.

Move the WARN_ONCE() to __ioremap_caller(), and update the
message to include the address range.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
Cc: Roland Dreier <roland@purestorage.com>
Cc: Luis R. Rodriguez <mcgrof@suse.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Borislav Petkov <bp@alien8.de>
---
 arch/x86/mm/ioremap.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/arch/x86/mm/ioremap.c b/arch/x86/mm/ioremap.c
index cc5ccc4..fd3df0d 100644
--- a/arch/x86/mm/ioremap.c
+++ b/arch/x86/mm/ioremap.c
@@ -63,8 +63,6 @@ static int __ioremap_check_ram(unsigned long start_pfn, unsigned long nr_pages,
 		    !PageReserved(pfn_to_page(start_pfn + i)))
 			return 1;
 
-	WARN_ONCE(1, "ioremap on RAM pfn 0x%lx\n", start_pfn);
-
 	return 0;
 }
 
@@ -131,8 +129,11 @@ static void __iomem *__ioremap_caller(resource_size_t phys_addr,
 		pfn      = phys_addr >> PAGE_SHIFT;
 		last_pfn = last_addr >> PAGE_SHIFT;
 		if (walk_system_ram_range(pfn, last_pfn - pfn + 1, NULL,
-					  __ioremap_check_ram) == 1)
+					  __ioremap_check_ram) == 1) {
+			WARN_ONCE(1, "ioremap on RAM at 0x%llx - 0x%llx\n",
+					phys_addr, last_addr);
 			return NULL;
+		}
 	}
 	/*
 	 * Mappings have to be page-aligned

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
