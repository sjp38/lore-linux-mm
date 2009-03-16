Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0E9E86B0047
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 12:37:41 -0400 (EDT)
Date: Mon, 16 Mar 2009 09:32:11 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [aarcange@redhat.com: [PATCH] fork vs gup(-fast) fix]
In-Reply-To: <200903170323.45917.nickpiggin@yahoo.com.au>
Message-ID: <alpine.LFD.2.00.0903160927240.3675@localhost.localdomain>
References: <1237007189.25062.91.camel@pasglop> <200903141620.45052.nickpiggin@yahoo.com.au> <20090316223612.4B2A.A69D9226@jp.fujitsu.com> <200903170323.45917.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@elte.hu>, Nick Piggin <npiggin@novell.com>, Hugh Dickins <hugh@veritas.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>



On Tue, 17 Mar 2009, Nick Piggin wrote:
> > Yes, my patch isn't realy solusion.
> > Andrea already pointed out that it's not O_DIRECT issue, it's gup vs fork
> > issue. *and* my patch is crazy slow :)
> 
> Well, it's an interesting question. I'd say it probably is more than
> just O_DIRECT. vmsplice too, for example (which I think is much harder
> to fix this way because the pages are retired by the other end of
> the pipe, so I don't think you can hold a lock across it).

Well, only the "fork()" has the race problem.

So having a fork-specific lock (but not naming it by directio) actually 
does make sense. The fork is much less performance-critical than most 
random mmap_sem users - and doesn't have the same scalability issues 
either (ie people probably _do_ want to do mmap/munmap/brk concurrently 
with gup lookup, but there's much less worry about concurrent fork() 
performance).

It doesn't necessarily make the general problem go away, but it makes the 
_particular_ race between get_user_pages() and fork() go away. Then you 
can do per-page flags or whatever and not have to worry about concurrent 
lookups.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
