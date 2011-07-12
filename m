Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 24FA76B007E
	for <linux-mm@kvack.org>; Tue, 12 Jul 2011 06:14:07 -0400 (EDT)
Date: Tue, 12 Jul 2011 11:14:00 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 1/3] mm: vmscan: Do use use PF_SWAPWRITE from zone_reclaim
Message-ID: <20110712101400.GC7529@suse.de>
References: <1310389274-13995-1-git-send-email-mgorman@suse.de>
 <1310389274-13995-2-git-send-email-mgorman@suse.de>
 <CAEwNFnATXiQsmbfuvZNEtcpcVZkyZKRFB1SKbkEREaCW4S-aUg@mail.gmail.com>
 <4E1C1684.4090706@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <4E1C1684.4090706@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: minchan.kim@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cl@linux.com

On Tue, Jul 12, 2011 at 06:40:20PM +0900, KOSAKI Motohiro wrote:
> (2011/07/12 18:27), Minchan Kim wrote:
> > Hi Mel,
> > 
> > On Mon, Jul 11, 2011 at 10:01 PM, Mel Gorman <mgorman@suse.de> wrote:
> >> Zone reclaim is similar to direct reclaim in a number of respects.
> >> PF_SWAPWRITE is used by kswapd to avoid a write-congestion check
> >> but it's set also set for zone_reclaim which is inappropriate.
> >> Setting it potentially allows zone_reclaim users to cause large IO
> >> stalls which is worse than remote memory accesses.
> > 
> > As I read zone_reclaim_mode in vm.txt, I think it's intentional.
> > It has meaning of throttle the process which are writing large amounts
> > of data. The point is to prevent use of remote node's free memory.
> > 
> > And we has still the comment. If you're right, you should remove comment.
> > "         * and we also need to be able to write out pages for RECLAIM_WRITE
> >          * and RECLAIM_SWAP."
> > 
> > 
> > And at least, we should Cc Christoph and KOSAKI.
> 
> Of course, I'll take full ack this. Do you remember I posted the same patch
> about one year ago.

Nope, I didn't remember it at all :) . I'll revive your signed-off
and sorry about that.

> At that time, Mel disagreed me and I'm glad to see he changed
> the mind. :)
> 

Did I disagree because of this?

	Simply that I believe the intention of PF_SWAPWRITE here was
	to allow zone_reclaim() to aggressively reclaim memory if the
	reclaim_mode allowed it as it was a statement that off-node
	accesses are really not desired.

Or was some other problem brought up that I'm not thinking of now?

I'm no longer think the level of aggression is appropriate after seeing
how seeing how zone_reclaim can stall when just copying large amounts
of data on recent x86-64 NUMA machines. In the same mail, I said

	Ok. I am not fully convinced but I'll not block it either if
	believe it's necessary. My current understanding is that this
	patch only makes a difference if the server is IO congested in
	which case the system is struggling anyway and an off-node
	access is going to be relatively small penalty overall.
	Conceivably, having PF_SWAPWRITE set makes things worse in
	that situation and the patch makes some sense.

While I still think this situation is hard to trigger, zone_reclaim
can cause significant stalls *without* IO and there is little point
making the situation even worse.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
