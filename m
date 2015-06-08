Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 6156D6B006C
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 08:14:52 -0400 (EDT)
Received: by wifx6 with SMTP id x6so84480883wif.0
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 05:14:52 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v10si4788551wja.89.2015.06.08.05.07.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 08 Jun 2015 05:07:06 -0700 (PDT)
From: Juergen Gross <jgross@suse.com>
Subject: [Patch V4 16/16] xen: remove no longer needed p2m.h
Date: Mon,  8 Jun 2015 14:06:57 +0200
Message-Id: <1433765217-16333-17-git-send-email-jgross@suse.com>
In-Reply-To: <1433765217-16333-1-git-send-email-jgross@suse.com>
References: <1433765217-16333-1-git-send-email-jgross@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: xen-devel@lists.xensource.com, konrad.wilk@oracle.com, david.vrabel@citrix.com, boris.ostrovsky@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Juergen Gross <jgross@suse.com>

Cleanup by removing arch/x86/xen/p2m.h as it isn't needed any more.

Most definitions in this file are used in p2m.c only. Move those into
p2m.c.

set_phys_range_identity() is already declared in
arch/x86/include/asm/xen/page.h, add __init annotation there.

MAX_REMAP_RANGES isn't used at all, just delete it.

The only define left is P2M_PER_PAGE which is moved to page.h as well.

Signed-off-by: Juergen Gross <jgross@suse.com>
---
 arch/x86/include/asm/xen/page.h |  6 ++++--
 arch/x86/xen/p2m.c              |  6 +++++-
 arch/x86/xen/p2m.h              | 15 ---------------
 arch/x86/xen/setup.c            |  1 -
 4 files changed, 9 insertions(+), 19 deletions(-)
 delete mode 100644 arch/x86/xen/p2m.h

diff --git a/arch/x86/include/asm/xen/page.h b/arch/x86/include/asm/xen/page.h
index 10ef14b..a3804fb 100644
--- a/arch/x86/include/asm/xen/page.h
+++ b/arch/x86/include/asm/xen/page.h
@@ -35,6 +35,8 @@ typedef struct xpaddr {
 #define FOREIGN_FRAME(m)	((m) | FOREIGN_FRAME_BIT)
 #define IDENTITY_FRAME(m)	((m) | IDENTITY_FRAME_BIT)
 
+#define P2M_PER_PAGE		(PAGE_SIZE / sizeof(unsigned long))
+
 extern unsigned long *machine_to_phys_mapping;
 extern unsigned long  machine_to_phys_nr;
 extern unsigned long *xen_p2m_addr;
@@ -44,8 +46,8 @@ extern unsigned long  xen_max_p2m_pfn;
 extern unsigned long get_phys_to_machine(unsigned long pfn);
 extern bool set_phys_to_machine(unsigned long pfn, unsigned long mfn);
 extern bool __set_phys_to_machine(unsigned long pfn, unsigned long mfn);
-extern unsigned long set_phys_range_identity(unsigned long pfn_s,
-					     unsigned long pfn_e);
+extern unsigned long __init set_phys_range_identity(unsigned long pfn_s,
+						    unsigned long pfn_e);
 
 extern int set_foreign_p2m_mapping(struct gnttab_map_grant_ref *map_ops,
 				   struct gnttab_map_grant_ref *kmap_ops,
diff --git a/arch/x86/xen/p2m.c b/arch/x86/xen/p2m.c
index 365a64a..1f63ad2 100644
--- a/arch/x86/xen/p2m.c
+++ b/arch/x86/xen/p2m.c
@@ -78,10 +78,14 @@
 #include <xen/balloon.h>
 #include <xen/grant_table.h>
 
-#include "p2m.h"
 #include "multicalls.h"
 #include "xen-ops.h"
 
+#define P2M_MID_PER_PAGE	(PAGE_SIZE / sizeof(unsigned long *))
+#define P2M_TOP_PER_PAGE	(PAGE_SIZE / sizeof(unsigned long **))
+
+#define MAX_P2M_PFN	(P2M_TOP_PER_PAGE * P2M_MID_PER_PAGE * P2M_PER_PAGE)
+
 #define PMDS_PER_MID_PAGE	(P2M_MID_PER_PAGE / PTRS_PER_PTE)
 
 unsigned long *xen_p2m_addr __read_mostly;
diff --git a/arch/x86/xen/p2m.h b/arch/x86/xen/p2m.h
deleted file mode 100644
index ad8aee2..0000000
--- a/arch/x86/xen/p2m.h
+++ /dev/null
@@ -1,15 +0,0 @@
-#ifndef _XEN_P2M_H
-#define _XEN_P2M_H
-
-#define P2M_PER_PAGE        (PAGE_SIZE / sizeof(unsigned long))
-#define P2M_MID_PER_PAGE    (PAGE_SIZE / sizeof(unsigned long *))
-#define P2M_TOP_PER_PAGE    (PAGE_SIZE / sizeof(unsigned long **))
-
-#define MAX_P2M_PFN         (P2M_TOP_PER_PAGE * P2M_MID_PER_PAGE * P2M_PER_PAGE)
-
-#define MAX_REMAP_RANGES    10
-
-extern unsigned long __init set_phys_range_identity(unsigned long pfn_s,
-                                      unsigned long pfn_e);
-
-#endif  /* _XEN_P2M_H */
diff --git a/arch/x86/xen/setup.c b/arch/x86/xen/setup.c
index f960021..a1a77ea 100644
--- a/arch/x86/xen/setup.c
+++ b/arch/x86/xen/setup.c
@@ -30,7 +30,6 @@
 #include <xen/hvc-console.h>
 #include "xen-ops.h"
 #include "vdso.h"
-#include "p2m.h"
 #include "mmu.h"
 
 #define GB(x) ((uint64_t)(x) * 1024 * 1024 * 1024)
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
