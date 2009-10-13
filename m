Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id B0EF06B00C6
	for <linux-mm@kvack.org>; Tue, 13 Oct 2009 16:38:43 -0400 (EDT)
From: Frans Pop <elendil@planet.nl>
Subject: Re: [Bug #14141] order 2 page allocation failures in iwlagn
Date: Tue, 13 Oct 2009 22:38:37 +0200
References: <3onW63eFtRF.A.xXH.oMTxKB@chimera> <20091012134328.GB8200@csn.ul.ie> <200910121932.14607.elendil@planet.nl>
In-Reply-To: <200910121932.14607.elendil@planet.nl>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200910132238.40867.elendil@planet.nl>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Kernel Testers List <kernel-testers@vger.kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Reinette Chatre <reinette.chatre@intel.com>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Mohamed Abbas <mohamed.abbas@intel.com>, "John W. Linville" <linville@tuxdriver.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Monday 12 October 2009, Frans Pop wrote:
> On Monday 12 October 2009, Mel Gorman wrote:
> > but after some digging around in this general area, I saw this patch
> >
> > 4752c93c30 iwlcore: Allow skb allocation from tasklet
>
> That is v2.6.30-rc6-773-g4752c93, which is part of the first wireless
> merge I tested and where I saw no issues. But see below.
>
> > This patch increases the number of GFP_ATOMIC allocations that can
> > occur by allocating GFP_ATOMIC in some cases and GFP_KERNEL in others.
> > Previously, only GFP_KERNEL was used and I didn't realise this
> > allocation method was so recent. Problems of this sort have cropped up
> > before and while there are later changes that suppress some of these
> > warnings, I believe this is a strong candidate for where the
> > allocation failures started appearing.

I have tried reverting this patch and that does make a significant 
difference, but the results are still not really conclusive.
I tested the revert on top of:
- the first net-next-2.6 merge (2ed0e21), i.e. before the mm merge
- 2.6.31.1

In both cases I no longer get SKB errors, but instead (?) I get firmware 
errors:
iwlagn 0000:10:00.0: Microcode SW error detected.  Restarting 0x2000000.

So on the wireless side it does look as if there is more than one change 
involved. Remember that with .30 I don't get any errors, only relatively 
mild latencies and skips in the music.

> I really do think that v2.6.30-rc6-1032-g7ba10a8 could play a role here.
> That's a fix for v2.6.30-rc1-1131-gaa837e1. So that bug was introduced
> _before_ the merge 82d0481 and may thus well explain both the latencies
> I saw _and_ why that merge tested without problems. And that would also
> go a long way to explain my test results.
> So I'm going to retest 82d0481 with 7ba10a8 cherry-picked on top.
                         ^^^^^^^-- should be 45ea4ea

I've tried this but still don't get any SKB errors, so that bug does not 
seem to make a difference.

> > > BISECTION of akpm (mm) MERGE
> > > ----------------------------
> > While I didn't spot anything too out of the ordinary here, they did
> > occur shortly after a number of other page allocator related patches.
> > One small thing I noticed there is that kswapd is getting woken up
> > less now than it did previously. Generally, I wouldn't have expected
> > it to make a difference but it's possible that kswapd is not being
> > woken up to reclaim at a higher order than it was previously. I have a
> > patch for this below. It'd be nice if you could apply it and see do
> > fewer allocation failures occur on current mainline.
>
> I'll give that patch a try and report back.

With your patch on .32-rc4 I still get the SKB errors, so it does not seem 
to help. The only change there may have been is that the desktop was 
frozen longer than without the patch, but that is an impression, not a 
hard fact.


Although identifying the problem on the wireless side is important, I still 
feel that tracing the mm change should have priority as it influences much 
more than just iwlagn, as the other reports prove.

> > After that, could you edit drivers/net/wireless/iwlwifi/iwl-rx.c and
> > make the GFP_ATOMIC in iwl_rx_replenish_now() GFP_ATOMIC|__GFP_NOWARN
> > and see do any of the "serious" allocation failure messages appear.

For the above reason I've not yet tried this. It seems to me that this 
change will not really solve anything, but just suppress errors.

Cheers,
FJP

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
