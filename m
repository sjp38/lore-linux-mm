Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 39CBD6B00F0
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 17:16:04 -0400 (EDT)
Received: from mail-wy0-f169.google.com (mail-wy0-f169.google.com [74.125.82.169])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p5GLG0GF012282
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 14:16:01 -0700
Received: by wyf19 with SMTP id 19so1763734wyf.14
        for <linux-mm@kvack.org>; Thu, 16 Jun 2011 14:15:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1308255972.17300.450.camel@schen9-DESK>
References: <1308097798.17300.142.camel@schen9-DESK> <1308101214.15392.151.camel@sli10-conroe>
 <1308138750.15315.62.camel@twins> <20110615161827.GA11769@tassilo.jf.intel.com>
 <1308156337.2171.23.camel@laptop> <1308163398.17300.147.camel@schen9-DESK>
 <1308169937.15315.88.camel@twins> <4DF91CB9.5080504@linux.intel.com>
 <1308172336.17300.177.camel@schen9-DESK> <1308173849.15315.91.camel@twins>
 <BANLkTim5TPKQ9RdLYRxy=mphOVKw5EXvTA@mail.gmail.com> <1308255972.17300.450.camel@schen9-DESK>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 16 Jun 2011 13:47:32 -0700
Message-ID: <BANLkTinptaydNvK4ZvGvy0KVLnRmmza7tA@mail.gmail.com>
Subject: Re: REGRESSION: Performance regressions from switching anon_vma->lock
 to mutex
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andi Kleen <ak@linux.intel.com>, Shaohua Li <shaohua.li@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Russell King <rmk@arm.linux.org.uk>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, "Luck, Tony" <tony.luck@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Namhyung Kim <namhyung@gmail.com>, "Shi, Alex" <alex.shi@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Rafael J. Wysocki" <rjw@sisk.pl>

On Thu, Jun 16, 2011 at 1:26 PM, Tim Chen <tim.c.chen@linux.intel.com> wrot=
e:
>
> I ran exim with different kernel versions. =A0Using 2.6.39-vanilla
> kernel as a baseline, the results are as follow:
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Throughput
> 2.6.39(vanilla) =A0 =A0 =A0 =A0 100.0%
> 2.6.39+ra-patch =A0 =A0 =A0 =A0 166.7% =A0(+66.7%) =A0 =A0 =A0 =A0(note: =
tmpfs readahead patchset is merged in 3.0-rc2)
> 3.0-rc2(vanilla) =A0 =A0 =A0 =A0 68.0% =A0(-32%)
> 3.0-rc2+linus =A0 =A0 =A0 =A0 =A0 115.7% =A0(+15.7%)
> 3.0-rc2+linus+softirq =A0 =A086.2% =A0(-17.3%)

Ok, so batching the semaphore operations makes more of a difference
than I would have expected.

I guess I'll cook up an improved patch that does it for the vma exit
case too, and see if that just makes the semaphores be a non-issue.

> I also notice that the run to run variations have increased quite a bit f=
or 3.0-rc2.
> I'm using 6 runs per kernel. =A0Perhaps a side effect of converting the a=
non_vma->lock to mutex?

So the thing about using the mutexes is that heavy contention on a
spinlock is very stable: it may be *slow*, but it's reliable, nicely
queued, and has very few surprises.

On a mutex, heavy contention results in very subtle behavior, with the
adaptive spinning often - but certainly not always - making the mutex
act as a spinlock, but once you have lots of contention the adaptive
spinning breaks down. And then you have lots of random interactions
with the scheduler and 'need_resched' etc.

The only valid answer to lock contention is invariably always just
"don't do that then". We've been pretty good at getting rid of
problematic locks, but this one clearly isn't one of the ones we've
fixed ;)

                        Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
