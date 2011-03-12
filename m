Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id EA4618D003A
	for <linux-mm@kvack.org>; Fri, 11 Mar 2011 23:02:52 -0500 (EST)
Date: Sat, 12 Mar 2011 05:02:23 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] thp: mremap support and TLB optimization
Message-ID: <20110312040223.GL5641@random.random>
References: <20110311020410.GH5641@random.random>
 <AANLkTikZJqTtVF48cc-AQ1z9iF29Z+f35Qdn_1m_SFQi@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AANLkTikZJqTtVF48cc-AQ1z9iF29Z+f35Qdn_1m_SFQi@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>

Hi Hugh,

On Fri, Mar 11, 2011 at 11:44:03AM -0800, Hugh Dickins wrote:
> On Thu, Mar 10, 2011 at 6:04 PM, Andrea Arcangeli <aarcange@redhat.com> wrote:
> >
> > I've been wondering why mremap is sending one IPI for each page that
> > it moves. I tried to remove that so we send an IPI for each
> > vma/syscall (not for each pte/page).
> 
> (It wouldn't usually have been sending an IPI for each page, only if
> the mm were active on another cpu, but...)

Correct, it mostly applies to threaded applications (but it also
applies to regular apps that migrate to one idle cpu to the next).  In
these cases it's very likely to send IPIs for each page, especially if
some other thread is running in another CPU. The IPI won't alter the
mm_cpumask(). So it can make quite some performance difference in some
microbenchmark using threads (which I didn't try to run yet). But more
interesting than microbenchmarks, is to see if this makes any
difference with real life JITs.

> That looks like a good optimization to me: I can't think of a good
> reason for it to be the way it was, just it started out like that and
> none of us ever thought to change it before.  Plus it's always nice to
> see the flush_tlb_range() afterwards complementing the
> flush_cache_range() beforehand, as you now have in move_page_tables().

Same here. I couldn't see a good reason for it to be the way it
was.

> And don't forget that move_page_tables() is also used by exec's
> shift_arg_pages(): no IPI saving there, but it should be more
> efficient when exec'ing with many arguments.

Yep I didn't forget it's also called from execve, that is an area we
had to fix too for the (hopefully) last migrate rmap SMP race with Mel
recently. I think the big saving is in the IPI reduction on large CPU
systems with plenty of threads running during mremap, that should be
measurable, execve I doubt because like you said there's no IPI
savings there but it sure will help a bit there too.

On this execve/move_page_tables very topic one thought I had last time
I read it, is that I don't get why we don't randomize the top of the
stack address _before_ allocating the stack, instead randomizing it
after it's created requiring an mremap. There shall be a good reason
for it but I didn't search for it too hard yet... so I may figure this
out myself if I look into the execve paths just a bit deeper (I assume
there's good reason for it, otherwise my point is we shouldn't have
been calling move_page_tables inside execve in the first place). Maybe
something in the randomization of the top of the stack seeds from
something that is known only after the stack exists, dunno yet. But
that's a separate issue...

Thanks a lot to you and Rik for reviewing it,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
