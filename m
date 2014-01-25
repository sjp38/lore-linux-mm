Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f170.google.com (mail-qc0-f170.google.com [209.85.216.170])
	by kanga.kvack.org (Postfix) with ESMTP id 8E33D6B0031
	for <linux-mm@kvack.org>; Fri, 24 Jan 2014 20:11:05 -0500 (EST)
Received: by mail-qc0-f170.google.com with SMTP id e9so5520090qcy.29
        for <linux-mm@kvack.org>; Fri, 24 Jan 2014 17:11:05 -0800 (PST)
Received: from e8.ny.us.ibm.com (e8.ny.us.ibm.com. [32.97.182.138])
        by mx.google.com with ESMTPS id w8si2197695qag.54.2014.01.24.17.11.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 24 Jan 2014 17:11:04 -0800 (PST)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Fri, 24 Jan 2014 20:11:03 -0500
Received: from b01cxnp22036.gho.pok.ibm.com (b01cxnp22036.gho.pok.ibm.com [9.57.198.26])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 3F7C76E804B
	for <linux-mm@kvack.org>; Fri, 24 Jan 2014 20:10:56 -0500 (EST)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by b01cxnp22036.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s0P1B02T50724916
	for <linux-mm@kvack.org>; Sat, 25 Jan 2014 01:11:00 GMT
Received: from d01av02.pok.ibm.com (localhost [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s0P1AxCa030060
	for <linux-mm@kvack.org>; Fri, 24 Jan 2014 20:10:59 -0500
Date: Fri, 24 Jan 2014 17:10:42 -0800
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: Re: [PATCH] slub: Don't throw away partial remote slabs if there is
 no local memory
Message-ID: <20140125011041.GB25344@linux.vnet.ibm.com>
References: <52dce7fe.e5e6420a.5ff6.ffff84a0SMTPIN_ADDED_BROKEN@mx.google.com>
 <alpine.DEB.2.10.1401201612340.28048@nuc>
 <52e1d960.2715420a.3569.1013SMTPIN_ADDED_BROKEN@mx.google.com>
 <52e1da8f.86f7440a.120f.25f3SMTPIN_ADDED_BROKEN@mx.google.com>
 <alpine.DEB.2.10.1401240946530.12886@nuc>
 <alpine.DEB.2.02.1401241301120.10968@chino.kir.corp.google.com>
 <20140124232902.GB30361@linux.vnet.ibm.com>
 <alpine.DEB.2.02.1401241543100.18620@chino.kir.corp.google.com>
 <20140125001643.GA25344@linux.vnet.ibm.com>
 <alpine.DEB.2.02.1401241618500.20466@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1401241618500.20466@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Han Pingtian <hanpt@linux.vnet.ibm.com>, penberg@kernel.org, linux-mm@kvack.org, paulus@samba.org, Anton Blanchard <anton@samba.org>, mpm@selenic.com, Christoph Lameter <cl@linux.com>, linuxppc-dev@lists.ozlabs.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>

On 24.01.2014 [16:25:58 -0800], David Rientjes wrote:
> On Fri, 24 Jan 2014, Nishanth Aravamudan wrote:
> 
> > Thank you for clarifying and providing  a test patch. I ran with this on
> > the system showing the original problem, configured to have 15GB of
> > memory.
> > 
> > With your patch after boot:
> > 
> > MemTotal:       15604736 kB
> > MemFree:         8768192 kB
> > Slab:            3882560 kB
> > SReclaimable:     105408 kB
> > SUnreclaim:      3777152 kB
> > 
> > With Anton's patch after boot:
> > 
> > MemTotal:       15604736 kB
> > MemFree:        11195008 kB
> > Slab:            1427968 kB
> > SReclaimable:     109184 kB
> > SUnreclaim:      1318784 kB
> > 
> > 
> > I know that's fairly unscientific, but the numbers are reproducible. 
> > 
> 
> I don't think the goal of the discussion is to reduce the amount of slab 
> allocated, but rather get the most local slab memory possible by use of 
> kmalloc_node().  When a memoryless node is being passed to kmalloc_node(), 
> which is probably cpu_to_node() for a cpu bound to a node without memory, 
> my patch is allocating it on the most local node; Anton's patch is 
> allocating it on whatever happened to be the cpu slab.

Well, the issue we're trying to resolve, based upon our analysis, is
that we're seeing incredibly inefficient slab usage with memoryless
nodes. To the point where we are OOM'ing a 8GB system without doing
anything in particularly stressful.

As to cpu_to_node() being passed to kmalloc_node(), I think an
appropriate fix is to change that to cpu_to_mem()?

> > > diff --git a/mm/slub.c b/mm/slub.c
> > > --- a/mm/slub.c
> > > +++ b/mm/slub.c
> > > @@ -2278,10 +2278,14 @@ redo:
> > > 
> > >  	if (unlikely(!node_match(page, node))) {
> > >  		stat(s, ALLOC_NODE_MISMATCH);
> > > -		deactivate_slab(s, page, c->freelist);
> > > -		c->page = NULL;
> > > -		c->freelist = NULL;
> > > -		goto new_slab;
> > > +		if (unlikely(!node_present_pages(node)))
> > > +			node = numa_mem_id();
> > > +		if (!node_match(page, node)) {
> > > +			deactivate_slab(s, page, c->freelist);
> > > +			c->page = NULL;
> > > +			c->freelist = NULL;
> > > +			goto new_slab;
> > > +		}
> > 
> > Semantically, and please correct me if I'm wrong, this patch is saying
> > if we have a memoryless node, we expect the page's locality to be that
> > of numa_mem_id(), and we still deactivate the slab if that isn't true.
> > Just wanting to make sure I understand the intent.
> > 
> 
> Yeah, the default policy should be to fallback to local memory if the node 
> passed is memoryless.

Thanks!

> > What I find odd is that there are only 2 nodes on this system, node 0
> > (empty) and node 1. So won't numa_mem_id() always be 1? And every page
> > should be coming from node 1 (thus node_match() should always be true?)
> > 
> 
> The nice thing about slub is its debugging ability, what is 
> /sys/kernel/slab/cache/objects showing in comparison between the two 
> patches?

Do you mean kmem_cache or kmem_cache_node?

-Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
