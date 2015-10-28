Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 8B83682F64
	for <linux-mm@kvack.org>; Wed, 28 Oct 2015 12:41:52 -0400 (EDT)
Received: by wicll6 with SMTP id ll6so205246270wic.0
        for <linux-mm@kvack.org>; Wed, 28 Oct 2015 09:41:52 -0700 (PDT)
Received: from mail-wi0-x243.google.com (mail-wi0-x243.google.com. [2a00:1450:400c:c05::243])
        by mx.google.com with ESMTPS id hq1si37221649wib.20.2015.10.28.09.41.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Oct 2015 09:41:50 -0700 (PDT)
Received: by wicuv6 with SMTP id uv6so3246371wic.2
        for <linux-mm@kvack.org>; Wed, 28 Oct 2015 09:41:50 -0700 (PDT)
From: Alexander Potapenko <glider@google.com>
Subject: [PATCH 2/2] mm: kasan: unified support for SLUB and SLAB allocators
Date: Wed, 28 Oct 2015 17:41:44 +0100
Message-Id: <1446050504-40376-1-git-send-email-glider@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <adech.fo@gmail.com>, Christoph Lameter <cl@linux.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dmitriy Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

With this patch kasan can be compiled with both SLAB and SLUB allocators,
using minimal dependencies on allocator internal structures and minimum
allocator-dependent code.

Dependency from SLUB_DEBUG is also removed. The metadata storage is made
more efficient, so the redzones aren't as large for small objects. The
redzone size is calculated based on the object size.

This is the second part of the "mm: kasan: unified support for SLUB and
SLAB allocators" patch originally prepared by Dmitry Chernenkov.

Signed-off-by: Dmitry Chernenkov <dmitryc@google.com>
Signed-off-by: Alexander Potapenko <glider@google.com>
---
 Documentation/kasan.txt  | 134 +++++++++++++++++++----------------------------
 include/linux/kasan.h    |  18 +++++++
 include/linux/slab.h     |   6 +++
 include/linux/slab_def.h |   3 ++
 include/linux/slub_def.h |   7 ++-
 lib/Kconfig.kasan        |   1 -
 lib/test_kasan.c         |   2 +
 mm/Makefile              |   1 +
 mm/kasan/kasan.c         |  82 +++++++++++++++++++++++++++++
 mm/kasan/kasan.h         |  33 ++++++++++++
 mm/kasan/report.c        |  72 ++++++++++++++++++++-----
 mm/slab.c                |  44 ++++++++++++++--
 mm/slab.h                |   4 ++
 mm/slab_common.c         |   2 +-
 mm/slub.c                |  22 ++++++--
 15 files changed, 326 insertions(+), 105 deletions(-)

diff --git a/Documentation/kasan.txt b/Documentation/kasan.txt
index 0d32355..e921bb0 100644
--- a/Documentation/kasan.txt
+++ b/Documentation/kasan.txt
@@ -28,9 +28,7 @@ is compiler instrumentation types. The former produces smaller binary the
 latter is 1.1 - 2 times faster. Inline instrumentation requires a gcc version
 of 5.0 or later.
 
-Currently KASAN works only with the SLUB memory allocator.
-For better bug detection and nicer report, enable CONFIG_STACKTRACE and put
-at least 'slub_debug=U' in the boot cmdline.
+Currently KASAN works only with the SLUB and SLAB memory allocators.
 
 To disable instrumentation for specific files or directories, add a line
 similar to the following to the respective kernel Makefile:
@@ -45,82 +43,60 @@ similar to the following to the respective kernel Makefile:
 ==========
 
 A typical out of bounds access report looks like this:
