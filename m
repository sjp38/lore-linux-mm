Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 103A96B003D
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 13:00:37 -0400 (EDT)
Date: Thu, 12 Mar 2009 18:00:11 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [aarcange@redhat.com: [PATCH] fork vs gup(-fast) fix]
Message-ID: <20090312170010.GT27823@random.random>
References: <20090311170611.GA2079@elte.hu> <alpine.LFD.2.00.0903111143150.32478@localhost.localdomain> <200903121636.18867.nickpiggin@yahoo.com.au> <200903130323.41193.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200903130323.41193.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Nick Piggin <npiggin@novell.com>, Hugh Dickins <hugh@veritas.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 13, 2009 at 03:23:40AM +1100, Nick Piggin wrote:
> OK, this is as far as I got tonight.
> 
> This passes Andrea's dma_thread test case. I haven't started hugepages,
> and it isn't quite right to drop the mmap_sem and retake it for write
> in get_user_pages (firstly, caller might hold mmap_sem for write,
> secondly, it may not be able to tolerate mmap_sem being dropped).

What's the point? I mean this will simply work worse than my patch
because it'll have to don't-cow the whole range regardless if it's
pinned or not. Which will slowdown fork in the O_DIRECT case even
more, for no good reason. I thought the complaint here was only a
beauty issue of not wanting to add a function called fork_pre_cow or
your equivalent decow_one_pte in the fork path, not any practical
issue with my patch which already passed all sort of regression
testing and performance valuations. Plus you still have a per-page
bitflag, and I think you have implementation issues in the patch (the
parent pte can't be left writeable if you are in a don't-cow vma, or
the copy will not be atomic, and glibc will have no chance to fix its
bugs). You're not removing the fork_pre_cow logic from fork, so I can
only see it as a regression to make the logic less granular in the
vma.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
