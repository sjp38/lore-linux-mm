Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f170.google.com (mail-yk0-f170.google.com [209.85.160.170])
	by kanga.kvack.org (Postfix) with ESMTP id B8B756B0261
	for <linux-mm@kvack.org>; Thu, 30 Jul 2015 13:04:37 -0400 (EDT)
Received: by ykdu72 with SMTP id u72so39082651ykd.2
        for <linux-mm@kvack.org>; Thu, 30 Jul 2015 10:04:37 -0700 (PDT)
Received: from SMTP02.CITRIX.COM (smtp02.citrix.com. [66.165.176.63])
        by mx.google.com with ESMTPS id t144si1281469ywe.114.2015.07.30.10.04.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 30 Jul 2015 10:04:28 -0700 (PDT)
From: David Vrabel <david.vrabel@citrix.com>
Subject: [PATCHv3 03/10] x86/xen: discard RAM regions above the maximum reservation
Date: Thu, 30 Jul 2015 18:03:05 +0100
Message-ID: <1438275792-5726-4-git-send-email-david.vrabel@citrix.com>
In-Reply-To: <1438275792-5726-1-git-send-email-david.vrabel@citrix.com>
References: <1438275792-5726-1-git-send-email-david.vrabel@citrix.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org
Cc: David Vrabel <david.vrabel@citrix.com>, linux-mm@kvack.org, Konrad
 Rzeszutek Wilk <konrad.wilk@oracle.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Daniel Kiper <daniel.kiper@oracle.com>

During setup, discard RAM regions that are above the maximum
reservation (instead of marking them as E820_UNUSABLE).  This allows
hotplug memory to be placed at these addresses.

Signed-off-by: David Vrabel <david.vrabel@citrix.com>
Reviewed-by: Daniel Kiper <daniel.kiper@oracle.com>
---
 arch/x86/xen/setup.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/arch/x86/xen/setup.c b/arch/x86/xen/setup.c
index 55f388e..32910c5 100644
--- a/arch/x86/xen/setup.c
+++ b/arch/x86/xen/setup.c
@@ -646,6 +646,7 @@ char * __init xen_memory_setup(void)
 		phys_addr_t addr = map[i].addr;
 		phys_addr_t size = map[i].size;
 		u32 type = map[i].type;
+		bool discard = false;
 
 		if (type == E820_RAM) {
 			if (addr < mem_end) {
@@ -656,10 +657,11 @@ char * __init xen_memory_setup(void)
 				xen_add_extra_mem(addr, size);
 				xen_max_p2m_pfn = PFN_DOWN(addr + size);
 			} else
-				type = E820_UNUSABLE;
+				discard = true;
 		}
 
-		xen_align_and_add_e820_region(addr, size, type);
+		if (!discard)
+			xen_align_and_add_e820_region(addr, size, type);
 
 		map[i].addr += size;
 		map[i].size -= size;
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
