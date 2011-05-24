Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 46B7D6B0011
	for <linux-mm@kvack.org>; Tue, 24 May 2011 08:21:18 -0400 (EDT)
Received: from j77219.upc-j.chello.nl ([24.132.77.219] helo=dyad.programming.kicks-ass.net)
	by casper.infradead.org with esmtpsa (Exim 4.76 #1 (Red Hat Linux))
	id 1QOqc2-0001Tu-Az
	for linux-mm@kvack.org; Tue, 24 May 2011 12:21:26 +0000
Subject: Re: [PATCH 4/4] writeback: reduce per-bdi dirty threshold ramp up
 time
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20110418145929.GH5557@quack.suse.cz>
References: <20110413220444.GF4648@quack.suse.cz>
	 <20110413233122.GA6097@localhost> <20110413235211.GN31057@dastard>
	 <20110414002301.GA9826@localhost> <20110414151424.GA367@localhost>
	 <20110414181609.GH5054@quack.suse.cz> <20110415034300.GA23430@localhost>
	 <20110415143711.GA17181@localhost> <20110415221314.GE5432@quack.suse.cz>
	 <1302942809.2388.254.camel@twins>  <20110418145929.GH5557@quack.suse.cz>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 24 May 2011 14:24:29 +0200
Message-ID: <1306239869.2497.50.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Dave Chinner <david@fromorbit.com>, Andrew Morton <akpm@linux-foundation.org>, Richard Kennedy <richard@rsk.demon.co.uk>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>

Sorry for the delay, life got interesting and then it slipped my mind.

On Mon, 2011-04-18 at 16:59 +0200, Jan Kara wrote:
>   Your formula is:
> p(j)=\sum_i x_i(j)/(t_i*2^{i+1})
>   where $i$ sums from 0 to \infty, x_i(j) is the number of events of type
> $j$ in period $i$, $t_i$ is the total number of events in period $i$.

Actually:

 p_j = \Sum_{i=0} (d/dt_i) * x_j / 2^(i+1)

[ discrete differential ]

Where x_j is the total number of events for the j-th element of the set
and t_i is the i-th last period.

Also, the 1/2^(i+1) factor ensures recent history counts heavier while
still maintaining a normalized distribution.

Furthermore, by measuring time in the same measure as the events we get:

 t = \Sum_i x_i

which yields that:

 p_j = x_j * {\Sum_i (d/dt_i)} * {\Sum 2^(-i-1)}
     = x_j * (1/t) * 1

Thus

 \Sum_j p_j = \Sum_j x_j / (\Sum_i x_i) = 1

>   I want to compute
> l(j)=\sum_i x_i(j)/2^{i+1}
> g=\sum_i t_i/2^{i+1}
>   and
> p(j)=l(j)/g

Which gives me:

 p_j = x_j * \Sum_i 1/t_i
     = x_j / t

Again, if we then measure t in the same events as x, such that:

 t = \Sum_i x_i

we again get:

 \Sum_j p_j = \Sum_j x_j / \Sum_i x_i = 1

However, if you start measuring t differently that breaks, and the
result is no longer normalized and thus not suitable as a proportion.

Furthermore, while x_j/t is an average, it does not have decaying
history, resulting in past behaviour always affecting current results.
The decaying history thing will ensure that past behaviour will slowly
be 'forgotten' so that when the media is used differently (seeky to
non-seeky workload transition) the slow writeout speed will be forgotten
and we'll end up at the high writeout speed corresponding to less seeks.
Your average will end up hovering in the middle of the slow and fast
modes.

>   Clearly, all these values can be computed in O(1).

True, but you get to keep x and t counts over all history, which could
lead to overflow scenarios (although switching to u64 should mitigate
that problem in our lifetime).

>  Now for t_i = t for every
> i, the results of both formulas are the same (which is what made me make my
> mistake).

I'm not actually seeing how the averages will be the same, as explained,
yours seems to never forget history.

>  But when t_i differ, the results are different.

>From what I can tell, when you stop measuring t in the same events as x
everything comes down because then the sum of proportions isn't
normalized.

>  I'd say that the
> new formula also provides a meaningful notion of writeback share although
> it's hard to quantify how far the computations will be in practice...

s/far/fair/ ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
