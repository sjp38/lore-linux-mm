Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 296FA6B01BF
	for <linux-mm@kvack.org>; Fri, 21 May 2010 08:33:15 -0400 (EDT)
Subject: Re: [PATCH] online CPU before memory failed in pcpu_alloc_pages()
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20100521134424.45e0ee36.kamezawa.hiroyu@jp.fujitsu.com>
References: <1274163442-7081-1-git-send-email-chaohong_guo@linux.intel.com>
	 <20100520134359.fdfb397e.akpm@linux-foundation.org>
	 <20100521105512.0c2cf254.sfr@canb.auug.org.au>
	 <20100521134424.45e0ee36.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain
Date: Fri, 21 May 2010 08:32:09 -0400
Message-Id: <1274445129.9131.9.camel@useless.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, Andrew Morton <akpm@linux-foundation.org>, minskey guo <chaohong_guo@linux.intel.com>, linux-mm@kvack.org, prarit@redhat.com, andi.kleen@intel.com, linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>, stable@kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 2010-05-21 at 13:44 +0900, KAMEZAWA Hiroyuki wrote:
> On Fri, 21 May 2010 10:55:12 +1000
> Stephen Rothwell <sfr@canb.auug.org.au> wrote:
> 
> > Hi Andrew,
> > 
> > On Thu, 20 May 2010 13:43:59 -0700 Andrew Morton <akpm@linux-foundation.org> wrote:
> > >
> > > > --- a/mm/percpu.c
> > > > +++ b/mm/percpu.c
> > > > @@ -714,13 +714,29 @@ static int pcpu_alloc_pages(struct pcpu_chunk *chunk,
> > > 
> > > In linux-next, Tejun has gone and moved pcpu_alloc_pages() into the new
> > > mm/percpu-vm.c.  So either
> > 
> > This has gone into Linus' tree today ...
> > 
> 
> Hmm, a comment here.
> 
> Recently, Lee Schermerhorn developed
> 
>  numa-introduce-numa_mem_id-effective-local-memory-node-id-fix2.patch
> 
> Then, you can use cpu_to_mem() instead of cpu_to_node() to find the
> nearest available node.
> I don't check cpu_to_mem() is synchronized with NUMA hotplug but
> using cpu_to_mem() rather than adding 
> =
> 
> +			if ((nid == -1) ||
> +			    !(node_zonelist(nid, GFP_KERNEL)->_zonerefs->zone))
> +				nid = numa_node_id();
> +
> ==
> 
> is better. 


Kame-san, all:

numa_mem_id() and cpu_to_mem() are not supported [yet] on x86 because
x86 hides all memoryless nodes and moves cpus to "nearby" [for some
definition thereof] nodes with memory.  So, these interfaces just return
numa_node_id() and cpu_to_node() for x86.  Perhaps that will change
someday...

Lee


> 
> Thanks,
> -Kame
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
