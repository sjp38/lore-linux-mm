Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f181.google.com (mail-pf0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id C47E76B0256
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 14:59:57 -0500 (EST)
Received: by pfbg73 with SMTP id g73so17426096pfb.1
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 11:59:57 -0800 (PST)
Received: from mail-pa0-x230.google.com (mail-pa0-x230.google.com. [2607:f8b0:400e:c03::230])
        by mx.google.com with ESMTPS id xd1si7081916pab.130.2015.12.08.11.59.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Dec 2015 11:59:55 -0800 (PST)
Received: by pacdm15 with SMTP id dm15so16918352pac.3
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 11:59:55 -0800 (PST)
From: Yang Shi <yang.shi@linaro.org>
Subject: [PATCH v3 2/7] mm/gup: add gup trace points
Date: Tue,  8 Dec 2015 11:39:50 -0800
Message-Id: <1449603595-718-3-git-send-email-yang.shi@linaro.org>
In-Reply-To: <1449603595-718-1-git-send-email-yang.shi@linaro.org>
References: <1449603595-718-1-git-send-email-yang.shi@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, rostedt@goodmis.org, mingo@redhat.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org, yang.shi@linaro.org

For slow version, just add trace point for raw __get_user_pages since all
slow variants call it to do the real work finally.

Signed-off-by: Yang Shi <yang.shi@linaro.org>
---
 mm/gup.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/mm/gup.c b/mm/gup.c
index deafa2c..44f05c9 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -18,6 +18,9 @@
 
 #include "internal.h"
 
+#define CREATE_TRACE_POINTS
+#include <trace/events/gup.h>
+
 static struct page *no_page_table(struct vm_area_struct *vma,
 		unsigned int flags)
 {
@@ -462,6 +465,8 @@ long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 	if (!nr_pages)
 		return 0;
 
+	trace_gup_get_user_pages(start, nr_pages);
+
 	VM_BUG_ON(!!pages != !!(gup_flags & FOLL_GET));
 
 	/*
@@ -599,6 +604,7 @@ int fixup_user_fault(struct task_struct *tsk, struct mm_struct *mm,
 	if (!(vm_flags & vma->vm_flags))
 		return -EFAULT;
 
+	trace_gup_fixup_user_fault(address);
 	ret = handle_mm_fault(mm, vma, address, fault_flags);
 	if (ret & VM_FAULT_ERROR) {
 		if (ret & VM_FAULT_OOM)
@@ -1340,6 +1346,8 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
 					start, len)))
 		return 0;
 
+	trace_gup_get_user_pages_fast(start, (unsigned long) nr_pages);
+
 	/*
 	 * Disable interrupts.  We use the nested form as we can already have
 	 * interrupts disabled by get_futex_key.
-- 
2.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
