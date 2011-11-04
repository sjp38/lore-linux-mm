Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id E46726B0072
	for <linux-mm@kvack.org>; Fri,  4 Nov 2011 10:34:57 -0400 (EDT)
Received: by vws16 with SMTP id 16so2881864vws.14
        for <linux-mm@kvack.org>; Fri, 04 Nov 2011 07:34:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.00.1111032318290.2058@sister.anvils>
References: <20111031171441.GD3466@redhat.com>
	<1320082040-1190-1-git-send-email-aarcange@redhat.com>
	<alpine.LSU.2.00.1111032318290.2058@sister.anvils>
Date: Fri, 4 Nov 2011 22:34:54 +0800
Message-ID: <CAPQyPG4DNofTw=rqJXPTbo3w4xGMdPF3SYt3qyQCWXYsDLa08A@mail.gmail.com>
Subject: Re: [PATCH] mremap: enforce rmap src/dst vma ordering in case of
 vma_merge succeeding in copy_vma
From: Nai Xia <nai.xia@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Pawel Sikora <pluto@agmk.net>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, jpiszcz@lucidpixels.com, arekm@pld-linux.org, linux-kernel@vger.kernel.org

On Fri, Nov 4, 2011 at 3:31 PM, Hugh Dickins <hughd@google.com> wrote:
> On Mon, 31 Oct 2011, Andrea Arcangeli wrote:
>
>> migrate was doing a rmap_walk with speculative lock-less access on
>> pagetables. That could lead it to not serialize properly against
>> mremap PT locks. But a second problem remains in the order of vmas in
>> the same_anon_vma list used by the rmap_walk.
>
> I do think that Nai Xia deserves special credit for thinking deeper
> into this than the rest of us (before you came back): something like
>
> Issue-conceived-by: Nai Xia <nai.xia@gmail.com>

Thanks! ;-)

