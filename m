Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 43AEF6B01B2
	for <linux-mm@kvack.org>; Thu, 20 May 2010 16:44:06 -0400 (EDT)
Date: Thu, 20 May 2010 13:43:59 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] online CPU before memory failed in pcpu_alloc_pages()
Message-Id: <20100520134359.fdfb397e.akpm@linux-foundation.org>
In-Reply-To: <1274163442-7081-1-git-send-email-chaohong_guo@linux.intel.com>
References: <1274163442-7081-1-git-send-email-chaohong_guo@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: minskey guo <chaohong_guo@linux.intel.com>
Cc: linux-mm@kvack.org, prarit@redhat.com, andi.kleen@intel.com, linux-kernel@vger.kernel.org, minskey guo <chaohong.guo@intel.com>, Tejun Heo <tj@kernel.org>, stable@kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 18 May 2010 14:17:22 +0800
minskey guo <chaohong_guo@linux.intel.com> wrote:

> From: minskey guo <chaohong.guo@intel.com>
> 
> The operation of "enable CPU to online before memory within a node"
> fails in some case according to Prarit. The warnings as follows:
> 
> Pid: 7440, comm: bash Not tainted 2.6.32 #2
> Call Trace:
>  [<ffffffff81155985>] pcpu_alloc+0xa05/0xa70
>  [<ffffffff81155a20>] __alloc_percpu+0x10/0x20
>  [<ffffffff81089605>] __create_workqueue_key+0x75/0x280
>  [<ffffffff8110e050>] ? __build_all_zonelists+0x0/0x5d0
>  [<ffffffff810c1eba>] stop_machine_create+0x3a/0xb0
>  [<ffffffff810c1f57>] stop_machine+0x27/0x60
>  [<ffffffff8110f1a0>] build_all_zonelists+0xd0/0x2b0
>  [<ffffffff814c1d12>] cpu_up+0xb3/0xe3
>  [<ffffffff814b3c40>] store_online+0x70/0xa0
>  [<ffffffff81326100>] sysdev_store+0x20/0x30
>  [<ffffffff811d29a5>] sysfs_write_file+0xe5/0x170
>  [<ffffffff81163d28>] vfs_write+0xb8/0x1a0
>  [<ffffffff810cfd22>] ? audit_syscall_entry+0x252/0x280
>  [<ffffffff81164761>] sys_write+0x51/0x90
>  [<ffffffff81013132>] system_call_fastpath+0x16/0x1b
> Built 4 zonelists in Zone order, mobility grouping on.  Total pages: 12331603
> PERCPU: allocation failed, size=128 align=64, failed to populate
> 
> With "enable CPU to online before memory" patch, when the 1st CPU of
> an offlined node is being onlined, we build zonelists for that node.
> If per-cpu area needs to be extended during zonelists building period,
> alloc_pages_node() will be called. The routine alloc_pages_node() fails
> on the node in-onlining because the node doesn't have zonelists created
> yet.
> 
> To fix this issue,  we try to alloc memory from current node.

How serious is this issue?  Just a warning?  Dead box?

Because if we want to port this fix into 2.6.34.x, we have a little
problem.


> --- a/mm/percpu.c
> +++ b/mm/percpu.c
> @@ -714,13 +714,29 @@ static int pcpu_alloc_pages(struct pcpu_chunk *chunk,

In linux-next, Tejun has gone and moved pcpu_alloc_pages() into the new
mm/percpu-vm.c.  So either

a) the -stable guys will need to patch a different file or

b) we apply this fix first and muck up Tejun's tree or

c) the bug isn't very serious so none of this applies.

>  {
>  	const gfp_t gfp = GFP_KERNEL | __GFP_HIGHMEM | __GFP_COLD;
>  	unsigned int cpu;
> +	int nid;
>  	int i;
>  
>  	for_each_possible_cpu(cpu) {
>  		for (i = page_start; i < page_end; i++) {
>  			struct page **pagep = &pages[pcpu_page_idx(cpu, i)];
>  
> -			*pagep = alloc_pages_node(cpu_to_node(cpu), gfp, 0);
> +			nid = cpu_to_node(cpu);
> +
> +			/*
> +			 * It is allowable to online a CPU within a NUMA
> +			 * node which doesn't have onlined local memory.
> +			 * In this case, we need to create zonelists for
> +			 * that node when cpu is being onlined. If per-cpu
> +			 * area needs to be extended at the exact time when
> +			 * zonelists of that node is being created, we alloc
> +			 * memory from current node.
> +			 */
> +			if ((nid == -1) ||
> +			    !(node_zonelist(nid, GFP_KERNEL)->_zonerefs->zone))
> +				nid = numa_node_id();
> +
> +			*pagep = alloc_pages_node(nid, gfp, 0);
>  			if (!*pagep) {
>  				pcpu_free_pages(chunk, pages, populated,
>  						page_start, page_end);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
