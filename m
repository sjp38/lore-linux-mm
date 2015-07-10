Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 60EAC6B0038
	for <linux-mm@kvack.org>; Thu,  9 Jul 2015 20:30:31 -0400 (EDT)
Received: by pacws9 with SMTP id ws9so160084435pac.0
        for <linux-mm@kvack.org>; Thu, 09 Jul 2015 17:30:31 -0700 (PDT)
Received: from mail-pd0-x22d.google.com (mail-pd0-x22d.google.com. [2607:f8b0:400e:c02::22d])
        by mx.google.com with ESMTPS id qx6si11651829pab.13.2015.07.09.17.30.30
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Jul 2015 17:30:30 -0700 (PDT)
Received: by pdjr16 with SMTP id r16so12568969pdj.3
        for <linux-mm@kvack.org>; Thu, 09 Jul 2015 17:30:30 -0700 (PDT)
From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: [PATCH v1] x86/mm, asm-generic: Add IOMMU ioremap_uc() variant default
Date: Thu,  9 Jul 2015 17:28:16 -0700
Message-Id: <1436488096-3165-1-git-send-email-mcgrof@do-not-panic.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mingo@kernel.org
Cc: bp@suse.de, arnd@arndb.de, dan.j.williams@intel.com, hch@lst.de, luto@amacapital.net, hpa@zytor.com, tglx@linutronix.de, geert@linux-m68k.org, ralf@linux-mips.org, hmh@hmh.eng.br, ross.zwisler@linux.intel.com, akpm@linux-foundation.org, jgross@suse.com, benh@kernel.crashing.org, mpe@ellerman.id.au, tj@kernel.org, x86@kernel.org, tomi.valkeinen@ti.com, mst@redhat.com, toshi.kani@hp.com, stefan.bader@canonical.com, linux-mm@kvack.org, linux-fbdev@vger.kernel.org, linux-kernel@vger.kernel.org, "Luis R. Rodriguez" <mcgrof@suse.com>

From: "Luis R. Rodriguez" <mcgrof@suse.com>

We currently have no safe way of currently defining architecture
agnostic IOMMU ioremap_*() variants. The trend is for folks to
*assume* that ioremap_nocache() should be the default everywhere
and then add this mapping on each architectures -- this is not
correct today for a variety of reasons.

We have two options:

1) Sit and wait for every architecture in Linux to get a
   an ioremap_*() variant defined before including it upstream

2) Gather consensus on a safe architecture agnostic ioremap_*()
   default

Approach 1) introduces development latencies, and since 2) will take
time and work on clarifying semantics the only remaining sensible
thing to do to avoid issues is returning NULL on ioremap_*()
variants.

In order for this to work we must have all architectures declare
their own ioremap_*() variants as defined. This will take some work,
do this for ioremp_uc() to set the example as its only currently
implemented on x86. Document all this.

Signed-off-by: Luis R. Rodriguez <mcgrof@suse.com>
---

Ingo,

I only provide implementation support for ioremap_uc() as the other ioremap_*()
variants are well defined all over the kernel for other architectures already.
Dan Williams is also providing declarations for them through another series [0]
This patch does not depend on that series, that patch series does not address
this specific issue.  With this patch in place now things won't fail to compile
if ioremap_uc() is used in the kernel on architectures lacking an ioremap_uc()
implementaiton and makes such calls simply fail. In the very near future there
is only one expected driver to use this, the atyfb framebuffer device drivers,
the series for which I've been respinning for a while now and it seems we
finally have settled on something with. In the future folks may want to
preemptively declare or annotate some regions already with ioremap_uc() ---
this would allow an easier transition in the future on x86 of the default
ioremap_nocache() and ioremap() behaviour to flip from PAT UC- to UC.  But
before people go out willy-nilly using ioremap_uc() all over though they should
at least take care to go and define all other architecture's own ioremap_uc()
implementation mappings. It would seem productive to have a broad discussion
about this objective alone with other architecture folks.

This patch would just fix compilation issues for future users of ioremap_uc()
and tries to prevent futher batched patches from folks adding
ioremap_nocache() for ioremap_uc() on other architectures. What implementation
is used for ioremap_uc() on each architecture requires review and careful
thought.

[0] http://lkml.kernel.org/r/20150622082427.35954.73529.stgit@dwillia2-desk3.jf.intel.com

 arch/x86/include/asm/io.h |  2 ++
 include/asm-generic/io.h  | 30 +++++++++++++++++++++++++++++-
 2 files changed, 31 insertions(+), 1 deletion(-)

diff --git a/arch/x86/include/asm/io.h b/arch/x86/include/asm/io.h
index cc9c61bc1abe..7cfc085b6879 100644
--- a/arch/x86/include/asm/io.h
+++ b/arch/x86/include/asm/io.h
@@ -180,6 +180,8 @@ static inline unsigned int isa_virt_to_bus(volatile void *address)
  */
 extern void __iomem *ioremap_nocache(resource_size_t offset, unsigned long size);
 extern void __iomem *ioremap_uc(resource_size_t offset, unsigned long size);
+#define ioremap_uc ioremap_uc
+
 extern void __iomem *ioremap_cache(resource_size_t offset, unsigned long size);
 extern void __iomem *ioremap_prot(resource_size_t offset, unsigned long size,
 				unsigned long prot_val);
diff --git a/include/asm-generic/io.h b/include/asm-generic/io.h
index f56094cfdeff..eed3bbe88c8a 100644
--- a/include/asm-generic/io.h
+++ b/include/asm-generic/io.h
@@ -736,6 +736,35 @@ static inline void *phys_to_virt(unsigned long address)
 }
 #endif
 
+/**
+ * DOC: ioremap() and ioremap_*() variants
+ *
+ * If you have an IOMMU your architecture is expected to have both ioremap()
+ * and iounmap() implemented otherwise the asm-generic helpers will provide a
+ * direct mapping.
+ *
+ * There are ioremap_*() call variants, if you have no IOMMU we naturally will
+ * default to direct mapping for all of them, you can override these defaults.
+ * If you have an IOMMU you are highly encouraged to provide your own
+ * ioremap variant implementation as there currently is no safe architecture
+ * agnostic default. To avoid possible improper behaviour default asm-generic
+ * ioremap_*() variants all return NULL when an IOMMU is available. If you've
+ * defined your own ioremap_*() variant you must then declare your own
+ * ioremap_*() variant as defined to itself to avoid the default NULL return.
+ */
+
+#ifdef CONFIG_MMU
+
+#ifndef ioremap_uc
+#define ioremap_uc ioremap_uc
+static inline void __iomem *ioremap_uc(phys_addr_t offset, size_t size)
+{
+	return NULL;
+}
+#endif
+
+#else /* !CONFIG_MMU */
+
 /*
  * Change "struct page" to physical address.
  *
@@ -743,7 +772,6 @@ static inline void *phys_to_virt(unsigned long address)
  * you'll need to provide your own definitions.
  */
 
-#ifndef CONFIG_MMU
 #ifndef ioremap
 #define ioremap ioremap
 static inline void __iomem *ioremap(phys_addr_t offset, size_t size)
-- 
2.3.2.209.gd67f9d5.dirty

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
