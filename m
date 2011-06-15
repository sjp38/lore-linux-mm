Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id E80A46B0012
	for <linux-mm@kvack.org>; Wed, 15 Jun 2011 15:25:11 -0400 (EDT)
Date: Wed, 15 Jun 2011 12:24:35 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: REGRESSION: Performance regressions from switching
 anon_vma->lock to mutex
Message-Id: <20110615122435.386731e0.akpm@linux-foundation.org>
In-Reply-To: <BANLkTikt88KnxTy8TuGGVrBVnXvsnL7nMQ@mail.gmail.com>
References: <1308097798.17300.142.camel@schen9-DESK>
	<1308134200.15315.32.camel@twins>
	<1308135495.15315.38.camel@twins>
	<BANLkTikt88KnxTy8TuGGVrBVnXvsnL7nMQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Tim Chen <tim.c.chen@linux.intel.com>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Russell King <rmk@arm.linux.org.uk>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Tony Luck <tony.luck@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Namhyung Kim <namhyung@gmail.com>, ak@linux.intel.com, shaohua.li@intel.com, alex.shi@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Rafael J. Wysocki" <rjw@sisk.pl>

On Wed, 15 Jun 2011 12:11:19 -0700
Linus Torvalds <torvalds@linux-foundation.org> wrote:

> So using anonymous kernel threads is actually a real downside. It
> makes it much less obvious what is going on. We saw that exact same
> thing with the generic worker thread conversions: things that used to
> have clear performance issues ("oh, the iwl-phy0 thread is using 3% of
> CPU time because it is polling for IO, and I can see that in 'top'")
> turned into much-harder-to-see issues ("oh, kwork0 us using 3% CPU
> time according to 'top' - I have no idea why").

Yes, this is an issue with the memcg async reclaim patches.  One
implementation uses a per-memcg kswapd and you can then actually see
what it's doing, and see when it goes nuts (as kswapd threads like to
do).  The other implementation uses worker threads and you have no clue
what's going on.

It could be that if more things move away from dedicated threads and
into worker threads, we'll need to build a separate accounting system
so we can see how much time worker threads are spending on a
per-handler basis.  Which means a new top-like tool, etc.

That's all pretty nasty and is a tradeoff which should be considered
when making thread-vs-worker decisions.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
