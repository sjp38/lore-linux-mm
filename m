Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 326896B03A2
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 10:15:25 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id e66so12970376pfe.5
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 07:15:25 -0800 (PST)
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (mail-dm3nam03on0055.outbound.protection.outlook.com. [104.47.41.55])
        by mx.google.com with ESMTPS id r9si3180180pfe.12.2017.03.02.07.15.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 02 Mar 2017 07:15:24 -0800 (PST)
Subject: [RFC PATCH v2 14/32] x86: mm: Provide support to use memblock when
 spliting large pages
From: Brijesh Singh <brijesh.singh@amd.com>
Date: Thu, 2 Mar 2017 10:15:15 -0500
Message-ID: <148846771545.2349.9373586041426414252.stgit@brijesh-build-machine>
In-Reply-To: <148846752022.2349.13667498174822419498.stgit@brijesh-build-machine>
References: <148846752022.2349.13667498174822419498.stgit@brijesh-build-machine>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: simon.guinot@sequanux.org, linux-efi@vger.kernel.org, brijesh.singh@amd.com, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linux-pci@vger.kernel.org, linus.walleij@linaro.org, gary.hook@amd.com, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, cl@linux.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, peterz@infradead.org, piotr.luc@intel.com, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, bp@suse.de, dyoung@redhat.com, thomas.lendacky@amd.com, jroedel@suse.de, keescook@chromium.org, arnd@arndb.de, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, luto@kernel.org, devel@linuxdriverproject.org, bhelgaas@google.com, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, mcgrof@kernel.org, mst@redhat.com, linux-crypto@vger.kernel.org, tj@kernel.org, pbonzini@redhat.com, akpm@linux-foundation.org, davem@davemloft.net

If kernel_maps_pages_in_pgd is called early in boot process to change the
memory attributes then it fails to allocate memory when spliting large
pages. The patch extends the cpa_data to provide the support to use
memblock_alloc when slab allocator is not available.

The feature will be used in Secure Encrypted Virtualization (SEV) mode,
where we may need to change the memory region attributes in early boot
process.

Signed-off-by: Brijesh Singh <brijesh.singh@amd.com>
---
 arch/x86/mm/pageattr.c |   51 ++++++++++++++++++++++++++++++++++++++++--------
 1 file changed, 42 insertions(+), 9 deletions(-)

diff --git a/arch/x86/mm/pageattr.c b/arch/x86/mm/pageattr.c
index 46cc89d..9e4ab3b 100644
--- a/arch/x86/mm/pageattr.c
+++ b/arch/x86/mm/pageattr.c
@@ -14,6 +14,7 @@
 #include <linux/gfp.h>
 #include <linux/pci.h>
 #include <linux/vmalloc.h>
+#include <linux/memblock.h>
 
 #include <asm/e820/api.h>
 #include <asm/processor.h>
@@ -37,6 +38,7 @@ struct cpa_data {
 	int		flags;
 	unsigned long	pfn;
 	unsigned	force_split : 1;
+	unsigned	force_memblock :1;
 	int		curpage;
 	struct page	**pages;
 };
@@ -627,9 +629,8 @@ try_preserve_large_page(pte_t *kpte, unsigned long address,
 
 static int
 __split_large_page(struct cpa_data *cpa, pte_t *kpte, unsigned long address,
-		   struct page *base)
+		  pte_t *pbase, unsigned long new_pfn)
 {
-	pte_t *pbase = (pte_t *)page_address(base);
 	unsigned long ref_pfn, pfn, pfninc = 1;
 	unsigned int i, level;
 	pte_t *tmp;
@@ -646,7 +647,7 @@ __split_large_page(struct cpa_data *cpa, pte_t *kpte, unsigned long address,
 		return 1;
 	}
 
-	paravirt_alloc_pte(&init_mm, page_to_pfn(base));
+	paravirt_alloc_pte(&init_mm, new_pfn);
 
 	switch (level) {
 	case PG_LEVEL_2M:
@@ -707,7 +708,8 @@ __split_large_page(struct cpa_data *cpa, pte_t *kpte, unsigned long address,
 	 * pagetable protections, the actual ptes set above control the
 	 * primary protection behavior:
 	 */
-	__set_pmd_pte(kpte, address, mk_pte(base, __pgprot(_KERNPG_TABLE)));
+	__set_pmd_pte(kpte, address,
+		native_make_pte((new_pfn << PAGE_SHIFT) + _KERNPG_TABLE));
 
 	/*
 	 * Intel Atom errata AAH41 workaround.
@@ -723,21 +725,50 @@ __split_large_page(struct cpa_data *cpa, pte_t *kpte, unsigned long address,
 	return 0;
 }
 
+static pte_t *try_alloc_pte(struct cpa_data *cpa, unsigned long *pfn)
+{
+	unsigned long phys;
+	struct page *base;
+
+	if (cpa->force_memblock) {
+		phys = memblock_alloc(PAGE_SIZE, PAGE_SIZE);
+		if (!phys)
+			return NULL;
+		*pfn = phys >> PAGE_SHIFT;
+		return (pte_t *)__va(phys);
+	}
+
+	base = alloc_pages(GFP_KERNEL | __GFP_NOTRACK, 0);
+	if (!base)
+		return NULL;
+	*pfn = page_to_pfn(base);
+	return (pte_t *)page_address(base);
+}
+
+static void try_free_pte(struct cpa_data *cpa, pte_t *pte)
+{
+	if (cpa->force_memblock)
+		memblock_free(__pa(pte), PAGE_SIZE);
+	else
+		__free_page((struct page *)pte);
+}
+
 static int split_large_page(struct cpa_data *cpa, pte_t *kpte,
 			    unsigned long address)
 {
-	struct page *base;
+	pte_t *new_pte;
+	unsigned long new_pfn;
 
 	if (!debug_pagealloc_enabled())
 		spin_unlock(&cpa_lock);
-	base = alloc_pages(GFP_KERNEL | __GFP_NOTRACK, 0);
+	new_pte = try_alloc_pte(cpa, &new_pfn);
 	if (!debug_pagealloc_enabled())
 		spin_lock(&cpa_lock);
-	if (!base)
+	if (!new_pte)
 		return -ENOMEM;
 
-	if (__split_large_page(cpa, kpte, address, base))
-		__free_page(base);
+	if (__split_large_page(cpa, kpte, address, new_pte, new_pfn))
+		try_free_pte(cpa, new_pte);
 
 	return 0;
 }
@@ -2035,6 +2066,7 @@ int kernel_map_pages_in_pgd(pgd_t *pgd, u64 pfn, unsigned long address,
 			    unsigned numpages, unsigned long page_flags)
 {
 	int retval = -EINVAL;
+	int use_memblock = !slab_is_available();
 
 	struct cpa_data cpa = {
 		.vaddr = &address,
@@ -2044,6 +2076,7 @@ int kernel_map_pages_in_pgd(pgd_t *pgd, u64 pfn, unsigned long address,
 		.mask_set = __pgprot(0),
 		.mask_clr = __pgprot(0),
 		.flags = 0,
+		.force_memblock = use_memblock,
 	};
 
 	if (!(__supported_pte_mask & _PAGE_NX))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
