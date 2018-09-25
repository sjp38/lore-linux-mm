Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 421F68E0072
	for <linux-mm@kvack.org>; Tue, 25 Sep 2018 08:46:44 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id l14-v6so10145330wrt.9
        for <linux-mm@kvack.org>; Tue, 25 Sep 2018 05:46:44 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y12-v6sor1683294wrq.31.2018.09.25.05.46.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 25 Sep 2018 05:46:42 -0700 (PDT)
From: Bartosz Golaszewski <brgl@bgdev.pl>
Subject: [PATCH v4 2/4] mm: move is_kernel_rodata() to asm-generic/sections.h
Date: Tue, 25 Sep 2018 14:46:27 +0200
Message-Id: <20180925124629.20710-3-brgl@bgdev.pl>
In-Reply-To: <20180925124629.20710-1-brgl@bgdev.pl>
References: <20180925124629.20710-1-brgl@bgdev.pl>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J . Wysocki" <rafael@kernel.org>, Jassi Brar <jassisinghbrar@gmail.com>, Thierry Reding <thierry.reding@gmail.com>, Jonathan Hunter <jonathanh@nvidia.com>, Arnd Bergmann <arnd@arndb.de>, Ulf Hansson <ulf.hansson@linaro.org>, Rob Herring <robh@kernel.org>, Bjorn Helgaas <bhelgaas@google.com>, Arend van Spriel <aspriel@gmail.com>, Robin Murphy <robin.murphy@arm.com>, Vivek Gautam <vivek.gautam@codeaurora.org>, Joe Perches <joe@perches.com>, Heikki Krogerus <heikki.krogerus@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@suse.com>, Huang Ying <ying.huang@intel.com>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Bjorn Andersson <bjorn.andersson@linaro.org>
Cc: linux-kernel@vger.kernel.org, linux-tegra@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Bartosz Golaszewski <brgl@bgdev.pl>

Export this routine so that we can use it later in devm_kstrdup_const()
and devm_kfree_const().

Signed-off-by: Bartosz Golaszewski <brgl@bgdev.pl>
Reviewed-by: Bjorn Andersson <bjorn.andersson@linaro.org>
Acked-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
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
