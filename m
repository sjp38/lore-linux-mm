Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 8B31E6B005C
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 12:50:22 -0400 (EDT)
From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [aarcange@redhat.com: [PATCH] fork vs gup(-fast) fix]
Date: Tue, 17 Mar 2009 03:50:12 +1100
References: <1237007189.25062.91.camel@pasglop> <200903170323.45917.nickpiggin@yahoo.com.au> <alpine.LFD.2.00.0903160927240.3675@localhost.localdomain>
In-Reply-To: <alpine.LFD.2.00.0903160927240.3675@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200903170350.13665.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@elte.hu>, Nick Piggin <npiggin@novell.com>, Hugh Dickins <hugh@veritas.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tuesday 17 March 2009 03:32:11 Linus Torvalds wrote:
> On Tue, 17 Mar 2009, Nick Piggin wrote:
> > > Yes, my patch isn't realy solusion.
> > > Andrea already pointed out that it's not O_DIRECT issue, it's gup vs
> > > fork issue. *and* my patch is crazy slow :)
> >
> > Well, it's an interesting question. I'd say it probably is more than
> > just O_DIRECT. vmsplice too, for example (which I think is much harder
> > to fix this way because the pages are retired by the other end of
> > the pipe, so I don't think you can hold a lock across it).
>
> Well, only the "fork()" has the race problem.
>
> So having a fork-specific lock (but not naming it by directio) actually
> does make sense. The fork is much less performance-critical than most
> random mmap_sem users - and doesn't have the same scalability issues
> either (ie people probably _do_ want to do mmap/munmap/brk concurrently
> with gup lookup, but there's much less worry about concurrent fork()
> performance).
>
> It doesn't necessarily make the general problem go away, but it makes the
> _particular_ race between get_user_pages() and fork() go away. Then you
> can do per-page flags or whatever and not have to worry about concurrent
> lookups.

Hmm, I see what you mean there; it can be used to solve Andrea's race
instead of using set_bit/memory barriers. But I think then you would
still need to put this lock in fork and get_user_pages[_fast], *and*
still do most of the other stuff required in Andrea's patch.

So I'm not sure if that was KAMEZAWA-san's patch.

It actually should solve one side of the race completely, as is, but
only for direct-IO. Because it ensures that no get_user_pages for direct
IO can be outstanding over a fork. However it does a) not solve other
get_user_pages problems, and b) doesn't solve the case where for
readonly get_user_pages on an already shared pte will get confused if it
is subsequently COWed -- it can end up being polluted with wrong data.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
