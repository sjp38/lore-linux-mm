Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 0E1B36B004D
	for <linux-mm@kvack.org>; Mon, 12 Oct 2009 14:43:44 -0400 (EDT)
Date: Mon, 12 Oct 2009 19:43:44 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [Bug #14141] order 2 page allocation failures in iwlagn
Message-ID: <20091012184344.GG8200@csn.ul.ie>
References: <3onW63eFtRF.A.xXH.oMTxKB@chimera> <200910120110.28061.elendil@planet.nl> <20091012134328.GB8200@csn.ul.ie> <200910121932.14607.elendil@planet.nl>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <200910121932.14607.elendil@planet.nl>
Sender: owner-linux-mm@kvack.org
To: Frans Pop <elendil@planet.nl>
Cc: David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Kernel Testers List <kernel-testers@vger.kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Reinette Chatre <reinette.chatre@intel.com>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Mohamed Abbas <mohamed.abbas@intel.com>, "John W. Linville" <linville@tuxdriver.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Oct 12, 2009 at 07:32:11PM +0200, Frans Pop wrote:
> On Monday 12 October 2009, Mel Gorman wrote:
> > Maybe. Your commit id's are different to what I see. Maybe it's because
> > your tree has been shuffled around a bit
> 
> No, the commit IDs should be identical. My tree is just plain mainline.
> 
> Just to make sure... You did remove the "g" from the IDs, right?
> So v2.6.30-rc6-1103-gb1bc81a becomes 'b1bc81a' and if you do
> 'git describe b1bc81a' you really should end up with the same IDs I have.
> 

Bah, that's what I was doing all right. No excuse, that was just plain
stupid of me.

> > but after some digging around in this general area, I saw this patch
> >
> > 4752c93c30 iwlcore: Allow skb allocation from tasklet
> 
> That is v2.6.30-rc6-773-g4752c93, which is part of the first wireless
> merge I tested and where I saw no issues. But see below.
> 

While there were no issues at that point, I think it might have been the
beginning of a few patches that made things progressively worse. It is
possible there is more than one patch causing trouble here and bisecting
each of them is unlikely to be an option. More on this later though.

> > This patch increases the number of GFP_ATOMIC allocations that can occur
> > by allocating GFP_ATOMIC in some cases and GFP_KERNEL in others.
> > Previously, only GFP_KERNEL was used and I didn't realise this
> > allocation method was so recent. Problems of this sort have cropped up
> > before and while there are later changes that suppress some of these
> > warnings, I believe this is a strong candidate for where the allocation
> > failures started appearing.
> >
> > > v2.6.30-rc6-1032-g7ba10a8       mac80211: fix transposed min/max CW values
> > >     1.13    -
> > >     This is a bugfix for aa837ee1d from an earlier merge! Could this maybe
> 
> There's a typo here. That ID should be: aa837e1d.
> 
> > >     influence the test results in between? There are various SKB related
> > >     changes there, for example: dfbf97f3..e5b9215e.
> > > v2.6.30-rc6-1037-g2c5b9e5	wireless: libertas: fix unaligned accesses
> > > 	1.12    +-
> > > v2.6.30-rc6-1044-g729e9c7	cfg80211: fix for duplicate userspace replies
> > >     1.10    +- 
> > > v2.6.30-rc6-1075-gc587de0	iwlwifi: unify station management
> > >     1.9     ++-|+-
> > > v2.6.30-rc6-1076-gd14d444	iwl3945: port allow skb allocation in tasklet
> > >     I thought this was a prime candidate, but as you can see 
> > >     several commits before failed too. Still worth looking at I think!
> >
> > Your commit IDs are different to what I see but it's the commit merge at
> > b1bc81a0ef86b86fa410dd303d84c8c7bd09a64d. I agree that the last commit
> > (d14d44407b9f06e3cf967fcef28ccb780caf0583) could make the problem worse
> > because it expands the use of GFP_ATOMIC for another driver.
> 
> No, that was a mistake of mine. d14d444 is in a driver I don't even compile.
> The one you identified (which is the same change for iwlagn) is much more
> interesting.
> 

I had forgotten what model your card was and assumed it must have been based
on this driver for the problem to get worse for you that point.

> I really do think that v2.6.30-rc6-1032-g7ba10a8 could play a role here.
> That's a fix for v2.6.30-rc1-1131-gaa837e1. So that bug was introduced
> _before_ the merge 82d0481 and may thus well explain both the latencies I
> saw _and_ why that merge tested without problems. And that would also go a
> long way to explain my test results.

Very good point.

> So I'm going to retest 82d0481 with 7ba10a8 cherry-picked on top.
> 

Great.

> > > BISECTION of akpm (mm) MERGE
> > > ----------------------------
> [...]
> > While I didn't spot anything too out of the ordinary here, they did
> > occur shortly after a number of other page allocator related patches. 
> > One small thing I noticed there is that kswapd is getting woken up less
> > now than it did previously. Generally, I wouldn't have expected it to
> > make a difference but it's possible that kswapd is not being woken up to
> > reclaim at a higher order than it was previously. I have a patch for
> > this below. It'd be nice if you could apply it and see do fewer
> > allocation failures occur on current mainline.
> 
> I'll give that patch a try and report back.
> 

Thanks a lot.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
