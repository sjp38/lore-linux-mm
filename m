Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 808A66B0070
	for <linux-mm@kvack.org>; Thu,  9 Apr 2015 02:56:09 -0400 (EDT)
Received: by widdi4 with SMTP id di4so80709295wid.0
        for <linux-mm@kvack.org>; Wed, 08 Apr 2015 23:56:09 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z5si22600181wjz.64.2015.04.08.23.56.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 08 Apr 2015 23:56:01 -0700 (PDT)
From: Juergen Gross <jgross@suse.com>
Subject: [Patch V2 02/15] xen: save linear p2m list address in shared info structure
Date: Thu,  9 Apr 2015 08:55:29 +0200
Message-Id: <1428562542-28488-3-git-send-email-jgross@suse.com>
In-Reply-To: <1428562542-28488-1-git-send-email-jgross@suse.com>
References: <1428562542-28488-1-git-send-email-jgross@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, xen-devel@lists.xensource.com, konrad.wilk@oracle.com, david.vrabel@citrix.com, boris.ostrovsky@oracle.com, linux-mm@kvack.org
Cc: Juergen Gross <jgross@suse.com>

The virtual address of the linear p2m list should be stored in the
shared info structure read by the Xen tools to be able to support
64 bit pv-domains larger than 512 GB. Additionally the linear p2m
list interface includes a generation count which is changed prior
to and after each mapping change of the p2m list. Reading the
generation count the Xen tools can detect changes of the mappings
and re-read the p2m list eventually.

Signed-off-by: Juergen Gross <jgross@suse.com>
---
 arch/x86/xen/p2m.c | 17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/arch/x86/xen/p2m.c b/arch/x86/xen/p2m.c
index b47124d..703f803 100644
--- a/arch/x86/xen/p2m.c
+++ b/arch/x86/xen/p2m.c
@@ -262,6 +262,10 @@ void xen_setup_mfn_list_list(void)
 	HYPERVISOR_shared_info->arch.pfn_to_mfn_frame_list_list =
 		virt_to_mfn(p2m_top_mfn);
 	HYPERVISOR_shared_info->arch.max_pfn = xen_max_p2m_pfn;
+	HYPERVISOR_shared_info->arch.p2m_generation = 0;
+	HYPERVISOR_shared_info->arch.p2m_vaddr = (unsigned long)xen_p2m_addr;
+	HYPERVISOR_shared_info->arch.p2m_cr3 =
+		xen_pfn_to_cr3(virt_to_mfn(swapper_pg_dir));
 }
 
 /* Set up p2m_top to point to the domain-builder provided p2m pages */
@@ -477,8 +481,12 @@ static pte_t *alloc_p2m_pmd(unsigned long addr, pte_t *pte_pg)
 
 		ptechk = lookup_address(vaddr, &level);
 		if (ptechk == pte_pg) {
+			HYPERVISOR_shared_info->arch.p2m_generation++;
+			wmb(); /* Tools are synchronizing via p2m_generation. */
 			set_pmd(pmdp,
 				__pmd(__pa(pte_newpg[i]) | _KERNPG_TABLE));
+			wmb(); /* Tools are synchronizing via p2m_generation. */
+			HYPERVISOR_shared_info->arch.p2m_generation++;
 			pte_newpg[i] = NULL;
 		}
 
@@ -576,8 +584,12 @@ static bool alloc_p2m(unsigned long pfn)
 		spin_lock_irqsave(&p2m_update_lock, flags);
 
 		if (pte_pfn(*ptep) == p2m_pfn) {
+			HYPERVISOR_shared_info->arch.p2m_generation++;
+			wmb(); /* Tools are synchronizing via p2m_generation. */
 			set_pte(ptep,
 				pfn_pte(PFN_DOWN(__pa(p2m)), PAGE_KERNEL));
+			wmb(); /* Tools are synchronizing via p2m_generation. */
+			HYPERVISOR_shared_info->arch.p2m_generation++;
 			if (mid_mfn)
 				mid_mfn[mididx] = virt_to_mfn(p2m);
 			p2m = NULL;
@@ -629,6 +641,11 @@ bool __set_phys_to_machine(unsigned long pfn, unsigned long mfn)
 		return true;
 	}
 
+	/*
+	 * The interface requires atomic updates on p2m elements.
+	 * xen_safe_write_ulong() is using __put_user which does an atomic
+	 * store via asm().
+	 */
 	if (likely(!xen_safe_write_ulong(xen_p2m_addr + pfn, mfn)))
 		return true;
 
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
