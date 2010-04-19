Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id E1CE86B01EF
	for <linux-mm@kvack.org>; Sun, 18 Apr 2010 22:36:49 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3J2ajAl021970
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 19 Apr 2010 11:36:45 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9131A45DE4D
	for <linux-mm@kvack.org>; Mon, 19 Apr 2010 11:36:45 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5B59045DE50
	for <linux-mm@kvack.org>; Mon, 19 Apr 2010 11:36:45 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3ABB61DB804D
	for <linux-mm@kvack.org>; Mon, 19 Apr 2010 11:36:45 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id CD5521DB8040
	for <linux-mm@kvack.org>; Mon, 19 Apr 2010 11:36:44 +0900 (JST)
Date: Mon, 19 Apr 2010 11:32:47 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/8] numa:  add generic percpu var numa_node_id()
 implementation
Message-Id: <20100419113247.27fd0ea0.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100415172956.8801.18133.sendpatchset@localhost.localdomain>
References: <20100415172950.8801.60358.sendpatchset@localhost.localdomain>
	<20100415172956.8801.18133.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-mm@kvack.org, linux-numa@vger.kernel.org, Tejun Heo <tj@kernel.org>, Mel Gorman <mel@csn.ul.ie>, andi@firstfloor.org, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, David Rientjes <rientjes@google.com>, eric.whitney@hp.com, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 15 Apr 2010 13:29:56 -0400
Lee Schermerhorn <lee.schermerhorn@hp.com> wrote:

> Against:  2.6.34-rc3-mmotm-100405-1609
> 
> Rework the generic version of the numa_node_id() function to use the
> new generic percpu variable infrastructure.
> 
> Guard the new implementation with a new config option:
> 
>         CONFIG_USE_PERCPU_NUMA_NODE_ID.
> 
> Archs which support this new implemention will default this option
> to 'y' when NUMA is configured.  This config option could be removed
> if/when all archs switch over to the generic percpu implementation
> of numa_node_id().  Arch support involves:
> 
>   1) converting any existing per cpu variable implementations to use
>      this implementation.  x86_64 is an instance of such an arch.
>   2) archs that don't use a per cpu variable for numa_node_id() will
>      need to initialize the new per cpu variable "numa_node" as cpus
>      are brought on-line.  ia64 is an example.
>   3) Defining USE_PERCPU_NUMA_NODE_ID in arch dependent Kconfig--e.g.,
>      when NUMA is configured.  This is required because I have
>      retained the old implementation by default to allow archs to
>      be modified incrementally, as desired.
> 
> Subsequent patches will convert x86_64 and ia64 to use this
> implemenation.
> 
> Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

