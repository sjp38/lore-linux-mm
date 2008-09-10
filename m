Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m8AMuvUq020055
	for <linux-mm@kvack.org>; Wed, 10 Sep 2008 18:56:57 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m8AMusLA233838
	for <linux-mm@kvack.org>; Wed, 10 Sep 2008 18:56:54 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m8AMuoja012739
	for <linux-mm@kvack.org>; Wed, 10 Sep 2008 18:56:53 -0400
Subject: Re: [Approach #2] [RFC][PATCH] Remove cgroup member from struct
	page
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <48C84C0A.30902@linux.vnet.ibm.com>
References: <48C66AF8.5070505@linux.vnet.ibm.com>
	 <20080901161927.a1fe5afc.kamezawa.hiroyu@jp.fujitsu.com>
	 <200809091358.28350.nickpiggin@yahoo.com.au>
	 <20080909135317.cbff4871.kamezawa.hiroyu@jp.fujitsu.com>
	 <200809091500.10619.nickpiggin@yahoo.com.au>
	 <20080909141244.721dfd39.kamezawa.hiroyu@jp.fujitsu.com>
	 <30229398.1220963412858.kamezawa.hiroyu@jp.fujitsu.com>
	 <20080910012048.GA32752@balbir.in.ibm.com>
	 <1221085260.6781.69.camel@nimitz>  <48C84C0A.30902@linux.vnet.ibm.com>
Content-Type: text/plain
Date: Wed, 10 Sep 2008 15:56:48 -0700
Message-Id: <1221087408.6781.73.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: kamezawa.hiroyu@jp.fujitsu.com, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, hugh@veritas.com, menage@google.com, xemul@openvz.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2008-09-10 at 15:36 -0700, Balbir Singh wrote:
> Dave Hansen wrote:
> > On Tue, 2008-09-09 at 18:20 -0700, Balbir Singh wrote:
> >> +       start = pgdat->node_start_pfn;
> >> +       end = pgdat->node_start_pfn + pgdat->node_spanned_pages;
> >> +       size = (end - start) * sizeof(struct page_cgroup);
> >> +       printk("Allocating %lu bytes for node %d\n", size, n);
> >> +       pcg_map[n] = alloc_bootmem_node(pgdat, size);
> >> +       /*
> >> +        * We can do smoother recovery
> >> +        */
> >> +       BUG_ON(!pcg_map[n]);
> >> +       return 0;
> >>  }
> > 
> > This will really suck for sparse memory machines.  Imagine a machine
> > with 1GB of memory at 0x0 and another 1GB of memory at 1TB up in the
> > address space.
> > 
> 
> I would hate to re-implement the entire sparsemem code :(
> Kame did suggest making the memory controller depend on sparsemem (to hook in
> from there for allocations)

Yeah, you could just make another mem_section member.  Or, you could
work to abstract the sparsemem code so that other people can use it, or
maybe make it more dynamic so we can have multiple pfn->object lookups
in parallel.  Adding the struct member is obviously easier.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
