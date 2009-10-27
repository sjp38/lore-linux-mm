From: Frans Pop <elendil@planet.nl>
Subject: Re: [Bug #14141] order 2 page allocation failures in iwlagn
Date: Tue, 27 Oct 2009 18:21:13 +0100
Message-ID: <200910271821.18521.elendil__41140.4026127004$1256664093$gmane$org@planet.nl>
References: <3onW63eFtRF.A.xXH.oMTxKB@chimera> <20091027155223.GL8900@csn.ul.ie> <20091027160332.GA7776@think>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Return-path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 5B73F6B0044
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 13:21:21 -0400 (EDT)
In-Reply-To: <20091027160332.GA7776@think>
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Chris Mason <chris.mason@oracle.com>, Mel Gorman <mel@csn.ul.ie>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sis>
List-Id: linux-mm.kvack.org

On Tuesday 27 October 2009, Chris Mason wrote:
> On Tue, Oct 27, 2009 at 03:52:24PM +0000, Mel Gorman wrote:
> > > So, after the move to async/sync, a lot more pages are getting
> > > queued for writeback - more than three times the number of pages are
> > > queued for writeback with the vanilla kernel. This amount of
> > > congestion might be why direct reclaimers and kswapd's timings have
> > > changed so much.
> >
> > Or more accurately, the vanilla kernel has queued up a lot more pages
> > for IO than when the patch is reverted. I'm not seeing yet why this
> > is.
>
> [ sympathies over confusion about congestion...lots of variables here ]
>
> If wb_kupdate has been able to queue more writes it is because the
> congestion logic isn't stopping it.  We have congestion_wait(), but
> before calling that in the writeback paths it says: are you congested?
> and then backs off if the answer is yes.
>
> Ideally, direct reclaim will never do writeback.  We want it to be able
> to find clean pages that kupdate and friends have already processed.
>
> Waiting for congestion is a funny thing, it only tells us the device has
> managed to finish some IO or that a timeout has passed.  Neither event
> has any relation to figuring out if the IO for reclaimable pages has
> finished.
>
> One option is to have the VM remember the hashed waitqueue for one of
> the pages it direct reclaims and then wait on it.

What people should be aware of is the behavior of the system I see at this 
point. I've already mentioned this in other mails, but it's probably good 
to repeat it here.

While gitk is reading commits with vanilla .31 and .32 kernels there is at 
some point a fairly long period (10-20 seconds) where I see:
- a completely frozen desktop, including frozen mouse cursor
- really very little disk activity (HD led flashes very briefly less than
  once per second)
- reading commits stops completely during this period
- no music.
After that there is a period (another 5-15 seconds) with a huge amount of 
disk activity during which the system gradually becomes responsive again 
and in gitk the count of commits that have been read starts increasing 
again (without a jump in the counter which confirms that no commits were 
read during the freeze).

I cannot really tell what the system is doing during those freezes. Because 
of the frozen desktop I cannot for example see CPU usage. I suspect that, 
as there is hardly any disk activity, the system must be reorganizing RAM 
or something. But it seems quite bad that that gets "bunched up" instead 
of happening more gradually.

With the congestion_wait() change reverted I never see these freezes, only 
much more normal minor latencies (< 2 seconds; mostly < 0.5 seconds), 
which is probably unavoidable during heavy swapping.

Hth,
FJP

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
