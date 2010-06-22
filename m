Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id BF5CB6B01DA
	for <linux-mm@kvack.org>; Tue, 22 Jun 2010 09:18:16 -0400 (EDT)
Date: Tue, 22 Jun 2010 15:17:46 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH RFC] mm: Implement balance_dirty_pages() through
 waiting for flusher thread
Message-ID: <20100622131745.GB3338@quack.suse.cz>
References: <1276797878-28893-1-git-send-email-jack@suse.cz>
 <20100618060901.GA6590@dastard>
 <20100621233628.GL3828@quack.suse.cz>
 <20100622054409.GP7869@dastard>
 <20100621231416.904c50c7.akpm@linux-foundation.org>
 <20100622100924.GQ7869@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100622100924.GQ7869@dastard>
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, hch@infradead.org, peterz@infradead.org, wfg@mail.ustc.edu.cn
List-ID: <linux-mm.kvack.org>

On Tue 22-06-10 20:09:24, Dave Chinner wrote:
> On Mon, Jun 21, 2010 at 11:14:16PM -0700, Andrew Morton wrote:
> > On Tue, 22 Jun 2010 15:44:09 +1000 Dave Chinner <david@fromorbit.com> wrote:
> > 
> > > > > And so on. This isn't necessarily bad - we'll throttle for longer
> > > > > than we strictly need to - but the cumulative counter resolution
> > > > > error gets worse as the number of CPUs doing IO completion grows.
> > > > > Worst case ends up at for (num cpus * 31) + 1 pages of writeback for
> > > > > just the first waiter. For an arbitrary FIFO queue of depth d, the
> > > > > worst case is more like d * (num cpus * 31 + 1).
> > > >   Hmm, I don't see how the error would depend on the FIFO depth.
> > > 
> > > It's the cumulative error that depends on the FIFO depth, not the
> > > error seen by a single waiter.
> > 
> > Could use the below to basically eliminate the inaccuracies.
> > 
> > Obviously things might get a bit expensive in certain threshold cases
> > but with some hysteresis that should be manageable.
> 
> That seems a lot more... unpredictable than modifying the accounting
> to avoid cumulative errors.
> 
> > +	/* Check to see if rough count will be sufficient for comparison */
> > +	if (abs(count - rhs) > (percpu_counter_batch*num_online_cpus())) {
> 
> Also, that's a big margin when we are doing equality matches for
> every page IO completion. If we a large CPU count machine where
> per-cpu counters actually improve performance (say 16p) then we're
> going to be hitting the slow path for the last 512 pages of every
> waiter. Hence I think the counter sum is compared too often to scale
> with this method of comparison.
  On the other hand I think we will have to come up with something
more clever than what I do now because for some huge machines with
nr_cpu_ids == 256, the error of the counter is 256*9*8 = 18432 so that's
already unacceptable given the amounts we want to check (like 1536) -
already for nr_cpu_ids == 32, the error is the same as the difference we
want to check.  I think we'll have to come up with some scheme whose error
is not dependent on the number of cpus or if it is dependent, it's only a
weak dependency (like a logarithm or so).
  Or we could rely on the fact that IO completions for a bdi won't happen on
all CPUs and thus the error would be much more bounded. But I'm not sure
how much that is true or not.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
