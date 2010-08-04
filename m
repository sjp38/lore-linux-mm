Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 704386B02A4
	for <linux-mm@kvack.org>; Wed,  4 Aug 2010 18:57:55 -0400 (EDT)
Date: Wed, 4 Aug 2010 15:56:10 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC PATCH 0/2] Prioritise inodes and zones for writeback
 required by page reclaim
Message-Id: <20100804155610.2a0d5e1f.akpm@linux-foundation.org>
In-Reply-To: <1280932711-23696-1-git-send-email-mel@csn.ul.ie>
References: <1280932711-23696-1-git-send-email-mel@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Wu Fengguang <fengguang.wu@intel.com>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed,  4 Aug 2010 15:38:29 +0100
Mel Gorman <mel@csn.ul.ie> wrote:

> Commenting on the series "Reduce writeback from page reclaim context V6"
> Andrew Morton noted;
> 
>   direct-reclaim wants to write a dirty page because that page is in the
>   zone which the caller wants to allocate from!  Telling the flusher threads
>   to perform generic writeback will sometimes cause them to just gum the
>   disk up with pages from different zones, making it even harder/slower to
>   allocate a page from the zones we're interested in, no?
> 
> On the machines used to test the series, there were relatively few zones
> and only one BDI so the scenario describes is a possibility. This series is
> a very early prototype series aimed at mitigating the problem.
> 
> Patch 1 adds wakeup_flusher_threads_pages() which takes a list of pages
> from page reclaim. Each inode belonging to a page on the list is marked
> I_DIRTY_RECLAIM. When the flusher thread wakes, inodes with this tag are
> unconditionally moved to the wb->b_io list for writing.
> 
> Patch 2 notes that writing back inodes does not necessarily write back
> pages belonging to the zone page reclaim is concerned with. In response, it
> adds a zone and counter to wb_writeback_work. As pages from the target zone
> are written, the zone-specific counter is updated. When the flusher thread
> then checks the zone counters if a specific zone is being targeted. While
> more pages may be written than necessary, the assumption is that the pages
> need cleaning eventually, the inode must be relatively old to have pages at
> the end of the LRU, the IO will be relatively efficient due to less random
> seeks and that pages from the target zone will still be cleaned.
> 
> Testing did not show any significant differences in terms of reducing dirty
> file pages being written back but the lack of multiple BDIs and NUMA nodes in
> the test rig is a problem. Maybe someone else has access to a more suitable
> test rig.
> 
> Any comment as to the suitability for such a direction?

um.  Might work.  Isn't pretty though.

But until we can demonstrate the problem or someone reports it, we
probably have more important issues to be looking at ;) I think that a
better approach is to try to trigger this problem as we develop and
test reclaim.  And if we _can't_ demonstrate it, work out why the heck
not - either the code's smarter than we thought it was or the test is
no good.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
