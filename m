Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 314926B0078
	for <linux-mm@kvack.org>; Thu,  9 Apr 2015 02:56:26 -0400 (EDT)
Received: by wiun10 with SMTP id n10so85869745wiu.1
        for <linux-mm@kvack.org>; Wed, 08 Apr 2015 23:56:25 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id dr2si22624641wid.108.2015.04.08.23.56.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 08 Apr 2015 23:56:02 -0700 (PDT)
From: Juergen Gross <jgross@suse.com>
Subject: [Patch V2 09/15] xen: check for kernel memory conflicting with memory layout
Date: Thu,  9 Apr 2015 08:55:36 +0200
Message-Id: <1428562542-28488-10-git-send-email-jgross@suse.com>
In-Reply-To: <1428562542-28488-1-git-send-email-jgross@suse.com>
References: <1428562542-28488-1-git-send-email-jgross@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, xen-devel@lists.xensource.com, konrad.wilk@oracle.com, david.vrabel@citrix.com, boris.ostrovsky@oracle.com, linux-mm@kvack.org
Cc: Juergen Gross <jgross@suse.com>

Checks whether the pre-allocated memory of the loaded kernel is in
conflict with the target memory map. If this is the case, just panic
instead of run into problems later, as there is nothing we can do
to repair this situation.

Signed-off-by: Juergen Gross <jgross@suse.com>
---
 arch/x86/xen/setup.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/arch/x86/xen/setup.c b/arch/x86/xen/setup.c
index 606ac2b..b92a486 100644
--- a/arch/x86/xen/setup.c
+++ b/arch/x86/xen/setup.c
@@ -27,6 +27,7 @@
 #include <xen/interface/memory.h>
 #include <xen/interface/physdev.h>
 #include <xen/features.h>
+#include <xen/hvc-console.h>
 #include "xen-ops.h"
 #include "vdso.h"
 #include "p2m.h"
@@ -790,6 +791,17 @@ char * __init xen_memory_setup(void)
 
 	sanitize_e820_map(e820.map, ARRAY_SIZE(e820.map), &e820.nr_map);
 
+	/*
+	 * Check whether the kernel itself conflicts with the target E820 map.
+	 * Failing now is better than running into weird problems later due
+	 * to relocating (and even reusing) pages with kernel text or data.
+	 */
+	if (xen_chk_e820_reserved(__pa_symbol(_text),
+			__pa_symbol(__bss_stop) - __pa_symbol(_text))) {
+		xen_raw_console_write("Xen hypervisor allocated kernel memory conflicts with E820 map\n");
+		BUG();
+	}
+
 	xen_reserve_xen_mfnlist();
 
 	/*
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
