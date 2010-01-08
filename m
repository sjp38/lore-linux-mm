Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id E95786B0096
	for <linux-mm@kvack.org>; Fri,  8 Jan 2010 04:32:59 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o089WvNM012945
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 8 Jan 2010 18:32:57 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 18E3C45DE51
	for <linux-mm@kvack.org>; Fri,  8 Jan 2010 18:32:57 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id ED53745DE50
	for <linux-mm@kvack.org>; Fri,  8 Jan 2010 18:32:56 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D544C1DB803E
	for <linux-mm@kvack.org>; Fri,  8 Jan 2010 18:32:56 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7452EE08004
	for <linux-mm@kvack.org>; Fri,  8 Jan 2010 18:32:53 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: Commit f50de2d38 seems to be breaking my oom killer
In-Reply-To: <20100108092503.GA3985@csn.ul.ie>
References: <20100108130742.C138.A69D9226@jp.fujitsu.com> <20100108092503.GA3985@csn.ul.ie>
Message-Id: <20100108183156.C144.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri,  8 Jan 2010 18:32:52 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Minchan Kim <minchan.kim@gmail.com>, Will Newton <will.newton@gmail.com>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> > Umm..
> > This code looks a bit risky. Please imazine asymmetric numa. If the system has
> > very small node, its nude have unreclaimable state at almost time.
> > 
> > Thus, if all zones in the node are unreclaimable, It should be slept. To retry balance_pgdat()
> > is meaningless. this is original intention, I think.
> > 
> > So why can't we write following?
> > 
> > From c00d7bb29552d3aa4d934b5007f3d52ade5f2dfd Mon Sep 17 00:00:00 2001
> > From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > Date: Fri, 8 Jan 2010 08:36:05 +0900
> > Subject: [PATCH] vmscan: kswapd don't retry balance_pgdat() if all zones are unreclaimable
> > 
> > Commit f50de2d3 (vmscan: have kswapd sleep for a short interval and
> > double check it should be asleep) can cause kswapd to enter an infinite
> > loop if running on a single-CPU system. If all zones are unreclaimble,
> > sleeping_prematurely return 1 and kswapd will call balance_pgdat()
> > again. but it's totally meaningless, balance_pgdat() doesn't anything
> > against unreclaimable zone!
> > 
> 
> Sure, that would be a safer check in the face of very small NUMA nodes.
> It could do with a comment explaining why unreclaimable zones are being skipped
> but it's no biggie.  Will, can you confirm this patch also fixes your problem.
> 
> Kosaki, if Will reports success, can you then report that patch please
> for upstreaming?  After today, I'm offline for a week so it'd be at
> least 10 days before I'd do it. Thanks

Sure. thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
