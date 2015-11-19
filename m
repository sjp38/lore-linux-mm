Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id E72BF6B0253
	for <linux-mm@kvack.org>; Wed, 18 Nov 2015 19:30:43 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so63077030pab.0
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 16:30:43 -0800 (PST)
Received: from mail-pa0-x230.google.com (mail-pa0-x230.google.com. [2607:f8b0:400e:c03::230])
        by mx.google.com with ESMTPS id tv2si7614126pac.119.2015.11.18.16.30.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Nov 2015 16:30:43 -0800 (PST)
Received: by pacdm15 with SMTP id dm15so61048392pac.3
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 16:30:43 -0800 (PST)
Date: Wed, 18 Nov 2015 16:30:41 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm] mm, vmalloc: remove VM_VPAGES
Message-ID: <alpine.DEB.2.10.1511181629220.1381@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

VM_VPAGES is unnecessary, it's easier to check is_vmalloc_addr() when
reading /proc/vmallocinfo.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 include/linux/vmalloc.h | 1 -
 mm/vmalloc.c            | 3 +--
 2 files changed, 1 insertion(+), 3 deletions(-)

diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
--- a/include/linux/vmalloc.h
+++ b/include/linux/vmalloc.h
@@ -14,7 +14,6 @@ struct vm_area_struct;		/* vma defining user mapping in mm_types.h */
 #define VM_ALLOC		0x00000002	/* vmalloc() */
 #define VM_MAP			0x00000004	/* vmap()ed pages */
 #define VM_USERMAP		0x00000008	/* suitable for remap_vmalloc_range */
-#define VM_VPAGES		0x00000010	/* buffer for pages was vmalloc'ed */
 #define VM_UNINITIALIZED	0x00000020	/* vm_struct is not fully initialized */
 #define VM_NO_GUARD		0x00000040      /* don't add guard page */
 #define VM_KASAN		0x00000080      /* has allocated kasan shadow memory */
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1591,7 +1591,6 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
 	if (array_size > PAGE_SIZE) {
 		pages = __vmalloc_node(array_size, 1, nested_gfp|__GFP_HIGHMEM,
 				PAGE_KERNEL, node, area->caller);
-		area->flags |= VM_VPAGES;
 	} else {
 		pages = kmalloc_node(array_size, nested_gfp, node);
 	}
@@ -2649,7 +2648,7 @@ static int s_show(struct seq_file *m, void *p)
 	if (v->flags & VM_USERMAP)
 		seq_puts(m, " user");
 
-	if (v->flags & VM_VPAGES)
+	if (is_vmalloc_addr(v->pages))
 		seq_puts(m, " vpages");
 
 	show_numa_info(m, v);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
