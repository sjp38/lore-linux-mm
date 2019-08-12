Return-Path: <SRS0=TLXr=WI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6AD41C433FF
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 16:07:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0B803206A2
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 16:07:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0B803206A2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7BCF56B000A; Mon, 12 Aug 2019 12:07:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6F7246B000C; Mon, 12 Aug 2019 12:07:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 60E176B000E; Mon, 12 Aug 2019 12:07:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0075.hostedemail.com [216.40.44.75])
	by kanga.kvack.org (Postfix) with ESMTP id 245616B000A
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 12:07:21 -0400 (EDT)
Received: from smtpin09.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 9DDA9181AC9B4
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 16:07:20 +0000 (UTC)
X-FDA: 75814255440.09.stone24_5bd2d8acf90b
X-HE-Tag: stone24_5bd2d8acf90b
X-Filterd-Recvd-Size: 18423
Received: from foss.arm.com (foss.arm.com [217.140.110.172])
	by imf12.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 16:07:19 +0000 (UTC)
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id B4FE71993;
	Mon, 12 Aug 2019 09:06:50 -0700 (PDT)
Received: from arrakis.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.121.207.14])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id 97DD43F718;
	Mon, 12 Aug 2019 09:06:49 -0700 (PDT)
From: Catalin Marinas <catalin.marinas@arm.com>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@kernel.org>,
	Matthew Wilcox <willy@infradead.org>,
	Qian Cai <cai@lca.pw>
Subject: [PATCH v3 3/3] mm: kmemleak: Use the memory pool for early allocations
Date: Mon, 12 Aug 2019 17:06:42 +0100
Message-Id: <20190812160642.52134-4-catalin.marinas@arm.com>
X-Mailer: git-send-email 2.23.0.rc0
In-Reply-To: <20190812160642.52134-1-catalin.marinas@arm.com>
References: <20190812160642.52134-1-catalin.marinas@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Currently kmemleak uses a static early_log buffer to trace all memory
allocation/freeing before the slab allocator is initialised. Such early
log is replayed during kmemleak_init() to properly initialise the
kmemleak metadata for objects allocated up that point. With a memory
pool that does not rely on the slab allocator, it is possible to skip
this early log entirely.

In order to remove the early logging, consider kmemleak_enabled =3D=3D 1 =
by
default while the kmem_cache availability is checked directly on the
object_cache and scan_area_cache variables. The RCU callback is only
invoked after object_cache has been initialised as we wouldn't have any
concurrent list traversal before this.

In order to reduce the number of callbacks before kmemleak is fully
initialised, move the kmemleak_init() call to mm_init().

Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
---
 init/main.c       |   2 +-
 lib/Kconfig.debug |  11 +-
 mm/kmemleak.c     | 267 +++++-----------------------------------------
 3 files changed, 35 insertions(+), 245 deletions(-)

diff --git a/init/main.c b/init/main.c
index 96f8d5af52d6..ca05e3cd7ef7 100644
--- a/init/main.c
+++ b/init/main.c
@@ -556,6 +556,7 @@ static void __init mm_init(void)
 	report_meminit();
 	mem_init();
 	kmem_cache_init();
+	kmemleak_init();
 	pgtable_init();
 	debug_objects_mem_init();
 	vmalloc_init();
@@ -740,7 +741,6 @@ asmlinkage __visible void __init start_kernel(void)
 		initrd_start =3D 0;
 	}
 #endif
-	kmemleak_init();
 	setup_per_cpu_pageset();
 	numa_policy_init();
 	acpi_early_init();
diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index 4d39540011e2..39df06ffd9f4 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -592,17 +592,18 @@ config DEBUG_KMEMLEAK
 	  In order to access the kmemleak file, debugfs needs to be
 	  mounted (usually at /sys/kernel/debug).
