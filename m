Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f45.google.com (mail-qe0-f45.google.com [209.85.128.45])
	by kanga.kvack.org (Postfix) with ESMTP id BA6F76B0035
	for <linux-mm@kvack.org>; Mon,  6 Jan 2014 21:21:06 -0500 (EST)
Received: by mail-qe0-f45.google.com with SMTP id 6so18986649qea.4
        for <linux-mm@kvack.org>; Mon, 06 Jan 2014 18:21:06 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [2402:b800:7003:1:1::1])
        by mx.google.com with ESMTPS id kc8si74137789qeb.27.2014.01.06.18.21.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Jan 2014 18:21:05 -0800 (PST)
Date: Tue, 7 Jan 2014 13:21:00 +1100
From: Anton Blanchard <anton@samba.org>
Subject: [PATCH] slub: Don't throw away partial remote slabs if there is no
 local memory
Message-ID: <20140107132100.5b5ad198@kryten>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org, cl@linux-foundation.org, penberg@kernel.org, mpm@selenic.com, nacc@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org


We noticed a huge amount of slab memory consumed on a large ppc64 box:

Slab:            2094336 kB

Almost 2GB. This box is not balanced and some nodes do not have local
memory, causing slub to be very inefficient in its slab usage.

Each time we call kmem_cache_alloc_node slub checks the per cpu slab,
sees it isn't node local, deactivates it and tries to allocate a new
slab. On empty nodes we will allocate a new remote slab and use the
first slot, but as explained above when we get called a second time
we will just deactivate that slab and retry.

As such we end up only using 1 entry in each slab:

slab                    mem  objects
                       used   active
------------------------------------
kmalloc-16384       1404 MB    4.90%
task_struct          668 MB    2.90%
kmalloc-128          193 MB    3.61%
kmalloc-192          152 MB    5.23%
kmalloc-8192          72 MB   23.40%
kmalloc-16            64 MB    7.43%
kmalloc-512           33 MB   22.41%

The patch below checks that a node is not empty before deactivating a
slab and trying to allocate it again. With this patch applied we now
use about 352MB:

Slab:             360192 kB

And our efficiency is much better:

slab                    mem  objects
                       used   active
------------------------------------
kmalloc-16384         92 MB   74.27%
task_struct           23 MB   83.46%
idr_layer_cache       18 MB  100.00%
pgtable-2^12          17 MB  100.00%
kmalloc-65536         15 MB  100.00%
inode_cache           14 MB  100.00%
kmalloc-256           14 MB   97.81%
kmalloc-8192          14 MB   85.71%

Signed-off-by: Anton Blanchard <anton@samba.org>
---

Thoughts? It seems like we could hit a similar situation if a machine
is balanced but we run out of memory on a single node.

Index: b/mm/slub.c
===================================================================
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2278,10 +2278,17 @@ redo:
 
 	if (unlikely(!node_match(page, node))) {
 		stat(s, ALLOC_NODE_MISMATCH);
-		deactivate_slab(s, page, c->freelist);
-		c->page = NULL;
-		c->freelist = NULL;
-		goto new_slab;
+
+		/*
+		 * If the node contains no memory there is no point in trying
+		 * to allocate a new node local slab
+		 */
+		if (node_spanned_pages(node)) {
+			deactivate_slab(s, page, c->freelist);
+			c->page = NULL;
+			c->freelist = NULL;
+			goto new_slab;
+		}
 	}
 
 	/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
