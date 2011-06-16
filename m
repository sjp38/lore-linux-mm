Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 61D806B0012
	for <linux-mm@kvack.org>; Wed, 15 Jun 2011 21:50:44 -0400 (EDT)
Received: from mail-ww0-f45.google.com (mail-ww0-f45.google.com [74.125.82.45])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p5G1od8H020365
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Wed, 15 Jun 2011 18:50:40 -0700
Received: by wwi36 with SMTP id 36so883158wwi.26
        for <linux-mm@kvack.org>; Wed, 15 Jun 2011 18:50:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1308173849.15315.91.camel@twins>
References: <1308097798.17300.142.camel@schen9-DESK> <1308101214.15392.151.camel@sli10-conroe>
 <1308138750.15315.62.camel@twins> <20110615161827.GA11769@tassilo.jf.intel.com>
 <1308156337.2171.23.camel@laptop> <1308163398.17300.147.camel@schen9-DESK>
 <1308169937.15315.88.camel@twins> <4DF91CB9.5080504@linux.intel.com>
 <1308172336.17300.177.camel@schen9-DESK> <1308173849.15315.91.camel@twins>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 15 Jun 2011 18:50:18 -0700
Message-ID: <BANLkTim5TPKQ9RdLYRxy=mphOVKw5EXvTA@mail.gmail.com>
Subject: Re: REGRESSION: Performance regressions from switching anon_vma->lock
 to mutex
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Tim Chen <tim.c.chen@linux.intel.com>
Cc: Andi Kleen <ak@linux.intel.com>, Shaohua Li <shaohua.li@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Russell King <rmk@arm.linux.org.uk>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, "Luck, Tony" <tony.luck@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Namhyung Kim <namhyung@gmail.com>, "Shi, Alex" <alex.shi@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Rafael J. Wysocki" <rjw@sisk.pl>

On Wed, Jun 15, 2011 at 2:37 PM, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
>
> http://programming.kicks-ass.net/sekrit/39-2.txt.bz2
> http://programming.kicks-ass.net/sekrit/tip-2.txt.bz2
>
> tip+sirq+linus is still slightly faster than .39 here,

Hmm. Your profile doesn't show the mutex slowpath at all, so there's a
big difference to the one Tim quoted parts of.

In fact, your profile looks fine. The load clearly spends tons of time
in page faulting and in timing things (that read_hpet thing is
disgusting), but with that in mind, the profile doesn't look scary.
Yes, the 2% spinlock time is bad, but you've clearly not hit the real
lock contention case. The mutex lock shows up, but _way_ below the
spinlock, and the slowpath never shows at all. You end up having
mutex_spin_on_owner at 0.09%, it's not really visible.

Clearly going from your two-socket 12-core thing to Tim's four-socket
40-core case is a big jump. But maybe it really was about RCU, and
even the limited softirq patch that moves the grace period stuff etc
back to softirqs ends up helping.

Tim, have you tried running your bigger load with that patch? You
could try my patch on top too just to match Peter's tree, but I doubt
that's the big first-order issue.

                       Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
