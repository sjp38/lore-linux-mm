Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 6805C6B002D
	for <linux-mm@kvack.org>; Fri,  4 Nov 2011 22:00:55 -0400 (EDT)
Received: by vws16 with SMTP id 16so3549020vws.14
        for <linux-mm@kvack.org>; Fri, 04 Nov 2011 19:00:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20111105013317.GU18879@redhat.com>
References: <20111031171441.GD3466@redhat.com>
	<1320082040-1190-1-git-send-email-aarcange@redhat.com>
	<alpine.LSU.2.00.1111032318290.2058@sister.anvils>
	<20111104235603.GT18879@redhat.com>
	<CAPQyPG5i87VcnwU5UoKiT6_=tzqO_NOPXFvyEooA1Orbe_ztGQ@mail.gmail.com>
	<20111105013317.GU18879@redhat.com>
Date: Sat, 5 Nov 2011 10:00:52 +0800
Message-ID: <CAPQyPG5Y1e2dac38OLwZAinWb6xpPMWCya2vTaWLPi9+vp1JXQ@mail.gmail.com>
Subject: Re: [PATCH] mremap: enforce rmap src/dst vma ordering in case of
 vma_merge succeeding in copy_vma
From: Nai Xia <nai.xia@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Pawel Sikora <pluto@agmk.net>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, jpiszcz@lucidpixels.com, arekm@pld-linux.org, linux-kernel@vger.kernel.org

On Sat, Nov 5, 2011 at 9:33 AM, Andrea Arcangeli <aarcange@redhat.com> wrot=
e:
> On Sat, Nov 05, 2011 at 08:21:03AM +0800, Nai Xia wrote:
>> copy_vma() ---> rmap_walk() scan dst VMA --> move_page_tables() moves sr=
c to dst
>> ---> =A0rmap_walk() scan src VMA. =A0:D
>
> Hmm yes. I think I got in the wrong track because I focused too much
> on that line you started talking about, the *vmap =3D new_vma, you said
> I had to reorder stuff there too, and that didn't make sense.

Oh, I think you misunderstood me in that. I was just saying:

if (*vmap =3D new_vma), then _NO_ PTEs need to be moved afterwards,
because vma has not yet been faulted at all. Otherwise, it breaks the
page->index semantics in the way I explained in my reply to Hugh.

So nothing need to be added there, but the reason is because
the above reasoning, not the same PTL locking...

And for this case alone, I think the proper solving place
should be outside move_vma() but inside do_mremap()
by only vma_adjust() and vma_merge() like stuff.
Because really it does not involve  move_page_tables().

>
> The reason it doesn't make sense is that it can't be ok to reorder
> stuff when *vmap =3D new_vma (i.e. new_vma =3D old_vma). So if I didn't
> need to reorder in that case I thought I could extrapolate it was
> always ok.
>
> But the opposite is true: that case can't be solved.
>
> Can it really happen that vma_merge will pack (prev_vma, new_range,
> old_vma) together in a single vma? (i.e. prev_vma extended to
> old_vma->vm_end)
>
> Even if there's no prev_vma in the picture (but that's the extreme
> case) it cannot be safe: i.e. a (new_range, old_vma) or (old_vma,
> new_range).
>
> 1 single "vma" for src and dst virtual ranges, means 1 single
> vma->vm_pgoff. But we've two virtual addresses and two ptes. So the
> same page->index can't work for both if the vma->vm_pgoff is the
> same.
>
> So regardless of the ordering here we're dealing with something more
> fundamental.
>
> If rmap_walk runs immediately after vma_merge completes and releases
> the anon_vma_lock, it won't find any pte in the vma anymore. No matter
> the order.
>
> I thought at this before and I didn't mention it but at the light of
> the above issue I start to think this is the only possible correct
> solution to the problem. We should just never call vma_merge before
> move_page_tables. And do the merge by hand later after mremap is
> complete.
>
> The only safe way to do it is to have _two_ different vmas, with two
> different ->vm_pgoff. Then it will work. And by always creating a new
> vma we'll always have it queued at the end, and it'll be safe for the
> same reasons fork is safe.
>
> Always allocate a new vma, and then after the whole vma copy is
> complete, look if we can merge and free some vma. After the fact, so
> it means we can't use vma_merge anymore. vma_merge assumes the
> new_range is "virtual" and no vma is mapped there I think. Anyway
> that's an implementation issue. In some unlikely case we'll allocate 1
> more vma than before, and we'll free it once mremap is finished, but
> that's small problem compared to solving this once and for all.
>
> And that will fix it without ordering games and it'll fix the *vmap=3D
> new_vma case too. That case really tripped on me as I was assuming
> *that* was correct.

Yes. "Allocating a new vma, copy first and merge later " seems
another solution without the tricky reordering. But you know,
I now share some of Hugh's feeling that maybe we are too
desperate using racing in places where locks are simpler
and guaranteed to be safe.

But I think Mel indicated that anon_vma_locking might be
harmful to JVM SMP performance.
How severe you expect this to be, Mel ?


Thanks

Nai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
