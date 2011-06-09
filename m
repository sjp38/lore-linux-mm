Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 81DD86B004A
	for <linux-mm@kvack.org>; Thu,  9 Jun 2011 19:58:09 -0400 (EDT)
Date: Fri, 10 Jun 2011 01:58:00 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 4/4] writeback: reduce per-bdi dirty threshold ramp up
 time
Message-ID: <20110609235800.GI4926@quack.suse.cz>
References: <20110413235211.GN31057@dastard>
 <20110414002301.GA9826@localhost>
 <20110414151424.GA367@localhost>
 <20110414181609.GH5054@quack.suse.cz>
 <20110415034300.GA23430@localhost>
 <20110415143711.GA17181@localhost>
 <20110415221314.GE5432@quack.suse.cz>
 <1302942809.2388.254.camel@twins>
 <20110418145929.GH5557@quack.suse.cz>
 <1306239869.2497.50.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1306239869.2497.50.camel@laptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Jan Kara <jack@suse.cz>, Wu Fengguang <fengguang.wu@intel.com>, Dave Chinner <david@fromorbit.com>, Andrew Morton <akpm@linux-foundation.org>, Richard Kennedy <richard@rsk.demon.co.uk>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>

On Tue 24-05-11 14:24:29, Peter Zijlstra wrote:
> Sorry for the delay, life got interesting and then it slipped my mind.
  And I missed you reply so sorry for my delay as well :).

> On Mon, 2011-04-18 at 16:59 +0200, Jan Kara wrote:
> >   Your formula is:
> > p(j)=\sum_i x_i(j)/(t_i*2^{i+1})
> >   where $i$ sums from 0 to \infty, x_i(j) is the number of events of type
> > $j$ in period $i$, $t_i$ is the total number of events in period $i$.
> 
> Actually:
> 
>  p_j = \Sum_{i=0} (d/dt_i) * x_j / 2^(i+1)
> 
> [ discrete differential ]
> 
> Where x_j is the total number of events for the j-th element of the set
> and t_i is the i-th last period.
> 
> Also, the 1/2^(i+1) factor ensures recent history counts heavier while
> still maintaining a normalized distribution.
> 
> Furthermore, by measuring time in the same measure as the events we get:
> 
>  t = \Sum_i x_i
> 
> which yields that:
> 
>  p_j = x_j * {\Sum_i (d/dt_i)} * {\Sum 2^(-i-1)}
>      = x_j * (1/t) * 1
> 
> Thus
> 
>  \Sum_j p_j = \Sum_j x_j / (\Sum_i x_i) = 1
  Yup, I understand this.

> >   I want to compute
> > l(j)=\sum_i x_i(j)/2^{i+1}
> > g=\sum_i t_i/2^{i+1}
> >   and
> > p(j)=l(j)/g
> 
> Which gives me:
> 
>  p_j = x_j * \Sum_i 1/t_i
>      = x_j / t
  It cannot really be simplified like this - 2^{i+1} parts do not cancel
out in p(j). Let's write the formula in an iterative manner so that it
becomes clearer. The first step almost looks like the 2^{i+1} members can
cancel out (note that I use x_1 and t_1 instead of x_0 and t_0 so that I don't
have to renumber when going for the next step):
l'(j) = x_1/2 + l(j)/2
g' = t_1/2 + g/2
thus
p'(j) = l'(j) / g'
      = (x_1 + l(j))/2 / ((t_1 + g)/2)
      = (x_1 + l(j)) / (t_1+g)

But if you properly expand to the next step you'll get:
l''(j) = x_0/2 + l'(j)/2
       = x_0/2 + x_1/4 + l(j)/4
g'' = t_0/2 + g'/2
    = t_0/2 + t_1/4 + g/4
thus we only get:
p''(j) = l''(j)/g''
       = (x_0/2 + x_1/4 + l(j)/4) / (t_0/2 + t_1/4 + g/4)
       = (x_0 + x_1/2 + l(j)/2) / (t_0 + t_1/2 + g/2)

Hmm, I guess I should have written the formulas as

l(j) = \sum_i x_i(j)/2^i
g = \sum_i t_i/2^i

It is equivalent and less confusing for the iterative expression where
we get directly:

l'(j)=x_0+l(j)/2
g'=t_0+g/2

which directly shows what's going on.

> Again, if we then measure t in the same events as x, such that:
> 
>  t = \Sum_i x_i
> 
> we again get:
> 
>  \Sum_j p_j = \Sum_j x_j / \Sum_i x_i = 1
> 
> However, if you start measuring t differently that breaks, and the
> result is no longer normalized and thus not suitable as a proportion.
  The normalization works with my formula as you noted in your next email
(I just expand it here for other readers):
\Sum_j p_j = \Sum_j l(j)/g
           = 1/g * \Sum_j \Sum_i x_i(j)/2^(i+1)
	   = 1/g * \Sum_i (1/2^(i+1) * \Sum_j x_i(j))
(*)        = 1/g * \Sum_i t_i/2^(i+1)
           = 1

(*) Here we use that t_i = \Sum_j x_i(j) because that's the definition of
t_i.

Note that exactly same equality holds when 2^(i+1) is replaced with 2^i in
g and l(j).

> Furthermore, while x_j/t is an average, it does not have decaying
> history, resulting in past behaviour always affecting current results.
> The decaying history thing will ensure that past behaviour will slowly
> be 'forgotten' so that when the media is used differently (seeky to
> non-seeky workload transition) the slow writeout speed will be forgotten
> and we'll end up at the high writeout speed corresponding to less seeks.
> Your average will end up hovering in the middle of the slow and fast
> modes.
  So this the most disputable point of my formulas I believe :). You are
right that if, for example, nothing happens during a time slice (i.e. t_0 =
0, x_0(j)=0), the proportions don't change (well, after some time rounding
starts to have effect but let's ignore that for now). Generally, if
previously t_i was big and then became small (system bandwidth lowered;
e.g. t_5=10000, t_4=10, t_3=20,...,), it will take roughly log_2(maximum
t_i/current t_i) time slices for the contribution of terms with t_i big 
to become comparable with the contribution of later terms with t_i small.
After this number of time slices, proportions will catch up with the change.

On the other hand when t_i was small for some time and then becomes big,
proportions will effectively reflect current state. So when someone starts
writing to a device on otherwise quiet system, the device immediately gets
fraction close to 1.

I'm not sure how big problem the above behavior is or what would actually
be a desirable one...

> >   Clearly, all these values can be computed in O(1).
> 
> True, but you get to keep x and t counts over all history, which could
> lead to overflow scenarios (although switching to u64 should mitigate
> that problem in our lifetime).
  I think even 32-bit numbers might be fine. The numbers we need to keep are
of an order of total maximum bandwidth of the system. If you plug maxbw
instead of all x_i(j) and t_i, you'll get that l(j)=maxbw (or 2*maxbw if we
use 2^i in the formula) and similarly for g. So the math will work in
32-bits for a bandwidth of an order of TB per slice (which I expect to be
something between 0.1 and 10 s). Reasonable given today's HW although
probably we'll have to go to 64-bits soon, you are right.

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
