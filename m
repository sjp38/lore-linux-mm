Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id C4A646B004D
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 06:17:29 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n59AoW5J013207
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 9 Jun 2009 19:50:32 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3B15445DD7B
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 19:50:32 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 19D5045DD7E
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 19:50:32 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id EBE9F1DB8042
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 19:50:31 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7D89E1DB8038
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 19:50:31 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/3] Reintroduce zone_reclaim_interval for when zone_reclaim() scans and fails to avoid CPU spinning at 100% on NUMA
In-Reply-To: <20090609104404.GP18380@csn.ul.ie>
References: <20090609185036.DD8E.A69D9226@jp.fujitsu.com> <20090609104404.GP18380@csn.ul.ie>
Message-Id: <20090609194551.DD94.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  9 Jun 2009 19:50:30 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, yanmin.zhang@intel.com, Wu Fengguang <fengguang.wu@intel.com>, linuxram@us.ibm.com, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> On Tue, Jun 09, 2009 at 06:59:03PM +0900, KOSAKI Motohiro wrote:
> > > > > > Here it is just recording the jiffies value. The real smarts with the counter
> > > > > > use time_before() which I assumed could handle jiffie wrap-arounds. Even
> > > > > > if it doesn't, the consequence is that one scan will occur that could have
> > > > > > been avoided around the time of the jiffie wraparound. The value will then
> > > > > > be reset and it will be fine.
> > > > > 
> > > > > time_before() assume two argument are enough nearly time.
> > > > > if we use 32bit cpu and HZ=1000, about jiffies wraparound about one month.
> > > > > 
> > > > > Then, 
> > > > > 
> > > > > 1. zone reclaim failure occur
> > > > > 2. system works fine for one month
> > > > > 3. jiffies wrap and time_before() makes mis-calculation.
> > > > > 
> > > > 
> > > > And the scan occurs uselessly and zone_reclaim_failure gets set again.
> > > > I believe the one useless scan is not significant enough to warrent dealing
> > > > with jiffie wraparound.
> > > 
> > > Thank you for kindful explanation.
> > > I fully agreed.
> > 
> > Bah, no, not agreed.
> > simple last failure recording makes following scenario.
> > 
> > 
> > 1. zone reclaim failure occur. update zone_reclaim_failure.
> >       ^
> >       |  time_before() return 1, and zone_reclaim() return immediately.
> >       v
> > 2. after 32 second.
> >       ^
> >       |  time_before() return 0, and zone_reclaim() works normally
> >       v
> > 3. after one month
> >       ^
> >       |  time_before() return 1, and zone_reclaim() return immediately.
> >       |  although recent zone_reclaim() never failed.
> >       v
> > 4. after more one month
> >       
> 
> Pants.
> 
> /me slaps self
> 
> +       /* Watch for jiffie wraparound */
> +       if (unlikely(jiffies < zone->zone_reclaim_failure))
> +               zone->zone_reclaim_failure = jiffies;
> +
> +       /* Do not attempt a scan if scanning failed recently */
> +       if (time_before(jiffies,
> +                       zone->zone_reclaim_failure + zone_reclaim_interval))
> +               return 0;
> +
> 
> ?

looks good.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
