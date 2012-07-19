Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id ACC076B005C
	for <linux-mm@kvack.org>; Wed, 18 Jul 2012 20:48:08 -0400 (EDT)
Date: Thu, 19 Jul 2012 09:48:45 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: +
 memory-hotplug-fix-kswapd-looping-forever-problem-fix-fix.patch added to -mm
 tree
Message-ID: <20120719004845.GA7346@bbox>
References: <20120717233115.A8E411E005C@wpzn4.hot.corp.google.com>
 <20120718012200.GA27770@bbox>
 <20120718143810.b15564b3.akpm@linux-foundation.org>
 <20120719001002.GA6579@bbox>
 <20120719002102.GN24336@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120719002102.GN24336@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ralf Baechle <ralf@linux-mips.org>, aaditya.kumar.30@gmail.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Yinghai Lu <yinghai@kernel.org>

Hi Tejun,

On Wed, Jul 18, 2012 at 05:21:02PM -0700, Tejun Heo wrote:
> (cc'ing Yinghai, hi!)
> 
> Hello,
> 
> On Thu, Jul 19, 2012 at 09:10:02AM +0900, Minchan Kim wrote:
> > On Wed, Jul 18, 2012 at 02:38:10PM -0700, Andrew Morton wrote:
> > > On Wed, 18 Jul 2012 10:22:00 +0900
> > > Minchan Kim <minchan@kernel.org> wrote:
> > > 
> > > > > 
> > > > > Is this really necessary?  Does the zone start out all-zeroes?  If not, can we
> > > > > make it do so?
> > > > 
> > > > Good point.
> > > > It can remove zap_zone_vm_stats and zone->flags = 0, too.
> > > > More important thing is that we could remove adding code to initialize
> > > > zero whenever we add new field to zone. So I look at the code.
> > > > 
> > > > In summary, IMHO, all is already initialie zero out but we need double
> > > > check in mips.
> > > > 
> > > 
> > > Well, this is hardly a performance-critical path.  So rather than
> > > groveling around ensuring that each and every architectures does the
> > > right thing, would it not be better to put a single memset() into core
> > > MM if there is an appropriate place?
> > 
> > I think most good place is free_area_init_node but at a glance,
> > bootmem_data is set up eariler than free_area_init_node so shouldn't we
> > keep that pointer still?
> 
> I don't think zapping node_data that late is a good idea.  It's used

As I look over all arch code[1], they seem to zero out when pg_data_t is allocated.
So we might not need this but Andrew want to make sure it in core MM code.
[1] http://marc.info/?l=linux-mm&m=134257473810711&w=3

> from very early in the boot and its usage during early boot is fairly
> platform dependent.  Dunno whether there's a good solution for this.

You mean some arches might want to use pglist_data's any fields
freely during bootup? So free_area_init_node should initialize fields
for core MM part explicitly?
If so, do they want to use fields of pglist_dat->node_zones[ ] freely?
Maybe not. If they doesn't use them, we could zero out zone structure
at least, not pg_data_t and it could be helpful, too.

> Maybe trigger warning if some fields which have to be zero aren't?

It's not good because this causes adding new WARNING in that part
whenever we add new field in pgdat. It nullify this patch's goal.

> 
> Thanks.
> 
> -- 
> tejun
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
