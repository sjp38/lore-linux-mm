Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 3BC806B009C
	for <linux-mm@kvack.org>; Thu, 17 Dec 2009 10:04:01 -0500 (EST)
Received: by pwi1 with SMTP id 1so1643927pwi.6
        for <linux-mm@kvack.org>; Thu, 17 Dec 2009 07:02:53 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <Pine.LNX.4.64.0912170937450.3176@sister.anvils>
References: <20091217114630.d353907a.minchan.kim@barrios-desktop>
	 <Pine.LNX.4.64.0912170937450.3176@sister.anvils>
Date: Fri, 18 Dec 2009 00:02:53 +0900
Message-ID: <28c262360912170702j108d7514pb0aa0919aed53e7@mail.gmail.com>
Subject: Re: Question about pte_offset_map_lock
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: linux-mm <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Hi, Hugh.

On Thu, Dec 17, 2009 at 6:54 PM, Hugh Dickins
<hugh.dickins@tiscali.co.uk> wrote:
> On Thu, 17 Dec 2009, Minchan Kim wrote:
>> It may be a dumb question.
>>
>> As I read the code of pte_lock, I have a question.
>> Now, there is pte_offset_map_lock following as.
>>
>> #define pte_offset_map_lock(mm, pmd, address, ptlp) =C2=A0 =C2=A0 \
>> ({ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0\
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 spinlock_t *__ptl =3D pte_lockptr(mm, pmd); =
=C2=A0 =C2=A0 =C2=A0 \
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 pte_t *__pte =3D pte_offset_map(pmd, address=
); =C2=A0 =C2=A0\
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 *(ptlp) =3D __ptl; =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0\
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 spin_lock(__ptl); =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 \
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 __pte; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0\
>> })
>>
>> Why do we grab the lock after getting __pte?
>> Is it possible that __pte might be changed before we grab the spin_lock?
>>
>> Some codes in mm checks original pte by pte_same.
>> There are not-checked cases in proc. As looking over the cases,
>> It seems no problem. But in future, new user of pte_offset_map_lock
>> could mistake with that?
>
> I think you wouldn't be asking the question if we'd called it __ptep.

Absolutely.

>
> It's a (perhaps kmap_atomic) pointer into the page table: the virtual
> address of a page table entry, not the page table entry itself.
>
> You're right that the entry itself could change before we get the lock,
> and pte_same() is what we use to check that an entry is still what we
> were expecting; but the containing page table will remain the same,
> until munmap() or exit_mmap() at least

Yes, In unmap case, it can be protected by mmap_sem.  :)

>
> (For completeness, I ought to add that the entry might even change
> while we have the lock: accessed and dirty bits could get set by a
> racing thread in userspace. =C2=A0There are places where we have to be
> very careful about not missing a dirty bit, but missing an accessed
> bit on rare occasions doesn't matter.)

Indeed!.
Thanks! Hugh.

> Hugh
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
