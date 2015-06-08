Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id B60A76B007B
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 08:07:24 -0400 (EDT)
Received: by wifx6 with SMTP id x6so84250768wif.0
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 05:07:24 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l5si4761480wjf.140.2015.06.08.05.07.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 08 Jun 2015 05:07:04 -0700 (PDT)
From: Juergen Gross <jgross@suse.com>
Subject: [Patch V4 09/16] xen: check for kernel memory conflicting with memory layout
Date: Mon,  8 Jun 2015 14:06:50 +0200
Message-Id: <1433765217-16333-10-git-send-email-jgross@suse.com>
In-Reply-To: <1433765217-16333-1-git-send-email-jgross@suse.com>
References: <1433765217-16333-1-git-send-email-jgross@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: xen-devel@lists.xensource.com, konrad.wilk@oracle.com, david.vrabel@citrix.com, boris.ostrovsky@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Juergen Gross <jgross@suse.com>

Checks whether the pre-allocated memory of the loaded kernel is in
conflict with the target memory map. If this is the case, just panic
instead of run into problems later, as there is nothing we can do
to repair this situation.

Signed-off-by: Juergen Gross <jgross@suse.com>
Reviewed-by: David Vrabel <david.vrabel@citrix.com>
---
 arch/x86/xen/setup.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/arch/x86/xen/setup.c b/arch/x86/xen/setup.c
index 973d294..9bd3f35 100644
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
+	if (xen_is_e820_reserved(__pa_symbol(_text),
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
