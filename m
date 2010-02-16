Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id CE5EC6B007B
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 02:29:26 -0500 (EST)
Received: from wpaz21.hot.corp.google.com (wpaz21.hot.corp.google.com [172.24.198.85])
	by smtp-out.google.com with ESMTP id o1G7TNRv017619
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 23:29:23 -0800
Received: from pxi33 (pxi33.prod.google.com [10.243.27.33])
	by wpaz21.hot.corp.google.com with ESMTP id o1G7TLVo011652
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 23:29:22 -0800
Received: by pxi33 with SMTP id 33so3754780pxi.10
        for <linux-mm@kvack.org>; Mon, 15 Feb 2010 23:29:21 -0800 (PST)
Date: Mon, 15 Feb 2010 23:29:17 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm 8/9 v2] oom: avoid oom killer for lowmem
 allocations
In-Reply-To: <20100216142856.72F4.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1002152324140.7470@chino.kir.corp.google.com>
References: <20100216085706.c7af93e1.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1002151606320.14484@chino.kir.corp.google.com> <20100216142856.72F4.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 16 Feb 2010, KOSAKI Motohiro wrote:

> No current user? I don't think so.
> 
> 	int bio_integrity_prep(struct bio *bio)
> 	{
> 	(snip)
> 	        buf = kmalloc(len, GFP_NOIO | __GFP_NOFAIL | q->bounce_gfp);
> 
> and 
> 
> 	void blk_queue_bounce_limit(struct request_queue *q, u64 dma_mask)
> 	{
> 	(snip)
> 	        if (dma) {
> 	                init_emergency_isa_pool();
> 	                q->bounce_gfp = GFP_NOIO | GFP_DMA;
> 	                q->limits.bounce_pfn = b_pfn;
> 	        }
> 
> 
> 
> I don't like rumor based discussion, I like fact based one.
> 

The GFP_NOIO will prevent the oom killer from being called, it requires 
__GFP_FS.

I can change this to invoke the should_alloc_retry() logic by testing for 
!(gfp_mask & __GFP_NOFAIL), but there's nothing else the page allocator 
can currently do to increase its probability of allocating pages; the 
memory compaction patchset might be particularly helpful for these types 
of scenarios.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
