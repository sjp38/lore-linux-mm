Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id ED7C66B0092
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 16:15:00 -0400 (EDT)
Message-ID: <4DFA6442.9000103@linux.intel.com>
Date: Thu, 16 Jun 2011 13:14:58 -0700
From: Andi Kleen <ak@linux.intel.com>
MIME-Version: 1.0
Subject: Re: REGRESSION: Performance regressions from switching anon_vma->lock
 to mutex
References: <1308097798.17300.142.camel@schen9-DESK> <1308101214.15392.151.camel@sli10-conroe> <1308138750.15315.62.camel@twins> <20110615161827.GA11769@tassilo.jf.intel.com> <1308156337.2171.23.camel@laptop> <1308163398.17300.147.camel@schen9-DESK> <1308169937.15315.88.camel@twins> <4DF91CB9.5080504@linux.intel.com> <1308172336.17300.177.camel@schen9-DESK> <1308173849.15315.91.camel@twins> <87ea4bd7-8b16-4b24-8fcb-d8e9b6f421ec@email.android.com> <4DF92FE1.5010208@linux.intel.com> <BANLkTi=Tw6je7zpi4L=pE0JJpZfeEC9Jsg@mail.gmail.com>
In-Reply-To: <BANLkTi=Tw6je7zpi4L=pE0JJpZfeEC9Jsg@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Tim Chen <tim.c.chen@linux.intel.com>, Shaohua Li <shaohua.li@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Russell King <rmk@arm.linux.org.uk>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, "Luck, Tony" <tony.luck@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Namhyung Kim <namhyung@gmail.com>, "Shi, Alex" <alex.shi@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Rafael J. Wysocki" <rjw@sisk.pl>


> /proc/stat may be slow, but it's not slower than doing real work -
> unless you call it millions of times.


I haven't analyzed it in detail, but I suspect it's some cache line 
bounce, which
can slow things down quite a lot.  Also the total number of invocations
is quite high (hundreds of messages per core * 32 cores)

Ok even with cache line bouncing it's suspicious.

> And you didn't actually look at glibc sources, did you?

I did, but I gave up fully following that code path because it's so 
convoluted :-/

Ok if you want I can implement caching in the LD_PRELOAD and see
if it changes things.

> There is very clearly no caching going on. And since exim doesn't even
> execve, it just forks, it's very clear that it could cache things just
> ONCE, so your argument that caching wouldn't be possible at that level
> is also bogus.

So you mean caching it at startup time? Otherwise the parent would
need to do sysconf() at least , which it doesn't do (the exim source doesn't
really know anything about libdb internals)

That would add /proc/stat overhead to every program execution. Is that 
what you
are proposing?

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
