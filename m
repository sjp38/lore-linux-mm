Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id B32E86B0169
	for <linux-mm@kvack.org>; Wed,  3 Aug 2011 15:06:45 -0400 (EDT)
Date: Wed, 3 Aug 2011 21:06:23 +0200
From: Johannes Weiner <jweiner@redhat.com>
Subject: Re: [patch 4/5] mm: writeback: throttle __GFP_WRITE on per-zone
 dirty limits
Message-ID: <20110803190623.GA5873@redhat.com>
References: <1311625159-13771-1-git-send-email-jweiner@redhat.com>
 <1311625159-13771-5-git-send-email-jweiner@redhat.com>
 <20110725203705.GA21691@tassilo.jf.intel.com>
 <CAEwNFnARzetfqZqjh_9-d+FOHtrCEwaSxgqBy_D+apxsNqzqkg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAEwNFnARzetfqZqjh_9-d+FOHtrCEwaSxgqBy_D+apxsNqzqkg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org

On Tue, Jul 26, 2011 at 08:40:59AM +0900, Minchan Kim wrote:
> Hi Andi,
> 
> On Tue, Jul 26, 2011 at 5:37 AM, Andi Kleen <ak@linux.intel.com> wrote:
> >> The global dirty limits are put in proportion to the respective zone's
> >> amount of dirtyable memory and the allocation denied when the limit of
> >> that zone is reached.
> >>
> >> Before the allocation fails, the allocator slowpath has a stage before
> >> compaction and reclaim, where the flusher threads are kicked and the
> >> allocator ultimately has to wait for writeback if still none of the
> >> zones has become eligible for allocation again in the meantime.
> >>
> >
> > I don't really like this. It seems wrong to make memory
> > placement depend on dirtyness.
> >
> > Just try to explain it to some system administrator or tuner: her
> > head will explode and for good reasons.
> >
> > On the other hand I like doing round-robin in filemap by default
> > (I think that is what your patch essentially does)
> > We should have made  this default long ago. It avoids most of the
> > "IO fills up local node" problems people run into all the time.
> >
> > So I would rather just change the default in filemap allocation.

It's not only a problem that exists solely on a node-level but also on
a zone-level.  Round-robin over the nodes does not fix the problem
that a small zone can fill up with dirty pages before the global dirty
limit kicks in.

> Just out of curiosity.
> Why do you want to consider only filemap allocation, not IO(ie,
> filemap + sys_[read/write]) allocation?

I guess Andi was referring to the page cache (mapping file offsets to
pages), rather than mmaps (mapping virtual addresses to pages).

mm/filemap.c::__page_cache_alloc()

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
