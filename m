Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id C7CCC6B02F2
	for <linux-mm@kvack.org>; Tue,  2 May 2017 09:47:04 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id p62so14087875wrc.13
        for <linux-mm@kvack.org>; Tue, 02 May 2017 06:47:04 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id 12si19797292wrt.64.2017.05.02.06.47.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 May 2017 06:47:03 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id u65so4664548wmu.3
        for <linux-mm@kvack.org>; Tue, 02 May 2017 06:47:03 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH] mm, vmalloc: properly track vmalloc users
Date: Tue,  2 May 2017 15:46:57 +0200
Message-Id: <20170502134657.12381-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

__vmalloc_node_flags used to be static inline but this has changed by
"mm: introduce kv[mz]alloc helpers" because kvmalloc_node needs to use
it as well and the code is outside of the vmalloc proper. I haven't
realized that changing this will lead to a subtle bug though. The
function is responsible to track the caller as well. This caller is
then printed by /proc/vmallocinfo. If __vmalloc_node_flags is not inline
then we would get only direct users of __vmalloc_node_flags as callers
(e.g. v[mz]alloc) which reduces usefulness of this debugging feature
considerably. It simply doesn't help to see that the given range belongs
to vmalloc as a caller:
0xffffc90002c79000-0xffffc90002c7d000   16384 vmalloc+0x16/0x18 pages=3 vmalloc N0=3
0xffffc90002c81000-0xffffc90002c85000   16384 vmalloc+0x16/0x18 pages=3 vmalloc N1=3
0xffffc90002c8d000-0xffffc90002c91000   16384 vmalloc+0x16/0x18 pages=3 vmalloc N1=3
0xffffc90002c95000-0xffffc90002c99000   16384 vmalloc+0x16/0x18 pages=3 vmalloc N1=3

We really want to catch the _caller_ of the vmalloc function. Fix this
issue by making __vmalloc_node_flags static inline again.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
Hi Andrew,
this is a follow up fix for mm-introduce-kvalloc-helpers.patch currently
sitting in your mmotm tree. You can either fold this into it or just
keep it on its own which I would consider slightly better for the
reference.  Anyway it would be great if it could hit the Linus' tree
along with the original patch.

I am sorry, I should have noticed this earlier.

 include/linux/vmalloc.h | 19 +++++++++++++++++++
 mm/vmalloc.c            | 12 +-----------
 2 files changed, 20 insertions(+), 11 deletions(-)

diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
index 46991ad3ddd5..0328ce003992 100644
--- a/include/linux/vmalloc.h
+++ b/include/linux/vmalloc.h
@@ -6,6 +6,7 @@
 #include <linux/list.h>
 #include <linux/llist.h>
 #include <asm/page.h>		/* pgprot_t */
+#include <asm/pgtable.h>	/* PAGE_KERNEL */
 #include <linux/rbtree.h>
 
 struct vm_area_struct;		/* vma defining user mapping in mm_types.h */
@@ -80,7 +81,25 @@ extern void *__vmalloc_node_range(unsigned long size, unsigned long align,
 			unsigned long start, unsigned long end, gfp_t gfp_mask,
 			pgprot_t prot, unsigned long vm_flags, int node,
 			const void *caller);
+#ifndef CONFIG_MMU
 extern void *__vmalloc_node_flags(unsigned long size, int node, gfp_t flags);
+#else
+extern void *__vmalloc_node(unsigned long size, unsigned long align,
+			    gfp_t gfp_mask, pgprot_t prot,
+			    int node, const void *caller);
+
+/*
+ * We really want to have this inlined due to caller tracking. This
+ * function is used by the highlevel vmalloc apis and so we want to track
+ * their callers and inlining will achieve that.
+ */
+static inline void *__vmalloc_node_flags(unsigned long size,
+					int node, gfp_t flags)
+{
+	return __vmalloc_node(size, 1, flags, PAGE_KERNEL,
+					node, __builtin_return_address(0));
+}
+#endif
 
 extern void vfree(const void *addr);
 extern void vfree_atomic(const void *addr);
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 65912eb93a2c..201eb20ba96a 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1649,9 +1649,6 @@ void *vmap(struct page **pages, unsigned int count,
 }
 EXPORT_SYMBOL(vmap);
 
-static void *__vmalloc_node(unsigned long size, unsigned long align,
-			    gfp_t gfp_mask, pgprot_t prot,
-			    int node, const void *caller);
 static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
 				 pgprot_t prot, int node)
 {
@@ -1794,7 +1791,7 @@ void *__vmalloc_node_range(unsigned long size, unsigned long align,
  *	with mm people.
  *
  */
-static void *__vmalloc_node(unsigned long size, unsigned long align,
+void *__vmalloc_node(unsigned long size, unsigned long align,
 			    gfp_t gfp_mask, pgprot_t prot,
 			    int node, const void *caller)
 {
@@ -1809,13 +1806,6 @@ void *__vmalloc(unsigned long size, gfp_t gfp_mask, pgprot_t prot)
 }
 EXPORT_SYMBOL(__vmalloc);
 
-void *__vmalloc_node_flags(unsigned long size,
-					int node, gfp_t flags)
-{
-	return __vmalloc_node(size, 1, flags, PAGE_KERNEL,
-					node, __builtin_return_address(0));
-}
-
 /**
  *	vmalloc  -  allocate virtually contiguous memory
  *	@size:		allocation size
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
