Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id E471E6B0195
	for <linux-mm@kvack.org>; Sat, 16 Oct 2010 00:33:25 -0400 (EDT)
Received: by pzk1 with SMTP id 1so306514pzk.14
        for <linux-mm@kvack.org>; Fri, 15 Oct 2010 21:33:19 -0700 (PDT)
Date: Sat, 16 Oct 2010 12:33:31 +0800
From: Dave Young <hidave.darkstar@gmail.com>
Subject: [PATCH 1/2] Add vzalloc shortcut
Message-ID: <20101016043331.GA3177@darkstar>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, kvm@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Add vzalloc for convinience of vmalloc-then-memset-zero case 

Use __GFP_ZERO in vzalloc to zero fill the allocated memory.

Signed-off-by: Dave Young <hidave.darkstar@gmail.com>
---
 include/linux/vmalloc.h |    1 +
 mm/vmalloc.c            |   13 +++++++++++++
 2 files changed, 14 insertions(+)

--- linux-2.6.orig/include/linux/vmalloc.h	2010-08-22 15:31:38.000000000 +0800
+++ linux-2.6/include/linux/vmalloc.h	2010-10-16 10:50:54.739996121 +0800
@@ -53,6 +53,7 @@ static inline void vmalloc_init(void)
 #endif
 
 extern void *vmalloc(unsigned long size);
+extern void *vzalloc(unsigned long size);
 extern void *vmalloc_user(unsigned long size);
 extern void *vmalloc_node(unsigned long size, int node);
 extern void *vmalloc_exec(unsigned long size);
--- linux-2.6.orig/mm/vmalloc.c	2010-08-22 15:31:39.000000000 +0800
+++ linux-2.6/mm/vmalloc.c	2010-10-16 10:51:57.126665918 +0800
@@ -1604,6 +1604,19 @@ void *vmalloc(unsigned long size)
 EXPORT_SYMBOL(vmalloc);
 
 /**
+ *	vzalloc  -  allocate virtually contiguous memory with zero filled
+ *	@size:		allocation size
+ *	Allocate enough pages to cover @size from the page level
+ *	allocator and map them into contiguous kernel virtual space.
+ */
+void *vzalloc(unsigned long size)
+{
+	return __vmalloc_node(size, 1, GFP_KERNEL | __GFP_HIGHMEM | __GFP_ZERO,
+				PAGE_KERNEL, -1, __builtin_return_address(0));
+}
+EXPORT_SYMBOL(vzalloc);
+
+/**
  * vmalloc_user - allocate zeroed virtually contiguous memory for userspace
  * @size: allocation size
  *

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
