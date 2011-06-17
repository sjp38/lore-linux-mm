Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 8DCCD6B0012
	for <linux-mm@kvack.org>; Fri, 17 Jun 2011 12:54:02 -0400 (EDT)
Received: from mail-wy0-f169.google.com (mail-wy0-f169.google.com [74.125.82.169])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p5HGrY4o007434
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Fri, 17 Jun 2011 09:53:35 -0700
Received: by wyf19 with SMTP id 19so2490061wyf.14
        for <linux-mm@kvack.org>; Fri, 17 Jun 2011 09:53:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1308310080.2355.19.camel@twins>
References: <1308097798.17300.142.camel@schen9-DESK> <1308101214.15392.151.camel@sli10-conroe>
 <1308138750.15315.62.camel@twins> <20110615161827.GA11769@tassilo.jf.intel.com>
 <1308156337.2171.23.camel@laptop> <1308163398.17300.147.camel@schen9-DESK>
 <1308169937.15315.88.camel@twins> <4DF91CB9.5080504@linux.intel.com>
 <1308172336.17300.177.camel@schen9-DESK> <1308173849.15315.91.camel@twins>
 <BANLkTim5TPKQ9RdLYRxy=mphOVKw5EXvTA@mail.gmail.com> <1308255972.17300.450.camel@schen9-DESK>
 <BANLkTinptaydNvK4ZvGvy0KVLnRmmza7tA@mail.gmail.com> <BANLkTi=GPtwjQ-bYDNUYCwzW5h--y86Law@mail.gmail.com>
 <BANLkTim-dBjva9w7AajqggKT3iUVYG2euQ@mail.gmail.com> <BANLkTimLV8aCZ7snXT_Do+f4vRY0EkoS4A@mail.gmail.com>
 <BANLkTinUBTYWxrF5TCuDSQuFUAyivXJXjQ@mail.gmail.com> <1308310080.2355.19.camel@twins>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 17 Jun 2011 09:36:48 -0700
Message-ID: <BANLkTim2bmPfeRT1tS7hx2Z85QHjPHwU3Q@mail.gmail.com>
Subject: Re: REGRESSION: Performance regressions from switching anon_vma->lock
 to mutex
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Shaohua Li <shaohua.li@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Russell King <rmk@arm.linux.org.uk>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, "Luck, Tony" <tony.luck@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Namhyung Kim <namhyung@gmail.com>, "Shi, Alex" <alex.shi@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Rafael J. Wysocki" <rjw@sisk.pl>

On Fri, Jun 17, 2011 at 4:28 AM, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
>
> Something like so? Compiles and runs the benchmark in question.

Yup.

Except I really think that test for a NULL anon_vma should go away.

If an avc entry has a NULL anon_vma, something is seriously wrong. The
comment about anon_vma_fork failure is definitely just bogus: the
anon_vma is allocated before the avc entry, so there's no way a avc
can have a NULL anon_vma from there.

But yes, your patch is cleaner than the one I was playing around with
(your "remove if not list empty" is prettier than what I was toying
with - having a separate flag in the avc)

Tim, can you test Peter's (second - the cleaned up one) patch on top
of mine, and see if that helps things further?

The only thing I don't love about the batching is that we now do hold
the lock over some situations where we _could_ have allowed
concurrency (notably some avc allocations), but I think it's a good
trade-off. And walking the list twice at unlink_anon_vmas() should be
basically free.

                       Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
