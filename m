Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 5341E6B009F
	for <linux-mm@kvack.org>; Tue,  8 Apr 2014 09:09:44 -0400 (EDT)
Received: by mail-wi0-f180.google.com with SMTP id q5so1304874wiv.13
        for <linux-mm@kvack.org>; Tue, 08 Apr 2014 06:09:42 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z42si2733107eel.182.2014.04.08.06.09.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 08 Apr 2014 06:09:41 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 5/5] x86: Allow Xen to enable NUMA_BALANCING
Date: Tue,  8 Apr 2014 14:09:30 +0100
Message-Id: <1396962570-18762-6-git-send-email-mgorman@suse.de>
In-Reply-To: <1396962570-18762-1-git-send-email-mgorman@suse.de>
References: <1396962570-18762-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-X86 <x86@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Cyrill Gorcunov <gorcunov@gmail.com>, Mel Gorman <mgorman@suse.de>, Peter Anvin <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Steven Noonan <steven@uplinklabs.net>, Rik van Riel <riel@redhat.com>, David Vrabel <david.vrabel@citrix.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Xen cannot use automatic NUMA balancing as they are depending on the same PTE
bit. There is another software bit that is currently used by software dirty
tracking of pages. This patch allows Xen to use that bit for automatic NUMA
balancing if MEM_SOFT_DIRTY is not enabled. If KMEMCHECK is enabled then
the bit is only set on global page tables so there should be no collision
with NUMA_BALANCING. This shuffling can be disabled if/when Xen moves away
from using _PAGE_BIT_IOMAP.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 arch/x86/Kconfig                     |  2 +-
 arch/x86/include/asm/pgtable_types.h | 14 +++++++++++++-
 2 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 4fab25a..3c4ba81 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -26,7 +26,7 @@ config X86
 	select ARCH_MIGHT_HAVE_PC_SERIO
 	select HAVE_AOUT if X86_32
 	select HAVE_UNSTABLE_SCHED_CLOCK
-	select ARCH_SUPPORTS_NUMA_BALANCING if X86_64 && !XEN
+	select ARCH_SUPPORTS_NUMA_BALANCING if X86_64 && (!XEN || !MEM_SOFT_DIRTY)
 	select ARCH_SUPPORTS_INT128 if X86_64
 	select ARCH_WANTS_PROT_NUMA_PROT_NONE
 	select HAVE_IDE
diff --git a/arch/x86/include/asm/pgtable_types.h b/arch/x86/include/asm/pgtable_types.h
index 49b3e15..fa84d1f 100644
--- a/arch/x86/include/asm/pgtable_types.h
+++ b/arch/x86/include/asm/pgtable_types.h
@@ -24,11 +24,23 @@
 #define _PAGE_BIT_CPA_TEST	_PAGE_BIT_SOFTW1
 #define _PAGE_BIT_SPLITTING	_PAGE_BIT_SOFTW1 /* only valid on a PSE pmd */
 #define _PAGE_BIT_IOMAP		_PAGE_BIT_SOFTW2 /* flag used to indicate IO mapping */
-#define _PAGE_BIT_NUMA		_PAGE_BIT_SOFTW2 /* for NUMA balancing hinting */
 #define _PAGE_BIT_HIDDEN	_PAGE_BIT_SOFTW3 /* hidden by kmemcheck */
 #define _PAGE_BIT_SOFT_DIRTY	_PAGE_BIT_SOFTW3 /* software dirty tracking */
 #define _PAGE_BIT_NX           63       /* No execute: only valid after cpuid check */
 
+/*
+ * Automatic NUMA balancing uses _PAGE_BIT_SOFTW2 if available as generally it
+ * is only used on the kernel page tables and is easily shared. Unfortunately,
+ * Xen also uses this bit so on those configurations it is necessary to use
+ * _PAGE_BIT_SOFTW3 but then MEM_SOFT_DIRTY cannot be enabled at the same time
+ * as it also requires that bit. Constraint is enforced by Kconfig.
+ */
+#ifndef CONFIG_XEN
+#define _PAGE_BIT_NUMA		_PAGE_BIT_SOFTW2
+#else
+#define _PAGE_BIT_NUMA		_PAGE_BIT_SOFTW3
+#endif
+
 /* If _PAGE_BIT_PRESENT is clear, we use these: */
 /* - if the user mapped it with PROT_NONE; pte_present gives true */
 #define _PAGE_BIT_PROTNONE	_PAGE_BIT_GLOBAL
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
