Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 17FB16B0003
	for <linux-mm@kvack.org>; Fri, 27 Apr 2018 20:15:32 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id v14-v6so2677833pgq.11
        for <linux-mm@kvack.org>; Fri, 27 Apr 2018 17:15:32 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id x32-v6si2222106pld.435.2018.04.27.17.15.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Apr 2018 17:15:30 -0700 (PDT)
From: "Luis R. Rodriguez" <mcgrof@kernel.org>
Subject: [PATCH] mm: provide a fallback for PAGE_KERNEL_RO for architectures
Date: Fri, 27 Apr 2018 17:15:26 -0700
Message-Id: <20180428001526.22475-1-mcgrof@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: arnd@arndb.de
Cc: gregkh@linuxfoundation.org, linux-arch@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Luis R. Rodriguez" <mcgrof@kernel.org>

Some architectures do not define PAGE_KERNEL_RO, best we can do
for them is to provide a fallback onto PAGE_KERNEL. Remove the
hack from the firmware loader and move it onto the asm-generic
header, and document while at it the affected architectures
which do not have a PAGE_KERNEL_RO:

  o alpha
  o ia64
  o m68k
  o mips
  o sparc64
  o sparc

Blessed-by: 0-day
Signed-off-by: Luis R. Rodriguez <mcgrof@kernel.org>
---
 drivers/base/firmware_loader/fallback.c |  5 -----
 include/asm-generic/pgtable.h           | 15 +++++++++++++++
 2 files changed, 15 insertions(+), 5 deletions(-)

diff --git a/drivers/base/firmware_loader/fallback.c b/drivers/base/firmware_loader/fallback.c
index 31b5015b59fe..90f36be9e5ca 100644
--- a/drivers/base/firmware_loader/fallback.c
+++ b/drivers/base/firmware_loader/fallback.c
@@ -219,11 +219,6 @@ static ssize_t firmware_loading_show(struct device *dev,
 	return sprintf(buf, "%d\n", loading);
 }
 
-/* Some architectures don't have PAGE_KERNEL_RO */
-#ifndef PAGE_KERNEL_RO
-#define PAGE_KERNEL_RO PAGE_KERNEL
-#endif
-
 /* one pages buffer should be mapped/unmapped only once */
 static int map_fw_priv_pages(struct fw_priv *fw_priv)
 {
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index f59639afaa39..da47fe81df51 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -1083,6 +1083,21 @@ int phys_mem_access_prot_allowed(struct file *file, unsigned long pfn,
 static inline void init_espfix_bsp(void) { }
 #endif
 
+/*
+ * Some architectures don't have PAGE_KERNEL_RO. This is the best
+ * we can do for them buggers for now. Currently known to not have it:
+ *
+ *  o alpha
+ *  o ia64
+ *  o m68k
+ *  o mips
+ *  o sparc64
+ *  o sparc
+ */
+#ifndef PAGE_KERNEL_RO
+#define PAGE_KERNEL_RO PAGE_KERNEL
+#endif
+
 #endif /* !__ASSEMBLY__ */
 
 #ifndef io_remap_pfn_range
-- 
2.13.2
