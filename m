Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 894696B004D
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 06:03:29 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nAHB3Q3Q029287
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 17 Nov 2009 20:03:26 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 862A745DE6F
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 20:03:26 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6440845DE6E
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 20:03:26 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4C3C8E18002
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 20:03:26 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id EBBD91DB803A
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 20:03:22 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 4/5] vmscan: Have kswapd sleep for a short interval and double check it should be asleep
In-Reply-To: <20091114154636.GR29804@csn.ul.ie>
References: <2f11576a0911140134u21eafa83t9642bb25ccd953de@mail.gmail.com> <20091114154636.GR29804@csn.ul.ie>
Message-Id: <20091117141638.3DCB.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 17 Nov 2009 20:03:21 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Stephan von Krawczynski <skraw@ithnet.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Kernel Testers List <kernel-testers@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

I'm sorry for the long delay.

> On Sat, Nov 14, 2009 at 06:34:23PM +0900, KOSAKI Motohiro wrote:
> > 2009/11/14 Mel Gorman <mel@csn.ul.ie>:
> > > On Sat, Nov 14, 2009 at 03:00:57AM +0900, KOSAKI Motohiro wrote:
> > >> > On Fri, Nov 13, 2009 at 07:43:09PM +0900, KOSAKI Motohiro wrote:
> > >> > > > After kswapd balances all zones in a pgdat, it goes to sleep. In the event
> > >> > > > of no IO congestion, kswapd can go to sleep very shortly after the high
> > >> > > > watermark was reached. If there are a constant stream of allocations from
> > >> > > > parallel processes, it can mean that kswapd went to sleep too quickly and
> > >> > > > the high watermark is not being maintained for sufficient length time.
> > >> > > >
> > >> > > > This patch makes kswapd go to sleep as a two-stage process. It first
> > >> > > > tries to sleep for HZ/10. If it is woken up by another process or the
> > >> > > > high watermark is no longer met, it's considered a premature sleep and
> > >> > > > kswapd continues work. Otherwise it goes fully to sleep.
> > >> > > >
> > >> > > > This adds more counters to distinguish between fast and slow breaches of
> > >> > > > watermarks. A "fast" premature sleep is one where the low watermark was
> > >> > > > hit in a very short time after kswapd going to sleep. A "slow" premature
> > >> > > > sleep indicates that the high watermark was breached after a very short
> > >> > > > interval.
> > >> > > >
> > >> > > > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > >> > >
> > >> > > Why do you submit this patch to mainline? this is debugging patch
> > >> > > no more and no less.
> > >> > >
> > >> >
> > >> > Do you mean the stats part? The stats are included until such time as the page
> > >> > allocator failure reports stop or are significantly reduced. In the event a
> > >> > report is received, the value of the counters help determine if kswapd was
> > >> > struggling or not. They should be removed once this mess is ironed out.
> > >> >
> > >> > If there is a preference, I can split out the stats part and send it to
> > >> > people with page allocator failure reports for retesting.
> > >>
> > >> I'm sorry my last mail didn't have enough explanation.
> > >> This stats help to solve this issue. I agreed. but after solving this issue,
> > >> I don't imagine administrator how to use this stats. if KSWAPD_PREMATURE_FAST or
> > >> KSWAPD_PREMATURE_SLOW significantly increased, what should admin do?
> > >
> > > One possible workaround would be to raise min_free_kbytes while a fix is
> > > being worked on.
> > 
> > Please correct me, if I said wrong thing.
> 
> You didn't.
> 
> > if I was admin, I don't watch this stats because kswapd frequently
> > wakeup doesn't mean any trouble. instead I watch number of allocation
> > failure.
> 
> The stats are not tracking when kswapd wakes up. It helps track how
> quickly the high or low watermarks are going under once kswapd tries to
> go back to sleep.

Umm, honestly I'm still puzlled. probably we need go back one step at once.
 kswapd wake up when memory amount less than low watermark and sleep
when memory amount much than high watermask. We need to know 
GFP_ATOMIC failure sign.

My point is, kswapd wakeup only happen after kswapd sleeping. but if the system is
under heavy pressure and memory amount go up and down between low watermark
and high watermark, this stats don't increase at all. IOW, this stats is strong related to
high watermark.

Probaby, min watermark or low watermark are more useful for us.

# of called wake_all_kswapd() is related to low watermark. and It's conteniously
increase although the system have strong memroy pressure. I'm ok.
KSWAPD_NO_CONGESTION_WAIT is related to min watermark. I'm ok too..
# of page allocation failure is related to  min watermark too. I'm ok too.

IOW, I only dislike this stat stop increase strong memory pressure (above explanation).
Can you please tell me why you think kswapd slept time is so important?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
