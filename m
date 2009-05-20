Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 1698E6B004F
	for <linux-mm@kvack.org>; Tue, 19 May 2009 21:58:15 -0400 (EDT)
Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4K1x7lS010877
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 20 May 2009 10:59:08 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 88DD145DE5B
	for <linux-mm@kvack.org>; Wed, 20 May 2009 10:59:07 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5A6CB45DE53
	for <linux-mm@kvack.org>; Wed, 20 May 2009 10:59:07 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 28C851DB803F
	for <linux-mm@kvack.org>; Wed, 20 May 2009 10:59:07 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9CC73E08002
	for <linux-mm@kvack.org>; Wed, 20 May 2009 10:59:06 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2/3] vmscan: make mapped executable pages the first class  citizen
In-Reply-To: <20090520014445.GA7645@localhost>
References: <2f11576a0905190528n5eb29e3fme42785a76eed3551@mail.gmail.com> <20090520014445.GA7645@localhost>
Message-Id: <20090520105159.743B.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 20 May 2009 10:59:05 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Christoph Lameter <cl@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Elladan <elladan@eskimo.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

> On Tue, May 19, 2009 at 08:28:28PM +0800, KOSAKI Motohiro wrote:
> > Hi
> > 
> > 2009/5/19 Wu Fengguang <fengguang.wu@intel.com>:
> > > On Tue, May 19, 2009 at 04:06:35PM +0800, KOSAKI Motohiro wrote:
> > >> > > > Like the console mode, the absolute nr_mapped drops considerably - to 1/13 of
> > >> > > > the original size - during the streaming IO.
> > >> > > >
> > >> > > > The delta of pgmajfault is 3 vs 107 during IO, or 236 vs 393 during the whole
> > >> > > > process.
> > >> > >
> > >> > > hmmm.
> > >> > >
> > >> > > about 100 page fault don't match Elladan's problem, I think.
> > >> > > perhaps We missed any addional reproduce condition?
> > >> >
> > >> > Elladan's case is not the point of this test.
> > >> > Elladan's IO is use-once, so probably not a caching problem at all.
> > >> >
> > >> > This test case is specifically devised to confirm whether this patch
> > >> > works as expected. Conclusion: it is.
> > >>
> > >> Dejection ;-)
> > >>
> > >> The number should address the patch is useful or not. confirming as expected
> > >> is not so great.
> > >
> > > OK, let's make the conclusion in this way:
> > >
> > > The changelog analyzed the possible beneficial situation, and this
> > > test backs that theory with real numbers, ie: it successfully stops
> > > major faults when the active file list is slowly scanned when there
> > > are partially cache hot streaming IO.
> > >
> > > Another (amazing) finding of the test is, only around 1/10 mapped pages
> > > are actively referenced in the absence of user activities.
> > >
> > > Shall we protect the remaining 9/10 inactive ones? This is a question ;-)
> > 
> > Unfortunately, I don't reproduce again.
> > I don't apply your patch yet. but mapped ratio is reduced only very little.
> 
> mapped ratio or absolute numbers? The ratio wont change much because
> nr_mapped is already small.

My box is running Fedora 10 initlevel 5 (GNOME desktop).

many GNOME component is mapped very many process (likes >50).
Thus, these page aren't dropped by typical any workload.



> > I think smem can show which library evicted.  Can you try it?
> > 
> > download:  http://www.selenic.com/smem/
> > usage:   ./smem -m -r --abbreviate
> 
> Sure, but I don't see much change in its output (see attachments).
> 
> smem-console-0 is collected after fresh boot,
> smem-console-1 is collected after the big IO.

hmmmm, your result has following characatistics.

- no graphics component
- very few mapped library
  (it is almost only zsh library)

Can you try test on X environment?



> > We can't decide 9/10 is important or not. we need know actual evicted file list.
> 
> Right. But what I measured is the activeness. Almost zero major page
> faults means the evicted 90% mapped pages are inactive during the
> long 300 seconds of IO.

Agreed.
IOW, I don't think your test environment is typical desktop...




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
