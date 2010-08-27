Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 047BF6B01F0
	for <linux-mm@kvack.org>; Fri, 27 Aug 2010 14:05:45 -0400 (EDT)
Date: Fri, 27 Aug 2010 12:13:22 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm: fix hang on anon_vma->root->lock
In-Reply-To: <AANLkTikvB1fN42A91ZdEHyEXnz2bGw9Q21dJcfa3PBP0@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1008271159160.18495@router.home>
References: <alpine.LSU.2.00.1008252305540.19107@sister.anvils> <20100826235052.GZ6803@random.random> <AANLkTimgKcP78CNakDf34NrVrd5apfXrtptNw+G6G5DK@mail.gmail.com> <20100827095546.GC6803@random.random>
 <AANLkTikvB1fN42A91ZdEHyEXnz2bGw9Q21dJcfa3PBP0@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hughd@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 27 Aug 2010, Hugh Dickins wrote:

> I would have liked to say "well known" above, but perhaps well known
> only to me: you're certainly not the first to be surprised by this.

Most people dealing with this for the first time get through a discovery
period. The network guys had similar problems when they first tried to use
SLAB_DESTROY_BY_RCU.

> IIRC both Christoph and Peter have at different times proposed patches
> to tighten up page_lock_anon_vma() to avoid returning a stale/reused
> anon_vma, probably both were dropped because neither was actually
> necessary, until now: I guess it's a good thing for understandability
> that anon_vma->root->lock now requires that we weed out that case.

Right. We need to verify that the object we have reached is the correct
one.

The basic problem with SLAB_DESTROY_BY_RCU is that you get a reference to
an object that is guaranteed only to have the same type (the instance may
fluctuate and be replaced from under you unless other measures are taken).

Typically one must take a lock within the memory structure to pin down
the object (or take a refcount). Only then can you follow pointers and
such. It is only possible to verify that the right object has been
reached *after* locking. Following a pointer without having determined
that we hit the right object should not occur.

A solution here would be to take the anon_vma->lock (prevents the object
switching under us) and then verify that the mapping is the one we are
looking for and that the pointer points to the right root. Then take the
root lock.

Hughs solution takes a global spinlock which will limit scalability.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
