Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 0896C6B00E8
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 16:25:41 -0400 (EDT)
Subject: Re: REGRESSION: Performance regressions from switching
 anon_vma->lock to mutex
From: Tim Chen <tim.c.chen@linux.intel.com>
In-Reply-To: <BANLkTim5TPKQ9RdLYRxy=mphOVKw5EXvTA@mail.gmail.com>
References: <1308097798.17300.142.camel@schen9-DESK>
	 <1308101214.15392.151.camel@sli10-conroe> <1308138750.15315.62.camel@twins>
	 <20110615161827.GA11769@tassilo.jf.intel.com>
	 <1308156337.2171.23.camel@laptop> <1308163398.17300.147.camel@schen9-DESK>
	 <1308169937.15315.88.camel@twins> <4DF91CB9.5080504@linux.intel.com>
	 <1308172336.17300.177.camel@schen9-DESK> <1308173849.15315.91.camel@twins>
	 <BANLkTim5TPKQ9RdLYRxy=mphOVKw5EXvTA@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 16 Jun 2011 13:26:12 -0700
Message-ID: <1308255972.17300.450.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andi Kleen <ak@linux.intel.com>, Shaohua Li <shaohua.li@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Russell King <rmk@arm.linux.org.uk>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, "Luck, Tony" <tony.luck@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Namhyung Kim <namhyung@gmail.com>, "Shi, Alex" <alex.shi@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Rafael J. Wysocki" <rjw@sisk.pl>

On Wed, 2011-06-15 at 18:50 -0700, Linus Torvalds wrote:

> 
> Tim, have you tried running your bigger load with that patch? You
> could try my patch on top too just to match Peter's tree, but I doubt
> that's the big first-order issue.
> 
>                        Linus

I ran exim with different kernel versions.  Using 2.6.39-vanilla
kernel as a baseline, the results are as follow:

			Throughput
2.6.39(vanilla)		100.0%
2.6.39+ra-patch 	166.7%  (+66.7%)	(note: tmpfs readahead patchset is merged in 3.0-rc2)
3.0-rc2(vanilla)	 68.0%	(-32%)
3.0-rc2+linus		115.7%	(+15.7%)
3.0-rc2+linus+softirq	 86.2%	(-17.3%)

So Linus' patch certainly helped things over vanilla 3.0-rc2, but throughput is still 
less than the 2.6.39 with the readahead patch set.  The softirq patch I used was from Ingo's
combined patch from Shaohua and Paul.  It seems odd that it makes things worse.  I will
recheck this data probably just this patch and without Linus' patch later.

I also notice that the run to run variations have increased quite a bit for 3.0-rc2.
I'm using 6 runs per kernel.  Perhaps a side effect of converting the anon_vma->lock to mutex?

			(Max-Min)/avg 
2.6.39(vanilla)		3%
2.6.39+ra-patch 	3%	
3.0-rc2(vanilla)	20% 
3.0-rc2+linus		36%
3.0-rc2+linus+softirq	40% 

Thanks.

Tim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
