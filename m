Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 204A86B063A
	for <linux-mm@kvack.org>; Thu, 10 May 2018 14:55:17 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id n78-v6so1591471pfj.4
        for <linux-mm@kvack.org>; Thu, 10 May 2018 11:55:17 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id z21-v6si1278470plo.465.2018.05.10.11.55.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 May 2018 11:55:15 -0700 (PDT)
From: "Luis R. Rodriguez" <mcgrof@kernel.org>
Subject: [PATCH v3 1/2] mm: provide a fallback for PAGE_KERNEL_RO for architectures
Date: Thu, 10 May 2018 11:55:06 -0700
Message-Id: <20180510185507.2439-2-mcgrof@kernel.org>
In-Reply-To: <20180510185507.2439-1-mcgrof@kernel.org>
References: <20180510185507.2439-1-mcgrof@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: arnd@arndb.de
Cc: gregkh@linuxfoundation.org, willy@infradead.org, geert@linux-m68k.org, linux-m68k@lists.linux-m68k.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Luis R. Rodriguez" <mcgrof@kernel.org>

Some architectures do not define certain PAGE_KERNEL_* flags, this is
either because:

a) The way to implement some of these flags is *not yet ported*, or
b) The architecture *has no way* to describe them

Over time we have accumulated a few PAGE_KERNEL_* fallback work arounds
for architectures in the kernel which do not define them using *relatively
safe* equivalents. Move these scattered fallback hacks into asm-generic.

We start off with PAGE_KERNEL_RO using PAGE_KERNEL as a fallback. This
has been in place on the firmware loader for years. Move the fallback
into the respective asm-generic header.

Signed-off-by: Luis R. Rodriguez <mcgrof@kernel.org>
---
 drivers/base/firmware_loader/fallback.c |  5 -----
 include/asm-generic/pgtable.h           | 14 ++++++++++++++
 2 files changed, 14 insertions(+), 5 deletions(-)

diff --git a/drivers/base/firmware_loader/fallback.c b/drivers/base/firmware_loader/fallback.c
index 358354148dec..36f016b753e0 100644
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
index f59639afaa39..4e310e543fc8 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -1083,6 +1083,20 @@ int phys_mem_access_prot_allowed(struct file *file, unsigned long pfn,
 static inline void init_espfix_bsp(void) { }
 #endif
 
+/*
+ * Architecture PAGE_KERNEL_* fallbacks
+ *
+ * Some architectures don't define certain PAGE_KERNEL_* flags. This is either
+ * because they really don't support them, or the port needs to be updated to
+ * reflect the required functionality. Below are a set of relatively safe
+ * fallbacks, as best effort, which we can count on in lieu of the architectures
+ * not defining them on their own yet.
+ */
+
+#ifndef PAGE_KERNEL_RO
+# define PAGE_KERNEL_RO PAGE_KERNEL
+#endif
+
 #endif /* !__ASSEMBLY__ */
 
 #ifndef io_remap_pfn_range
-- 
2.17.0
