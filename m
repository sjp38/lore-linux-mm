Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id 6AE7F6B0031
	for <linux-mm@kvack.org>; Mon, 27 Jan 2014 00:58:09 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id up15so5474956pbc.14
        for <linux-mm@kvack.org>; Sun, 26 Jan 2014 21:58:08 -0800 (PST)
Received: from LGEMRELSE6Q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id to9si9976530pbc.125.2014.01.26.21.58.06
        for <linux-mm@kvack.org>;
        Sun, 26 Jan 2014 21:58:07 -0800 (PST)
Date: Mon, 27 Jan 2014 14:58:05 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH] slub: Don't throw away partial remote slabs if there is
 no local memory
Message-ID: <20140127055805.GA2471@lge.com>
References: <alpine.DEB.2.10.1401201612340.28048@nuc>
 <52e1d960.2715420a.3569.1013SMTPIN_ADDED_BROKEN@mx.google.com>
 <52e1da8f.86f7440a.120f.25f3SMTPIN_ADDED_BROKEN@mx.google.com>
 <alpine.DEB.2.10.1401240946530.12886@nuc>
 <alpine.DEB.2.02.1401241301120.10968@chino.kir.corp.google.com>
 <20140124232902.GB30361@linux.vnet.ibm.com>
 <alpine.DEB.2.02.1401241543100.18620@chino.kir.corp.google.com>
 <20140125001643.GA25344@linux.vnet.ibm.com>
 <alpine.DEB.2.02.1401241618500.20466@chino.kir.corp.google.com>
 <20140125011041.GB25344@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140125011041.GB25344@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Cc: David Rientjes <rientjes@google.com>, Han Pingtian <hanpt@linux.vnet.ibm.com>, penberg@kernel.org, linux-mm@kvack.org, paulus@samba.org, Anton Blanchard <anton@samba.org>, mpm@selenic.com, Christoph Lameter <cl@linux.com>, linuxppc-dev@lists.ozlabs.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

On Fri, Jan 24, 2014 at 05:10:42PM -0800, Nishanth Aravamudan wrote:
> On 24.01.2014 [16:25:58 -0800], David Rientjes wrote:
> > On Fri, 24 Jan 2014, Nishanth Aravamudan wrote:
> > 
> > > Thank you for clarifying and providing  a test patch. I ran with this on
> > > the system showing the original problem, configured to have 15GB of
> > > memory.
> > > 
> > > With your patch after boot:
> > > 
> > > MemTotal:       15604736 kB
> > > MemFree:         8768192 kB
> > > Slab:            3882560 kB
> > > SReclaimable:     105408 kB
> > > SUnreclaim:      3777152 kB
> > > 
> > > With Anton's patch after boot:
> > > 
> > > MemTotal:       15604736 kB
> > > MemFree:        11195008 kB
> > > Slab:            1427968 kB
> > > SReclaimable:     109184 kB
> > > SUnreclaim:      1318784 kB
> > > 
> > > 
> > > I know that's fairly unscientific, but the numbers are reproducible. 
> > > 

Hello,

I think that there is one mistake on David's patch although I'm not sure
that it is the reason for this result.

With David's patch, get_partial() in new_slab_objects() doesn't work properly,
because we only change node id in !node_match() case. If we meet just !freelist
case, we pass node id directly to new_slab_objects(), so we always try to allocate
new slab page regardless existence of partial pages. We should solve it.

Could you try this one?

Thanks.

--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1698,8 +1698,10 @@ static void *get_partial(struct kmem_cache *s, gfp_t flags, int node,
                struct kmem_cache_cpu *c)
 {
        void *object;
-       int searchnode = (node == NUMA_NO_NODE) ? numa_node_id() : node;
+       int searchnode = (node == NUMA_NO_NODE) ? numa_mem_id() : node;
 
+       if (node != NUMA_NO_NODE && !node_present_pages(node))
+               searchnode = numa_mem_id();
        object = get_partial_node(s, get_node(s, searchnode), c, flags);
        if (object || node != NUMA_NO_NODE)
                return object;
@@ -2278,10 +2280,14 @@ redo:
 
        if (unlikely(!node_match(page, node))) {
                stat(s, ALLOC_NODE_MISMATCH);
-               deactivate_slab(s, page, c->freelist);
-               c->page = NULL;
-               c->freelist = NULL;
-               goto new_slab;
+               if (unlikely(!node_present_pages(node)))
+                       node = numa_mem_id();
+               if (!node_match(page, node)) {
+                       deactivate_slab(s, page, c->freelist);
+                       c->page = NULL;
+                       c->freelist = NULL;
+                       goto new_slab;
+               }
        }
 
        /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
