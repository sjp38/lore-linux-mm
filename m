Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 6DD1B900015
	for <linux-mm@kvack.org>; Thu, 19 Feb 2015 08:21:35 -0500 (EST)
Received: by pdbfp1 with SMTP id fp1so8814371pdb.9
        for <linux-mm@kvack.org>; Thu, 19 Feb 2015 05:21:35 -0800 (PST)
Received: from mailout3.w1.samsung.com (mailout3.w1.samsung.com. [210.118.77.13])
        by mx.google.com with ESMTPS id qo8si1606872pdb.77.2015.02.19.05.21.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Thu, 19 Feb 2015 05:21:34 -0800 (PST)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NK0006JXTAM2I80@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 19 Feb 2015 13:25:34 +0000 (GMT)
Message-id: <54E5E355.9020404@samsung.com>
Date: Thu, 19 Feb 2015 16:21:25 +0300
From: Andrey Ryabinin <a.ryabinin@samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH] kasan, module,
 vmalloc: rework shadow allocation for modules
References: <1424281467-2593-1-git-send-email-a.ryabinin@samsung.com>
 <87pp96stmz.fsf@rustcorp.com.au>
In-reply-to: <87pp96stmz.fsf@rustcorp.com.au>
Content-type: text/plain; charset=utf-8
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rusty Russell <rusty@rustcorp.com.au>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>

