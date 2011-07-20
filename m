Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id BD7866B004A
	for <linux-mm@kvack.org>; Wed, 20 Jul 2011 01:18:27 -0400 (EDT)
Subject: Re: [PATCH]vmscan: fix a livelock in kswapd
From: Shaohua Li <shaohua.li@intel.com>
In-Reply-To: <CAEwNFnCg4+mK62oC0k+7wHib_0dFFvDYbJ3VkP91WHY+f5XcpQ@mail.gmail.com>
References: <1311059367.15392.299.camel@sli10-conroe>
	 <CAEwNFnB6HKJ3j9cWzyb2e3BS2BQrE66F6eT02C4cozRC9YQ7kw@mail.gmail.com>
	 <1311065584.15392.300.camel@sli10-conroe>
	 <20110719165155.GB2978@barrios-desktop>
	 <1311122601.15392.310.camel@sli10-conroe>
	 <CAEwNFnCg4+mK62oC0k+7wHib_0dFFvDYbJ3VkP91WHY+f5XcpQ@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 20 Jul 2011 13:18:24 +0800
Message-ID: <1311139104.15392.344.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "mgorman@suse.de" <mgorman@suse.de>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>

On Wed, 2011-07-20 at 12:09 +0800, Minchan Kim wrote:
> On Wed, Jul 20, 2011 at 9:43 AM, Shaohua Li <shaohua.li@intel.com> wrote:
> > On Wed, 2011-07-20 at 00:51 +0800, Minchan Kim wrote:
> >> On Tue, Jul 19, 2011 at 04:53:04PM +0800, Shaohua Li wrote:
> >> > On Tue, 2011-07-19 at 16:45 +0800, Minchan Kim wrote:
> >> > > On Tue, Jul 19, 2011 at 4:09 PM, Shaohua Li <shaohua.li@intel.com> wrote:
> >> > > > I'm running a workload which triggers a lot of swap in a machine with 4 nodes.
> >> > > > After I kill the workload, I found a kswapd livelock. Sometimes kswapd3 or
> >> > > > kswapd2 are keeping running and I can't access filesystem, but most memory is
> >> > > > free. This looks like a regression since commit 08951e545918c159.
> >> > >
> >> > > Could you tell me what is 08951e545918c159?
> >> > > You mean [ebd64e21ec5a,
> >> > > mm-vmscan-only-read-new_classzone_idx-from-pgdat-when-reclaiming-successfully]
> >> > > ?
> >> > ha, sorry, I should copy the commit title.
> >> > 08951e545918c159(mm: vmscan: correct check for kswapd sleeping in
> >> > sleeping_prematurely)
> >> >
> >>
> >> I don't mean it. In my bogus git tree, I can't find it but I can look at it in repaired git tree. :)
> >> Anyway, I have a comment. Please look at below.
> >>
> >> On Tue, Jul 19, 2011 at 03:09:27PM +0800, Shaohua Li wrote:
> >> > I'm running a workload which triggers a lot of swap in a machine with 4 nodes.
> >> > After I kill the workload, I found a kswapd livelock. Sometimes kswapd3 or
> >> > kswapd2 are keeping running and I can't access filesystem, but most memory is
> >> > free. This looks like a regression since commit 08951e545918c159.
> >> > Node 2 and 3 have only ZONE_NORMAL, but balance_pgdat() will return 0 for
> >> > classzone_idx. The reason is end_zone in balance_pgdat() is 0 by default, if
> >> > all zones have watermark ok, end_zone will keep 0.
> >> > Later sleeping_prematurely() always returns true. Because this is an order 3
> >> > wakeup, and if classzone_idx is 0, both balanced_pages and present_pages
> >> > in pgdat_balanced() are 0.
> >>
> >> Sigh. Yes.
> >>
> >> > We add a special case here. If a zone has no page, we think it's balanced. This
> >> > fixes the livelock.
> >>
> >> Yes. Your patch can fix it but I don't like that it adds handling special case.
> >> (Although Andrew merged quickly).
> > The special case is reasonable, because if a zone has no page, it should
> > be considered balanced.
> 
> Yes. It's not bad and even simple but my concern is that at the moment
> kswapd code is very complicated and it's not hot path so I would like
> to add more readable code.
> 
> >
> >> The problem is to return 0-classzone_idx if all zones was okay.
> >> So how about this?
> > My original implementation is like this (I return a populated zone with
> > minimum zone index). But I changed my mind later. the end_zone is zone
> > we work, so return 0 is reasonable, because all zones are ok. Maybe we
> 
> If it is reasonable, did you work on ZONE_DMA(zone index: 0)?
return -1 can help.

> > should return -1 if all zones are ok, but this is another story.
> 
> I think that return classzone_id(-1) and handle such case is more readable.
sure, we need another patch to clean up it.

> >
> >> This can change old behavior slightly.
> >> For example, if balance_pgdat calls with order-3 and all zones are okay about order-3,
> >> it will recheck order-0 as end_zone isn't 0 any more.
> >> But I think it's desriable side effect we have missed.
> > if order-3 is ok, order-0 is ok too I think, so the check is
> > unnecessary.
> 
> No. It's not for the zone but *zones.
> In case of reclaiming higher order zone, it can sleep without all
> zones being balanced so that precious order-0 of some zone would be
> not balanced.
when balance_pgdat() skips the loop for higher order zone, it already
sets end_zone, so I thought this isn't a problem.

> Even we can lost chance of clearing congestion flag of the zone.
> It would be a another patch.
yep, the congestion flag clearing is a bit confusing. I don't even know
why just do it in high order allocation. If all zones are ok, we should
clear the flag regardless the order. 

> In conclusion, I would like to avoid complicated thing but I am going
> to be not against you strongly if other doesn't agree on me.
> I might need a time to clean kswapd's spagetti up.
ok, understand it. I have similar concerns actually. I thought my patch
is simple enough to solve the livelock. But we do have space to cleanup
balance_pgdat().

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
