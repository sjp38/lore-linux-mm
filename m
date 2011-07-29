Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 26C666B00EE
	for <linux-mm@kvack.org>; Fri, 29 Jul 2011 11:40:39 -0400 (EDT)
Date: Fri, 29 Jul 2011 16:40:31 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] kswapd: avoid unnecessary rebalance after an
 unsuccessful balancing
Message-ID: <20110729154031.GV3010@suse.de>
References: <1311952990-3844-1-git-send-email-alex.shi@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1311952990-3844-1-git-send-email-alex.shi@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Shi <alex.shi@intel.com>
Cc: linux-mm@kvack.org, P@draigBrady.com, linux-kernel@vger.kernel.org, andrea@cpushare.com, tim.c.chen@intel.com, shaohua.li@intel.com, akpm@linux-foundation.org, riel@redhat.com, luto@mit.edu

On Fri, Jul 29, 2011 at 11:23:10PM +0800, Alex Shi wrote:
> In commit 215ddd66, Mel Gorman said kswapd is better to sleep after a
> unsuccessful balancing if there is tighter reclaim request pending in
> the balancing. In this scenario, the 'order' and 'classzone_idx'
> that are checked for tighter request judgment is incorrect, since they
> aren't the one kswapd should read from new pgdat, but the last time pgdat
> value for just now balancing. Then kswapd will skip try_to_sleep func
> and rebalance the last pgdat request. It's not our expected behavior.
> 
> So, I added new variables to distinguish the returned order/classzone_idx
> from last balancing, that can resolved above issue in that scenario.
> 

I'm afraid this changelog is very difficult to read and I do not see
what problem you are trying to solve and I do not see what this patch
might solve.

When balance_pgdat() returns with a lower classzone or order, the values
stored in pgdat are not re-read and instead it tries to go to sleep
based on the starting request. Something like;

1. Read pgdat request A (classzone_idx, order)
2. balance_pgdat()
3.	During pgdat, a new pgdat request B (classzone_idx, order) is placed
4. balance_pgdat() returns but failed so classzone_idx is lower
5. Try to sleep based on pgdat request A

i.e. pgdat request B is not read and there is a comment explaining
why pgdat request B is not read after balance_pgdat() fails.

This patch adds some variables that might improve the readability
for some people but otherwise I can't see what problem is being
fixed. What did I miss?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
