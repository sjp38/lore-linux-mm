Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id BE450900086
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 10:59:34 -0400 (EDT)
Date: Mon, 18 Apr 2011 16:59:29 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 4/4] writeback: reduce per-bdi dirty threshold ramp up
 time
Message-ID: <20110418145929.GH5557@quack.suse.cz>
References: <20110413220444.GF4648@quack.suse.cz>
 <20110413233122.GA6097@localhost>
 <20110413235211.GN31057@dastard>
 <20110414002301.GA9826@localhost>
 <20110414151424.GA367@localhost>
 <20110414181609.GH5054@quack.suse.cz>
 <20110415034300.GA23430@localhost>
 <20110415143711.GA17181@localhost>
 <20110415221314.GE5432@quack.suse.cz>
 <1302942809.2388.254.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1302942809.2388.254.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Jan Kara <jack@suse.cz>, Wu Fengguang <fengguang.wu@intel.com>, Dave Chinner <david@fromorbit.com>, Andrew Morton <akpm@linux-foundation.org>, Richard Kennedy <richard@rsk.demon.co.uk>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>

On Sat 16-04-11 10:33:29, Peter Zijlstra wrote:
> On Sat, 2011-04-16 at 00:13 +0200, Jan Kara wrote:
> > 
> > So what is a takeaway from this for me is that scaling the period
> > with the dirty limit is not the right thing. If you'd have 4-times more
> > memory, your choice of "dirty limit" as the period would be as bad as
> > current 4*"dirty limit". What would seem like a better choice of period
> > to me would be to have the period in an order of a few seconds worth of
> > writeback. That would allow the bdi limit to scale up reasonably fast when
> > new bdi starts to be used and still not make it fluctuate that much
> > (hopefully).
> 
> No best would be to scale the period with the writeout bandwidth, but
> lacking that the dirty limit had to do. Since we're counting pages, and
> bandwidth is pages/second we'll end up with a time measure, exactly the
> thing you wanted.
  Yes, I was thinking about this as well. We could measure the throughput
but essentially it's a changing entity (dependent on the type of load and
possibly other things like network load for NFS, or other machines
accessing your NAS). So I'm not sure one constant value will work (esp.
because you have to measure it and you never know at which state you did
the measurement). And when you have changing values, you have to solve the
same problem as with time based periods - that's how I came to them.

> > Looking at math in lib/proportions.c, nothing really fundamental requires
> > that each period has the same length. So it shouldn't be hard to actually
> > create proportions calculator that would have timer triggered periods -
> > simply whenever the timer fires, we would declare a new period. The only
> > things which would be broken by this are (t represents global counter of
> > events):
> > a) counting of periods as t/period_len - we would have to maintain global
> > period counter but that's trivial
> > b) trick that we don't do t=t/2 for each new period but rather use
> > period_len/2+(t % (period_len/2)) when calculating fractions - again we
> > would have to bite the bullet and divide the global counter when we declare
> > new period but again it's not a big deal in our case.
> > 
> > Peter what do you think about this? Do you (or anyone else) think it makes
> > sense? 
> 
> But if you don't have a fixed sized period, then how do you catch up on
> fractions that haven't been updated for several periods? You cannot go
> remember all the individual period lengths.
  OK, I wrote the expressions down and the way I want to do it would get
different fractions than your original formula:

  Your formula is:
p(j)=\sum_i x_i(j)/(t_i*2^{i+1})
  where $i$ sums from 0 to \infty, x_i(j) is the number of events of type
$j$ in period $i$, $t_i$ is the total number of events in period $i$.

  I want to compute
l(j)=\sum_i x_i(j)/2^{i+1}
g=\sum_i t_i/2^{i+1}
  and
p(j)=l(j)/g

  Clearly, all these values can be computed in O(1). Now for t_i = t for every
i, the results of both formulas are the same (which is what made me make my
mistake). But when t_i differ, the results are different. I'd say that the
new formula also provides a meaningful notion of writeback share although
it's hard to quantify how far the computations will be in practice...
  
> The whole trick to the proportion stuff is that its all O(1) regardless
> of the number of contestants. There isn't a single loop that iterates
> over all BDIs or tasks to update their cycle, that wouldn't have scaled.
  Sure, I understand.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
