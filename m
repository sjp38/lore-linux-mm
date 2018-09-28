Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id E8AC88E0001
	for <linux-mm@kvack.org>; Fri, 28 Sep 2018 03:14:27 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id 199-v6so1250643wme.1
        for <linux-mm@kvack.org>; Fri, 28 Sep 2018 00:14:27 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d9-v6sor3029036wrw.34.2018.09.28.00.14.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 28 Sep 2018 00:14:26 -0700 (PDT)
From: Bartosz Golaszewski <brgl@bgdev.pl>
Subject: [PATCH v5 3/4] devres: provide devm_kstrdup_const()
Date: Fri, 28 Sep 2018 09:14:13 +0200
Message-Id: <20180928071414.30703-4-brgl@bgdev.pl>
In-Reply-To: <20180928071414.30703-1-brgl@bgdev.pl>
References: <20180928071414.30703-1-brgl@bgdev.pl>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J . Wysocki" <rafael@kernel.org>, Jassi Brar <jassisinghbrar@gmail.com>, Thierry Reding <thierry.reding@gmail.com>, Jonathan Hunter <jonathanh@nvidia.com>, Arnd Bergmann <arnd@arndb.de>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Rasmus Villemoes <linux@rasmusvillemoes.dk>
Cc: linux-kernel@vger.kernel.org, linux-tegra@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Bartosz Golaszewski <brgl@bgdev.pl>

Provide a resource managed version of kstrdup_const(). This variant
internally calls devm_kstrdup() on pointers that are outside of
.rodata section and returns the string as is otherwise.

Make devm_kfree() check if the passed pointer doesn't point to .rodata
and if so - don't actually destroy the resource.

Signed-off-by: Bartosz Golaszewski <brgl@bgdev.pl>
Reviewed-by: Bjorn Andersson <bjorn.andersson@linaro.org>
Acked-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 drivers/base/devres.c  | 31 +++++++++++++++++++++++++++++++
 include/linux/device.h |  2 ++
 2 files changed, 33 insertions(+)

diff --git a/drivers/base/devres.c b/drivers/base/devres.c
index 438c91a43508..00c70f0fcdcd 100644
--- a/drivers/base/devres.c
+++ b/drivers/base/devres.c
@@ -11,6 +11,8 @@
 #include <linux/slab.h>
 #include <linux/percpu.h>
 
+#include <asm/sections.h>
+
 #include "base.h"
 
 struct devres_node {
@@ -822,6 +824,28 @@ char *devm_kstrdup(struct device *dev, const char *s, gfp_t gfp)
 }
 EXPORT_SYMBOL_GPL(devm_kstrdup);
 
+/**
+ * devm_kstrdup_const - resource managed conditional string duplication
+ * @dev: device for which to duplicate the string
+ * @s: the string to duplicate
+ * @gfp: the GFP mask used in the kmalloc() call when allocating memory
+ *
+ * Strings allocated by devm_kstrdup_const will be automatically freed when
+ * the associated device is detached.
+ *
+ * RETURNS:
+ * Source string if it is in .rodata section otherwise it falls back to
+ * devm_kstrdup.
+ */
+const char *devm_kstrdup_const(struct device *dev, const char *s, gfp_t gfp)
+{
+	if (is_kernel_rodata((unsigned long)s))
+		return s;
+
+	return devm_kstrdup(dev, s, gfp);
+}
+EXPORT_SYMBOL(devm_kstrdup_const);
+
 /**
  * devm_kvasprintf - Allocate resource managed space and format a string
  *		     into that.
@@ -889,6 +913,13 @@ void devm_kfree(struct device *dev, const void *p)
 {
 	int rc;
 
+	/*
+	 * Special case: pointer to a string in .rodata returned by
+	 * devm_kstrdup_const().
+	 */
+	if (unlikely(is_kernel_rodata((unsigned long)p)))
+		return;
+
 	rc = devres_destroy(dev, devm_kmalloc_release,
 			    devm_kmalloc_match, (void *)p);
 	WARN_ON(rc);
diff --git a/include/linux/device.h b/include/linux/device.h
index 33f7cb271fbb..e626acb93ef5 100644
--- a/include/linux/device.h
+++ b/include/linux/device.h
@@ -694,6 +694,8 @@ static inline void *devm_kcalloc(struct device *dev,
 }
 extern void devm_kfree(struct device *dev, const void *p);
 extern char *devm_kstrdup(struct device *dev, const char *s, gfp_t gfp) __malloc;
+extern const char *devm_kstrdup_const(struct device *dev,
+				      const char *s, gfp_t gfp);
 extern void *devm_kmemdup(struct device *dev, const void *src, size_t len,
 			  gfp_t gfp);
 
-- 
2.18.0
