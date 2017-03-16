Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id EBF936B0390
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 02:12:42 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id y17so74522842pgh.2
        for <linux-mm@kvack.org>; Wed, 15 Mar 2017 23:12:42 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id t2si3033885pfl.148.2017.03.15.23.12.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Mar 2017 23:12:42 -0700 (PDT)
Subject: [PATCH v4 08/13] x86,
 kasan: clarify kasan's dependency on vmemmap_populate_hugepages()
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 15 Mar 2017 23:07:30 -0700
Message-ID: <148964445079.19438.904042108424174547.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <148964440651.19438.2288075389153762985.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <148964440651.19438.2288075389153762985.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nicolai Stange <nicstange@gmail.com>, Alexander Potapenko <glider@google.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dmitry Vyukov <dvyukov@google.com>

Historically kasan has not been careful about whether vmemmap_populate()
internally allocates a section worth of memmap even if the parameters
call for less.  For example, a request to shadow map a single page
results in a full section (128MB) that contains that page being mapped.
Also, kasan has not been careful to handle cases where this section
promotion causes overlaps / overrides of previous calls to
vmemmap_populate().

Before we teach vmemmap_populate() to support sub-section hotplug,
arrange for kasan to explicitly avoid vmemmap_populate_basepages().
This should be functionally equivalent to the current state since
CONFIG_KASAN requires x86_64 (implies PSE) and it does not collide with
sub-section hotplug support since CONFIG_KASAN disables
CONFIG_MEMORY_HOTPLUG.

Cc: Dmitry Vyukov <dvyukov@google.com>
Cc: Alexander Potapenko <glider@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
Reported-by: Nicolai Stange <nicstange@gmail.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 arch/x86/mm/init_64.c       |    2 +-
 arch/x86/mm/kasan_init_64.c |   30 ++++++++++++++++++++++++++----
 include/linux/mm.h          |    2 ++
 3 files changed, 29 insertions(+), 5 deletions(-)

diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 15173d37f399..879cd1842610 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -1152,7 +1152,7 @@ static long __meminitdata addr_start, addr_end;
 static void __meminitdata *p_start, *p_end;
 static int __meminitdata node_start;
 
-static int __meminit vmemmap_populate_hugepages(unsigned long start,
+int __meminit vmemmap_populate_hugepages(unsigned long start,
 		unsigned long end, int node, struct vmem_altmap *altmap)
 {
 	unsigned long addr;
diff --git a/arch/x86/mm/kasan_init_64.c b/arch/x86/mm/kasan_init_64.c
index 8d63d7a104c3..e7c147140914 100644
--- a/arch/x86/mm/kasan_init_64.c
+++ b/arch/x86/mm/kasan_init_64.c
@@ -13,6 +13,25 @@
 extern pgd_t early_level4_pgt[PTRS_PER_PGD];
 extern struct range pfn_mapped[E820_X_MAX];
 
+static int __init kasan_vmemmap_populate(unsigned long start, unsigned long end)
+{
+	/*
+	 * Historically kasan has not been careful about whether
+	 * vmemmap_populate() internally allocates a section worth of memmap
+	 * even if the parameters call for less.  For example, a request to
+	 * shadow map a single page results in a full section (128MB) that
+	 * contains that page being mapped.  Also, kasan has not been careful to
+	 * handle cases where this section promotion causes overlaps / overrides
+	 * of previous calls to vmemmap_populate(). Make this implicit
+	 * dependency explicit to avoid interactions with sub-section memory
+	 * hotplug support.
+	 */
+	if (!boot_cpu_has(X86_FEATURE_PSE))
+		return -ENXIO;
+
+	return vmemmap_populate_hugepages(start, end, NUMA_NO_NODE, NULL);
+}
+
 static int __init map_range(struct range *range)
 {
 	unsigned long start;
@@ -26,7 +45,7 @@ static int __init map_range(struct range *range)
 	 * to slightly speed up fastpath. In some rare cases we could cross
 	 * boundary of mapped shadow, so we just map some more here.
 	 */
-	return vmemmap_populate(start, end + 1, NUMA_NO_NODE);
+	return kasan_vmemmap_populate(start, end + 1);
 }
 
 static void __init clear_pgds(unsigned long start,
@@ -90,6 +109,10 @@ void __init kasan_init(void)
 {
 	int i;
 
+	/* should never trigger, x86_64 implies PSE */
+	WARN(!boot_cpu_has(X86_FEATURE_PSE),
+			"kasan requires page size extensions\n");
+
 #ifdef CONFIG_KASAN_INLINE
 	register_die_notifier(&kasan_die_notifier);
 #endif
@@ -114,9 +137,8 @@ void __init kasan_init(void)
 		kasan_mem_to_shadow((void *)PAGE_OFFSET + MAXMEM),
 		kasan_mem_to_shadow((void *)__START_KERNEL_map));
 
-	vmemmap_populate((unsigned long)kasan_mem_to_shadow(_stext),
-			(unsigned long)kasan_mem_to_shadow(_end),
-			NUMA_NO_NODE);
+	kasan_vmemmap_populate((unsigned long)kasan_mem_to_shadow(_stext),
+			(unsigned long)kasan_mem_to_shadow(_end));
 
 	kasan_populate_zero_shadow(kasan_mem_to_shadow((void *)MODULES_END),
 			(void *)KASAN_SHADOW_END);
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 5f01c88f0800..601560ad3981 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2423,6 +2423,8 @@ void vmemmap_verify(pte_t *, int, unsigned long, unsigned long);
 int vmemmap_populate_basepages(unsigned long start, unsigned long end,
 			       int node);
 int vmemmap_populate(unsigned long start, unsigned long end, int node);
+int vmemmap_populate_hugepages(unsigned long start, unsigned long end, int node,
+		struct vmem_altmap *altmap);
 void vmemmap_populate_print_last(void);
 #ifdef CONFIG_MEMORY_HOTPLUG
 void vmemmap_free(unsigned long start, unsigned long end);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
