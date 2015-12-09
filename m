Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 16EEC6B0259
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 12:49:23 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so33170691pac.3
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 09:49:22 -0800 (PST)
Received: from mail-pf0-x235.google.com (mail-pf0-x235.google.com. [2607:f8b0:400e:c00::235])
        by mx.google.com with ESMTPS id 71si13996880pft.108.2015.12.09.09.49.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Dec 2015 09:49:20 -0800 (PST)
Received: by pfbg73 with SMTP id g73so34124412pfb.1
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 09:49:20 -0800 (PST)
From: Yang Shi <yang.shi@linaro.org>
Subject: [PATCH v4 2/7] mm/gup: add gup trace points
Date: Wed,  9 Dec 2015 09:29:19 -0800
Message-Id: <1449682164-9933-3-git-send-email-yang.shi@linaro.org>
In-Reply-To: <1449682164-9933-1-git-send-email-yang.shi@linaro.org>
References: <1449682164-9933-1-git-send-email-yang.shi@linaro.org>
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
index deafa2c..00a3cff 100644
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
 
+	trace_gup_get_user_pages_fast(start, nr_pages);
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
