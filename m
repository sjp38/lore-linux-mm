Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 751C96B0092
	for <linux-mm@kvack.org>; Sat, 11 Dec 2010 05:05:30 -0500 (EST)
From: KyongHo Cho <pullip.cho@samsung.com>
Subject: [RFC,3/7] mm: vcm: VCM VMM driver added
Date: Sat, 11 Dec 2010 18:21:15 +0900
Message-Id: <1292059279-10026-4-git-send-email-pullip.cho@samsung.com>
In-Reply-To: <1292059279-10026-3-git-send-email-pullip.cho@samsung.com>
References: <1292059279-10026-1-git-send-email-pullip.cho@samsung.com>
 <1292059279-10026-2-git-send-email-pullip.cho@samsung.com>
 <1292059279-10026-3-git-send-email-pullip.cho@samsung.com>
Sender: owner-linux-mm@kvack.org
To: linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Randy Dunlap <rdunlap@xenotime.net>, Michal Nazarewicz <m.nazarewicz@samsung.com>, InKi Dae <inki.dae@samsung.com>
List-ID: <linux-mm.kvack.org>

From: Michal Nazarewicz <m.nazarewicz@samsung.com>

This commit adds a VCM VMM driver that handles kernl virtual
address space mappings.  The VCM context is available as a static
object vcm_vmm.  It is mostly just a wrapper around vmap()
function.

Signed-off-by: Michal Nazarewicz <m.nazarewicz@samsung.com>
---
 Documentation/virtual-contiguous-memory.txt |   22 +++++-
 include/linux/vcm.h                         |   13 +++
 mm/vcm.c                                    |  108 +++++++++++++++++++++++++++
 3 files changed, 140 insertions(+), 3 deletions(-)

diff --git a/Documentation/virtual-contiguous-memory.txt b/Documentation/virtual-contiguous-memory.txt
index 56924df..c522071 100644
--- a/Documentation/virtual-contiguous-memory.txt
+++ b/Documentation/virtual-contiguous-memory.txt
@@ -482,6 +482,25 @@ state.
 
 The following VCM drivers are provided:
 
