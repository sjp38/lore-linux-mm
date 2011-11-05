Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 91EF36B002D
	for <linux-mm@kvack.org>; Fri,  4 Nov 2011 20:59:04 -0400 (EDT)
Received: by vcbfo13 with SMTP id fo13so71404vcb.14
        for <linux-mm@kvack.org>; Fri, 04 Nov 2011 17:59:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAPQyPG5i87VcnwU5UoKiT6_=tzqO_NOPXFvyEooA1Orbe_ztGQ@mail.gmail.com>
References: <20111031171441.GD3466@redhat.com>
	<1320082040-1190-1-git-send-email-aarcange@redhat.com>
	<alpine.LSU.2.00.1111032318290.2058@sister.anvils>
	<20111104235603.GT18879@redhat.com>
	<CAPQyPG5i87VcnwU5UoKiT6_=tzqO_NOPXFvyEooA1Orbe_ztGQ@mail.gmail.com>
Date: Sat, 5 Nov 2011 08:59:02 +0800
Message-ID: <CAPQyPG5=a0HM-wK72-a-1AGjMVUtg3o03ttoZigb+tvKcxjJ6g@mail.gmail.com>
Subject: Re: [PATCH] mremap: enforce rmap src/dst vma ordering in case of
 vma_merge succeeding in copy_vma
From: Nai Xia <nai.xia@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Pawel Sikora <pluto@agmk.net>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, jpiszcz@lucidpixels.com, arekm@pld-linux.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>

On Sat, Nov 5, 2011 at 8:21 AM, Nai Xia <nai.xia@gmail.com> wrote:
> On Sat, Nov 5, 2011 at 7:56 AM, Andrea Arcangeli <aarcange@redhat.com> wr=
ote:
>> On Fri, Nov 04, 2011 at 12:31:04AM -0700, Hugh Dickins wrote:
>>> On Mon, 31 Oct 2011, Andrea Arcangeli wrote:
>>> > diff --git a/mm/mmap.c b/mm/mmap.c
>>> > index a65efd4..a5858dc 100644
>>> > --- a/mm/mmap.c
>>> > +++ b/mm/mmap.c
>>> > @@ -2339,7 +2339,15 @@ struct vm_area_struct *copy_vma(struct vm_area=
_struct **vmap,
>>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>>> > =A0 =A0 =A0 =A0 =A0 =A0 if (vma_start >=3D new_vma->vm_start &&
>>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vma_start < new_vma->vm_end)
>>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
>>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* No need to call anon_vma_o=
rder_tail() in
>>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* this case because the same=
 PT lock will
>>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* serialize the rmap_walk ag=
ainst both src
>>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* and dst vmas.
>>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>>>
>>> Really? =A0Please convince me: I just do not see what ensures that
>>> the same pt lock covers both src and dst areas in this case.
>>
>> Right, vma being the same for src/dst doesn't mean the PT lock is the
>> same, it might be if source pte entry fit in the same pagetable but
>> maybe not if the vma is >2M (the max a single pagetable can point to).
>>
>>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 *vmap =3D new_vma;
>>> > + =A0 =A0 =A0 =A0 =A0 else
>>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 anon_vma_order_tail(new_vma);
>>>
>>> And if this puts new_vma in the right position for the normal
>>> move_page_tables(), as anon_vma_clone() does in the block below,
>>> aren't they both in exactly the wrong position for the abnormal
>>> move_page_tables(), called to put ptes back where they were if
>>> the original move_page_tables() fails?
>>
>> Failure paths. Good point, they'd need to be reversed again in that
>> case.
>>
>>> It might be possible to argue that move_page_tables() can only
>>> fail by failing to allocate memory for pud or pmd, and that (perhaps)
>>> could only happen if the task was being OOM-killed and ran out of
>>> reserves at this point, and if it's being OOM-killed then we don't
>>> mind losing a migration entry for a moment... perhaps.
>>
>> Hmm no it wouldn't be ok, or I wouldn't want to risk that.
>>
>>> Certainly I'd agree that it's a very rare case. =A0But it feels wrong
>>> to be attempting to fix the already unlikely issue, while ignoring
>>> this aspect, or relying on such unrelated implementation details.
>>
>> Agreed.
>>
>>> Perhaps some further anon_vma_ordering could fix it up,
>>> but that would look increasingly desperate.
>>
>> I think what Nai didn't consider in explaining this theoretical race
>> that I noticed now is the anon_vma root lock taken by adjust_vma.
>>
>> If the merge succeeds adjust_vma will take the lock and flush away
>> from all others CPUs any sign of rmap_walk before the move_page_tables
>> can start.
>>
>> So it can't happen that you do rmap_walk, check vma1, mremap moves
>> stuff from vma2 to vma1 (wrong order), and then rmap_walk continues
>> checking vma2 where the pte won't be there anymore. It can't happen
>> because mremap would block in vma_merge waiting the rmap_walk to
>> complete. Before proceeding moving any pte. Thanks to the anon_vma
>> lock already taken by adjust_vma.
>
> Still, =A0I think it's not rmap_walk() ---> mremap() --> rmap_walk() that=
 trigger
> the bug, =A0but this events would:
>
> copy_vma() ---> rmap_walk() scan dst VMA --> move_page_tables() moves src=
 to dst
> ---> =A0rmap_walk() scan src VMA. =A0:D

OK, I think I need to be more concise: Your last reasoning only
ensures that mremap
as a whole entity cannot interleave with  rmap_walk(). But I think
nothing can prevent
move_page_tables() from doing this. As long as copy_vma() gives an
wrong ordering,
the racing between  rmap_walk() & move_page_tables() afterwards may
trigger the bug.

Do you agree?



>
> I might be wrong. But thank you all for the time and patience for
> playing this racing game
> with me. It's really an honor to exhaust my mind on a daunting thing
> with you. :)
>
>
> Best Regards,
>
> Nai
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
