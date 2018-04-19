Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 023D46B0006
	for <linux-mm@kvack.org>; Thu, 19 Apr 2018 17:27:08 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id u8so4424524qkg.15
        for <linux-mm@kvack.org>; Thu, 19 Apr 2018 14:27:07 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id t8si1209560qke.46.2018.04.19.14.27.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Apr 2018 14:27:07 -0700 (PDT)
Date: Thu, 19 Apr 2018 17:27:06 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: [PATCH] kvmalloc: always use vmalloc if CONFIG_DEBUG_SG
In-Reply-To: <20180419193554-mutt-send-email-mst@kernel.org>
Message-ID: <alpine.LRH.2.02.1804191719400.10099@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1804181029270.19294@file01.intranet.prod.int.rdu2.redhat.com> <3e65977e-53cd-bf09-bc4b-0ce40e9091fe@gmail.com> <alpine.LRH.2.02.1804181218270.19136@file01.intranet.prod.int.rdu2.redhat.com> <20180418.134651.2225112489265654270.davem@davemloft.net>
 <alpine.LRH.2.02.1804181350050.17942@file01.intranet.prod.int.rdu2.redhat.com> <alpine.LRH.2.02.1804191207380.31175@file01.intranet.prod.int.rdu2.redhat.com> <20180419193554-mutt-send-email-mst@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, eric.dumazet@gmail.com, edumazet@google.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, jasowang@redhat.com, virtualization@lists.linux-foundation.org, dm-devel@redhat.com, Vlastimil Babka <vbabka@suse.cz>



On Thu, 19 Apr 2018, Michael S. Tsirkin wrote:

> Maybe make it conditional on CONFIG_DEBUG_SG too?
> Otherwise I think you just trigger a hard to debug memory corruption.

OK, here I resend the patch with CONFIG_DEBUG_SG. With CONFIG_DEBUG_SG, 
the DMA API will print a stacktrace where the misuse happened, so it's 
much easier to debug than with CONFIG_DEBUG_VM.

Fedora doesn't use CONFIG_DEBUG_SG in its default kernel (it only uses it 
in the debugging kernel), so users won't be hurt by this.



From: Mikulas Patocka <mpatocka@redhat.com>
Subject: [PATCH] kvmalloc: always use vmalloc if CONFIG_DEBUG_SG

The kvmalloc function tries to use kmalloc and falls back to vmalloc if
kmalloc fails.

Unfortunatelly, some kernel code has bugs - it uses kvmalloc and then
uses DMA-API on the returned memory or frees it with kfree. Such bugs were
found in the virtio-net driver, dm-integrity or RHEL7 powerpc-specific
code.

These bugs are hard to reproduce because vmalloc falls back to kmalloc
only if memory is fragmented.

In order to detect these bugs reliably I submit this patch that changes
kvmalloc to always use vmalloc if CONFIG_DEBUG_SG is turned on.

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>

---
 mm/util.c |    2 ++
 1 file changed, 2 insertions(+)

Index: linux-2.6/mm/util.c
===================================================================
--- linux-2.6.orig/mm/util.c	2018-04-18 15:46:23.000000000 +0200
+++ linux-2.6/mm/util.c	2018-04-19 23:14:14.000000000 +0200
@@ -395,6 +395,7 @@ EXPORT_SYMBOL(vm_mmap);
  */
 void *kvmalloc_node(size_t size, gfp_t flags, int node)
 {
+#ifndef CONFIG_DEBUG_SG
 	gfp_t kmalloc_flags = flags;
 	void *ret;
 
@@ -426,6 +427,7 @@ void *kvmalloc_node(size_t size, gfp_t f
 	 */
 	if (ret || size <= PAGE_SIZE)
 		return ret;
+#endif
 
 	return __vmalloc_node_flags_caller(size, node, flags,
 			__builtin_return_address(0));
