Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 33CD46B0083
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 04:15:57 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n598j4Qw006708
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 9 Jun 2009 17:45:04 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id DBDE545DD76
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 17:45:03 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id B8D9A45DD75
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 17:45:03 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8F3EFE08004
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 17:45:03 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 47BC61DB8012
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 17:45:03 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/3] Reintroduce zone_reclaim_interval for when zone_reclaim() scans and fails to avoid CPU spinning at 100% on NUMA
In-Reply-To: <20090609081821.GE18380@csn.ul.ie>
References: <20090609143211.DD64.A69D9226@jp.fujitsu.com> <20090609081821.GE18380@csn.ul.ie>
Message-Id: <20090609173011.DD7F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  9 Jun 2009 17:45:02 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, yanmin.zhang@intel.com, Wu Fengguang <fengguang.wu@intel.com>, linuxram@us.ibm.com, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi

> > > @@ -1192,6 +1192,15 @@ static struct ctl_table vm_table[] = {
> > >  		.extra1		= &zero,
> > >  	},
> > >  	{
> > > +		.ctl_name       = CTL_UNNUMBERED,
> > > +		.procname       = "zone_reclaim_interval",
> > > +		.data           = &zone_reclaim_interval,
> > > +		.maxlen         = sizeof(zone_reclaim_interval),
> > > +		.mode           = 0644,
> > > +		.proc_handler   = &proc_dointvec_jiffies,
> > > +		.strategy       = &sysctl_jiffies,
> > > +	},
> > 
> > hmmm, I think nobody can know proper interval settings on his own systems.
> > I agree with Wu. It can be hidden.
> > 
> 
> For the few users that case, I expect the majority of those will choose
> either 0 or the default value of 30. They might want to alter this while
> setting zone_reclaim_mode if they don't understand the different values
> it can have for example.
> 
> My preference would be that this not exist at all but the
> scan-avoidance-heuristic has to be perfect to allow that.

Ah, I didn't concern interval==0. thanks.
I can ack this now, but please add documentation about interval==0 meaning?




> > > @@ -2414,6 +2426,16 @@ int zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
> > >  	ret = __zone_reclaim(zone, gfp_mask, order);
> > >  	zone_clear_flag(zone, ZONE_RECLAIM_LOCKED);
> > >  
> > > +	if (!ret) {
> > > +		/*
> > > +		 * We were unable to reclaim enough pages to stay on node and
> > > +		 * unable to detect in advance that the scan would fail. Allow
> > > +		 * off node accesses for zone_reclaim_inteval jiffies before
> > > +		 * trying zone_reclaim() again
> > > +		 */
> > > +		zone->zone_reclaim_failure = jiffies;
> > 
> > Oops, this simple assignment don't care jiffies round-trip.
> > 
> 
> Here it is just recording the jiffies value. The real smarts with the counter
> use time_before() which I assumed could handle jiffie wrap-arounds. Even
> if it doesn't, the consequence is that one scan will occur that could have
> been avoided around the time of the jiffie wraparound. The value will then
> be reset and it will be fine.

time_before() assume two argument are enough nearly time.
if we use 32bit cpu and HZ=1000, about jiffies wraparound about one month.

Then, 

1. zone reclaim failure occur
2. system works fine for one month
3. jiffies wrap and time_before() makes mis-calculation.

I think.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
