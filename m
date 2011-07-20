Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 2DB326B00FF
	for <linux-mm@kvack.org>; Tue, 19 Jul 2011 20:43:24 -0400 (EDT)
Subject: Re: [PATCH]vmscan: fix a livelock in kswapd
From: Shaohua Li <shaohua.li@intel.com>
In-Reply-To: <20110719165155.GB2978@barrios-desktop>
References: <1311059367.15392.299.camel@sli10-conroe>
	 <CAEwNFnB6HKJ3j9cWzyb2e3BS2BQrE66F6eT02C4cozRC9YQ7kw@mail.gmail.com>
	 <1311065584.15392.300.camel@sli10-conroe>
	 <20110719165155.GB2978@barrios-desktop>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 20 Jul 2011 08:43:21 +0800
Message-ID: <1311122601.15392.310.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "mgorman@suse.de" <mgorman@suse.de>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>

On Wed, 2011-07-20 at 00:51 +0800, Minchan Kim wrote:
> On Tue, Jul 19, 2011 at 04:53:04PM +0800, Shaohua Li wrote:
> > On Tue, 2011-07-19 at 16:45 +0800, Minchan Kim wrote:
> > > On Tue, Jul 19, 2011 at 4:09 PM, Shaohua Li <shaohua.li@intel.com> wrote:
> > > > I'm running a workload which triggers a lot of swap in a machine with 4 nodes.
> > > > After I kill the workload, I found a kswapd livelock. Sometimes kswapd3 or
> > > > kswapd2 are keeping running and I can't access filesystem, but most memory is
> > > > free. This looks like a regression since commit 08951e545918c159.
> > > 
> > > Could you tell me what is 08951e545918c159?
> > > You mean [ebd64e21ec5a,
> > > mm-vmscan-only-read-new_classzone_idx-from-pgdat-when-reclaiming-successfully]
> > > ?
> > ha, sorry, I should copy the commit title.
> > 08951e545918c159(mm: vmscan: correct check for kswapd sleeping in
> > sleeping_prematurely)
> > 
> 
> I don't mean it. In my bogus git tree, I can't find it but I can look at it in repaired git tree. :)
> Anyway, I have a comment. Please look at below.
> 
> On Tue, Jul 19, 2011 at 03:09:27PM +0800, Shaohua Li wrote:
> > I'm running a workload which triggers a lot of swap in a machine with 4 nodes.
> > After I kill the workload, I found a kswapd livelock. Sometimes kswapd3 or
> > kswapd2 are keeping running and I can't access filesystem, but most memory is
> > free. This looks like a regression since commit 08951e545918c159.
> > Node 2 and 3 have only ZONE_NORMAL, but balance_pgdat() will return 0 for
> > classzone_idx. The reason is end_zone in balance_pgdat() is 0 by default, if
> > all zones have watermark ok, end_zone will keep 0.
> > Later sleeping_prematurely() always returns true. Because this is an order 3
> > wakeup, and if classzone_idx is 0, both balanced_pages and present_pages
> > in pgdat_balanced() are 0.
> 
> Sigh. Yes.
> 
> > We add a special case here. If a zone has no page, we think it's balanced. This
> > fixes the livelock.
> 
> Yes. Your patch can fix it but I don't like that it adds handling special case.
> (Although Andrew merged quickly).
The special case is reasonable, because if a zone has no page, it should
be considered balanced.

> The problem is to return 0-classzone_idx if all zones was okay.
> So how about this?
My original implementation is like this (I return a populated zone with
minimum zone index). But I changed my mind later. the end_zone is zone
we work, so return 0 is reasonable, because all zones are ok. Maybe we
should return -1 if all zones are ok, but this is another story.

> This can change old behavior slightly.
> For example, if balance_pgdat calls with order-3 and all zones are okay about order-3,
> it will recheck order-0 as end_zone isn't 0 any more.
> But I think it's desriable side effect we have missed.
if order-3 is ok, order-0 is ok too I think, so the check is
unnecessary.

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
