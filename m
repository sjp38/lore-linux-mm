Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 0E66A6B01F2
	for <linux-mm@kvack.org>; Wed, 12 May 2010 17:08:19 -0400 (EDT)
Message-ID: <4BEB18BB.5010803@redhat.com>
Date: Wed, 12 May 2010 17:08:11 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/5] always lock the root (oldest) anon_vma
References: <20100512133815.0d048a86@annuminas.surriel.com> <20100512134029.36c286c4@annuminas.surriel.com> <20100512210216.GP24989@csn.ul.ie>
In-Reply-To: <20100512210216.GP24989@csn.ul.ie>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Linux-MM <linux-mm@kvack.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On 05/12/2010 05:02 PM, Mel Gorman wrote:

> This last comment is a bit light. It's actually restoring the lock that
> was taken in 2.6.33 to some extent except we are always taking it now.
> In 2.6.33, it was resricted to
>
>         if (vma->anon_vma&&  (insert || importer || start != vma->vm_start))
>                  anon_vma = vma->anon_vma;
>
> but now it's always. Has it been determined that the locking in 2.6.33
> was insufficient or are we playing it safe now?

Playing it safe, mostly.

Another aspect is that, if you look at the if condition above,
the number of cases where we have an anon_vma and do not take
the lock is pretty small.

Basically only the case where we expand a VMA upward or merge
VMAs in an mprotect.  I believe in pretty much all other cases
we end up needing to take the lock.

I am not entirely convinced the old code took the lock in all
of the required cases.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
