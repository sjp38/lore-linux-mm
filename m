Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9A33E280244
	for <linux-mm@kvack.org>; Tue, 31 Oct 2017 18:32:19 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id s75so435855pgs.12
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 15:32:19 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id u5si2565026pgn.73.2017.10.31.15.32.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Oct 2017 15:32:18 -0700 (PDT)
Subject: [PATCH 17/23] x86, kaiser: map virtually-addressed performance monitoring buffers
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Tue, 31 Oct 2017 15:32:17 -0700
References: <20171031223146.6B47C861@viggo.jf.intel.com>
In-Reply-To: <20171031223146.6B47C861@viggo.jf.intel.com>
Message-Id: <20171031223217.A213B920@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, dave.hansen@linux.intel.com, hughd@google.com, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, x86@kernel.org


From: Hugh Dickins <hughd@google.com>

The BTS and PEBS buffers both have their virtual addresses programmed
into the hardware.  This means that we have to access them via the page
tables.  The times that the hardware accesses these are entirely
dependent on how the performance monitoring hardware events are set up.
In other words, we have no idea when we might need to access these
buffers.

Avoid perf crashes: place debug_store in the user-mapped per-cpu area
instead of allocating, and use page allocator plus kaiser_add_mapping()
to keep the BTS and PEBS buffers user-mapped (that is, present in the
user mapping, though visible only to kernel and hardware).  The PEBS
fixup buffer does not need this treatment.

The need for a user-mapped struct debug_store showed up before doing
any conscious perf testing: in a couple of kernel paging oopses on
Westmere, implicating the debug_store offset of the per-cpu area.

Signed-off-by: Hugh Dickins <hughd@google.com>
Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Moritz Lipp <moritz.lipp@iaik.tugraz.at>
Cc: Daniel Gruss <daniel.gruss@iaik.tugraz.at>
Cc: Michael Schwarz <michael.schwarz@iaik.tugraz.at>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Kees Cook <keescook@google.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: x86@kernel.org
---

 b/arch/x86/events/intel/ds.c |   57 +++++++++++++++++++++++++++++++++----------
 1 file changed, 45 insertions(+), 12 deletions(-)

diff -puN arch/x86/events/intel/ds.c~kaiser-user-map-virtually-addressed-performance-monitoring-buffers arch/x86/events/intel/ds.c
--- a/arch/x86/events/intel/ds.c~kaiser-user-map-virtually-addressed-performance-monitoring-buffers	2017-10-31 15:03:57.933471803 -0700
+++ b/arch/x86/events/intel/ds.c	2017-10-31 15:03:57.937471992 -0700
@@ -2,11 +2,15 @@
 #include <linux/types.h>
 #include <linux/slab.h>
 
+#include <asm/kaiser.h>
 #include <asm/perf_event.h>
 #include <asm/insn.h>
 
 #include "../perf_event.h"
 
+static
+DEFINE_PER_CPU_SHARED_ALIGNED_USER_MAPPED(struct debug_store, cpu_debug_store);
+
 /* The size of a BTS record in bytes: */
 #define BTS_RECORD_SIZE		24
 
@@ -278,6 +282,39 @@ void fini_debug_store_on_cpu(int cpu)
 
 static DEFINE_PER_CPU(void *, insn_buffer);
 
+static void *dsalloc(size_t size, gfp_t flags, int node)
+{
+#ifdef CONFIG_KAISER
+	unsigned int order = get_order(size);
+	struct page *page;
+	unsigned long addr;
+
+	page = __alloc_pages_node(node, flags | __GFP_ZERO, order);
+	if (!page)
+		return NULL;
+	addr = (unsigned long)page_address(page);
+	if (kaiser_add_mapping(addr, size, __PAGE_KERNEL) < 0) {
+		__free_pages(page, order);
+		addr = 0;
+	}
+	return (void *)addr;
+#else
+	return kmalloc_node(size, flags | __GFP_ZERO, node);
+#endif
+}
+
+static void dsfree(const void *buffer, size_t size)
+{
+#ifdef CONFIG_KAISER
+	if (!buffer)
+		return;
+	kaiser_remove_mapping((unsigned long)buffer, size);
+	free_pages((unsigned long)buffer, get_order(size));
+#else
+	kfree(buffer);
+#endif
+}
+
 static int alloc_pebs_buffer(int cpu)
 {
 	struct debug_store *ds = per_cpu(cpu_hw_events, cpu).ds;
@@ -288,7 +325,7 @@ static int alloc_pebs_buffer(int cpu)
 	if (!x86_pmu.pebs)
 		return 0;
 
-	buffer = kzalloc_node(x86_pmu.pebs_buffer_size, GFP_KERNEL, node);
+	buffer = dsalloc(x86_pmu.pebs_buffer_size, GFP_KERNEL, node);
 	if (unlikely(!buffer))
 		return -ENOMEM;
 
@@ -299,7 +336,7 @@ static int alloc_pebs_buffer(int cpu)
 	if (x86_pmu.intel_cap.pebs_format < 2) {
 		ibuffer = kzalloc_node(PEBS_FIXUP_SIZE, GFP_KERNEL, node);
 		if (!ibuffer) {
-			kfree(buffer);
+			dsfree(buffer, x86_pmu.pebs_buffer_size);
 			return -ENOMEM;
 		}
 		per_cpu(insn_buffer, cpu) = ibuffer;
@@ -325,7 +362,8 @@ static void release_pebs_buffer(int cpu)
 	kfree(per_cpu(insn_buffer, cpu));
 	per_cpu(insn_buffer, cpu) = NULL;
 
-	kfree((void *)(unsigned long)ds->pebs_buffer_base);
+	dsfree((void *)(unsigned long)ds->pebs_buffer_base,
+			x86_pmu.pebs_buffer_size);
 	ds->pebs_buffer_base = 0;
 }
 
@@ -339,7 +377,7 @@ static int alloc_bts_buffer(int cpu)
 	if (!x86_pmu.bts)
 		return 0;
 
-	buffer = kzalloc_node(BTS_BUFFER_SIZE, GFP_KERNEL | __GFP_NOWARN, node);
+	buffer = dsalloc(BTS_BUFFER_SIZE, GFP_KERNEL | __GFP_NOWARN, node);
 	if (unlikely(!buffer)) {
 		WARN_ONCE(1, "%s: BTS buffer allocation failure\n", __func__);
 		return -ENOMEM;
@@ -365,19 +403,15 @@ static void release_bts_buffer(int cpu)
 	if (!ds || !x86_pmu.bts)
 		return;
 
-	kfree((void *)(unsigned long)ds->bts_buffer_base);
+	dsfree((void *)(unsigned long)ds->bts_buffer_base, BTS_BUFFER_SIZE);
 	ds->bts_buffer_base = 0;
 }
 
 static int alloc_ds_buffer(int cpu)
 {
-	int node = cpu_to_node(cpu);
-	struct debug_store *ds;
-
-	ds = kzalloc_node(sizeof(*ds), GFP_KERNEL, node);
-	if (unlikely(!ds))
-		return -ENOMEM;
+	struct debug_store *ds = per_cpu_ptr(&cpu_debug_store, cpu);
 
+	memset(ds, 0, sizeof(*ds));
 	per_cpu(cpu_hw_events, cpu).ds = ds;
 
 	return 0;
@@ -391,7 +425,6 @@ static void release_ds_buffer(int cpu)
 		return;
 
 	per_cpu(cpu_hw_events, cpu).ds = NULL;
-	kfree(ds);
 }
 
 void release_ds_buffers(void)
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
