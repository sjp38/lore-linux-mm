Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 571676B004D
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 15:49:27 -0400 (EDT)
Date: Wed, 28 Oct 2009 12:47:56 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/3] vmscan: Force kswapd to take notice faster when
 high-order watermarks are being hit
Message-Id: <20091028124756.7af44b6b.akpm@linux-foundation.org>
In-Reply-To: <20091028102936.GS8900@csn.ul.ie>
References: <1256650833-15516-1-git-send-email-mel@csn.ul.ie>
	<1256650833-15516-4-git-send-email-mel@csn.ul.ie>
	<20091027131905.410ec04a.akpm@linux-foundation.org>
	<20091028102936.GS8900@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: stable@kernel.org, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Stephan von Krawczynski <skraw@ithnet.com>, Kernel Testers List <kernel-testers@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 28 Oct 2009 10:29:36 +0000
Mel Gorman <mel@csn.ul.ie> wrote:

> On Tue, Oct 27, 2009 at 01:19:05PM -0700, Andrew Morton wrote:
> > On Tue, 27 Oct 2009 13:40:33 +0000
> > Mel Gorman <mel@csn.ul.ie> wrote:
> > 
> > > When a high-order allocation fails, kswapd is kicked so that it reclaims
> > > at a higher-order to avoid direct reclaimers stall and to help GFP_ATOMIC
> > > allocations. Something has changed in recent kernels that affect the timing
> > > where high-order GFP_ATOMIC allocations are now failing with more frequency,
> > > particularly under pressure. This patch forces kswapd to notice sooner that
> > > high-order allocations are occuring.
> > > 
> > 
> > "something has changed"?  Shouldn't we find out what that is?
> > 
> 
> We've been trying but the answer right now is "lots". There were some
> changes in the allocator itself which were unintentional and fixed in
> patches 1 and 2 of this series. The two other major changes are
> 
> iwlagn is now making high order GFP_ATOMIC allocations which didn't
> help. This is being addressed separetly and I believe the relevant
> patches are now in mainline.
> 
> The other major change appears to be in page writeback. Reverting
> commits 373c0a7e + 8aa7e847 significantly helps one bug reporter but
> it's still unknown as to why that is.

Peculiar.  Those changes are fairly remote from large-order-GFP_ATOMIC
allocations.

> ...
>
> Wireless drivers in particularly seem to be very
> high-order GFP_ATOMIC happy.

It would be nice if we could find a way of preventing people from
attempting high-order atomic allocations in the first place - it's a bit
of a trap.

Maybe add a runtime warning which is suppressable by GFP_NOWARN (or a
new flag), then either fix existing callers or, after review, add the
flag.

Of course, this might just end up with people adding these hopeless
allocation attempts and just setting the nowarn flag :(

> > If one where to whack a printk in that `if' block, how often would it
> > trigger, and under what circumstances?
> 
> I don't know the frequency. The circumstances are "under load" when
> there are drivers depending on high-order allocations but the
> reproduction cases are unreliable.
> 
> Do you want me to slap together a patch that adds a vmstat counter for
> this? I can then ask future bug reporters to examine that counter and see
> if it really is a major factor for a lot of people or not.

Something like that, if it will help us understand what's going on.  I
don't see a permanent need for that instrumentation but while this
problem is still in the research stage, sure, lard it up with debug
stuff?



It's very important to understand _why_ the VM got worse.  And, of
course, to fix that up.  But, separately, we should find a way of
preventing developers from using these very unreliable allocations.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
