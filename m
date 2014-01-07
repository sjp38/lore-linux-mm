Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 738A36B0031
	for <linux-mm@kvack.org>; Tue,  7 Jan 2014 03:49:01 -0500 (EST)
Received: by mail-pd0-f178.google.com with SMTP id y10so92622pdj.37
        for <linux-mm@kvack.org>; Tue, 07 Jan 2014 00:49:01 -0800 (PST)
Received: from e23smtp05.au.ibm.com (e23smtp05.au.ibm.com. [202.81.31.147])
        by mx.google.com with ESMTPS id sz7si56099851pab.232.2014.01.07.00.48.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 07 Jan 2014 00:48:59 -0800 (PST)
Received: from /spool/local
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 7 Jan 2014 18:48:56 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id E85A43578052
	for <linux-mm@kvack.org>; Tue,  7 Jan 2014 19:48:52 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s078mUMx459244
	for <linux-mm@kvack.org>; Tue, 7 Jan 2014 19:48:40 +1100
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s078mgtD008689
	for <linux-mm@kvack.org>; Tue, 7 Jan 2014 19:48:42 +1100
Date: Tue, 7 Jan 2014 16:48:40 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH] slub: Don't throw away partial remote slabs if there is
 no local memory
Message-ID: <52cbbf7b.2792420a.571c.ffffd476SMTPIN_ADDED_BROKEN@mx.google.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <20140107132100.5b5ad198@kryten>
 <20140107074136.GA4011@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140107074136.GA4011@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Anton Blanchard <anton@samba.org>, benh@kernel.crashing.org, paulus@samba.org, cl@linux-foundation.org, penberg@kernel.org, mpm@selenic.com, nacc@linux.vnet.ibm.com, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

Hi Joonsoo,
On Tue, Jan 07, 2014 at 04:41:36PM +0900, Joonsoo Kim wrote:
>On Tue, Jan 07, 2014 at 01:21:00PM +1100, Anton Blanchard wrote:
>> 
[...]
>Hello,
>
>I think that we need more efforts to solve unbalanced node problem.
>
>With this patch, even if node of current cpu slab is not favorable to
>unbalanced node, allocation would proceed and we would get the unintended memory.
>

We have a machine:

[    0.000000] Node 0 Memory:
[    0.000000] Node 4 Memory: 0x0-0x10000000 0x20000000-0x60000000 0x80000000-0xc0000000
[    0.000000] Node 6 Memory: 0x10000000-0x20000000 0x60000000-0x80000000
[    0.000000] Node 10 Memory: 0xc0000000-0x180000000

[    0.041486] Node 0 CPUs: 0-19
[    0.041490] Node 4 CPUs:
[    0.041492] Node 6 CPUs:
[    0.041495] Node 10 CPUs:

The pages of current cpu slab should be allocated from fallback zones/nodes 
of the memoryless node in buddy system, how can not favorable happen? 

>And there is one more problem. Even if we have some partial slabs on
>compatible node, we would allocate new slab, because get_partial() cannot handle
>this unbalance node case.
>
>To fix this correctly, how about following patch?
>

So I think we should fold both of your two patches to one.

Regards,
Wanpeng Li 

>Thanks.
>
>------------->8--------------------
>diff --git a/mm/slub.c b/mm/slub.c
>index c3eb3d3..a1f6dfa 100644
>--- a/mm/slub.c
>+++ b/mm/slub.c
>@@ -1672,7 +1672,19 @@ static void *get_partial(struct kmem_cache *s, gfp_t flags, int node,
> {
>        void *object;
>        int searchnode = (node == NUMA_NO_NODE) ? numa_node_id() : node;
>+       struct zonelist *zonelist;
>+       struct zoneref *z;
>+       struct zone *zone;
>+       enum zone_type high_zoneidx = gfp_zone(flags);
>
>+       if (!node_present_pages(searchnode)) {
>+               zonelist = node_zonelist(searchnode, flags);
>+               for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
>+                       searchnode = zone_to_nid(zone);
>+                       if (node_present_pages(searchnode))
>+                               break;
>+               }
>+       }
>        object = get_partial_node(s, get_node(s, searchnode), c, flags);
>        if (object || node != NUMA_NO_NODE)
>                return object;
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