> 
> ---
> 
> V0:
> #  From cl@linux-foundation.org Wed Nov  4 10:36:12 2009
> #  Date: Wed, 4 Nov 2009 12:35:14 -0500 (EST)
> #  From: Christoph Lameter <cl@linux-foundation.org>
> #  To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
> #  Subject: Re: [PATCH/RFC] slab:  handle memoryless nodes efficiently
> #
> #  I have a very early form of a draft of a patch here that genericizes
> #  numa_node_id(). Uses the new generic this_cpu_xxx stuff.
> #
> #  Not complete.
> 
> V1:
>   + split out x86 specific changes to subsequent patch
>   + split out "numa_mem_id()" and related changes to separate patch
>   + moved generic definitions of __this_cpu_xxx from linux/percpu.h
>     to asm-generic/percpu.h where asm/percpu.h and other asm hdrs
>     can use them.
>   + export new percpu symbol 'numa_node' in mm/percpu.h
>   + include <asm/percpu.h> in <linux/topology.h> for use by new
>     numa_node_id().
> 
> V2:
>   + add back the #ifndef/#endif guard around numa_node_id() so that archs
>     can override generic definition
>   + add generic stub for set_numa_node()
>   + use generic percpu numa_node_id() only if enabled by
>       CONFIG_USE_PERCPU_NUMA_NODE_ID
>    to allow incremental per arch support.  This option could be removed when/if
>    all archs that support NUMA support this option.
> 
> V3:
>   + separated the rework of linux/percpu.h into another [preceding] patch.
>   + moved definition of the numa_node percpu variable from mm/percpu.c to
>     mm/page-alloc.c
>   + moved premature definition of cpu_to_mem() to later patch.
> 
> V4:
>   + topology.h:  include <linux/percpu.h> rather than <linux/percpu-defs.h>
>     Requires Tejun Heo's percpu.h/slab.h cleanup series
> 
>  include/linux/topology.h |   33 ++++++++++++++++++++++++++++-----
>  mm/page_alloc.c          |    5 +++++
>  2 files changed, 33 insertions(+), 5 deletions(-)
> 
> Index: linux-2.6.34-rc3-mmotm-100405-1609/mm/page_alloc.c
> ===================================================================
> --- linux-2.6.34-rc3-mmotm-100405-1609.orig/mm/page_alloc.c	2010-04-07 10:04:04.000000000 -0400
> +++ linux-2.6.34-rc3-mmotm-100405-1609/mm/page_alloc.c	2010-04-07 10:10:23.000000000 -0400
> @@ -56,6 +56,11 @@
>  #include <asm/div64.h>
>  #include "internal.h"
>  
> +#ifdef CONFIG_USE_PERCPU_NUMA_NODE_ID
> +DEFINE_PER_CPU(int, numa_node);
> +EXPORT_PER_CPU_SYMBOL(numa_node);
> +#endif
> +
>  /*
>   * Array of node states.
>   */
> Index: linux-2.6.34-rc3-mmotm-100405-1609/include/linux/topology.h
> ===================================================================
> --- linux-2.6.34-rc3-mmotm-100405-1609.orig/include/linux/topology.h	2010-04-07 09:49:13.000000000 -0400
> +++ linux-2.6.34-rc3-mmotm-100405-1609/include/linux/topology.h	2010-04-07 10:10:23.000000000 -0400
> @@ -31,6 +31,7 @@
>  #include <linux/bitops.h>
>  #include <linux/mmzone.h>
>  #include <linux/smp.h>
> +#include <linux/percpu.h>
>  #include <asm/topology.h>
>  
>  #ifndef node_has_online_mem
> @@ -203,8 +204,35 @@ int arch_update_cpu_topology(void);
>  #ifndef SD_NODE_INIT
>  #error Please define an appropriate SD_NODE_INIT in include/asm/topology.h!!!
>  #endif
> +
>  #endif /* CONFIG_NUMA */
>  
> +#ifdef CONFIG_USE_PERCPU_NUMA_NODE_ID
> +DECLARE_PER_CPU(int, numa_node);
> +
> +#ifndef numa_node_id
> +/* Returns the number of the current Node. */
> +#define numa_node_id()		__this_cpu_read(numa_node)
> +#endif
> +
> +#ifndef cpu_to_node
> +#define cpu_to_node(__cpu)	per_cpu(numa_node, (__cpu))
> +#endif
> +
> +#ifndef set_numa_node
> +#define set_numa_node(__node) percpu_write(numa_node, __node)
> +#endif
> +
> +#else	/* !CONFIG_USE_PERCPU_NUMA_NODE_ID */
> +
> +/* Returns the number of the current Node. */
> +#ifndef numa_node_id
> +#define numa_node_id()		(cpu_to_node(raw_smp_processor_id()))
> +
> +#endif
> +
> +#endif	/* [!]CONFIG_USE_PERCPU_NUMA_NODE_ID */
> +
>  #ifndef topology_physical_package_id
>  #define topology_physical_package_id(cpu)	((void)(cpu), -1)
>  #endif
> @@ -218,9 +246,4 @@ int arch_update_cpu_topology(void);
>  #define topology_core_cpumask(cpu)		cpumask_of(cpu)
>  #endif
>  
> -/* Returns the number of the current Node. */
> -#ifndef numa_node_id
> -#define numa_node_id()		(cpu_to_node(raw_smp_processor_id()))
> -#endif
> -
>  #endif /* _LINUX_TOPOLOGY_H */
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
