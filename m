Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 897FF6B0234
	for <linux-mm@kvack.org>; Tue, 15 Jun 2010 10:00:43 -0400 (EDT)
Date: Tue, 15 Jun 2010 16:00:11 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC PATCH 0/6] Do not call ->writepage[s] from direct reclaim
 and use a_ops->writepages() where possible
Message-ID: <20100615140011.GD28052@random.random>
References: <1275987745-21708-1-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1275987745-21708-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi Mel,

I know lots of people doesn't like direct reclaim, but I personally do
and I think if memory pressure is hard enough we should eventually
enter direct reclaim full force including ->writepage to avoid false
positive OOM failures. Transparent hugepage allocation in fact won't
even wakeup kswapd that would be insist to create hugepages and shrink
an excessive amount of memory (especially before memory compaction was
merged, it shall be tried again but if memory compaction fails in
kswapd context, definitely kswapd should immediately stop and not go
ahead trying the create hugepages the blind way, kswapd
order-awareness the blind way is surely detrimental and pointless).

When memory pressure is low, not going into ->writepage may be
beneficial from latency prospective too. (but again it depends how
much it matters to go in LRU and how beneficial is the cache, to know
if it's worth taking clean cache away even if hotter than dirty cache)

About the stack overflow did you ever got any stack-debug error? We've
plenty of instrumentation and ->writepage definitely runs with irq
enable, so if there's any issue, it can't possibly be unnoticed. The
worry about stack overflow shall be backed by numbers.

You posted lots of latency numbers (surely latency will improve but
it's only safe approach on light memory pressure, on heavy pressure
it'll early-oom not to call ->writepage, and if cache is very
important and system has little ram, not going in lru order may also
screw fs-cache performance), but I didn't see any max-stack usage hard
numbers, to back the claim that we're going to overflow.

In any case I'd prefer to be able to still call ->writepage if memory
pressure is high (at some point when priority going down and
collecting clean cache doesn't still satisfy the allocation), during
allocations in direct reclaim and increase the THREAD_SIZE than doing
this purely for stack reasons as the VM will lose reliability if we
forbid ->writepage at all in direct reclaim. Throttling on kswapd is
possible but it's probably less efficient and on the stack we know
exactly which kind of memory we should allocate, kswapd doesn't and it
works global.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
