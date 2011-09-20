Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id A0EF79000C9
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 08:19:52 -0400 (EDT)
Date: Tue, 20 Sep 2011 14:19:36 +0200
From: Johannes Weiner <jweiner@redhat.com>
Subject: Re: [patch 0/5] mm: per-zone dirty limiting
Message-ID: <20110920121742.GE11489@redhat.com>
References: <1311625159-13771-1-git-send-email-jweiner@redhat.com>
 <20110726154741.GE3010@suse.de>
 <20110726180559.GA667@redhat.com>
 <20110729110510.GS3010@suse.de>
 <20110802121733.GA24434@redhat.com>
 <20110803131811.GF19099@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110803131811.GF19099@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Jan Kara <jack@suse.cz>, Andi Kleen <ak@linux.intel.com>, linux-kernel@vger.kernel.org

Hi, sorry for the long delay,

On Wed, Aug 03, 2011 at 02:18:11PM +0100, Mel Gorman wrote:
> On Tue, Aug 02, 2011 at 02:17:33PM +0200, Johannes Weiner wrote:
> > My theory is that the closer (file_pages - dirty_pages) is to the high
> > watermark which kswapd tries to balance to, the more likely it is to
> > run into dirty pages.  And to my knowledge, these tests are run with a
> > non-standard 40% dirty ratio, which lowers the threshold at which
> > perzonedirty falls apart.  Per-zone dirty limits should probably take
> > the high watermark into account.
> > 
> 
> That would appear sensible. The choice of 40% dirty ratio is deliberate.
> My understanding is a number of servers that are IO intensive will have
> dirty ratio tuned to this value. On bug reports I've seen for distro
> kernels related to IO slowdowns, it seemed to be a common choice. I
> suspect it's tuned to this because it used to be the old default. Of
> course, 40% also made the writeback problem worse so the effect of the
> patches is easier to see.

Agreed.

It was just meant as an observation/possible explanation for why this
might exacerbate adverse effects, no blaming, rest assured :)

I added a patch that excludes reserved pages from dirtyable memory and
file writes are now down to the occassional hundred pages once in ten
runs, even with a dirty ratio of 40%.  I even ran a test with 40%
background and 80% foreground limit for giggles and still no writeouts
from reclaim with this patch, so this was probably it.

> > What makes me wonder, is that in addition, something in perzonedirty
> > makes kswapd less efficient in the 4G tests, which is the opposite
> > effect it had in all other setups.  This increases direct reclaim
> > invocations against the preferred Normal zone.  The higher pressure
> > could also explain why reclaim rushes through the clean pages and runs
> > into dirty pages quicker.
> > 
> > Does anyone have a theory about what might be going on here?
> > 
> 
> This is tenuous at best and I confess I have not thought deeply
> about it but it could be due to the relative age of the pages in the
> highest zone.
> 
> In the vanilla kernel, the Normal zone gets filled with dirty pages
> first and then the lower zones get used up until dirty ratio when
> flusher threads get woken. Because the highest zone also has the
> oldest pages and presumably the oldest inodes, the zone gets fully
> cleaned by the flusher. The pattern is "fill zone with dirty pages,
> use lower zones, highest zone gets fully cleaned reclaimed and refilled
> with dirty pages, repeat"
> 
> In the patched kernel, lower zones are used when the dirty limits of a
> zone are met and the flusher threads are woken to clean a small number
> of pages but not the full zone. Reclaim takes the clean pages and they
> get replaced with younger dirty pages. Over time, the highest zone
> becomes a mix of old and young dirty pages. The flusher threads run
> but instead of cleaning the highest zone first, it is cleaning a mix
> of pages both all the zones. If this was the case, kswapd would end
> up writing more pages from the higher zone and stalling as a result.
> 
> A further problem could be that direct reclaimers are hitting that new
> congestion_wait(). Unfortunately, I was not running with stats enabled
> to see what the congestion figures looked like.

The throttling could indeed uselessly force a NOFS allocation to wait
a bit without making progress, so kswapd could in turn get stuck
waiting on that allocator when calling into the fs.

I dropped the throttling completely for now and the zone dirty limits
are only applied in the allocator fast path to distribute allocations,
but not throttle/writeback anything.  The direct reclaim invocations
are no longer increased.

This leaves the problem to allocations whose allowable zones are in
sum not big enough to trigger the global limit, but the series is
still useful without it and we can handle such situations in later
patches.

Thanks for your input, Mel, I'll shortly send out the latest revision.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