>
>>
>> If vma_merge would succeed in copy_vma, the src vma could be placed
>> after the dst vma in the same_anon_vma list. That could still lead
>> migrate to miss some pte.
>>
>> This patch adds a anon_vma_order_tail() function to force the dst vma
>
> I agree with Mel that anon_vma_moveto_tail() would be a better name;
> or even anon_vma_move_to_tail().
>
>> at the end of the list before mremap starts to solve the problem.
>>
>> If the mremap is very large and there are a lots of parents or childs
>> sharing the anon_vma root lock, this should still scale better than
>> taking the anon_vma root lock around every pte copy practically for
>> the whole duration of mremap.
>
> But I'm sorry to say that I'm actually not persuaded by the patch,
> on three counts.
>
>>
>> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
>> ---
>> =A0include/linux/rmap.h | =A0 =A01 +
>> =A0mm/mmap.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A08 ++++++++
>> =A0mm/rmap.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 44 +++++++++++++++++++++++++++=
+++++++++++++++++
>> =A03 files changed, 53 insertions(+), 0 deletions(-)
> B
>>
>> diff --git a/include/linux/rmap.h b/include/linux/rmap.h
>> index 2148b12..45eb098 100644
>> --- a/include/linux/rmap.h
>> +++ b/include/linux/rmap.h
>> @@ -120,6 +120,7 @@ void anon_vma_init(void); /* create anon_vma_cachep =
*/
>> =A0int =A0anon_vma_prepare(struct vm_area_struct *);
>> =A0void unlink_anon_vmas(struct vm_area_struct *);
>> =A0int anon_vma_clone(struct vm_area_struct *, struct vm_area_struct *);
>> +void anon_vma_order_tail(struct vm_area_struct *);
>> =A0int anon_vma_fork(struct vm_area_struct *, struct vm_area_struct *);
>> =A0void __anon_vma_link(struct vm_area_struct *);
>>
>> diff --git a/mm/mmap.c b/mm/mmap.c
>> index a65efd4..a5858dc 100644
>> --- a/mm/mmap.c
>> +++ b/mm/mmap.c
>> @@ -2339,7 +2339,15 @@ struct vm_area_struct *copy_vma(struct vm_area_st=
ruct **vmap,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (vma_start >=3D new_vma->vm_start &&
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vma_start < new_vma->vm_end)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* No need to call anon_vma_=
order_tail() in
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* this case because the sam=
e PT lock will
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* serialize the rmap_walk a=
gainst both src
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* and dst vmas.
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>
> Really? =A0Please convince me: I just do not see what ensures that
> the same pt lock covers both src and dst areas in this case.

At the first glance that rmap_walk does travel this merged VMA
once...
But, Now, Wait...., I am actually really puzzled that this case can really
happen at all, you see that vma_merge() does not break the validness
between page->index and its VMA. So if this can really happen,
a page->index should be valid in both areas in a same VMA.
It's strange to imagine that a PTE is copy inside a _same_ VMA
and page->index is valid at both old and new places.

IMO, the only case that src VMA can be merged by the new
is that src VMA hasn't been faulted yet and the pgoff
is recalculated. And if my reasoning is true, this place
does not need to be worried about.

How do you think?

>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 *vmap =3D new_vma;
>> + =A0 =A0 =A0 =A0 =A0 =A0 else
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 anon_vma_order_tail(new_vma);
>
> And if this puts new_vma in the right position for the normal
> move_page_tables(), as anon_vma_clone() does in the block below,
> aren't they both in exactly the wrong position for the abnormal
> move_page_tables(), called to put ptes back where they were if
> the original move_page_tables() fails?

OH,MY, at least 6 six eye balls missed another apparent case...
Now you know why I said "Human brains are all weak in...." :P

>
> It might be possible to argue that move_page_tables() can only
> fail by failing to allocate memory for pud or pmd, and that (perhaps)
> could only happen if the task was being OOM-killed and ran out of
> reserves at this point, and if it's being OOM-killed then we don't
> mind losing a migration entry for a moment... perhaps.
>
> Certainly I'd agree that it's a very rare case. =A0But it feels wrong
> to be attempting to fix the already unlikely issue, while ignoring
> this aspect, or relying on such unrelated implementation details.
>
> Perhaps some further anon_vma_ordering could fix it up,
> but that would look increasingly desperate.
>
>> =A0 =A0 =A0 } else {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 new_vma =3D kmem_cache_alloc(vm_area_cachep,=
 GFP_KERNEL);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (new_vma) {
>> diff --git a/mm/rmap.c b/mm/rmap.c
>> index 8005080..6dbc165 100644
>> --- a/mm/rmap.c
>> +++ b/mm/rmap.c
>> @@ -272,6 +272,50 @@ int anon_vma_clone(struct vm_area_struct *dst, stru=
ct vm_area_struct *src)
>> =A0}
>>
>> =A0/*
>> + * Some rmap walk that needs to find all ptes/hugepmds without false
>> + * negatives (like migrate and split_huge_page) running concurrent
>> + * with operations that copy or move pagetables (like mremap() and
>> + * fork()) to be safe depends the anon_vma "same_anon_vma" list to be
>> + * in a certain order: the dst_vma must be placed after the src_vma in
>> + * the list. This is always guaranteed by fork() but mremap() needs to
>> + * call this function to enforce it in case the dst_vma isn't newly
>> + * allocated and chained with the anon_vma_clone() function but just
>> + * an extension of a pre-existing vma through vma_merge.
>> + *
>> + * NOTE: the same_anon_vma list can still be changed by other
>> + * processes while mremap runs because mremap doesn't hold the
>> + * anon_vma mutex to prevent modifications to the list while it
>> + * runs. All we need to enforce is that the relative order of this
>> + * process vmas isn't changing (we don't care about other vmas
>> + * order). Each vma corresponds to an anon_vma_chain structure so
>> + * there's no risk that other processes calling anon_vma_order_tail()
>> + * and changing the same_anon_vma list under mremap() will screw with
>> + * the relative order of this process vmas in the list, because we
>> + * won't alter the order of any vma that isn't belonging to this
>> + * process. And there can't be another anon_vma_order_tail running
>> + * concurrently with mremap() coming from this process because we hold
>> + * the mmap_sem for the whole mremap(). fork() ordering dependency
>> + * also shouldn't be affected because we only care that the parent
>> + * vmas are placed in the list before the child vmas and
>> + * anon_vma_order_tail won't reorder vmas from either the fork parent
>> + * or child.
>> + */
>> +void anon_vma_order_tail(struct vm_area_struct *dst)
>> +{
>> + =A0 =A0 struct anon_vma_chain *pavc;
>> + =A0 =A0 struct anon_vma *root =3D NULL;
>> +
>> + =A0 =A0 list_for_each_entry_reverse(pavc, &dst->anon_vma_chain, same_v=
ma) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 struct anon_vma *anon_vma =3D pavc->anon_vma;
>> + =A0 =A0 =A0 =A0 =A0 =A0 VM_BUG_ON(pavc->vma !=3D dst);
>> + =A0 =A0 =A0 =A0 =A0 =A0 root =3D lock_anon_vma_root(root, anon_vma);
>> + =A0 =A0 =A0 =A0 =A0 =A0 list_del(&pavc->same_anon_vma);
>> + =A0 =A0 =A0 =A0 =A0 =A0 list_add_tail(&pavc->same_anon_vma, &anon_vma-=
>head);
>> + =A0 =A0 }
>> + =A0 =A0 unlock_anon_vma_root(root);
>> +}
>
> I thought this was correct, but now I'm not so sure. =A0You rightly
> consider the question of interference between concurrent mremaps in
> different mms in your comment above, but I'm still not convinced it
> is safe. =A0Oh, probably just my persistent failure to picture these
> avcs properly.
>
> If we were back in the days of the simple anon_vma list, I'd probably
> share your enthusiasm for the list ordering solution; but now it looks
> like a fragile and contorted way of avoiding the obvious... we just
> need to use the anon_vma_lock (but perhaps there are some common and
> easily tested conditions under which we can skip it e.g. when a single
> pt lock covers src and dst?).
>
> Sorry to be so negative! =A0I may just be wrong on all counts.
>
> Hugh
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
