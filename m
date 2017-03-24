Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9020D6B0343
	for <linux-mm@kvack.org>; Fri, 24 Mar 2017 07:31:07 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id c23so21833504pfj.0
        for <linux-mm@kvack.org>; Fri, 24 Mar 2017 04:31:07 -0700 (PDT)
Received: from mailout2.samsung.com (mailout2.samsung.com. [203.254.224.25])
        by mx.google.com with ESMTPS id k21si2493576pgg.16.2017.03.24.04.31.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 24 Mar 2017 04:31:02 -0700 (PDT)
Received: from epcas2p3.samsung.com (unknown [182.195.41.55])
 by mailout2.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0ONB00R8QHBNQAF0@mailout2.samsung.com> for linux-mm@kvack.org;
 Fri, 24 Mar 2017 20:30:59 +0900 (KST)
From: Maninder Singh <maninder1.s@samsung.com>
Subject: [PATCH 1/1] module: check if memory leak by module.
Date: Fri, 24 Mar 2017 17:00:28 +0530
Message-id: <1490355028-13292-1-git-send-email-maninder1.s@samsung.com>
Content-type: text/plain; charset=utf-8
References: 
 <CGME20170324113058epcas5p48d9b7cf45d62d2cf7c2146ebc8719542@epcas5p4.samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jeyu@redhat.com, rusty@rustcorp.com.au, akpm@linux-foundation.org, chris@chris-wilson.co.uk, aryabinin@virtuozzo.com, joonas.lahtinen@linux.intel.com, mhocko@suse.com, keescook@chromium.org, pavel@ucw.cz, jinb.park7@gmail.com, anisse@astier.eu, rafael.j.wysocki@intel.com, zijun_hu@htc.com, mingo@kernel.org, mawilcox@microsoft.com, thgarnie@google.com, joelaf@google.com, kirill.shutemov@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: pankaj.m@samsung.com, ajeet.y@samsung.com, hakbong5.lee@samsung.com, a.sahrawat@samsung.com, lalit.mohan@samsung.com, cpgs@samsung.com, Maninder Singh <maninder1.s@samsung.com>, Vaneet Narang <v.narang@samsung.com>

This patch adds new config VMALLOC_MEMORY_LEAK to check if any
module which is going to be unloaded is doing vmalloc memory leak.

Logs:-
[  129.336368] Module vmalloc is getting unloaded before doing vfree
[  129.336371] Memory still allocated: addr:0xffffc90001461000 - 0xffffc900014c7000, pages 101
[  129.336376] Allocating function kernel_init+0x1c/0x20 [vmalloc]

Signed-off-by: Maninder Singh <maninder1.s@samsung.com>
Signed-off-by: Vaneet Narang <v.narang@samsung.com>
---
 include/linux/vmalloc.h |  2 ++
 kernel/module.c         | 28 ++++++++++++++++++++++++++++
 mm/Kconfig.debug        |  7 +++++++
 mm/vmalloc.c            |  2 --
 4 files changed, 37 insertions(+), 2 deletions(-)

diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
index 3d9d786..abfc03c 100644
--- a/include/linux/vmalloc.h
+++ b/include/linux/vmalloc.h
@@ -29,6 +29,8 @@ struct notifier_block;		/* in notifier.h */
 #define IOREMAP_MAX_ORDER	(7 + PAGE_SHIFT)	/* 128 pages */
 #endif
 
+#define VM_VM_AREA  0x04
+
 struct vm_struct {
 	struct vm_struct	*next;
 	void			*addr;
diff --git a/kernel/module.c b/kernel/module.c
index 529efae..b492f34 100644
--- a/kernel/module.c
+++ b/kernel/module.c
@@ -2082,9 +2082,37 @@ void __weak module_arch_freeing_init(struct module *mod)
 {
 }
 
+#ifdef CONFIG_VMALLOC_MEMORY_LEAK
+static void check_memory_leak(struct module *mod)
+{
+	struct vmap_area *va;
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(va, &vmap_area_list, list) {
+		if (!(va->flags & VM_VM_AREA))
+			continue;
+		if ((mod->core_layout.base < va->vm->caller) &&
+			(mod->core_layout.base +  mod->core_layout.size) > va->vm->caller) {
+			pr_alert("Module %s is getting unloaded before doing vfree\n", mod->name);
+			pr_alert("Memory still allocated: addr:0x%lx - 0x%lx, pages %u\n",
+				va->va_start, va->va_end, va->vm->nr_pages);
+			pr_alert("Allocating function %pS\n", va->vm->caller);
+		}
+
+	}
+	rcu_read_unlock();
+}
+#else
+static inline void check_memory_leak(struct module *mod)
+{
+}
+#endif
+
 /* Free a module, remove from lists, etc. */
 static void free_module(struct module *mod)
 {
+	check_memory_leak(mod);
+
 	trace_module_free(mod);
 
 	mod_sysfs_teardown(mod);
diff --git a/mm/Kconfig.debug b/mm/Kconfig.debug
index 22f4cd9..0bead5d 100644
--- a/mm/Kconfig.debug
+++ b/mm/Kconfig.debug
@@ -92,3 +92,10 @@ config DEBUG_PAGE_REF
 	  careful when enabling this feature because it adds about 30 KB to the
 	  kernel code.  However the runtime performance overhead is virtually
 	  nil until the tracepoints are actually enabled.
+
+config VMALLOC_MEMORY_LEAK
+	bool "Enable to check memory leaks by modules"
+	default n
+	---help---
+	  This is a feature to check if any module has allocated memory using vmalloc
+	  but getting unloaded without doing vfree.
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 91f44e7..7fba87a 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -275,8 +275,6 @@ EXPORT_SYMBOL(vmalloc_to_pfn);
 
 /*** Global kva allocator ***/
 
-#define VM_VM_AREA	0x04
-
 static DEFINE_SPINLOCK(vmap_area_lock);
 /* Export for kexec only */
 LIST_HEAD(vmap_area_list);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