-
-==================================================================
-BUG: AddressSanitizer: out of bounds access in kmalloc_oob_right+0x65/0x75 [test_kasan] at addr ffff8800693bc5d3
-Write of size 1 by task modprobe/1689
-=============================================================================
-BUG kmalloc-128 (Not tainted): kasan error
------------------------------------------------------------------------------
-
-Disabling lock debugging due to kernel taint
-INFO: Allocated in kmalloc_oob_right+0x3d/0x75 [test_kasan] age=0 cpu=0 pid=1689
- __slab_alloc+0x4b4/0x4f0
- kmem_cache_alloc_trace+0x10b/0x190
- kmalloc_oob_right+0x3d/0x75 [test_kasan]
- init_module+0x9/0x47 [test_kasan]
- do_one_initcall+0x99/0x200
- load_module+0x2cb3/0x3b20
- SyS_finit_module+0x76/0x80
- system_call_fastpath+0x12/0x17
-INFO: Slab 0xffffea0001a4ef00 objects=17 used=7 fp=0xffff8800693bd728 flags=0x100000000004080
-INFO: Object 0xffff8800693bc558 @offset=1368 fp=0xffff8800693bc720
-
-Bytes b4 ffff8800693bc548: 00 00 00 00 00 00 00 00 5a 5a 5a 5a 5a 5a 5a 5a  ........ZZZZZZZZ
-Object ffff8800693bc558: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
-Object ffff8800693bc568: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
-Object ffff8800693bc578: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
-Object ffff8800693bc588: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
-Object ffff8800693bc598: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
-Object ffff8800693bc5a8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
-Object ffff8800693bc5b8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
-Object ffff8800693bc5c8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5  kkkkkkkkkkkkkkk.
-Redzone ffff8800693bc5d8: cc cc cc cc cc cc cc cc                          ........
-Padding ffff8800693bc718: 5a 5a 5a 5a 5a 5a 5a 5a                          ZZZZZZZZ
-CPU: 0 PID: 1689 Comm: modprobe Tainted: G    B          3.18.0-rc1-mm1+ #98
-Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.7.5-0-ge51488c-20140602_164612-nilsson.home.kraxel.org 04/01/2014
- ffff8800693bc000 0000000000000000 ffff8800693bc558 ffff88006923bb78
- ffffffff81cc68ae 00000000000000f3 ffff88006d407600 ffff88006923bba8
- ffffffff811fd848 ffff88006d407600 ffffea0001a4ef00 ffff8800693bc558
-Call Trace:
- [<ffffffff81cc68ae>] dump_stack+0x46/0x58
- [<ffffffff811fd848>] print_trailer+0xf8/0x160
- [<ffffffffa00026a7>] ? kmem_cache_oob+0xc3/0xc3 [test_kasan]
- [<ffffffff811ff0f5>] object_err+0x35/0x40
- [<ffffffffa0002065>] ? kmalloc_oob_right+0x65/0x75 [test_kasan]
- [<ffffffff8120b9fa>] kasan_report_error+0x38a/0x3f0
- [<ffffffff8120a79f>] ? kasan_poison_shadow+0x2f/0x40
- [<ffffffff8120b344>] ? kasan_unpoison_shadow+0x14/0x40
- [<ffffffff8120a79f>] ? kasan_poison_shadow+0x2f/0x40
- [<ffffffffa00026a7>] ? kmem_cache_oob+0xc3/0xc3 [test_kasan]
- [<ffffffff8120a995>] __asan_store1+0x75/0xb0
- [<ffffffffa0002601>] ? kmem_cache_oob+0x1d/0xc3 [test_kasan]
- [<ffffffffa0002065>] ? kmalloc_oob_right+0x65/0x75 [test_kasan]
- [<ffffffffa0002065>] kmalloc_oob_right+0x65/0x75 [test_kasan]
- [<ffffffffa00026b0>] init_module+0x9/0x47 [test_kasan]
- [<ffffffff810002d9>] do_one_initcall+0x99/0x200
- [<ffffffff811e4e5c>] ? __vunmap+0xec/0x160
- [<ffffffff81114f63>] load_module+0x2cb3/0x3b20
- [<ffffffff8110fd70>] ? m_show+0x240/0x240
- [<ffffffff81115f06>] SyS_finit_module+0x76/0x80
- [<ffffffff81cd3129>] system_call_fastpath+0x12/0x17
-Memory state around the buggy address:
- ffff8800693bc300: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
- ffff8800693bc380: fc fc 00 00 00 00 00 00 00 00 00 00 00 00 00 fc
- ffff8800693bc400: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
- ffff8800693bc480: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
- ffff8800693bc500: fc fc fc fc fc fc fc fc fc fc fc 00 00 00 00 00
->ffff8800693bc580: 00 00 00 00 00 00 00 00 00 00 03 fc fc fc fc fc
-                                                 ^
- ffff8800693bc600: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
- ffff8800693bc680: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
- ffff8800693bc700: fc fc fc fc fb fb fb fb fb fb fb fb fb fb fb fb
- ffff8800693bc780: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
- ffff8800693bc800: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
-==================================================================
-
-First sections describe slub object where bad access happened.
-See 'SLUB Debug output' section in Documentation/vm/slub.txt for details.
+ ==================================================================
+ BUG: KASan: out of bounds access in kmalloc_oob_right+0xce/0x117 [test_kasan] at addr ffff8800b91250fb
+ Read of size 1 by task insmod/2754
+ CPU: 0 PID: 2754 Comm: insmod Not tainted 4.0.0-rc4+ #1
+ Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
+  ffff8800b9125080 ffff8800b9aff958 ffffffff82c97b9e 0000000000000022
+  ffff8800b9affa00 ffff8800b9aff9e8 ffffffff813fc8c9 ffff8800b9aff988
+  ffffffff813fb3ff ffff8800b9aff998 0000000000000296 000000000000007b
+ Call Trace:
+  [<ffffffff82c97b9e>] dump_stack+0x45/0x57
+  [<ffffffff813fc8c9>] kasan_report_error+0x129/0x420
+  [<ffffffff813fb3ff>] ? kasan_poison_shadow+0x2f/0x40
+  [<ffffffff813fb3ff>] ? kasan_poison_shadow+0x2f/0x40
+  [<ffffffff813fbeff>] ? kasan_kmalloc+0x5f/0x100
+  [<ffffffffa0008f3d>] ? kmalloc_node_oob_right+0x11f/0x11f [test_kasan]
+  [<ffffffff813fcc05>] __asan_report_load1_noabort+0x45/0x50
+  [<ffffffffa0008f00>] ? kmalloc_node_oob_right+0xe2/0x11f [test_kasan]
+  [<ffffffffa00087bf>] ? kmalloc_oob_right+0xce/0x117 [test_kasan]
+  [<ffffffffa00087bf>] kmalloc_oob_right+0xce/0x117 [test_kasan]
+  [<ffffffffa00086f1>] ? kmalloc_oob_left+0xe9/0xe9 [test_kasan]
+  [<ffffffff819cc140>] ? kvasprintf+0xf0/0xf0
+  [<ffffffffa00086f1>] ? kmalloc_oob_left+0xe9/0xe9 [test_kasan]
+  [<ffffffffa000001e>] run_test+0x1e/0x40 [test_kasan]
+  [<ffffffffa0008f54>] init_module+0x17/0x128 [test_kasan]
+  [<ffffffff81000351>] do_one_initcall+0x111/0x2b0
+  [<ffffffff81000240>] ? try_to_run_init_process+0x40/0x40
+  [<ffffffff813fb3ff>] ? kasan_poison_shadow+0x2f/0x40
+  [<ffffffff813fbeff>] ? kasan_kmalloc+0x5f/0x100
+  [<ffffffff813fb3ff>] ? kasan_poison_shadow+0x2f/0x40
+  [<ffffffff813fbde4>] ? kasan_unpoison_shadow+0x14/0x40
+  [<ffffffff813fb3ff>] ? kasan_poison_shadow+0x2f/0x40
+  [<ffffffff813fbe80>] ? __asan_register_globals+0x70/0x90
+  [<ffffffff82c934a4>] do_init_module+0x1d2/0x531
+  [<ffffffff8122d5bf>] load_module+0x55cf/0x73e0
+  [<ffffffff81224020>] ? symbol_put_addr+0x50/0x50
+  [<ffffffff81227ff0>] ? module_frob_arch_sections+0x20/0x20
+  [<ffffffff810c213a>] ? trace_do_page_fault+0x6a/0x1d0
+  [<ffffffff810b5454>] ? do_async_page_fault+0x14/0x80
+  [<ffffffff82cb0c88>] ? async_page_fault+0x28/0x30
+  [<ffffffff8122f4da>] SyS_init_module+0x10a/0x140
+  [<ffffffff8122f3d0>] ? load_module+0x73e0/0x73e0
+  [<ffffffff82caef89>] system_call_fastpath+0x12/0x17
+ Object at ffff8800b9125080, in cache kmalloc-128
+ Object allocated with size 123 bytes.
+ Allocation:
+ PID = 2754, CPU = 0, timestamp = 4294707705
+ Memory state around the buggy address:
+  ffff8800b9124f80: fc fc fc fc fc fc fc fc 00 00 00 00 00 00 00 00
+  ffff8800b9125000: 00 00 00 00 00 fc fc fc fc fc fc fc fc fc fc fc
+ >ffff8800b9125080: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 03
+                                                                 ^
+  ffff8800b9125100: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
+  ffff8800b9125180: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
+ ==================================================================
 
 In the last section the report shows memory state around the accessed address.
 Reading this part requires some more understanding of how KASAN works.
