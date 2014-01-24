Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f50.google.com (mail-bk0-f50.google.com [209.85.214.50])
	by kanga.kvack.org (Postfix) with ESMTP id C70796B0031
	for <linux-mm@kvack.org>; Fri, 24 Jan 2014 18:49:40 -0500 (EST)
Received: by mail-bk0-f50.google.com with SMTP id w16so1592865bkz.9
        for <linux-mm@kvack.org>; Fri, 24 Jan 2014 15:49:40 -0800 (PST)
Received: from mail-bk0-x234.google.com (mail-bk0-x234.google.com [2a00:1450:4008:c01::234])
        by mx.google.com with ESMTPS id qg10si4769016bkb.79.2014.01.24.15.49.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 24 Jan 2014 15:49:39 -0800 (PST)
Received: by mail-bk0-f52.google.com with SMTP id e11so1583378bkh.39
        for <linux-mm@kvack.org>; Fri, 24 Jan 2014 15:49:39 -0800 (PST)
Date: Fri, 24 Jan 2014 15:49:33 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] slub: Don't throw away partial remote slabs if there is
 no local memory
In-Reply-To: <20140124232902.GB30361@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.02.1401241543100.18620@chino.kir.corp.google.com>
References: <20140107132100.5b5ad198@kryten> <20140107074136.GA4011@lge.com> <52dce7fe.e5e6420a.5ff6.ffff84a0SMTPIN_ADDED_BROKEN@mx.google.com> <alpine.DEB.2.10.1401201612340.28048@nuc> <52e1d960.2715420a.3569.1013SMTPIN_ADDED_BROKEN@mx.google.com>
 <52e1da8f.86f7440a.120f.25f3SMTPIN_ADDED_BROKEN@mx.google.com> <alpine.DEB.2.10.1401240946530.12886@nuc> <alpine.DEB.2.02.1401241301120.10968@chino.kir.corp.google.com> <20140124232902.GB30361@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Cc: Christoph Lameter <cl@linux.com>, penberg@kernel.org, linux-mm@kvack.org, Han Pingtian <hanpt@linux.vnet.ibm.com>, paulus@samba.org, Anton Blanchard <anton@samba.org>, mpm@selenic.com, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linuxppc-dev@lists.ozlabs.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

On Fri, 24 Jan 2014, Nishanth Aravamudan wrote:

> > I think the problem is a memoryless node being used for kmalloc_node() so 
> > we need to decide where to enforce node_present_pages().  __slab_alloc() 
> > seems like the best candidate when !node_match().
> 
> Actually, this is effectively what Anton's patch does, except with
> Wanpeng's adjustment to use node_present_pages(). Does that seem
> sufficient to you?
> 

I don't see that as being the effect of Anton's patch.  We need to use 
numa_mem_id() as Christoph mentioned when a memoryless node is passed for 
the best NUMA locality.  Something like this:

diff --git a/mm/slub.c b/mm/slub.c
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2278,10 +2278,14 @@ redo:
 
 	if (unlikely(!node_match(page, node))) {
 		stat(s, ALLOC_NODE_MISMATCH);
-		deactivate_slab(s, page, c->freelist);
-		c->page = NULL;
-		c->freelist = NULL;
-		goto new_slab;
+		if (unlikely(!node_present_pages(node)))
+			node = numa_mem_id();
+		if (!node_match(page, node)) {
+			deactivate_slab(s, page, c->freelist);
+			c->page = NULL;
+			c->freelist = NULL;
+			goto new_slab;
+		}
 	}
 
 	/*

> It does only cover the memoryless node case (not the exhausted node
> case), but I think that shouldn't block the fix (and it does fix the
> issue we've run across in our testing).
> 

kmalloc_node(nid) and kmem_cache_alloc_node(nid) should fallback to nodes 
other than nid when memory can't be allocated, these functions only 
indicate a preference.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