=20
-config DEBUG_KMEMLEAK_EARLY_LOG_SIZE
-	int "Maximum kmemleak early log entries"
+config DEBUG_KMEMLEAK_MEM_POOL_SIZE
+	int "Kmemleak memory pool size"
 	depends on DEBUG_KMEMLEAK
 	range 200 40000
 	default 16000
 	help
 	  Kmemleak must track all the memory allocations to avoid
 	  reporting false positives. Since memory may be allocated or
-	  freed before kmemleak is initialised, an early log buffer is
-	  used to store these actions. If kmemleak reports "early log
-	  buffer exceeded", please increase this value.
+	  freed before kmemleak is fully initialised, use a static pool
+	  of metadata objects to track such callbacks. After kmemleak is
+	  fully initialised, this memory pool acts as an emergency one
+	  if slab allocations fail.
=20
 config DEBUG_KMEMLEAK_TEST
 	tristate "Simple test for the kernel memory leak detector"
diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index 2fb86524d70b..bcb05b9b4eb4 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -180,15 +180,13 @@ struct kmemleak_object {
 #define HEX_ASCII		1
 /* max number of lines to be printed */
 #define HEX_MAX_LINES		2
-/* memory pool size */
-#define MEM_POOL_SIZE		16000
=20
 /* the list of all allocated objects */
 static LIST_HEAD(object_list);
 /* the list of gray-colored objects (see color_gray comment below) */
 static LIST_HEAD(gray_list);
 /* memory pool allocation */
-static struct kmemleak_object mem_pool[MEM_POOL_SIZE];
+static struct kmemleak_object mem_pool[CONFIG_DEBUG_KMEMLEAK_MEM_POOL_SI=
ZE];
 static int mem_pool_free_count =3D ARRAY_SIZE(mem_pool);
 static LIST_HEAD(mem_pool_free_list);
 /* search tree for object boundaries */
@@ -201,13 +199,11 @@ static struct kmem_cache *object_cache;
 static struct kmem_cache *scan_area_cache;
=20
 /* set if tracing memory operations is enabled */
-static int kmemleak_enabled;
+static int kmemleak_enabled =3D 1;
 /* same as above but only for the kmemleak_free() callback */
-static int kmemleak_free_enabled;
+static int kmemleak_free_enabled =3D 1;
 /* set in the late_initcall if there were no errors */
 static int kmemleak_initialized;
-/* enables or disables early logging of the memory operations */
-static int kmemleak_early_log =3D 1;
 /* set if a kmemleak warning was issued */
 static int kmemleak_warning;
 /* set if a fatal kmemleak error has occurred */
@@ -235,49 +231,6 @@ static bool kmemleak_found_leaks;
 static bool kmemleak_verbose;
 module_param_named(verbose, kmemleak_verbose, bool, 0600);
=20
-/*
- * Early object allocation/freeing logging. Kmemleak is initialized afte=
r the
- * kernel allocator. However, both the kernel allocator and kmemleak may
- * allocate memory blocks which need to be tracked. Kmemleak defines an
- * arbitrary buffer to hold the allocation/freeing information before it=
 is
- * fully initialized.
- */
-
-/* kmemleak operation type for early logging */
-enum {
-	KMEMLEAK_ALLOC,
-	KMEMLEAK_ALLOC_PERCPU,
-	KMEMLEAK_FREE,
-	KMEMLEAK_FREE_PART,
-	KMEMLEAK_FREE_PERCPU,
-	KMEMLEAK_NOT_LEAK,
-	KMEMLEAK_IGNORE,
-	KMEMLEAK_SCAN_AREA,
-	KMEMLEAK_NO_SCAN,
-	KMEMLEAK_SET_EXCESS_REF
-};
-
-/*
- * Structure holding the information passed to kmemleak callbacks during=
 the
- * early logging.
- */
-struct early_log {
-	int op_type;			/* kmemleak operation type */
-	int min_count;			/* minimum reference count */
-	const void *ptr;		/* allocated/freed memory block */
-	union {
-		size_t size;		/* memory block size */
-		unsigned long excess_ref; /* surplus reference passing */
-	};
-	unsigned long trace[MAX_TRACE];	/* stack trace */
-	unsigned int trace_len;		/* stack trace length */
-};
-
-/* early logging buffer and current position */
-static struct early_log
-	early_log[CONFIG_DEBUG_KMEMLEAK_EARLY_LOG_SIZE] __initdata;
-static int crt_early_log __initdata;
-
 static void kmemleak_disable(void);
=20
 /*
@@ -466,9 +419,13 @@ static struct kmemleak_object *mem_pool_alloc(gfp_t =
gfp)
 	struct kmemleak_object *object;
=20
 	/* try the slab allocator first */
-	object =3D kmem_cache_alloc(object_cache, gfp_kmemleak_mask(gfp));
-	if (object)
-		return object;
+	if (object_cache) {
+		object =3D kmem_cache_alloc(object_cache, gfp_kmemleak_mask(gfp));
+		if (object)
+			return object;
+		else
+			WARN_ON_ONCE(1);
+	}
=20
 	/* slab allocation failed, try the memory pool */
 	write_lock_irqsave(&kmemleak_lock, flags);
@@ -478,6 +435,8 @@ static struct kmemleak_object *mem_pool_alloc(gfp_t g=
fp)
 		list_del(&object->object_list);
 	else if (mem_pool_free_count)
 		object =3D &mem_pool[--mem_pool_free_count];
+	else
+		pr_warn_once("Memory pool empty, consider increasing CONFIG_DEBUG_KMEM=
LEAK_MEM_POOL_SIZE\n");
 	write_unlock_irqrestore(&kmemleak_lock, flags);
=20
 	return object;
@@ -537,7 +496,15 @@ static void put_object(struct kmemleak_object *objec=
t)
 	/* should only get here after delete_object was called */
 	WARN_ON(object->flags & OBJECT_ALLOCATED);
=20
-	call_rcu(&object->rcu, free_object_rcu);
+	/*
+	 * It may be too early for the RCU callbacks, however, there is no
+	 * concurrent object_list traversal when !object_cache and all objects
+	 * came from the memory pool. Free the object directly.
+	 */
+	if (object_cache)
+		call_rcu(&object->rcu, free_object_rcu);
+	else
+		free_object_rcu(&object->rcu);
 }
=20
 /*
@@ -741,9 +708,7 @@ static void delete_object_part(unsigned long ptr, siz=
e_t size)
 	/*
 	 * Create one or two objects that may result from the memory block
 	 * split. Note that partial freeing is only done by free_bootmem() and
-	 * this happens before kmemleak_init() is called. The path below is
-	 * only executed during early log recording in kmemleak_init(), so
-	 * GFP_KERNEL is enough.
+	 * this happens before kmemleak_init() is called.
 	 */
 	start =3D object->pointer;
 	end =3D object->pointer + object->size;
@@ -815,7 +780,7 @@ static void add_scan_area(unsigned long ptr, size_t s=
ize, gfp_t gfp)
 {
 	unsigned long flags;
 	struct kmemleak_object *object;
-	struct kmemleak_scan_area *area;
+	struct kmemleak_scan_area *area =3D NULL;
=20
 	object =3D find_and_get_object(ptr, 1);
 	if (!object) {
@@ -824,7 +789,8 @@ static void add_scan_area(unsigned long ptr, size_t s=
ize, gfp_t gfp)
 		return;
 	}
=20
-	area =3D kmem_cache_alloc(scan_area_cache, gfp_kmemleak_mask(gfp));
+	if (scan_area_cache)
+		area =3D kmem_cache_alloc(scan_area_cache, gfp_kmemleak_mask(gfp));
=20
 	spin_lock_irqsave(&object->lock, flags);
 	if (!area) {
@@ -898,86 +864,6 @@ static void object_no_scan(unsigned long ptr)
 	put_object(object);
 }
=20
-/*
- * Log an early kmemleak_* call to the early_log buffer. These calls wil=
l be
- * processed later once kmemleak is fully initialized.
- */
-static void __init log_early(int op_type, const void *ptr, size_t size,
-			     int min_count)
-{
-	unsigned long flags;
-	struct early_log *log;
-
-	if (kmemleak_error) {
-		/* kmemleak stopped recording, just count the requests */
-		crt_early_log++;
-		return;
-	}
-
-	if (crt_early_log >=3D ARRAY_SIZE(early_log)) {
-		crt_early_log++;
-		kmemleak_disable();
-		return;
-	}
-
-	/*
-	 * There is no need for locking since the kernel is still in UP mode
-	 * at this stage. Disabling the IRQs is enough.
-	 */
-	local_irq_save(flags);
-	log =3D &early_log[crt_early_log];
-	log->op_type =3D op_type;
-	log->ptr =3D ptr;
-	log->size =3D size;
-	log->min_count =3D min_count;
-	log->trace_len =3D __save_stack_trace(log->trace);
-	crt_early_log++;
-	local_irq_restore(flags);
-}
-
-/*
- * Log an early allocated block and populate the stack trace.
- */
-static void early_alloc(struct early_log *log)
-{
-	struct kmemleak_object *object;
-	unsigned long flags;
-	int i;
-
-	if (!kmemleak_enabled || !log->ptr || IS_ERR(log->ptr))
-		return;
-
-	/*
-	 * RCU locking needed to ensure object is not freed via put_object().
-	 */
-	rcu_read_lock();
-	object =3D create_object((unsigned long)log->ptr, log->size,
-			       log->min_count, GFP_ATOMIC);
-	if (!object)
-		goto out;
-	spin_lock_irqsave(&object->lock, flags);
-	for (i =3D 0; i < log->trace_len; i++)
-		object->trace[i] =3D log->trace[i];
-	object->trace_len =3D log->trace_len;
-	spin_unlock_irqrestore(&object->lock, flags);
-out:
-	rcu_read_unlock();
-}
-
-/*
- * Log an early allocated block and populate the stack trace.
- */
-static void early_alloc_percpu(struct early_log *log)
-{
-	unsigned int cpu;
-	const void __percpu *ptr =3D log->ptr;
-
-	for_each_possible_cpu(cpu) {
-		log->ptr =3D per_cpu_ptr(ptr, cpu);
-		early_alloc(log);
-	}
-}
-
 /**
  * kmemleak_alloc - register a newly allocated object
  * @ptr:	pointer to beginning of the object
@@ -999,8 +885,6 @@ void __ref kmemleak_alloc(const void *ptr, size_t siz=
e, int min_count,
=20
 	if (kmemleak_enabled && ptr && !IS_ERR(ptr))
 		create_object((unsigned long)ptr, size, min_count, gfp);
-	else if (kmemleak_early_log)
-		log_early(KMEMLEAK_ALLOC, ptr, size, min_count);
 }
 EXPORT_SYMBOL_GPL(kmemleak_alloc);
=20
@@ -1028,8 +912,6 @@ void __ref kmemleak_alloc_percpu(const void __percpu=
 *ptr, size_t size,
 		for_each_possible_cpu(cpu)
 			create_object((unsigned long)per_cpu_ptr(ptr, cpu),
 				      size, 0, gfp);
-	else if (kmemleak_early_log)
-		log_early(KMEMLEAK_ALLOC_PERCPU, ptr, size, 0);
 }
 EXPORT_SYMBOL_GPL(kmemleak_alloc_percpu);
=20
@@ -1054,11 +936,6 @@ void __ref kmemleak_vmalloc(const struct vm_struct =
*area, size_t size, gfp_t gfp
 		create_object((unsigned long)area->addr, size, 2, gfp);
 		object_set_excess_ref((unsigned long)area,
 				      (unsigned long)area->addr);
-	} else if (kmemleak_early_log) {
-		log_early(KMEMLEAK_ALLOC, area->addr, size, 2);
-		/* reusing early_log.size for storing area->addr */
-		log_early(KMEMLEAK_SET_EXCESS_REF,
-			  area, (unsigned long)area->addr, 0);
 	}
 }
 EXPORT_SYMBOL_GPL(kmemleak_vmalloc);
