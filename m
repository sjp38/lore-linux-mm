Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f177.google.com (mail-yk0-f177.google.com [209.85.160.177])
	by kanga.kvack.org (Postfix) with ESMTP id 2E0846B0031
	for <linux-mm@kvack.org>; Tue, 28 Jan 2014 13:29:58 -0500 (EST)
Received: by mail-yk0-f177.google.com with SMTP id 19so3331883ykq.8
        for <linux-mm@kvack.org>; Tue, 28 Jan 2014 10:29:57 -0800 (PST)
Received: from e39.co.us.ibm.com (e39.co.us.ibm.com. [32.97.110.160])
        by mx.google.com with ESMTPS id n38si12384949yhp.123.2014.01.28.10.29.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 28 Jan 2014 10:29:56 -0800 (PST)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Tue, 28 Jan 2014 11:29:55 -0700
Received: from b03cxnp07028.gho.boulder.ibm.com (b03cxnp07028.gho.boulder.ibm.com [9.17.130.15])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id D803819D8036
	for <linux-mm@kvack.org>; Tue, 28 Jan 2014 11:29:42 -0700 (MST)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by b03cxnp07028.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s0SITWtR10879370
	for <linux-mm@kvack.org>; Tue, 28 Jan 2014 19:29:32 +0100
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s0SITpk6008695
	for <linux-mm@kvack.org>; Tue, 28 Jan 2014 11:29:52 -0700
Date: Tue, 28 Jan 2014 10:29:47 -0800
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: Re: [PATCH] slub: Don't throw away partial remote slabs if there is
 no local memory
Message-ID: <20140128182947.GA1591@linux.vnet.ibm.com>
References: <52e1d960.2715420a.3569.1013SMTPIN_ADDED_BROKEN@mx.google.com>
 <52e1da8f.86f7440a.120f.25f3SMTPIN_ADDED_BROKEN@mx.google.com>
 <alpine.DEB.2.10.1401240946530.12886@nuc>
 <alpine.DEB.2.02.1401241301120.10968@chino.kir.corp.google.com>
 <20140124232902.GB30361@linux.vnet.ibm.com>
 <alpine.DEB.2.02.1401241543100.18620@chino.kir.corp.google.com>
 <20140125001643.GA25344@linux.vnet.ibm.com>
 <alpine.DEB.2.02.1401241618500.20466@chino.kir.corp.google.com>
 <20140125011041.GB25344@linux.vnet.ibm.com>
 <20140127055805.GA2471@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140127055805.GA2471@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: David Rientjes <rientjes@google.com>, Han Pingtian <hanpt@linux.vnet.ibm.com>, penberg@kernel.org, linux-mm@kvack.org, paulus@samba.org, Anton Blanchard <anton@samba.org>, mpm@selenic.com, Christoph Lameter <cl@linux.com>, linuxppc-dev@lists.ozlabs.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

On 27.01.2014 [14:58:05 +0900], Joonsoo Kim wrote:
> On Fri, Jan 24, 2014 at 05:10:42PM -0800, Nishanth Aravamudan wrote:
> > On 24.01.2014 [16:25:58 -0800], David Rientjes wrote:
> > > On Fri, 24 Jan 2014, Nishanth Aravamudan wrote:
> > > 
> > > > Thank you for clarifying and providing  a test patch. I ran with this on
> > > > the system showing the original problem, configured to have 15GB of
> > > > memory.
> > > > 
> > > > With your patch after boot:
> > > > 
> > > > MemTotal:       15604736 kB
> > > > MemFree:         8768192 kB
> > > > Slab:            3882560 kB
> > > > SReclaimable:     105408 kB
> > > > SUnreclaim:      3777152 kB
> > > > 
> > > > With Anton's patch after boot:
> > > > 
> > > > MemTotal:       15604736 kB
> > > > MemFree:        11195008 kB
> > > > Slab:            1427968 kB
> > > > SReclaimable:     109184 kB
> > > > SUnreclaim:      1318784 kB
> > > > 
> > > > 
> > > > I know that's fairly unscientific, but the numbers are reproducible. 
> > > > 
> 
> Hello,
> 
> I think that there is one mistake on David's patch although I'm not sure
> that it is the reason for this result.
> 
> With David's patch, get_partial() in new_slab_objects() doesn't work
> properly, because we only change node id in !node_match() case. If we
> meet just !freelist case, we pass node id directly to
> new_slab_objects(), so we always try to allocate new slab page
> regardless existence of partial pages. We should solve it.
> 
> Could you try this one?

This helps about the same as David's patch -- but I found the reason
why! ppc64 doesn't set CONFIG_HAVE_MEMORYLESS_NODES :) Expect a patch
shortly for that and one other case I found.

This patch on its own seems to help on our test system by saving around
1.5GB of slab.

Tested-by: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Acked-by: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>

with the caveat below.

Thanks,
Nish

> 
> Thanks.
> 
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -1698,8 +1698,10 @@ static void *get_partial(struct kmem_cache *s, gfp_t flags, int node,
>                 struct kmem_cache_cpu *c)
>  {
>         void *object;
> -       int searchnode = (node == NUMA_NO_NODE) ? numa_node_id() : node;
> +       int searchnode = (node == NUMA_NO_NODE) ? numa_mem_id() : node;
> 
> +       if (node != NUMA_NO_NODE && !node_present_pages(node))
> +               searchnode = numa_mem_id();

This might be clearer as:

int searchnode = node;
if (node == NUMA_NO_NODE || !node_present_pages(node))
	searchnode = numa_mem_id();

>         object = get_partial_node(s, get_node(s, searchnode), c, flags);
>         if (object || node != NUMA_NO_NODE)
>                 return object;
> @@ -2278,10 +2280,14 @@ redo:
> 
>         if (unlikely(!node_match(page, node))) {
>                 stat(s, ALLOC_NODE_MISMATCH);
> -               deactivate_slab(s, page, c->freelist);
> -               c->page = NULL;
> -               c->freelist = NULL;
> -               goto new_slab;
> +               if (unlikely(!node_present_pages(node)))
> +                       node = numa_mem_id();
> +               if (!node_match(page, node)) {
> +                       deactivate_slab(s, page, c->freelist);
> +                       c->page = NULL;
> +                       c->freelist = NULL;
> +                       goto new_slab;
> +               }
>         }
> 
>         /*
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
