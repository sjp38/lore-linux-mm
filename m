Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 400E16B004D
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 05:27:41 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n599x8va009173
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 9 Jun 2009 18:59:08 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 795CF45DE51
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 18:59:08 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3D83045DD79
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 18:59:08 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 245681DB8038
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 18:59:08 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A76411DB8041
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 18:59:04 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/3] Reintroduce zone_reclaim_interval for when zone_reclaim() scans and fails to avoid CPU spinning at 100% on NUMA
In-Reply-To: <20090609184422.DD8B.A69D9226@jp.fujitsu.com>
References: <20090609094231.GM18380@csn.ul.ie> <20090609184422.DD8B.A69D9226@jp.fujitsu.com>
Message-Id: <20090609185036.DD8E.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  9 Jun 2009 18:59:03 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, yanmin.zhang@intel.com, Wu Fengguang <fengguang.wu@intel.com>, linuxram@us.ibm.com, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> > > > Here it is just recording the jiffies value. The real smarts with the counter
> > > > use time_before() which I assumed could handle jiffie wrap-arounds. Even
> > > > if it doesn't, the consequence is that one scan will occur that could have
> > > > been avoided around the time of the jiffie wraparound. The value will then
> > > > be reset and it will be fine.
> > > 
> > > time_before() assume two argument are enough nearly time.
> > > if we use 32bit cpu and HZ=1000, about jiffies wraparound about one month.
> > > 
> > > Then, 
> > > 
> > > 1. zone reclaim failure occur
> > > 2. system works fine for one month
> > > 3. jiffies wrap and time_before() makes mis-calculation.
> > > 
> > 
> > And the scan occurs uselessly and zone_reclaim_failure gets set again.
> > I believe the one useless scan is not significant enough to warrent dealing
> > with jiffie wraparound.
> 
> Thank you for kindful explanation.
> I fully agreed.

Bah, no, not agreed.
simple last failure recording makes following scenario.


1. zone reclaim failure occur. update zone_reclaim_failure.
      ^
      |  time_before() return 1, and zone_reclaim() return immediately.
      v
2. after 32 second.
      ^
      |  time_before() return 0, and zone_reclaim() works normally
      v
3. after one month
      ^
      |  time_before() return 1, and zone_reclaim() return immediately.
      |  although recent zone_reclaim() never failed.
      v
4. after more one month
      



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
