Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id AABCE6B004D
	for <linux-mm@kvack.org>; Sun,  7 Jun 2009 10:41:39 -0400 (EDT)
Received: by yw-out-1718.google.com with SMTP id 5so1469236ywm.26
        for <linux-mm@kvack.org>; Sun, 07 Jun 2009 08:16:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <Pine.LNX.4.64.0906051906000.14826@sister.anvils>
References: <1244212553-21629-1-git-send-email-minchan.kim@gmail.com>
	 <Pine.LNX.4.64.0906051906000.14826@sister.anvils>
Date: Mon, 8 Jun 2009 00:16:17 +0900
Message-ID: <28c262360906070816h765bf4fag9b426199ac0627d@mail.gmail.com>
Subject: Re: [RFC] remove page_table_lock in anon_vma_prepare
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

Hi, Hugh.

On Sat, Jun 6, 2009 at 3:26 AM, Hugh Dickins<hugh.dickins@tiscali.co.uk> wr=
ote:
> On Fri, 5 Jun 2009, Minchan Kim wrote:
>
>> As I looked over the page_table_lock, it related to page table not anon_=
vma
>>
>> I think anon_vma->lock can protect race against threads.
>> Do I miss something ?
>>
>> If I am right, we can remove unnecessary page_table_lock holding
>> in anon_vma_prepare. We can get performance benefit.
>>
>> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
>> Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>
>> Cc: Rik van Riel <riel@redhat.com>
>> Cc: Nick Piggin <npiggin@suse.de>
>
> No, NAK to this one. =C2=A0Look above the context shown in the patch:
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0anon_vma =3D find_=
mergeable_anon_vma(vma);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0allocated =3D NULL=
;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!anon_vma) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0anon_vma =3D anon_vma_alloc();
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0if (unlikely(!anon_vma))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return -ENOMEM;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0allocated =3D anon_vma;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_lock(&anon_vm=
a->lock);
>
> So if find_mergeable_anon_vma failed to find a suitable neighbouring
> vma to share with, we'll have got the anon_vma from anon_vma_alloc().
>
> Two threads could perfectly well do that concurrently (mmap_sem is
> held only for reading), each allocating a separate fresh anon_vma,
> then they'd each do spin_lock(&anon_vma->lock), but on _different_
> anon_vmas, so wouldn't exclude each other at all: we need a common
> lock to exclude that race, and abuse page_table_lock for the purpose.

Indeed!
I have missed it until now.
In fact, I expected whoever expert like you point me out.


> (As I expect you've noticed, we used not to bother with the spin_lock
> on anon_vma->lock when we'd freshly allocated the anon_vma, it looks
> as if it's unnecessary. =C2=A0But in fact Nick and Linus found there's a
> subtle reason why it is necessary even then - hopefully the git log
> explains it, or I could look up the mails if you want, but at this
> moment the details escape me.

Hmm. I didn't follow up that at that time.

After you noticed me, I found that.
commit d9d332e0874f46b91d8ac4604b68ee42b8a7a2c6
Author: Linus Torvalds <torvalds@linux-foundation.org>
Date:   Sun Oct 19 10:32:20 2008 -0700

    anon_vma_prepare: properly lock even newly allocated entries

It's subtle race so I can't digest it fully but I can understand that
following as.

If we don't hold lock at fresh anon_vma, it can be removed and
reallocated by other threads since other cpu's can find it, free,
reallocate before first thread which call anon_vma_prepare adds
anon_vma to list after vma->anon_vma =3D anon_vma

I hope my above explanation is right :)

> And do we need the page_table_lock even when find_mergeable_anon_vma
> succeeds? =C2=A0That also looks as if it's unnecessary, but I've the ghos=
t
> of a memory that it's needed even for that case: I seem to remember
> that there can be a benign race where find_mergeable_anon_vma called
> by concurrent threads could actually return different anon_vmas.
> That also is something I don't want to think too deeply into at
> this instant, but beg me if you wish!)

Unfortunately I can't found this issue mail or changelog.
Hugh. Could you explain this issue more detail in your convenient time ?
I don't mind you ignore me. I don't want you to be busy from me. :)

I always thanks for your kind explanation and learns lots of thing from you=
. :)
Thanks again.

--=20
Kinds regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
