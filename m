Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id A9FE16B0080
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 08:07:29 -0400 (EDT)
Received: by wgbgq6 with SMTP id gq6so101616728wgb.3
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 05:07:29 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id kf4si796103wic.48.2015.06.08.05.07.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 08 Jun 2015 05:07:04 -0700 (PDT)
From: Juergen Gross <jgross@suse.com>
Subject: [Patch V4 13/16] xen: add explicit memblock_reserve() calls for special pages
Date: Mon,  8 Jun 2015 14:06:54 +0200
Message-Id: <1433765217-16333-14-git-send-email-jgross@suse.com>
In-Reply-To: <1433765217-16333-1-git-send-email-jgross@suse.com>
References: <1433765217-16333-1-git-send-email-jgross@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: xen-devel@lists.xensource.com, konrad.wilk@oracle.com, david.vrabel@citrix.com, boris.ostrovsky@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Juergen Gross <jgross@suse.com>

Some special pages containing interfaces to xen are being reserved
implicitly only today. The memblock_reserve() call to reserve them is
meant to reserve the p2m list supplied by xen. It is just reserving
not only the p2m list itself, but some more pages up to the start of
the xen built page tables.

To be able to move the p2m list to another pfn range, which is needed
for support of huge RAM, this memblock_reserve() must be split up to
cover all affected reserved pages explicitly.

The affected pages are:
- start_info page
- xenstore ring
- console ring
- shared_info page

Signed-off-by: Juergen Gross <jgross@suse.com>
---
 arch/x86/xen/enlighten.c |  1 +
 arch/x86/xen/mmu.c       | 11 +++++++++++
 arch/x86/xen/xen-ops.h   |  1 +
 3 files changed, 13 insertions(+)

diff --git a/arch/x86/xen/enlighten.c b/arch/x86/xen/enlighten.c
index 46957ea..a29bcdb 100644
--- a/arch/x86/xen/enlighten.c
+++ b/arch/x86/xen/enlighten.c
@@ -1569,6 +1569,7 @@ asmlinkage __visible void __init xen_start_kernel(void)
 
 	xen_raw_console_write("mapping kernel into physical memory\n");
 	xen_setup_kernel_pagetable((pgd_t *)xen_start_info->pt_base, xen_start_info->nr_pages);
+	xen_reserve_special_pages();
 
 	/*
 	 * Modify the cache mode translation tables to match Xen's PAT
diff --git a/arch/x86/xen/mmu.c b/arch/x86/xen/mmu.c
index 1982617..a286953 100644
--- a/arch/x86/xen/mmu.c
+++ b/arch/x86/xen/mmu.c
@@ -2084,6 +2084,17 @@ void __init xen_setup_kernel_pagetable(pgd_t *pgd, unsigned long max_pfn)
 }
 #endif	/* CONFIG_X86_64 */
 
+void __init xen_reserve_special_pages(void)
+{
+	memblock_reserve(__pa(xen_start_info), PAGE_SIZE);
+	memblock_reserve(PFN_PHYS(mfn_to_pfn(xen_start_info->store_mfn)),
+			 PAGE_SIZE);
+	if (!xen_initial_domain())
+		memblock_reserve(PFN_PHYS(mfn_to_pfn(
+				 xen_start_info->console.domU.mfn)), PAGE_SIZE);
+	memblock_reserve(__pa(HYPERVISOR_shared_info), PAGE_SIZE);
+}
+
 void __init xen_pt_check_e820(void)
 {
 	if (xen_is_e820_reserved(xen_pt_base, xen_pt_size)) {
diff --git a/arch/x86/xen/xen-ops.h b/arch/x86/xen/xen-ops.h
index 553abd8..88bd15f 100644
--- a/arch/x86/xen/xen-ops.h
+++ b/arch/x86/xen/xen-ops.h
@@ -35,6 +35,7 @@ void xen_build_mfn_list_list(void);
 void xen_setup_machphys_mapping(void);
 void xen_setup_kernel_pagetable(pgd_t *pgd, unsigned long max_pfn);
 void xen_reserve_top(void);
+void __init xen_reserve_special_pages(void);
 void __init xen_pt_check_e820(void);
 
 void xen_mm_pin_all(void);
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
