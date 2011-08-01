Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 9C5C3900137
	for <linux-mm@kvack.org>; Sun, 31 Jul 2011 20:43:33 -0400 (EDT)
Subject: Re: [PATCH] kswapd: avoid unnecessary rebalance after an
 unsuccessful balancing
From: "Alex,Shi" <alex.shi@intel.com>
In-Reply-To: <20110729154031.GV3010@suse.de>
References: <1311952990-3844-1-git-send-email-alex.shi@intel.com>
	 <20110729154031.GV3010@suse.de>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 01 Aug 2011 08:45:17 +0800
Message-ID: <1312159517.27358.2446.camel@debian>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "P@draigBrady.com" <P@draigBrady.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "andrea@cpushare.com" <andrea@cpushare.com>, "Chen, Tim C" <tim.c.chen@intel.com>, "Li, Shaohua" <shaohua.li@intel.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "riel@redhat.com" <riel@redhat.com>, "luto@mit.edu" <luto@mit.edu>

On Fri, 2011-07-29 at 23:40 +0800, Mel Gorman wrote:
> On Fri, Jul 29, 2011 at 11:23:10PM +0800, Alex Shi wrote:
> > In commit 215ddd66, Mel Gorman said kswapd is better to sleep after a
> > unsuccessful balancing if there is tighter reclaim request pending in
> > the balancing. In this scenario, the 'order' and 'classzone_idx'
> > that are checked for tighter request judgment is incorrect, since they
> > aren't the one kswapd should read from new pgdat, but the last time pgdat
> > value for just now balancing. Then kswapd will skip try_to_sleep func
> > and rebalance the last pgdat request. It's not our expected behavior.
> > 
> > So, I added new variables to distinguish the returned order/classzone_idx
> > from last balancing, that can resolved above issue in that scenario.
> > 
> 
> I'm afraid this changelog is very difficult to read and I do not see
> what problem you are trying to solve and I do not see what this patch
> might solve.
> 
> When balance_pgdat() returns with a lower classzone or order, the values
> stored in pgdat are not re-read and instead it tries to go to sleep
> based on the starting request. Something like;

Thanks for your comments, I will use this comments style next time, list
request A, B etc. 

> 
> 1. Read pgdat request A (classzone_idx, order)

Assume the order of A > 0, like is 3.

> 2. balance_pgdat()
> 3.	During pgdat, a new pgdat request B (classzone_idx, order) is placed
> 4. balance_pgdat() returns but failed so classzone_idx is lower

Another balance_pgdat() failure indicate is returned order == 0, am I
right?  If so, the next step of kswapd is not trying to sleep, but do
request A balance again.  And I thought this behavior doesn't match the
comments in kswapd. 

> 5. Try to sleep based on pgdat request A 

> 
> i.e. pgdat request B is not read and there is a comment explaining
> why pgdat request B is not read after balance_pgdat() fails.
> 
> This patch adds some variables that might improve the readability
> for some people but otherwise I can't see what problem is being
> fixed. What did I miss?
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
