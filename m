Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3EDD36B0007
	for <linux-mm@kvack.org>; Sun, 30 Sep 2018 16:26:25 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id v6-v6so13986069wrr.20
        for <linux-mm@kvack.org>; Sun, 30 Sep 2018 13:26:25 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 32-v6sor7102103wrd.39.2018.09.30.13.26.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 30 Sep 2018 13:26:23 -0700 (PDT)
From: Bartosz Golaszewski <brgl@bgdev.pl>
Subject: [PATCH v6 2/4] mm: move is_kernel_rodata() to asm-generic/sections.h
Date: Sun, 30 Sep 2018 22:26:13 +0200
Message-Id: <20180930202615.12951-3-brgl@bgdev.pl>
In-Reply-To: <20180930202615.12951-1-brgl@bgdev.pl>
References: <20180930202615.12951-1-brgl@bgdev.pl>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J . Wysocki" <rafael@kernel.org>, Jassi Brar <jassisinghbrar@gmail.com>, Thierry Reding <thierry.reding@gmail.com>, Jonathan Hunter <jonathanh@nvidia.com>, Arnd Bergmann <arnd@arndb.de>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Rasmus Villemoes <linux@rasmusvillemoes.dk>
Cc: linux-kernel@vger.kernel.org, linux-tegra@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Bartosz Golaszewski <brgl@bgdev.pl>

Export this routine so that we can use it later in devm_kstrdup_const()
and devm_kfree().

Signed-off-by: Bartosz Golaszewski <brgl@bgdev.pl>
Reviewed-by: Bjorn Andersson <bjorn.andersson@linaro.org>
Acked-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
Acked-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Reviewed-by: Geert Uytterhoeven <geert+renesas@glider.be>
---
 include/asm-generic/sections.h | 14 ++++++++++++++
 mm/util.c                      |  7 -------
 2 files changed, 14 insertions(+), 7 deletions(-)

diff --git a/include/asm-generic/sections.h b/include/asm-generic/sections.h
index 849cd8eb5ca0..d79abca81a52 100644
--- a/include/asm-generic/sections.h
+++ b/include/asm-generic/sections.h
@@ -141,4 +141,18 @@ static inline bool init_section_intersects(void *virt, size_t size)
 	return memory_intersects(__init_begin, __init_end, virt, size);
 }
 
+/**
+ * is_kernel_rodata - checks if the pointer address is located in the
+ *                    .rodata section
+ *
+ * @addr: address to check
+ *
+ * Returns: true if the address is located in .rodata, false otherwise.
+ */
+static inline bool is_kernel_rodata(unsigned long addr)
+{
+	return addr >= (unsigned long)__start_rodata &&
+	       addr < (unsigned long)__end_rodata;
+}
+
 #endif /* _ASM_GENERIC_SECTIONS_H_ */
diff --git a/mm/util.c b/mm/util.c
index 9e3ebd2ef65f..470f5cd80b64 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -15,17 +15,10 @@
 #include <linux/vmalloc.h>
 #include <linux/userfaultfd_k.h>
 
-#include <asm/sections.h>
 #include <linux/uaccess.h>
 
 #include "internal.h"
 
-static inline int is_kernel_rodata(unsigned long addr)
-{
-	return addr >= (unsigned long)__start_rodata &&
-		addr < (unsigned long)__end_rodata;
-}
-
 /**
  * kfree_const - conditionally free memory
  * @x: pointer to the memory
-- 
2.18.0
