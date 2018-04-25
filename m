Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8E7A16B0003
	for <linux-mm@kvack.org>; Wed, 25 Apr 2018 16:57:46 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id x2-v6so6964631qto.10
        for <linux-mm@kvack.org>; Wed, 25 Apr 2018 13:57:46 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id l19-v6si6164356qtp.285.2018.04.25.13.57.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Apr 2018 13:57:45 -0700 (PDT)
Date: Wed, 25 Apr 2018 16:57:43 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: [PATCH v5] fault-injection: introduce kvmalloc fallback options
In-Reply-To: <1114eda5-9b1f-4db8-2090-556b4a37c532@infradead.org>
Message-ID: <alpine.LRH.2.02.1804251656300.9428@file01.intranet.prod.int.rdu2.redhat.com>
References: <20180421144757.GC14610@bombadil.infradead.org> <alpine.LRH.2.02.1804221733520.7995@file01.intranet.prod.int.rdu2.redhat.com> <20180423151545.GU17484@dhcp22.suse.cz> <alpine.LRH.2.02.1804232003100.2299@file01.intranet.prod.int.rdu2.redhat.com>
 <20180424125121.GA17484@dhcp22.suse.cz> <alpine.LRH.2.02.1804241142340.15660@file01.intranet.prod.int.rdu2.redhat.com> <20180424162906.GM17484@dhcp22.suse.cz> <alpine.LRH.2.02.1804241250350.28995@file01.intranet.prod.int.rdu2.redhat.com>
 <20180424170349.GQ17484@dhcp22.suse.cz> <alpine.LRH.2.02.1804241319390.28995@file01.intranet.prod.int.rdu2.redhat.com> <20180424173836.GR17484@dhcp22.suse.cz> <alpine.LRH.2.02.1804251556060.30569@file01.intranet.prod.int.rdu2.redhat.com>
 <1114eda5-9b1f-4db8-2090-556b4a37c532@infradead.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: Michal Hocko <mhocko@kernel.org>, Matthew Wilcox <willy@infradead.org>, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, eric.dumazet@gmail.com, edumazet@google.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, mst@redhat.com, jasowang@redhat.com, virtualization@lists.linux-foundation.org, dm-devel@redhat.com, Vlastimil Babka <vbabka@suse.cz>



On Wed, 25 Apr 2018, Randy Dunlap wrote:

> On 04/25/2018 01:02 PM, Mikulas Patocka wrote:
> > 
> > 
> > From: Mikulas Patocka <mpatocka@redhat.com>
> > Subject: [PATCH v4] fault-injection: introduce kvmalloc fallback options
> > 
> > This patch introduces a fault-injection option "kvmalloc_fallback". This
> > option makes kvmalloc randomly fall back to vmalloc.
> > 
> > Unfortunatelly, some kernel code has bugs - it uses kvmalloc and then
> 
>   Unfortunately,

OK - here I fixed the typos:


From: Mikulas Patocka <mpatocka@redhat.com>
Subject: [PATCH] fault-injection: introduce kvmalloc fallback options

This patch introduces a fault-injection option "kvmalloc_fallback". This
option makes kvmalloc randomly fall back to vmalloc.

Unfortunately, some kernel code has bugs - it uses kvmalloc and then
uses DMA-API on the returned memory or frees it with kfree. Such bugs were
found in the virtio-net driver, dm-integrity or RHEL7 powerpc-specific
code. This options helps to test for these bugs.

The patch introduces a config option FAIL_KVMALLOC_FALLBACK_PROBABILITY.
It can be enabled in distribution debug kernels, so that kvmalloc abuse
can be tested by the users. The default can be overridden with
"kvmalloc_fallback" parameter or in /sys/kernel/debug/kvmalloc_fallback/.

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>

---
 Documentation/fault-injection/fault-injection.txt |    7 +++++
 include/linux/fault-inject.h                      |    9 +++---
 kernel/futex.c                                    |    2 -
 lib/Kconfig.debug                                 |   15 +++++++++++
 mm/failslab.c                                     |    2 -
 mm/page_alloc.c                                   |    2 -
 mm/util.c                                         |   30 ++++++++++++++++++++++
 7 files changed, 60 insertions(+), 7 deletions(-)

