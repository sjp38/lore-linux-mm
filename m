Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id DAB6E6B0044
	for <linux-mm@kvack.org>; Tue,  1 May 2012 10:13:41 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so2917122pbb.14
        for <linux-mm@kvack.org>; Tue, 01 May 2012 07:13:41 -0700 (PDT)
Date: Tue, 1 May 2012 23:13:30 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [patch 5/5] mm: refault distance-based file cache sizing
Message-ID: <20120501141330.GA2207@barrios>
References: <1335861713-4573-1-git-send-email-hannes@cmpxchg.org>
 <1335861713-4573-6-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1335861713-4573-6-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Hi Hannes,

On Tue, May 01, 2012 at 10:41:53AM +0200, Johannes Weiner wrote:
> To protect frequently used page cache (workingset) from bursts of less
> frequently used or one-shot cache, page cache pages are managed on two
> linked lists.  The inactive list is where all cache starts out on
> fault and ends on reclaim.  Pages that get accessed another time while
> on the inactive list get promoted to the active list to protect them
> from reclaim.
> 
> Right now we have two main problems.
> 
> One stems from numa allocation decisions and how the page allocator
> and kswapd interact.  The both of them can enter into a perfect loop
> where kswapd reclaims from the preferred zone of a task, allowing the
> task to continuously allocate from that zone.  Or, the node distance
> can lead to the allocator to do direct zone reclaim to stay in the
> preferred zone.  This may be good for locality, but the task has only

Understood.

> the inactive space of that one zone to get its memory activated.
> Forcing the allocator to spread out to lower zones in the right
> situation makes the difference between continuous IO to serve the
> workingset, or taking the numa cost but serving fully from memory.

It's hard to parse your word due to my dumb brain.
Could you elaborate on it?
It would be a good if you say with example.

> 
> The other issue is that with the two lists alone, we can never detect
> when a new set of data with equal access frequency should be cached if
> the size of it is bigger than total/allowed memory minus the active
> set.  Currently we have the perfect compromise given those
> constraints: the active list is not allowed to grow bigger than the
> inactive list.  This means that we can protect cache from reclaim only

Okay.

> up to half of memory, and don't recognize workingset changes that are
> bigger than half of memory.

Workingset change?
You mean if new workingset is bigger than half of memory and it's like
stream before retouch, we could cache only part of working set because 
head pages on working set would be discared by tail pages of working set
in inactive list?

I'm sure I totally coudln't parse your point.
Could you explain in detail? Before reading your approach and diving into code,
I would like to see the problem clearly.

Thanks.
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
