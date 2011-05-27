Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id DBDAA6B0012
	for <linux-mm@kvack.org>; Fri, 27 May 2011 15:07:41 -0400 (EDT)
Received: from hpaq6.eem.corp.google.com (hpaq6.eem.corp.google.com [172.25.149.6])
	by smtp-out.google.com with ESMTP id p4RJ7YdY000385
	for <linux-mm@kvack.org>; Fri, 27 May 2011 12:07:35 -0700
Received: from pwj8 (pwj8.prod.google.com [10.241.219.72])
	by hpaq6.eem.corp.google.com with ESMTP id p4RJ6WEp025954
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 27 May 2011 12:07:33 -0700
Received: by pwj8 with SMTP id 8so1185543pwj.13
        for <linux-mm@kvack.org>; Fri, 27 May 2011 12:07:32 -0700 (PDT)
Date: Fri, 27 May 2011 12:07:30 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2] cpusets: randomize node rotor used in
 cpuset_mem_spread_node()
In-Reply-To: <20110527124705.GB4067@tiehlicka.suse.cz>
Message-ID: <alpine.DEB.2.00.1105271157350.2533@chino.kir.corp.google.com>
References: <20110414065146.GA19685@tiehlicka.suse.cz> <20110414160145.0830.A69D9226@jp.fujitsu.com> <20110415161831.12F8.A69D9226@jp.fujitsu.com> <20110415082051.GB8828@tiehlicka.suse.cz> <20110526153319.b7e8c0b6.akpm@linux-foundation.org>
 <20110527124705.GB4067@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Jack Steiner <steiner@sgi.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Paul Menage <menage@google.com>, Robin Holt <holt@sgi.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org

On Fri, 27 May 2011, Michal Hocko wrote:

> > alpha allmodconfig:
> > 
> > kernel/built-in.o: In function `cpuset_slab_spread_node':
> > (.text+0x67360): undefined reference to `node_random'
> > kernel/built-in.o: In function `cpuset_slab_spread_node':
> > (.text+0x67368): undefined reference to `node_random'
> > kernel/built-in.o: In function `cpuset_mem_spread_node':
> > (.text+0x673b8): undefined reference to `node_random'
> > kernel/built-in.o: In function `cpuset_mem_spread_node':
> > (.text+0x673c0): undefined reference to `node_random'
> > 
> > because it has CONFIG_NUMA=n, CONFIG_NODES_SHIFT=7.
> 
> non-NUMA with MAX_NUMA_NODES? Hmm, really weird and looks like a numa
> misuse.
> 

CONFIG_NODES_SHIFT is used for UMA machines that are using DISCONTIGMEM 
usually because they have very large holes; such machines don't need 
things like mempolicies but do need the data structures that abstract 
ranges of memory in the physical address space.  This build breakage 
probably isn't restricted to only alpha, you could probably see it with at 
least ia64 and mips as well.

> Define node_random directly in the mempolicy header
> 
> Alpha allows a strange configuration CONFIG_NUMA=n and CONFIG_NODES_SHIFT=7
> which means that mempolicy.c is not compiled and linked while we still have
> MAX_NUMNODES>1 which means that node_random is not defined.
> 

It's not just alpha, and it's not entirely strange.

> Let's move node_random definition into the header. We will be consistent with
> other node_* functions.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> Index: linus_tree/include/linux/nodemask.h
> ===================================================================
> --- linus_tree.orig/include/linux/nodemask.h	2011-05-27 14:15:52.000000000 +0200
> +++ linus_tree/include/linux/nodemask.h	2011-05-27 14:36:30.000000000 +0200
> @@ -433,7 +433,21 @@ static inline void node_set_offline(int
>  	nr_online_nodes = num_node_state(N_ONLINE);
>  }
>  
> -extern int node_random(const nodemask_t *maskp);
> +unsigned int get_random_int(void );

Spurious space.

> +/*
> + * Return the bit number of a random bit set in the nodemask.
> + * (returns -1 if nodemask is empty)
> + */
> +static inline int node_random(const nodemask_t *maskp)
> +{
> +	int w, bit = -1;
> +
> +	w = nodes_weight(*maskp);
> +	if (w)
> +		bit = bitmap_ord_to_pos(maskp->bits,
> +			get_random_int() % w, MAX_NUMNODES);
> +	return bit;
> +}
>  
>  #else
>  

Probably should have a no-op definition when MAX_NUMNODES == 1 that just 
returns 0?

> Index: linus_tree/mm/mempolicy.c
> ===================================================================
> --- linus_tree.orig/mm/mempolicy.c	2011-05-27 14:16:05.000000000 +0200
> +++ linus_tree/mm/mempolicy.c	2011-05-27 14:16:34.000000000 +0200
> @@ -1650,21 +1650,6 @@ static inline unsigned interleave_nid(st
>  		return interleave_nodes(pol);
>  }
>  
> -/*
> - * Return the bit number of a random bit set in the nodemask.
> - * (returns -1 if nodemask is empty)
> - */
> -int node_random(const nodemask_t *maskp)
> -{
> -	int w, bit = -1;
> -
> -	w = nodes_weight(*maskp);
> -	if (w)
> -		bit = bitmap_ord_to_pos(maskp->bits,
> -			get_random_int() % w, MAX_NUMNODES);
> -	return bit;
> -}
> -
>  #ifdef CONFIG_HUGETLBFS
>  /*
>   * huge_zonelist(@vma, @addr, @gfp_flags, @mpol)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
