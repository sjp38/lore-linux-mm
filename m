Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 85FAC6B0003
	for <linux-mm@kvack.org>; Thu, 19 Apr 2018 12:12:41 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id a124so3745560qkb.19
        for <linux-mm@kvack.org>; Thu, 19 Apr 2018 09:12:41 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id c4-v6si5198566qtg.119.2018.04.19.09.12.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Apr 2018 09:12:40 -0700 (PDT)
Date: Thu, 19 Apr 2018 12:12:38 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: [PATCH] kvmalloc: always use vmalloc if CONFIG_DEBUG_VM
In-Reply-To: <alpine.LRH.2.02.1804181350050.17942@file01.intranet.prod.int.rdu2.redhat.com>
Message-ID: <alpine.LRH.2.02.1804191207380.31175@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1804181029270.19294@file01.intranet.prod.int.rdu2.redhat.com> <3e65977e-53cd-bf09-bc4b-0ce40e9091fe@gmail.com> <alpine.LRH.2.02.1804181218270.19136@file01.intranet.prod.int.rdu2.redhat.com> <20180418.134651.2225112489265654270.davem@davemloft.net>
 <alpine.LRH.2.02.1804181350050.17942@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: eric.dumazet@gmail.com, edumazet@google.com, bhutchings@solarflare.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, mst@redhat.com, jasowang@redhat.com, virtualization@lists.linux-foundation.org, dm-devel@redhat.com, Vlastimil Babka <vbabka@suse.cz>



On Wed, 18 Apr 2018, Mikulas Patocka wrote:

> 
> 
> On Wed, 18 Apr 2018, David Miller wrote:
> 
> > From: Mikulas Patocka <mpatocka@redhat.com>
> > Date: Wed, 18 Apr 2018 12:44:25 -0400 (EDT)
> > 
> > > The structure net_device is followed by arbitrary driver-specific data 
> > > (accessible with the function netdev_priv). And for virtio-net, these 
> > > driver-specific data must be in DMA memory.
> > 
> > And we are saying that this assumption is wrong and needs to be
> > corrected.
> 
> So, try to find all the networking drivers that to DMA to the private 
> area.
> 
> The problem here is that kvzalloc usually returns DMA-able area, but it 
> may return non-DMA area rarely, if the memory is too fragmented. So, we 
> are in a situation, where some networking drivers will randomly fail. Go 
> and find them.
> 
> Mikulas

Her I submit a patch that makes kvmalloc always use vmalloc if 
CONFIG_DEBUG_VM is defined.




From: Mikulas Patocka <mpatocka@redhat.com>
Subject: [PATCH] kvmalloc: always use vmalloc if CONFIG_DEBUG_VM

The kvmalloc function tries to use kmalloc and falls back to vmalloc if
kmalloc fails.

Unfortunatelly, some kernel code has bugs - it uses kvmalloc and then
uses DMA-API on the returned memory or frees it with kfree. Such bugs were
found in the virtio-net driver, dm-integrity or RHEL7 powerpc-specific
code.

These bugs are hard to reproduce because vmalloc falls back to kmalloc
only if memory is fragmented.

In order to detect these bugs reliably I submit this patch that changes
kvmalloc to always use vmalloc if CONFIG_DEBUG_VM is turned on.

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>

---
 mm/util.c |    2 ++
 1 file changed, 2 insertions(+)

Index: linux-2.6/mm/util.c
===================================================================
--- linux-2.6.orig/mm/util.c	2018-04-18 15:46:23.000000000 +0200
+++ linux-2.6/mm/util.c	2018-04-18 16:00:43.000000000 +0200
@@ -395,6 +395,7 @@ EXPORT_SYMBOL(vm_mmap);
  */
 void *kvmalloc_node(size_t size, gfp_t flags, int node)
 {
+#ifndef CONFIG_DEBUG_VM
 	gfp_t kmalloc_flags = flags;
 	void *ret;
 
@@ -426,6 +427,7 @@ void *kvmalloc_node(size_t size, gfp_t f
 	 */
 	if (ret || size <= PAGE_SIZE)
 		return ret;
+#endif
 
 	return __vmalloc_node_flags_caller(size, node, flags,
 			__builtin_return_address(0));
