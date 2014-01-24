Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f43.google.com (mail-oa0-f43.google.com [209.85.219.43])
	by kanga.kvack.org (Postfix) with ESMTP id 9CB4D6B0031
	for <linux-mm@kvack.org>; Fri, 24 Jan 2014 18:29:25 -0500 (EST)
Received: by mail-oa0-f43.google.com with SMTP id h16so4544126oag.30
        for <linux-mm@kvack.org>; Fri, 24 Jan 2014 15:29:25 -0800 (PST)
Received: from e31.co.us.ibm.com (e31.co.us.ibm.com. [32.97.110.149])
        by mx.google.com with ESMTPS id iz10si1310641obb.104.2014.01.24.15.29.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 24 Jan 2014 15:29:24 -0800 (PST)
Received: from /spool/local
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Fri, 24 Jan 2014 16:29:23 -0700
Received: from b03cxnp08025.gho.boulder.ibm.com (b03cxnp08025.gho.boulder.ibm.com [9.17.130.17])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 0E41A1FF0027
	for <linux-mm@kvack.org>; Fri, 24 Jan 2014 16:28:48 -0700 (MST)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by b03cxnp08025.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s0ONTKfV2490738
	for <linux-mm@kvack.org>; Sat, 25 Jan 2014 00:29:20 +0100
Received: from d03av02.boulder.ibm.com (localhost [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s0ONTK0d028531
	for <linux-mm@kvack.org>; Fri, 24 Jan 2014 16:29:20 -0700
Date: Fri, 24 Jan 2014 15:29:02 -0800
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: Re: [PATCH] slub: Don't throw away partial remote slabs if there is
 no local memory
Message-ID: <20140124232902.GB30361@linux.vnet.ibm.com>
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
Cc: Christoph Lameter <cl@linux.com>, penberg@kernel.org, linux-mm@kvack.org, Han Pingtian <hanpt@linux.vnet.ibm.com>, paulus@samba.org, Anton Blanchard <anton@samba.org>, mpm@selenic.com, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linuxppc-dev@lists.ozlabs.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

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

Actually, this is effectively what Anton's patch does, except with
Wanpeng's adjustment to use node_present_pages(). Does that seem
sufficient to you?

It does only cover the memoryless node case (not the exhausted node
case), but I think that shouldn't block the fix (and it does fix the
issue we've run across in our testing).

-Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
