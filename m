Subject: [PATCH] 2.6.9-rc3-mm2 alloc_percpu fix for non-NUMA
From: Badari Pulavarty <pbadari@us.ibm.com>
Content-Type: multipart/mixed; boundary="=-eOeuRYUE3He0+4NtAWPn"
Message-Id: <1097161585.12861.240.camel@dyn318077bld.beaverton.ibm.com>
Mime-Version: 1.0
Date: 07 Oct 2004 08:06:25 -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

--=-eOeuRYUE3He0+4NtAWPn
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hi,

alloc_percpu() calls kmem_cache_alloc_node() to allocate memory
on a particular node. But for non-NUMA cases, it doesn't matter
all the memory comes from same node.  This patch short-cuts and 
calls kmalloc() if its non-NUMA. I hate to add #ifdefs in the 
mainline code, but I don't see easy way around.

kmem_cache_alloc_node()allocates a new slab to satisfy allocation 
from that node instead of doing it from a partial slab from that node 
- which causes fragmentation (with my scsi-debug tests). Thats my 
next problem to deal with.

BTW, with this patch size-64 cache is no longer fragmented for
scsi-debug test case.

size-64            76920  76921     64   61    1 : tunables  120   60   
8 : slabdata   1261   1261   0

Thanks,
Badari




--=-eOeuRYUE3He0+4NtAWPn
Content-Disposition: attachment; filename=alloc_percpu_fix.patch
Content-Type: text/plain; name=alloc_percpu_fix.patch; charset=UTF-8
Content-Transfer-Encoding: 7bit

Signed-off-by: pbadari@us.ibm.com
--- linux-2.6.9-rc3.org/mm/slab.c	2004-10-07 07:55:05.451137928 -0700
+++ linux-2.6.9-rc3/mm/slab.c	2004-10-07 07:55:56.990160360 -0700
@@ -2452,9 +2452,13 @@ void *__alloc_percpu(size_t size, size_t
 	for (i = 0; i < NR_CPUS; i++) {
 		if (!cpu_possible(i))
 			continue;
+#ifdef CONFIG_NUMA
 		pdata->ptrs[i] = kmem_cache_alloc_node(
 				kmem_find_general_cachep(size, GFP_KERNEL),
 				cpu_to_node(i));
+#else
+		pdata->ptrs[i] = kmalloc(size, GFP_KERNEL);
+#endif
 
 		if (!pdata->ptrs[i])
 			goto unwind_oom;

--=-eOeuRYUE3He0+4NtAWPn--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
