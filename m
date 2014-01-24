Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f175.google.com (mail-ob0-f175.google.com [209.85.214.175])
	by kanga.kvack.org (Postfix) with ESMTP id B24716B0031
	for <linux-mm@kvack.org>; Fri, 24 Jan 2014 17:20:05 -0500 (EST)
Received: by mail-ob0-f175.google.com with SMTP id wn1so4252540obc.34
        for <linux-mm@kvack.org>; Fri, 24 Jan 2014 14:20:05 -0800 (PST)
Received: from e36.co.us.ibm.com (e36.co.us.ibm.com. [32.97.110.154])
        by mx.google.com with ESMTPS id co8si1252511oec.21.2014.01.24.14.20.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 24 Jan 2014 14:20:04 -0800 (PST)
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Fri, 24 Jan 2014 15:20:03 -0700
Received: from b03cxnp07028.gho.boulder.ibm.com (b03cxnp07028.gho.boulder.ibm.com [9.17.130.15])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 828D21FF001B
	for <linux-mm@kvack.org>; Fri, 24 Jan 2014 15:19:28 -0700 (MST)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by b03cxnp07028.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s0OMJgoj1835382
	for <linux-mm@kvack.org>; Fri, 24 Jan 2014 23:19:42 +0100
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s0OMK0gg023080
	for <linux-mm@kvack.org>; Fri, 24 Jan 2014 15:20:01 -0700
Date: Fri, 24 Jan 2014 14:19:42 -0800
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: Re: [PATCH] slub: Don't throw away partial remote slabs if there is
 no local memory
Message-ID: <20140124221942.GA30361@linux.vnet.ibm.com>
References: <20140107132100.5b5ad198@kryten>
 <20140107074136.GA4011@lge.com>
 <52dce7fe.e5e6420a.5ff6.ffff84a0SMTPIN_ADDED_BROKEN@mx.google.com>
 <alpine.DEB.2.10.1401201612340.28048@nuc>
 <52e1d960.2715420a.3569.1013SMTPIN_ADDED_BROKEN@mx.google.com>
 <52e1da8f.86f7440a.120f.25f3SMTPIN_ADDED_BROKEN@mx.google.com>
 <alpine.DEB.2.10.1401240946530.12886@nuc>
 <alpine.DEB.2.02.1401241301120.10968@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1401241301120.10968@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Christoph Lameter <cl@linux.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, benh@kernel.crashing.org, paulus@samba.org, penberg@kernel.org, mpm@selenic.com, Anton Blanchard <anton@samba.org>, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, Han Pingtian <hanpt@linux.vnet.ibm.com>

On 24.01.2014 [13:03:13 -0800], David Rientjes wrote:
> On Fri, 24 Jan 2014, Christoph Lameter wrote:
> 
> > On Fri, 24 Jan 2014, Wanpeng Li wrote:
> > 
> > > >
> > > >diff --git a/mm/slub.c b/mm/slub.c
> > > >index 545a170..a1c6040 100644
> > > >--- a/mm/slub.c
> > > >+++ b/mm/slub.c
> > > >@@ -1700,6 +1700,9 @@ static void *get_partial(struct kmem_cache *s, gfp_t flags, int node,
> > > > 	void *object;
> > > >	int searchnode = (node == NUMA_NO_NODE) ? numa_node_id() : node;
> > 
> > This needs to be numa_mem_id() and numa_mem_id would need to be
> > consistently used.
> > 
> > > >
> > > >+	if (!node_present_pages(searchnode))
> > > >+		searchnode = numa_mem_id();
> > 
> > Probably wont need that?
> > 
> 
> I think the problem is a memoryless node being used for kmalloc_node() so 
> we need to decide where to enforce node_present_pages().  __slab_alloc() 
> seems like the best candidate when !node_match().
> 

Yep, I'm looking through callers and such right now and came to a
similar conclusion. I should have a patch soon.

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
