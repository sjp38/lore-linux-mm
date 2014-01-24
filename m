Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f49.google.com (mail-bk0-f49.google.com [209.85.214.49])
	by kanga.kvack.org (Postfix) with ESMTP id E03B36B0031
	for <linux-mm@kvack.org>; Fri, 24 Jan 2014 16:03:20 -0500 (EST)
Received: by mail-bk0-f49.google.com with SMTP id v15so1462250bkz.8
        for <linux-mm@kvack.org>; Fri, 24 Jan 2014 13:03:20 -0800 (PST)
Received: from mail-bk0-x232.google.com (mail-bk0-x232.google.com [2a00:1450:4008:c01::232])
        by mx.google.com with ESMTPS id q2si4329155bkr.347.2014.01.24.13.03.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 24 Jan 2014 13:03:19 -0800 (PST)
Received: by mail-bk0-f50.google.com with SMTP id w16so1473164bkz.23
        for <linux-mm@kvack.org>; Fri, 24 Jan 2014 13:03:19 -0800 (PST)
Date: Fri, 24 Jan 2014 13:03:13 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] slub: Don't throw away partial remote slabs if there is
 no local memory
In-Reply-To: <alpine.DEB.2.10.1401240946530.12886@nuc>
Message-ID: <alpine.DEB.2.02.1401241301120.10968@chino.kir.corp.google.com>
References: <20140107132100.5b5ad198@kryten> <20140107074136.GA4011@lge.com> <52dce7fe.e5e6420a.5ff6.ffff84a0SMTPIN_ADDED_BROKEN@mx.google.com> <alpine.DEB.2.10.1401201612340.28048@nuc> <52e1d960.2715420a.3569.1013SMTPIN_ADDED_BROKEN@mx.google.com>
 <52e1da8f.86f7440a.120f.25f3SMTPIN_ADDED_BROKEN@mx.google.com> <alpine.DEB.2.10.1401240946530.12886@nuc>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Wanpeng Li <liwanp@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, benh@kernel.crashing.org, paulus@samba.org, penberg@kernel.org, mpm@selenic.com, nacc@linux.vnet.ibm.com, Anton Blanchard <anton@samba.org>, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, Han Pingtian <hanpt@linux.vnet.ibm.com>

On Fri, 24 Jan 2014, Christoph Lameter wrote:

> On Fri, 24 Jan 2014, Wanpeng Li wrote:
> 
> > >
> > >diff --git a/mm/slub.c b/mm/slub.c
> > >index 545a170..a1c6040 100644
> > >--- a/mm/slub.c
> > >+++ b/mm/slub.c
> > >@@ -1700,6 +1700,9 @@ static void *get_partial(struct kmem_cache *s, gfp_t flags, int node,
> > > 	void *object;
> > >	int searchnode = (node == NUMA_NO_NODE) ? numa_node_id() : node;
> 
> This needs to be numa_mem_id() and numa_mem_id would need to be
> consistently used.
> 
> > >
> > >+	if (!node_present_pages(searchnode))
> > >+		searchnode = numa_mem_id();
> 
> Probably wont need that?
> 

I think the problem is a memoryless node being used for kmalloc_node() so 
we need to decide where to enforce node_present_pages().  __slab_alloc() 
seems like the best candidate when !node_match().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
