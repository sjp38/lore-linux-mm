Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 77ABF6B01F0
	for <linux-mm@kvack.org>; Fri, 27 Aug 2010 17:28:11 -0400 (EDT)
Received: from hpaq13.eem.corp.google.com (hpaq13.eem.corp.google.com [172.25.149.13])
	by smtp-out.google.com with ESMTP id o7RLS7xP011218
	for <linux-mm@kvack.org>; Fri, 27 Aug 2010 14:28:07 -0700
Received: from vws15 (vws15.prod.google.com [10.241.21.143])
	by hpaq13.eem.corp.google.com with ESMTP id o7RLS5kY012728
	for <linux-mm@kvack.org>; Fri, 27 Aug 2010 14:28:05 -0700
Received: by vws15 with SMTP id 15so3920299vws.12
        for <linux-mm@kvack.org>; Fri, 27 Aug 2010 14:28:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1008271547200.22988@router.home>
References: <alpine.LSU.2.00.1008252305540.19107@sister.anvils>
	<20100826235052.GZ6803@random.random>
	<AANLkTimgKcP78CNakDf34NrVrd5apfXrtptNw+G6G5DK@mail.gmail.com>
	<20100827095546.GC6803@random.random>
	<AANLkTikvB1fN42A91ZdEHyEXnz2bGw9Q21dJcfa3PBP0@mail.gmail.com>
	<alpine.DEB.2.00.1008271159160.18495@router.home>
	<AANLkTi=FeHnLu4_6M5N6yUL==4YyxVXXxsccsE2kNUbm@mail.gmail.com>
	<alpine.DEB.2.00.1008271420400.18495@router.home>
	<AANLkTinLpDnpwr40dtU5UFq53avODSKxTA4=xnZwmJFX@mail.gmail.com>
	<alpine.DEB.2.00.1008271547200.22988@router.home>
Date: Fri, 27 Aug 2010 14:28:04 -0700
Message-ID: <AANLkTim16oT13keYK_oz=7kmDmdG=ADfkGXMKp3_dEw_@mail.gmail.com>
Subject: Re: [PATCH] mm: fix hang on anon_vma->root->lock
From: Hugh Dickins <hughd@google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 27, 2010 at 1:56 PM, Christoph Lameter <cl@linux.com> wrote:
> On Fri, 27 Aug 2010, Hugh Dickins wrote:
>
>> Nothing ensures that the root pointer was not changed after the
>> ACCESS_ONCE, that's exactly why we use ACCESS_ONCE there: once we've
>> got the lock and realize that what we've locked may not be what we
>> wanted (or may change from what we were wanting at any moment, the
>> page no longer being mapped there - but in that case we no longer want
>> it), we have to be sure to unlock the one we locked, rather than the
>> one which anon_vma->root might subsequently point to.
>
> I do not see any check after we have taken the lock to verify that we
> locked the correct object. Was there a second version of the patch?

No second version of the patch, no.  As I said already, it's that
second page_mapped check which gives the guarantee that the anon_vma
has not yet been freed, hence we've locked the correct object.

>
>> > Since there is no lock taken before the mapped check none of the
>> > earlier reads from the anon vma structure nor the page mapped check
>> > necessarily reflect a single state of the anon_vma.
>>
>> There's no lock (other than RCU's read "lock") =C2=A0taken before the
>> original mapped check, and that's important, otherwise our attempt to
>> lock might actually spinon or corrupt something that was long ago an
>> anon_vma. =C2=A0But we do take the anon_vma->root->lock before the secon=
d
>> mapped check which I added. =C2=A0If the page is still mapped at the poi=
nt
>
> You then are using an object from the anon_vma (the pointer) without a
> lock!

Yes. (not counting RCU's read "lock" as a lock).

> This is unstable therefore unless there are other constraints. The
> anon_vma->lock must be taken before derefencing that pointer.

No, SLAB_DESTROY_BY_RCU gives us just the stablity we need to take the lock=
