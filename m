Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id DD6C86B01EF
	for <linux-mm@kvack.org>; Sun, 18 Apr 2010 22:55:35 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3J2tXKl024626
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 19 Apr 2010 11:55:33 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 00F8D45DE4E
	for <linux-mm@kvack.org>; Mon, 19 Apr 2010 11:55:33 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id D532945DE51
	for <linux-mm@kvack.org>; Mon, 19 Apr 2010 11:55:32 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id B2D8A1DB805B
	for <linux-mm@kvack.org>; Mon, 19 Apr 2010 11:55:32 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 23B191DB8040
	for <linux-mm@kvack.org>; Mon, 19 Apr 2010 11:55:29 +0900 (JST)
Date: Mon, 19 Apr 2010 11:51:34 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 3/8] numa:  ia64:  use generic percpu var numa_node_id()
 implementation
Message-Id: <20100419115134.bd756fdb.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100415173009.8801.67345.sendpatchset@localhost.localdomain>
References: <20100415172950.8801.60358.sendpatchset@localhost.localdomain>
	<20100415173009.8801.67345.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-mm@kvack.org, linux-numa@vger.kernel.org, Tejun Heo <tj@kernel.org>, Mel Gorman <mel@csn.ul.ie>, andi@firstfloor.org, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, David Rientjes <rientjes@google.com>, eric.whitney@hp.com, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 15 Apr 2010 13:30:09 -0400
Lee Schermerhorn <lee.schermerhorn@hp.com> wrote:

> Against:  2.6.34-rc3-mmotm-100405-1609
> 
> ia64:  Use generic percpu implementation of numa_node_id()
>    + intialize per cpu 'numa_node'
>    + remove ia64 cpu_to_node() macro;  use generic
>    + define CONFIG_USE_PERCPU_NUMA_NODE_ID when NUMA configured
> 
> Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>
> Reviewed-by: Christoph Lameter <cl@linux-foundation.org>
> 

Reviewd-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

BTW, Could add some explanation about "when numa_node_id() turns to be available" ?

IIUC,
 - BOOT cpu ...  after smp_prepare_boot_cpu()
 - Other cpu ..  after smp_init() (i.e. always.)

Right ? I'm sorry if it's well-known.

Thanks,
-Kame



> ---
> 
> New in V2
> 
> V3, V4: no change
> 
>  arch/ia64/Kconfig                |    4 ++++
>  arch/ia64/include/asm/topology.h |    5 -----
>  arch/ia64/kernel/smpboot.c       |    6 ++++++
>  3 files changed, 10 insertions(+), 5 deletions(-)
> 
> Index: linux-2.6.34-rc3-mmotm-100405-1609/arch/ia64/kernel/smpboot.c
> ===================================================================
> --- linux-2.6.34-rc3-mmotm-100405-1609.orig/arch/ia64/kernel/smpboot.c	2010-04-07 10:03:38.000000000 -0400
> +++ linux-2.6.34-rc3-mmotm-100405-1609/arch/ia64/kernel/smpboot.c	2010-04-07 10:10:27.000000000 -0400
> @@ -390,6 +390,11 @@ smp_callin (void)
>  
>  	fix_b0_for_bsp();
>  
> +	/*
> +	 * numa_node_id() works after this.
> +	 */
> +	set_numa_node(cpu_to_node_map[cpuid]);
> +
>  	ipi_call_lock_irq();
>  	spin_lock(&vector_lock);
>  	/* Setup the per cpu irq handling data structures */
> @@ -632,6 +637,7 @@ void __devinit smp_prepare_boot_cpu(void
>  {
>  	cpu_set(smp_processor_id(), cpu_online_map);
>  	cpu_set(smp_processor_id(), cpu_callin_map);
> +	set_numa_node(cpu_to_node_map[smp_processor_id()]);
>  	per_cpu(cpu_state, smp_processor_id()) = CPU_ONLINE;
>  	paravirt_post_smp_prepare_boot_cpu();
>  }
> Index: linux-2.6.34-rc3-mmotm-100405-1609/arch/ia64/include/asm/topology.h
> ===================================================================
> --- linux-2.6.34-rc3-mmotm-100405-1609.orig/arch/ia64/include/asm/topology.h	2010-04-07 09:49:13.000000000 -0400
> +++ linux-2.6.34-rc3-mmotm-100405-1609/arch/ia64/include/asm/topology.h	2010-04-07 10:10:27.000000000 -0400
> @@ -26,11 +26,6 @@
>  #define RECLAIM_DISTANCE 15
>  
>  /*
> - * Returns the number of the node containing CPU 'cpu'
> - */
> -#define cpu_to_node(cpu) (int)(cpu_to_node_map[cpu])
> -
> -/*
>   * Returns a bitmask of CPUs on Node 'node'.
>   */
>  #define cpumask_of_node(node) ((node) == -1 ?				\
> Index: linux-2.6.34-rc3-mmotm-100405-1609/arch/ia64/Kconfig
> ===================================================================
> --- linux-2.6.34-rc3-mmotm-100405-1609.orig/arch/ia64/Kconfig	2010-04-07 10:04:03.000000000 -0400
> +++ linux-2.6.34-rc3-mmotm-100405-1609/arch/ia64/Kconfig	2010-04-07 10:10:27.000000000 -0400
> @@ -497,6 +497,10 @@ config HAVE_ARCH_NODEDATA_EXTENSION
>  	def_bool y
>  	depends on NUMA
>  
> +config USE_PERCPU_NUMA_NODE_ID
> +	def_bool y
> +	depends on NUMA
> +
>  config ARCH_PROC_KCORE_TEXT
>  	def_bool y
>  	depends on PROC_KCORE
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
