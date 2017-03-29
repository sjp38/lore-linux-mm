Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 40DCE6B0390
	for <linux-mm@kvack.org>; Wed, 29 Mar 2017 02:03:20 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id k62so2332416pfc.16
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 23:03:20 -0700 (PDT)
Received: from epoutp01.samsung.com (mailout1.samsung.com. [203.254.224.24])
        by mx.google.com with ESMTPS id 1si6346158pgt.210.2017.03.28.23.03.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Mar 2017 23:03:19 -0700 (PDT)
Received: from epcas2p2.samsung.com (unknown [182.195.41.54])
	by epoutp01.samsung.com (KnoxPortal) with ESMTP id 20170329060316epoutp01ddecd7b371fac8df3e22471adf2c212e~wRQxiS1H-1600516005epoutp01K
	for <linux-mm@kvack.org>; Wed, 29 Mar 2017 06:03:16 +0000 (GMT)
From: Maninder Singh <maninder1.s@samsung.com>
Subject: [PATCH v2] module: check if memory leak by module.
Date: Wed, 29 Mar 2017 11:32:02 +0530
Message-Id: <1490767322-9914-1-git-send-email-maninder1.s@samsung.com>
Content-Type: text/plain; charset="utf-8"
References: <CGME20170329060315epcas5p1c6f7ce3aca1b2770c5e1d9aaeb1a27e1@epcas5p1.samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jeyu@redhat.com, rusty@rustcorp.com.au, akpm@linux-foundation.org, chris@chris-wilson.co.uk, aryabinin@virtuozzo.com, joonas.lahtinen@linux.intel.com, mhocko@suse.com, keescook@chromium.org, pavel@ucw.cz, jinb.park7@gmail.com, anisse@astier.eu, rafael.j.wysocki@intel.com, zijun_hu@htc.com, mingo@kernel.org, mawilcox@microsoft.com, thgarnie@google.com, joelaf@google.com, kirill.shutemov@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: pankaj.m@samsung.com, ajeet.y@samsung.com, hakbong5.lee@samsung.com, a.sahrawat@samsung.com, lalit.mohan@samsung.com, cpgs@samsung.com, Maninder Singh <maninder1.s@samsung.com>, Vaneet Narang <v.narang@samsung.com>

This patch checks if any module which is going to be unloaded
is doing vmalloc memory leak or not.

Logs:-
[  129.336368] Module [test_module] is getting unloaded before doing vfree
[  129.336371] Memory still allocated: addr:0xffffc90001461000 - 0xffffc900014c7000, pages 101
[  129.336376] Allocating function kernel_init+0x1c/0x20 [test_module]

Signed-off-by: Vaneet Narang <v.narang@samsung.com>
Signed-off-by: Maninder Singh <maninder1.s@samsung.com>
---
v1->v2: made code generic rather than dependent on config.
	changed pr_alert to pr_err.

 include/linux/vmalloc.h |  2 ++
 kernel/module.c         | 22 ++++++++++++++++++++++
 mm/vmalloc.c            |  2 --
 3 files changed, 24 insertions(+), 2 deletions(-)

diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
index 46991ad..5531af3 100644
--- a/include/linux/vmalloc.h
+++ b/include/linux/vmalloc.h
@@ -29,6 +29,8 @@
 #define IOREMAP_MAX_ORDER	(7 + PAGE_SHIFT)	/* 128 pages */
 #endif
 
+#define VM_VM_AREA  0x04
+
 struct vm_struct {
 	struct vm_struct	*next;
 	void			*addr;
diff --git a/kernel/module.c b/kernel/module.c
index f953df9..98a8018 100644
--- a/kernel/module.c
+++ b/kernel/module.c
@@ -2117,9 +2117,31 @@ void __weak module_arch_freeing_init(struct module *mod)
 {
 }
 
+static void check_memory_leak(struct module *mod)
+{
+	struct vmap_area *va;
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(va, &vmap_area_list, list) {
+		if (!(va->flags & VM_VM_AREA))
+			continue;
+		if ((mod->core_layout.base < va->vm->caller) &&
+			(mod->core_layout.base + mod->core_layout.size) > va->vm->caller) {
+			pr_err("Module [%s] is getting unloaded before doing vfree\n", mod->name);
+			pr_err("Memory still allocated: addr:0x%lx - 0x%lx, pages %u\n",
+				va->va_start, va->va_end, va->vm->nr_pages);
+			pr_err("Allocating function %pS\n", va->vm->caller);
+		}
+
+	}
+	rcu_read_unlock();
+}
+
 /* Free a module, remove from lists, etc. */
 static void free_module(struct module *mod)
 {
+	check_memory_leak(mod);
+
 	trace_module_free(mod);
 
 	mod_sysfs_teardown(mod);
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 68eb002..0166a0a 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -314,8 +314,6 @@ unsigned long vmalloc_to_pfn(const void *vmalloc_addr)
 
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
