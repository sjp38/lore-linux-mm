Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 634AA6B0071
	for <linux-mm@kvack.org>; Mon,  4 May 2015 04:23:25 -0400 (EDT)
Received: by widdi4 with SMTP id di4so112698841wid.0
        for <linux-mm@kvack.org>; Mon, 04 May 2015 01:23:25 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id tb3si10324706wic.122.2015.05.04.01.23.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 04 May 2015 01:23:19 -0700 (PDT)
From: Juergen Gross <jgross@suse.com>
Subject: [RESEND Patch V3 03/15] xen: don't build mfn tree if tools don't need it
Date: Mon,  4 May 2015 10:23:03 +0200
Message-Id: <1430727795-25133-4-git-send-email-jgross@suse.com>
In-Reply-To: <1430727795-25133-1-git-send-email-jgross@suse.com>
References: <1430727795-25133-1-git-send-email-jgross@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: xen-devel@lists.xensource.com, konrad.wilk@oracle.com, david.vrabel@citrix.com, boris.ostrovsky@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
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
