Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 86EEB6B004D
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 07:29:58 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n59C5OCi017796
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 9 Jun 2009 21:05:24 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id D038745DE4F
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 21:05:23 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id AE56645DE51
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 21:05:23 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 9884A1DB803F
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 21:05:23 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 325DC1DB803C
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 21:05:20 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 3/3] Do not unconditionally treat zones that fail zone_reclaim() as full
In-Reply-To: <20090609092554.GJ18380@csn.ul.ie>
References: <20090609143806.DD67.A69D9226@jp.fujitsu.com> <20090609092554.GJ18380@csn.ul.ie>
Message-Id: <20090609190232.DD91.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  9 Jun 2009 21:05:19 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, yanmin.zhang@intel.com, Wu Fengguang <fengguang.wu@intel.com>, linuxram@us.ibm.com, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> > hmmm
> > I haven't catch your mention yet. sorry.
> > Could you please explain more?
> > 
> > My confuseness are:
> > 
> > 1.
> > ----
> > I think your patch almost revert Paul's 9276b1bc96a132f4068fdee00983c532f43d3a26 essence.
> > after your patch applied, zlc_mark_zone_full() is called only when zone_is_all_unreclaimable()==1
> > or memory stealed after zone_watermark_ok() rechecking.
> > 
> 
> It's true that the zone is only being marked full when it's .... full due
> to all pages being unreclaimable. Maybe this is too aggressive.
> 
> > but zone_is_all_unreclaimable() is very rare on large NUMA machine. Thus
> > your patch makes zlc_zone_worth_trying() check to worthless.
> > So, I like simple reverting 9276b1bc rather than introduce more messy if necessary.
> > 
> > but necessary? why?
> > 
> 
> Allegedly the ZLC cache reduces on large NUMA machines but I have no figures
> proving or disproving that so I'm wary of a full revert.
> 
> The danger as I see it is that zones get skipped when there was no need
> simply because the previous caller failed to scan with the case of the GFP
> flags causing the zone to be marked full of particular concern.
> 
> I was also concerned that once it was marked full, the zone was unconditionally
> skipped even though the next caller might be using a different watermark
> level like ALLOC_WMARK_LOW or ALLOC_NO_WATERMARKS.

Right.


> How about the following.
> 
> o If the zone is fully unreclaimable - mark full
> o If the zone_reclaim() avoids the scan because of the number of pages
>   and the current setting of reclaim_mode - mark full
> o If the scan occurs but enough pages were not reclaimed to meet the
>   watermarks - mark full

Looks good.


> 
> This is the important part
> 
> o Push down the zlc_zone_worth_trying() further down to take place after
>   the watermark check has failed but before reclaim_zone() is considered
> 
> The last part in particular is important because it might mean the
> zone_reclaim_interval can be later dropped because the zlc does the necessary
> scan avoidance for a period of time. It also means that a check of a bitmap
> is happening outside of a fast path.

hmmm...
I guess the intension of zlc_zone_worth_trying() is for reduce zone_watermark_ok() calling.
it's because zone_watermark_ok() is a bit heavy weight function.

I also strongly hope to improve fast-path of page allocator. but I'm afraid 
this change break ZLC worth perfectly.

What do you think this? I think this is key point of this change.



> > 2.
> > -----
> > Why simple following switch-case is wrong?
> > 
> > 	case ZONE_RECLAIM_NOSCAN:
> > 		goto try_next_zone;
> > 	case ZONE_RECLAIM_FULL:
> > 	case ZONE_RECLAIM_SOME:
> > 		goto this_zone_full;
> > 	case ZONE_RECLAIM_SUCCESS
> > 		; /* do nothing */
> > 
> > I mean, 
> >  (1) ZONE_RECLAIM_SOME and zone_watermark_ok()==1
> > are rare.
> 
> How rare? In the event the zone is under pressure, we could be just on the
> watermark. If we're within 32 pages of that watermark, then reclaiming some
> pages might just be enough to meet the watermark so why consider it full?

I mean, typically zone-reclaim can found reclaimable clean 32 pages easily.
it mean
  - in current kernel, dirty-ratio works perfectly.
    all pages dirty scenario never happend.
  - now, we have split lru. plenty anon pages don't prevent
    reclaim file-backed page.


> > Is rechecking really worth?
> 
> If we don't recheck and we reclaimed just 1 page, we allow a caller
> to go below watermarks. This could have an impact on GFP_ATOMIC
> allocations.

Is jsut 1 page reclaimed really happen?


> > In my experience, zone_watermark_ok() is not so fast function.
> > 
> 
> It's not, but watermarks can't be ignored just because the function is not
> fast. For what it's worth, we are already in a horrible slow path by the
> time we're reclaiming pages and the cost of zone_watermark_ok() is less
> of a concern?

for clarification,

reclaim bail out (commit a79311c1) changed zone-reclaim behavior too.

distro zone reclaim is horrible slow. it's because ZONE_RECLAIM_PRIORITY==4.
but mainline kernel's zone reclaim isn't so slow. it have bail-out and
effective split-lru based reclaim.

but unfortunately bail-out cause frequently zone-reclaim calling, because
one time zone-reclaim only reclaim 32 pages.

in distro kernel, zone_watermark_ok() x number-of-called-zone-reclaim is not
heavy at all. but its premise was changed.



> > And,
> > 
> >  (2) ZONE_RECLAIM_SUCCESS and zone_watermark_ok()==0
> > 
> > is also rare.
> 
> Again, how rare? I don't actually know myself.

it only happen reclaim success and another thread steal it.


> 
> > What do you afraid bad thing?
> 
> Because watermarks are important.

Yes.



> > I guess, high-order allocation and ZONE_RECLAIM_SUCCESS and 
> > zone_watermark_ok()==0 case, right?
> > 
> > if so, Why your system makes high order allocation so freqently?
> 
> This is not about high-order allocations.

ok.


> > 3.
> > ------
> > your patch do:
> > 
> > 1. call zone_reclaim() and return ZONE_RECLAIM_SUCCESS
> > 2. another thread steal memory
> > 3. call zone_watermark_ok() and return 0
> > 
> > but
> > 
> > 1. call zone_reclaim() and return ZONE_RECLAIM_SUCCESS
> > 2. call zone_watermark_ok() and return 1
> > 3. another thread steal memory
> > 4. call buffered_rmqueue() and return NULL
> > 
> > Then, it call zlc_mark_zone_full().
> > 
> > it seems a bit inconsistency.
> > 
> 
> There is a relatively harmless race in there when memory is extremely
> tight and there are multiple threads contending. Potentially, we go one
> page below the watermark per thread contending on the one zone because
> we are not locking in this path and the allocation could be satisified
> from the per-cpu allocator.
> 
> However, I do not see this issue as being serious enough to warrent
> fixing because it would require a lock just to very strictly adhere to
> the watermarks. It's different to the case above where if we did not check
> watermarks, a thread can go below the watermark without any other thread
> contending.

I agree with this is not so important. ok, I get rid of this claim.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
