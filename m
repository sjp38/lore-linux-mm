Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 12B976B0169
	for <linux-mm@kvack.org>; Tue,  2 Aug 2011 06:22:41 -0400 (EDT)
Date: Tue, 2 Aug 2011 11:22:31 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] kswapd: avoid unnecessary rebalance after an
 unsuccessful balancing
Message-ID: <20110802102231.GC10436@suse.de>
References: <1311952990-3844-1-git-send-email-alex.shi@intel.com>
 <20110729154031.GV3010@suse.de>
 <1312159517.27358.2446.camel@debian>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1312159517.27358.2446.camel@debian>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Alex,Shi" <alex.shi@intel.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "P@draigBrady.com" <P@draigBrady.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "andrea@cpushare.com" <andrea@cpushare.com>, "Chen, Tim C" <tim.c.chen@intel.com>, "Li, Shaohua" <shaohua.li@intel.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "riel@redhat.com" <riel@redhat.com>, "luto@mit.edu" <luto@mit.edu>

On Mon, Aug 01, 2011 at 08:45:17AM +0800, Alex,Shi wrote:
> On Fri, 2011-07-29 at 23:40 +0800, Mel Gorman wrote:
> > On Fri, Jul 29, 2011 at 11:23:10PM +0800, Alex Shi wrote:
> > > In commit 215ddd66, Mel Gorman said kswapd is better to sleep after a
> > > unsuccessful balancing if there is tighter reclaim request pending in
> > > the balancing. In this scenario, the 'order' and 'classzone_idx'
> > > that are checked for tighter request judgment is incorrect, since they
> > > aren't the one kswapd should read from new pgdat, but the last time pgdat
> > > value for just now balancing. Then kswapd will skip try_to_sleep func
> > > and rebalance the last pgdat request. It's not our expected behavior.
> > > 
> > > So, I added new variables to distinguish the returned order/classzone_idx
> > > from last balancing, that can resolved above issue in that scenario.
> > > 
> > 
> > I'm afraid this changelog is very difficult to read and I do not see
> > what problem you are trying to solve and I do not see what this patch
> > might solve.
> > 
> > When balance_pgdat() returns with a lower classzone or order, the values
> > stored in pgdat are not re-read and instead it tries to go to sleep
> > based on the starting request. Something like;
> 
> Thanks for your comments, I will use this comments style next time, list
> request A, B etc. 
> 
> > 
> > 1. Read pgdat request A (classzone_idx, order)
> 
> Assume the order of A > 0, like is 3.
> 
> > 2. balance_pgdat()
> > 3.During pgdat, a new pgdat request B (classzone_idx, order) is placed
> > 4. balance_pgdat() returns but failed so classzone_idx is lower
> 
> Another balance_pgdat() failure indicate is returned order == 0, am I
> right? 

Yes.

> If so, the next step of kswapd is not trying to sleep, but do
> request A balance again.  And I thought this behavior doesn't match the
> comments in kswapd. 
> 

You're right. I was thinking only of classzone_idx. I see the point now.

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
