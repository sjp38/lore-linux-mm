Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id D404B6B0080
	for <linux-mm@kvack.org>; Mon,  4 May 2015 04:23:46 -0400 (EDT)
Received: by wiun10 with SMTP id n10so101920507wiu.1
        for <linux-mm@kvack.org>; Mon, 04 May 2015 01:23:46 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l9si10322163wia.121.2015.05.04.01.23.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 04 May 2015 01:23:21 -0700 (PDT)
From: Juergen Gross <jgross@suse.com>
Subject: [RESEND Patch V3 11/15] xen: check for initrd conflicting with e820 map
Date: Mon,  4 May 2015 10:23:11 +0200
Message-Id: <1430727795-25133-12-git-send-email-jgross@suse.com>
In-Reply-To: <1430727795-25133-1-git-send-email-jgross@suse.com>
References: <1430727795-25133-1-git-send-email-jgross@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: xen-devel@lists.xensource.com, konrad.wilk@oracle.com, david.vrabel@citrix.com, boris.ostrovsky@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Juergen Gross <jgross@suse.com>

Check whether the initrd is placed at a location which is conflicting
with the target E820 map. If this is the case relocate it to a new
area unused up to now and compliant to the E820 map.

Signed-off-by: Juergen Gross <jgross@suse.com>
Reviewed-by: David Vrabel <david.vrabel@citrix.com>
---
 arch/x86/xen/setup.c | 51 +++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 51 insertions(+)

diff --git a/arch/x86/xen/setup.c b/arch/x86/xen/setup.c
index 3fca9c1..0d7f881 100644
--- a/arch/x86/xen/setup.c
+++ b/arch/x86/xen/setup.c
@@ -632,6 +632,36 @@ phys_addr_t __init xen_find_free_area(phys_addr_t size)
 }
 
 /*
+ * Like memcpy, but with physical addresses for dest and src.
+ */
+static void __init xen_phys_memcpy(phys_addr_t dest, phys_addr_t src,
+				   phys_addr_t n)
+{
+	phys_addr_t dest_off, src_off, dest_len, src_len, len;
+	void *from, *to;
+
+	while (n) {
+		dest_off = dest & ~PAGE_MASK;
+		src_off = src & ~PAGE_MASK;
+		dest_len = n;
+		if (dest_len > (NR_FIX_BTMAPS << PAGE_SHIFT) - dest_off)
+			dest_len = (NR_FIX_BTMAPS << PAGE_SHIFT) - dest_off;
+		src_len = n;
+		if (src_len > (NR_FIX_BTMAPS << PAGE_SHIFT) - src_off)
+			src_len = (NR_FIX_BTMAPS << PAGE_SHIFT) - src_off;
+		len = min(dest_len, src_len);
+		to = early_memremap(dest - dest_off, dest_len + dest_off);
+		from = early_memremap(src - src_off, src_len + src_off);
+		memcpy(to, from, len);
+		early_memunmap(to, dest_len + dest_off);
+		early_memunmap(from, src_len + src_off);
+		n -= len;
+		dest += len;
+		src += len;
+	}
+}
+
+/*
  * Reserve Xen mfn_list.
  * See comment above "struct start_info" in <xen/interface/xen.h>
  * We tried to make the the memblock_reserve more selective so
@@ -810,6 +840,27 @@ char * __init xen_memory_setup(void)
 
 	xen_reserve_xen_mfnlist();
 
+	/* Check for a conflict of the initrd with the target E820 map. */
+	if (xen_is_e820_reserved(boot_params.hdr.ramdisk_image,
+				 boot_params.hdr.ramdisk_size)) {
+		phys_addr_t new_area, start, size;
+
+		new_area = xen_find_free_area(boot_params.hdr.ramdisk_size);
+		if (!new_area) {
+			xen_raw_console_write("Can't find new memory area for initrd needed due to E820 map conflict\n");
+			BUG();
+		}
+
+		start = boot_params.hdr.ramdisk_image;
+		size = boot_params.hdr.ramdisk_size;
+		xen_phys_memcpy(new_area, start, size);
+		pr_info("initrd moved from [mem %#010llx-%#010llx] to [mem %#010llx-%#010llx]\n",
+			start, start + size, new_area, new_area + size);
+		memblock_free(start, size);
+		boot_params.hdr.ramdisk_image = new_area;
+		boot_params.ext_ramdisk_image = new_area >> 32;
+	}
+
 	/*
 	 * Set identity map on non-RAM pages and prepare remapping the
 	 * underlying RAM.
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
