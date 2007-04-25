Date: Wed, 25 Apr 2007 16:55:45 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] syctl for selecting global zonelist[] order
Message-Id: <20070425165545.2d614ccd.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070425004214.e21da2d8.akpm@linux-foundation.org>
References: <20070425121946.9eb27a79.kamezawa.hiroyu@jp.fujitsu.com>
	<20070425004214.e21da2d8.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, y-goto@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Wed, 25 Apr 2007 00:42:14 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Wed, 25 Apr 2007 12:19:46 +0900 KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > Make zonelist policy selectable from sysctl.
> > 
> > Assume 2 node NUMA, only node(0) has ZONE_DMA (ZONE_DMA32).
> > 
> > In this case, default (node0's) zonelist order is
> > 
> > Node(0)'s NORMAL -> Node(0)'s DMA -> Node(1)"s NORMAL.
> > 
> > This means Node(0)'s DMA is used before Node(1)'s NORMAL.
> > 
> > In some server, some application uses large memory allcation.
> > This exhaust memory in the above order.
> > Then....sometimes OOM_KILL will occur when 32bit device requires memory.
> > 
> > This patch adds sysctl for rebuilding zonelist after boot and doesn't change
> > default zonelist order.
> 
> hm.  Why don't we use that ordering all the time?  Does the present ordering have
> any advantage?
> 
I don't know ;) maybe some high-end NUMA hardware has IOMMU and
zoning by memory address has no meaning.

> > command:
> > %echo 0 > /proc/sys/vm/better_locality
> 
> Who could resist having better locality? ;)
> 

how about changing this name to strict_zone_order and

if strict_zone_order = 1
	Node(0)'NORMAL -> Node(1)'Normal -> Node(0)'DMA
if strict_zone_order = 0
	Node(0)'NORMAL -> Node(0)'DMA -> Node(1)'NORMAL

If someone thinks of better name, please teach me.



> >  extern int percpu_pagelist_fraction;
> >  extern int compat_log;
> > +#ifdef CONFIG_NUMA
> > +extern int sysctl_better_locality;
> > +#endif
> 
> The ifdef isn't needed here.  If something went wrong, we'll find out at
> link-time.
>   
Okay.

> >  /* this is needed for the proc_dointvec_minmax for [fs_]overflow UID and GID */
> >  static int maxolduid = 65535;
> > @@ -845,6 +848,15 @@ static ctl_table vm_table[] = {
> >  		.extra1		= &zero,
> >  		.extra2		= &one_hundred,
> >  	},
> > +	{
> > +		.ctl_name	= VM_BETTER_LOCALITY,
> 
> Please don't add new sysctls: use CTL_UNNUMBERED here.
> 
Oh, I didn't know about CTL_UNNUMBERED. looks useful. I'll try.


> > +static void build_zonelists(pg_data_t *pgdat)
> > +{
> > +	if (sysctl_better_locality) {
> > +		build_zonelists_locality_aware(pgdat);
> > +	} else {
> > +		build_zonelists_zone_aware(pgdat);
> > +	}
> 
> Remove all the braces please.

Okay.

> 
> > @@ -207,6 +207,7 @@ enum
> >  	VM_PANIC_ON_OOM=33,	/* panic at out-of-memory */
> >  	VM_VDSO_ENABLED=34,	/* map VDSO into new processes? */
> >  	VM_MIN_SLAB=35,		 /* Percent pages ignored by zone reclaim */
> > +	VM_BETTER_LOCALITY=36,	 /* create locality-preference zonelist */
> 
> This can go away.
> 
Okay.

I'll wait for other replies and post updated one tomorrow.

Thank you,

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
