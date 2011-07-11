Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id B11296B007E
	for <linux-mm@kvack.org>; Mon, 11 Jul 2011 15:09:44 -0400 (EDT)
Message-ID: <4E1B4A64.6040403@redhat.com>
Date: Mon, 11 Jul 2011 15:09:24 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 03/27] xfs: use write_cache_pages for writeback clustering
References: <20110629140109.003209430@bombadil.infradead.org> <20110629140336.950805096@bombadil.infradead.org> <20110701022248.GM561@dastard> <20110701041851.GN561@dastard> <20110701093305.GA28531@infradead.org> <20110701154136.GA17881@localhost> <20110704032534.GD1026@dastard> <20110706151229.GA1998@redhat.com> <20110708095456.GI1026@dastard> <20110711172050.GA2849@redhat.com>
In-Reply-To: <20110711172050.GA2849@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Dave Chinner <david@fromorbit.com>, Wu Fengguang <fengguang.wu@intel.com>, Christoph Hellwig <hch@infradead.org>, Mel Gorman <mgorman@suse.de>, "xfs@oss.sgi.com" <xfs@oss.sgi.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 07/11/2011 01:20 PM, Johannes Weiner wrote:

> I CC'd Rik for reclaim-wizardry.  But if I am not completly off with
> this there is a chance that the change that let the active list grow
> unscanned may actually have contributed to this single-page writing
> problem becoming worse?

Yes, the patch probably contributed.

However, the patch does help protect the working set in
the page cache from streaming IO, so on balance I believe
we need to keep this change.

What it changes is that the size of the inactive file list
can no longer grow unbounded, keeping it a little smaller
than it could have grown in the past.

> commit 56e49d218890f49b0057710a4b6fef31f5ffbfec
> Author: Rik van Riel<riel@redhat.com>
> Date:   Tue Jun 16 15:32:28 2009 -0700
>
>      vmscan: evict use-once pages first
>
>      When the file LRU lists are dominated by streaming IO pages, evict those
>      pages first, before considering evicting other pages.
>
>      This should be safe from deadlocks or performance problems
>      because only three things can happen to an inactive file page:
>
>      1) referenced twice and promoted to the active list
>      2) evicted by the pageout code
>      3) under IO, after which it will get evicted or promoted
>
>      The pages freed in this way can either be reused for streaming IO, or
>      allocated for something else.  If the pages are used for streaming IO,
>      this pageout pattern continues.  Otherwise, we will fall back to the
>      normal pageout pattern.
>
>      Signed-off-by: Rik van Riel<riel@redhat.com>
>      Reported-by: Elladan<elladan@eskimo.com>
>      Cc: KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>
>      Cc: Peter Zijlstra<peterz@infradead.org>
>      Cc: Lee Schermerhorn<lee.schermerhorn@hp.com>
>      Acked-by: Johannes Weiner<hannes@cmpxchg.org>
>      Signed-off-by: Andrew Morton<akpm@linux-foundation.org>
>      Signed-off-by: Linus Torvalds<torvalds@linux-foundation.org>


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
