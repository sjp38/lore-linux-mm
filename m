Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 032496B004D
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 06:44:54 -0500 (EST)
Date: Tue, 17 Nov 2009 11:44:44 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 4/5] vmscan: Have kswapd sleep for a short interval and
	double check it should be asleep
Message-ID: <20091117114444.GY29804@csn.ul.ie>
References: <2f11576a0911140134u21eafa83t9642bb25ccd953de@mail.gmail.com> <20091114154636.GR29804@csn.ul.ie> <20091117141638.3DCB.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20091117141638.3DCB.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Stephan von Krawczynski <skraw@ithnet.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Kernel Testers List <kernel-testers@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, Nov 17, 2009 at 08:03:21PM +0900, KOSAKI Motohiro wrote:
> I'm sorry for the long delay.
> 
> > On Sat, Nov 14, 2009 at 06:34:23PM +0900, KOSAKI Motohiro wrote:
> > > 2009/11/14 Mel Gorman <mel@csn.ul.ie>:
> > > > On Sat, Nov 14, 2009 at 03:00:57AM +0900, KOSAKI Motohiro wrote:
> > > >> > On Fri, Nov 13, 2009 at 07:43:09PM +0900, KOSAKI Motohiro wrote:
> > > >> > > > After kswapd balances all zones in a pgdat, it goes to sleep. In the event
> > > >> > > > of no IO congestion, kswapd can go to sleep very shortly after the high
> > > >> > > > watermark was reached. If there are a constant stream of allocations from
> > > >> > > > parallel processes, it can mean that kswapd went to sleep too quickly and
> > > >> > > > the high watermark is not being maintained for sufficient length time.
> > > >> > > >
> > > >> > > > This patch makes kswapd go to sleep as a two-stage process. It first
> > > >> > > > tries to sleep for HZ/10. If it is woken up by another process or the
> > > >> > > > high watermark is no longer met, it's considered a premature sleep and
> > > >> > > > kswapd continues work. Otherwise it goes fully to sleep.
> > > >> > > >
> > > >> > > > This adds more counters to distinguish between fast and slow breaches of
> > > >> > > > watermarks. A "fast" premature sleep is one where the low watermark was
> > > >> > > > hit in a very short time after kswapd going to sleep. A "slow" premature
> > > >> > > > sleep indicates that the high watermark was breached after a very short
> > > >> > > > interval.
> > > >> > > >
> > > >> > > > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > > >> > >
> > > >> > > Why do you submit this patch to mainline? this is debugging patch
> > > >> > > no more and no less.
> > > >> > >
> > > >> >
> > > >> > Do you mean the stats part? The stats are included until such time as the page
> > > >> > allocator failure reports stop or are significantly reduced. In the event a
> > > >> > report is received, the value of the counters help determine if kswapd was
> > > >> > struggling or not. They should be removed once this mess is ironed out.
> > > >> >
> > > >> > If there is a preference, I can split out the stats part and send it to
> > > >> > people with page allocator failure reports for retesting.
> > > >>
> > > >> I'm sorry my last mail didn't have enough explanation.
> > > >> This stats help to solve this issue. I agreed. but after solving this issue,
> > > >> I don't imagine administrator how to use this stats. if KSWAPD_PREMATURE_FAST or
> > > >> KSWAPD_PREMATURE_SLOW significantly increased, what should admin do?
> > > >
> > > > One possible workaround would be to raise min_free_kbytes while a fix is
> > > > being worked on.
> > > 
> > > Please correct me, if I said wrong thing.
> > 
> > You didn't.
> > 
> > > if I was admin, I don't watch this stats because kswapd frequently
> > > wakeup doesn't mean any trouble. instead I watch number of allocation
> > > failure.
> > 
> > The stats are not tracking when kswapd wakes up. It helps track how
> > quickly the high or low watermarks are going under once kswapd tries to
> > go back to sleep.
> 
> Umm, honestly I'm still puzlled. probably we need go back one step at once.
> kswapd wake up when memory amount less than low watermark and sleep
> when memory amount much than high watermask. We need to know 
> GFP_ATOMIC failure sign.
> 
> My point is, kswapd wakeup only happen after kswapd sleeping. but if the system is
> under heavy pressure and memory amount go up and down between low watermark
> and high watermark, this stats don't increase at all. IOW, this stats is strong related to
> high watermark.
> 

Yes, this is true but as long as kswapd is awake and doing its job, it
will continue taking direction on what order it should be reclaiming from
processes that failed the low_watermark test.  The GFP_ATOMIC allocations
will be allowed to go under this low watermark but will have informed kswapd
what order it should be reclaiming at so it stays working.

A stat that increases between the low and high watermark would indicate
that memory pressure is there or that the reclaim algorithm is not
working as expected but that's checking for a different problem.

What I was looking at was  kswapd going to sleep and the low or min watermarks
being hit very quickly after that so that kswapd pre-emptively kicks in
before allocations start failing again.

> Probaby, min watermark or low watermark are more useful for us.
> 

Why? kswapd is awake between those points.

> # of called wake_all_kswapd() is related to low watermark. and It's conteniously
> increase although the system have strong memroy pressure. I'm ok.
> KSWAPD_NO_CONGESTION_WAIT is related to min watermark. I'm ok too..
> # of page allocation failure is related to  min watermark too. I'm ok too.
> 
> IOW, I only dislike this stat stop increase strong memory pressure (above explanation).
> Can you please tell me why you think kswapd slept time is so important?
> 

I don't think the amount of time it has slept is important. I think it's
important to know if the system is getting back into watermark trouble very
shortly after kswapd reached the high watermark.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
