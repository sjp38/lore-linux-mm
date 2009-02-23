Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id CC38B6B00B9
	for <linux-mm@kvack.org>; Mon, 23 Feb 2009 10:22:39 -0500 (EST)
From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [RFC PATCH 00/20] Cleanup and optimise the page allocator
Date: Tue, 24 Feb 2009 02:22:03 +1100
References: <1235344649-18265-1-git-send-email-mel@csn.ul.ie> <200902240146.03456.nickpiggin@yahoo.com.au> <20090223150055.GK6740@csn.ul.ie>
In-Reply-To: <20090223150055.GK6740@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200902240222.04645.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>
List-ID: <linux-mm.kvack.org>

On Tuesday 24 February 2009 02:00:56 Mel Gorman wrote:
> On Tue, Feb 24, 2009 at 01:46:01AM +1100, Nick Piggin wrote:

> > free_page_mlock shouldn't really be in free_pages_check, but oh well.
>
> Agreed, I took it out of there.

Oh good. I didn't notice that.


> > > Patch 16 avoids using the zonelist cache on non-NUMA machines
> > >
> > > Patch 17 removes an expensive and excessively paranoid check in the
> > > allocator fast path
> >
> > I would be careful of removing useful debug checks completely like
> > this. What is the cost? Obviously non-zero, but it is also a check
>
> The cost was something like 1/10th the cost of the path. There are atomic
> operations in there that are causing the problems.

The only atomic memory operations in there should be atomic loads of
word or atomic_t sized and aligned locations, which should just be
normal loads on any architecture?

The only atomic RMW you might see in that function would come from
free_page_mlock (which you moved out of there, and anyway can be
made non-atomic).

I'd like you to just reevaluate it after your patchset, after the
patch to make mlock non-atomic, and my patch I just sent.


> > I have seen trigger on quite a lot of occasions (due to kernel bugs
> > and hardware bugs, and in each case it is better to warn than not,
> > even if many other situations can go undetected).
>
> Have you really seen it trigger for the allocation path or did it
> trigger in teh free path? Essentially we are making the same check on
> every allocation and free which is why I considered it excessivly
> paranoid.

Yes I've seen it trigger in the allocation path. Kernel memory scribbles
or RAM errors.


> > One problem is that some of the calls we're making in page_alloc.c
> > do the compound_head() thing, wheras we know that we only want to
> > look at this page. I've attached a patch which cuts out about 150
> > bytes of text and several branches from these paths.
>
> Nice, I should have spotted that. I'm going to fold this into the series
> if that is ok with you? I'll replace patch 17 with it and see does it
> still show up on profiles.

Great! Sure fold it in (and put SOB: me on there if you like).


> > > So, by and large it's an improvement of some sort.
> >
> > Most of these benchmarks *really* need to be run quite a few times to get
> > a reasonable confidence.
>
> Most are run repeatedly and an average taken but I should double check
> what is going on. It's irritating that gains/regressions are
> inconsistent between different machine types but that is nothing new.

Yeah. Cache behaviour maybe. One thing you might try is to size the struct
page out to 64 bytes if it isn't already. This could bring down any skews
if one kernel is lucky to get a nice packing of pages, or another is unlucky
to get lots of struct pages spread over 2 cachelines. Maybe I'm just
thinking wishfully :)

I think with many of your changes, common sense will tell us that it is a
better code sequence. Sometimes it's just impossible to really get
"scientific proof" :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