diff --git a/include/linux/kasan.h b/include/linux/kasan.h
index e1ce960..e37d934 100644
--- a/include/linux/kasan.h
+++ b/include/linux/kasan.h
@@ -7,6 +7,12 @@ struct kmem_cache;
 struct page;
 struct vm_struct;
 
+#ifdef SLAB
+#define cache_size_t size_t
+#else
+#define cache_size_t unsigned long
+#endif
+
 #ifdef CONFIG_KASAN
 
 #define KASAN_SHADOW_SCALE_SHIFT 3
@@ -46,6 +52,9 @@ void kasan_unpoison_shadow(const void *address, size_t size);
 void kasan_alloc_pages(struct page *page, unsigned int order);
 void kasan_free_pages(struct page *page, unsigned int order);
 
+void kasan_cache_create(struct kmem_cache *cache, cache_size_t *size,
+			unsigned long *flags);
+
 void kasan_poison_slab(struct page *page);
 void kasan_unpoison_object_data(struct kmem_cache *cache, void *object);
 void kasan_poison_object_data(struct kmem_cache *cache, void *object);
@@ -60,6 +69,11 @@ void kasan_krealloc(const void *object, size_t new_size, gfp_t flags);
 void kasan_slab_alloc(struct kmem_cache *s, void *object, gfp_t flags);
 void kasan_slab_free(struct kmem_cache *s, void *object);
 
