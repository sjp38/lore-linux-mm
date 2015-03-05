Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f173.google.com (mail-ie0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id 64CB26B006E
	for <linux-mm@kvack.org>; Thu,  5 Mar 2015 10:44:51 -0500 (EST)
Received: by iecrp18 with SMTP id rp18so9611893iec.10
        for <linux-mm@kvack.org>; Thu, 05 Mar 2015 07:44:51 -0800 (PST)
Received: from g2t2354.austin.hp.com (g2t2354.austin.hp.com. [15.217.128.53])
        by mx.google.com with ESMTPS id e42si8937452iod.90.2015.03.05.07.44.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Mar 2015 07:44:50 -0800 (PST)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH] Fix undefined ioremap_huge_init when CONFIG_MMU is not set
Date: Thu,  5 Mar 2015 08:44:06 -0700
Message-Id: <1425570246-812-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-next@vger.kernel.org, linux-kernel@vger.kernel.org, kbuild-all@01.org, sfr@canb.auug.org.au, fengguang.wu@intel.com, hannes@cmpxchg.org, Toshi Kani <toshi.kani@hp.com>

Fix a build error, undefined reference to ioremap_huge_init, when
CONFIG_MMU is not defined on linux-next and -mm tree.

lib/ioremap.o is not linked to the kernel when CONFIG_MMU is not
defined.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
---
 include/linux/io.h |    5 +++--
 lib/ioremap.c      |    1 -
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/linux/io.h b/include/linux/io.h
index 1ce8b4e..4cc299c 100644
--- a/include/linux/io.h
+++ b/include/linux/io.h
@@ -38,11 +38,12 @@ static inline int ioremap_page_range(unsigned long addr, unsigned long end,
 }
 #endif
 
-void __init ioremap_huge_init(void);
-
 #ifdef CONFIG_HAVE_ARCH_HUGE_VMAP
+void __init ioremap_huge_init(void);
 int arch_ioremap_pud_supported(void);
 int arch_ioremap_pmd_supported(void);
+#else
+static inline void ioremap_huge_init(void) { }
 #endif
 
 /*
diff --git a/lib/ioremap.c b/lib/ioremap.c
index 3055ada..be24906 100644
--- a/lib/ioremap.c
+++ b/lib/ioremap.c
@@ -46,7 +46,6 @@ static inline int ioremap_pmd_enabled(void)
 }
 
 #else	/* !CONFIG_HAVE_ARCH_HUGE_VMAP */
-void __init ioremap_huge_init(void) { }
 static inline int ioremap_pud_enabled(void) { return 0; }
 static inline int ioremap_pmd_enabled(void) { return 0; }
 #endif	/* CONFIG_HAVE_ARCH_HUGE_VMAP */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
