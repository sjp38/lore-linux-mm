Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8F0FC6B05AF
	for <linux-mm@kvack.org>; Wed,  9 May 2018 21:44:51 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id t5-v6so335537ply.13
        for <linux-mm@kvack.org>; Wed, 09 May 2018 18:44:51 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id h68-v6si14995882pgc.158.2018.05.09.18.44.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 May 2018 18:44:50 -0700 (PDT)
From: "Luis R. Rodriguez" <mcgrof@kernel.org>
Subject: [PATCH v2 2/2] mm: provide a fallback for PAGE_KERNEL_EXEC for architectures
Date: Wed,  9 May 2018 18:44:47 -0700
Message-Id: <20180510014447.15989-3-mcgrof@kernel.org>
In-Reply-To: <20180510014447.15989-1-mcgrof@kernel.org>
References: <20180510014447.15989-1-mcgrof@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: arnd@arndb.de
Cc: gregkh@linuxfoundation.org, willy@infradead.org, geert@linux-m68k.org, linux-m68k@lists.linux-m68k.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Luis R. Rodriguez" <mcgrof@kernel.org>

Some architectures just don't have PAGE_KERNEL_EXEC. The mm/nommu.c
and mm/vmalloc.c code have been using PAGE_KERNEL as a fallback for years.
Move this fallback to asm-generic.

Architectures which do not define PAGE_KERNEL_EXEC yet:

  o alpha
  o mips
  o openrisc
  o sparc64

Suggested-by: Matthew Wilcox <willy@infradead.org>
Signed-off-by: Luis R. Rodriguez <mcgrof@kernel.org>
---
 include/asm-generic/pgtable.h | 12 ++++++++++++
 mm/nommu.c                    |  4 ----
 mm/vmalloc.c                  |  4 ----
 3 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index 890fc54f4713..39e9bd66c786 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -1107,6 +1107,18 @@ static inline void init_espfix_bsp(void) { }
 # define PAGE_KERNEL_RO PAGE_KERNEL
 #endif
 
+/*
+ * Current architectures known to not define PAGE_KERNEL_EXEC:
+ *
+ *  o alpha
+ *  o mips
+ *  o openrisc
+ *  o sparc64
+ */
+#ifndef PAGE_KERNEL_EXEC
+# define PAGE_KERNEL_EXEC PAGE_KERNEL
+#endif
+
 #endif /* !__ASSEMBLY__ */
 
 #ifndef io_remap_pfn_range
diff --git a/mm/nommu.c b/mm/nommu.c
index 13723736d38f..08ad4dcd281d 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -364,10 +364,6 @@ void *vzalloc_node(unsigned long size, int node)
 }
 EXPORT_SYMBOL(vzalloc_node);
 
-#ifndef PAGE_KERNEL_EXEC
-# define PAGE_KERNEL_EXEC PAGE_KERNEL
-#endif
-
 /**
  *	vmalloc_exec  -  allocate virtually contiguous, executable memory
  *	@size:		allocation size
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index ebff729cc956..89543d13e32a 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1920,10 +1920,6 @@ void *vzalloc_node(unsigned long size, int node)
 }
 EXPORT_SYMBOL(vzalloc_node);
 
-#ifndef PAGE_KERNEL_EXEC
-# define PAGE_KERNEL_EXEC PAGE_KERNEL
-#endif
-
 /**
  *	vmalloc_exec  -  allocate virtually contiguous, executable memory
  *	@size:		allocation size
-- 
2.17.0