+struct kasan_cache {
+	int alloc_meta_offset;
+	int free_meta_offset;
+};
+
 int kasan_module_alloc(void *addr, size_t size);
 void kasan_free_shadow(const struct vm_struct *vm);
 
@@ -73,6 +87,10 @@ static inline void kasan_disable_current(void) {}
 static inline void kasan_alloc_pages(struct page *page, unsigned int order) {}
 static inline void kasan_free_pages(struct page *page, unsigned int order) {}
 
+static inline void kasan_cache_create(struct kmem_cache *cache,
+				      cache_size_t *size,
+				      unsigned long *flags) {}
+
 static inline void kasan_poison_slab(struct page *page) {}
 static inline void kasan_unpoison_object_data(struct kmem_cache *cache,
 					void *object) {}
diff --git a/include/linux/slab.h b/include/linux/slab.h
index 7e37d44..b4de362 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -87,6 +87,12 @@
 # define SLAB_FAILSLAB		0x00000000UL
 #endif
 
+#ifdef CONFIG_KASAN
+#define SLAB_KASAN		0x08000000UL
+#else
+#define SLAB_KASAN		0x00000000UL
+#endif
+
 /* The following flags affect the page allocator grouping pages by mobility */
 #define SLAB_RECLAIM_ACCOUNT	0x00020000UL		/* Objects are reclaimable */
 #define SLAB_TEMPORARY		SLAB_RECLAIM_ACCOUNT	/* Objects are short-lived */
diff --git a/include/linux/slab_def.h b/include/linux/slab_def.h
index 33d0490..83f80aa 100644
--- a/include/linux/slab_def.h
+++ b/include/linux/slab_def.h
@@ -72,6 +72,9 @@ struct kmem_cache {
 #ifdef CONFIG_MEMCG_KMEM
 	struct memcg_cache_params memcg_params;
 #endif
+#ifdef CONFIG_KASAN
+	struct kasan_cache kasan_info;
+#endif
 
 	struct kmem_cache_node *node[MAX_NUMNODES];
 };
diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index 3388511..66f5244 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -91,13 +91,15 @@ struct kmem_cache {
 	struct kset *memcg_kset;
 #endif
 #endif
-
 #ifdef CONFIG_NUMA
 	/*
 	 * Defragmentation by allocating from a remote node.
 	 */
 	int remote_node_defrag_ratio;
 #endif
+#ifdef CONFIG_KASAN
+	struct kasan_cache kasan_info;
+#endif
 	struct kmem_cache_node *node[MAX_NUMNODES];
 };
 
@@ -126,7 +128,4 @@ static inline void *virt_to_obj(struct kmem_cache *s,
 	return (void *)x - ((x - slab_page) % s->size);
 }
 
-void object_err(struct kmem_cache *s, struct page *page,
-		u8 *object, char *reason);
-
 #endif /* _LINUX_SLUB_DEF_H */
diff --git a/lib/Kconfig.kasan b/lib/Kconfig.kasan
index 39f24d6..a904a4e 100644
--- a/lib/Kconfig.kasan
+++ b/lib/Kconfig.kasan
@@ -5,7 +5,6 @@ if HAVE_ARCH_KASAN
 
 config KASAN
 	bool "KASan: runtime memory debugger"
-	depends on SLUB_DEBUG
 	select CONSTRUCTORS
 	help
 	  Enables kernel address sanitizer - runtime memory debugger,
diff --git a/lib/test_kasan.c b/lib/test_kasan.c
index c1efb1b..0ae338c 100644
--- a/lib/test_kasan.c
+++ b/lib/test_kasan.c
@@ -259,7 +259,9 @@ static int __init kmalloc_tests_init(void)
 	kmalloc_oob_right();
 	kmalloc_oob_left();
 	kmalloc_node_oob_right();
+#ifdef CONFIG_SLUB
 	kmalloc_large_oob_right();
+#endif
 	kmalloc_oob_krealloc_more();
 	kmalloc_oob_krealloc_less();
 	kmalloc_oob_16();
diff --git a/mm/Makefile b/mm/Makefile
index 2ed4319..2b66fc6 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -4,6 +4,7 @@
 
 KASAN_SANITIZE_slab_common.o := n
 KASAN_SANITIZE_slub.o := n
+KASAN_SANITIZE_slab.o := n
 
 mmu-y			:= nommu.o
 mmu-$(CONFIG_MMU)	:= gup.o highmem.o memory.o mincore.o \
diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index ba0734b..171e54a 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -299,6 +299,54 @@ void kasan_free_pages(struct page *page, unsigned int order)
 				KASAN_FREE_PAGE);
 }
 
