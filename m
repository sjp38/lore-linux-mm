Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f53.google.com (mail-yh0-f53.google.com [209.85.213.53])
	by kanga.kvack.org (Postfix) with ESMTP id A4E316B0038
	for <linux-mm@kvack.org>; Fri, 29 Aug 2014 10:55:01 -0400 (EDT)
Received: by mail-yh0-f53.google.com with SMTP id a41so1554149yho.40
        for <linux-mm@kvack.org>; Fri, 29 Aug 2014 07:55:01 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id w66si222012yhc.90.2014.08.29.07.55.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 29 Aug 2014 07:55:00 -0700 (PDT)
From: Sasha Levin <sasha.levin@oracle.com>
Subject: [PATCH 2/3] Introduce VM_BUG_ON_VMA
Date: Fri, 29 Aug 2014 10:54:18 -0400
Message-Id: <1409324059-28692-2-git-send-email-sasha.levin@oracle.com>
In-Reply-To: <1409324059-28692-1-git-send-email-sasha.levin@oracle.com>
References: <1409324059-28692-1-git-send-email-sasha.levin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: kirill.shutemov@linux.intel.com, khlebnikov@openvz.org, riel@redhat.com, mgorman@suse.de, n-horiguchi@ah.jp.nec.com, mhocko@suse.cz, hughd@google.com, vbabka@suse.cz, walken@google.com, minchan@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sasha Levin <sasha.levin@oracle.com>

Very similar to VM_BUG_ON_PAGE but dumps VMA information instead.

Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---
 include/linux/mmdebug.h |    8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/include/linux/mmdebug.h b/include/linux/mmdebug.h
index dfb9333..569e4c8 100644
--- a/include/linux/mmdebug.h
+++ b/include/linux/mmdebug.h
@@ -20,12 +20,20 @@ void dump_vma(const struct vm_area_struct *vma);
 			BUG();						\
 		}							\
 	} while (0)
+#define VM_BUG_ON_VMA(cond, vma)					\
+	do {								\
+		if (unlikely(cond)) {					\
+			dump_vma(vma);					\
+			BUG();						\
+		}							\
+	} while (0)
 #define VM_WARN_ON(cond) WARN_ON(cond)
 #define VM_WARN_ON_ONCE(cond) WARN_ON_ONCE(cond)
 #define VM_WARN_ONCE(cond, format...) WARN_ONCE(cond, format)
 #else
 #define VM_BUG_ON(cond) BUILD_BUG_ON_INVALID(cond)
 #define VM_BUG_ON_PAGE(cond, page) VM_BUG_ON(cond)
+#define VM_BUG_ON_VMA(cond, vma) VM_BUG_ON(cond)
 #define VM_WARN_ON(cond) BUILD_BUG_ON_INVALID(cond)
 #define VM_WARN_ON_ONCE(cond) BUILD_BUG_ON_INVALID(cond)
 #define VM_WARN_ONCE(cond, format...) BUILD_BUG_ON_INVALID(cond)
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
