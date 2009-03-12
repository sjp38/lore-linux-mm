Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 5999A6B003D
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 13:20:33 -0400 (EDT)
From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [aarcange@redhat.com: [PATCH] fork vs gup(-fast) fix]
Date: Fri, 13 Mar 2009 04:20:27 +1100
References: <20090311170611.GA2079@elte.hu> <200903130323.41193.nickpiggin@yahoo.com.au> <20090312170010.GT27823@random.random>
In-Reply-To: <20090312170010.GT27823@random.random>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200903130420.28772.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Nick Piggin <npiggin@novell.com>, Hugh Dickins <hugh@veritas.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Friday 13 March 2009 04:00:11 Andrea Arcangeli wrote:
> On Fri, Mar 13, 2009 at 03:23:40AM +1100, Nick Piggin wrote:
> > OK, this is as far as I got tonight.
> >
> > This passes Andrea's dma_thread test case. I haven't started hugepages,
> > and it isn't quite right to drop the mmap_sem and retake it for write
> > in get_user_pages (firstly, caller might hold mmap_sem for write,
> > secondly, it may not be able to tolerate mmap_sem being dropped).
>
> What's the point?

Well the main point is to avoid atomics and barriers and stuff like
that especially in the fast gup path. It also seems very much smaller
(the vast majority of the change is the addition of decow function).


> I mean this will simply work worse than my patch
> because it'll have to don't-cow the whole range regardless if it's
> pinned or not. Which will slowdown fork in the O_DIRECT case even
> more, for no good reason. 

Hmm, maybe. It probably can possibly work entirely without the vm_flag
and just use the page flag, however. Yes I think it could, and that
might just avoid the whole problem of modifying vm_flags in gup. I'll
have to consider it more tomorrow.

But this case is just if we want to transparently support this without
too much intrusive. Apps that know and care very much could use
MADV_DONTFORK to avoid the copy completely.


> I thought the complaint here was only a
> beauty issue of not wanting to add a function called fork_pre_cow or
> your equivalent decow_one_pte in the fork path, not any practical
> issue with my patch which already passed all sort of regression
> testing and performance valuations.

My complaint is not decow / pre cow (I think I suggested it as the
fix for the problem in the first place). I think the patch is quite
complex and is quite a slowdown for fast gup (especially with
hugepages). I'm just trying to explore different approach.


> Plus you still have a per-page
> bitflag,

Sure. It's the atomic operations which I want to try to minimise.


> and I think you have implementation issues in the patch (the
> parent pte can't be left writeable if you are in a don't-cow vma, or
> the copy will not be atomic, and glibc will have no chance to fix its
> bugs)

Oh, we need to do that? OK, then just take out that statement, and
change VM_BUG_ON(PageDontCOW()) in do_wp_page to
VM_BUG_ON(PageDontCOW() && !reuse);

> . You're not removing the fork_pre_cow logic from fork, so I can
> only see it as a regression to make the logic less granular in the
> vma.

I'll see if it can be made per-page. But I still don't know if it
is a big problem. It's hard to know exactly what crazy things apps
require to be fast.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
