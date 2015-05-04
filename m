Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 94E8E6B0038
	for <linux-mm@kvack.org>; Mon,  4 May 2015 02:24:39 -0400 (EDT)
Received: by wgso17 with SMTP id o17so140006759wgs.1
        for <linux-mm@kvack.org>; Sun, 03 May 2015 23:24:39 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gb3si9927980wib.86.2015.05.03.23.19.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 03 May 2015 23:19:15 -0700 (PDT)
From: Juergen Gross <jgross@suse.com>
Subject: [RESEND Patch V3 14/15] xen: allow more than 512 GB of RAM for 64 bit pv-domains
Date: Mon,  4 May 2015 08:19:05 +0200
Message-Id: <1430720346-21063-15-git-send-email-jgross@suse.com>
In-Reply-To: <1430720346-21063-1-git-send-email-jgross@suse.com>
References: <1430720346-21063-1-git-send-email-jgross@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: xen-devel@lists.xensource.com, konrad.wilk@oracle.com, david.vrabel@citrix.com, boris.ostrovsky@oracle.com, linux-mm@kvack.org
Cc: Juergen Gross <jgross@suse.com>

64 bit pv-domains under Xen are limited to 512 GB of RAM today. The
main reason has been the 3 level p2m tree, which was replaced by the
virtual mapped linear p2m list. Parallel to the p2m list which is
being used by the kernel itself there is a 3 level mfn tree for usage
by the Xen tools and eventually for crash dump analysis. For this tree
the linear p2m list can serve as a replacement, too. As the kernel
can't know whether the tools are capable of dealing with the p2m list
instead of the mfn tree, the limit of 512 GB can't be dropped in all
cases.

This patch replaces the hard limit by a kernel parameter which tells
the kernel to obey the 512 GB limit or not. The default is selected by
a configuration parameter which specifies whether the 512 GB limit
should be active per default for domUs (domain save/restore/migration
and crash dump analysis are affected).

Memory above the domain limit is returned to the hypervisor instead of
being identity mapped, which was wrong anyway.

The kernel configuration parameter to specify the maximum size of a
domain can be deleted, as it is not relevant any more.

Signed-off-by: Juergen Gross <jgross@suse.com>
---
 Documentation/kernel-parameters.txt |  7 +++++
 arch/x86/include/asm/xen/page.h     |  4 ---
 arch/x86/xen/Kconfig                | 20 ++++++++-----
 arch/x86/xen/p2m.c                  | 10 +++----
 arch/x86/xen/setup.c                | 59 +++++++++++++++++++++++++++++++------
 5 files changed, 73 insertions(+), 27 deletions(-)

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index 274252f..87b7a50 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -3999,6 +3999,13 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 			plus one apbt timer for broadcast timer.
 			x86_intel_mid_timer=apbt_only | lapic_and_apbt
 
+	xen_512gb_limit		[KNL,X86-64,XEN]
+			Restricts the kernel running paravirtualized under Xen
+			to use only up to 512 GB of RAM. The reason to do so is
+			crash analysis tools and Xen tools for doing domain
+			save/restore/migration must be enabled to handle larger
+			domains.
+
 	xen_emul_unplug=		[HW,X86,XEN]
 			Unplug Xen emulated devices
 			Format: [unplug0,][unplug1]
