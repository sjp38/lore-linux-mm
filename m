Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 552776B0011
	for <linux-mm@kvack.org>; Thu, 26 May 2011 18:34:14 -0400 (EDT)
Date: Thu, 26 May 2011 15:33:19 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] cpusets: randomize node rotor used in
 cpuset_mem_spread_node()
Message-Id: <20110526153319.b7e8c0b6.akpm@linux-foundation.org>
In-Reply-To: <20110415082051.GB8828@tiehlicka.suse.cz>
References: <20110414065146.GA19685@tiehlicka.suse.cz>
	<20110414160145.0830.A69D9226@jp.fujitsu.com>
	<20110415161831.12F8.A69D9226@jp.fujitsu.com>
	<20110415082051.GB8828@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Jack Steiner <steiner@sgi.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Paul Menage <menage@google.com>, Robin Holt <holt@sgi.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org

On Fri, 15 Apr 2011 10:20:51 +0200
Michal Hocko <mhocko@suse.cz> wrote:

> Some workloads that create a large number of small files tend to assign
> too many pages to node 0 (multi-node systems).  Part of the reason is that
> the rotor (in cpuset_mem_spread_node()) used to assign nodes starts at
> node 0 for newly created tasks.
> 
> This patch changes the rotor to be initialized to a random node number of
> the cpuset. We are initializating it lazily in cpuset_mem_spread_node
> resp. cpuset_slab_spread_node.
> 
>
> ...
>
> --- a/kernel/cpuset.c
> +++ b/kernel/cpuset.c
> @@ -2465,11 +2465,19 @@ static int cpuset_spread_node(int *rotor)
>  
>  int cpuset_mem_spread_node(void)
>  {
> +	if (current->cpuset_mem_spread_rotor == -1)
> +		current->cpuset_mem_spread_rotor =
> +			node_random(&current->mems_allowed);
> +
>  	return cpuset_spread_node(&current->cpuset_mem_spread_rotor);
>  }
>  
>  int cpuset_slab_spread_node(void)
>  {
> +	if (current->cpuset_slab_spread_rotor == -1)
> +		current->cpuset_slab_spread_rotor
> +			= node_random(&current->mems_allowed);
> +
>  	return cpuset_spread_node(&current->cpuset_slab_spread_rotor);
>  }
>  

alpha allmodconfig:

kernel/built-in.o: In function `cpuset_slab_spread_node':
(.text+0x67360): undefined reference to `node_random'
kernel/built-in.o: In function `cpuset_slab_spread_node':
(.text+0x67368): undefined reference to `node_random'
kernel/built-in.o: In function `cpuset_mem_spread_node':
(.text+0x673b8): undefined reference to `node_random'
kernel/built-in.o: In function `cpuset_mem_spread_node':
(.text+0x673c0): undefined reference to `node_random'

because it has CONFIG_NUMA=n, CONFIG_NODES_SHIFT=7.

We use "#if MAX_NUMNODES > 1" in nodemask.h, but we use CONFIG_NUMA
when deciding to build mempolicy.o.  That's a bit odd - why didn't
nodemask.h use CONFIG_NUMA?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
