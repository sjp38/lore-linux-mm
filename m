Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f41.google.com (mail-yh0-f41.google.com [209.85.213.41])
	by kanga.kvack.org (Postfix) with ESMTP id E7B516B0070
	for <linux-mm@kvack.org>; Thu, 25 Jun 2015 13:11:20 -0400 (EDT)
Received: by yhjh26 with SMTP id h26so9980317yhj.3
        for <linux-mm@kvack.org>; Thu, 25 Jun 2015 10:11:20 -0700 (PDT)
Received: from SMTP02.CITRIX.COM (smtp02.citrix.com. [66.165.176.63])
        by mx.google.com with ESMTPS id r4si11761763yhg.164.2015.06.25.10.11.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 25 Jun 2015 10:11:18 -0700 (PDT)
From: David Vrabel <david.vrabel@citrix.com>
Subject: [PATCHv1 3/8] x86/xen: discard RAM regions above the maximum reservation
Date: Thu, 25 Jun 2015 18:10:58 +0100
Message-ID: <1435252263-31952-4-git-send-email-david.vrabel@citrix.com>
In-Reply-To: <1435252263-31952-1-git-send-email-david.vrabel@citrix.com>
References: <1435252263-31952-1-git-send-email-david.vrabel@citrix.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: xen-devel@lists.xenproject.org
Cc: David Vrabel <david.vrabel@citrix.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Daniel Kiper <daniel.kiper@oracle.com>

During setup, discard RAM regions that are above the maximum
reservation (instead of marking them as E820_UNUSABLE).  This allows
hotplug memory to be placed at these addresses.

Signed-off-by: David Vrabel <david.vrabel@citrix.com>
---
 arch/x86/xen/setup.c |    6 ++++--
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
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
