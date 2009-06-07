Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 785CD6B004D
	for <linux-mm@kvack.org>; Sun,  7 Jun 2009 18:59:20 -0400 (EDT)
Received: by yw-out-1718.google.com with SMTP id 5so1577424ywm.26
        for <linux-mm@kvack.org>; Sun, 07 Jun 2009 16:50:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <Pine.LNX.4.64.0906071651410.17597@sister.anvils>
References: <1244212553-21629-1-git-send-email-minchan.kim@gmail.com>
	 <Pine.LNX.4.64.0906051906000.14826@sister.anvils>
	 <28c262360906070816h765bf4fag9b426199ac0627d@mail.gmail.com>
	 <Pine.LNX.4.64.0906071651410.17597@sister.anvils>
Date: Mon, 8 Jun 2009 08:50:08 +0900
Message-ID: <28c262360906071650u610fdb05u937f1fc232ead22e@mail.gmail.com>
Subject: Re: [RFC] remove page_table_lock in anon_vma_prepare
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Mon, Jun 8, 2009 at 1:28 AM, Hugh Dickins<hugh.dickins@tiscali.co.uk> wr=
ote:
> On Mon, 8 Jun 2009, Minchan Kim wrote:
>> On Sat, Jun 6, 2009 at 3:26 AM, Hugh Dickins<hugh.dickins@tiscali.co.uk>=
 wrote:
>> > On Fri, 5 Jun 2009, Minchan Kim wrote:
>>
>> > (As I expect you've noticed, we used not to bother with the spin_lock
>> > on anon_vma->lock when we'd freshly allocated the anon_vma, it looks
>> > as if it's unnecessary. =C2=A0But in fact Nick and Linus found there's=
 a
>> > subtle reason why it is necessary even then - hopefully the git log
>
> Actually, Linus put a lot of his git comment into the comment above
> anon_vma_prepare(); but it doesn't pin down the case Nick identified
> as well as Nick's original mail.
>
>> > explains it, or I could look up the mails if you want, but at this
>> > moment the details escape me.
>>
>> Hmm. I didn't follow up that at that time.
>>
>> After you noticed me, I found that.
>> commit d9d332e0874f46b91d8ac4604b68ee42b8a7a2c6
>> Author: Linus Torvalds <torvalds@linux-foundation.org>
>> Date: =C2=A0 Sun Oct 19 10:32:20 2008 -0700
>>
>> =C2=A0 =C2=A0 anon_vma_prepare: properly lock even newly allocated entri=
es
>>
>> It's subtle race so I can't digest it fully but I can understand that
>> following as.
>>
>> If we don't hold lock at fresh anon_vma, it can be removed and
>> reallocated by other threads since other cpu's can find it, free,
>> reallocate before first thread which call anon_vma_prepare adds
>> anon_vma to list after vma->anon_vma =3D anon_vma
>>
>> I hope my above explanation is right :)
>
> Not really: I don't think there was a risk of it getting freed at
> that point, but there was a risk of its list head getting dereferenced
> before we'd initialized it.
>
> Here's a link to Nick's 16oct08 linux-mm mail on the subject, then you
> can follow the thread from there. =C2=A0In brief, IIRC, Nick found a race
> which he proposed to fix with barriers, but in the end we were all
> much happier just taking the anon_vma lock in all cases.
>
> http://marc.info/?l=3Dlinux-mm&m=3D122413030612659&w=3D2

Huge long.
Thanks for searching it for me.
I will read the thread and digest it.  ;-)

>>
>> > And do we need the page_table_lock even when find_mergeable_anon_vma
>> > succeeds? =C2=A0That also looks as if it's unnecessary, but I've the g=
host
>> > of a memory that it's needed even for that case: I seem to remember
>> > that there can be a benign race where find_mergeable_anon_vma called
>> > by concurrent threads could actually return different anon_vmas.
>> > That also is something I don't want to think too deeply into at
>> > this instant, but beg me if you wish!)
>>
>> Unfortunately I can't found this issue mail or changelog.
>> Hugh. Could you explain this issue more detail in your convenient time ?
>
> Sure, I remembered it once I went to bed that night, it's an easy one;
> wasn't ever discussed on list, just something I'd been aware of.
>
> Remember that anon_vma_prepare() gets called at fault time, when we
> have only down_read of mmap_sem, so there may well be concurrent faults.
>
> find_mergeable_anon_vma looks at the vma on either side of our faulting
> vma, to see if the neighbouring vma already has an anon_vma, which we'd
> be wise to use if that vma could plausibly be merged with our vma later
> e.g. mprotect may have temporarily split ours from the next, but another
> mprotect may make them mergeable - it would be a pity to be prevented
> from merging them just because we'd already attached distinct anon_vmas.

Absolutely.

> But, as I said, there may well be concurrent faults, on ours and on
> neighbouring vmas: so one call to find_mergeable_anon_vma on our vma
> may find that the next vma has no anon_vma yet, but the prev has one,
> so it returns the prev's anon_vma; but a racing fault on the next
> vma immediately gives it an anon_vma, and a racing fault on our vma
> finds that, so its find_mergeable_anon_vma returns the next's anon_vma.
>
> So the two faults on our vma could both be in anon_vma_prepare(),
> doing the spin_lock(&anon_vma->lock) on find_mergeable_anon_vma's
> anon_vma, but those could still be different anon_vmas: but if
> both lock the page_table_lock, we can be sure to catch that case.

I can understand it completely.
Thanks for quick replay and good explanation.

I expect this thread can help other some day. :)

>
> When I said the race was benign, I meant that it doesn't matter in
> such a case which one we choose; but we don't want to choose both!
>
> Hugh



--=20
Kinds regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
