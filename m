Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 3B62F6B0012
	for <linux-mm@kvack.org>; Fri, 17 Jun 2011 14:02:18 -0400 (EDT)
Received: from mail-wy0-f169.google.com (mail-wy0-f169.google.com [74.125.82.169])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p5HI1gVs013457
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Fri, 17 Jun 2011 11:01:43 -0700
Received: by wyf19 with SMTP id 19so2541924wyf.14
        for <linux-mm@kvack.org>; Fri, 17 Jun 2011 11:01:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.00.1106171040460.7018@sister.anvils>
References: <1308097798.17300.142.camel@schen9-DESK> <1308101214.15392.151.camel@sli10-conroe>
 <1308138750.15315.62.camel@twins> <20110615161827.GA11769@tassilo.jf.intel.com>
 <1308156337.2171.23.camel@laptop> <1308163398.17300.147.camel@schen9-DESK>
 <1308169937.15315.88.camel@twins> <4DF91CB9.5080504@linux.intel.com>
 <1308172336.17300.177.camel@schen9-DESK> <1308173849.15315.91.camel@twins>
 <BANLkTim5TPKQ9RdLYRxy=mphOVKw5EXvTA@mail.gmail.com> <1308255972.17300.450.camel@schen9-DESK>
 <BANLkTinptaydNvK4ZvGvy0KVLnRmmza7tA@mail.gmail.com> <BANLkTi=GPtwjQ-bYDNUYCwzW5h--y86Law@mail.gmail.com>
 <BANLkTim-dBjva9w7AajqggKT3iUVYG2euQ@mail.gmail.com> <BANLkTimLV8aCZ7snXT_Do+f4vRY0EkoS4A@mail.gmail.com>
 <BANLkTinUBTYWxrF5TCuDSQuFUAyivXJXjQ@mail.gmail.com> <1308310080.2355.19.camel@twins>
 <BANLkTim2bmPfeRT1tS7hx2Z85QHjPHwU3Q@mail.gmail.com> <alpine.LSU.2.00.1106171040460.7018@sister.anvils>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 17 Jun 2011 11:01:08 -0700
Message-ID: <BANLkTim3vo0vpovV=5sU=GLxkotheB=Ryg@mail.gmail.com>
Subject: Re: REGRESSION: Performance regressions from switching anon_vma->lock
 to mutex
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Shaohua Li <shaohua.li@intel.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Russell King <rmk@arm.linux.org.uk>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, "Luck, Tony" <tony.luck@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Namhyung Kim <namhyung@gmail.com>, "Shi, Alex" <alex.shi@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Rafael J. Wysocki" <rjw@sisk.pl>

On Fri, Jun 17, 2011 at 10:41 AM, Hugh Dickins <hughd@google.com> wrote:
>
> Applying load with those two patches applied (combined patch shown at
> the bottom, in case you can tell me I misunderstood what to apply,
> and have got the wrong combination on), lockdep very soon protested.

Combined patch looks good, it's just the one without the NULL ptr tests removed.

And yup, that makes sense. Since we now hold the anon_vma lock over an
allocation, the memory allocation might want to start to free things.

> I've not given it _any_ thought, and won't be able to come back to
> it for a couple of hours: chucked over the wall for your delectation.

It's a mis-feature of "page_referenced()": we can call it without
holding any page locks ("is_locked=0"), and that function will then do
a try_lock() on the page, and just consider it referenced if it
failed.

HOWEVER, the code to then do the same thing for the anon_vma lock
doesn't do the same trylock model, because it used to be a spinlock:
so there was "no need" (since you can never do a non-atomic allocation
from within a spinlock).

So this is arguably a bug in memory reclaim, but sicne the
mutex->spinlock conversion had been pretty mindless, nobody noticed
until the mutex region grew.

So I do think that "page_referenced_anon()" should do a trylock, and
return "referenced" if the trylock fails. Comments?

That said, we have a few other mutexes that are just not allowed to be
held over an allocation. page_referenced_file() has that
mapping->i_mmap_mutex lock, for example. So maybe the rule just has to
be "you cannot hold anon_vma lock over an allocation". Which would be
sad: one of the whole _points_ of turning it from a spinlock to a
mutex would be that it relaxes the locking rules a lot (and not just
the preemptibility)

                      Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
