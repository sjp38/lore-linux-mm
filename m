Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 882F36B0035
	for <linux-mm@kvack.org>; Thu, 29 May 2014 18:40:36 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id kx10so970490pab.14
        for <linux-mm@kvack.org>; Thu, 29 May 2014 15:40:36 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id mn6si2829603pbc.17.2014.05.29.15.40.35
        for <linux-mm@kvack.org>;
        Thu, 29 May 2014 15:40:35 -0700 (PDT)
Date: Thu, 29 May 2014 15:40:33 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] page_alloc: skip cpuset enforcement for lower zone
 allocations (v4)
Message-Id: <20140529154033.f8d159b909794d71e2754489@linux-foundation.org>
In-Reply-To: <20140529184303.GA20571@amt.cnet>
References: <20140523193706.GA22854@amt.cnet>
	<20140526185344.GA19976@amt.cnet>
	<53858A06.8080507@huawei.com>
	<20140528224324.GA1132@amt.cnet>
	<20140529184303.GA20571@amt.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marcelo Tosatti <mtosatti@redhat.com>
Cc: Li Zefan <lizefan@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Lai Jiangshan <laijs@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>

On Thu, 29 May 2014 15:43:03 -0300 Marcelo Tosatti <mtosatti@redhat.com> wrote:

> 
> Zone specific allocations, such as GFP_DMA32, should not be restricted
> to cpusets allowed node list: the zones which such allocations demand
> might be contained in particular nodes outside the cpuset node list.
> 
> Necessary for the following usecase:
> - driver which requires zone specific memory (such as KVM, which
> requires root pagetable at paddr < 4GB).
> - user wants to limit allocations of application to nodeX, and nodeX has
> no memory < 4GB.
> 
> --- a/kernel/cpuset.c
> +++ b/kernel/cpuset.c
> @@ -2392,6 +2393,10 @@ int __cpuset_node_allowed_softwall(int node, gfp_t gfp_mask)
>  
>  	if (in_interrupt() || (gfp_mask & __GFP_THISNODE))
>  		return 1;
> +#ifdef CONFIG_NUMA
> +	if (gfp_zone(gfp_mask) < policy_zone)
> +		return 1;
> +#endif

It's not very obvious why this code is doing what it does, so I'm
thinking a comment is needed.  And that changelog text looks good, so

--- a/kernel/cpuset.c~page_alloc-skip-cpuset-enforcement-for-lower-zone-allocations-v4-fix
+++ a/kernel/cpuset.c
@@ -2388,6 +2388,11 @@ int __cpuset_node_allowed_softwall(int n
 	if (in_interrupt() || (gfp_mask & __GFP_THISNODE))
 		return 1;
 #ifdef CONFIG_NUMA
+	/*
+	 * Zone specific allocations such as GFP_DMA32 should not be restricted
+	 * to cpusets allowed node list: the zones which such allocations
+	 * demand be contained in particular nodes outside the cpuset node list
+	 */
 	if (gfp_zone(gfp_mask) < policy_zone)
 		return 1;
 #endif
--- a/mm/page_alloc.c~page_alloc-skip-cpuset-enforcement-for-lower-zone-allocations-v4-fix
+++ a/mm/page_alloc.c
@@ -2742,6 +2742,11 @@ retry_cpuset:
 	cpuset_mems_cookie = read_mems_allowed_begin();
 
 #ifdef CONFIG_NUMA
+	/*
+	 * Zone specific allocations such as GFP_DMA32 should not be restricted
+	 * to cpusets allowed node list: the zones which such allocations
+	 * demand be contained in particular nodes outside the cpuset node list
+	 */
 	if (gfp_zone(gfp_mask) < policy_zone)
 		nodemask = &node_states[N_ONLINE];
 #endif



However perhaps it would be nicer to do



#ifdef CONFIG_NUMA
/*
 * Zone specific allocations such as GFP_DMA32 should not be restricted to
 * cpusets allowed node list: the zones which such allocations demand be
 * contained in particular nodes outside the cpuset node list
 */
static inline bool i_cant_think_of_a_name(gfp_t mask)
{
	return gfp_zone(gfp_mask) < policy_zone;
}
#else
static inline bool i_cant_think_of_a_name(gfp_t mask)
{
	return false;
}
#endif

This encapsulates it all in a single place and zaps those ifdefs?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
