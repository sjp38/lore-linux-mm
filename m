Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id B05AE6B012D
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 22:39:38 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9E2dabv005070
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 14 Oct 2010 11:39:36 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id F26F045DE51
	for <linux-mm@kvack.org>; Thu, 14 Oct 2010 11:39:35 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id D47CE45DE4F
	for <linux-mm@kvack.org>; Thu, 14 Oct 2010 11:39:35 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id B88821DB8038
	for <linux-mm@kvack.org>; Thu, 14 Oct 2010 11:39:35 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7720C1DB803A
	for <linux-mm@kvack.org>; Thu, 14 Oct 2010 11:39:35 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 3/3] mm: reserve max drift pages at boot time instead using zone_page_state_snapshot()
In-Reply-To: <20101013131916.GN30667@csn.ul.ie>
References: <20101013152922.ADC6.A69D9226@jp.fujitsu.com> <20101013131916.GN30667@csn.ul.ie>
Message-Id: <20101014113426.8B83.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 14 Oct 2010 11:39:34 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Shaohua Li <shaohua.li@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "cl@linux.com" <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 53627fa..194bdaa 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -4897,6 +4897,15 @@ static void setup_per_zone_wmarks(void)
> >  	for_each_zone(zone) {
> >  		u64 tmp;
> >  
> > +		/*
> > +		 * If max drift are less than 1%, reserve max drift pages
> > +		 * instead costly runtime calculation.
> > +		 */
> > +		if (zone->percpu_drift_mark < (zone->present_pages/100)) {
> > +			pages_min += zone->percpu_drift_mark;
> > +			zone->percpu_drift_mark = 0;
> > +		}
> > +
> 
> I don't see how this solves Shaohua's problem as such. Large systems will
> still suffer a bug performance penalty from zone_page_state_snapshot(). I
> do see the logic of adjusting min for larger systems to limit the amount of
> time per-cpu thresholds are lowered but that would be as a follow-on to my
> patch rather than a replacement.

My patch rescue 256cpus or more smaller systems. and I assumed 4096cpus system don't
run IO intensive workload such as Shaohua's case. they always use cpusets and run hpc
workload.

If you know another >1024cpus system, please let me know.
And again, my patch works on 4096cpus sysmtem although slow, but your don't.

Am I missing something?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