@@ -1076,8 +953,6 @@ void __ref kmemleak_free(const void *ptr)
=20
 	if (kmemleak_free_enabled && ptr && !IS_ERR(ptr))
 		delete_object_full((unsigned long)ptr);
-	else if (kmemleak_early_log)
-		log_early(KMEMLEAK_FREE, ptr, 0, 0);
 }
 EXPORT_SYMBOL_GPL(kmemleak_free);
=20
@@ -1096,8 +971,6 @@ void __ref kmemleak_free_part(const void *ptr, size_=
t size)
=20
 	if (kmemleak_enabled && ptr && !IS_ERR(ptr))
 		delete_object_part((unsigned long)ptr, size);
-	else if (kmemleak_early_log)
-		log_early(KMEMLEAK_FREE_PART, ptr, size, 0);
 }
 EXPORT_SYMBOL_GPL(kmemleak_free_part);
=20
@@ -1118,8 +991,6 @@ void __ref kmemleak_free_percpu(const void __percpu =
*ptr)
 		for_each_possible_cpu(cpu)
 			delete_object_full((unsigned long)per_cpu_ptr(ptr,
 								      cpu));
-	else if (kmemleak_early_log)
-		log_early(KMEMLEAK_FREE_PERCPU, ptr, 0, 0);
 }
 EXPORT_SYMBOL_GPL(kmemleak_free_percpu);
