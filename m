Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 88C5D6B0209
	for <linux-mm@kvack.org>; Thu, 13 May 2010 05:55:01 -0400 (EDT)
Date: Thu, 13 May 2010 10:54:39 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 4/5] always lock the root (oldest) anon_vma
Message-ID: <20100513095439.GA27949@csn.ul.ie>
References: <20100512133815.0d048a86@annuminas.surriel.com> <20100512134029.36c286c4@annuminas.surriel.com> <20100512210216.GP24989@csn.ul.ie> <4BEB18BB.5010803@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <4BEB18BB.5010803@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Linux-MM <linux-mm@kvack.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Wed, May 12, 2010 at 05:08:11PM -0400, Rik van Riel wrote:
> On 05/12/2010 05:02 PM, Mel Gorman wrote:
>
>> This last comment is a bit light. It's actually restoring the lock that
>> was taken in 2.6.33 to some extent except we are always taking it now.
>> In 2.6.33, it was resricted to
>>
>>         if (vma->anon_vma&&  (insert || importer || start != vma->vm_start))
>>                  anon_vma = vma->anon_vma;
>>
>> but now it's always. Has it been determined that the locking in 2.6.33
>> was insufficient or are we playing it safe now?
>
> Playing it safe, mostly.
>

Sure. I did the same, got the same question from Andrea and more or less
gave the same answer :) . I asked again in case you spotted something I
didn't.

> Another aspect is that, if you look at the if condition above,
> the number of cases where we have an anon_vma and do not take
> the lock is pretty small.
>
> Basically only the case where we expand a VMA upward or merge
> VMAs in an mprotect.  I believe in pretty much all other cases
> we end up needing to take the lock.
>

Looking at the if condition, brk() would appear to be the most important
case, right? This would appear to correlate with the reasoning behind
that condition in the first place in commit
252c5f94d944487e9f50ece7942b0fbf659c5c31 where sbrk contended on the
lock heavily.

I can't convince myself 100% but it is possible we will regress on that
test case again if the same logic is not applied to the locking. I ran a
brk() microbenchmark from aim9 and the results were really bad - 48%
regression. I didn't rerun with the old logic to see the results
unfortunately and right now I'm on the road. It'll be tomorrow morning
before I get the chance.

> I am not entirely convinced the old code took the lock in all
> of the required cases.
>

I have vague worries about expand_upwards but otherwise the reasoning
seemed solid and even with the new anon_vma code, we are not doing
anything fundamentally different in this area. Maybe it's best to play
it safe now and always take the lock, but it's worth reconsidering later
particularly if this patch gets fingered in some performance-related
bisection later.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
