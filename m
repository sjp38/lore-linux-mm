Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id B065D900086
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 21:15:25 -0400 (EDT)
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id p3J1FJJ3010594
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 18:15:19 -0700
Received: from pxi7 (pxi7.prod.google.com [10.243.27.7])
	by wpaz29.hot.corp.google.com with ESMTP id p3J1F0wq029669
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 18:15:12 -0700
Received: by pxi7 with SMTP id 7so4198573pxi.16
        for <linux-mm@kvack.org>; Mon, 18 Apr 2011 18:15:12 -0700 (PDT)
Date: Mon, 18 Apr 2011 18:15:10 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH incremental] cpusets: initialize spread rotor lazily
In-Reply-To: <20110418212915.GA17376@tiehlicka.suse.cz>
Message-ID: <alpine.DEB.2.00.1104181814320.7351@chino.kir.corp.google.com>
References: <20110414065146.GA19685@tiehlicka.suse.cz> <20110414160145.0830.A69D9226@jp.fujitsu.com> <20110415161831.12F8.A69D9226@jp.fujitsu.com> <20110415082051.GB8828@tiehlicka.suse.cz> <alpine.DEB.2.00.1104151639080.3967@chino.kir.corp.google.com>
 <20110418084248.GB8925@tiehlicka.suse.cz> <alpine.DEB.2.00.1104181316110.31186@chino.kir.corp.google.com> <20110418212915.GA17376@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Jack Steiner <steiner@sgi.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Paul Menage <menage@google.com>, Robin Holt <holt@sgi.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org

On Mon, 18 Apr 2011, Michal Hocko wrote:

> From: Michal Hocko <mhocko@suse.cz>
> Subject: cpusets: initialize spread mem/slab rotor lazily
> 
> Kosaki Motohiro raised a concern that copy_process is hot path and we do
> not want to initialize cpuset_{mem,slab}_spread_rotor if they are not
> used most of the time.
> 
> I think that we should rather initialize it lazily when rotors are used
> for the first time.
> This will also catch the case when we set up spread mem/slab later.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Acked-by: David Rientjes <rientjes@google.com>

Thanks Michal!

> Index: linus_tree/kernel/cpuset.c
> ===================================================================
> --- linus_tree.orig/kernel/cpuset.c	2011-04-18 10:33:15.000000000 +0200
> +++ linus_tree/kernel/cpuset.c	2011-04-18 23:24:02.000000000 +0200
> @@ -2460,11 +2460,19 @@ static int cpuset_spread_node(int *rotor
>  
>  int cpuset_mem_spread_node(void)
>  {
> +	if (current->cpuset_mem_spread_rotor == NUMA_NO_NODE)
> +		current->cpuset_mem_spread_rotor =
> +			node_random(&current->mems_allowed);
> +
>  	return cpuset_spread_node(&current->cpuset_mem_spread_rotor);
>  }
>  
>  int cpuset_slab_spread_node(void)
>  {
> +	if (current->cpuset_slab_spread_rotor == NUMA_NO_NODE)
> +		current->cpuset_slab_spread_rotor =
> +			node_random(&current->mems_allowed);
> +
>  	return cpuset_spread_node(&current->cpuset_slab_spread_rotor);
>  }
>  
> Index: linus_tree/kernel/fork.c
> ===================================================================
> --- linus_tree.orig/kernel/fork.c	2011-04-18 10:33:15.000000000 +0200
> +++ linus_tree/kernel/fork.c	2011-04-18 10:33:56.000000000 +0200
> @@ -1126,8 +1126,8 @@ static struct task_struct *copy_process(
>  	mpol_fix_fork_child_flag(p);
>  #endif
>  #ifdef CONFIG_CPUSETS
> -	p->cpuset_mem_spread_rotor = node_random(&p->mems_allowed);
> -	p->cpuset_slab_spread_rotor = node_random(&p->mems_allowed);
> +	p->cpuset_mem_spread_rotor = NUMA_NO_NODE;
> +	p->cpuset_slab_spread_rotor = NUMA_NO_NODE;
>  #endif
>  #ifdef CONFIG_TRACE_IRQFLAGS
>  	p->irq_events = 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
