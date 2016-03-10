Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f181.google.com (mail-pf0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id BA1166B0256
	for <linux-mm@kvack.org>; Thu, 10 Mar 2016 18:55:39 -0500 (EST)
Received: by mail-pf0-f181.google.com with SMTP id 129so80442733pfw.1
        for <linux-mm@kvack.org>; Thu, 10 Mar 2016 15:55:39 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id e69si1448939pfd.66.2016.03.10.15.55.38
        for <linux-mm@kvack.org>;
        Thu, 10 Mar 2016 15:55:38 -0800 (PST)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH v5 01/14] mmdebug: Always evaluate the arguments to VM_BUG_ON_*
Date: Thu, 10 Mar 2016 18:55:18 -0500
Message-Id: <1457654131-4562-2-git-send-email-matthew.r.wilcox@intel.com>
In-Reply-To: <1457654131-4562-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1457654131-4562-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, x86@kernel.org, willy@linux.intel.com

I recently got the order of arguments to VM_BUG_ON_VMA the wrong way
around, which was only noticable when compiling with CONFIG_DEBUG_VM.
Prevent the next mistake of this kind by making the macros evaluate both
their arguments at compile time (this has no effect on the built kernel).

Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
---
 include/linux/mmdebug.h | 21 ++++++++++++++++++---
 1 file changed, 18 insertions(+), 3 deletions(-)

diff --git a/include/linux/mmdebug.h b/include/linux/mmdebug.h
index de7be78..abfc316 100644
--- a/include/linux/mmdebug.h
+++ b/include/linux/mmdebug.h
@@ -41,9 +41,24 @@ void dump_mm(const struct mm_struct *mm);
 #define VM_WARN_ONCE(cond, format...) WARN_ONCE(cond, format)
 #else
 #define VM_BUG_ON(cond) BUILD_BUG_ON_INVALID(cond)
-#define VM_BUG_ON_PAGE(cond, page) VM_BUG_ON(cond)
-#define VM_BUG_ON_VMA(cond, vma) VM_BUG_ON(cond)
-#define VM_BUG_ON_MM(cond, mm) VM_BUG_ON(cond)
+#define VM_BUG_ON_PAGE(cond, page)					\
+	do {								\
+		if (0) dump_page(page, "");				\
+		VM_BUG_ON(cond);					\
+	} while (0)
+
+#define VM_BUG_ON_VMA(cond, vma)					\
+	do {								\
+		if (0) dump_vma(vma);					\
+		VM_BUG_ON(cond);					\
+	} while (0)
+
+#define VM_BUG_ON_MM(cond, mm)						\
+	do {								\
+		if (0) dump_mm(mm);					\
+		VM_BUG_ON(cond);					\
+	} while (0)
+
 #define VM_WARN_ON(cond) BUILD_BUG_ON_INVALID(cond)
 #define VM_WARN_ON_ONCE(cond) BUILD_BUG_ON_INVALID(cond)
 #define VM_WARN_ONCE(cond, format...) BUILD_BUG_ON_INVALID(cond)
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
