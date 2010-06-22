Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 8702D6B0071
	for <linux-mm@kvack.org>; Tue, 22 Jun 2010 18:46:12 -0400 (EDT)
Date: Wed, 23 Jun 2010 08:45:51 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH RFC] mm: Implement balance_dirty_pages() through
 waiting for flusher thread
Message-ID: <20100622224551.GS7869@dastard>
References: <1276797878-28893-1-git-send-email-jack@suse.cz>
 <20100618060901.GA6590@dastard>
 <20100621233628.GL3828@quack.suse.cz>
 <20100622054409.GP7869@dastard>
 <20100621231416.904c50c7.akpm@linux-foundation.org>
 <20100622100924.GQ7869@dastard>
 <20100622131745.GB3338@quack.suse.cz>
 <20100622135234.GA11561@localhost>
 <20100622143124.GA15235@infradead.org>
 <20100622143856.GG3338@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100622143856.GG3338@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
To: Jan Kara <jack@suse.cz>
Cc: Christoph Hellwig <hch@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, peterz@infradead.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 22, 2010 at 04:38:56PM +0200, Jan Kara wrote:
> On Tue 22-06-10 10:31:24, Christoph Hellwig wrote:
> > On Tue, Jun 22, 2010 at 09:52:34PM +0800, Wu Fengguang wrote:
> > > 2) most writeback will be submitted by one per-bdi-flusher, so no worry
> > >    of cache bouncing (this also means the per CPU counter error is
> > >    normally bounded by the batch size)
> > 
> > What counter are we talking about exactly?  Once balanance_dirty_pages
>   The new per-bdi counter I'd like to introduce.
> 
> > stops submitting I/O the per-bdi flusher thread will in fact be
> > the only thing submitting writeback, unless you count direct invocations
> > of writeback_single_inode.
>   Yes, I agree that the per-bdi flusher thread should be the only thread
> submitting lots of IO (there is direct reclaim or kswapd if we change
> direct reclaim but those should be negligible). So does this mean that
> also I/O completions will be local to the CPU running per-bdi flusher
> thread? Because the counter is incremented from the I/O completion
> callback.

By default we set QUEUE_FLAG_SAME_COMP, which means we hand
completions back to the submitter CPU during blk_complete_request().
Completion processing is then handled by a softirq on the CPU
selected for completion processing.

This was done, IIRC, because it provided some OLTP benchmark 1-2%
better results. It can, however, be turned off via
/sys/block/<foo>/queue/rq_affinity, and there's no guarantee that
the completion processing doesn't get handled off to some other CPU
(e.g. via a workqueue) so we cannot rely on this completion
behaviour to avoid cacheline bouncing.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
