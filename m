Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f47.google.com (mail-oa0-f47.google.com [209.85.219.47])
	by kanga.kvack.org (Postfix) with ESMTP id AC8AA6B0031
	for <linux-mm@kvack.org>; Fri, 24 Jan 2014 19:17:08 -0500 (EST)
Received: by mail-oa0-f47.google.com with SMTP id m1so4533011oag.20
        for <linux-mm@kvack.org>; Fri, 24 Jan 2014 16:17:08 -0800 (PST)
Received: from e39.co.us.ibm.com (e39.co.us.ibm.com. [32.97.110.160])
        by mx.google.com with ESMTPS id tk7si537257obc.81.2014.01.24.16.17.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 24 Jan 2014 16:17:07 -0800 (PST)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Fri, 24 Jan 2014 17:17:06 -0700
Received: from b01cxnp22035.gho.pok.ibm.com (b01cxnp22035.gho.pok.ibm.com [9.57.198.25])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id A9C7E6E803A
	for <linux-mm@kvack.org>; Fri, 24 Jan 2014 19:16:58 -0500 (EST)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by b01cxnp22035.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s0P0H26i64684154
	for <linux-mm@kvack.org>; Sat, 25 Jan 2014 00:17:02 GMT
Received: from d01av04.pok.ibm.com (localhost [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s0P0H1iK028077
	for <linux-mm@kvack.org>; Fri, 24 Jan 2014 19:17:02 -0500
Date: Fri, 24 Jan 2014 16:16:43 -0800
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: Re: [PATCH] slub: Don't throw away partial remote slabs if there is
 no local memory
Message-ID: <20140125001643.GA25344@linux.vnet.ibm.com>
References: <20140107132100.5b5ad198@kryten>
 <20140107074136.GA4011@lge.com>
 <52dce7fe.e5e6420a.5ff6.ffff84a0SMTPIN_ADDED_BROKEN@mx.google.com>
 <alpine.DEB.2.10.1401201612340.28048@nuc>
 <52e1d960.2715420a.3569.1013SMTPIN_ADDED_BROKEN@mx.google.com>
 <52e1da8f.86f7440a.120f.25f3SMTPIN_ADDED_BROKEN@mx.google.com>
 <alpine.DEB.2.10.1401240946530.12886@nuc>
 <alpine.DEB.2.02.1401241301120.10968@chino.kir.corp.google.com>
 <20140124232902.GB30361@linux.vnet.ibm.com>
 <alpine.DEB.2.02.1401241543100.18620@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1401241543100.18620@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Han Pingtian <hanpt@linux.vnet.ibm.com>, penberg@kernel.org, linux-mm@kvack.org, paulus@samba.org, Anton Blanchard <anton@samba.org>, mpm@selenic.com, Christoph Lameter <cl@linux.com>, linuxppc-dev@lists.ozlabs.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>

On 24.01.2014 [15:49:33 -0800], David Rientjes wrote:
> On Fri, 24 Jan 2014, Nishanth Aravamudan wrote:
> 
> > > I think the problem is a memoryless node being used for kmalloc_node() so 
> > > we need to decide where to enforce node_present_pages().  __slab_alloc() 
> > > seems like the best candidate when !node_match().
> > 
> > Actually, this is effectively what Anton's patch does, except with
> > Wanpeng's adjustment to use node_present_pages(). Does that seem
> > sufficient to you?
> > 
> 
> I don't see that as being the effect of Anton's patch.  We need to use 
> numa_mem_id() as Christoph mentioned when a memoryless node is passed for 
> the best NUMA locality.  Something like this:

Thank you for clarifying and providing  a test patch. I ran with this on
the system showing the original problem, configured to have 15GB of
memory.

With your patch after boot:

MemTotal:       15604736 kB
MemFree:         8768192 kB
Slab:            3882560 kB
SReclaimable:     105408 kB
SUnreclaim:      3777152 kB

With Anton's patch after boot:

MemTotal:       15604736 kB
MemFree:        11195008 kB
Slab:            1427968 kB
SReclaimable:     109184 kB
SUnreclaim:      1318784 kB


I know that's fairly unscientific, but the numbers are reproducible. 

For what it's worth, a sample of the unmodified numbers:

MemTotal:       15317632 kB
MemFree:         5023424 kB
Slab:            7176064 kB
SReclaimable:     106816 kB
SUnreclaim:      7069248 kB

So it's an improvement, but something is still causing us to (it seems)
be pretty inefficient with the slabs.


> diff --git a/mm/slub.c b/mm/slub.c
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -2278,10 +2278,14 @@ redo:
> 
>  	if (unlikely(!node_match(page, node))) {
>  		stat(s, ALLOC_NODE_MISMATCH);
> -		deactivate_slab(s, page, c->freelist);
> -		c->page = NULL;
> -		c->freelist = NULL;
> -		goto new_slab;
> +		if (unlikely(!node_present_pages(node)))
> +			node = numa_mem_id();
> +		if (!node_match(page, node)) {
> +			deactivate_slab(s, page, c->freelist);
> +			c->page = NULL;
> +			c->freelist = NULL;
> +			goto new_slab;
> +		}

Semantically, and please correct me if I'm wrong, this patch is saying
if we have a memoryless node, we expect the page's locality to be that
of numa_mem_id(), and we still deactivate the slab if that isn't true.
Just wanting to make sure I understand the intent.

What I find odd is that there are only 2 nodes on this system, node 0
(empty) and node 1. So won't numa_mem_id() always be 1? And every page
should be coming from node 1 (thus node_match() should always be true?)

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
