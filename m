Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 6AE086B0031
	for <linux-mm@kvack.org>; Fri,  7 Feb 2014 07:15:49 -0500 (EST)
Received: by mail-pd0-f180.google.com with SMTP id x10so3087939pdj.11
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 04:15:49 -0800 (PST)
Received: from mail-pb0-x232.google.com (mail-pb0-x232.google.com [2607:f8b0:400e:c01::232])
        by mx.google.com with ESMTPS id ds4si4831955pbb.289.2014.02.07.04.15.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 07 Feb 2014 04:15:47 -0800 (PST)
Received: by mail-pb0-f50.google.com with SMTP id rq2so3170120pbb.23
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 04:15:47 -0800 (PST)
Date: Fri, 7 Feb 2014 17:45:42 +0530
From: Rashika Kheria <rashika.kheria@gmail.com>
Subject: [PATCH 9/9] mm: Remove ifdef condition in include/linux/mm.h
Message-ID: <63adb3b97f2869d4c7e76d17ef4aa76b8cf599f3.1391167128.git.rashika.kheria@gmail.com>
References: <a7658fc8f2ab015bffe83de1448cc3db79d2a9fc.1391167128.git.rashika.kheria@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <a7658fc8f2ab015bffe83de1448cc3db79d2a9fc.1391167128.git.rashika.kheria@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jiang Liu <jiang.liu@huawei.com>, Michel Lespinasse <walken@google.com>, linux-mm@kvack.org, josh@joshtriplett.org

The ifdef conditions in include/linux/mm.h presents three cases:

- !defined(CONFIG_HAVE_MEMBLOCK_NODE_MAP) && !defined(CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID)
There is no actual definition of function but include/linux/mm.h has a
static inline stub defined.

- defined(CONFIG_HAVE_MEMBLOCK_NODE_MAP) && !defined(CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID)
linux/mm.h does not define a prototype, but mm/page_alloc.c defines
the function.
Hence, compiler reports the following warning:
mm/page_alloc.c:4300:15: warning: no previous prototype for a??__early_pfn_to_nida?? [-Wmissing-prototypes]

- defined(CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID)
The architecture defines the function, and linux/mm.h has a prototype.

Thus, join the conditions of Case 2 and 3 i.e. eliminate the ifdef
condition of CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID to eliminate the
missing prototype warning from file mm/page_alloc.c.

Signed-off-by: Rashika Kheria <rashika.kheria@gmail.com>
Reviewed-by: Josh Triplett <josh@joshtriplett.org>
---
 include/linux/mm.h |    2 --
 1 file changed, 2 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 1cedd00..5f8348f 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1589,10 +1589,8 @@ static inline int __early_pfn_to_nid(unsigned long pfn)
 #else
 /* please see mm/page_alloc.c */
 extern int __meminit early_pfn_to_nid(unsigned long pfn);
-#ifdef CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID
 /* there is a per-arch backend function. */
 extern int __meminit __early_pfn_to_nid(unsigned long pfn);
-#endif /* CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID */
 #endif
 
 extern void set_dma_reserve(unsigned long new_dma_reserve);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