On 02/19/2015 02:10 AM, Rusty Russell wrote:
> Andrey Ryabinin <a.ryabinin@samsung.com> writes:
>> Current approach in handling shadow memory for modules is broken.
>>
>> Shadow memory could be freed only after memory shadow corresponds
>> it is no longer used.
>> vfree() called from interrupt context could use memory its
>> freeing to store 'struct llist_node' in it:
>>
>> void vfree(const void *addr)
>> {
>> ...
>> 	if (unlikely(in_interrupt())) {
>> 		struct vfree_deferred *p = this_cpu_ptr(&vfree_deferred);
>> 		if (llist_add((struct llist_node *)addr, &p->list))
>> 			schedule_work(&p->wq);
>>
>> Latter this list node used in free_work() which actually frees memory.
>> Currently module_memfree() called in interrupt context will free
>> shadow before freeing module's memory which could provoke kernel
>> crash.
>> So shadow memory should be freed after module's memory.
>> However, such deallocation order could race with kasan_module_alloc()
>> in module_alloc().
>>
>> To fix this we could move kasan hooks into vmalloc code. This allows
>> us to allocate/free shadow memory in appropriate time and order.
>>
>> This hooks also might be helpful in future if we decide to track
>> other vmalloc'ed memory.
> 
> This is not portable.  Other archs don't use vmalloc, or don't use
> (or define) MODULES_VADDR.  If you really want to hook here, you'd
> need a new flag (or maybe use PAGE_KERNEL_EXEC after an audit).
> 

Well, instead of explicit (addr >= MODULES_VADDR && addr < MODULES_END)
I could hide this into arch-specific function: 'kasan_need_to_allocate_shadow(const void *addr)'
or make make all those functions weak and allow arch code to redefine them.

> Thus I think modifying the callers is the better choice.
> 

I could suggest following (though, I still prefer 'modifying vmalloc' approach):
  * In do_init_module(), instead of call_rcu(&freeinit->rcu, do_free_init);
    use synchronyze_rcu() + module_memfree(). Of course this will be under CONFIG_KASAN.

    As you said there other module_memfree() users, so what if they will decide
    to free memory in atomic context?


   * And another option would be deferred kasan_module_free() in patch bellow.
     This is mostly copy-paste of deferred vfree(), thus I don't like it.

---
 arch/x86/mm/kasan_init_64.c |  1 +
 include/linux/kasan.h       |  1 +
 kernel/module.c             |  6 ++++--
 mm/kasan/kasan.c            | 42 +++++++++++++++++++++++++++++++++++++++++-
 4 files changed, 47 insertions(+), 3 deletions(-)

diff --git a/arch/x86/mm/kasan_init_64.c b/arch/x86/mm/kasan_init_64.c
index 4860906..66d2dba 100644
--- a/arch/x86/mm/kasan_init_64.c
+++ b/arch/x86/mm/kasan_init_64.c
@@ -173,6 +173,7 @@ void __init kasan_init(void)
 #ifdef CONFIG_KASAN_INLINE
 	register_die_notifier(&kasan_die_notifier);
 #endif
+	kasan_modules_init();

 	memcpy(early_level4_pgt, init_level4_pgt, sizeof(early_level4_pgt));
 	load_cr3(early_level4_pgt);
diff --git a/include/linux/kasan.h b/include/linux/kasan.h
index 72ba725..dba26f3 100644
--- a/include/linux/kasan.h
+++ b/include/linux/kasan.h
@@ -53,6 +53,7 @@ void kasan_slab_free(struct kmem_cache *s, void *object);

 int kasan_module_alloc(void *addr, size_t size);
 void kasan_module_free(void *addr);
+void kasan_modules_init(void);

 #else /* CONFIG_KASAN */

diff --git a/kernel/module.c b/kernel/module.c
index 8426ad4..e3d1a45 100644
--- a/kernel/module.c
+++ b/kernel/module.c
@@ -1813,8 +1813,10 @@ static void unset_module_init_ro_nx(struct module *mod) { }

 void __weak module_memfree(void *module_region)
 {
-	vfree(module_region);
-	kasan_module_free(module_region);
+	if (IS_ENABLED(CONFIG_KASAN))
+		kasan_module_free(module_region);
+	else
+		vfree(module_region);
 }

 void __weak module_arch_cleanup(struct module *mod)
diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index 78fee63..333241e 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -19,6 +19,7 @@
 #include <linux/export.h>
 #include <linux/init.h>
 #include <linux/kernel.h>
+#include <linux/llist.h>
 #include <linux/memblock.h>
 #include <linux/memory.h>
 #include <linux/mm.h>
@@ -29,6 +30,7 @@
 #include <linux/stacktrace.h>
 #include <linux/string.h>
 #include <linux/types.h>
+#include <linux/vmalloc.h>
 #include <linux/kasan.h>

 #include "kasan.h"
@@ -417,9 +419,47 @@ int kasan_module_alloc(void *addr, size_t size)
 	return ret ? 0 : -ENOMEM;
 }

+struct vfree_deferred {
+	struct llist_head list;
+	struct work_struct wq;
+};
+static DEFINE_PER_CPU(struct vfree_deferred, vfree_deferred);
+
+static void free_work(struct work_struct *w)
+{
+	struct vfree_deferred *p = container_of(w, struct vfree_deferred, wq);
+	struct llist_node *llnode = llist_del_all(&p->list);
+	while (llnode) {
+		void *p = llnode;
+		llnode = llist_next(llnode);
+		vfree(kasan_mem_to_shadow(p));
+		vfree(p);
+	}
+}
+
 void kasan_module_free(void *addr)
 {
-	vfree(kasan_mem_to_shadow(addr));
+	if (unlikely(in_interrupt())) {
+		struct vfree_deferred *p = this_cpu_ptr(&vfree_deferred);
+		if (llist_add((struct llist_node *)addr, &p->list))
+			schedule_work(&p->wq);
+	} else {
+		vfree(kasan_mem_to_shadow(addr));
+		vfree(addr);
+	}
+}
+
+void __init kasan_modules_init(void)
+{
+	int i;
+
+	for_each_possible_cpu(i) {
+		struct vfree_deferred *p;
+
+		p = &per_cpu(vfree_deferred, i);
+		init_llist_head(&p->list);
+		INIT_WORK(&p->wq, free_work);
+	}
 }

 static void register_global(struct kasan_global *global)
-- 
2.3.0


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