=20
@@ -1170,8 +1041,6 @@ void __ref kmemleak_not_leak(const void *ptr)
=20
 	if (kmemleak_enabled && ptr && !IS_ERR(ptr))
 		make_gray_object((unsigned long)ptr);
-	else if (kmemleak_early_log)
-		log_early(KMEMLEAK_NOT_LEAK, ptr, 0, 0);
 }
 EXPORT_SYMBOL(kmemleak_not_leak);
=20
@@ -1190,8 +1059,6 @@ void __ref kmemleak_ignore(const void *ptr)
=20
 	if (kmemleak_enabled && ptr && !IS_ERR(ptr))
 		make_black_object((unsigned long)ptr);
-	else if (kmemleak_early_log)
-		log_early(KMEMLEAK_IGNORE, ptr, 0, 0);
 }
 EXPORT_SYMBOL(kmemleak_ignore);
=20
@@ -1212,8 +1079,6 @@ void __ref kmemleak_scan_area(const void *ptr, size=
_t size, gfp_t gfp)
=20
 	if (kmemleak_enabled && ptr && size && !IS_ERR(ptr))
 		add_scan_area((unsigned long)ptr, size, gfp);
-	else if (kmemleak_early_log)
-		log_early(KMEMLEAK_SCAN_AREA, ptr, size, 0);
 }
 EXPORT_SYMBOL(kmemleak_scan_area);