+/* TODO: comment this redzone policy */
+static size_t optimal_redzone(size_t object_size)
+{
+	int rz =
+		object_size <= 64        - 16   ? 16 :
+		object_size <= 128       - 32   ? 32 :
+		object_size <= 512       - 64   ? 64 :
+		object_size <= 4096      - 128  ? 128 :
+		object_size <= (1 << 14) - 256  ? 256 :
+		object_size <= (1 << 15) - 512  ? 512 :
+		object_size <= (1 << 16) - 1024 ? 1024 : 2048;
+	return rz;
+}
+
+void kasan_cache_create(struct kmem_cache *cache, cache_size_t *size,
+			unsigned long *flags)
+{
+	int redzone_adjust;
+
+	if (*flags & (SLAB_POISON)) {
+		/* TODO: consider dropping SLAB_POISON flag instead */
+		pr_warn("SLAB_POISON is set up for cache %s, disabling KASan\n",
+			cache->name);
+		return;
+	}
+#ifdef CONFIG_SLAB
+	if (cache->object_size >= 4 << 20) /* TODO: use MAX_ORDER */
+		return;
+#endif
+	*flags |= SLAB_KASAN;
+
+	cache->kasan_info.alloc_meta_offset = *size;
+	*size += sizeof(struct kasan_alloc_meta);
+
+	if (cache->flags & SLAB_DESTROY_BY_RCU || cache->ctor ||
+	    cache->object_size <
+	    sizeof(struct kasan_free_meta) + sizeof(void *)) {
+		cache->kasan_info.free_meta_offset = *size;
+		*size += sizeof(struct kasan_free_meta);
+	} else
+		cache->kasan_info.free_meta_offset = 0;
+
+	redzone_adjust = optimal_redzone(cache->object_size) -
+		(*size - cache->object_size);
+	if (redzone_adjust > 0)
+		*size += redzone_adjust;
+}
+
 void kasan_poison_slab(struct page *page)
 {
 	kasan_poison_shadow(page_address(page),
@@ -316,6 +364,31 @@ void kasan_poison_object_data(struct kmem_cache *cache, void *object)
 	kasan_poison_shadow(object,
 			round_up(cache->object_size, KASAN_SHADOW_SCALE_SIZE),
 			KASAN_KMALLOC_REDZONE);
+	if (cache->flags & SLAB_KASAN) {
+		struct kasan_alloc_meta *alloc_info =
+			get_alloc_info(cache, object);
+
+		alloc_info->state = KASAN_STATE_INIT;
+	}
+}
+
+static inline void set_track(struct kasan_track *track, gfp_t flags)
+{
+	track->cpu = smp_processor_id();
+	track->pid = current->pid;
+	track->when = jiffies;
+}
+
+struct kasan_alloc_meta *get_alloc_info(struct kmem_cache *cache,
+					const void *object)
+{
+	return (void *)object + cache->kasan_info.alloc_meta_offset;
+}
+
+struct kasan_free_meta *get_free_info(struct kmem_cache *cache,
+				      const void *object)
+{
+	return (void *)object + cache->kasan_info.free_meta_offset;
 }
 
 void kasan_slab_alloc(struct kmem_cache *cache, void *object, gfp_t flags)
@@ -352,6 +425,15 @@ void kasan_kmalloc(struct kmem_cache *cache, const void *object, size_t size,
 	kasan_unpoison_shadow(object, size);
 	kasan_poison_shadow((void *)redzone_start, redzone_end - redzone_start,
 		KASAN_KMALLOC_REDZONE);
+
+	if (cache->flags & SLAB_KASAN) {
+		struct kasan_alloc_meta *alloc_info =
+			get_alloc_info(cache, object);
+
+		alloc_info->state = KASAN_STATE_ALLOC;
+		alloc_info->alloc_size = size;
+		set_track(&alloc_info->track, flags);
+	}
 }
 EXPORT_SYMBOL(kasan_kmalloc);
 
diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
index c242adf..6530880 100644
--- a/mm/kasan/kasan.h
+++ b/mm/kasan/kasan.h
@@ -54,6 +54,39 @@ struct kasan_global {
 #endif
 };
 
+/**
+ * Structures to keep alloc and free tracks *
+ */
+
+enum kasan_state {
+	KASAN_STATE_INIT,
+	KASAN_STATE_ALLOC,
+	KASAN_STATE_FREE
+};
+
+/* TODO: rethink the structs and field sizes */
+struct kasan_track {
+	u64 cpu : 6;			/* for NR_CPUS = 64 */
+	u64 pid : 16;			/* 65536 processes */
+	u64 when : 48;			/* ~9000 years */
+};
+
+struct kasan_alloc_meta {
+	enum kasan_state state : 2;
+	size_t alloc_size : 30;
+	struct kasan_track track;
+};
+
+struct kasan_free_meta {
+	void **freelist;
+	struct kasan_track track;
+};
+
+struct kasan_alloc_meta *get_alloc_info(struct kmem_cache *cache,
+				   const void *object);
+struct kasan_free_meta *get_free_info(struct kmem_cache *cache,
+				 const void *object);
+
 void kasan_report_error(struct kasan_access_info *info);
 void kasan_report_user_access(struct kasan_access_info *info);
 
diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index e07c94f..7dbe5be 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -97,6 +97,58 @@ static inline bool init_task_stack_addr(const void *addr)
 			sizeof(init_thread_union.stack));
 }
 
