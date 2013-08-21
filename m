Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 3BBF46B0078
	for <linux-mm@kvack.org>; Wed, 21 Aug 2013 06:17:08 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH 5/8] x86, brk: Make extend_brk() available with va/pa.
Date: Wed, 21 Aug 2013 18:15:40 +0800
Message-Id: <1377080143-28455-6-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1377080143-28455-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1377080143-28455-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: konrad.wilk@oracle.com, robert.moore@intel.com, lv.zheng@intel.com, rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

We are going to do acpi_initrd_override() at very early time:

On 32bit: do it in head_32.S, before paging is enabled. In this case, we can
          access initrd with physical address without page tables.

On 64bit: do it in head_64.c, after paging is enabled but before direct mapping
          is setup.

          On 64bit, we have an early page fault handler to help to access data
          with direct mapping page tables. So it is easy to do in head_64.c.

And we need to allocate memory to store override tables. At such an early time,
no memory allocator works. So we can only use BRK.

As mentioned above, on 32bit before paging is enabled, we have to access variables
with pa. So introduce a "bool is_phys" parameter to extend_brk(), and convert va
to pa is it is true.

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
---
 arch/x86/include/asm/dmi.h   |    2 +-
 arch/x86/include/asm/setup.h |    2 +-
 arch/x86/kernel/setup.c      |   20 ++++++++++++++------
 arch/x86/mm/init.c           |    2 +-
 arch/x86/xen/enlighten.c     |    2 +-
 arch/x86/xen/mmu.c           |    6 +++---
 arch/x86/xen/p2m.c           |   27 ++++++++++++++-------------
 drivers/acpi/osl.c           |    2 +-
 8 files changed, 36 insertions(+), 27 deletions(-)

diff --git a/arch/x86/include/asm/dmi.h b/arch/x86/include/asm/dmi.h
index fd8f9e2..3b51d81 100644
--- a/arch/x86/include/asm/dmi.h
+++ b/arch/x86/include/asm/dmi.h
@@ -9,7 +9,7 @@
 
 static __always_inline __init void *dmi_alloc(unsigned len)
 {
-	return extend_brk(len, sizeof(int));
+	return extend_brk(len, sizeof(int), false);
 }
 
 /* Use early IO mappings for DMI because it's initialized early */
diff --git a/arch/x86/include/asm/setup.h b/arch/x86/include/asm/setup.h
index 4f71d48..96d00da 100644
--- a/arch/x86/include/asm/setup.h
+++ b/arch/x86/include/asm/setup.h
@@ -75,7 +75,7 @@ extern struct boot_params boot_params;
 
 /* exceedingly early brk-like allocator */
 extern unsigned long _brk_end;
