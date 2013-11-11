Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f47.google.com (mail-pb0-f47.google.com [209.85.160.47])
	by kanga.kvack.org (Postfix) with ESMTP id 18A6F6B00F8
	for <linux-mm@kvack.org>; Mon, 11 Nov 2013 18:27:11 -0500 (EST)
Received: by mail-pb0-f47.google.com with SMTP id rq2so2957178pbb.20
        for <linux-mm@kvack.org>; Mon, 11 Nov 2013 15:27:10 -0800 (PST)
Received: from psmtp.com ([74.125.245.194])
        by mx.google.com with SMTP id yk3si17552570pac.331.2013.11.11.15.27.08
        for <linux-mm@kvack.org>;
        Mon, 11 Nov 2013 15:27:09 -0800 (PST)
From: Laura Abbott <lauraa@codeaurora.org>
Subject: [RFC PATCH 4/4] mm/vmalloc.c: Treat the entire kernel virtual space as vmalloc
Date: Mon, 11 Nov 2013 15:26:52 -0800
Message-Id: <1384212412-21236-5-git-send-email-lauraa@codeaurora.org>
In-Reply-To: <1384212412-21236-1-git-send-email-lauraa@codeaurora.org>
References: <1384212412-21236-1-git-send-email-lauraa@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org
Cc: Laura Abbott <lauraa@codeaurora.org>, Neeti Desai <neetid@codeaurora.org>

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
index c7b138b..181247d 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1385,16 +1385,27 @@ struct vm_struct *__get_vm_area_caller(unsigned long size, unsigned long flags,
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
