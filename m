Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 652766B007D
	for <linux-mm@kvack.org>; Mon,  4 May 2015 04:23:44 -0400 (EDT)
Received: by wgen6 with SMTP id n6so142464426wge.3
        for <linux-mm@kvack.org>; Mon, 04 May 2015 01:23:43 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h5si10365103wix.46.2015.05.04.01.23.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 04 May 2015 01:23:21 -0700 (PDT)
From: Juergen Gross <jgross@suse.com>
Subject: [RESEND Patch V3 10/15] xen: check pre-allocated page tables for conflict with memory map
Date: Mon,  4 May 2015 10:23:10 +0200
Message-Id: <1430727795-25133-11-git-send-email-jgross@suse.com>
In-Reply-To: <1430727795-25133-1-git-send-email-jgross@suse.com>
References: <1430727795-25133-1-git-send-email-jgross@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: xen-devel@lists.xensource.com, konrad.wilk@oracle.com, david.vrabel@citrix.com, boris.ostrovsky@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Juergen Gross <jgross@suse.com>

Check whether the page tables built by the domain builder are at
memory addresses which are in conflict with the target memory map.
If this is the case just panic instead of running into problems
later.

Signed-off-by: Juergen Gross <jgross@suse.com>
---
 arch/x86/xen/mmu.c     | 19 ++++++++++++++++---
 arch/x86/xen/setup.c   |  6 ++++++
 arch/x86/xen/xen-ops.h |  1 +
 3 files changed, 23 insertions(+), 3 deletions(-)

diff --git a/arch/x86/xen/mmu.c b/arch/x86/xen/mmu.c
index c04e14e..1982617 100644
--- a/arch/x86/xen/mmu.c
+++ b/arch/x86/xen/mmu.c
@@ -116,6 +116,7 @@ static pud_t level3_user_vsyscall[PTRS_PER_PUD] __page_aligned_bss;
 DEFINE_PER_CPU(unsigned long, xen_cr3);	 /* cr3 stored as physaddr */
 DEFINE_PER_CPU(unsigned long, xen_current_cr3);	 /* actual vcpu cr3 */
 
+static phys_addr_t xen_pt_base, xen_pt_size __initdata;
 
 /*
  * Just beyond the highest usermode address.  STACK_TOP_MAX has a
@@ -1998,7 +1999,9 @@ void __init xen_setup_kernel_pagetable(pgd_t *pgd, unsigned long max_pfn)
 		check_pt_base(&pt_base, &pt_end, addr[i]);
 
 	/* Our (by three pages) smaller Xen pagetable that we are using */
-	memblock_reserve(PFN_PHYS(pt_base), (pt_end - pt_base) * PAGE_SIZE);
+	xen_pt_base = PFN_PHYS(pt_base);
+	xen_pt_size = (pt_end - pt_base) * PAGE_SIZE;
+	memblock_reserve(xen_pt_base, xen_pt_size);
 	/* protect xen_start_info */
 	memblock_reserve(__pa(xen_start_info), PAGE_SIZE);
 	/* Revector the xen_start_info */
@@ -2074,11 +2077,21 @@ void __init xen_setup_kernel_pagetable(pgd_t *pgd, unsigned long max_pfn)
 			  PFN_DOWN(__pa(initial_page_table)));
 	xen_write_cr3(__pa(initial_page_table));
 
-	memblock_reserve(__pa(xen_start_info->pt_base),
-			 xen_start_info->nr_pt_frames * PAGE_SIZE);
+	xen_pt_base = __pa(xen_start_info->pt_base);
+	xen_pt_size = xen_start_info->nr_pt_frames * PAGE_SIZE;
+
+	memblock_reserve(xen_pt_base, xen_pt_size);
 }
 #endif	/* CONFIG_X86_64 */
 
+void __init xen_pt_check_e820(void)
+{
+	if (xen_is_e820_reserved(xen_pt_base, xen_pt_size)) {
+		xen_raw_console_write("Xen hypervisor allocated page table memory conflicts with E820 map\n");
+		BUG();
+	}
+}
+
 static unsigned char dummy_mapping[PAGE_SIZE] __page_aligned_bss;
 
 static void xen_set_fixmap(unsigned idx, phys_addr_t phys, pgprot_t prot)
diff --git a/arch/x86/xen/setup.c b/arch/x86/xen/setup.c
index 9bd3f35..3fca9c1 100644
--- a/arch/x86/xen/setup.c
+++ b/arch/x86/xen/setup.c
@@ -802,6 +802,12 @@ char * __init xen_memory_setup(void)
 		BUG();
 	}
 
+	/*
+	 * Check for a conflict of the hypervisor supplied page tables with
+	 * the target E820 map.
+	 */
+	xen_pt_check_e820();
+
 	xen_reserve_xen_mfnlist();
 
 	/*
diff --git a/arch/x86/xen/xen-ops.h b/arch/x86/xen/xen-ops.h
index 3f1669c..553abd8 100644
--- a/arch/x86/xen/xen-ops.h
+++ b/arch/x86/xen/xen-ops.h
@@ -35,6 +35,7 @@ void xen_build_mfn_list_list(void);
 void xen_setup_machphys_mapping(void);
 void xen_setup_kernel_pagetable(pgd_t *pgd, unsigned long max_pfn);
 void xen_reserve_top(void);
+void __init xen_pt_check_e820(void);
 
 void xen_mm_pin_all(void);
 void xen_mm_unpin_all(void);
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
