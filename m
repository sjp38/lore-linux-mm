Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 8B4F56B01F0
	for <linux-mm@kvack.org>; Fri, 27 Aug 2010 13:55:17 -0400 (EDT)
Received: from hpaq14.eem.corp.google.com (hpaq14.eem.corp.google.com [172.25.149.14])
	by smtp-out.google.com with ESMTP id o7RHtDd2028645
	for <linux-mm@kvack.org>; Fri, 27 Aug 2010 10:55:13 -0700
Received: from vws18 (vws18.prod.google.com [10.241.21.146])
	by hpaq14.eem.corp.google.com with ESMTP id o7RHsjlP009309
	for <linux-mm@kvack.org>; Fri, 27 Aug 2010 10:55:12 -0700
Received: by vws18 with SMTP id 18so5588505vws.1
        for <linux-mm@kvack.org>; Fri, 27 Aug 2010 10:55:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1008271159160.18495@router.home>
References: <alpine.LSU.2.00.1008252305540.19107@sister.anvils>
	<20100826235052.GZ6803@random.random>
	<AANLkTimgKcP78CNakDf34NrVrd5apfXrtptNw+G6G5DK@mail.gmail.com>
	<20100827095546.GC6803@random.random>
	<AANLkTikvB1fN42A91ZdEHyEXnz2bGw9Q21dJcfa3PBP0@mail.gmail.com>
	<alpine.DEB.2.00.1008271159160.18495@router.home>
Date: Fri, 27 Aug 2010 10:55:11 -0700
Message-ID: <AANLkTi=FeHnLu4_6M5N6yUL==4YyxVXXxsccsE2kNUbm@mail.gmail.com>
Subject: Re: [PATCH] mm: fix hang on anon_vma->root->lock
From: Hugh Dickins <hughd@google.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 27, 2010 at 10:13 AM, Christoph Lameter <cl@linux.com> wrote:

> The basic problem with SLAB_DESTROY_BY_RCU is that you get a reference to
> an object that is guaranteed only to have the same type (the instance may
> fluctuate and be replaced from under you unless other measures are taken).

(I wouldn't describe that as a "problem with SLAB_DESTROY_BY_RCU":
it's precisely the nature of SLAB_DESTROY_BY_RCU, what makes it useful
in solving backward-locking problems elsewhere.)

>
> Typically one must take a lock within the memory structure to pin down
> the object (or take a refcount). Only then can you follow pointers and
> such. It is only possible to verify that the right object has been
> reached *after* locking. Following a pointer without having determined
> that we hit the right object should not occur.
>
> A solution here would be to take the anon_vma->lock (prevents the object
> switching under us) and then verify that the mapping is the one we are
> looking for and that the pointer points to the right root. Then take the
> root lock.
>
> Hughs solution takes a global spinlock which will limit scalability.

Eh?  My solution was a second page_mapped(page) test i.e. testing an atomic.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
