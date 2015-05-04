Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 22AAE6B0070
	for <linux-mm@kvack.org>; Mon,  4 May 2015 02:19:19 -0400 (EDT)
Received: by wief7 with SMTP id f7so70160247wie.0
        for <linux-mm@kvack.org>; Sun, 03 May 2015 23:19:18 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e19si21088471wjn.201.2015.05.03.23.19.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 03 May 2015 23:19:12 -0700 (PDT)
From: Juergen Gross <jgross@suse.com>
Subject: [RESEND Patch V3 03/15] xen: don't build mfn tree if tools don't need it
Date: Mon,  4 May 2015 08:18:54 +0200
Message-Id: <1430720346-21063-4-git-send-email-jgross@suse.com>
In-Reply-To: <1430720346-21063-1-git-send-email-jgross@suse.com>
References: <1430720346-21063-1-git-send-email-jgross@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: xen-devel@lists.xensource.com, konrad.wilk@oracle.com, david.vrabel@citrix.com, boris.ostrovsky@oracle.com, linux-mm@kvack.org
Cc: Juergen Gross <jgross@suse.com>

In case the Xen tools indicate they don't need the p2m 3 level tree
as they support the virtual mapped linear p2m list, just omit building
the tree.

Signed-off-by: Juergen Gross <jgross@suse.com>
Reviewed-by: David Vrabel <david.vrabel@citrix.com>
---
 arch/x86/xen/p2m.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/arch/x86/xen/p2m.c b/arch/x86/xen/p2m.c
index 703f803..6f80cd3 100644
--- a/arch/x86/xen/p2m.c
+++ b/arch/x86/xen/p2m.c
@@ -198,7 +198,8 @@ void __ref xen_build_mfn_list_list(void)
 	unsigned int level, topidx, mididx;
 	unsigned long *mid_mfn_p;
 
-	if (xen_feature(XENFEAT_auto_translated_physmap))
+	if (xen_feature(XENFEAT_auto_translated_physmap) ||
+	    xen_start_info->flags & SIF_VIRT_P2M_4TOOLS)
 		return;
 
 	/* Pre-initialize p2m_top_mfn to be completely missing */
@@ -259,8 +260,11 @@ void xen_setup_mfn_list_list(void)
 
 	BUG_ON(HYPERVISOR_shared_info == &xen_dummy_shared_info);
 
-	HYPERVISOR_shared_info->arch.pfn_to_mfn_frame_list_list =
-		virt_to_mfn(p2m_top_mfn);
+	if (xen_start_info->flags & SIF_VIRT_P2M_4TOOLS)
+		HYPERVISOR_shared_info->arch.pfn_to_mfn_frame_list_list = ~0UL;
+	else
+		HYPERVISOR_shared_info->arch.pfn_to_mfn_frame_list_list =
+			virt_to_mfn(p2m_top_mfn);
 	HYPERVISOR_shared_info->arch.max_pfn = xen_max_p2m_pfn;
 	HYPERVISOR_shared_info->arch.p2m_generation = 0;
 	HYPERVISOR_shared_info->arch.p2m_vaddr = (unsigned long)xen_p2m_addr;
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
