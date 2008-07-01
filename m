Subject: Re: [problem] raid performance loss with 2.6.26-rc8 on 32-bit x86
	(bisected)
From: Dan Williams <dan.j.williams@intel.com>
In-Reply-To: <20080701190741.GB16501@csn.ul.ie>
References: <1214877439.7885.40.camel@dwillia2-linux.ch.intel.com>
	 <20080701080910.GA10865@csn.ul.ie> <20080701175855.GI32727@shadowen.org>
	 <20080701190741.GB16501@csn.ul.ie>
Content-Type: text/plain
Date: Tue, 01 Jul 2008 13:29:35 -0700
Message-Id: <1214944175.26855.18.camel@dwillia2-linux.ch.intel.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andy Whitcroft <apw@shadowen.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, NeilBrown <neilb@suse.de>, babydr@baby-dragons.com, cl@linux-foundation.org, lee.schermerhorn@hp.com
List-ID: <linux-mm.kvack.org>

On Tue, 2008-07-01 at 12:07 -0700, Mel Gorman wrote:
> On (01/07/08 18:58), Andy Whitcroft didst pronounce:
> > > > Neil suggested CONFIG_NOHIGHMEM=y, I will give that a shot tomorrow.
> > > > Other suggestions / experiments?
> > > >
> >
> > Looking at the commit in question (54a6eb5c) there is one slight anomoly
> > in the conversion.  When nr_free_zone_pages() was converted to the new
> > iterators it started using the offset parameter to limit the zones
> > traversed; which is not unreasonable as that appears to be the
> > parameters purpose.  However, if we look at the original implementation
> > of this function (reproduced below) we can see it actually did nothing
> > with this parameter:
> >
> > static unsigned int nr_free_zone_pages(int offset)
> > {
> >       /* Just pick one node, since fallback list is circular */
> >       unsigned int sum = 0;
> >
> >       struct zonelist *zonelist = node_zonelist(numa_node_id(), GFP_KERNEL);
> >       struct zone **zonep = zonelist->zones;
> >       struct zone *zone;
> >
> >       for (zone = *zonep++; zone; zone = *zonep++) {
> >               unsigned long size = zone->present_pages;
> >               unsigned long high = zone->pages_high;
> >               if (size > high)
> >                       sum += size - high;
> >       }
> >
> >       return sum;
> > }
> >
> 
> This looks kinda promising and depends heavily on how this patch was
> tested in isolation. Dan, can you post the patch you use on 2.6.25
> because the commit in question should not have applied cleanly please?
> 
> To be clear, 2.6.25 used the offset parameter correctly to get a zonelist with
> the right zones in it. However, with two-zonelist, there is only one that
> gets filtered so using GFP_KERNEL to find a zone is equivilant as it gets
> filtered based on offset.  However, if this patch was tested in isolation,
> it could result in bogus values of vm_total_pages. Dan, can you confirm
> in your dmesg logs that the line like the following has similar values
> please?
> 
> Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 258544

The system is booted with mem=1024M on the kernel command line and with
or without Andy's patch this reports:

	Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 227584

Performance is still sporadic with the change.  Moreover this condition
is reproducing even with CONFIG_NOHIGHMEM=y.

Let us take commit 8b3e6cdc out of the equation and just look at raid0 
performance:

revision   2.6.25.8-fc8 54a6eb5c 54a6eb5c-nohighmem 2.6.26-rc8
           279          278      273                277
           281          278      275                277
           281          113      68.7               66.8
           279          69.2     277                73.7
           278          75.6     62.5               80.3
MB/s (avg) 280          163      191                155
% change   0%           -42%     -32%               -45%
result     base         bad      bad                bad

These numbers are taken from the results of:
for i in `seq 1 5`; do dd if=/dev/zero of=/dev/md0 bs=1024k count=2048; done

Where md0 is created by:
mdadm --create /dev/md0 /dev/sd[b-e] -n 4 -l 0

I will try your debug patch next Mel, and then try to collect more data
with blktrace.

--
Dan





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
