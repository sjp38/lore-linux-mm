Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j4GDr2Uo015659
	for <linux-mm@kvack.org>; Mon, 16 May 2005 09:53:02 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j4GDr1Xn103156
	for <linux-mm@kvack.org>; Mon, 16 May 2005 09:53:02 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j4GDr1ju025722
	for <linux-mm@kvack.org>; Mon, 16 May 2005 09:53:01 -0400
Subject: Re: NUMA aware slab allocator V3
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <Pine.LNX.4.62.0505131823210.12315@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.58.0505110816020.22655@schroedinger.engr.sgi.com>
	 <20050512000444.641f44a9.akpm@osdl.org>
	 <Pine.LNX.4.58.0505121252390.32276@schroedinger.engr.sgi.com>
	 <20050513000648.7d341710.akpm@osdl.org>
	 <Pine.LNX.4.58.0505130411300.4500@schroedinger.engr.sgi.com>
	 <20050513043311.7961e694.akpm@osdl.org>
	 <Pine.LNX.4.62.0505131823210.12315@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Mon, 16 May 2005 06:52:48 -0700
Message-Id: <1116251568.1005.29.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, shai@scalex86.org, steiner@sgi.com
List-ID: <linux-mm.kvack.org>

On Fri, 2005-05-13 at 18:24 -0700, Christoph Lameter wrote: 
>  /*
> + * Some Linux kernels currently have weird notions of NUMA. Make sure that
> + * there is only a single node if CONFIG_NUMA is not set. Remove this check
> + * after the situation has stabilized.
> + */
> +#ifndef CONFIG_NUMA
> +#if MAX_NUMNODES != 1
> +#error "Broken Configuration: CONFIG_NUMA not set but MAX_NUMNODES !=1 !!"
> +#endif
> +#endif

There are some broken assumptions in the kernel that
CONFIG_DISCONTIG==CONFIG_NUMA.  These usually manifest when code assumes
that one pg_data_t means one NUMA node.

However, NUMA node ids are actually distinct from "discontigmem nodes".
A "discontigmem node" is just one physically contiguous area of memory,
thus one pg_data_t.  Some (non-NUMA) Mac G5's have a gap in their
address space, so they get two discontigmem nodes.

So, that #error is bogus.  It's perfectly valid to have multiple
discontigmem nodes, when the number of NUMA nodes is 1.  MAX_NUMNODES
refers to discontigmem nodes, not NUMA nodes.

In current -mm, you can use CONFIG_NEED_MULTIPLE_NODES to mean 'NUMA ||
DISCONTIG'.  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