=20
@@ -1232,8 +1097,6 @@ void __ref kmemleak_no_scan(const void *ptr)
=20
 	if (kmemleak_enabled && ptr && !IS_ERR(ptr))
 		object_no_scan((unsigned long)ptr);
-	else if (kmemleak_early_log)
-		log_early(KMEMLEAK_NO_SCAN, ptr, 0, 0);
 }
 EXPORT_SYMBOL(kmemleak_no_scan);
=20
@@ -2020,7 +1883,6 @@ static void kmemleak_disable(void)
=20
 	/* stop any memory operation tracing */
 	kmemleak_enabled =3D 0;
-	kmemleak_early_log =3D 0;
=20
 	/* check whether it is too early for a kernel thread */
 	if (kmemleak_initialized)
@@ -2048,20 +1910,11 @@ static int __init kmemleak_boot_config(char *str)
 }
 early_param("kmemleak", kmemleak_boot_config);
=20
-static void __init print_log_trace(struct early_log *log)
-{
-	pr_notice("Early log backtrace:\n");
-	stack_trace_print(log->trace, log->trace_len, 2);
-}
-
 /*
  * Kmemleak initialization.
  */
 void __init kmemleak_init(void)
 {
-	int i;
-	unsigned long flags;
-
 #ifdef CONFIG_DEBUG_KMEMLEAK_DEFAULT_OFF
 	if (!kmemleak_skip_disable) {
 		kmemleak_disable();
@@ -2069,28 +1922,15 @@ void __init kmemleak_init(void)
 	}
 #endif
=20
+	if (kmemleak_error)
+		return;
+
 	jiffies_min_age =3D msecs_to_jiffies(MSECS_MIN_AGE);
 	jiffies_scan_wait =3D msecs_to_jiffies(SECS_SCAN_WAIT * 1000);
=20
 	object_cache =3D KMEM_CACHE(kmemleak_object, SLAB_NOLEAKTRACE);
 	scan_area_cache =3D KMEM_CACHE(kmemleak_scan_area, SLAB_NOLEAKTRACE);
=20
-	if (crt_early_log > ARRAY_SIZE(early_log))
-		pr_warn("Early log buffer exceeded (%d), please increase DEBUG_KMEMLEA=
K_EARLY_LOG_SIZE\n",
-			crt_early_log);
-
-	/* the kernel is still in UP mode, so disabling the IRQs is enough */
-	local_irq_save(flags);
-	kmemleak_early_log =3D 0;
-	if (kmemleak_error) {
-		local_irq_restore(flags);
-		return;
-	} else {
-		kmemleak_enabled =3D 1;
-		kmemleak_free_enabled =3D 1;
-	}
-	local_irq_restore(flags);
-
 	/* register the data/bss sections */
 	create_object((unsigned long)_sdata, _edata - _sdata,
 		      KMEMLEAK_GREY, GFP_ATOMIC);
@@ -2101,57 +1941,6 @@ void __init kmemleak_init(void)
 		create_object((unsigned long)__start_ro_after_init,
 			      __end_ro_after_init - __start_ro_after_init,
 			      KMEMLEAK_GREY, GFP_ATOMIC);
-
-	/*
-	 * This is the point where tracking allocations is safe. Automatic
-	 * scanning is started during the late initcall. Add the early logged
-	 * callbacks to the kmemleak infrastructure.
-	 */
-	for (i =3D 0; i < crt_early_log; i++) {
-		struct early_log *log =3D &early_log[i];
-
-		switch (log->op_type) {
-		case KMEMLEAK_ALLOC:
-			early_alloc(log);
-			break;
-		case KMEMLEAK_ALLOC_PERCPU:
-			early_alloc_percpu(log);
-			break;
-		case KMEMLEAK_FREE:
-			kmemleak_free(log->ptr);
-			break;
-		case KMEMLEAK_FREE_PART:
-			kmemleak_free_part(log->ptr, log->size);
-			break;
-		case KMEMLEAK_FREE_PERCPU:
-			kmemleak_free_percpu(log->ptr);
-			break;
-		case KMEMLEAK_NOT_LEAK:
-			kmemleak_not_leak(log->ptr);
-			break;
-		case KMEMLEAK_IGNORE:
-			kmemleak_ignore(log->ptr);
-			break;
-		case KMEMLEAK_SCAN_AREA:
-			kmemleak_scan_area(log->ptr, log->size, GFP_KERNEL);
-			break;
-		case KMEMLEAK_NO_SCAN:
-			kmemleak_no_scan(log->ptr);
-			break;
-		case KMEMLEAK_SET_EXCESS_REF:
-			object_set_excess_ref((unsigned long)log->ptr,
-					      log->excess_ref);
-			break;
-		default:
-			kmemleak_warn("Unknown early log operation: %d\n",
-				      log->op_type);
-		}
-
-		if (kmemleak_warning) {
-			print_log_trace(log);
-			kmemleak_warning =3D 0;
-		}
-	}
 }
=20
 /*