+static void print_track(struct kasan_track *track)
+{
+	pr_err("PID = %lu, CPU = %lu, timestamp = %lu\n", track->pid,
+	       track->cpu, track->when);
+}
+
+static void print_object(struct kmem_cache *cache, void *object)
+{
+	struct kasan_alloc_meta *alloc_info = get_alloc_info(cache, object);
+	struct kasan_free_meta *free_info;
+
+	pr_err("Object at %p, in cache %s\n", object, cache->name);
+	if (!(cache->flags & SLAB_KASAN))
+		return;
+	switch (alloc_info->state) {
+	case KASAN_STATE_INIT:
+		pr_err("Object not allocated yet\n");
+		break;
+	case KASAN_STATE_ALLOC:
+		pr_err("Object allocated with size %lu bytes.\n",
+		       alloc_info->alloc_size);
+		pr_err("Allocation:\n");
+		print_track(&alloc_info->track);
+		break;
+	case KASAN_STATE_FREE:
+		pr_err("Object freed, allocated with size %lu bytes\n",
+		       alloc_info->alloc_size);
+		free_info = get_free_info(cache, object);
+		pr_err("Allocation:\n");
+		print_track(&alloc_info->track);
+		pr_err("Deallocation:\n");
+		print_track(&free_info->track);
+		break;
+	}
+}
+
+static inline void *nearest_obj(struct kmem_cache *cache, struct page *page,
+				void *x) {
+#if defined(CONFIG_SLUB)
+	void *object = x - (x - page_address(page)) % cache->size;
+	void *last_object = page_address(page) +
+		(page->objects - 1) * cache->size;
+#elif defined(CONFIG_SLAB)
+	void *object = x - (x - page->s_mem) % cache->size;
+	void *last_object = page->s_mem + (cache->num - 1) * cache->size;
+#endif
+	if (unlikely(object > last_object))
+		return last_object;
+	else
+		return object;
+}
+
 static void print_address_description(struct kasan_access_info *info)
 {
 	const void *addr = info->access_addr;
@@ -108,17 +160,10 @@ static void print_address_description(struct kasan_access_info *info)
 		if (PageSlab(page)) {
 			void *object;
 			struct kmem_cache *cache = page->slab_cache;
-			void *last_object;
-
-			object = virt_to_obj(cache, page_address(page), addr);
-			last_object = page_address(page) +
-				page->objects * cache->size;
 
-			if (unlikely(object > last_object))
-				object = last_object; /* we hit into padding */
-
-			object_err(cache, page, object,
-				"kasan: bad access detected");
+			object = nearest_obj(cache, page,
+					(void *)info->access_addr);
+			print_object(cache, object);
 			return;
 		}
 		dump_page(page, "kasan: bad access detected");
@@ -128,8 +173,6 @@ static void print_address_description(struct kasan_access_info *info)
 		if (!init_task_stack_addr(addr))
 			pr_err("Address belongs to variable %pS\n", addr);
 	}
-
-	dump_stack();
 }
 
 static bool row_is_guilty(const void *row, const void *guilty)
