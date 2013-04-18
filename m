Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 24DA86B0036
	for <linux-mm@kvack.org>; Thu, 18 Apr 2013 12:44:13 -0400 (EDT)
Date: Thu, 18 Apr 2013 09:43:06 -0700
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 08/10] mm: vmscan: Have kswapd shrink slab only once per
 priority
Message-ID: <20130418164306.GJ2018@cmpxchg.org>
References: <1365710278-6807-1-git-send-email-mgorman@suse.de>
 <1365710278-6807-9-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1365710278-6807-9-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, dormando <dormando@rydia.net>, Michal Hocko <mhocko@suse.cz>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Apr 11, 2013 at 08:57:56PM +0100, Mel Gorman wrote:
> If kswaps fails to make progress but continues to shrink slab then it'll
> either discard all of slab or consume CPU uselessly scanning shrinkers.
> This patch causes kswapd to only call the shrinkers once per priority.

But the priority level changes _only_ when kswapd is not making
progress, so I don't see how this fixes this case.

On the other hand, what about shrinkable memory like dentries and
inodes that build up during a streaming IO load like a backup program?

Kswapd may be cooperating with the page allocator and never change
priority as it reclaims the continuous file page stream, but it won't
do the same for the stream of slab memory.

So if anything, I would expect us to lay off slab memory when lru
reclaim is struggling, but receive continuous aging and pushback as
long as lru reclaim is comfortably running alongside the workload.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
