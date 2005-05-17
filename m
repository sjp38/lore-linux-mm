Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j4H0RS2O008001
	for <linux-mm@kvack.org>; Mon, 16 May 2005 20:27:28 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j4H0RSXn111380
	for <linux-mm@kvack.org>; Mon, 16 May 2005 20:27:28 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j4H0RHU8006406
	for <linux-mm@kvack.org>; Mon, 16 May 2005 20:27:18 -0400
Subject: Re: NUMA aware slab allocator V3
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <Pine.LNX.4.62.0505161713130.21512@graphe.net>
References: <Pine.LNX.4.58.0505110816020.22655@schroedinger.engr.sgi.com>
	 <Pine.LNX.4.62.0505161046430.1653@schroedinger.engr.sgi.com>
	 <714210000.1116266915@flay> <200505161410.43382.jbarnes@virtuousgeek.org>
	 <740100000.1116278461@flay>  <Pine.LNX.4.62.0505161713130.21512@graphe.net>
Content-Type: text/plain
Date: Mon, 16 May 2005 17:26:53 -0700
Message-Id: <1116289613.26955.14.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <christoph@lameter.com>
Cc: "Martin J. Bligh" <mbligh@mbligh.org>, Jesse Barnes <jbarnes@virtuousgeek.org>, Christoph Lameter <clameter@engr.sgi.com>, Andy Whitcroft <apw@shadowen.org>, Andrew Morton <akpm@osdl.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, shai@scalex86.org, steiner@sgi.com, "Matthew C. Dobson [imap]" <colpatch@us.ibm.com>
List-ID: <linux-mm.kvack.org>

> +#ifdef CONFIG_NUMA
> +#define NUMA_NODES MAX_NUMNODES
> +#define NUMA_NODE_ID numa_node_id()
> +#else
> +#define NUMA_NODES 1
> +#define NUMA_NODE_ID 0
>  #endif

I think numa_node_id() should always do what you want.  It is never
related to discontig nodes, and #defines down to the same thing you have
in the end, anyway:
        
        #define numa_node_id()       (cpu_to_node(_smp_processor_id()))
        
        asm-i386/topology.h
        #ifdef CONFIG_NUMA
        ...
        static inline int cpu_to_node(int cpu)
        {
                return cpu_2_node[cpu];
        }
        
        asm-generic/topology.h:
        #ifndef cpu_to_node
        #define cpu_to_node(cpu)        (0)
        #endif

As for the MAX_NUMNODES, I'd just continue to use it, instead of a new
#define.  There is no case where there can be more NUMA nodes than
DISCONTIG nodes, and this assumption appears in plenty of other code.

I'm cc'ing Matt Dobson, who's touched this MAX_NUMNODES business a lot
more recently than I.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
