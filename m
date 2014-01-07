Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f178.google.com (mail-ob0-f178.google.com [209.85.214.178])
	by kanga.kvack.org (Postfix) with ESMTP id D6E916B0031
	for <linux-mm@kvack.org>; Tue,  7 Jan 2014 05:29:03 -0500 (EST)
Received: by mail-ob0-f178.google.com with SMTP id uz6so19886261obc.9
        for <linux-mm@kvack.org>; Tue, 07 Jan 2014 02:29:03 -0800 (PST)
Received: from e28smtp07.in.ibm.com (e28smtp07.in.ibm.com. [122.248.162.7])
        by mx.google.com with ESMTPS id ds9si58696893obc.125.2014.01.07.02.28.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 07 Jan 2014 02:29:02 -0800 (PST)
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 7 Jan 2014 15:58:35 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 67C351258053
	for <linux-mm@kvack.org>; Tue,  7 Jan 2014 15:59:56 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s07ASKKC51773504
	for <linux-mm@kvack.org>; Tue, 7 Jan 2014 15:58:20 +0530
Received: from d28av05.in.ibm.com (localhost [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s07ASQ7X028748
	for <linux-mm@kvack.org>; Tue, 7 Jan 2014 15:58:27 +0530
Date: Tue, 7 Jan 2014 18:28:25 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH] slub: Don't throw away partial remote slabs if there is
 no local memory
Message-ID: <52cbd6ee.09b5b60a.633e.ffffc915SMTPIN_ADDED_BROKEN@mx.google.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <20140107132100.5b5ad198@kryten>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140107132100.5b5ad198@kryten>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Blanchard <anton@samba.org>
Cc: benh@kernel.crashing.org, paulus@samba.org, cl@linux-foundation.org, penberg@kernel.org, mpm@selenic.com, nacc@linux.vnet.ibm.com, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andi Kleen <andi@firstfloor.org>

On Tue, Jan 07, 2014 at 01:21:00PM +1100, Anton Blanchard wrote:
>
>We noticed a huge amount of slab memory consumed on a large ppc64 box:
>
>Slab:            2094336 kB
>
>Almost 2GB. This box is not balanced and some nodes do not have local
>memory, causing slub to be very inefficient in its slab usage.
>
>Each time we call kmem_cache_alloc_node slub checks the per cpu slab,
>sees it isn't node local, deactivates it and tries to allocate a new
>slab. On empty nodes we will allocate a new remote slab and use the
>first slot, but as explained above when we get called a second time
>we will just deactivate that slab and retry.
>

Deactive cpu slab cache doesn't always mean free the slab cache to buddy system, 
maybe the slab cache will be putback to the remote node's partial list if there 
are objects still in used in this unbalance situation. In this case, the slub slow 
path can freeze the partial slab in remote node again. So why the slab cache is 
fragmented as below? 

Regards,
Wanpeng Li 

>As such we end up only using 1 entry in each slab:
>
>slab                    mem  objects
>                       used   active
>------------------------------------
>kmalloc-16384       1404 MB    4.90%
>task_struct          668 MB    2.90%
>kmalloc-128          193 MB    3.61%
>kmalloc-192          152 MB    5.23%
>kmalloc-8192          72 MB   23.40%
>kmalloc-16            64 MB    7.43%
>kmalloc-512           33 MB   22.41%
>
>The patch below checks that a node is not empty before deactivating a
>slab and trying to allocate it again. With this patch applied we now
>use about 352MB:
>
>Slab:             360192 kB
>
>And our efficiency is much better:
>
>slab                    mem  objects
>                       used   active
>------------------------------------
>kmalloc-16384         92 MB   74.27%
>task_struct           23 MB   83.46%
>idr_layer_cache       18 MB  100.00%
>pgtable-2^12          17 MB  100.00%
>kmalloc-65536         15 MB  100.00%
>inode_cache           14 MB  100.00%
>kmalloc-256           14 MB   97.81%
>kmalloc-8192          14 MB   85.71%
>
>Signed-off-by: Anton Blanchard <anton@samba.org>
>---
>
>Thoughts? It seems like we could hit a similar situation if a machine
>is balanced but we run out of memory on a single node.
>
>Index: b/mm/slub.c
>===================================================================
>--- a/mm/slub.c
>+++ b/mm/slub.c
>@@ -2278,10 +2278,17 @@ redo:
>
> 	if (unlikely(!node_match(page, node))) {
> 		stat(s, ALLOC_NODE_MISMATCH);
>-		deactivate_slab(s, page, c->freelist);
>-		c->page = NULL;
>-		c->freelist = NULL;
>-		goto new_slab;
>+
>+		/*
>+		 * If the node contains no memory there is no point in trying
>+		 * to allocate a new node local slab
>+		 */
>+		if (node_spanned_pages(node)) {
>+			deactivate_slab(s, page, c->freelist);
>+			c->page = NULL;
>+			c->freelist = NULL;
>+			goto new_slab;
>+		}
> 	}
>
> 	/*
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
