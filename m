Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 97BA58D0039
	for <linux-mm@kvack.org>; Thu, 17 Feb 2011 17:22:49 -0500 (EST)
Date: Thu, 17 Feb 2011 14:22:09 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: vmscan: Stop reclaim/compaction earlier due to
 insufficient progress if !__GFP_REPEAT
Message-Id: <20110217142209.8736cca1.akpm@linux-foundation.org>
In-Reply-To: <20110216095048.GA4473@csn.ul.ie>
References: <20110209154606.GJ27110@cmpxchg.org>
	<20110209164656.GA1063@csn.ul.ie>
	<20110209182846.GN3347@random.random>
	<20110210102109.GB17873@csn.ul.ie>
	<20110210124838.GU3347@random.random>
	<20110210133323.GH17873@csn.ul.ie>
	<20110210141447.GW3347@random.random>
	<20110210145813.GK17873@csn.ul.ie>
	<20110216095048.GA4473@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, Kent Overstreet <kent.overstreet@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 16 Feb 2011 09:50:49 +0000
Mel Gorman <mel@csn.ul.ie> wrote:

> should_continue_reclaim() for reclaim/compaction allows scanning to continue
> even if pages are not being reclaimed until the full list is scanned. In
> terms of allocation success, this makes sense but potentially it introduces
> unwanted latency for high-order allocations such as transparent hugepages
> and network jumbo frames that would prefer to fail the allocation attempt
> and fallback to order-0 pages.  Worse, there is a potential that the full
> LRU scan will clear all the young bits, distort page aging information and
> potentially push pages into swap that would have otherwise remained resident.

afaict the patch affects order-0 allocations as well.  What are the
implications of this?

Also, what might be the downsides of this change, and did you test for
them?

> This patch will stop reclaim/compaction if no pages were reclaimed in the
> last SWAP_CLUSTER_MAX pages that were considered.

a) Why SWAP_CLUSTER_MAX?  Is (SWAP_CLUSTER_MAX+7) better or worse?

b) The sentence doesn't seem even vaguely accurate.  shrink_zone()
   will scan vastly more than SWAP_CLUSTER_MAX pages before calling
   should_continue_reclaim().  Confused.

c) The patch doesn't "stop reclaim/compaction" fully.  It stops it
   against one zone.  reclaim will then advance on to any other
   eligible zones.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
