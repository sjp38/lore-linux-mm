Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 554A36B0069
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 11:58:39 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id w5so12882963pgt.4
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 08:58:39 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id l5si10313357pgr.469.2017.12.19.08.58.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Dec 2017 08:58:38 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 2/2] Introduce __cond_lock_err
Date: Tue, 19 Dec 2017 08:58:23 -0800
Message-Id: <20171219165823.24243-2-willy@infradead.org>
In-Reply-To: <20171219165823.24243-1-willy@infradead.org>
References: <20171219165823.24243-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, linux-mm@kvack.org, Josh Triplett <josh@joshtriplett.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

The __cond_lock macro expects the function to return 'true' if the lock
was acquired and 'false' if it wasn't.  We have another common calling
convention in the kernel, which is returning 0 on success and an errno
on failure.  It's hard to use the existing __cond_lock macro for those
kinds of functions, so introduce __cond_lock_err() and convert the
two existing users.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/compiler_types.h | 2 ++
 include/linux/mm.h             | 9 ++-------
 mm/memory.c                    | 9 ++-------
 3 files changed, 6 insertions(+), 14 deletions(-)

diff --git a/include/linux/compiler_types.h b/include/linux/compiler_types.h
index 6b79a9bba9a7..ff3c41c78efa 100644
--- a/include/linux/compiler_types.h
+++ b/include/linux/compiler_types.h
@@ -16,6 +16,7 @@
 # define __acquire(x)	__context__(x,1)
 # define __release(x)	__context__(x,-1)
 # define __cond_lock(x,c)	((c) ? ({ __acquire(x); 1; }) : 0)
+# define __cond_lock_err(x,c)	((c) ? 1 : ({ __acquire(x); 0; }))
 # define __percpu	__attribute__((noderef, address_space(3)))
 # define __rcu		__attribute__((noderef, address_space(4)))
 # define __private	__attribute__((noderef))
@@ -42,6 +43,7 @@ extern void __chk_io_ptr(const volatile void __iomem *);
 # define __acquire(x) (void)0
 # define __release(x) (void)0
 # define __cond_lock(x,c) (c)
+# define __cond_lock_err(x,c) (c)
 # define __percpu
 # define __rcu
 # define __private
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 94a9d2149bd6..2ccdc980296b 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1328,13 +1328,8 @@ static inline int follow_pte_pmd(struct mm_struct *mm, unsigned long address,
 			     unsigned long *start, unsigned long *end,
 			     pte_t **ptepp, pmd_t **pmdpp, spinlock_t **ptlp)
 {
-	int res;
-
-	/* (void) is needed to make gcc happy */
-	(void) __cond_lock(*ptlp,
-			   !(res = __follow_pte_pmd(mm, address, start, end,
-						    ptepp, pmdpp, ptlp)));
-	return res;
+	return __cond_lock_err(*ptlp, __follow_pte_pmd(mm, address, start, end,
+						    ptepp, pmdpp, ptlp));
 }
 
 static inline void unmap_shared_mapping_range(struct address_space *mapping,
diff --git a/mm/memory.c b/mm/memory.c
index cb433662af21..92d58309cf45 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -4269,13 +4269,8 @@ int __follow_pte_pmd(struct mm_struct *mm, unsigned long address,
 static inline int follow_pte(struct mm_struct *mm, unsigned long address,
 			     pte_t **ptepp, spinlock_t **ptlp)
 {
-	int res;
-
-	/* (void) is needed to make gcc happy */
-	(void) __cond_lock(*ptlp,
-			   !(res = __follow_pte_pmd(mm, address, NULL, NULL,
-						    ptepp, NULL, ptlp)));
-	return res;
+	return __cond_lock_err(*ptlp, __follow_pte_pmd(mm, address, NULL, NULL,
+						    ptepp, NULL, ptlp));
 }
 
 /**
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
