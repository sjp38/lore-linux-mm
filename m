Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id D797B900015
	for <linux-mm@kvack.org>; Thu, 11 Jun 2015 17:22:17 -0400 (EDT)
Received: by pdjm12 with SMTP id m12so10437886pdj.3
        for <linux-mm@kvack.org>; Thu, 11 Jun 2015 14:22:17 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id fk17si2486283pdb.56.2015.06.11.14.22.16
        for <linux-mm@kvack.org>;
        Thu, 11 Jun 2015 14:22:17 -0700 (PDT)
Subject: [PATCH v4 4/6] devm: fix ioremap_cache() usage
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 11 Jun 2015 17:19:36 -0400
Message-ID: <20150611211936.10271.3169.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <20150611211354.10271.57950.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <20150611211354.10271.57950.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: arnd@arndb.de, mingo@redhat.com, bp@alien8.de, hpa@zytor.com, tglx@linutronix.de, ross.zwisler@linux.intel.com, akpm@linux-foundation.org
Cc: jgross@suse.com, x86@kernel.org, toshi.kani@hp.com, linux-nvdimm@lists.01.org, benh@kernel.crashing.org, mcgrof@suse.com, konrad.wilk@oracle.com, linux-kernel@vger.kernel.org, stefan.bader@canonical.com, luto@amacapital.net, linux-mm@kvack.org, geert@linux-m68k.org, ralf@linux-mips.org, hmh@hmh.eng.br, mpe@ellerman.id.au, tj@kernel.org, paulus@samba.org, hch@lst.de

Provide devm_ioremap_cache() and fix up devm_ioremap_resource() to
actually provide cacheable mappings.  On archs that implement
ioremap_cache() devm_ioremap_resource() is always silently falling back
to uncached when IORESOURCE_CACHEABLE is specified.

Cc: Toshi Kani <toshi.kani@hp.com>
Cc: Arnd Bergmann <arnd@arndb.de>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 include/linux/io.h |    2 ++
 lib/devres.c       |   53 +++++++++++++++++++++++++---------------------------
 2 files changed, 27 insertions(+), 28 deletions(-)

diff --git a/include/linux/io.h b/include/linux/io.h
index fb5a99800e77..4cd8996cfea0 100644
--- a/include/linux/io.h
+++ b/include/linux/io.h
@@ -71,6 +71,8 @@ static inline void devm_ioport_unmap(struct device *dev, void __iomem *addr)
 
 void __iomem *devm_ioremap(struct device *dev, resource_size_t offset,
 			   resource_size_t size);
+void __iomem *devm_ioremap_cache(struct device *dev, resource_size_t offset,
+			   resource_size_t size);
 void __iomem *devm_ioremap_nocache(struct device *dev, resource_size_t offset,
 				   resource_size_t size);
 void __iomem *devm_ioremap_wc(struct device *dev, resource_size_t offset,
diff --git a/lib/devres.c b/lib/devres.c
index f4001d90d24d..c8e75cdaf816 100644
--- a/lib/devres.c
+++ b/lib/devres.c
@@ -14,6 +14,8 @@ static int devm_ioremap_match(struct device *dev, void *res, void *match_data)
 	return *(void **)res == match_data;
 }
 
+typedef void __iomem *(*ioremap_fn)(resource_size_t offset, unsigned long size);
+
 /**
  * devm_ioremap - Managed ioremap()
  * @dev: Generic device to remap IO address for
@@ -22,8 +24,9 @@ static int devm_ioremap_match(struct device *dev, void *res, void *match_data)
  *
  * Managed ioremap().  Map is automatically unmapped on driver detach.
  */
-void __iomem *devm_ioremap(struct device *dev, resource_size_t offset,
-			   resource_size_t size)
+static void __iomem *devm_ioremap_type(struct device *dev,
+		resource_size_t offset, resource_size_t size,
+		ioremap_fn ioremap_type)
 {
 	void __iomem **ptr, *addr;
 
@@ -31,7 +34,7 @@ void __iomem *devm_ioremap(struct device *dev, resource_size_t offset,
 	if (!ptr)
 		return NULL;
 
-	addr = ioremap(offset, size);
+	addr = ioremap_type(offset, size);
 	if (addr) {
 		*ptr = addr;
 		devres_add(dev, ptr);
@@ -40,34 +43,25 @@ void __iomem *devm_ioremap(struct device *dev, resource_size_t offset,
 
 	return addr;
 }
+
+void __iomem *devm_ioremap(struct device *dev, resource_size_t offset,
+			   resource_size_t size)
+{
+	return devm_ioremap_type(dev, offset, size, ioremap);
+}
 EXPORT_SYMBOL(devm_ioremap);
 
-/**
- * devm_ioremap_nocache - Managed ioremap_nocache()
- * @dev: Generic device to remap IO address for
- * @offset: BUS offset to map
- * @size: Size of map
- *
- * Managed ioremap_nocache().  Map is automatically unmapped on driver
- * detach.
- */
+void __iomem *devm_ioremap_cache(struct device *dev, resource_size_t offset,
+			   resource_size_t size)
+{
+	return devm_ioremap_type(dev, offset, size, ioremap_cache);
+}
+EXPORT_SYMBOL(devm_ioremap_cache);
+
 void __iomem *devm_ioremap_nocache(struct device *dev, resource_size_t offset,
 				   resource_size_t size)
 {
-	void __iomem **ptr, *addr;
-
-	ptr = devres_alloc(devm_ioremap_release, sizeof(*ptr), GFP_KERNEL);
-	if (!ptr)
-		return NULL;
-
-	addr = ioremap_nocache(offset, size);
-	if (addr) {
-		*ptr = addr;
-		devres_add(dev, ptr);
-	} else
-		devres_free(ptr);
-
-	return addr;
+	return devm_ioremap_type(dev, offset, size, ioremap_nocache);
 }
 EXPORT_SYMBOL(devm_ioremap_nocache);
 
@@ -153,8 +147,11 @@ void __iomem *devm_ioremap_resource(struct device *dev, struct resource *res)
 		return IOMEM_ERR_PTR(-EBUSY);
 	}
 
-	/* FIXME: add devm_ioremap_cache support */
-	dest_ptr = devm_ioremap(dev, res->start, size);
+	if (res->flags & IORESOURCE_CACHEABLE)
+		dest_ptr = devm_ioremap_cache(dev, res->start, size);
+	else
+		dest_ptr = devm_ioremap_nocache(dev, res->start, size);
+
 	if (!dest_ptr) {
 		dev_err(dev, "ioremap failed for resource %pR\n", res);
 		devm_release_mem_region(dev, res->start, size);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
