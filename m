Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j4HNanrV000649
	for <linux-mm@kvack.org>; Tue, 17 May 2005 19:36:49 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j4HNanOt136832
	for <linux-mm@kvack.org>; Tue, 17 May 2005 19:36:49 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j4HNanOu009350
	for <linux-mm@kvack.org>; Tue, 17 May 2005 19:36:49 -0400
Message-ID: <428A800D.8050902@us.ibm.com>
Date: Tue, 17 May 2005 16:36:45 -0700
From: Matthew Dobson <colpatch@us.ibm.com>
MIME-Version: 1.0
Subject: Re: NUMA aware slab allocator V3
References: <Pine.LNX.4.58.0505110816020.22655@schroedinger.engr.sgi.com>	 <Pine.LNX.4.62.0505161046430.1653@schroedinger.engr.sgi.com>	 <714210000.1116266915@flay> <200505161410.43382.jbarnes@virtuousgeek.org>	 <740100000.1116278461@flay>  <Pine.LNX.4.62.0505161713130.21512@graphe.net> <1116289613.26955.14.camel@localhost>
In-Reply-To: <1116289613.26955.14.camel@localhost>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Christoph Lameter <christoph@lameter.com>, "Martin J. Bligh" <mbligh@mbligh.org>, Jesse Barnes <jbarnes@virtuousgeek.org>, Christoph Lameter <clameter@engr.sgi.com>, Andy Whitcroft <apw@shadowen.org>, Andrew Morton <akpm@osdl.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, shai@scalex86.org, steiner@sgi.com
List-ID: <linux-mm.kvack.org>

Dave Hansen wrote:
>>+#ifdef CONFIG_NUMA
>>+#define NUMA_NODES MAX_NUMNODES
>>+#define NUMA_NODE_ID numa_node_id()
>>+#else
>>+#define NUMA_NODES 1
>>+#define NUMA_NODE_ID 0
>> #endif
> 
> 
> I think numa_node_id() should always do what you want.  It is never
> related to discontig nodes, and #defines down to the same thing you have
> in the end, anyway:
>         
>         #define numa_node_id()       (cpu_to_node(_smp_processor_id()))
>         
>         asm-i386/topology.h
>         #ifdef CONFIG_NUMA
>         ...
>         static inline int cpu_to_node(int cpu)
>         {
>                 return cpu_2_node[cpu];
>         }
>         
>         asm-generic/topology.h:
>         #ifndef cpu_to_node
>         #define cpu_to_node(cpu)        (0)
>         #endif
> 
> As for the MAX_NUMNODES, I'd just continue to use it, instead of a new
> #define.  There is no case where there can be more NUMA nodes than
> DISCONTIG nodes, and this assumption appears in plenty of other code.
> 
> I'm cc'ing Matt Dobson, who's touched this MAX_NUMNODES business a lot
> more recently than I.
> 
> -- Dave


You're right, Dave.  The series of #defines at the top resolve to the same
thing as numa_node_id().  Adding the above #defines will serve only to
obfuscate the code.

Another thing that will really help, Christoph, would be replacing all your
open-coded for (i = 0; i < MAX_NUMNODES/NR_CPUS; i++) loops.  We have
macros that make that all nice and clean and (should?) do the right thing
for various combinations of SMP/DISCONTIG/NUMA/etc.  Use those and if they
DON'T do the right thing, please let me know and we'll fix them ASAP.

for_each_cpu(i)
for_each_online_cpu(i)
for_each_node(i)
for_each_online_node(i)

Those 4 macros should replace all your open-coded loops, Christoph.

-Matt
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
