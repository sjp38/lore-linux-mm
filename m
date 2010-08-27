Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id C68446B01F0
	for <linux-mm@kvack.org>; Fri, 27 Aug 2010 16:56:52 -0400 (EDT)
Date: Fri, 27 Aug 2010 15:56:48 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm: fix hang on anon_vma->root->lock
In-Reply-To: <AANLkTinLpDnpwr40dtU5UFq53avODSKxTA4=xnZwmJFX@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1008271547200.22988@router.home>
References: <alpine.LSU.2.00.1008252305540.19107@sister.anvils> <20100826235052.GZ6803@random.random> <AANLkTimgKcP78CNakDf34NrVrd5apfXrtptNw+G6G5DK@mail.gmail.com> <20100827095546.GC6803@random.random> <AANLkTikvB1fN42A91ZdEHyEXnz2bGw9Q21dJcfa3PBP0@mail.gmail.com>
 <alpine.DEB.2.00.1008271159160.18495@router.home> <AANLkTi=FeHnLu4_6M5N6yUL==4YyxVXXxsccsE2kNUbm@mail.gmail.com> <alpine.DEB.2.00.1008271420400.18495@router.home> <AANLkTinLpDnpwr40dtU5UFq53avODSKxTA4=xnZwmJFX@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hughd@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 27 Aug 2010, Hugh Dickins wrote:

> Nothing ensures that the root pointer was not changed after the
> ACCESS_ONCE, that's exactly why we use ACCESS_ONCE there: once we've
> got the lock and realize that what we've locked may not be what we
> wanted (or may change from what we were wanting at any moment, the
> page no longer being mapped there - but in that case we no longer want
> it), we have to be sure to unlock the one we locked, rather than the
> one which anon_vma->root might subsequently point to.

I do not see any check after we have taken the lock to verify that we
locked the correct object. Was there a second version of the patch?

> > Since there is no lock taken before the mapped check none of the
> > earlier reads from the anon vma structure nor the page mapped check
> > necessarily reflect a single state of the anon_vma.
>
> There's no lock (other than RCU's read "lock")  taken before the
> original mapped check, and that's important, otherwise our attempt to
> lock might actually spinon or corrupt something that was long ago an
> anon_vma.  But we do take the anon_vma->root->lock before the second
> mapped check which I added.  If the page is still mapped at the point

You then are using an object from the anon_vma (the pointer) without a
lock! This is unstable therefore unless there are other constraints. The
anon_vma->lock must be taken before derefencing that pointer. The page may
have been unmapped and mapped again between the two checks. Unlikely but
possible.

> of that second check, then we know that we got the right anon_vma,

I do not see a second check (*after* taking the lock) in the patch and the
way the lock is taken can be a problem in itself.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