Index: linux-2.6/Documentation/fault-injection/fault-injection.txt
===================================================================
--- linux-2.6.orig/Documentation/fault-injection/fault-injection.txt	2018-04-16 21:08:34.000000000 +0200
+++ linux-2.6/Documentation/fault-injection/fault-injection.txt	2018-04-25 21:36:36.000000000 +0200
@@ -15,6 +15,12 @@ o fail_page_alloc
 
   injects page allocation failures. (alloc_pages(), get_free_pages(), ...)
 
+o kvmalloc_fallback
+
+  makes the function kvmalloc randomly fall back to vmalloc. This could be used
+  to detects bugs such as using DMA-API on the result of kvmalloc or freeing
+  the result of kvmalloc with free.
+
 o fail_futex
 
   injects futex deadlock and uaddr fault errors.
@@ -167,6 +173,7 @@ use the boot option:
 
 	failslab=
 	fail_page_alloc=
+	kvmalloc_fallback=
 	fail_make_request=
 	fail_futex=
 	mmc_core.fail_request=<interval>,<probability>,<space>,<times>
Index: linux-2.6/include/linux/fault-inject.h
===================================================================
--- linux-2.6.orig/include/linux/fault-inject.h	2018-04-16 21:08:36.000000000 +0200
+++ linux-2.6/include/linux/fault-inject.h	2018-04-25 21:38:22.000000000 +0200
@@ -31,17 +31,18 @@ struct fault_attr {
 	struct dentry *dname;
 };
 
-#define FAULT_ATTR_INITIALIZER {					\
+#define FAULT_ATTR_INITIALIZER(p) {					\
+		.probability = (p),					\
 		.interval = 1,						\
-		.times = ATOMIC_INIT(1),				\
+		.times = ATOMIC_INIT((p) ? -1 : 1),			\
+		.verbose = (p) ? 0 : 2,					\
 		.require_end = ULONG_MAX,				\
 		.stacktrace_depth = 32,					\
 		.ratelimit_state = RATELIMIT_STATE_INIT_DISABLED,	\
-		.verbose = 2,						\
 		.dname = NULL,						\
 	}
 
-#define DECLARE_FAULT_ATTR(name) struct fault_attr name = FAULT_ATTR_INITIALIZER
+#define DECLARE_FAULT_ATTR(name) struct fault_attr name = FAULT_ATTR_INITIALIZER(0)
 int setup_fault_attr(struct fault_attr *attr, char *str);
 bool should_fail(struct fault_attr *attr, ssize_t size);
 
Index: linux-2.6/lib/Kconfig.debug
===================================================================
--- linux-2.6.orig/lib/Kconfig.debug	2018-04-25 15:56:16.000000000 +0200
+++ linux-2.6/lib/Kconfig.debug	2018-04-25 21:39:45.000000000 +0200
@@ -1527,6 +1527,21 @@ config FAIL_PAGE_ALLOC
 	help
 	  Provide fault-injection capability for alloc_pages().
 
+config FAIL_KVMALLOC_FALLBACK_PROBABILITY
+	int "Default kvmalloc fallback probability"
+	depends on FAULT_INJECTION
+	range 0 100
+	default "0"
+	help
+	  This option will make kvmalloc randomly fall back to vmalloc.
+	  Normally, kvmalloc falls back to vmalloc only rarely, if memory
+	  is fragmented.
+
+	  This option helps to detect hard-to-reproduce driver bugs, for
+	  example using DMA API on the result of kvmalloc.
+
+	  The default may be overridden with the kvmalloc_fallback parameter.
+
 config FAIL_MAKE_REQUEST
 	bool "Fault-injection capability for disk IO"
 	depends on FAULT_INJECTION && BLOCK
Index: linux-2.6/mm/util.c
===================================================================
--- linux-2.6.orig/mm/util.c	2018-04-25 15:48:39.000000000 +0200
+++ linux-2.6/mm/util.c	2018-04-25 21:43:31.000000000 +0200
@@ -14,6 +14,7 @@
 #include <linux/hugetlb.h>
 #include <linux/vmalloc.h>
 #include <linux/userfaultfd_k.h>
