Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8107B2806D7
	for <linux-mm@kvack.org>; Tue,  9 May 2017 10:41:28 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id s5so483396lfs.11
        for <linux-mm@kvack.org>; Tue, 09 May 2017 07:41:28 -0700 (PDT)
Received: from mail-lf0-f68.google.com (mail-lf0-f68.google.com. [209.85.215.68])
        by mx.google.com with ESMTPS id t17si96735lfd.237.2017.05.09.07.41.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 May 2017 07:41:26 -0700 (PDT)
Received: by mail-lf0-f68.google.com with SMTP id q24so168006lfb.1
        for <linux-mm@kvack.org>; Tue, 09 May 2017 07:41:26 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH] mm, vmalloc: fix vmalloc users tracking properly
Date: Tue,  9 May 2017 16:41:08 +0200
Message-Id: <20170509144108.31910-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Tobias Klauser <tklauser@distanz.ch>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

1f5307b1e094 ("mm, vmalloc: properly track vmalloc users") has pulled
asm/pgtable.h include dependency to linux/vmalloc.h and that turned out
to be a bad idea for some architectures. E.g. m68k fails with
   In file included from arch/m68k/include/asm/pgtable_mm.h:145:0,
                    from arch/m68k/include/asm/pgtable.h:4,
                    from include/linux/vmalloc.h:9,
                    from arch/m68k/kernel/module.c:9:
   arch/m68k/include/asm/mcf_pgtable.h: In function 'nocache_page':
>> arch/m68k/include/asm/mcf_pgtable.h:339:43: error: 'init_mm' undeclared (first use in this function)
    #define pgd_offset_k(address) pgd_offset(&init_mm, address)

as spotted by kernel build bot. nios2 fails for other reason
In file included from ./include/asm-generic/io.h:767:0,
                 from ./arch/nios2/include/asm/io.h:61,
                 from ./include/linux/io.h:25,
                 from ./arch/nios2/include/asm/pgtable.h:18,
                 from ./include/linux/mm.h:70,
                 from ./include/linux/pid_namespace.h:6,
                 from ./include/linux/ptrace.h:9,
                 from ./arch/nios2/include/uapi/asm/elf.h:23,
                 from ./arch/nios2/include/asm/elf.h:22,
                 from ./include/linux/elf.h:4,
                 from ./include/linux/module.h:15,
                 from init/main.c:16:
./include/linux/vmalloc.h: In function '__vmalloc_node_flags':
./include/linux/vmalloc.h:99:40: error: 'PAGE_KERNEL' undeclared (first use in this function); did you mean 'GFP_KERNEL'?

which is due to the newly added #include <asm/pgtable.h>, which on nios2
includes <linux/io.h> and thus <asm/io.h> and <asm-generic/io.h> which
again includes <linux/vmalloc.h>.

Tweaking that around just turns out a bigger headache than
necessary. This patch reverts 1f5307b1e094 and reimplements the original
fix in a different way. __vmalloc_node_flags can stay static inline
which will cover vmalloc* functions. We only have one external user
(kvmalloc_node) and we can export __vmalloc_node_flags_caller and
provide the caller directly. This is much simpler and it doesn't really
need any games with header files.

Fixes: 1f5307b1e094 ("mm, vmalloc: properly track vmalloc users")
Signed-off-by: Michal Hocko <mhocko@suse.com>
---

Hi Linus and Andrew,
it seems that this one slipped through cracks as well. Kbuild robot has
quickly noticed that my original fix doesn't compile on m68k [1] and
I've provided fix [2] at the time but it seems Andrew has missed it and
sent the wrong one which got merged. Other users have noticed as well [3].

This is a full revert along with the fix.  I can split it to a revert
and the new fix if you prefer. Just let me know.

[1] http://lkml.kernel.org/r/201705030806.pzzQRBiN%fengguang.wu@intel.com
[2] http://lkml.kernel.org/r/20170503063750.GC1236@dhcp22.suse.cz
[3] http://lkml.kernel.org/r/20170509085045.7342-1-tklauser@distanz.ch

 include/linux/vmalloc.h | 19 +++++++------------
 mm/util.c               |  3 ++-
 mm/vmalloc.c            | 18 +++++++++++++++++-
 3 files changed, 26 insertions(+), 14 deletions(-)

diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
index 0328ce003992..4a0fabeb1e92 100644
--- a/include/linux/vmalloc.h
+++ b/include/linux/vmalloc.h
@@ -6,7 +6,6 @@
 #include <linux/list.h>
 #include <linux/llist.h>
 #include <asm/page.h>		/* pgprot_t */
-#include <asm/pgtable.h>	/* PAGE_KERNEL */
 #include <linux/rbtree.h>
 
 struct vm_area_struct;		/* vma defining user mapping in mm_types.h */
@@ -82,23 +81,19 @@ extern void *__vmalloc_node_range(unsigned long size, unsigned long align,
 			pgprot_t prot, unsigned long vm_flags, int node,
 			const void *caller);
 #ifndef CONFIG_MMU
-extern void *__vmalloc_node_flags(unsigned long size, int node, gfp_t flags);
+extern void *__vmalloc_node_flags_caller(unsigned long size, int node, gfp_t flags);
+static inline void *__vmalloc_node_flags_caller(unsigned long size, int node, gfp_t flags, void* caller)
+{
+	return __vmalloc_node_flags(size, node, flags);
+}
 #else
-extern void *__vmalloc_node(unsigned long size, unsigned long align,
-			    gfp_t gfp_mask, pgprot_t prot,
-			    int node, const void *caller);
-
 /*
  * We really want to have this inlined due to caller tracking. This
  * function is used by the highlevel vmalloc apis and so we want to track
  * their callers and inlining will achieve that.
  */
-static inline void *__vmalloc_node_flags(unsigned long size,
-					int node, gfp_t flags)
-{
-	return __vmalloc_node(size, 1, flags, PAGE_KERNEL,
-					node, __builtin_return_address(0));
-}
+extern void *__vmalloc_node_flags_caller(unsigned long size,
+					int node, gfp_t flags, void* caller);
 #endif
 
 extern void vfree(const void *addr);
diff --git a/mm/util.c b/mm/util.c
index 718154debc87..464df3489903 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -382,7 +382,8 @@ void *kvmalloc_node(size_t size, gfp_t flags, int node)
 	if (ret || size <= PAGE_SIZE)
 		return ret;
 
-	return __vmalloc_node_flags(size, node, flags);
+	return __vmalloc_node_flags_caller(size, node, flags,
+			__builtin_return_address(0));
 }
 EXPORT_SYMBOL(kvmalloc_node);
 
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 1dda6d8a200a..4a1de70e68e1 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1649,6 +1649,9 @@ void *vmap(struct page **pages, unsigned int count,
 }
 EXPORT_SYMBOL(vmap);
 
+static void *__vmalloc_node(unsigned long size, unsigned long align,
+			    gfp_t gfp_mask, pgprot_t prot,
+			    int node, const void *caller);
 static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
 				 pgprot_t prot, int node)
 {
@@ -1791,7 +1794,7 @@ void *__vmalloc_node_range(unsigned long size, unsigned long align,
  *	with mm people.
  *
  */
-void *__vmalloc_node(unsigned long size, unsigned long align,
+static void *__vmalloc_node(unsigned long size, unsigned long align,
 			    gfp_t gfp_mask, pgprot_t prot,
 			    int node, const void *caller)
 {
@@ -1806,6 +1809,19 @@ void *__vmalloc(unsigned long size, gfp_t gfp_mask, pgprot_t prot)
 }
 EXPORT_SYMBOL(__vmalloc);
 
+static inline void *__vmalloc_node_flags(unsigned long size,
+					int node, gfp_t flags)
+{
+	return __vmalloc_node(size, 1, flags, PAGE_KERNEL,
+					node, __builtin_return_address(0));
+}
+
+
+void *__vmalloc_node_flags_caller(unsigned long size, int node, gfp_t flags, void *caller)
+{
+	return __vmalloc_node(size, 1, flags, PAGE_KERNEL, node, caller);
+}
+
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
