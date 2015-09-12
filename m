Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 53BAA6B0038
	for <linux-mm@kvack.org>; Sat, 12 Sep 2015 02:12:18 -0400 (EDT)
Received: by padhy16 with SMTP id hy16so93845103pad.1
        for <linux-mm@kvack.org>; Fri, 11 Sep 2015 23:12:18 -0700 (PDT)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com. [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id qm11si5477404pab.36.2015.09.11.23.12.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Sep 2015 23:12:17 -0700 (PDT)
Received: by padhk3 with SMTP id hk3so93742644pad.3
        for <linux-mm@kvack.org>; Fri, 11 Sep 2015 23:12:17 -0700 (PDT)
Date: Sat, 12 Sep 2015 14:04:30 +0800
From: Wang YanQing <udknight@gmail.com>
Subject: [PATCH] ARM: mm: avoid unneeded page protection fault for memory
 range with (VM_PFNMAP|VM_PFNWRITE)
Message-ID: <20150912060430.GA16768@udknight>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rmk+kernel@arm.linux.org.uk
Cc: linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux@arm.linux.org.uk

Add L_PTE_DIRTY to PTEs for memory range with (VM_PFNMAP|VM_PFNWRITE),
then we could avoid unneeded page protection fault in write access
first time due to L_PTE_RDONLY.

There are no valid struct pages behind VM_PFNMAP range, so it make no
sense to set L_PTE_DIRTY in page fault handler.

Signed-off-by: Wang YanQing <udknight@gmail.com>
---
 arch/arm/include/asm/mman.h | 21 +++++++++++++++++++++
 1 file changed, 21 insertions(+)
 create mode 100644 arch/arm/include/asm/mman.h

diff --git a/arch/arm/include/asm/mman.h b/arch/arm/include/asm/mman.h
new file mode 100644
index 0000000..f59bbf3
--- /dev/null
+++ b/arch/arm/include/asm/mman.h
@@ -0,0 +1,21 @@
+/*
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version
+ * 2 of the License, or (at your option) any later version.
+ */
+#ifndef __ASM_ARM_MMAN_H
+#define __ASM_ARM_MMAN_H
+
+#include <uapi/asm/mman.h>
+
+static inline pgprot_t arch_vm_get_page_prot(unsigned long vm_flags)
+{
+	if ((vm_flags & (VM_PFNMAP|VM_WRITE)) == (VM_PFNMAP|VM_WRITE))
+		return __pgprot(L_PTE_DIRTY);
+	else
+		return __pgprot(0);
+}
+#define arch_vm_get_page_prot(vm_flags) arch_vm_get_page_prot(vm_flags)
+
+#endif	/* __ASM_ARM_MMAN_H */
-- 
1.8.5.6.2.g3d8a54e.dirty

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
