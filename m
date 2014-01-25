Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f42.google.com (mail-bk0-f42.google.com [209.85.214.42])
	by kanga.kvack.org (Postfix) with ESMTP id F370A6B0031
	for <linux-mm@kvack.org>; Fri, 24 Jan 2014 19:26:04 -0500 (EST)
Received: by mail-bk0-f42.google.com with SMTP id 6so1609910bkj.29
        for <linux-mm@kvack.org>; Fri, 24 Jan 2014 16:26:04 -0800 (PST)
Received: from mail-bk0-x231.google.com (mail-bk0-x231.google.com [2a00:1450:4008:c01::231])
        by mx.google.com with ESMTPS id ec9si4824592bkc.211.2014.01.24.16.26.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 24 Jan 2014 16:26:03 -0800 (PST)
Received: by mail-bk0-f49.google.com with SMTP id v15so1592162bkz.36
        for <linux-mm@kvack.org>; Fri, 24 Jan 2014 16:26:03 -0800 (PST)
Date: Fri, 24 Jan 2014 16:25:58 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] slub: Don't throw away partial remote slabs if there is
 no local memory
In-Reply-To: <20140125001643.GA25344@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.02.1401241618500.20466@chino.kir.corp.google.com>
References: <20140107132100.5b5ad198@kryten> <20140107074136.GA4011@lge.com> <52dce7fe.e5e6420a.5ff6.ffff84a0SMTPIN_ADDED_BROKEN@mx.google.com> <alpine.DEB.2.10.1401201612340.28048@nuc> <52e1d960.2715420a.3569.1013SMTPIN_ADDED_BROKEN@mx.google.com>
 <52e1da8f.86f7440a.120f.25f3SMTPIN_ADDED_BROKEN@mx.google.com> <alpine.DEB.2.10.1401240946530.12886@nuc> <alpine.DEB.2.02.1401241301120.10968@chino.kir.corp.google.com> <20140124232902.GB30361@linux.vnet.ibm.com> <alpine.DEB.2.02.1401241543100.18620@chino.kir.corp.google.com>
 <20140125001643.GA25344@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Cc: Han Pingtian <hanpt@linux.vnet.ibm.com>, penberg@kernel.org, linux-mm@kvack.org, paulus@samba.org, Anton Blanchard <anton@samba.org>, mpm@selenic.com, Christoph Lameter <cl@linux.com>, linuxppc-dev@lists.ozlabs.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>

On Fri, 24 Jan 2014, Nishanth Aravamudan wrote:

> Thank you for clarifying and providing  a test patch. I ran with this on
> the system showing the original problem, configured to have 15GB of
> memory.
> 
> With your patch after boot:
> 
> MemTotal:       15604736 kB
> MemFree:         8768192 kB
> Slab:            3882560 kB
> SReclaimable:     105408 kB
> SUnreclaim:      3777152 kB
> 
> With Anton's patch after boot:
> 
> MemTotal:       15604736 kB
> MemFree:        11195008 kB
> Slab:            1427968 kB
> SReclaimable:     109184 kB
> SUnreclaim:      1318784 kB
> 
> 
> I know that's fairly unscientific, but the numbers are reproducible. 
> 

I don't think the goal of the discussion is to reduce the amount of slab 
allocated, but rather get the most local slab memory possible by use of 
kmalloc_node().  When a memoryless node is being passed to kmalloc_node(), 
which is probably cpu_to_node() for a cpu bound to a node without memory, 
my patch is allocating it on the most local node; Anton's patch is 
allocating it on whatever happened to be the cpu slab.

> > diff --git a/mm/slub.c b/mm/slub.c
> > --- a/mm/slub.c
> > +++ b/mm/slub.c
> > @@ -2278,10 +2278,14 @@ redo:
> > 
> >  	if (unlikely(!node_match(page, node))) {
> >  		stat(s, ALLOC_NODE_MISMATCH);
> > -		deactivate_slab(s, page, c->freelist);
> > -		c->page = NULL;
> > -		c->freelist = NULL;
> > -		goto new_slab;
> > +		if (unlikely(!node_present_pages(node)))
> > +			node = numa_mem_id();
> > +		if (!node_match(page, node)) {
> > +			deactivate_slab(s, page, c->freelist);
> > +			c->page = NULL;
> > +			c->freelist = NULL;
> > +			goto new_slab;
> > +		}
> 
> Semantically, and please correct me if I'm wrong, this patch is saying
> if we have a memoryless node, we expect the page's locality to be that
> of numa_mem_id(), and we still deactivate the slab if that isn't true.
> Just wanting to make sure I understand the intent.
> 

Yeah, the default policy should be to fallback to local memory if the node 
passed is memoryless.

> What I find odd is that there are only 2 nodes on this system, node 0
> (empty) and node 1. So won't numa_mem_id() always be 1? And every page
> should be coming from node 1 (thus node_match() should always be true?)
> 

The nice thing about slub is its debugging ability, what is 
/sys/kernel/slab/cache/objects showing in comparison between the two 
patches?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
