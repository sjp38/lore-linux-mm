Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 02C296B0075
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 08:07:20 -0400 (EDT)
Received: by wifx6 with SMTP id x6so84248336wif.0
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 05:07:19 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fp5si767799wib.85.2015.06.08.05.07.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 08 Jun 2015 05:07:03 -0700 (PDT)
From: Juergen Gross <jgross@suse.com>
Subject: [Patch V4 07/16] xen: check memory area against e820 map
Date: Mon,  8 Jun 2015 14:06:48 +0200
Message-Id: <1433765217-16333-8-git-send-email-jgross@suse.com>
In-Reply-To: <1433765217-16333-1-git-send-email-jgross@suse.com>
References: <1433765217-16333-1-git-send-email-jgross@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: xen-devel@lists.xensource.com, konrad.wilk@oracle.com, david.vrabel@citrix.com, boris.ostrovsky@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Juergen Gross <jgross@suse.com>

Provide a service routine to check a physical memory area against the
E820 map. The routine will return false if the complete area is RAM
according to the E820 map and true otherwise.

Signed-off-by: Juergen Gross <jgross@suse.com>
Reviewed-by: David Vrabel <david.vrabel@citrix.com>
---
 arch/x86/xen/setup.c   | 23 +++++++++++++++++++++++
 arch/x86/xen/xen-ops.h |  1 +
 2 files changed, 24 insertions(+)

diff --git a/arch/x86/xen/setup.c b/arch/x86/xen/setup.c
index 87251b4..99ef82c 100644
--- a/arch/x86/xen/setup.c
+++ b/arch/x86/xen/setup.c
@@ -573,6 +573,29 @@ static unsigned long __init xen_count_remap_pages(unsigned long max_pfn)
 	return extra;
 }
 
+bool __init xen_is_e820_reserved(phys_addr_t start, phys_addr_t size)
+{
+	struct e820entry *entry;
+	unsigned mapcnt;
+	phys_addr_t end;
+
+	if (!size)
+		return false;
+
+	end = start + size;
+	entry = xen_e820_map;
+
+	for (mapcnt = 0; mapcnt < xen_e820_map_entries; mapcnt++) {
+		if (entry->type == E820_RAM && entry->addr <= start &&
+		    (entry->addr + entry->size) >= end)
+			return false;
+
+		entry++;
+	}
+
+	return true;
+}
+
 /*
  * Reserve Xen mfn_list.
  * See comment above "struct start_info" in <xen/interface/xen.h>
diff --git a/arch/x86/xen/xen-ops.h b/arch/x86/xen/xen-ops.h
index 9e195c6..c1385b8 100644
--- a/arch/x86/xen/xen-ops.h
+++ b/arch/x86/xen/xen-ops.h
@@ -39,6 +39,7 @@ void xen_reserve_top(void);
 void xen_mm_pin_all(void);
 void xen_mm_unpin_all(void);
 
+bool __init xen_is_e820_reserved(phys_addr_t start, phys_addr_t size);
 unsigned long __ref xen_chk_extra_mem(unsigned long pfn);
 void __init xen_inv_extra_mem(void);
 void __init xen_remap_memory(void);
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
