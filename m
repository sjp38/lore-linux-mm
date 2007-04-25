Date: Wed, 25 Apr 2007 00:42:14 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC][PATCH] syctl for selecting global zonelist[] order
Message-Id: <20070425004214.e21da2d8.akpm@linux-foundation.org>
In-Reply-To: <20070425121946.9eb27a79.kamezawa.hiroyu@jp.fujitsu.com>
References: <20070425121946.9eb27a79.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, GOTO <y-goto@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, 25 Apr 2007 12:19:46 +0900 KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> Make zonelist policy selectable from sysctl.
> 
> Assume 2 node NUMA, only node(0) has ZONE_DMA (ZONE_DMA32).
> 
> In this case, default (node0's) zonelist order is
> 
> Node(0)'s NORMAL -> Node(0)'s DMA -> Node(1)"s NORMAL.
> 
> This means Node(0)'s DMA is used before Node(1)'s NORMAL.
> 
> In some server, some application uses large memory allcation.
> This exhaust memory in the above order.
> Then....sometimes OOM_KILL will occur when 32bit device requires memory.
> 
> This patch adds sysctl for rebuilding zonelist after boot and doesn't change
> default zonelist order.

hm.  Why don't we use that ordering all the time?  Does the present ordering have
any advantage?

> command:
> %echo 0 > /proc/sys/vm/better_locality

Who could resist having better locality? ;)

> Will rebuild zonelist in following order.
> 
> Node(0)'s NORMAL -> Node(1)'s NORMAL -> Node(0)'s DMA.
> 
> if set better_locality == 1 (default), zonelist is
> Node(0)'s NORMAL -> Node(0)'s DMA -> Node(1)'s NORMAL.
> 
> Maybe useful in some users with heavy memory pressure and mlocks.
> 
> ...
>
>  extern int percpu_pagelist_fraction;
>  extern int compat_log;
> +#ifdef CONFIG_NUMA
> +extern int sysctl_better_locality;
> +#endif

The ifdef isn't needed here.  If something went wrong, we'll find out at
link-time.
  
>  /* this is needed for the proc_dointvec_minmax for [fs_]overflow UID and GID */
>  static int maxolduid = 65535;
> @@ -845,6 +848,15 @@ static ctl_table vm_table[] = {
>  		.extra1		= &zero,
>  		.extra2		= &one_hundred,
>  	},
> +	{
> +		.ctl_name	= VM_BETTER_LOCALITY,

Please don't add new sysctls: use CTL_UNNUMBERED here.

> +		.procname	= "better_locality",
> +		.data		= &sysctl_better_locality,
> +		.maxlen		= sizeof(sysctl_better_locality),
> +		.mode		= 0644,
> +		.proc_handler	= &sysctl_better_locality_handler,
> +		.strategy	= &sysctl_intvec,
> +	},
>
> ..
>
> +static void build_zonelists(pg_data_t *pgdat)
> +{
> +	if (sysctl_better_locality) {
> +		build_zonelists_locality_aware(pgdat);
> +	} else {
> +		build_zonelists_zone_aware(pgdat);
> +	}

Remove all the braces please.

> @@ -207,6 +207,7 @@ enum
>  	VM_PANIC_ON_OOM=33,	/* panic at out-of-memory */
>  	VM_VDSO_ENABLED=34,	/* map VDSO into new processes? */
>  	VM_MIN_SLAB=35,		 /* Percent pages ignored by zone reclaim */
> +	VM_BETTER_LOCALITY=36,	 /* create locality-preference zonelist */

This can go away.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
