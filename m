Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 53A526B0007
	for <linux-mm@kvack.org>; Fri, 27 Apr 2018 19:20:11 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id d11so2593873qkg.20
        for <linux-mm@kvack.org>; Fri, 27 Apr 2018 16:20:11 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id p91-v6si2307390qva.207.2018.04.27.16.20.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Apr 2018 16:20:10 -0700 (PDT)
Date: Fri, 27 Apr 2018 19:20:07 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: [dm-devel] [PATCH v5] fault-injection: introduce kvmalloc fallback
 options
In-Reply-To: <20180427005213-mutt-send-email-mst@kernel.org>
Message-ID: <alpine.LRH.2.02.1804271914200.4345@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1804251556060.30569@file01.intranet.prod.int.rdu2.redhat.com> <1114eda5-9b1f-4db8-2090-556b4a37c532@infradead.org> <alpine.LRH.2.02.1804251656300.9428@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.21.1804251417470.166306@chino.kir.corp.google.com>
 <alpine.LRH.2.02.1804251720090.9428@file01.intranet.prod.int.rdu2.redhat.com> <1524694663.4100.21.camel@HansenPartnership.com> <alpine.LRH.2.02.1804251857070.31135@file01.intranet.prod.int.rdu2.redhat.com> <1524697697.4100.23.camel@HansenPartnership.com>
 <23266.8532.619051.784274@quad.stoffel.home> <alpine.LRH.2.02.1804261726540.13401@file01.intranet.prod.int.rdu2.redhat.com> <20180427005213-mutt-send-email-mst@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: John Stoffel <john@stoffel.org>, James Bottomley <James.Bottomley@HansenPartnership.com>, Michal@stoffel.org, eric.dumazet@gmail.com, netdev@vger.kernel.org, jasowang@redhat.com, Randy Dunlap <rdunlap@infradead.org>, linux-kernel@vger.kernel.org, Matthew Wilcox <willy@infradead.org>, Hocko <mhocko@kernel.org>, linux-mm@kvack.org, dm-devel@redhat.com, Vlastimil Babka <vbabka@suse.cz>, Andrew@stoffel.org, David Rientjes <rientjes@google.com>, Morton <akpm@linux-foundation.org>, virtualization@lists.linux-foundation.org, David Miller <davem@davemloft.net>, edumazet@google.com



On Fri, 27 Apr 2018, Michael S. Tsirkin wrote:

> 2. Ability to control this from a separate config
>    option.
> 
>    It's still not that clear to me why is this such a
>    hard requirement.  If a distro wants to force specific
>    boot time options, why isn't CONFIG_CMDLINE sufficient?

So, try this and turn it on with CONFIG_CMDLINE. But I'm not a 
blogger and I will not write a blog post about it as James Bottomley 
suggests :-)
- so very few users will use it. 


fault-injection: introduce kvmalloc fallback options

This patch introduces a fault-injection option "kvmalloc_fallback". This
option makes kvmalloc randomly fall back to vmalloc.

Unfortunately, some kernel code has bugs - it uses kvmalloc and then
uses DMA-API on the returned memory or frees it with kfree. Such bugs were
found in the virtio-net driver, dm-integrity or RHEL7 powerpc-specific
code. This options helps to test for these bugs.

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>

---
 Documentation/fault-injection/fault-injection.txt |    7 +++++
 mm/util.c                                         |   30 ++++++++++++++++++++++
 2 files changed, 37 insertions(+)

Index: linux-2.6/Documentation/fault-injection/fault-injection.txt
===================================================================
--- linux-2.6.orig/Documentation/fault-injection/fault-injection.txt	2018-04-28 01:01:25.000000000 +0200
+++ linux-2.6/Documentation/fault-injection/fault-injection.txt	2018-04-28 01:01:25.000000000 +0200
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
Index: linux-2.6/mm/util.c
===================================================================
--- linux-2.6.orig/mm/util.c	2018-04-28 01:01:25.000000000 +0200
+++ linux-2.6/mm/util.c	2018-04-28 01:03:25.000000000 +0200
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
+static DECLARE_FAULT_ATTR(kvmalloc_fallback);
+
+static int __init setup_kvmalloc_fallback(char *str)
+{
+	kvmalloc_fallback.verbose = 0;
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
