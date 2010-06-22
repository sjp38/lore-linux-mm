Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 56F816B01ED
	for <linux-mm@kvack.org>; Tue, 22 Jun 2010 10:24:21 -0400 (EDT)
Date: Tue, 22 Jun 2010 22:24:02 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH RFC] mm: Implement balance_dirty_pages() through
 waiting for flusher thread
Message-ID: <20100622142402.GA12860@localhost>
References: <1276797878-28893-1-git-send-email-jack@suse.cz>
 <20100618060901.GA6590@dastard>
 <20100621233628.GL3828@quack.suse.cz>
 <20100622054409.GP7869@dastard>
 <20100621231416.904c50c7.akpm@linux-foundation.org>
 <20100622100924.GQ7869@dastard>
 <20100622131745.GB3338@quack.suse.cz>
 <20100622135234.GA11561@localhost>
 <20100622140258.GE3338@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100622140258.GE3338@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
To: Jan Kara <jack@suse.cz>
Cc: Dave Chinner <david@fromorbit.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "hch@infradead.org" <hch@infradead.org>, "peterz@infradead.org" <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 22, 2010 at 10:02:59PM +0800, Jan Kara wrote:
> On Tue 22-06-10 21:52:34, Wu Fengguang wrote:
> > >   On the other hand I think we will have to come up with something
> > > more clever than what I do now because for some huge machines with
> > > nr_cpu_ids == 256, the error of the counter is 256*9*8 = 18432 so that's
> > > already unacceptable given the amounts we want to check (like 1536) -
> > > already for nr_cpu_ids == 32, the error is the same as the difference we
> > > want to check.  I think we'll have to come up with some scheme whose error
> > > is not dependent on the number of cpus or if it is dependent, it's only a
> > > weak dependency (like a logarithm or so).
> > >   Or we could rely on the fact that IO completions for a bdi won't happen on
> > > all CPUs and thus the error would be much more bounded. But I'm not sure
> > > how much that is true or not.
> > 
> > Yes the per CPU counter seems tricky. How about plain atomic operations? 
> > 
> > This test shows that atomic_dec_and_test() is about 4.5 times slower
> > than plain i-- in a 4-core CPU. Not bad.
> > 
> > Note that
> > 1) we can avoid the atomic operations when there are no active waiters
> > 2) most writeback will be submitted by one per-bdi-flusher, so no worry
> >    of cache bouncing (this also means the per CPU counter error is
> >    normally bounded by the batch size)
>   Yes, writeback will be submitted by one flusher thread but the question
> is rather where the writeback will be completed. And that depends on which
> CPU that particular irq is handled. As far as my weak knowledge of HW goes,
> this very much depends on the system configuration (i.e., irq affinity and
> other things).

Either the irq goes to the io submit CPU, or some fixed CPU (somehow
determined by the bdi?) I guess?  My wild guess is, it may be bad for
the irq to goto some random CPU...

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
