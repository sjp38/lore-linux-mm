Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 2573F6B0062
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 12:11:34 -0500 (EST)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 5252E82C889
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 12:17:58 -0500 (EST)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id Pv6Z7OTI23Ne for <linux-mm@kvack.org>;
	Mon,  2 Nov 2009 12:17:52 -0500 (EST)
Received: from V090114053VZO-1 (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 0250582C905
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 12:12:05 -0500 (EST)
Date: Mon, 2 Nov 2009 12:05:09 -0500 (EST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [RFC][-mm][PATCH 1/6] oom-killer: updates for classification of
 OOM
In-Reply-To: <20091102162412.107ff8ac.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.1.10.0911021159120.2028@V090114053VZO-1>
References: <20091102162244.9425e49b.kamezawa.hiroyu@jp.fujitsu.com> <20091102162412.107ff8ac.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, aarcange@redhat.com, akpm@linux-foundation.org, minchan.kim@gmail.com, rientjes@google.com, vedran.furac@gmail.com, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

On Mon, 2 Nov 2009, KAMEZAWA Hiroyuki wrote:

>  /*
> - * Types of limitations to the nodes from which allocations may occur
> + * Types of limitations to zones from which allocations may occur
>   */

"Types of limitations that may cause OOMs"? MEMCG limitations are not zone
based.

>   */
>
> -unsigned long badness(struct task_struct *p, unsigned long uptime)
> +static unsigned long __badness(struct task_struct *p,
> +		      unsigned long uptime, enum oom_constraint constraint,
> +		      struct mem_cgroup *mem)
>  {
>  	unsigned long points, cpu_time, run_time;
>  	struct mm_struct *mm;

Why rename this function? You are adding a global_badness anyways.


> +	/*
> +	 * In numa environ, almost all allocation will be against NORMAL zone.

The typical allocations will be against the policy_zone! SGI IA64 (and
others) have policy_zone == GFP_DMA.

> +	 * But some small area, ex)GFP_DMA for ia64 or GFP_DMA32 for x86-64
> +	 * can cause OOM. We can use policy_zone for checking lowmem.
> +	 */

Simply say that we are checking if the zone constraint is below the policy
zone?

> +	 * Now, only mempolicy specifies nodemask. But if nodemask
> +	 * covers all nodes, this oom is global oom.
> +	 */
> +	if (nodemask && !nodes_equal(node_states[N_HIGH_MEMORY], *nodemask))
> +		ret = CONSTRAINT_MEMORY_POLICY;

Huh? A cpuset can also restrict the nodes?

> +	/*
> + 	 * If not __GFP_THISNODE, zonelist containes all nodes. And if

Dont see any __GFP_THISNODE checks here.

>  		panic("out of memory from page fault. panic_on_oom is selected.\n");
>
>  	read_lock(&tasklist_lock);
> -	__out_of_memory(0, 0); /* unknown gfp_mask and order */
> +	/*
> +	 * Considering nature of pages required for page-fault,this must be
> +	 * global OOM (if not cpuset...). Then, CONSTRAINT_NONE is correct.
> +	 * zonelist, nodemasks are unknown...
> +	 */
> +	__out_of_memory(0, CONSTRAINT_NONE, 0, NULL);
>  	read_unlock(&tasklist_lock);

Page faults can occur on processes that have memory restrictions.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