diff --git a/arch/x86/include/asm/xen/page.h b/arch/x86/include/asm/xen/page.h
index 358dcd3..18a11f2 100644
--- a/arch/x86/include/asm/xen/page.h
+++ b/arch/x86/include/asm/xen/page.h
@@ -35,10 +35,6 @@ typedef struct xpaddr {
 #define FOREIGN_FRAME(m)	((m) | FOREIGN_FRAME_BIT)
 #define IDENTITY_FRAME(m)	((m) | IDENTITY_FRAME_BIT)
 
-/* Maximum amount of memory we can handle in a domain in pages */
-#define MAX_DOMAIN_PAGES						\
-    ((unsigned long)((u64)CONFIG_XEN_MAX_DOMAIN_MEMORY * 1024 * 1024 * 1024 / PAGE_SIZE))
-
 extern unsigned long *machine_to_phys_mapping;
 extern unsigned long  machine_to_phys_nr;
 extern unsigned long *xen_p2m_addr;
diff --git a/arch/x86/xen/Kconfig b/arch/x86/xen/Kconfig
index e88fda8..7bcf21b 100644
--- a/arch/x86/xen/Kconfig
+++ b/arch/x86/xen/Kconfig
@@ -23,14 +23,18 @@ config XEN_PVHVM
 	def_bool y
 	depends on XEN && PCI && X86_LOCAL_APIC
 
-config XEN_MAX_DOMAIN_MEMORY
-       int
-       default 500 if X86_64
-       default 64 if X86_32
-       depends on XEN
-       help
-         This only affects the sizing of some bss arrays, the unused
-         portions of which are freed.
+config XEN_512GB
+	bool "Limit Xen pv-domain memory to 512GB"
+	depends on XEN && X86_64
+	default y
+	help
+	  Limit paravirtualized user domains to 512GB of RAM.
+
+	  The Xen tools and crash dump analysis tools might not support
+	  pv-domains with more than 512 GB of RAM. This option controls the
+	  default setting of the kernel to use only up to 512 GB or more.
+	  It is always possible to change the default via specifying the
+	  boot parameter "xen_512gb_limit".
 
 config XEN_SAVE_RESTORE
        bool
diff --git a/arch/x86/xen/p2m.c b/arch/x86/xen/p2m.c
index 6f80cd3..365a64a 100644
--- a/arch/x86/xen/p2m.c
+++ b/arch/x86/xen/p2m.c
@@ -516,7 +516,7 @@ static pte_t *alloc_p2m_pmd(unsigned long addr, pte_t *pte_pg)
  */
 static bool alloc_p2m(unsigned long pfn)
 {
-	unsigned topidx, mididx;
+	unsigned topidx;
 	unsigned long *top_mfn_p, *mid_mfn;
 	pte_t *ptep, *pte_pg;
 	unsigned int level;
@@ -524,9 +524,6 @@ static bool alloc_p2m(unsigned long pfn)
 	unsigned long addr = (unsigned long)(xen_p2m_addr + pfn);
 	unsigned long p2m_pfn;
 
-	topidx = p2m_top_index(pfn);
-	mididx = p2m_mid_index(pfn);
-
 	ptep = lookup_address(addr, &level);
 	BUG_ON(!ptep || level != PG_LEVEL_4K);
 	pte_pg = (pte_t *)((unsigned long)ptep & ~(PAGE_SIZE - 1));
@@ -538,7 +535,8 @@ static bool alloc_p2m(unsigned long pfn)
 			return false;
 	}
 
-	if (p2m_top_mfn) {
+	if (p2m_top_mfn && pfn < MAX_P2M_PFN) {
+		topidx = p2m_top_index(pfn);
 		top_mfn_p = &p2m_top_mfn[topidx];
 		mid_mfn = ACCESS_ONCE(p2m_top_mfn_p[topidx]);
 
@@ -595,7 +593,7 @@ static bool alloc_p2m(unsigned long pfn)
 			wmb(); /* Tools are synchronizing via p2m_generation. */
 			HYPERVISOR_shared_info->arch.p2m_generation++;
 			if (mid_mfn)
-				mid_mfn[mididx] = virt_to_mfn(p2m);
+				mid_mfn[p2m_mid_index(pfn)] = virt_to_mfn(p2m);
 			p2m = NULL;
 		}
 
diff --git a/arch/x86/xen/setup.c b/arch/x86/xen/setup.c
index b096d02..f960021 100644
--- a/arch/x86/xen/setup.c
+++ b/arch/x86/xen/setup.c
@@ -33,6 +33,8 @@
 #include "p2m.h"
 #include "mmu.h"
 
+#define GB(x) ((uint64_t)(x) * 1024 * 1024 * 1024)
+
 /* Amount of extra memory space we add to the e820 ranges */
 struct xen_memory_region xen_extra_mem[XEN_EXTRA_MEM_MAX_REGIONS] __initdata;
 
@@ -69,6 +71,26 @@ static unsigned long xen_remap_mfn __initdata = INVALID_P2M_ENTRY;
  */
 #define EXTRA_MEM_RATIO		(10)
 
+static bool xen_512gb_limit __initdata = IS_ENABLED(CONFIG_XEN_512GB);
+
+static void __init xen_parse_512gb(void)
+{
+	bool val = false;
+	char *arg;
+
+	arg = strstr(xen_start_info->cmd_line, "xen_512gb_limit");
+	if (!arg)
+		return;
+
+	arg = strstr(xen_start_info->cmd_line, "xen_512gb_limit=");
+	if (!arg)
+		val = true;
+	else if (strtobool(arg + strlen("xen_512gb_limit="), &val))
+		return;
+
+	xen_512gb_limit = val;
+}
+
 static void __init xen_add_extra_mem(phys_addr_t start, phys_addr_t size)
 {
 	int i;
@@ -503,12 +525,29 @@ void __init xen_remap_memory(void)
 	pr_info("Remapped %ld page(s)\n", remapped);
 }
 
+static unsigned long __init xen_get_pages_limit(void)
+{
+	unsigned long limit;
+
+#ifdef CONFIG_X86_32
+	limit = GB(64) / PAGE_SIZE;
+#else
+	limit = ~0ul;
+	if (!xen_initial_domain() && xen_512gb_limit)
+		limit = GB(512) / PAGE_SIZE;
+#endif
+	return limit;
+}
+
 static unsigned long __init xen_get_max_pages(void)
 {
-	unsigned long max_pages = MAX_DOMAIN_PAGES;
+	unsigned long max_pages, limit;
 	domid_t domid = DOMID_SELF;
 	int ret;
 
+	limit = xen_get_pages_limit();
+	max_pages = limit;
+
 	/*
 	 * For the initial domain we use the maximum reservation as
 	 * the maximum page.
@@ -524,7 +563,7 @@ static unsigned long __init xen_get_max_pages(void)
 			max_pages = ret;
 	}
 
-	return min(max_pages, MAX_DOMAIN_PAGES);
+	return min(max_pages, limit);
 }
 
 static void __init xen_align_and_add_e820_region(phys_addr_t start,
@@ -699,7 +738,7 @@ static void __init xen_reserve_xen_mfnlist(void)
  **/
 char * __init xen_memory_setup(void)
 {
-	unsigned long max_pfn = xen_start_info->nr_pages;
+	unsigned long max_pfn;
 	phys_addr_t mem_end, addr, size, chunk_size;
 	u32 type;
 	int rc;
@@ -709,7 +748,9 @@ char * __init xen_memory_setup(void)
 	int i;
 	int op;
 
-	max_pfn = min(MAX_DOMAIN_PAGES, max_pfn);
+	xen_parse_512gb();
+	max_pfn = xen_get_pages_limit();
+	max_pfn = min(max_pfn, xen_start_info->nr_pages);
 	mem_end = PFN_PHYS(max_pfn);
 
 	memmap.nr_entries = E820MAX;
@@ -762,12 +803,15 @@ char * __init xen_memory_setup(void)
 	 * is limited to the max size of lowmem, so that it doesn't
 	 * get completely filled.
 	 *
+	 * Make sure we have no memory above max_pages, as this area
+	 * isn't handled by the p2m management.
+	 *
 	 * In principle there could be a problem in lowmem systems if
 	 * the initial memory is also very large with respect to
 	 * lowmem, but we won't try to deal with that here.
 	 */
-	extra_pages = min(EXTRA_MEM_RATIO * min(max_pfn, PFN_DOWN(MAXMEM)),
-			  extra_pages);
+	extra_pages = min3(EXTRA_MEM_RATIO * min(max_pfn, PFN_DOWN(MAXMEM)),
+			   extra_pages, max_pages - max_pfn);
 	i = 0;
 	addr = xen_e820_map[0].addr;
 	size = xen_e820_map[0].size;
@@ -803,9 +847,6 @@ char * __init xen_memory_setup(void)
 	/*
 	 * Set the rest as identity mapped, in case PCI BARs are
 	 * located here.
-	 *
-	 * PFNs above MAX_P2M_PFN are considered identity mapped as
-	 * well.
 	 */
 	set_phys_range_identity(addr / PAGE_SIZE, ~0ul);
 
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