-void *extend_brk(size_t size, size_t align);
+void *extend_brk(size_t size, size_t align, bool is_phys);
 
 /*
  * Reserve space in the brk section.  The name must be unique within
diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
index 51fcd5d..a189909 100644
--- a/arch/x86/kernel/setup.c
+++ b/arch/x86/kernel/setup.c
@@ -259,19 +259,27 @@ static inline void __init copy_edd(void)
 }
 #endif
 
-void * __init extend_brk(size_t size, size_t align)
+void * __init extend_brk(size_t size, size_t align, bool is_phys)
 {
 	size_t mask = align - 1;
 	void *ret;
+	unsigned long *brk_start, *brk_end, *brk_limit;
 
-	BUG_ON(_brk_start == 0);
+	brk_start = is_phys ? (unsigned long *)__pa_nodebug(&_brk_start) :
+			      (unsigned long *)&_brk_start;
+	brk_end = is_phys ? (unsigned long *)__pa_nodebug(&_brk_end) :
+			    (unsigned long *)&_brk_end;
+	brk_limit = is_phys ? (unsigned long *)__pa_nodebug(__brk_limit) :
+			      (unsigned long *)__brk_limit;
+
+	BUG_ON(*brk_start == 0);
 	BUG_ON(align & mask);
 
-	_brk_end = (_brk_end + mask) & ~mask;
-	BUG_ON((char *)(_brk_end + size) > __brk_limit);
+	*brk_end = (*brk_end + mask) & ~mask;
+	BUG_ON((char *)(*brk_end + size) > brk_limit);
 
-	ret = (void *)_brk_end;
-	_brk_end += size;
+	ret = (void *)(*brk_end);
+	*brk_end += size;
 
 	memset(ret, 0, size);
 
diff --git a/arch/x86/mm/init.c b/arch/x86/mm/init.c
index 2ec29ac..189a9e2 100644
--- a/arch/x86/mm/init.c
+++ b/arch/x86/mm/init.c
@@ -86,7 +86,7 @@ void  __init early_alloc_pgt_buf(void)
 	unsigned long tables = INIT_PGT_BUF_SIZE;
 	phys_addr_t base;
 
-	base = __pa(extend_brk(tables, PAGE_SIZE));
+	base = __pa(extend_brk(tables, PAGE_SIZE, false));
 
 	pgt_buf_start = base >> PAGE_SHIFT;
 	pgt_buf_end = pgt_buf_start;
diff --git a/arch/x86/xen/enlighten.c b/arch/x86/xen/enlighten.c
index 193097e..2d5a34f 100644
--- a/arch/x86/xen/enlighten.c
+++ b/arch/x86/xen/enlighten.c
@@ -1629,7 +1629,7 @@ void __ref xen_hvm_init_shared_info(void)
 
 	if (!shared_info_page)
 		shared_info_page = (struct shared_info *)
-			extend_brk(PAGE_SIZE, PAGE_SIZE);
+			extend_brk(PAGE_SIZE, PAGE_SIZE, false);
 	xatp.domid = DOMID_SELF;
 	xatp.idx = 0;
 	xatp.space = XENMAPSPACE_shared_info;
diff --git a/arch/x86/xen/mmu.c b/arch/x86/xen/mmu.c
index fdc3ba2..573bc50 100644
--- a/arch/x86/xen/mmu.c
+++ b/arch/x86/xen/mmu.c
@@ -1768,7 +1768,7 @@ static void __init xen_map_identity_early(pmd_t *pmd, unsigned long max_pfn)
 	unsigned long pfn;
 
 	level1_ident_pgt = extend_brk(sizeof(pte_t) * LEVEL1_IDENT_ENTRIES,
-				      PAGE_SIZE);
+				      PAGE_SIZE, false);
 
 	ident_pte = 0;
 	pfn = 0;
@@ -1980,7 +1980,7 @@ static void __init xen_write_cr3_init(unsigned long cr3)
 	 * swapper_pg_dir.
 	 */
 	swapper_kernel_pmd =
-		extend_brk(sizeof(pmd_t) * PTRS_PER_PMD, PAGE_SIZE);
+		extend_brk(sizeof(pmd_t) * PTRS_PER_PMD, PAGE_SIZE, false);
 	copy_page(swapper_kernel_pmd, initial_kernel_pmd);
 	swapper_pg_dir[KERNEL_PGD_BOUNDARY] =
 		__pgd(__pa(swapper_kernel_pmd) | _PAGE_PRESENT);
@@ -2003,7 +2003,7 @@ void __init xen_setup_kernel_pagetable(pgd_t *pgd, unsigned long max_pfn)
 	pmd_t *kernel_pmd;
 
 	initial_kernel_pmd =
