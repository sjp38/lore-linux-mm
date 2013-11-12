Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 2877F6B00AE
	for <linux-mm@kvack.org>; Tue, 12 Nov 2013 17:27:45 -0500 (EST)
Received: by mail-pd0-f174.google.com with SMTP id z10so7508562pdj.5
        for <linux-mm@kvack.org>; Tue, 12 Nov 2013 14:27:44 -0800 (PST)
Received: from psmtp.com ([74.125.245.113])
        by mx.google.com with SMTP id ws5si21372951pab.296.2013.11.12.14.27.43
        for <linux-mm@kvack.org>;
        Tue, 12 Nov 2013 14:27:43 -0800 (PST)
From: Laura Abbott <lauraa@codeaurora.org>
Subject: [RFC PATCHv2 4/4] mm/vmalloc.c: Treat the entire kernel virtual space as vmalloc
Date: Tue, 12 Nov 2013 14:27:32 -0800
Message-Id: <1384295252-31778-5-git-send-email-lauraa@codeaurora.org>
In-Reply-To: <1384295252-31778-1-git-send-email-lauraa@codeaurora.org>
References: <1384295252-31778-1-git-send-email-lauraa@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org
Cc: Kyungmin Park <kmpark@infradead.org>, Russell King <linux@arm.linux.org.uk>, Laura Abbott <lauraa@codeaurora.org>, Neeti Desai <neetid@codeaurora.org>

With CONFIG_ENABLE_VMALLOC_SAVINGS, all lowmem is tracked in
vmalloc. This means that all the kernel virtual address space
can be treated as part of the vmalloc region. Allow vm areas
to be allocated from the full kernel address range.

Signed-off-by: Laura Abbott <lauraa@codeaurora.org>
Signed-off-by: Neeti Desai <neetid@codeaurora.org>
---
 mm/vmalloc.c |   11 +++++++++++
 1 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 2ec9ac7..31644b6 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1394,16 +1394,27 @@ struct vm_struct *__get_vm_area_caller(unsigned long size, unsigned long flags,
  */
 struct vm_struct *get_vm_area(unsigned long size, unsigned long flags)
 {
+#ifdef CONFIG_ENABLE_VMALLOC_SAVING
+	return __get_vm_area_node(size, 1, flags, PAGE_OFFSET, VMALLOC_END,
+				  NUMA_NO_NODE, GFP_KERNEL,
+				  __builtin_return_address(0));
+#else
 	return __get_vm_area_node(size, 1, flags, VMALLOC_START, VMALLOC_END,
 				  NUMA_NO_NODE, GFP_KERNEL,
 				  __builtin_return_address(0));
+#endif
 }
 
 struct vm_struct *get_vm_area_caller(unsigned long size, unsigned long flags,
 				const void *caller)
 {
+#ifdef CONFIG_ENABLE_VMALLOC_SAVING
+	return __get_vm_area_node(size, 1, flags, PAGE_OFFSET, VMALLOC_END,
+				  NUMA_NO_NODE, GFP_KERNEL, caller);
+#else
 	return __get_vm_area_node(size, 1, flags, VMALLOC_START, VMALLOC_END,
 				  NUMA_NO_NODE, GFP_KERNEL, caller);
+#endif
 }
 
 /**
-- 
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum,
hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