@@ -186,21 +229,25 @@ void kasan_report_error(struct kasan_access_info *info)
 {
 	unsigned long flags;
 
+	kasan_disable_current();
 	spin_lock_irqsave(&report_lock, flags);
 	pr_err("================================="
 		"=================================\n");
 	print_error_description(info);
+	dump_stack();
 	print_address_description(info);
 	print_shadow_for_address(info->first_bad_addr);
 	pr_err("================================="
 		"=================================\n");
 	spin_unlock_irqrestore(&report_lock, flags);
+	kasan_enable_current();
 }
 
 void kasan_report_user_access(struct kasan_access_info *info)
 {
 	unsigned long flags;
 
+	kasan_disable_current();
 	spin_lock_irqsave(&report_lock, flags);
 	pr_err("================================="
 		"=================================\n");
@@ -213,6 +260,7 @@ void kasan_report_user_access(struct kasan_access_info *info)
 	pr_err("================================="
 		"=================================\n");
 	spin_unlock_irqrestore(&report_lock, flags);
+	kasan_enable_current();
 }
 
 void kasan_report(unsigned long addr, size_t size,
diff --git a/mm/slab.c b/mm/slab.c
index 4fcc5dd..b63c1e1 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2206,6 +2206,7 @@ __kmem_cache_create (struct kmem_cache *cachep, unsigned long flags)
 #endif
 #endif
 
+	kasan_cache_create(cachep, &size, &flags);
 	/*
 	 * Determine if the slab management is 'on' or 'off' slab.
 	 * (bootstrapping cannot cope with offslab caches so don't do
@@ -2513,8 +2514,12 @@ static void cache_init_objs(struct kmem_cache *cachep,
 		 * cache which they are a constructor for.  Otherwise, deadlock.
 		 * They must also be threaded.
 		 */
-		if (cachep->ctor && !(cachep->flags & SLAB_POISON))
+		if (cachep->ctor && !(cachep->flags & SLAB_POISON)) {
+			kasan_unpoison_object_data(cachep,
+						   objp + obj_offset(cachep));
 			cachep->ctor(objp + obj_offset(cachep));
+		}
+		kasan_poison_object_data(cachep, objb + obj_offset(cachep));
 
 		if (cachep->flags & SLAB_RED_ZONE) {
 			if (*dbg_redzone2(cachep, objp) != RED_INACTIVE)
@@ -2529,8 +2534,11 @@ static void cache_init_objs(struct kmem_cache *cachep,
 			kernel_map_pages(virt_to_page(objp),
 					 cachep->size / PAGE_SIZE, 0);
 #else
-		if (cachep->ctor)
+		if (cachep->ctor) {
+			kasan_unpoison_object_data(cachep, objp);
 			cachep->ctor(objp);
+		}
+		kasan_poison_object_data(cachep, objp);
 #endif
 		set_obj_status(page, i, OBJECT_FREE);
 		set_free_obj(page, i, i);
@@ -2659,7 +2667,7 @@ static int cache_grow(struct kmem_cache *cachep,
 		goto opps1;
 
 	slab_map_pages(cachep, page, freelist);
-
+	kasan_poison_slab(page);
 	cache_init_objs(cachep, page);
 
 	if (local_flags & __GFP_WAIT)
@@ -3200,6 +3208,7 @@ slab_alloc_node(struct kmem_cache *cachep, gfp_t flags, int nodeid,
 
 	if (likely(ptr)) {
 		kmemcheck_slab_alloc(cachep, flags, ptr, cachep->object_size);
+		kasan_slab_alloc(cachep, ptr, flags);
 		if (unlikely(flags & __GFP_ZERO))
 			memset(ptr, 0, cachep->object_size);
 	}
@@ -3266,6 +3275,7 @@ slab_alloc(struct kmem_cache *cachep, gfp_t flags, unsigned long caller)
 
 	if (likely(objp)) {
 		kmemcheck_slab_alloc(cachep, flags, objp, cachep->object_size);
+		kasan_slab_alloc(cachep, objp, flags);
 		if (unlikely(flags & __GFP_ZERO))
 			memset(objp, 0, cachep->object_size);
 	}
@@ -3376,6 +3386,15 @@ free_done:
 static inline void __cache_free(struct kmem_cache *cachep, void *objp,
 				unsigned long caller)
 {
+#ifdef CONFIG_KASAN
+	kasan_slab_free(cachep, objp);
+	nokasan_free(cachep, objp, caller);
+}
+
+void nokasan_free(struct kmem_cache *cachep, void *objp,
+		  unsigned long caller)
+{
+#endif
 	struct array_cache *ac = cpu_cache_get(cachep);
 
 	check_irq_off();
@@ -3446,6 +3465,8 @@ kmem_cache_alloc_trace(struct kmem_cache *cachep, gfp_t flags, size_t size)
 
 	trace_kmalloc(_RET_IP_, ret,
 		      size, cachep->size, flags);
+
+	kasan_kmalloc(cachep, ret, size, flags);
 	return ret;
 }
 EXPORT_SYMBOL(kmem_cache_alloc_trace);
@@ -3497,11 +3518,15 @@ static __always_inline void *
 __do_kmalloc_node(size_t size, gfp_t flags, int node, unsigned long caller)
 {
 	struct kmem_cache *cachep;
+	void *ret;
 
 	cachep = kmalloc_slab(size, flags);
 	if (unlikely(ZERO_OR_NULL_PTR(cachep)))
 		return cachep;
-	return kmem_cache_alloc_node_trace(cachep, flags, node, size);
+	ret = kmem_cache_alloc_node_trace(cachep, flags, node, size);
+	kasan_kmalloc(cachep, ret, size, flags);
+
+	return ret;
 }
 
 void *__kmalloc_node(size_t size, gfp_t flags, int node)
@@ -3535,6 +3560,7 @@ static __always_inline void *__do_kmalloc(size_t size, gfp_t flags,
 		return cachep;
 	ret = slab_alloc(cachep, flags, caller);
 
+	kasan_kmalloc(cachep, ret, size, flags);
 	trace_kmalloc(caller, ret,
 		      size, cachep->size, flags);
 
@@ -4252,10 +4278,18 @@ module_init(slab_proc_init);
  */
 size_t ksize(const void *objp)
 {
+	size_t size;
+
 	BUG_ON(!objp);
 	if (unlikely(objp == ZERO_SIZE_PTR))
 		return 0;
 
-	return virt_to_cache(objp)->object_size;
+	size = virt_to_cache(objp)->object_size;
+	/* We assume that ksize callers could use whole allocated area,
+	 * so we need unpoison this area.
+	 */
+	kasan_krealloc(objp, size, GFP_NOWAIT);
+
+	return size;
 }
 EXPORT_SYMBOL(ksize);
diff --git a/mm/slab.h b/mm/slab.h
index a3a967d..0fea223 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -387,4 +387,8 @@ void *slab_next(struct seq_file *m, void *p, loff_t *pos);
 void slab_stop(struct seq_file *m, void *p);
 int memcg_slab_show(struct seq_file *m, void *p);
 
+#ifdef CONFIG_KASAN
+void nokasan_free(struct kmem_cache *cache, void *x, unsigned long addr);
+#endif
+
 #endif /* MM_SLAB_H */
diff --git a/mm/slab_common.c b/mm/slab_common.c
index a07bfe0..a86fcbb 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -35,7 +35,7 @@ struct kmem_cache *kmem_cache;
  */
 #define SLAB_NEVER_MERGE (SLAB_RED_ZONE | SLAB_POISON | SLAB_STORE_USER | \
 		SLAB_TRACE | SLAB_DESTROY_BY_RCU | SLAB_NOLEAKTRACE | \
-		SLAB_FAILSLAB)
+		SLAB_FAILSLAB | SLAB_KASAN)
 
 #define SLAB_MERGE_SAME (SLAB_RECLAIM_ACCOUNT | SLAB_CACHE_DMA | SLAB_NOTRACK)
 
diff --git a/mm/slub.c b/mm/slub.c
index 4e20d66..9b7315a 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -34,6 +34,7 @@
 #include <linux/stacktrace.h>
 #include <linux/prefetch.h>
 #include <linux/memcontrol.h>
+#include <linux/kasan.h>
 
 #include <trace/events/kmem.h>
 
@@ -286,6 +287,9 @@ static inline int slab_index(void *p, struct kmem_cache *s, void *addr)
 
 static inline size_t slab_ksize(const struct kmem_cache *s)
 {
+#ifdef CONFIG_KASAN
+	return s->object_size;
+#else
 #ifdef CONFIG_SLUB_DEBUG
 	/*
 	 * Debugging requires use of the padding between object
@@ -306,6 +310,7 @@ static inline size_t slab_ksize(const struct kmem_cache *s)
 	 * Else we can use all the padding etc for the allocation
 	 */
 	return s->size;
+#endif
 }
 
 static inline int order_objects(int order, unsigned long size, int reserved)
@@ -650,7 +655,7 @@ static void print_trailer(struct kmem_cache *s, struct page *page, u8 *p)
 	dump_stack();
 }
 
-void object_err(struct kmem_cache *s, struct page *page,
+static void object_err(struct kmem_cache *s, struct page *page,
 			u8 *object, char *reason)
 {
 	slab_bug(s, "%s", reason);
@@ -1303,7 +1308,6 @@ static inline void slab_free_hook(struct kmem_cache *s, void *x)
 	if (!(s->flags & SLAB_DEBUG_OBJECTS))
 		debug_check_no_obj_freed(x, s->object_size);
 
-	kasan_slab_free(s, x);
 }
 
 static void setup_object(struct kmem_cache *s, struct page *page,
@@ -1313,8 +1317,8 @@ static void setup_object(struct kmem_cache *s, struct page *page,
 	if (unlikely(s->ctor)) {
 		kasan_unpoison_object_data(s, object);
 		s->ctor(object);
-		kasan_poison_object_data(s, object);
 	}
+	kasan_poison_object_data(s, object);
 }
 
 /*
@@ -1403,6 +1407,7 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
 	if (page_is_pfmemalloc(page))
 		SetPageSlabPfmemalloc(page);
 
+	kasan_poison_slab(page);
 	start = page_address(page);
 
 	if (unlikely(s->flags & SLAB_POISON))
@@ -2698,6 +2703,15 @@ slab_empty:
 static __always_inline void slab_free(struct kmem_cache *s,
 			struct page *page, void *x, unsigned long addr)
 {
+#ifdef CONFIG_KASAN
+	kasan_slab_free(s, x);
+	nokasan_free(s, x, addr);
+}
+
+void nokasan_free(struct kmem_cache *s, void *x, unsigned long addr)
+{
+	struct page *page = virt_to_head_page(x);
+#endif
 	void **object = (void *)x;
 	struct kmem_cache_cpu *c;
 	unsigned long tid;
@@ -3185,6 +3199,8 @@ static int calculate_sizes(struct kmem_cache *s, int forced_order)
 		size += sizeof(void *);
 #endif
 
+	kasan_cache_create(s, &size, &s->flags);
+
 	/*
 	 * SLUB stores one object immediately after another beginning from
 	 * offset 0. In order to align the objects we have to simply size
-- 
2.6.0.rc2.230.g3dd15c0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
