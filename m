Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 6B9476B01F0
	for <linux-mm@kvack.org>; Fri, 27 Aug 2010 12:43:51 -0400 (EDT)
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id o7RGhjUi005793
	for <linux-mm@kvack.org>; Fri, 27 Aug 2010 09:43:45 -0700
Received: from vws10 (vws10.prod.google.com [10.241.21.138])
	by wpaz17.hot.corp.google.com with ESMTP id o7RGhhu5018382
	for <linux-mm@kvack.org>; Fri, 27 Aug 2010 09:43:44 -0700
Received: by vws10 with SMTP id 10so4431539vws.17
        for <linux-mm@kvack.org>; Fri, 27 Aug 2010 09:43:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100827095546.GC6803@random.random>
References: <alpine.LSU.2.00.1008252305540.19107@sister.anvils>
	<20100826235052.GZ6803@random.random>
	<AANLkTimgKcP78CNakDf34NrVrd5apfXrtptNw+G6G5DK@mail.gmail.com>
	<20100827095546.GC6803@random.random>
Date: Fri, 27 Aug 2010 09:43:43 -0700
Message-ID: <AANLkTikvB1fN42A91ZdEHyEXnz2bGw9Q21dJcfa3PBP0@mail.gmail.com>
Subject: Re: [PATCH] mm: fix hang on anon_vma->root->lock
From: Hugh Dickins <hughd@google.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 27, 2010 at 2:55 AM, Andrea Arcangeli <aarcange@redhat.com> wrote:
> On Thu, Aug 26, 2010 at 06:43:31PM -0700, Hugh Dickins wrote:
>> some light., I think you're mistaking the role that RCU plays here.
>
> That's exactly correct, I thought it prevented reuse of the slab
> entry, not only of the whole slab... SLAB_DESTROY_BY_RCU is a lot more
> tricky to use than I though...
>
> However at the light of this, I think page_lock_anon_vma could have
> returned a freed and reused anon_vma well before the anon-vma changes.
>
> The anon_vma could have been freed after the first page_mapped check
> succeed but before taking the spinlock. I think, it worked fine
> because the rmap walks are robust enough just not to fall apart on a
> reused anon_vma while the lock is hold. It become a visible problem
> now because we were unlocking the wrong lock leading to a
> deadlock. But I guess it wasn't too intentional to return a reused
> anon_vma out of page_lock_anon_vma.

What you say there is all exactly right, except for "I guess it wasn't
too intentional": it was intentional, and known that it all worked out
okay in the rare case when a reused anon_vma got fed into the loops -
the anon_vma, after all, is nothing more than a list of places where
you may find the page mapped, it has never asserted that a page will
be found everywhere that the anon_vma lists.

I would have liked to say "well known" above, but perhaps well known
only to me: you're certainly not the first to be surprised by this.
IIRC both Christoph and Peter have at different times proposed patches
to tighten up page_lock_anon_vma() to avoid returning a stale/reused
anon_vma, probably both were dropped because neither was actually
necessary, until now: I guess it's a good thing for understandability
that anon_vma->root->lock now requires that we weed out that case.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