+** Virtual Memory Manager driver
+
+Virtual Memory Manager driver is available as vcm_vmm and lets one map
+VCM managed physical memory into kernel space.  The calls that this
+driver supports are:
+
+	vcm_make_binding()
+	vcm_destroy_binding()
+
+	vcm_alloc()
+
+	vcm_map()
+	vcm_unmap()
+
+vcm_map() is likely to work with physical memory allocated in context
+of other drivers as well (the only requirement is that "page" field of
+struct vcm_phys_part will be set for all physically contiguous parts
+and that each part's size will be multiply of PAGE_SIZE).
+
 ** Real hardware drivers
 
 There are no real hardware drivers at this time.
@@ -746,6 +765,3 @@ rewritten by Michal Nazarewicz <m.nazarewicz@samsung.com>.
 The new version is still lacking a few important features.  Most
 notably, no real hardware MMU has been implemented yet.  This may be
 ported from original Zach's proposal.
-
-Also, support for VMM is lacking.  This is another thing that can be
-ported from Zach's proposal.
diff --git a/include/linux/vcm.h b/include/linux/vcm.h
index 965dc9b..7b183c2 100644
--- a/include/linux/vcm.h
+++ b/include/linux/vcm.h
@@ -272,4 +272,17 @@ int  __must_check vcm_activate(struct vcm *vcm);
  */
 void vcm_deactivate(struct vcm *vcm);
 
+/**
+ * vcm_vmm - VMM context
+ *
+ * Context for manipulating kernel virtual mappings.  Reserve as well
+ * as rebinding is not supported by this driver.  Also, all mappings
+ * are always active (till unbound) regardless of calls to
+ * vcm_activate().
+ *
+ * After mapping, the start field of struct vcm_res should be cast to
+ * pointer to void and interpreted as a valid kernel space pointer.
+ */
+extern struct vcm vcm_vmm[1];
+
 #endif
diff --git a/mm/vcm.c b/mm/vcm.c
index a9c5161..d7791a9 100644
--- a/mm/vcm.c
+++ b/mm/vcm.c
@@ -16,6 +16,7 @@
 #include <linux/vcm-drv.h>
 #include <linux/module.h>
 #include <linux/mm.h>
+#include <linux/vmalloc.h>
 #include <linux/err.h>
 #include <linux/slab.h>
 
@@ -288,6 +289,113 @@ void vcm_deactivate(struct vcm *vcm)
 EXPORT_SYMBOL_GPL(vcm_deactivate);
 
 
+/****************************** VCM VMM driver ******************************/
+
+static void vcm_vmm_cleanup(struct vcm *vcm)
+{
+	/* This should never be called.  vcm_vmm is a static object. */
+	BUG_ON(1);
+}
+
+static struct vcm_phys *
+vcm_vmm_phys(struct vcm *vcm, resource_size_t size, unsigned flags)
+{
+	static const unsigned char orders[] = { 0 };
+	return vcm_phys_alloc(size, flags, orders);
+}
+
+static void vcm_vmm_unreserve(struct vcm_res *res)
+{
+	kfree(res);
+}
+
+struct vcm_res *vcm_vmm_map(struct vcm *vcm, struct vcm_phys *phys,
+			    unsigned flags)
+{
+	/*
+	 * Original implementation written by Cho KyongHo
+	 * (pullip.cho@samsung.com).  Later rewritten by mina86.
+	 */
+	struct vcm_phys_part *part;
+	struct page **pages, **p;
+	struct vcm_res *res;
+	int ret = -ENOMEM;
+	unsigned i;
+
+	pages = kmalloc((phys->size >> PAGE_SHIFT) * sizeof *pages, GFP_KERNEL);
+	if (!pages)
+		return ERR_PTR(-ENOMEM);
+	p = pages;
+
+	res = kmalloc(sizeof *res, GFP_KERNEL);
+	if (!res)
+		goto error_pages;
+
+	i    = phys->count;
+	part = phys->parts;
+	do {
+		unsigned j = part->size >> PAGE_SHIFT;
+		struct page *page = part->page;
+		if (!page)
+			goto error_notsupp;
+		do {
+			*p++ = page++;
+		} while (--j);
+	} while (++part, --i);
+
+	res->start = (dma_addr_t)vmap(pages, p - pages, VM_ALLOC, PAGE_KERNEL);
+	if (!res->start)
+		goto error_res;
+
+	kfree(pages);
+	res->res_size = phys->size;
+	return res;
+
+error_notsupp:
+	ret = -EOPNOTSUPP;
+error_res:
+	kfree(res);
+error_pages:
+	kfree(pages);
+	return ERR_PTR(ret);
+}
+
+static void vcm_vmm_unbind(struct vcm_res *res)
+{
+	vunmap((void *)res->start);
+}
+
+static int vcm_vmm_activate(struct vcm *vcm)
+{
+	/* no operation, all bindings are immediately active */
+	return 0;
+}
+
+static void vcm_vmm_deactivate(struct vcm *vcm)
+{
+	/*
+	 * no operation, all bindings are immediately active and
+	 * cannot be deactivated unless unbound.
+	 */
+}
+
+struct vcm vcm_vmm[1] = { {
+	.start       = 0,
+	.size        = ~(resource_size_t)0,
+	/* prevent activate/deactivate from being called */
+	.activations = ATOMIC_INIT(1),
+	.driver      = &(const struct vcm_driver) {
+		.cleanup	= vcm_vmm_cleanup,
+		.phys		= vcm_vmm_phys,
+		.unbind		= vcm_vmm_unbind,
+		.unreserve	= vcm_vmm_unreserve,
+		.activate	= vcm_vmm_activate,
+		.deactivate	= vcm_vmm_deactivate,
+	}
+} };
+EXPORT_SYMBOL_GPL(vcm_vmm);
+
+
 /****************************** VCM Drivers API *****************************/
 
 struct vcm *__must_check vcm_init(struct vcm *vcm)
-- 
1.6.2.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