-		extend_brk(sizeof(pmd_t) * PTRS_PER_PMD, PAGE_SIZE);
+		extend_brk(sizeof(pmd_t) * PTRS_PER_PMD, PAGE_SIZE, false);
 
 	max_pfn_mapped = PFN_DOWN(__pa(xen_start_info->pt_base) +
 				  xen_start_info->nr_pt_frames * PAGE_SIZE +
diff --git a/arch/x86/xen/p2m.c b/arch/x86/xen/p2m.c
index 95fb2aa..bbdcf20 100644
--- a/arch/x86/xen/p2m.c
+++ b/arch/x86/xen/p2m.c
@@ -281,13 +281,13 @@ void __ref xen_build_mfn_list_list(void)
 
 	/* Pre-initialize p2m_top_mfn to be completely missing */
 	if (p2m_top_mfn == NULL) {
-		p2m_mid_missing_mfn = extend_brk(PAGE_SIZE, PAGE_SIZE);
+		p2m_mid_missing_mfn = extend_brk(PAGE_SIZE, PAGE_SIZE, false);
 		p2m_mid_mfn_init(p2m_mid_missing_mfn);
 
-		p2m_top_mfn_p = extend_brk(PAGE_SIZE, PAGE_SIZE);
+		p2m_top_mfn_p = extend_brk(PAGE_SIZE, PAGE_SIZE, false);
 		p2m_top_mfn_p_init(p2m_top_mfn_p);
 
-		p2m_top_mfn = extend_brk(PAGE_SIZE, PAGE_SIZE);
+		p2m_top_mfn = extend_brk(PAGE_SIZE, PAGE_SIZE, false);
 		p2m_top_mfn_init(p2m_top_mfn);
 	} else {
 		/* Reinitialise, mfn's all change after migration */
@@ -322,7 +322,7 @@ void __ref xen_build_mfn_list_list(void)
 			 * runtime.  extend_brk() will BUG if we call
 			 * it too late.
 			 */
-			mid_mfn_p = extend_brk(PAGE_SIZE, PAGE_SIZE);
+			mid_mfn_p = extend_brk(PAGE_SIZE, PAGE_SIZE, false);
 			p2m_mid_mfn_init(mid_mfn_p);
 
 			p2m_top_mfn_p[topidx] = mid_mfn_p;
@@ -351,16 +351,16 @@ void __init xen_build_dynamic_phys_to_machine(void)
 
 	xen_max_p2m_pfn = max_pfn;
 
-	p2m_missing = extend_brk(PAGE_SIZE, PAGE_SIZE);
+	p2m_missing = extend_brk(PAGE_SIZE, PAGE_SIZE, false);
 	p2m_init(p2m_missing);
 
-	p2m_mid_missing = extend_brk(PAGE_SIZE, PAGE_SIZE);
+	p2m_mid_missing = extend_brk(PAGE_SIZE, PAGE_SIZE, false);
 	p2m_mid_init(p2m_mid_missing);
 
-	p2m_top = extend_brk(PAGE_SIZE, PAGE_SIZE);
+	p2m_top = extend_brk(PAGE_SIZE, PAGE_SIZE, false);
 	p2m_top_init(p2m_top);
 
-	p2m_identity = extend_brk(PAGE_SIZE, PAGE_SIZE);
+	p2m_identity = extend_brk(PAGE_SIZE, PAGE_SIZE, false);
 	p2m_init(p2m_identity);
 
 	/*
@@ -373,7 +373,8 @@ void __init xen_build_dynamic_phys_to_machine(void)
 		unsigned mididx = p2m_mid_index(pfn);
 
 		if (p2m_top[topidx] == p2m_mid_missing) {
-			unsigned long **mid = extend_brk(PAGE_SIZE, PAGE_SIZE);
+			unsigned long **mid = extend_brk(PAGE_SIZE, PAGE_SIZE,
+							 false);
 			p2m_mid_init(mid);
 
 			p2m_top[topidx] = mid;
@@ -609,7 +610,7 @@ static bool __init early_alloc_p2m_middle(unsigned long pfn, bool check_boundary
 		return false;
 
 	/* Boundary cross-over for the edges: */
-	p2m = extend_brk(PAGE_SIZE, PAGE_SIZE);
+	p2m = extend_brk(PAGE_SIZE, PAGE_SIZE, false);
 
 	p2m_init(p2m);
 
@@ -635,7 +636,7 @@ static bool __init early_alloc_p2m(unsigned long pfn)
 	mid = p2m_top[topidx];
 	mid_mfn_p = p2m_top_mfn_p[topidx];
 	if (mid == p2m_mid_missing) {
-		mid = extend_brk(PAGE_SIZE, PAGE_SIZE);
+		mid = extend_brk(PAGE_SIZE, PAGE_SIZE, false);
 
 		p2m_mid_init(mid);
 
@@ -645,7 +646,7 @@ static bool __init early_alloc_p2m(unsigned long pfn)
 	}
 	/* And the save/restore P2M tables.. */
 	if (mid_mfn_p == p2m_mid_missing_mfn) {
-		mid_mfn_p = extend_brk(PAGE_SIZE, PAGE_SIZE);
+		mid_mfn_p = extend_brk(PAGE_SIZE, PAGE_SIZE, false);
 		p2m_mid_mfn_init(mid_mfn_p);
 
 		p2m_top_mfn_p[topidx] = mid_mfn_p;
@@ -858,7 +859,7 @@ static void __init m2p_override_init(void)
 	unsigned i;
 
 	m2p_overrides = extend_brk(sizeof(*m2p_overrides) * M2P_OVERRIDE_HASH,
-				   sizeof(unsigned long));
+				   sizeof(unsigned long), false);
 
 	for (i = 0; i < M2P_OVERRIDE_HASH; i++)
 		INIT_LIST_HEAD(&m2p_overrides[i]);
diff --git a/drivers/acpi/osl.c b/drivers/acpi/osl.c
index 4c1baa7..dff7fcc 100644
--- a/drivers/acpi/osl.c
+++ b/drivers/acpi/osl.c
@@ -563,7 +563,7 @@ RESERVE_BRK(acpi_override_tables_alloc, ACPI_OVERRIDE_TABLES_SIZE);
 void __init early_alloc_acpi_override_tables_buf(void)
 {
 	acpi_tables_addr = __pa(extend_brk(ACPI_OVERRIDE_TABLES_SIZE,
-					   PAGE_SIZE));
+					   PAGE_SIZE, false));
 }
 
 void __init acpi_initrd_override(void *data, size_t size)
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