+#include <linux/fault-inject.h>
 
 #include <asm/sections.h>
 #include <linux/uaccess.h>
@@ -377,6 +378,29 @@ unsigned long vm_mmap(struct file *file,
 }
 EXPORT_SYMBOL(vm_mmap);
 
+#ifdef CONFIG_FAULT_INJECTION
+
+static struct fault_attr kvmalloc_fallback =
+	FAULT_ATTR_INITIALIZER(CONFIG_FAIL_KVMALLOC_FALLBACK_PROBABILITY);
+
+static int __init setup_kvmalloc_fallback(char *str)
+{
+	return setup_fault_attr(&kvmalloc_fallback, str);
+}
+
+__setup("kvmalloc_fallback=", setup_kvmalloc_fallback);
+
+#ifdef CONFIG_FAULT_INJECTION_DEBUG_FS
+static int __init kvmalloc_fallback_debugfs_init(void)
+{
+	fault_create_debugfs_attr("kvmalloc_fallback", NULL, &kvmalloc_fallback);
+	return 0;
+}
+late_initcall(kvmalloc_fallback_debugfs_init);
+#endif
+
+#endif
+
 /**
  * kvmalloc_node - attempt to allocate physically contiguous memory, but upon
  * failure, fall back to non-contiguous (vmalloc) allocation.
@@ -404,6 +428,11 @@ void *kvmalloc_node(size_t size, gfp_t f
 	 */
 	WARN_ON_ONCE((flags & GFP_KERNEL) != GFP_KERNEL);
 
+#ifdef CONFIG_FAULT_INJECTION
+	if (should_fail(&kvmalloc_fallback, size))
+		goto do_vmalloc;
+#endif
+
 	/*
 	 * We want to attempt a large physically contiguous block first because
 	 * it is less likely to fragment multiple larger blocks and therefore
@@ -427,6 +456,7 @@ void *kvmalloc_node(size_t size, gfp_t f
 	if (ret || size <= PAGE_SIZE)
 		return ret;
 
+do_vmalloc: __maybe_unused
 	return __vmalloc_node_flags_caller(size, node, flags,
 			__builtin_return_address(0));
 }
Index: linux-2.6/kernel/futex.c
===================================================================
--- linux-2.6.orig/kernel/futex.c	2018-02-14 20:24:42.000000000 +0100
+++ linux-2.6/kernel/futex.c	2018-04-25 21:11:33.000000000 +0200
@@ -288,7 +288,7 @@ static struct {
 
 	bool ignore_private;
 } fail_futex = {
-	.attr = FAULT_ATTR_INITIALIZER,
+	.attr = FAULT_ATTR_INITIALIZER(0),
 	.ignore_private = false,
 };
 
Index: linux-2.6/mm/failslab.c
===================================================================
--- linux-2.6.orig/mm/failslab.c	2018-04-16 21:08:36.000000000 +0200
+++ linux-2.6/mm/failslab.c	2018-04-25 21:11:40.000000000 +0200
@@ -9,7 +9,7 @@ static struct {
 	bool ignore_gfp_reclaim;
 	bool cache_filter;
 } failslab = {
-	.attr = FAULT_ATTR_INITIALIZER,
+	.attr = FAULT_ATTR_INITIALIZER(0),
 	.ignore_gfp_reclaim = true,
 	.cache_filter = false,
 };
Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c	2018-04-16 21:08:36.000000000 +0200
+++ linux-2.6/mm/page_alloc.c	2018-04-25 21:11:47.000000000 +0200
@@ -3055,7 +3055,7 @@ static struct {
 	bool ignore_gfp_reclaim;
 	u32 min_order;
 } fail_page_alloc = {
-	.attr = FAULT_ATTR_INITIALIZER,
+	.attr = FAULT_ATTR_INITIALIZER(0),
 	.ignore_gfp_reclaim = true,
 	.ignore_gfp_highmem = true,
 	.min_order = 1,
