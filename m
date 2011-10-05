Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 5F9DA900149
	for <linux-mm@kvack.org>; Wed,  5 Oct 2011 09:56:24 -0400 (EDT)
Date: Wed, 5 Oct 2011 21:56:16 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 00/11] IO-less dirty throttling v12
Message-ID: <20111005135615.GA16438@localhost>
References: <20111003134228.090592370@intel.com>
 <20111004195206.GG28306@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111004195206.GG28306@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vivek Goyal <vgoyal@redhat.com>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Oct 05, 2011 at 03:52:06AM +0800, Vivek Goyal wrote:
> On Mon, Oct 03, 2011 at 09:42:28PM +0800, Wu Fengguang wrote:
> > Hi,
> > 
> > This is the minimal IO-less balance_dirty_pages() changes that are expected to
> > be regression free (well, except for NFS).
> > 
> >         git://github.com/fengguang/linux.git dirty-throttling-v12
> > 
> > Tests results will be posted in a separate email.
> 
> Looks like we are solving two problems.
> 
> - IO less balance_dirty_pages()
> - Throttling based on ratelimit instead of based on number of dirty pages.
> 
> The second piece is the one which has complicated calculations for
> calculating the global/bdi rates and logic for stablizing the rates etc.
> 
> IIUC, second piece is primarily needed for better latencies for writers.

Well, yes. The bdi->dirty_ratelimit estimation turns out to be the
most confusing part of the patchset... Other than the complexities,
the algorithm does work pretty well in the tests (except for small
memory cases, in which case its estimation accuracy no longer matters).

Note that the bdi->dirty_ratelimit thing, even when goes wrong, is
very unlikely to cause large regressions. The known regressions mostly
originate from the nature of IO-less.

> Will it make sense to break down this work in two patch series. First
> push IO less balance dirty pages and then all the complicated pieces
> of ratelimits.
> 
> ratelimit allowed you to come up with sleep time for the process. Without
> that I think you shall have to fall back to what Jan Kar had done, 
> calculation based on number of pages.

If dropping all the smoothness considerations, the minimal
implementation would be close to this patch:

        [PATCH 05/35] writeback: IO-less balance_dirty_pages()
        http://www.spinics.net/lists/linux-mm/msg12880.html

However the experiences were, it may lead to much worse latencies than
the vanilla one in JBOD cases. This is because vanilla kernel has the
option to break out of the loop when written enough pages, however the
IO-less balance_dirty_pages() will just wait until the dirty pages
drop below the (rushed high) bdi threshold, which could take long time.

Another question is, the IO-less balance_dirty_pages() is basically

        on every N pages dirtied, sleep for M jiffies

In current patchset, we get the desired N with formula

        N = bdi->dirty_ratelimit / desired_M

When dirty_ratelimit is not available, it would be a problem to
estimate the adequate N that works well for various workloads.

And to avoid regressions, patches 8,9,10,11 (maybe updated form) will
still be necessary. And a complete rerun of all the test cases and to
fix up any possible new regressions.

Overall it may cost too much (if possible at all, considering the two
problems listed above) to try out the above steps. The main intention
being "whether we can introduce the dirty_ratelimit complexities later".
Considering that the complexity itself is not likely causing problems
other than lose of smoothness, it looks beneficial to test the ready
made code earlier in production environments, rather than to take lots
of efforts to strip them out and test new code, only to add them back
in some future release.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
