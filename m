Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 0418F6B005C
	for <linux-mm@kvack.org>; Wed, 13 Mar 2013 02:33:17 -0400 (EDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v2 7/8] mm, vmalloc: export vmap_area_list, instead of vmlist
Date: Wed, 13 Mar 2013 15:32:59 +0900
Message-Id: <1363156381-2881-8-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1363156381-2881-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1363156381-2881-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Anderson <anderson@redhat.com>, Atsushi Kumagai <kumagai-atsushi@mxc.nes.nec.co.jp>, Vivek Goyal <vgoyal@redhat.com>, Bob Liu <lliubbo@gmail.com>, Pekka Enberg <penberg@kernel.org>, kexec@lists.infradead.org, Joonsoo Kim <js1304@gmail.com>, Eric Biederman <ebiederm@xmission.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <js1304@gmail.com>

Although our intention is to unexport internal structure entirely,
but there is one exception for kexec. kexec dumps address of vmlist
and makedumpfile uses this information.

We are about to remove vmlist, then another way to retrieve information
of vmalloc layer is needed for makedumpfile. For this purpose,
we export vmap_area_list, instead of vmlist.

Cc: Eric Biederman <ebiederm@xmission.com>
Cc: Dave Anderson <anderson@redhat.com>
Cc: Vivek Goyal <vgoyal@redhat.com>
Cc: Atsushi Kumagai <kumagai-atsushi@mxc.nes.nec.co.jp>
Signed-off-by: Joonsoo Kim <js1304@gmail.com>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
index 698b1e5..8a25f90 100644
--- a/include/linux/vmalloc.h
+++ b/include/linux/vmalloc.h
@@ -130,8 +130,7 @@ extern long vwrite(char *buf, char *addr, unsigned long count);
 /*
  *	Internals.  Dont't use..
  */
-extern rwlock_t vmlist_lock;
-extern struct vm_struct *vmlist;
+extern struct list_head vmap_area_list;
 extern __init void vm_area_add_early(struct vm_struct *vm);
 extern __init void vm_area_register_early(struct vm_struct *vm, size_t align);
 
diff --git a/kernel/kexec.c b/kernel/kexec.c
index bddd3d7..d9bfc6c 100644
--- a/kernel/kexec.c
+++ b/kernel/kexec.c
@@ -1489,7 +1489,7 @@ static int __init crash_save_vmcoreinfo_init(void)
 	VMCOREINFO_SYMBOL(swapper_pg_dir);
 #endif
 	VMCOREINFO_SYMBOL(_stext);
-	VMCOREINFO_SYMBOL(vmlist);
+	VMCOREINFO_SYMBOL(vmap_area_list);
 
 #ifndef CONFIG_NEED_MULTIPLE_NODES
 	VMCOREINFO_SYMBOL(mem_map);
diff --git a/mm/nommu.c b/mm/nommu.c
index e193280..ed82358 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -228,8 +228,7 @@ int follow_pfn(struct vm_area_struct *vma, unsigned long address,
 }
 EXPORT_SYMBOL(follow_pfn);
 
-DEFINE_RWLOCK(vmlist_lock);
-struct vm_struct *vmlist;
+LIST_HEAD(vmap_area_list);
 
 void vfree(const void *addr)
 {
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index bda6cef..7e63984 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -261,7 +261,8 @@ struct vmap_area {
 };
 
 static DEFINE_SPINLOCK(vmap_area_lock);
-static LIST_HEAD(vmap_area_list);
+/* Export for kexec only */
+LIST_HEAD(vmap_area_list);
 static struct rb_root vmap_area_root = RB_ROOT;
 
 /* The vmap cache globals are protected by vmap_area_lock */
@@ -272,6 +273,10 @@ static unsigned long cached_align;
 
 static unsigned long vmap_area_pcpu_hole;
 
+/*** Old vmalloc interfaces ***/
+static DEFINE_RWLOCK(vmlist_lock);
+static struct vm_struct *vmlist;
+
 static struct vmap_area *__find_vmap_area(unsigned long addr)
 {
 	struct rb_node *n = vmap_area_root.rb_node;
@@ -1283,10 +1288,6 @@ int map_vm_area(struct vm_struct *area, pgprot_t prot, struct page ***pages)
 }
 EXPORT_SYMBOL_GPL(map_vm_area);
 
-/*** Old vmalloc interfaces ***/
-DEFINE_RWLOCK(vmlist_lock);
-struct vm_struct *vmlist;
-
 static void setup_vmalloc_vm(struct vm_struct *vm, struct vmap_area *va,
 			      unsigned long flags, const void *caller)
 {
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
