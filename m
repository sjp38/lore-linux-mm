Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id E3D416B0005
	for <linux-mm@kvack.org>; Mon, 23 Apr 2018 20:06:18 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id e21so12291467qkm.1
        for <linux-mm@kvack.org>; Mon, 23 Apr 2018 17:06:18 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id p19si1360706qvf.76.2018.04.23.17.06.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Apr 2018 17:06:17 -0700 (PDT)
Date: Mon, 23 Apr 2018 20:06:16 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: [PATCH v3] kvmalloc: always use vmalloc if CONFIG_DEBUG_SG
In-Reply-To: <20180423151545.GU17484@dhcp22.suse.cz>
Message-ID: <alpine.LRH.2.02.1804232003100.2299@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1804181218270.19136@file01.intranet.prod.int.rdu2.redhat.com> <20180418.134651.2225112489265654270.davem@davemloft.net> <alpine.LRH.2.02.1804181350050.17942@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.LRH.2.02.1804191207380.31175@file01.intranet.prod.int.rdu2.redhat.com> <20180420130852.GC16083@dhcp22.suse.cz> <alpine.LRH.2.02.1804201635180.25408@file01.intranet.prod.int.rdu2.redhat.com> <20180420210200.GH10788@bombadil.infradead.org>
 <alpine.LRH.2.02.1804201704580.25408@file01.intranet.prod.int.rdu2.redhat.com> <20180421144757.GC14610@bombadil.infradead.org> <alpine.LRH.2.02.1804221733520.7995@file01.intranet.prod.int.rdu2.redhat.com> <20180423151545.GU17484@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Matthew Wilcox <willy@infradead.org>, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, eric.dumazet@gmail.com, edumazet@google.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, mst@redhat.com, jasowang@redhat.com, virtualization@lists.linux-foundation.org, dm-devel@redhat.com, Vlastimil Babka <vbabka@suse.cz>

The kvmalloc function tries to use kmalloc and falls back to vmalloc if
kmalloc fails.

Unfortunatelly, some kernel code has bugs - it uses kvmalloc and then
uses DMA-API on the returned memory or frees it with kfree. Such bugs were
found in the virtio-net driver, dm-integrity or RHEL7 powerpc-specific
code.

These bugs are hard to reproduce because kvmalloc falls back to vmalloc
only if memory is fragmented.

In order to detect these bugs reliably I submit this patch that changes
kvmalloc to fall back to vmalloc with 1/2 probability if CONFIG_DEBUG_SG
is turned on. CONFIG_DEBUG_SG is used, because it makes the DMA API layer
verify the addresses passed to it, and so the user will get a reliable
stacktrace.

Some bugs (such as buffer overflows) are better detected
with kmalloc code, so we must test the kmalloc path too.

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>

---
 mm/util.c |   10 ++++++++++
 1 file changed, 10 insertions(+)

Index: linux-2.6/mm/util.c
===================================================================
--- linux-2.6.orig/mm/util.c	2018-04-23 00:12:05.000000000 +0200
+++ linux-2.6/mm/util.c	2018-04-23 17:57:02.000000000 +0200
@@ -14,6 +14,7 @@
 #include <linux/hugetlb.h>
 #include <linux/vmalloc.h>
 #include <linux/userfaultfd_k.h>
+#include <linux/random.h>
 
 #include <asm/sections.h>
 #include <linux/uaccess.h>
@@ -404,6 +405,12 @@ void *kvmalloc_node(size_t size, gfp_t f
 	 */
 	WARN_ON_ONCE((flags & GFP_KERNEL) != GFP_KERNEL);
 
+#ifdef CONFIG_DEBUG_SG
+	/* Catch bugs when the caller uses DMA API on the result of kvmalloc. */
+	if (!(prandom_u32_max(2) & 1))
+		goto do_vmalloc;
+#endif
+
 	/*
 	 * We want to attempt a large physically contiguous block first because
 	 * it is less likely to fragment multiple larger blocks and therefore
@@ -427,6 +434,9 @@ void *kvmalloc_node(size_t size, gfp_t f
 	if (ret || size <= PAGE_SIZE)
 		return ret;
 
+#ifdef CONFIG_DEBUG_SG
+do_vmalloc:
+#endif
 	return __vmalloc_node_flags_caller(size, node, flags,
 			__builtin_return_address(0));
 }
