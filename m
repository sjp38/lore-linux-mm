Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8C3BF6B00F2
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 17:28:08 -0400 (EDT)
Received: from mail-wy0-f169.google.com (mail-wy0-f169.google.com [74.125.82.169])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p5GLRZYO014233
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 14:27:37 -0700
Received: by wyf19 with SMTP id 19so1771630wyf.14
        for <linux-mm@kvack.org>; Thu, 16 Jun 2011 14:27:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTinptaydNvK4ZvGvy0KVLnRmmza7tA@mail.gmail.com>
References: <1308097798.17300.142.camel@schen9-DESK> <1308101214.15392.151.camel@sli10-conroe>
 <1308138750.15315.62.camel@twins> <20110615161827.GA11769@tassilo.jf.intel.com>
 <1308156337.2171.23.camel@laptop> <1308163398.17300.147.camel@schen9-DESK>
 <1308169937.15315.88.camel@twins> <4DF91CB9.5080504@linux.intel.com>
 <1308172336.17300.177.camel@schen9-DESK> <1308173849.15315.91.camel@twins>
 <BANLkTim5TPKQ9RdLYRxy=mphOVKw5EXvTA@mail.gmail.com> <1308255972.17300.450.camel@schen9-DESK>
 <BANLkTinptaydNvK4ZvGvy0KVLnRmmza7tA@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 16 Jun 2011 14:05:28 -0700
Message-ID: <BANLkTi=GPtwjQ-bYDNUYCwzW5h--y86Law@mail.gmail.com>
Subject: Re: REGRESSION: Performance regressions from switching anon_vma->lock
 to mutex
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andi Kleen <ak@linux.intel.com>, Shaohua Li <shaohua.li@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Russell King <rmk@arm.linux.org.uk>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, "Luck, Tony" <tony.luck@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Namhyung Kim <namhyung@gmail.com>, "Shi, Alex" <alex.shi@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Rafael J. Wysocki" <rjw@sisk.pl>

On Thu, Jun 16, 2011 at 1:47 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> I guess I'll cook up an improved patch that does it for the vma exit
> case too, and see if that just makes the semaphores be a non-issue.

Ok, I bet it doesn't make them a non-issue, but if doing this in
anon_vma_clone() helped a lot, then doing the exact same pattern in
unlink_anon_vmas() hopefully helps some more.

This patch is UNTESTED! It replaces my previous one (it's really just
an extension of it), and while I actually test-booted that previous
one I did *not* do it for this one. So please look out. But it's using
the exact same pattern, so there should be no real surprises.

Does it improve things further on your load?

(Btw, I'm not at all certain about that "we can get an empty
anon_vma_chain" comment. I left it - and the test for a NULL anon_vma
- in the code, but I think it's bogus. If we've linked in the
anon_vma_chain, it will have an anon_vma associated with it, I'm
pretty sure)

VM people, please do comment on both that "empty anon_vma_chain"
issue, and on whether we can ever have two different anon_vma roots in
the 'same_vma' list. I have that WARN_ON_ONCE() there in both paths, I
just wonder whether we should just inconditionally take the first
entry in the list and lock it outside the whole loop instead?

Peter? Hugh?

                           Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
