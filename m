Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp03.au.ibm.com (8.13.1/8.13.1) with ESMTP id m087BrWe007544
	for <linux-mm@kvack.org>; Tue, 8 Jan 2008 18:11:53 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m087CJP23723376
	for <linux-mm@kvack.org>; Tue, 8 Jan 2008 18:12:20 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m087C3Z1002908
	for <linux-mm@kvack.org>; Tue, 8 Jan 2008 18:12:03 +1100
Date: Tue, 8 Jan 2008 12:41:35 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [BUG]  at mm/slab.c:3320
Message-ID: <20080108071135.GC6615@skywalker>
References: <20071225140519.ef8457ff.akpm@linux-foundation.org> <20071227153235.GA6443@skywalker> <Pine.LNX.4.64.0712271130200.30555@schroedinger.engr.sgi.com> <20071228051959.GA6385@skywalker> <Pine.LNX.4.64.0801021227580.20331@schroedinger.engr.sgi.com> <20080103155046.GA7092@skywalker> <20080107102301.db52ab64.kamezawa.hiroyu@jp.fujitsu.com> <Pine.LNX.4.64.0801071008050.22642@schroedinger.engr.sgi.com> <20080108104016.4fa5a4f3.kamezawa.hiroyu@jp.fujitsu.com> <Pine.LNX.4.64.0801072131350.28725@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0801072131350.28725@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, nacc@us.ibm.com, lee.schermerhorn@hp.com, bob.picco@hp.com, mel@skynet.ie
List-ID: <linux-mm.kvack.org>

On Mon, Jan 07, 2008 at 09:38:51PM -0800, Christoph Lameter wrote:
> On Tue, 8 Jan 2008, KAMEZAWA Hiroyuki wrote:
> 
> > In usual alloc_pages() allocator, this is done by zonelist fallback.
> 
> Hmmm... __cache_alloc_node does:
> 
>     if (unlikely(!cachep->nodelists[nodeid])) {
>                 /* Node not bootstrapped yet */
>                 ptr = fallback_alloc(cachep, flags);
>                 goto out;
>         }
> 
> So kmalloc_node does the correct fallback.
> 
> Kmalloc does not fall back but relies on numa_node_id() referring to a 
> node that has ZONE_NORMAL memory. Sigh.
> 
> cache_alloc_refill:
> 
>         node = numa_node_id();
> 
>         check_irq_off();
>         ac = cpu_cache_get(cachep);
> retry:
>         batchcount = ac->batchcount;
>         if (!ac->touched && batchcount > BATCHREFILL_LIMIT) {
>                 /*
>                  * If there was little recent activity on this cache, then
>                  * perform only a partial refill.  Otherwise we could generate
>                  * refill bouncing.
>                  */
>                 batchcount = BATCHREFILL_LIMIT;
>         }
>         l3 = cachep->nodelists[node];
> 
> 	BUG_ON(ac->avail > 0 || !l3);
> 	^^^^ triggers
> 
> 
> > complicated ?
> 
> Hmm.. We could check for l3 == NULL and fail in that case? The 
> ___cache_alloc would fail and __do_cache_alloc would call 
> ___cache_alloc_node whicvh would provide the correct fallback.
> 
> Doesd this fix it?

Will test and get back to you. Waiting for the machine to be free.

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
